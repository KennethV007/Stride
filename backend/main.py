import dotenv
import os
from supabase import create_client, Client
from fastapi import FastAPI, UploadFile, File, HTTPException
import shutil
import subprocess
import uuid
import sys
import json


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

    # Upload to Supabase Storage (original video, optional)
    # try:
    #     with open(temp_filename, "rb") as f:
    #         res = supabase.storage.from_("videos").upload(temp_filename, f)
    #     if res.get("error"):
    #         raise HTTPException(status_code=500, detail=f"Failed to upload to Supabase: {res['error']['message']}")
    # except Exception as e:
    #     os.remove(temp_filename)
    #     raise HTTPException(status_code=500, detail=f"Supabase upload error: {str(e)}")

    # Run analysis script with input and output paths
    processed_video_path = f"skeleton_{os.path.basename(temp_filename)}"
    try:
        result = subprocess.run([
            sys.executable, "analyze.py", temp_filename, processed_video_path
        ], capture_output=True, text=True, check=True)
        analysis_json = result.stdout.strip()
        # Find the last line that is valid JSON (in case of debug prints)
        last_json = None
        for line in analysis_json.splitlines()[::-1]:
            try:
                last_json = json.loads(line)
                break
            except Exception:
                continue
        if not last_json:
            raise HTTPException(status_code=500, detail=f"Analysis script did not return valid JSON. Output: {analysis_json}")
        if 'error' in last_json:
            raise HTTPException(status_code=500, detail=f"Analysis error: {last_json['error']}")
        analysis = last_json
    except subprocess.CalledProcessError as e:
        os.remove(temp_filename)
        if os.path.exists(processed_video_path):
            os.remove(processed_video_path)
        raise HTTPException(status_code=500, detail=f"Analysis error: {e.stderr}")

    # Upload processed video to Supabase Storage
    try:
        with open(processed_video_path, "rb") as f:
            res = supabase.storage.from_("demo-bucket").upload(
                "public/processed.mp4", f, {"content-type": "video/mp4", "upsert": "true"}
            )
    except Exception as e:
        os.remove(temp_filename)
        if os.path.exists(processed_video_path):
            os.remove(processed_video_path)
        raise HTTPException(status_code=500, detail=f"Supabase upload error: {str(e)}")

    # Clean up local files
    os.remove(temp_filename)
    if os.path.exists(processed_video_path):
        os.remove(processed_video_path)

    # Construct a public URL (if bucket is public)
    supabase_url = os.getenv('SUPABASE_URL')
    if supabase_url.endswith('/'):
        supabase_url = supabase_url[:-1]
    public_url = f"{supabase_url}/storage/v1/object/public/demo-bucket/public/processed.mp4"
    return {"processed_video_url": public_url, "analysis": analysis}

    