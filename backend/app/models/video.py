from pydantic import BaseModel
from typing import Optional, Dict, Any

class VideoUploadResponse(BaseModel):
    processed_video_url: str
    analysis: Dict[str, Any]

class VideoAnalysis(BaseModel):
    video_id: str
    analysis_data: Dict[str, Any]
    processed_video_url: Optional[str] = None
    status: str = "completed"  # pending, processing, completed, failed 