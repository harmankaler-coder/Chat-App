import pytesseract
import pyautogui
import cv2
import numpy as np

def screen_ocr(tesseract_path=None):
    if tesseract_path:
        pytesseract.pytesseract.tesseract_cmd = tesseract_path

    screenshot = pyautogui.screenshot()

    screenshot_cv = cv2.cvtColor(np.array(screenshot), cv2.COLOR_RGB2BGR)

    gray = cv2.cvtColor(screenshot_cv, cv2.COLOR_BGR2GRAY)

    data = pytesseract.image_to_data(gray, config="--psm 6", output_type=pytesseract.Output.DICT)

    # Draw bounding boxes around detected text
    for i in range(len(data["text"])):
        if data["text"][i].strip():  # Ignore empty text
            x, y, w, h = data["left"][i], data["top"][i], data["width"][i], data["height"][i]
            cv2.rectangle(screenshot_cv, (x, y), (x + w, y + h), (0, 255, 0), 2)
            cv2.putText(screenshot_cv, data["text"][i], (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
            print(f"Detected text: '{data['text'][i]}' at ({x}, {y}, {w}, {h})")

    # Show the image with detected text
    cv2.imshow("Detected Text", screenshot_cv)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    return data["text"]  # Return extracted text

def main():
    text = screen_ocr()
    print("Extracted text:", text)


