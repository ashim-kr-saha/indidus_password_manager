use crate::compression;
use crate::config::Config;
use crate::encryption;
use crate::error::BackupError;
use crate::schedule::Scheduler;
use crate::verification;
use log::info;
// use std::fs;
use std::{
    fs,
    path::{Path, PathBuf},
};

pub struct Backup {
    config: Config,
}

impl Backup {
    pub fn new(source_db: &str, backup_path: &str) -> Result<Self, BackupError> {
        let config = Config {
            source_db: source_db.to_string(),
            backup_path: backup_path.to_string(),
            compression: false,
            encryption: false,
            encryption_key: None,
            schedule: None,
            chunk_size: 1024,
            backup_rotation: None,
            skip_verification: false, // Add this line
        };
        Ok(Backup { config })
    }

    pub fn set_compression(&mut self, enable: bool) {
        self.config.compression = enable;
    }

    pub fn set_encryption(&mut self, enable: bool, key: Option<String>) {
        self.config.encryption = enable;
        self.config.encryption_key = key;
    }

    pub fn set_schedule(&mut self, schedule: crate::schedule::Schedule) {
        self.config.schedule = Some(schedule.to_config());
    }

    pub fn set_chunk_size(&mut self, chunk_size: usize) {
        self.config.chunk_size = chunk_size;
    }

    pub fn set_backup_rotation(&mut self, rotation: crate::config::BackupRotationConfig) {
        self.config.backup_rotation = Some(rotation);
    }

    pub fn set_backup_path(&mut self, path: String) {
        self.config.backup_path = path;
    }

    pub fn set_skip_verification(&mut self, skip: bool) {
        self.config.skip_verification = skip;
    }

    pub fn run(&mut self) -> Result<(), BackupError> {
        info!("Starting backup process...");

        // Create backup directory if it doesn't exist
        if let Some(parent) = Path::new(&self.config.backup_path).parent() {
            std::fs::create_dir_all(parent)?;
        }

        // Perform full backup
        std::fs::copy(&self.config.source_db, &self.config.backup_path)?;

        // Compression
        if self.config.compression {
            let compressed_path = format!("{}.gz", &self.config.backup_path);
            compression::compress_file(&self.config.backup_path, &compressed_path)?;
            std::fs::remove_file(&self.config.backup_path)?;
            // Update backup path to compressed file
            self.config.backup_path = compressed_path;
        }

        // Encryption
        if self.config.encryption {
            let key = match &self.config.encryption_key {
                Some(k) => {
                    let mut key_bytes = [0u8; 32];
                    k.bytes()
                        .take(32)
                        .enumerate()
                        .for_each(|(i, b)| key_bytes[i] = b);
                    key_bytes
                }
                None => {
                    return Err(BackupError::EncryptionError(
                        "No encryption key provided".into(),
                    ))
                }
            };
            let encrypted_path = format!("{}.enc", &self.config.backup_path);
            encryption::encrypt_file(&self.config.backup_path, &encrypted_path, &key)?;
            std::fs::remove_file(&self.config.backup_path)?;
            // Update backup path to encrypted file
            self.config.backup_path = encrypted_path;
        }

        // Rotate backups
        self.rotate_backups()?;

        // Verification
        if !self.config.skip_verification {
            verification::verify_backup(&self.config)?;
        }

        info!("Backup completed successfully.");
        Ok(())
    }

    pub fn schedule(&self, schedule: crate::schedule::Schedule) -> Result<(), BackupError> {
        let scheduler = Scheduler::new(schedule, self.clone());
        scheduler.start();
        Ok(())
    }

    pub fn rotate_backups(&self) -> Result<(), BackupError> {
        if let Some(rotation_config) = &self.config.backup_rotation {
            let backup_dir = Path::new(&self.config.backup_path)
                .parent()
                .ok_or_else(|| BackupError::InvalidPath("Invalid backup path".to_string()))?
                .to_path_buf();

            let backup_prefix = "backup_";
            let backup_extension = "db";

            // Collect all backup files matching the pattern: backup_*.db
            let mut backups: Vec<PathBuf> = fs::read_dir(&backup_dir)?
                .filter_map(|entry| entry.ok().map(|e| e.path()))
                .filter(|path| {
                    path.is_file()
                        && path
                            .file_name()
                            .and_then(|name| name.to_str())
                            .map_or(false, |name| {
                                name.starts_with(backup_prefix)
                                    && path
                                        .extension()
                                        .and_then(|ext| ext.to_str())
                                        .map_or(false, |ext| ext == backup_extension)
                            })
                })
                .collect();

            // Sort backups by file name (which includes the number) in descending order
            backups.sort_by(|a, b| b.file_name().cmp(&a.file_name()));

            println!("Sorted Backups: {:?}", backups);
            println!("Backups count: {}", backups.len());
            println!("Max backups allowed: {}", rotation_config.max_backups);

            // Remove oldest backups exceeding the max_backups limit
            if backups.len() > rotation_config.max_backups {
                let backups_to_remove = backups.len() - rotation_config.max_backups;
                for path in backups
                    .iter()
                    .skip(rotation_config.max_backups)
                    .take(backups_to_remove)
                {
                    println!("Removing backup: {:?}", path);
                    fs::remove_file(path).map_err(|e| BackupError::IoError(e))?;
                }
            }
        }
        Ok(())
    }
}

// Implement Clone for Backup to use in scheduler
impl Clone for Backup {
    fn clone(&self) -> Self {
        Backup {
            config: self.config.clone(),
        }
    }
}
