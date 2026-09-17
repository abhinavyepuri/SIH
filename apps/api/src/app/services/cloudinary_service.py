import logging
import cloudinary
import cloudinary.uploader
from typing import BinaryIO, Optional
from ..config import settings

logger = logging.getLogger(__name__)


def is_cloudinary_configured() -> bool:
    """Checks if any valid Cloudinary configuration is present."""
    if getattr(settings, "CLOUDINARY_URL", None):
        return True
    if settings.CLOUDINARY_CLOUD_NAME and settings.CLOUDINARY_API_KEY and settings.CLOUDINARY_API_SECRET:
        return True
    if settings.CLOUDINARY_CLOUD_NAME and settings.CLOUDINARY_UPLOAD_PRESET:
        return True
    return False


def configure_cloudinary():
    """Applies Cloudinary configuration based on available settings."""
    cloudinary_url = getattr(settings, "CLOUDINARY_URL", None)
    if cloudinary_url:
        cloudinary.config(cloudinary_url=cloudinary_url, secure=True)
    elif settings.CLOUDINARY_CLOUD_NAME:
        cloudinary.config(
            cloud_name=settings.CLOUDINARY_CLOUD_NAME,
            api_key=settings.CLOUDINARY_API_KEY,
            api_secret=settings.CLOUDINARY_API_SECRET,
            secure=True,
        )


def upload_image_to_cloudinary(file_obj: BinaryIO, folder: str = "artisan_products") -> str:
    """
    Uploads a file object to Cloudinary and returns the secure HTTPS URL.
    
    Raises:
        ValueError: If Cloudinary credentials are missing or upload fails.
    """
    if not is_cloudinary_configured():
        raise ValueError(
            "Cloudinary credentials are not configured in .env. "
            "Please provide CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET (or CLOUDINARY_URL)."
        )

    configure_cloudinary()

    kwargs = {
        "folder": folder,
        "resource_type": "auto",
    }
    if settings.CLOUDINARY_UPLOAD_PRESET:
        kwargs["upload_preset"] = settings.CLOUDINARY_UPLOAD_PRESET

    try:
        if settings.CLOUDINARY_UPLOAD_PRESET and not settings.CLOUDINARY_API_SECRET:
            upload_result = cloudinary.uploader.unsigned_upload(
                file_obj,
                upload_preset=settings.CLOUDINARY_UPLOAD_PRESET,
                folder=folder,
            )
        else:
            upload_result = cloudinary.uploader.upload(
                file_obj,
                **kwargs,
            )
        secure_url = upload_result.get("secure_url")
        if not secure_url:
            raise ValueError("Cloudinary upload failed: secure_url was not returned.")
        return secure_url
    except Exception as e:
        err_msg = str(e)
        logger.error(f"Cloudinary upload error: {err_msg}")
        if 'missing permissions (actions=["create"])' in err_msg or "403" in err_msg:
            raise ValueError(
                "Cloudinary Permission Error: The API Key used does not have permission to create/upload assets. "
                "In your Cloudinary Console (https://console.cloudinary.com), use the Master API Key & Secret from your Dashboard, "
                "or grant 'Manage Assets' / 'Create' permissions to this Access Key under Settings > Access Keys."
            )
        raise ValueError(f"Cloudinary upload failed: {err_msg}")
