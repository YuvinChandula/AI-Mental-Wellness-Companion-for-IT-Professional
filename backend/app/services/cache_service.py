import time
from typing import Any, Dict, Optional

class CacheService:
    # Dictionary mapping string key to tuple of (value, expiry_timestamp)
    _cache: Dict[str, tuple] = {}

    @classmethod
    def get(cls, key: str) -> Optional[Any]:
        if key not in cls._cache:
            return None
        val, expiry = cls._cache[key]
        if time.time() > expiry:
            del cls._cache[key]
            return None
        return val

    @classmethod
    def set(cls, key: str, value: Any, ttl: int = 300) -> None:
        cls._cache[key] = (value, time.time() + ttl)

    @classmethod
    def delete(cls, key: str) -> None:
        if key in cls._cache:
            del cls._cache[key]

    @classmethod
    def clear(cls) -> None:
        cls._cache.clear()
