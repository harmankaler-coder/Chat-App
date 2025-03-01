import pytesseract
import pyautogui
import cv2
import numpy as np

def screen_ocr(tesseract_path=None):
    
    if tesseract_path:
        pytesseract.pytesseract.tesseract_cmd = tesseract_path
    
    screenshot = pyautogui.screenshot()
    
    screenshot_cv = cv2.cvtColor(np.array(screenshot), cv2.COLOR_RGB2BGR)
    
    extracted_text = pytesseract.image_to_string(screenshot_cv)
    
    return extracted_text

def main():
    text = screen_ocr()
    print("Extracted text:")
    print(text)
