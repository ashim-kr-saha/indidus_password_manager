use actix_web::HttpResponse;
use anyhow::Error as AnyhowError;
use rust_lib_password::common::errors::AppError;
use std::fmt;

#[derive(Debug)]
pub struct MyAppError(pub AppError);

impl fmt::Display for MyAppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?}", self.0)
    }
}

impl actix_web::ResponseError for MyAppError {
    fn error_response(&self) -> HttpResponse {
        match &self.0 {
            AppError::LibraryError(_) => {
                HttpResponse::InternalServerError().body(self.0.to_string())
            }
            AppError::UserNotFound => HttpResponse::NotFound().body(self.0.to_string()),
            AppError::DatabaseError(_) => HttpResponse::InternalServerError().finish(),
            AppError::EncryptionError(_) => HttpResponse::InternalServerError().finish(),
            AppError::PasswordHashError(_) => HttpResponse::InternalServerError().finish(),
            AppError::JWTKeyError(_) => HttpResponse::InternalServerError().finish(),
            AppError::JWTTokenExpired => HttpResponse::Unauthorized().finish(),
            AppError::UsernameTooShort => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::PasswordTooShort => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::PasswordTooWeak => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::InvalidEmail => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::PasswordTooLong => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::PasswordNotValid => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::InvalidPasswordConfig => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::PasswordsDoNotMatch => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::TOTPSecretInvalid => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::TOTPVerificationFailed => {
                HttpResponse::Unauthorized().body(self.0.to_string())
            }
            AppError::TOTPAlreadyVerified => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::TOTPNotEnabled => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::JwtEncodingError => HttpResponse::InternalServerError().finish(),
            AppError::JwtDecodingError => HttpResponse::Unauthorized().finish(),
            AppError::UsernameExists => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::InvalidCredentials => HttpResponse::Unauthorized().body(self.0.to_string()),
            AppError::Unauthorized => HttpResponse::Unauthorized().finish(),
            AppError::TOTPSecretParseError => HttpResponse::InternalServerError().finish(),
            AppError::TOTPAlreadyEnabled => HttpResponse::BadRequest().body(self.0.to_string()),
            AppError::InternalServerError => HttpResponse::InternalServerError().finish(),
            AppError::QRCodeGenerationError => HttpResponse::InternalServerError().finish(),
        }
    }

    fn status_code(&self) -> actix_web::http::StatusCode {
        actix_web::http::StatusCode::INTERNAL_SERVER_ERROR
    }
}

impl std::convert::From<AppError> for MyAppError {
    fn from(error: AppError) -> Self {
        MyAppError(error)
    }
}

impl std::convert::Into<AppError> for MyAppError {
    fn into(self) -> AppError {
        self.0
    }
}
impl From<AnyhowError> for MyAppError {
    fn from(err: AnyhowError) -> Self {
        MyAppError(AppError::LibraryError(err.to_string()))
    }
}
