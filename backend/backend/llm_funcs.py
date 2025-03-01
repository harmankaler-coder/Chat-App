import subprocess
import time
import pyautogui
import pygetwindow


def exec_cmd(command: str) -> str:
    process = subprocess.run(command, shell=True, capture_output=True, text=True)
    return process.stdout


def close_window(title: str) -> bool:
    window = pygetwindow.getWindowsWithTitle(title)
    if window:
        window[0].close()
        return True
    return False


def key(keys_press=None, keys_down=None, keys_up=None, delay=0.1):
    """
    Simulates pressing, holding, and releasing keys using pyautogui.

    :param keys_press: List of keys to be pressed and released immediately.
    :param keys_down: List of keys to be held down.
    :param keys_up: List of keys to be released (should match keys held down).
    """
    keys_press = keys_press or []
    keys_down = keys_down or []
    keys_up = keys_up or []

    # Press and release keys immediately
    for key in keys_press:
        pyautogui.press(key)
    # Hold down keys
    for key in keys_down:
        pyautogui.keyDown(key)

    # Release keys
    for key in keys_up:
        pyautogui.keyUp(key)


def wait(delay=1) -> str:
    """
    Waits for a specified delay and returns a message.

    :param delay: The delay in seconds.
    :param message: The message to be displayed.
    :return: The message.
    """
    time.sleep(delay)
    # return message


def enable_code_mode():
    return
