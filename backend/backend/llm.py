from typing import Callable, Dict, List
import openai
from openai.types.chat import (
    ChatCompletionUserMessageParam,
    ChatCompletionAssistantMessageParam,
    ChatCompletionContentPartParam,
)
from openai.types.chat.chat_completion_content_part_text_param import (
    ChatCompletionContentPartTextParam,
)

from backend.conn import Connection


class LLMChat:
    def __init__(
        self,
        api_key,
        model="gemini-2.0-flash",
        temperature=0.7,
        max_tokens=512,
        base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
        functions: List[Dict] = [],
        tool_choice: str = "required",
        connection: Connection = None,
    ):
        """
        Initializes the LLMChat instance.

        :param api_key: OpenAI API key
        :param model: Model to use
        :param temperature: Controls randomness
        :param max_tokens: Maximum response length
        """
        self.api_key = api_key
        self.model = model
        self.temperature = temperature
        self.max_tokens = max_tokens
        self.chat_history = []  # Stores chat history
        self.functions = functions
        self.tool_choice = tool_choice
        self.client = openai.OpenAI(api_key=self.api_key, base_url=base_url)
        self.connection = connection
        self.response_id = 0

    def chat(self, user_input):
        """
        Sends a user message to the model and gets a response.

        :param user_input: The user's message
        :return: The model's response
        """

        self.connection.send(
            b"USR" + self.response_id.to_bytes(4, "big") + user_input.encode("utf-8")
        )
        self.chat_history.append(
            {
                "role": "user",
                "content": user_input,
            }
        )

        response = self.client.chat.completions.create(
            model=self.model,
            messages=self.chat_history,
            temperature=self.temperature,
            max_tokens=self.max_tokens,
            tools=self.functions,
            tool_choice=self.tool_choice,
            stream=True,
        )

        for chunk in response:
            if chunk.choices[0].delta.content is not None:
                self.connection.send(
                    b"LLM"
                    + self.response_id.to_bytes(4, "big")
                    + chunk.choices[0].delta.content.encode("utf-8")
                )

        reply = response.choices[0].message
        self.chat_history.append(reply)

        return reply

    def reset_chat(self):
        """Clears the chat history."""
        self.chat_history = []
