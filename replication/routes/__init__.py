from .logical_replication import logical_router
from .sequential_replication import sequential_router
from fastapi import APIRouter

router = APIRouter()

router.include_router(logical_router)
router.include_router(sequential_router)