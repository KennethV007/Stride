from fastapi import APIRouter, HTTPException, UploadFile, File, status
from supabase import Client
from ..database import get_supabase_client
from ..models.video import VideoUploadResponse
from ..config import settings
import shutil
import subprocess
import uuid
import sys
import json
import os

router = APIRouter(prefix="/video", tags=["video"])

@router.post("/upload", response_model=VideoUploadResponse)
async def upload_video(
    file: UploadFile = File(...),
):
    """
    Upload and analyze a video file (public, no authentication)
    """
    # Validate file type
    if not file.content_type.startswith('video/'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be a video"
        )
    
    # Save uploaded file locally
    temp_filename = f"temp_{uuid.uuid4()}_{file.filename}"
    try:
        with open(temp_filename, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save uploaded file: {str(e)}"
        )

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
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
                detail=f"Analysis script did not return valid JSON. Output: {analysis_json}"
            )
            
        if 'error' in last_json:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
                detail=f"Analysis error: {last_json['error']}"
            )
            
        analysis = last_json
        
    except subprocess.CalledProcessError as e:
        # Clean up files on error
        if os.path.exists(temp_filename):
            os.remove(temp_filename)
        if os.path.exists(processed_video_path):
            os.remove(processed_video_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analysis error: {e.stderr}"
        )

    # Upload processed video to Supabase Storage
    try:
        with open(processed_video_path, "rb") as f:
            # Create unique filename for the processed video
            processed_filename = f"processed_{uuid.uuid4()}.mp4"
            supabase: Client = get_supabase_client()
            res = supabase.storage.from_(settings.STORAGE_BUCKET).upload(
                f"public/{processed_filename}", 
                f, 
                {"content-type": "video/mp4", "upsert": "true"}
            )
    except Exception as e:
        # Clean up files on error
        if os.path.exists(temp_filename):
            os.remove(temp_filename)
        if os.path.exists(processed_video_path):
            os.remove(processed_video_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Supabase upload error: {str(e)}"
        )

    # Clean up local files
    if os.path.exists(temp_filename):
        os.remove(temp_filename)
    if os.path.exists(processed_video_path):
        os.remove(processed_video_path)

    # Construct a public URL
    supabase_url = settings.SUPABASE_URL
    if supabase_url.endswith('/'):
        supabase_url = supabase_url[:-1]
    public_url = f"{supabase_url}/storage/v1/object/public/{settings.STORAGE_BUCKET}/public/{processed_filename}"
    
    return VideoUploadResponse(
        processed_video_url=public_url,
        analysis=analysis
    ) 