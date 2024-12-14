use aes_gcm::{
    aead::{Aead, KeyInit},
    Aes256Gcm, Nonce,
};
use argon2::{
    password_hash::{rand_core::OsRng, PasswordHasher, SaltString},
    Argon2, ParamsBuilder,
};
use base64::{engine::general_purpose, Engine as _};
use rand::Rng;
use thiserror::Error;
use zeroize::Zeroize;

#[derive(Error, Debug)]
pub enum EncryptionError {
    #[error("Encryption failed")]
    EncryptionFailed,
    #[error("Decryption failed")]
    DecryptionFailed,
    #[error("Key derivation failed")]
    KeyDerivationFailed,
    #[error("Unsupported version")]
    UnsupportedVersion,
    #[error("Argon2 parameters builder failed")]
    Argon2ParametersBuilderFailed,
}

// Constants for Argon2 parameters
// const MEMORY_COST: u32 = 65536; // 64 MB
// const MEMORY_COST: u32 = 32768; // 32 MB
const MEMORY_COST: u32 = 16384; // 16 MB
                                // const MEMORY_COST: u32 = 8192; // 8 MB
                                // const MEMORY_COST: u32 = 4096; // 4 MB
const TIME_COST: u32 = 3;
const PARALLELISM: u32 = 4;

// Explicitly define the structure of encrypted data
const SALT_LENGTH: usize = 22; // Base64 encoded salt length
const NONCE_LENGTH: usize = 12;

pub fn encrypt(data: &str, password: &str) -> Result<String, EncryptionError> {
    // Generate a random salt
    let salt = SaltString::generate(&mut OsRng);

    // Derive a key from the password with explicit parameters
    let mut argon2_params = ParamsBuilder::new();
    argon2_params
        .m_cost(MEMORY_COST)
        .t_cost(TIME_COST)
        .p_cost(PARALLELISM)
        .output_len(32); // AES-256 key length
    let argon2 = Argon2::new(
        argon2::Algorithm::Argon2id,
        argon2::Version::V0x13,
        argon2_params
            .build()
            .map_err(|_| EncryptionError::Argon2ParametersBuilderFailed)?,
    );

    let mut key = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|_| EncryptionError::KeyDerivationFailed)?
        .hash
        .ok_or(EncryptionError::KeyDerivationFailed)?
        .as_bytes()
        .to_vec();

    // Create AES-GCM cipher
    let cipher = Aes256Gcm::new_from_slice(&key).map_err(|_| EncryptionError::EncryptionFailed)?;

    // Generate a random nonce
    let x = rand::thread_rng().gen::<[u8; NONCE_LENGTH]>();
    let nonce = Nonce::from_slice(&x);

    // Encrypt the data
    let ciphertext = cipher
        .encrypt(nonce, data.as_bytes())
        .map_err(|_| EncryptionError::EncryptionFailed)?;

    // Combine version, salt, nonce, and ciphertext
    let mut result = vec![1]; // Version 1
    result.extend_from_slice(salt.as_str().as_bytes());
    result.extend_from_slice(nonce);
    result.extend_from_slice(&ciphertext);

    // Securely clear the key from memory
    key.zeroize();

    // Encode the result as base64
    Ok(general_purpose::STANDARD.encode(result))
}

