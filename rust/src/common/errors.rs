#![allow(dead_code)]

use thiserror::Error;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("Library error: {0}")]
    LibraryError(String),
    #[error("User not found")]
    UserNotFound,
    #[error("Database error: {0}")]
    DatabaseError(#[from] sql::SqlError),
    #[error("Encryption error: {0}")]
    EncryptionError(#[from] bcrypt::BcryptError),
    #[error("Password hash error: {0}")]
    PasswordHashError(String),
    #[error("JWT key error: {0}")]
    JWTKeyError(#[from] jsonwebtoken::errors::Error),
    #[error("JWT token expired")]
    JWTTokenExpired,
    #[error("Username too short")]
    UsernameTooShort,
    #[error("Password too short")]
    PasswordTooShort,
    #[error("Password too weak")]
    PasswordTooWeak,
    #[error("Invalid email")]
    InvalidEmail,
    #[error("Password too long")]
    PasswordTooLong,
    #[error("Password contains invalid characters")]
    PasswordNotValid,
    #[error("Password config is invalid")]
    InvalidPasswordConfig,
    #[error("Passwords do not match")]
    PasswordsDoNotMatch,
    #[error("TOTP secret invalid")]
    TOTPSecretInvalid,
    #[error("TOTP verification failed")]
    TOTPVerificationFailed,
    #[error("TOTP already verified")]
    TOTPAlreadyVerified,
    #[error("TOTP not enabled")]
    TOTPNotEnabled,
    #[error("JWT encoding error")]
    JwtEncodingError,
    #[error("JWT decoding error")]
    JwtDecodingError,
    #[error("Username already exists")]
    UsernameExists,
    #[error("Invalid credentials")]
    InvalidCredentials,
    #[error("Unauthorized")]
    Unauthorized,
    #[error("TOTP secret parse error")]
    TOTPSecretParseError,
    #[error("TOTP already enabled")]
    TOTPAlreadyEnabled,
    #[error("Internal server error")]
    InternalServerError,
    #[error("QR code generation error")]
    QRCodeGenerationError,
}

impl From<argon2::password_hash::Error> for AppError {
    fn from(err: argon2::password_hash::Error) -> Self {
        // Convert argon2 error to AppError
        AppError::PasswordHashError(err.to_string()) // Adjust this line based on your AppError variants
    }
}
