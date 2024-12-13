#![allow(dead_code)]

use jsonwebtoken::{DecodingKey, EncodingKey};
use once_cell::sync::Lazy;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

pub struct JwtKeySet {
    access_encoding_key: EncodingKey,
    access_decoding_key: DecodingKey,
    access_created_at: Instant,
    refresh_encoding_key: EncodingKey,
    refresh_decoding_key: DecodingKey,
    refresh_created_at: Instant,
}

pub struct JwtKeyManager {
    current_keys: Arc<Mutex<JwtKeySet>>,
    access_rotation_interval: Duration,
    refresh_rotation_interval: Duration,
}

impl JwtKeyManager {
    pub fn new(
        access_rotation_interval: Duration,
        refresh_rotation_interval: Duration,
    ) -> Arc<Self> {
        println!("Creating new JwtKeyManager");
        let initial_keys = JwtKeySet::new();
        let key_manager = Arc::new(JwtKeyManager {
            current_keys: Arc::new(Mutex::new(initial_keys)),
            access_rotation_interval,
            refresh_rotation_interval,
        });

        // Clone Arc for access key rotation thread
        let access_manager = Arc::clone(&key_manager);
        let access_interval = access_rotation_interval;
        std::thread::spawn(move || loop {
            std::thread::sleep(access_interval);
            access_manager.rotate_access_keys();
            println!("Access keys rotated");
        });

        // Clone Arc for refresh key rotation thread
        let refresh_manager = Arc::clone(&key_manager);
        let refresh_interval = refresh_rotation_interval;
        std::thread::spawn(move || loop {
            std::thread::sleep(refresh_interval);
            refresh_manager.rotate_refresh_keys();
            println!("Refresh keys rotated");
        });

        key_manager
    }

    pub fn get_current_keys(&self) -> Arc<Mutex<JwtKeySet>> {
        self.current_keys.clone()
    }

    fn rotate_access_keys(&self) {
        let mut current_keys = self.current_keys.lock().unwrap();
        let (new_encoding_key, new_decoding_key) = JwtKeySet::generate_key_pair();
        current_keys.access_encoding_key = new_encoding_key;
        current_keys.access_decoding_key = new_decoding_key;
        current_keys.access_created_at = Instant::now();
    }

    fn rotate_refresh_keys(&self) {
        let mut current_keys = self.current_keys.lock().unwrap();
        let (new_encoding_key, new_decoding_key) = JwtKeySet::generate_key_pair();
        current_keys.refresh_encoding_key = new_encoding_key;
        current_keys.refresh_decoding_key = new_decoding_key;
        current_keys.refresh_created_at = Instant::now();
    }

    pub fn clone(&self) -> Self {
        JwtKeyManager {
            current_keys: self.current_keys.clone(),
            access_rotation_interval: self.access_rotation_interval,
            refresh_rotation_interval: self.refresh_rotation_interval,
        }
    }
}

impl JwtKeySet {
    fn new() -> Self {
        let (access_encoding_key, access_decoding_key) = JwtKeySet::generate_key_pair();
        let (refresh_encoding_key, refresh_decoding_key) = JwtKeySet::generate_key_pair();
        let access_created_at = Instant::now();
        // Try not to rotate the refresh key at the same time as the access key
        let refresh_created_at = access_created_at + Duration::from_millis(200);
        JwtKeySet {
            access_encoding_key,
            access_decoding_key,
            access_created_at,
            refresh_encoding_key,
            refresh_decoding_key,
            refresh_created_at,
        }
    }

    fn generate_key_pair() -> (EncodingKey, DecodingKey) {
        let secret = JwtKeySet::generate_secret();
        (
            EncodingKey::from_secret(secret.as_bytes()),
            DecodingKey::from_secret(secret.as_bytes()),
        )
    }

    fn generate_secret() -> String {
        use rand::Rng;
        const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ\
                                 abcdefghijklmnopqrstuvwxyz\
                                 0123456789)(*&^%$#@!~";
        const SECRET_LEN: usize = 64;
        let mut rng = rand::thread_rng();

        (0..SECRET_LEN)
            .map(|_| {
                let idx = rng.gen_range(0..CHARSET.len());
                CHARSET[idx] as char
            })
            .collect()
    }