pub fn decrypt(encrypted_data: &str, password: &str) -> Result<String, EncryptionError> {
    // Decode the base64 input
    let decoded = general_purpose::STANDARD
        .decode(encrypted_data)
        .map_err(|_| EncryptionError::DecryptionFailed)?;

    // Extract version, salt, nonce, and ciphertext
    if decoded.len() < 1 + SALT_LENGTH + NONCE_LENGTH {
        return Err(EncryptionError::DecryptionFailed);
    }
    let version = decoded[0];
    if version != 1 {
        return Err(EncryptionError::UnsupportedVersion);
    }
    let salt = SaltString::from_b64(&String::from_utf8_lossy(&decoded[1..1 + SALT_LENGTH]))
        .map_err(|_| EncryptionError::DecryptionFailed)?;
    let nonce = Nonce::from_slice(&decoded[1 + SALT_LENGTH..1 + SALT_LENGTH + NONCE_LENGTH]);
    let ciphertext = &decoded[1 + SALT_LENGTH + NONCE_LENGTH..];

    // Derive the key from the password
    let mut argon2_params = ParamsBuilder::new();
    argon2_params
        .m_cost(MEMORY_COST)
        .t_cost(TIME_COST)
        .p_cost(PARALLELISM)
        .output_len(32); // AES-256 key length
    let argon2 = Argon2::new(
        argon2::Algorithm::Argon2id,
        argon2::Version::V0x13,
        argon2_params
            .build()
            .map_err(|_| EncryptionError::Argon2ParametersBuilderFailed)?,
    );

    let mut key = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|_| EncryptionError::KeyDerivationFailed)?
        .hash
        .ok_or(EncryptionError::KeyDerivationFailed)?
        .as_bytes()
        .to_vec();

    // Create AES-GCM cipher
    let cipher = Aes256Gcm::new_from_slice(&key).map_err(|_| EncryptionError::DecryptionFailed)?;

    // Decrypt the data
    let plaintext = cipher
        .decrypt(nonce, ciphertext)
        .map_err(|_| EncryptionError::DecryptionFailed)?;

    // Securely clear the key from memory
    key.zeroize();

    String::from_utf8(plaintext).map_err(|_| EncryptionError::DecryptionFailed)
}

#[cfg(test)]
mod tests {
    use super::*;
    use statrs::distribution::ContinuousCDF as _;
    use std::time::Instant;

    #[test]
    fn test_encrypt_decrypt() {
        let data = "Hello, world!";
        let password = "secret_password";

        let encrypted = encrypt(data, password).unwrap();
        let decrypted = decrypt(&encrypted, password).unwrap();

        assert_eq!(data, decrypted);
    }

    #[test]
    fn test_decrypt_wrong_password() {
        let data = "Hello, world!";
        let password = "secret_password";
        let wrong_password = "wrong_password";

        let encrypted = encrypt(data, password).unwrap();
        let result = decrypt(&encrypted, wrong_password);

        assert!(result.is_err());
    }

    #[test]
    fn test_decrypt_corrupted_data() {
        let data = "Hello, world!";
        let password = "secret_password";

        let mut encrypted = encrypt(data, password).unwrap();
        encrypted.push('A'); // Corrupt the data

        let result = decrypt(&encrypted, password);

        assert!(result.is_err());
    }

    #[test]
    fn test_timing_attack_resistance() {
        use statrs::distribution::Normal;

        let data = "Hello, world!";
        let password = "correct_password";
        let wrong_password = "wrong_password";

        let encrypted = encrypt(data, password).unwrap();

        let sample_size = 10;
        let mut correct_times = Vec::with_capacity(sample_size);
        let mut wrong_times = Vec::with_capacity(sample_size);

        for _ in 0..sample_size {
            let start = Instant::now();
            let _ = decrypt(&encrypted, password);
            correct_times.push(start.elapsed().as_nanos() as f64);

            let start = Instant::now();
            let _ = decrypt(&encrypted, wrong_password);
            wrong_times.push(start.elapsed().as_nanos() as f64);
        }

        let correct_mean = correct_times.iter().sum::<f64>() / sample_size as f64;
        let wrong_mean = wrong_times.iter().sum::<f64>() / sample_size as f64;

        let correct_std_dev = (correct_times
            .iter()
            .map(|&x| (x - correct_mean).powi(2))
            .sum::<f64>()
            / sample_size as f64)
            .sqrt();
        let wrong_std_dev = (wrong_times
            .iter()
            .map(|&x| (x - wrong_mean).powi(2))
            .sum::<f64>()
            / sample_size as f64)
            .sqrt();

        let normal = Normal::new(0.0, 1.0).unwrap();
        let z_score = (correct_mean - wrong_mean)
            / (correct_std_dev.powi(2) / sample_size as f64
                + wrong_std_dev.powi(2) / sample_size as f64)
                .sqrt();
        let p_value = 2.0 * (1.0 - normal.cdf(z_score.abs()));

        println!("Correct mean: {}, Wrong mean: {}", correct_mean, wrong_mean);
        println!(
            "Correct std dev: {}, Wrong std dev: {}",
            correct_std_dev, wrong_std_dev
        );
        println!("Z-score: {}, p-value: {}", z_score, p_value);

        assert!(
            p_value > 0.05,
            "Timing difference is statistically significant"
        );
    }
}
