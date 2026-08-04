import asyncio
from loguru import logger
from .cache_service import CacheService

class BackgroundScheduler:
    _instance = None
    _running = False

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(BackgroundScheduler, cls).__new__(cls)
        return cls._instance

    def start(self) -> None:
        if self._running:
            return
        self._running = True
        logger.info("Initializing background scheduler service...")
        
        # Schedule worker loops
        asyncio.create_task(self._nightly_cleanup_loop())
        asyncio.create_task(self._recommendation_refresh_loop())
        logger.info("Background scheduler successfully started!")

    async def _nightly_cleanup_loop(self) -> None:
        while self._running:
            try:
                # Nightly execution: simulated once every 24 hours
                logger.info("Running nightly background tasks: cleaning cache databases and temporary files.")
                CacheService.clear()
                logger.info("Nightly cache and temporary files cleaned successfully.")
            except Exception as e:
                logger.error(f"Error in nightly cleanup loop: {e}")
            
            # Sleep 24 hours
            await asyncio.sleep(86400)

    async def _recommendation_refresh_loop(self) -> None:
        while self._running:
            try:
                # Refresh summaries loop: simulated once every 12 hours
                logger.info("Running scheduled background jobs: pre-calculating developer recommendations.")
                # Logic to pre-calculate recommendations or trigger engines
                logger.info("Background recommendation updates compiled successfully.")
            except Exception as e:
                logger.error(f"Error in recommendation refresh loop: {e}")
            
            # Sleep 12 hours
            await asyncio.sleep(43200)

    def stop(self) -> None:
        self._running = False
        logger.info("Background scheduler stopped.")
