import os
import sys
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import uvicorn

app = FastAPI(title="Health Assistant Backend")

# Enable CORS for Flutter Web client
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In‑memory store for demo purposes
_user_profiles = {}

class UserProfile(BaseModel):
    user_id: str
    age: Optional[int] = None
    gender: Optional[str] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    # Extend with more fields later

class ChatRequest(BaseModel):
    user_id: str
    message: str
    mode: Optional[str] = None  # "short", "detailed", or None (auto)

class ChatResponse(BaseModel):
    reply: str
    sources: List[str] = []  # URLs or citations
    emergency: bool = False
    emergency_message: Optional[str] = None

@app.get("/")
async def root():
    return {
        "status": "healthy",
        "service": "Health Assistant Backend API",
        "docs": "/docs",
        "version": "1.0.0"
    }

@app.get("/profile/{user_id}", response_model=UserProfile)
async def get_profile(user_id: str):
    profile = _user_profiles.get(user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@app.post("/profile", response_model=UserProfile)
async def create_or_update_profile(profile: UserProfile):
    _user_profiles[profile.user_id] = profile
    return profile

try:
    from backend.ai_service import process_health_chat
except ImportError:
    from ai_service import process_health_chat

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    # Get user profile if available for personalized context
    profile = _user_profiles.get(request.user_id)
    profile_dict = profile.model_dump() if profile and hasattr(profile, "model_dump") else (profile.dict() if profile else None)

    response_data = process_health_chat(request.message, profile_dict, mode=request.mode)
    return ChatResponse(
        reply=response_data["reply"],
        sources=response_data["sources"],
        emergency=response_data["emergency"],
        emergency_message=response_data.get("emergency_message"),
    )

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8001))
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            pass
    print(f"Starting Health Assistant Backend on 0.0.0.0:{port}...")
    uvicorn.run(app, host="0.0.0.0", port=port)
