import dotenv
import os
from supabase import create_client, Client


if __name__ == "__main__":
    dotenv.load_dotenv()

    supabase: Client = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

