from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import video, health
from app.config import settings

# Create FastAPI app
app = FastAPI(
    title="Stride API",
    description="Running form analysis API (no authentication)",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router)
app.include_router(video.router)

@app.get("/")
async def root():
    """
    Root endpoint
    """
    return {
        "message": "Welcome to Stride API (no authentication)",
        "version": "1.0.0",
        "docs": "/docs"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

    