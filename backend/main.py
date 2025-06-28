import dotenv
import os
from supabase import create_client, Client
from fastapi import FastAPI


dotenv.load_dotenv()
app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

# supabase: Client = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

    