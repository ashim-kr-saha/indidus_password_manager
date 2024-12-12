use crate::compression;
use crate::encryption;
use crate::error::BackupError;
use log::info;
use std::fs;

pub struct Restore;

impl Restore {
    pub fn from_backup(
        backup_path: &str,
        restore_path: &str,
        encryption_key: Option<&str>,
    ) -> Result<(), BackupError> {
        let mut intermediate_path = backup_path.to_string();

        // Decrypt if necessary
        if backup_path.ends_with(".enc") {
            let decrypted_path = format!("{}.decrypted", backup_path);
            let key = match encryption_key {
                Some(k) => {
                    let mut key_bytes = [0u8; 32];
                    k.bytes()
                        .take(32)
                        .enumerate()
                        .for_each(|(i, b)| key_bytes[i] = b);
                    key_bytes
                }
                None => return Err(BackupError::RestoreError("Encryption key required".into())),
            };
            encryption::decrypt_file(backup_path, &decrypted_path, &key)?;
            intermediate_path = decrypted_path;
        }

        // Decompress if necessary
        if intermediate_path.ends_with(".gz") {
            let decompressed_path = format!("{}.decompressed", intermediate_path);
            compression::decompress_file(&intermediate_path, &decompressed_path)?;
            fs::remove_file(&intermediate_path)?;
            intermediate_path = decompressed_path;
        }

        // Restore the database
        fs::copy(&intermediate_path, restore_path)?;

        // Clean up temporary files
        if intermediate_path.contains(".decrypted") || intermediate_path.contains(".decompressed") {
            fs::remove_file(&intermediate_path)?;
        }

        info!("Restore completed successfully.");
        Ok(())
    }
}
