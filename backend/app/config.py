import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # Supabase Configuration
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")
    SUPABASE_ANON_KEY: str = os.getenv("SUPABASE_ANON_KEY", "")
    
    # JWT Configuration
    JWT_SECRET: str = os.getenv("JWT_SECRET", "your-secret-key")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Storage Configuration
    STORAGE_BUCKET: str = "demo-bucket"
    
    # CORS Configuration
    ALLOWED_ORIGINS: list = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:8000",
        "https://your-frontend-domain.com"
    ]

settings = Settings() 