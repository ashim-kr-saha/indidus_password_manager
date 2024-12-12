use once_cell::sync::OnceCell;
use r2d2::Pool;
use r2d2_sqlite::SqliteConnectionManager;
// use rusqlite::Connection;
// use std::fs::OpenOptions;
// use std::io::Read;
// use std::path::Path;

use crate::error::SqlError;

// Add this line at the top of the file
type Result<T> = std::result::Result<T, SqlError>;

#[derive(Debug, Clone)]
pub struct SqlitePool {
    pool: Pool<SqliteConnectionManager>,
}

impl SqlitePool {
    pub fn new(db_file: &str) -> Result<Self> {
        let manager = SqliteConnectionManager::file(db_file);
        let pool = Pool::new(manager).map_err(|e| SqlError::PoolCreationError(e.to_string()))?;
        Ok(Self { pool })
    }

    // Initialize the global pool
    pub fn init_global(db_file: &str) -> Result<()> {
        if Self::global_instance().get().is_some() {
            return Ok(());
        }
        let pool = SqlitePool::new(db_file)?;
        let x = Self::global_instance().set(pool);
        if x.is_err() {
            // Should not happen
            return Err(SqlError::PoolInitializationError(
                "Global pool already initialized".to_owned(),
            ));
        }
        Ok(())
    }

    pub fn get_pool(&self) -> &Pool<SqliteConnectionManager> {
        &self.pool
    }

    pub fn is_initialized() -> bool {
        Self::global_instance().get().is_some()
    }

    // Get the global pool instance
    pub fn global() -> Result<&'static SqlitePool> {
        Self::global_instance()
            .get()
            .ok_or(SqlError::PoolNotInitialized)
    }

    // Private method to access the global instance
    fn global_instance() -> &'static OnceCell<SqlitePool> {
        static INSTANCE: OnceCell<SqlitePool> = OnceCell::new();
        &INSTANCE
    }
}

// Remove this line
// static GLOBAL_POOL: OnceCell<SqlitePool> = OnceCell::new();

pub fn create_file_if_not_exists(file: &str) -> Result<()> {
    let path = std::path::Path::new(file);
    if !path.exists() {
        // Create parent directories if they don't exist
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        // Create the file
        std::fs::File::create(path)?;
    }
    Ok(())
}

pub async fn is_database_initialized() -> Result<bool> {
    let pool = SqlitePool::is_initialized();
    Ok(pool)
}

pub async fn migrate_sqlite(db_file: &str) -> Result<()> {
    create_file_if_not_exists(db_file)?;
    SqlitePool::init_global(db_file)?;
    let pool = SqlitePool::global()?;

    let mut conn = pool.pool.get()?;
    let tx = conn.transaction()?;

    // Create migrations table if it doesn't exist
    tx.execute(
        "CREATE TABLE IF NOT EXISTS migrations (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )",
        [],
    )?;

    // Get list of applied migrations
    let applied_migrations = {
        let mut stmt = tx.prepare("SELECT name FROM migrations")?;
        let rows = stmt.query_map([], |row| row.get(0))?;

        let mut applied = Vec::new();
        for row in rows {
            applied.push(row?);
        }
        applied
    };

    // Define migrations as a vector of tuples (name, content)
    let migrations = vec![
        (
            "0_init.up.sql",
            include_str!("../../../migrations/0_init.up.sql"),
        ),
        // Add more migrations as needed
    ];

    // Apply new migrations
    for (migration_name, migration_content) in migrations {
        if !applied_migrations.contains(&migration_name.to_string()) {
            tx.execute_batch(migration_content)?;

            tx.execute(
                "INSERT INTO migrations (name) VALUES (?1)",
                [migration_name],
            )?;

            println!("Applied migration: {}", migration_name);
        }
    }

    // Commit the transaction
    tx.commit()?;

    Ok(())
}

// New function to get a connection easily
pub fn get_db_connection() -> Result<r2d2::PooledConnection<SqliteConnectionManager>> {
    SqlitePool::global()?
        .pool
        .get()
        .map_err(|e| SqlError::ConnectionError(e.to_string()))
}
