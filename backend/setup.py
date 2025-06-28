#!/usr/bin/env python3
"""
Setup script for Stride Backend
"""

import os
import sys
import subprocess
import venv
from pathlib import Path

def run_command(command, description):
    """Run a command and handle errors"""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"✅ {description} completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed: {e.stderr}")
        return False

def create_env_file():
    """Create .env file if it doesn't exist"""
    env_file = Path(".env")
    if not env_file.exists():
        print("📝 Creating .env file...")
        env_content = """# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_KEY=your_supabase_service_role_key_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# JWT Configuration (optional)
JWT_SECRET=your_jwt_secret_key_here

# Storage Configuration
STORAGE_BUCKET=demo-bucket
"""
        with open(env_file, "w") as f:
            f.write(env_content)
        print("✅ .env file created. Please update it with your actual values.")
    else:
        print("✅ .env file already exists")

def main():
    print("🚀 Setting up Stride Backend...")
    
    # Check if Python 3.8+ is available
    if sys.version_info < (3, 8):
        print("❌ Python 3.8 or higher is required")
        sys.exit(1)
    
    # Create virtual environment if it doesn't exist
    venv_path = Path("venv")
    if not venv_path.exists():
        print("📦 Creating virtual environment...")
        venv.create("venv", with_pip=True)
        print("✅ Virtual environment created")
    else:
        print("✅ Virtual environment already exists")
    
    # Determine the correct pip path
    if os.name == 'nt':  # Windows
        pip_path = "venv\\Scripts\\pip"
        python_path = "venv\\Scripts\\python"
    else:  # Unix/Linux/Mac
        pip_path = "venv/bin/pip"
        python_path = "venv/bin/python"
    
    # Install dependencies
    if not run_command(f"{pip_path} install -r requirements.txt", "Installing dependencies"):
        print("❌ Failed to install dependencies")
        sys.exit(1)
    
    # Create .env file
    create_env_file()
    
    print("\n🎉 Setup completed successfully!")
    print("\n📋 Next steps:")
    print("1. Update the .env file with your Supabase credentials")
    print("2. Activate the virtual environment:")
    if os.name == 'nt':
        print("   venv\\Scripts\\activate")
    else:
        print("   source venv/bin/activate")
    print("3. Run the application:")
    print("   uvicorn main:app --reload")
    print("\n📚 For more information, see README.md")

if __name__ == "__main__":
    main() 