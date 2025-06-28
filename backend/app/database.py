from supabase import create_client, Client
from .config import settings

def get_supabase_client() -> Client:
    """Get Supabase client instance"""
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)

def get_supabase_anon_client() -> Client:
    """Get Supabase anonymous client instance for public operations"""
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY) 