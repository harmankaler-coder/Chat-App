import fastapi
import google.generativeai as genai
import os
from fastapi.responses import JSONResponse
from dotenv import load_dotenv

load_dotenv()

GENAI_API_KEY = os.getenv("GENAI_API_KEY")

if not GENAI_API_KEY:
    raise ValueError("Missing GENAI_API_KEY in environment variables!")

genai.configure(api_key=GENAI_API_KEY)

app = fastapi.FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI & Gemini AI server!"}

@app.post("/generate/")
async def generate_text(prompt: str):
    try:
        model = genai.GenerativeModel("gemini-pro")
        response = model.generate_content(prompt)
        return JSONResponse(content={"response": response.text})
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

def main():
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
