from pydantic_settings import BaseSettings
from pydantic import Field
from pathlib import Path
from typing import Optional


class Settings(BaseSettings):
    APP_ENV: str = Field(default="development", validation_alias="APP_ENV")

    # ---------------------------------------------------------------------------
    # Database — all individual fields loaded from .env, no hardcoded fallbacks
    # ---------------------------------------------------------------------------
    POSTGRES_USER: str = Field(validation_alias="POSTGRES_USER")
    POSTGRES_PASSWORD: str = Field(validation_alias="POSTGRES_PASSWORD")
    POSTGRES_HOST: str = Field(validation_alias="POSTGRES_HOST")
    POSTGRES_PORT: int = Field(validation_alias="POSTGRES_PORT")
    POSTGRES_DB: str = Field(validation_alias="POSTGRES_DB")
    # Optional explicit full URL override (takes precedence if set)
    DATABASE_URL_OVERRIDE: Optional[str] = Field(default=None, validation_alias="DATABASE_URL")

    # ---------------------------------------------------------------------------
    # Stripe Payment Gateway — MUST be in .env, no defaults
    # ---------------------------------------------------------------------------
    STRIPE_SECRET_KEY: str = Field(validation_alias="STRIPE_SECRET_KEY")
    STRIPE_WEBHOOK_SECRET: str = Field(validation_alias="STRIPE_WEBHOOK_SECRET")
    STRIPE_PUBLISHABLE_KEY: str = Field(validation_alias="STRIPE_PUBLISHABLE_KEY")

    # ---------------------------------------------------------------------------
    # Admin Super User — hardcoded logic, credentials must come from .env
    # ---------------------------------------------------------------------------
    ADMIN_EMAIL: str = Field(validation_alias="ADMIN_EMAIL")
    ADMIN_PASSWORD: str = Field(validation_alias="ADMIN_PASSWORD")

    # ---------------------------------------------------------------------------
    # Security & Auth
    # ---------------------------------------------------------------------------
    JWT_SECRET: str = Field(validation_alias="JWT_SECRET")
    JWT_ALGORITHM: str = Field(default="HS256", validation_alias="JWT_ALGORITHM")

    # ---------------------------------------------------------------------------
    # Cache & Services
    # ---------------------------------------------------------------------------
    REDIS_URL: str = Field(validation_alias="REDIS_URL")

    # ---------------------------------------------------------------------------
    # Cloudinary Storage
    # ---------------------------------------------------------------------------
    CLOUDINARY_CLOUD_NAME: Optional[str] = Field(default=None, validation_alias="CLOUDINARY_CLOUD_NAME")
    CLOUDINARY_API_KEY: Optional[str] = Field(default=None, validation_alias="CLOUDINARY_API_KEY")
    CLOUDINARY_API_SECRET: Optional[str] = Field(default=None, validation_alias="CLOUDINARY_API_SECRET")
    CLOUDINARY_UPLOAD_PRESET: Optional[str] = Field(default=None, validation_alias="CLOUDINARY_UPLOAD_PRESET")
    CLOUDINARY_URL: Optional[str] = Field(default=None, validation_alias="CLOUDINARY_URL")

    # ---------------------------------------------------------------------------
    # PhonePe & Paytm Payment Gateways (India)
    # ---------------------------------------------------------------------------
    PHONEPE_MERCHANT_ID: Optional[str] = Field(default=None, validation_alias="PHONEPE_MERCHANT_ID")
    PHONEPE_SALT_KEY: Optional[str] = Field(default=None, validation_alias="PHONEPE_SALT_KEY")
    PHONEPE_SALT_INDEX: Optional[int] = Field(default=1, validation_alias="PHONEPE_SALT_INDEX")
    PHONEPE_ENV: Optional[str] = Field(default="UAT", validation_alias="PHONEPE_ENV")

    PAYTM_MID: Optional[str] = Field(default=None, validation_alias="PAYTM_MID")
    PAYTM_MERCHANT_KEY: Optional[str] = Field(default=None, validation_alias="PAYTM_MERCHANT_KEY")
    PAYTM_WEBSITE: Optional[str] = Field(default="WEBSTAGING", validation_alias="PAYTM_WEBSITE")
    PAYTM_ENV: Optional[str] = Field(default="test", validation_alias="PAYTM_ENV")

    model_config = {
        "env_file": (
            str(Path(__file__).resolve().parent.parent.parent / ".env"),
            ".env",
            "../.env",
        ),
        "env_file_encoding": "utf-8",
        "extra": "ignore",
    }

    @property
    def DATABASE_URL(self) -> str:
        if self.DATABASE_URL_OVERRIDE:
            return self.DATABASE_URL_OVERRIDE
        return (
            f"postgresql+psycopg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )


settings = Settings()
