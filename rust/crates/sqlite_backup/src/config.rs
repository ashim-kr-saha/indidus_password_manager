use serde::Deserialize;

#[derive(Deserialize, Debug, Clone)]
pub struct Config {
    pub source_db: String,
    pub backup_path: String,
    pub compression: bool,
    pub encryption: bool,
    pub encryption_key: Option<String>,
    pub schedule: Option<ScheduleConfig>,
    pub chunk_size: usize,
    pub backup_rotation: Option<BackupRotationConfig>,
    pub skip_verification: bool,
}

#[derive(Deserialize, Debug, Clone)]
pub struct ScheduleConfig {
    pub frequency: String, // e.g., "daily", "weekly"
    pub time: String,      // e.g., "02:30"
}

#[derive(Deserialize, Debug, Clone)]
pub struct BackupRotationConfig {
    pub max_backups: usize,
}
