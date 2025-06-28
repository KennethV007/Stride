from fastapi import APIRouter

router = APIRouter(prefix="/health", tags=["health"])

@router.get("/")
async def health_check():
    """
    Basic health check endpoint
    """
    return {"status": "healthy", "message": "Stride API is running"}

@router.get("/ready")
async def readiness_check():
    """
    Readiness check for deployment
    """
    return {"status": "ready", "message": "Stride API is ready to serve requests"} 