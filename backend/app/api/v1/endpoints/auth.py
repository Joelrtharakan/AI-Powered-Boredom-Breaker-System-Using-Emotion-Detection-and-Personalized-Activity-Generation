import ast
from fastapi import APIRouter, Depends, HTTPException, status
# force reload
from sqlalchemy.orm import Session
from datetime import timedelta
from pydantic import BaseModel
from typing import List, Optional

from app.db.session import SessionLocal
from app.core import security, config
from app.models.user import User
from app.models.token import RefreshToken
from app.schemas.user import UserCreate, UserLogin, Token

settings = config.settings
router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class RefreshRequest(BaseModel):
    refresh_token: str

class LogoutRequest(BaseModel):
    refresh_token: str

@router.post("/register", response_model=Token)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == user_in.email).first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this email already exists in the system.",
        )
    
    user = User(
        email=user_in.email,
        username=user_in.username,
        password_hash=security.get_password_hash(user_in.password),
        interests=str(user_in.interests) # simplify for now
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = security.create_access_token(
        user.id, expires_delta=access_token_expires
    )
    refresh_token = security.create_refresh_token(user.id)
    
    # Store refresh token in DB
    db_token = RefreshToken(token_hash=refresh_token, user_id=user.id, expires_at=security.datetime.utcnow() + timedelta(days=7))
    db.add(db_token)
    db.commit()
    
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "refresh_token": refresh_token,
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "is_active": True,
            "interests": user_in.interests
        }
    }

@router.post("/login", response_model=Token)
def login(login_req: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == login_req.email).first()
    print(f"DEBUG: Login attempt for {login_req.email}. User found: {user is not None}")
    if user:
         print(f"DEBUG: Password verification: {security.verify_password(login_req.password, user.password_hash)}")

    if not user or not security.verify_password(login_req.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = security.create_access_token(
        user.id, expires_delta=access_token_expires
    )
    refresh_token = security.create_refresh_token(user.id)

    # Store refresh token
    # Revoke old ones? For simplicity, just add new one
    db_token = RefreshToken(token_hash=refresh_token, user_id=user.id, expires_at=security.datetime.utcnow() + timedelta(days=7))
    db.add(db_token)
    db.commit()
    
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "refresh_token": refresh_token,
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "is_active": True,
            "interests": ast.literal_eval(user.interests) if user.interests else []
        }
    }

@router.post("/refresh", response_model=Token)
def refresh_token(req: RefreshRequest, db: Session = Depends(get_db)):
    # Verify token exists in DB and is valid
    db_token = db.query(RefreshToken).filter(RefreshToken.token_hash == req.refresh_token).first()
    if not db_token:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
        
    # In real app: check expiration
    
    user = db.query(User).filter(User.id == db_token.user_id).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = security.create_access_token(
        user.id, expires_delta=access_token_expires
    )
    
    return {
         "access_token": access_token,
         "token_type": "bearer",
         "refresh_token": req.refresh_token # Return same refresh token
    }

@router.post("/logout")
def logout(req: LogoutRequest, db: Session = Depends(get_db)):
    # Revoke token
    db.query(RefreshToken).filter(RefreshToken.token_hash == req.refresh_token).delete()
    db.commit()
    return {"ok": True}

class PasswordResetRequest(BaseModel):
    email: str
    new_password: str

@router.post("/reset-password")
def reset_password(req: PasswordResetRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.password_hash = security.get_password_hash(req.new_password)
    db.commit()
    return {"message": "Password updated successfully"}

class InterestUpdateRequest(BaseModel):
    user_id: int
    interests: List[str]

@router.post("/update-interests")
def update_interests(req: InterestUpdateRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == req.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.interests = str(req.interests)
    db.commit()
    return {"message": "Interests updated successfully", "interests": req.interests}

# --- Profile Feature ---

from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/v1/auth/login")

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_exception
    return user

@router.get("/me")
def read_users_me(current_user: User = Depends(get_current_user)):
    """Get current user details including profile picture"""
    interests_list = []
    if current_user.interests:
        try:
            interests_list = ast.literal_eval(current_user.interests)
        except:
            interests_list = []
            
    return {
        "id": current_user.id,
        "email": current_user.email,
        "username": current_user.username,
        "is_active": current_user.is_active == 1,
        "interests": interests_list,
        "profile_picture": current_user.profile_picture
    }

class ProfilePicUpdate(BaseModel):
    image_base64: str

@router.post("/update-profile-picture")
def update_profile_picture(req: ProfilePicUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Update profile picture (stores base64 string in DB)"""
    # Simply update the text column
    current_user.profile_picture = req.image_base64
    db.commit()
    return {"message": "Profile picture updated successfully"}
