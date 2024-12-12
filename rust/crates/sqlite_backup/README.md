# SQLite Backup

## Features

sqlite_backup provides the following features:

- **Full Database Backup**: Create complete backups of SQLite databases.
- **Incremental Backup**: Perform incremental backups to save space and time.
- **Customizable Backup Path**: Specify custom paths for backup files.
- **Compression**: Optionally compress backup files to save storage space.
- **Encryption**: Encrypt backup files for enhanced security.
- **Scheduled Backups**: Set up automatic, scheduled backups.
- **Backup Verification**: Verify the integrity of backup files.
- **Restore Functionality**: Easily restore databases from backup files.
- **Progress Tracking**: Monitor backup progress in real-time.
- **Error Handling**: Robust error handling and reporting.
- **Logging**: Detailed logging of backup operations.
- **Multi-threading**: Utilize multiple threads for faster backups of large databases.
- **Configurable Chunk Size**: Adjust the chunk size for optimal performance.
- **Backup Rotation**: Implement a rotation system for managing multiple backups.
- **Cross-platform Support**: Works on various operating systems.


## Feature Flags

Enable or disable features using Cargo feature flags to customize the library for your needs.
To enable specific features, add them to your `Cargo.toml` file. For example:

```toml
[dependencies]
sqlite_backup = { version = "0.1.0", features = ["compression", "encryption"] }
```

Available feature flags:

- `compression`: Enable backup file compression
- `encryption`: Enable backup file encryption
- `scheduling`: Enable scheduled backup functionality
- `verification`: Enable backup verification
- `restore`: Enable database restoration from backups
- `progress`: Enable real-time progress tracking
- `logging`: Enable detailed logging
- `multi_threading`: Enable multi-threaded backup operations

By default, only the core backup functionality is enabled. Enable additional features as needed for your project.

## Usage

Here are some examples of how to use sqlite_backup with various features:

### Basic Backup

```rust
use sqlite_backup::Backup;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let backup = Backup::new("path/to/source.db", "path/to/backup.db")?;
    backup.run()?;
    Ok(())
}
```

### Compressed Backup

```rust
use sqlite_backup::Backup;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut backup = Backup::new("path/to/source.db", "path/to/backup.db.gz")?;
    backup.set_compression(true);
    backup.run()?;
    Ok(())
}
```

### Encrypted Backup

```rust
use sqlite_backup::Backup;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut backup = Backup::new("path/to/source.db", "path/to/backup.db.enc")?;
    backup.set_encryption_key("your_secret_key");
    backup.run()?;
    Ok(())
}
```

### Scheduled Backup

```rust
use sqlite_backup::{Backup, Schedule};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let backup = Backup::new("path/to/source.db", "path/to/backup.db")?;
    let schedule = Schedule::daily(2, 30); // Run every day at 2:30 AM
    backup.schedule(schedule)?;
    Ok(())
}
```