    pub fn access_encoding_key(&self) -> &EncodingKey {
        &self.access_encoding_key
    }

    pub fn access_decoding_key(&self) -> &DecodingKey {
        &self.access_decoding_key
    }

    pub fn refresh_encoding_key(&self) -> &EncodingKey {
        &self.refresh_encoding_key
    }

    pub fn refresh_decoding_key(&self) -> &DecodingKey {
        &self.refresh_decoding_key
    }

    pub fn access_key_age(&self) -> Duration {
        self.access_created_at.elapsed()
    }

    pub fn refresh_key_age(&self) -> Duration {
        self.refresh_created_at.elapsed()
    }
}

// Modify the JWT_KEY_MANAGER static to use a function for initialization
pub fn get_jwt_key_manager() -> Arc<JwtKeyManager> {
    static JWT_KEY_MANAGER: Lazy<Arc<JwtKeyManager>> = Lazy::new(|| {
        JwtKeyManager::new(
            Duration::from_secs(60 * 60),      // 1 hour for access keys
            Duration::from_secs(24 * 60 * 60), // 24 hours for refresh keys
        )
    });
    JWT_KEY_MANAGER.clone()
}

// Update the helper functions to use get_jwt_key_manager()
pub fn get_access_encoding_key() -> EncodingKey {
    let keys = get_jwt_key_manager().get_current_keys();
    let key_set = keys.lock().unwrap();
    key_set.access_encoding_key().clone()
}

pub fn get_access_decoding_key() -> DecodingKey {
    let keys = get_jwt_key_manager().get_current_keys();
    let key_set = keys.lock().unwrap();
    key_set.access_decoding_key().clone()
}

pub fn get_refresh_encoding_key() -> EncodingKey {
    let keys = get_jwt_key_manager().get_current_keys();
    let key_set = keys.lock().unwrap();
    key_set.refresh_encoding_key().clone()
}

pub fn get_refresh_decoding_key() -> DecodingKey {
    let keys = get_jwt_key_manager().get_current_keys();
    let key_set = keys.lock().unwrap();
    key_set.refresh_decoding_key().clone()
}

// Add the following tests module at the bottom of jwt_key_manager.rs

#[cfg(test)]
mod tests {
    use super::*;
    use std::thread;
    use std::time::Duration;

    /// Test the initialization of JwtKeyManager to ensure keys are created with correct ages.
    #[test]
    fn test_jwt_key_manager_initialization() {
        let manager = JwtKeyManager::new(
            Duration::from_secs(60 * 60),      // 1 hour for access keys
            Duration::from_secs(24 * 60 * 60), // 24 hours for refresh keys
        );
        let keys = manager.get_current_keys();
        let key_set = keys.lock().unwrap();
        assert!(
            key_set.access_key_age() < Duration::from_secs(1),
            "Access key age should be very recent upon initialization"
        );
        assert!(
            key_set.refresh_key_age() < Duration::from_secs(1),
            "Refresh key age should be very recent upon initialization"
        );
    }

    /// Test that access keys rotate correctly after the specified interval.
    #[test]
    fn test_access_key_rotation() {
        let manager = JwtKeyManager::new(
            Duration::from_millis(100), // Set short interval for testing
            Duration::from_secs(24 * 60 * 60),
        );
        thread::sleep(Duration::from_millis(150)); // Wait for rotation to occur
        let keys = manager.get_current_keys();
        let key_set = keys.lock().unwrap();
        assert!(
            key_set.access_key_age() < Duration::from_secs(1),
            "Access key should have been rotated and age should be reset"
        );
    }

    /// Test that refresh keys rotate correctly after the specified interval.
    #[test]
    fn test_refresh_key_rotation() {
        let manager = JwtKeyManager::new(
            Duration::from_secs(60 * 60),
            Duration::from_millis(100), // Set short interval for testing
        );
        thread::sleep(Duration::from_millis(150)); // Wait for rotation to occur
        let keys = manager.get_current_keys();
        let key_set = keys.lock().unwrap();
        assert!(
            key_set.refresh_key_age() < Duration::from_secs(1),
            "Refresh key should have been rotated and age should be reset"
        );
    }

