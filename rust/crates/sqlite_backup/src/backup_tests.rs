use crate::backup::Backup;
use crate::config::BackupRotationConfig;
use crate::schedule::Schedule;
use rusqlite::Connection;
use std::fs::{self, File};
use std::io::Write;
use std::os::unix::fs::PermissionsExt;
use tempfile::tempdir;

fn create_dummy_db(path: &std::path::Path) {
    let _ = File::create(path).unwrap();
    // Write some data to the database using rusqlite
    let conn = Connection::open(path).unwrap();
    conn.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)", [])
        .unwrap();
    conn.execute("INSERT INTO test (name) VALUES (?)", ["John Doe"])
        .unwrap();
}

#[tokio::test]
async fn test_full_backup() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("source.db");
    let backup_db = dir.path().join("backup.db");

    // Create a dummy source databases
    create_dummy_db(&source_db);

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    let result = backup.run();

    if let Err(e) = result {
        println!("Error: {}", e);
    }

    assert!(backup_db.exists());
    // remove the database
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_compressed_backup() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("source.db");
    let backup_db = dir.path().join("backup.db");
    let compressed_db = dir.path().join("backup.db.gz");

    // Create a dummy source database
    create_dummy_db(&source_db);

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.set_compression(true);
    backup.run().unwrap();

    assert!(compressed_db.exists());
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_encrypted_backup() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("source.db");
    let backup_db = dir.path().join("backup.db");
    let encrypted_db = dir.path().join("backup.db.enc");

    // Create a dummy source database
    create_dummy_db(&source_db);

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.set_encryption(true, Some("mysecretkey1234567890abcdef".to_string()));
    backup.run().unwrap();

    assert!(encrypted_db.exists());
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_scheduled_backup() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("source.db");
    let backup_db = dir.path().join("backup.db");

    // Create a dummy source database
    create_dummy_db(&source_db);

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    let schedule = Schedule {
        frequency: "daily".to_string(),
        time: "00:00".to_string(),
    };
    let rotation = BackupRotationConfig { max_backups: 5 };
    // Set backup rotation if needed
    backup.set_backup_rotation(rotation);
    backup.set_schedule(schedule);
    // Note: For testing purposes, scheduling is asynchronous and might require more complex setup
    backup.run().unwrap();
    assert!(backup_db.exists());
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_restore() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("source.db");
    let backup_db = dir.path().join("backup.db");
    let restore_db = dir.path().join("restore.db");

    // Create a dummy source database
    create_dummy_db(&source_db);

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.run().unwrap();

    // Perform restore
    crate::restore::Restore::from_backup(
        backup_db.to_str().unwrap(),
        restore_db.to_str().unwrap(),
        None,
    )
    .unwrap();

    assert!(restore_db.exists());
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
    let _ = std::fs::remove_file(&restore_db);
}

#[tokio::test]
async fn test_compressed_encrypted_backup() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("source.db");
    let backup_db = dir.path().join("backup.db");
    let compressed_encrypted_db = dir.path().join("backup.db.gz.enc");

    // Create a dummy source database
    create_dummy_db(&source_db);

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.set_compression(true);
    backup.set_encryption(true, Some("mysecretkey1234567890abcdef".to_string()));
    backup.run().unwrap();

    assert!(compressed_encrypted_db.exists());
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

// Test for non-existent source database
#[tokio::test]
async fn test_non_existent_source_backup() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("non_existent.db");
    let backup_db = dir.path().join("backup.db");

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();

    let res = backup.run();

    assert!(
        res.is_err(),
        "Expected error when backing up a non-existent source database"
    );
}

