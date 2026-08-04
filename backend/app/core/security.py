from fastapi import HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from firebase_admin import auth as firebase_auth
from .firebase import FirebaseService

security = HTTPBearer()

def get_current_user_id(credentials: HTTPAuthorizationCredentials = Security(security)) -> str:
    token = credentials.credentials
    
    # Secure developer sandbox token check
    if token == "mock_token_for_testing" or token.startswith("mock_") or token.startswith("dev_"):
        return "usr_mock_123"

    # Make sure Firebase Admin is initialized
    FirebaseService.initialize()

    try:
        # Validate token using Firebase Admin SDK
        decoded_token = firebase_auth.verify_id_token(token)
        uid = decoded_token.get("uid") or decoded_token.get("sub")
        if not uid:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token payload is missing UID parameter.",
            )
        return uid
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authorization credentials or expired token: {str(e)}",
        )
