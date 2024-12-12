use crate::config::Config;
use crate::error::BackupError;
use log::info;
use rusqlite::Connection;

pub fn verify_backup(config: &Config) -> Result<(), BackupError> {
    info!("Starting backup verification...");

    let mut tmp_files_to_remove: Vec<String> = vec![];

    // Open source database
    let source_conn = Connection::open(&config.source_db)?;

    // Open backup database
    let backup_path = if config.encryption {
        // Decrypt to a temporary file
        let decrypted_path = format!("{}_decrypted.db", &config.backup_path);
        let key = match &config.encryption_key {
            Some(k) => {
                let mut key_bytes = [0u8; 32];
                k.bytes()
                    .take(32)
                    .enumerate()
                    .for_each(|(i, b)| key_bytes[i] = b);
                key_bytes
            }
            None => return Err(BackupError::VerificationError),
        };
        crate::encryption::decrypt_file(&config.backup_path, &decrypted_path, &key)?;
        // Add file path to tmp_files_to_remove
        tmp_files_to_remove.push(decrypted_path.clone());
        decrypted_path
    } else {
        config.backup_path.clone()
    };

    let backup_path = if config.compression {
        // Decompress to a temporary file
        let decompressed_path = format!("{}_decompressed.db", &backup_path);
        crate::compression::decompress_file(&backup_path, &decompressed_path)?;
        // Update backup_path to decompressed file
        tmp_files_to_remove.push(decompressed_path.clone());
        decompressed_path
    } else {
        backup_path
    };

    let backup_conn = Connection::open(&backup_path)?;

    // Compare table schemas
    let source_schema: Vec<String> = source_conn
        .prepare("SELECT sql FROM sqlite_master WHERE type='table';")?
        .query_map([], |row| row.get(0))?
        .collect::<Result<_, _>>()?;

    let backup_schema: Vec<String> = backup_conn
        .prepare("SELECT sql FROM sqlite_master WHERE type='table';")?
        .query_map([], |row| row.get(0))?
        .collect::<Result<_, _>>()?;

    if source_schema != backup_schema {
        return Err(BackupError::VerificationError);
    }

    // Compare data counts
    let tables: Vec<String> = source_conn
        .prepare("SELECT name FROM sqlite_master WHERE type='table';")?
        .query_map([], |row| row.get(0))?
        .collect::<Result<_, _>>()?;

    for table in tables {
        let source_count: i64 =
            source_conn.query_row(&format!("SELECT COUNT(*) FROM {}", table), [], |row| {
                row.get(0)
            })?;
        let backup_count: i64 =
            backup_conn.query_row(&format!("SELECT COUNT(*) FROM {}", table), [], |row| {
                row.get(0)
            })?;
        if source_count != backup_count {
            return Err(BackupError::VerificationError);
        }
    }

    // Clean up temporary files if any
    for tmp_file in tmp_files_to_remove {
        let _ = std::fs::remove_file(tmp_file);
    }

    info!("Backup verification successful.");
    Ok(())
}