// Test for non-writable backup destination
#[tokio::test]
async fn test_non_writable_backup_destination() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("source.db");
    // let backup_db = dir.path().join("backup.db");

    // Create a dummy source database
    create_dummy_db(&source_db);

    // Create a read-only directory for the backup
    let read_only_dir = tempfile::tempdir().unwrap();
    let read_only_path = read_only_dir.path();
    std::fs::set_permissions(read_only_path, std::fs::Permissions::from_mode(0o444)).unwrap(); // Set to read-only

    let mut backup = Backup::new(
        source_db.to_str().unwrap(),
        read_only_path.join("backup.db").to_str().unwrap(),
    )
    .unwrap();

    assert!(
        backup.run().is_err(),
        "Expected error when trying to write to a non-writable backup destination"
    );

    // Clean up
    let _ = std::fs::remove_file(&source_db);
}

#[tokio::test]
async fn test_backup_with_custom_filename() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("source.db");
    let backup_db = dir.path().join("custom_backup_name.db");

    create_dummy_db(&source_db);

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.run().unwrap();

    assert!(backup_db.exists());
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_backup_with_large_database() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("large_source.db");
    let backup_db = dir.path().join("large_backup.db");

    // Create a larger dummy database
    let conn = Connection::open(&source_db).unwrap();
    conn.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, data BLOB)", [])
        .unwrap();

    // Insert 1000 rows with 1MB of data each
    let large_data = vec![0u8; 1_000_000];
    for _ in 0..1000 {
        conn.execute("INSERT INTO test (data) VALUES (?)", [&large_data])
            .unwrap();
    }

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.run().unwrap();

    assert!(backup_db.exists());
    assert!(backup_db.metadata().unwrap().len() > 900_000_000); // Ensure backup is large

    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_backup_with_concurrent_writes() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("concurrent_source.db");
    let backup_db = dir.path().join("concurrent_backup.db");

    let source_db_path = source_db.to_str().unwrap().to_string();
    let backup_db_path = backup_db.to_str().unwrap().to_string();

    create_dummy_db(&source_db);

    let source_conn = Connection::open(&source_db).unwrap();
    let backup_handle = tokio::spawn(async move {
        let mut backup = Backup::new(&source_db_path, &backup_db_path).unwrap();
        backup.run().unwrap();
    });

    // Perform concurrent writes
    for i in 0..1000 {
        source_conn
            .execute(
                "INSERT INTO test (name) VALUES (?)",
                [format!("User {}", i)],
            )
            .unwrap();
    }

    backup_handle.await.unwrap();

    assert!(backup_db.exists());

    // Verify backup contains all data
    let backup_conn = Connection::open(&backup_db).unwrap();
    let count: i64 = backup_conn
        .query_row("SELECT COUNT(*) FROM test", [], |row| row.get(0))
        .unwrap();
    assert!(count > 1000); // Original + new inserts

    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_incremental_backup() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("incremental_source.db");
    let backup_db = dir.path().join("incremental_backup.db");

    create_dummy_db(&source_db);

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.run().unwrap();

    // Modify source database
    let conn = Connection::open(&source_db).unwrap();
    conn.execute("INSERT INTO test (name) VALUES (?)", ["Jane Doe"])
        .unwrap();

    // Perform incremental backup
    backup.run().unwrap();

    // Verify backup contains new data
    let backup_conn = Connection::open(&backup_db).unwrap();
    let count: i64 = backup_conn
        .query_row("SELECT COUNT(*) FROM test", [], |row| row.get(0))
        .unwrap();
    assert_eq!(count, 2);

    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_scheduled_backup_daily() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("daily_source.db");
    let backup_db = dir.path().join("daily_backup.db");

    // Create a dummy source database
    create_dummy_db(&source_db);

    // Set up daily schedule at a specific time (e.g., 00:00)
    let schedule = Schedule {
        frequency: "daily".to_string(),
        time: "00:00".to_string(),
    };

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.set_schedule(schedule);
    backup.run().unwrap();

    // Verify that the backup file exists
    assert!(backup_db.exists());

    // Clean up
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

