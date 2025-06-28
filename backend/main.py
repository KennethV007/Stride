import dotenv
import os
from supabase import create_client, Client
from fastapi import FastAPI, UploadFile, File, HTTPException
import shutil
import subprocess
import uuid


dotenv.load_dotenv()
app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

# supabase: Client = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))
supabase: Client = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

@app.post("/upload")
async def upload_video(file: UploadFile = File(...)):
    # Save uploaded file locally
    temp_filename = f"temp_{uuid.uuid4()}_{file.filename}"
    with open(temp_filename, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Upload to Supabase Storage
    try:
        with open(temp_filename, "rb") as f:
            res = supabase.storage.from_("demo-bucket").upload(
                file=f,
                path="/public/upload.mp4",
                file_options={"content-type": "video/mp4"}
            )
        if not res:
            raise HTTPException(status_code=500, detail="Failed to upload to Supabase")
    except Exception as e:
        os.remove(temp_filename)
        raise HTTPException(status_code=500, detail=f"Supabase upload error: {str(e)}")

    # Run analysis script
    try:
        result = subprocess.run([
            "python", "analyze.py", temp_filename
        ], capture_output=True, text=True, check=True)
        analysis = result.stdout
    except subprocess.CalledProcessError as e:
        os.remove(temp_filename)
        raise HTTPException(status_code=500, detail=f"Analysis error: {e.stderr}")

    os.remove(temp_filename)
    return {"analysis": analysis}

    