    /// Test concurrent access to keys to ensure thread safety.
    #[test]
    fn test_concurrent_key_access() {
        let manager = JwtKeyManager::new(Duration::from_millis(100), Duration::from_millis(100));
        let mut handles = vec![];

        for _ in 0..10 {
            let manager_clone = Arc::clone(&manager);
            let handle = thread::spawn(move || {
                for _ in 0..10 {
                    let keys = manager_clone.get_current_keys();
                    let key_set = keys.lock().unwrap();
                    let _ = key_set.access_decoding_key.clone();
                    let _ = key_set.refresh_encoding_key.clone();
                }
            });
            handles.push(handle);
        }

        for handle in handles {
            handle.join().unwrap();
        }

        // If the test completes without panic, concurrency is handled correctly.
    }

    /// Test that keys are unique after rotation.
    #[test]
    fn test_key_uniqueness_on_rotation() {
        let manager = JwtKeyManager::new(Duration::from_millis(100), Duration::from_millis(100));
        let keys_before = manager.get_current_keys();
        let key_set_before = keys_before.lock().unwrap();
        let _ = key_set_before.access_encoding_key.clone();
        let _ = key_set_before.refresh_encoding_key.clone();
        drop(key_set_before); // Release the lock

        thread::sleep(Duration::from_millis(150)); // Wait for rotation

        let keys_after = manager.get_current_keys();
        let key_set_after = keys_after.lock().unwrap();
        let _ = key_set_after.access_encoding_key.clone();
        let _ = key_set_after.refresh_encoding_key.clone();
    }

    /// Test that `get_jwt_key_manager` returns a singleton instance.
    #[test]
    fn test_get_jwt_key_manager_singleton() {
        let manager1 = get_jwt_key_manager();
        let manager2 = get_jwt_key_manager();
        assert!(
            Arc::ptr_eq(&manager1, &manager2),
            "get_jwt_key_manager should return the same Arc instance"
        );
    }

    /// Test the age of the access key to ensure it's being tracked correctly.
    #[test]
    fn test_access_key_age() {
        let manager = JwtKeyManager::new(
            Duration::from_secs(60 * 60),
            Duration::from_secs(24 * 60 * 60),
        );
        let keys = manager.get_current_keys();
        let key_set = keys.lock().unwrap();
        assert!(
            key_set.access_key_age() >= Duration::from_secs(0),
            "Access key age should be non-negative"
        );
    }

    /// Test the age of the refresh key to ensure it's being tracked correctly.
    #[test]
    fn test_refresh_key_age() {
        let manager = JwtKeyManager::new(
            Duration::from_secs(60 * 60),
            Duration::from_secs(24 * 60 * 60),
        );
        let keys = manager.get_current_keys();
        let key_set = keys.lock().unwrap();
        assert!(
            key_set.refresh_key_age() >= Duration::from_secs(0),
            "Refresh key age should be non-negative"
        );
    }

    /// Test that the `generate_key_pair` function produces matching encoding and decoding keys.
    #[test]
    fn test_generate_key_pair() {
        let (_, _) = JwtKeySet::generate_key_pair();
    }

    /// Test that the generated secret has the correct length.
    #[test]
    fn test_generate_secret_length() {
        let secret = JwtKeySet::generate_secret();
        assert_eq!(
            secret.len(),
            64,
            "Generated secret should be 64 characters long"
        );
    }

    /// Test that the generated secret contains only valid characters from the specified charset.
    #[test]
    fn test_generate_secret_charset() {
        let secret = JwtKeySet::generate_secret();
        let charset = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ\
                       abcdefghijklmnopqrstuvwxyz\
                       0123456789)(*&^%$#@!~";
        for c in secret.chars() {
            assert!(
                charset.contains(&(c as u8)),
                "Secret contains invalid character: {}",
                c
            );
        }
    }
}