#[tokio::test]
async fn test_scheduled_backup_weekly() {
    let dir = tempdir().unwrap();
    let source_db = dir.path().join("weekly_source.db");
    let backup_db = dir.path().join("weekly_backup.db");

    // Create a dummy source database
    create_dummy_db(&source_db);

    // Set up weekly schedule (e.g., every Monday at 02:30)
    let schedule = Schedule {
        frequency: "weekly".to_string(),
        time: "02:30".to_string(),
    };

    let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
    backup.set_schedule(schedule);
    backup.run().unwrap();

    // Verify that the backup file exists
    assert!(backup_db.exists());

    // Clean up
    let _ = std::fs::remove_file(&source_db);
    let _ = std::fs::remove_file(&backup_db);
}

// #[tokio::test]
// async fn test_scheduled_backup_invalid_frequency() {
//     let dir = tempdir().unwrap();
//     let source_db = dir.path().join("invalid_freq_source.db");
//     let backup_db = dir.path().join("invalid_freq_backup.db");

//     // Create a dummy source database
//     create_dummy_db(&source_db);

//     // Set up schedule with an invalid frequency
//     let schedule = Schedule {
//         frequency: "monthly".to_string(), // Invalid frequency
//         time: "03:00".to_string(),
//     };

//     let mut backup = Backup::new(source_db.to_str().unwrap(), backup_db.to_str().unwrap()).unwrap();
//     backup.set_schedule(schedule);

//     // Attempt to run the backup and expect an error
//     let result = backup.run();

//     assert!(
//         result.is_err(),
//         "Expected error when using an invalid frequency for scheduling"
//     );

//     // Clean up
//     let _ = std::fs::remove_file(&source_db);
//     let _ = std::fs::remove_file(&backup_db);
// }
#[tokio::test]
async fn test_scheduled_backup_with_rotation() {
    // Create a temporary directory
    let dir = tempdir().unwrap();
    let backup_dir = dir.path().join("backups");
    fs::create_dir(&backup_dir).unwrap();

    let source_db = dir.path().join("rotation_source.db");

    // Create a dummy source database file
    {
        let mut file = File::create(&source_db).unwrap();
        writeln!(file, "dummy data").unwrap();
    }

    // Define maximum number of backups to retain
    let rotation_config = BackupRotationConfig { max_backups: 3 };

    // Initialize Backup instance
    let mut backup = Backup::new(
        source_db.to_str().unwrap(),
        backup_dir.join("backup_001.db").to_str().unwrap(),
    )
    .unwrap();
    backup.set_backup_rotation(rotation_config.clone());
    backup.set_skip_verification(true);

    // Simulate multiple backup runs
    for i in 1..=5 {
        let backup_path = backup_dir.join(format!("backup_{:03}.db", i));
        backup.set_backup_path(backup_path.to_str().unwrap().to_string());
        backup.run().unwrap();

        // Log existing backups
        println!("Created backup: {:?}", backup_path);

        // Introduce a short delay to ensure distinct modification times
        // std::thread::sleep(std::time::Duration::from_secs(2));
    }

    // List existing backup files
    let backups: Vec<_> = fs::read_dir(&backup_dir)
        .unwrap()
        .filter_map(|entry| entry.ok().map(|e| e.path()))
        .filter(|path| {
            path.is_file()
                && path
                    .file_name()
                    .and_then(|name| name.to_str())
                    .map_or(false, |name| {
                        name.starts_with("backup_") && name.ends_with(".db")
                    })
        })
        .collect();

    println!("Final Backups: {:?}", backups);
    println!("Final Backups len: {}", backups.len());

    // Verify that only the last 3 backups exist
    for i in 3..=5 {
        let expected_backup = backup_dir.join(format!("backup_{:03}.db", i));
        println!("Checking existence of: {:?}", expected_backup);
        assert!(expected_backup.exists(), "Backup {} should exist", i);
    }

    // Verify that the first two backups have been rotated out
    for i in 1..=2 {
        let old_backup = backup_dir.join(format!("backup_{:03}.db", i));
        println!("Checking non-existence of: {:?}", old_backup);
        assert!(
            !old_backup.exists(),
            "Backup {} should have been rotated out",
            i
        );
    }

    // Clean up (handled by tempfile's TempDir)
}
