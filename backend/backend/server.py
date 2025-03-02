from typing import Callable
import pyaudio
import numpy as np
import whisper
import json

# import threading
import time
from backend.conn import Connection
from backend.llm_funcs import close_window, exec_cmd, key, wait
import llm
import dotenv

config = dotenv.dotenv_values(".env")

# Load Whisper Model
# model = whisper.load_model("turbo")  # "base")
model = whisper.load_model("base")

# Audio Configuration
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 16000  # 16kHz works best for Whisper
CHUNK = 1024

# Voice Activity Detection Parameters
SILENCE_THRESHOLD = 10000  # Adjust based on your microphone sensitivity
SILENCE_DURATION = 1.0  # Seconds of silence to consider speech ended
MIN_SPEECH_DURATION = 0.5  # Minimum seconds to consider as valid speech

# Initialize PyAudio
audio = pyaudio.PyAudio()


func_map = {
    "key": key,
    "wait": wait,
    "close_window": close_window,
    "exec_cmd": exec_cmd,
}

functions = [
    {
        "type": "function",
        "function": {
            "name": "key",
            "description": "Press, hold, and release keys.",
            "parameters": {
                "type": "object",
                "properties": {
                    "keys_press": {
                        "type": "string",
                        "description": "The keys to be pressed and released immediately.",
                    },
                    "keys_down": {
                        "type": "string",
                        "description": "The keys to be held down.",
                    },
                    "keys_up": {
                        "type": "string",
                        "description": "The keys to be released (should match keys held down).",
                    },
                },
                "required": [],
                "additionalProperties": False,
            },
            "strict": True,
        },
    },
    {
        "type": "function",
        "function": {
            "name": "exec_cmd",
            "description": "Execute a shell command. You can open applications, run scripts, etc.",
            "parameters": {
                "type": "object",
                "properties": {
                    "command": {
                        "type": "string",
                        "description": "The shell command to be executed.",
                    }
                },
                "required": [],
                "additionalProperties": False,
            },
            "strict": True,
        },
    },
    {
        "type": "function",
        "function": {
            "name": "wait",
            "description": "Wait for a specified delay before executing further commands.",
            "parameters": {
                "type": "object",
                "properties": {
                    "delay": {
                        "type": "integer",
                        "description": "The delay in seconds.",
                    }
                },
                "required": [],
                "additionalProperties": False,
            },
            "strict": True,
        },
    },
    {
        "type": "function",
        "function": {
            "name": "close_window",
            "description": "Close a window.",
            "parameters": {
                "type": "object",
                "properties": {
                    "title": {
                        "type": "string",
                        "description": "The title of the window to be closed.",
                    }
                },
                "required": [],
                "additionalProperties": False,
            },
            "strict": True,
        },
    },
]


class SpeechLLM:
    def __init__(self, connection: Connection):
        self.llm = llm.LLMChat(
            api_key=config["OPENAI_API_KEY"],
            functions=functions,
            tool_choice="auto",
            connection=connection,
        )
        self.connection = connection

    def on_speech_recognised(self, transcription: str):
        if not transcription:
            return
        response = self.llm.chat(transcription)

        if (tool_calls := response.tool_calls) is not None:
            for tool_call in tool_calls:
                exc = self.connection.query(
                    "LLM wants to execute function {tool_call.function.name} with args: {tool_call.function.arguments}",
                    timeout=60,
                )
                if exc == b"y":
                    func_map[tool_call.function.name](
                        **(json.loads(tool_call.function.arguments))
                    )

    def start(self):
        try:
            while True:
                self.speech_recognition(self.on_speech_recognised)
        except KeyboardInterrupt:
            print("\nStopping.")

    @staticmethod
    def is_silent(audio_data, threshold):
        """Check if the audio chunk is below the silence threshold"""
        return np.max(np.abs(audio_data)) < threshold

    @staticmethod
    def process_audio_data(frames, sample_width):
        """Convert audio frames to numpy array suitable for Whisper"""
        # Join all audio frames
        audio_data = b"".join(frames)

        # Convert to numpy array
        audio_np = np.frombuffer(audio_data, dtype=np.int16)

        # Normalize to float32 in range [-1.0, 1.0]
        max_int = 2 ** (8 * sample_width - 1)
        audio_float32 = audio_np.astype(np.float32) / max_int

        return audio_float32

    def speech_recognition(self, callback: Callable[[str], None] = None):
        """Record when speech is detected and transcribe after silence"""
        stream = audio.open(
            format=FORMAT,
            channels=CHANNELS,
            rate=RATE,
            input=True,
            frames_per_buffer=CHUNK,
        )

        sample_width = audio.get_sample_size(FORMAT)

        try:
            # Wait for speech to start
            self.connection.send(b"LISTENING")
            speech_detected = False
            frames = []

            # Keep listening until speech is detected
            while not speech_detected:
        audio_data = b"".join(frames)
                audio_chunk = np.frombuffer(data, dtype=np.int16)
                if not self.is_silent(audio_chunk, SILENCE_THRESHOLD):
                    speech_detected = True
                    frames.append(data)
                    self.connection.send(b"DETECTED")
                    break

            # Continue recording until silence is detected
            silence_count = 0
            recording_start_time = time.time()

            while True:
                data = stream.read(CHUNK, exception_on_overflow=False)
                frames.append(data)

                audio_chunk = np.frombuffer(data, dtype=np.int16)
                if self.is_silent(audio_chunk, SILENCE_THRESHOLD):
                    silence_count += 1
                else:
                    silence_count = 0

                # Check if silence duration threshold is reached
                silence_seconds = silence_count * CHUNK / RATE
                if silence_seconds >= SILENCE_DURATION:
                    total_duration = time.time() - recording_start_time

                    # Only process if speech was long enough
                    if total_duration >= MIN_SPEECH_DURATION:
                        break
                    else:
                        # Reset if it was just a short noise
                        frames = []
                        speech_detected = False
                        break

            # If we have valid speech, process it
            if speech_detected and frames:
                self.connection.send(b"PROCESSING")

                # Convert to format Whisper can use
                audio_float32 = self.process_audio_data(frames, sample_width)

                # Transcribe Audio directly
                result = model.transcribe(
                    audio_float32,
                    fp16=False,  # Disable FP16 for CPU
                    language="en",  # Specify language to improve accuracy
                )

                transcription = result["text"].strip()

                # Print result
                if transcription:
                    callback(transcription)
                else:
                    self.connection.send(b"NOSPEECH")

        except Exception:
            import traceback

            traceback.print_exc()
        finally:
            stream.stop_stream()
            stream.close()
            audio.terminate()


def main():
    print("Connection status active")
    connection = Connection()
    SpeechLLM(connection).start()
