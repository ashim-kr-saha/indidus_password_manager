use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};

use super::errors::AppError;

pub fn password_hash(password: &str) -> Result<String, AppError> {
    let salt = SaltString::generate(&mut OsRng); // Generate random salt
    let argon2 = Argon2::default(); // Use standard Argon2id configuration

    // Hash the password with generated salt
    let password_hash = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|e| AppError::from(e))?; // Convert argon2 error to AppError

    // Extract salt and hash strings for storage
    // let salt_str = salt.to_string();
    let hash_str = password_hash.to_string();

    Ok(hash_str)
}

pub fn verify_password(
    password: &str,
    password_hash: &str,
) -> Result<bool, argon2::password_hash::Error> {
    // Parse the stored hash string
    let parsed_hash = PasswordHash::new(password_hash);

    if parsed_hash.is_err() {
        return Err(parsed_hash.unwrap_err());
    }
    let parsed_hash = parsed_hash.unwrap();

    let res = Argon2::default().verify_password(password.as_bytes(), &parsed_hash);
    if res.is_err() {
        return Ok(false);
    }

    Ok(true)
}

mod tests {
    #[test]
    fn test_password_hash() {
        let password = "XXXXXXXXX@1234";
        let hash = super::password_hash(password).unwrap();
        assert_eq!(super::verify_password(password, &hash).unwrap(), true);
    }
}
