# Stride Backend API

A FastAPI-based backend for running form analysis. **No authentication required**—anyone can upload a video and get analysis.

## Features

- **Video Analysis**: Upload and analyze running form videos with MediaPipe
- **File Storage**: Store processed videos in Supabase Storage
- **RESTful API**: Well-organized routes with proper error handling
- **CORS Support**: Configured for frontend integration

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── config.py              # Configuration and environment variables
│   ├── database.py            # Supabase client initialization
│   ├── models/
│   │   └── video.py          # Video-related Pydantic models
│   └── routes/
│       ├── __init__.py
│       ├── video.py          # Video upload and analysis endpoints
│       └── health.py         # Health check endpoints
├── main.py                   # FastAPI application entry point
├── analyze.py               # Video analysis script
├── requirements.txt         # Python dependencies
└── README.md               # This file
```

## Setup

### 1. Environment Variables

Create a `.env` file in the backend directory with the following variables:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_KEY=your_supabase_service_role_key_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Storage Configuration
STORAGE_BUCKET=demo-bucket
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run the Application

```bash
# Development
uvicorn main:app --reload

# Production
uvicorn main:app --host 0.0.0.0 --port 8000
```

## API Endpoints

### Video Analysis (`/video`)

- `POST /video/upload` - Upload and analyze a video (no authentication required)

### Health Checks (`/health`)

- `GET /health/` - Basic health check
- `GET /health/ready` - Readiness check

## Video Upload Flow

1. **Upload**: Send video file to `/video/upload`
2. **Analysis**: Backend processes video with MediaPipe
3. **Storage**: Processed video uploaded to Supabase Storage
4. **Response**: Returns analysis data and video URL

## Error Handling

The API includes comprehensive error handling:

- **400 Bad Request**: Invalid input data
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server-side errors

## CORS Configuration

The API is configured to accept requests from:
- `http://localhost:3000` (React/Next.js)
- `http://localhost:8080` (Vue.js)
- `http://localhost:8000` (Development)
- `https://your-frontend-domain.com` (Production)

## Development

### Adding New Routes

1. Create a new router file in `app/routes/`
2. Define your endpoints with proper models
3. Include the router in `main.py`

### Adding New Models

1. Create Pydantic models in `app/models/`
2. Use for request/response validation

### Environment Variables

Add new variables to `app/config.py` and update the `.env` template.

## Production Deployment

1. Set up proper environment variables
2. Configure CORS origins for your domain
3. Set up Supabase storage bucket permissions
4. Use a production WSGI server like Gunicorn

## API Documentation

Once the server is running, visit:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc` 