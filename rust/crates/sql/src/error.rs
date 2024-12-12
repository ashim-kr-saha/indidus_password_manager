use rusqlite;
use std::fmt;
use std::io;

#[derive(Debug)]
pub enum SqlError {
    QueryReturnedNoRows,
    IoError(io::Error),
    SqliteError(rusqlite::Error),
    InvalidPath(String),
    PoolInitializationError(String),
    DatabaseError(String),
    MigrationError(String),
    PoolCreationError(String),
    ConnectionError(String),
    PoolNotInitialized,
}

impl fmt::Display for SqlError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            SqlError::QueryReturnedNoRows => write!(f, "Query returned no rows"),
            SqlError::IoError(err) => write!(f, "IO error: {}", err),
            SqlError::SqliteError(err) => write!(f, "SQLite error: {}", err),
            SqlError::InvalidPath(path) => write!(f, "Invalid path: {}", path),
            SqlError::PoolInitializationError(msg) => {
                write!(f, "Pool initialization error: {}", msg)
            }
            SqlError::PoolCreationError(msg) => {
                write!(f, "Pool creation error: {}", msg)
            }
            SqlError::DatabaseError(msg) => write!(f, "Database error: {}", msg),
            SqlError::MigrationError(msg) => write!(f, "Migration error: {}", msg),
            SqlError::ConnectionError(msg) => write!(f, "Connection error: {}", msg),
            SqlError::PoolNotInitialized => write!(f, "Pool not initialized"),
        }
    }
}

impl std::error::Error for SqlError {}

impl From<io::Error> for SqlError {
    fn from(err: io::Error) -> Self {
        SqlError::IoError(err)
    }
}

impl From<rusqlite::Error> for SqlError {
    fn from(error: rusqlite::Error) -> Self {
        SqlError::DatabaseError(error.to_string())
    }
}

impl From<r2d2::Error> for SqlError {
    fn from(error: r2d2::Error) -> Self {
        SqlError::PoolCreationError(error.to_string())
    }
}

// impl From<rusqlite::MigrationError> for SqlError {
//     fn from(error: rusqlite::MigrationError) -> Self {
//         SqlError::MigrationError(error.to_string())
//     }
// }

// impl From<r2d2::Error> for SqlError {
//     fn from(error: r2d2::Error) -> Self {
//         SqlError::PoolInitializationError(error.to_string())
//     }
// }
