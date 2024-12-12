use thiserror::Error;

#[derive(Error, Debug)]
pub enum BackupError {
    #[error("SQLite error: {0}")]
    SqliteError(#[from] rusqlite::Error),

    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),

    #[error("Compression error: {0}")]
    CompressionError(String),

    #[error("Encryption error: {0}")]
    EncryptionError(String),

    #[error("Verification failed")]
    VerificationError,

    #[error("Scheduling error: {0}")]
    SchedulingError(String),

    #[error("Restore error: {0}")]
    RestoreError(String),

    #[error("Configuration error: {0}")]
    ConfigurationError(String),

    #[error("Invalid path: {0}")]
    InvalidPath(String),
}
