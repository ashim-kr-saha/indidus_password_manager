#![allow(dead_code)]

use jsonwebtoken::{decode, encode, Header, Validation};

use crate::models::others::jwt_claims::{Claims, RefreshTokenClaims};

use super::{
    errors::AppError,
    jwt_key_manager::{
        get_access_decoding_key, get_access_encoding_key, get_refresh_decoding_key,
        get_refresh_encoding_key,
    },
    time::now,
};

pub fn is_not_expired(exp: usize) -> bool {
    return exp > chrono::Utc::now().timestamp() as usize;
}

pub fn generate_access_token(user_id: String, duration: usize) -> Result<String, AppError> {
    let n = now();
    let claims = Claims {
        exp: (n + duration),
        uid: user_id,
        iat: n,
    };
    let key = get_access_encoding_key();
    encode(&Header::default(), &claims, &key).map_err(AppError::JWTKeyError)
}

pub fn generate_refresh_token(uid: String, duration: usize) -> Result<String, AppError> {
    let n = now();
    let claims = RefreshTokenClaims {
        jti: uuid::Uuid::new_v4().to_string(),
        uid,
        iat: n,
        exp: (n + duration),
    };

    let key = get_refresh_encoding_key();
    encode(&Header::default(), &claims, &key).map_err(AppError::JWTKeyError)
}

pub fn get_refresh_claims(token: &str) -> Result<RefreshTokenClaims, AppError> {
    let key = get_refresh_decoding_key();
    let decoded = decode::<RefreshTokenClaims>(token, &key, &Validation::default())?;
    if decoded.claims.exp <= now() {
        return Err(AppError::JWTTokenExpired);
    }
    Ok(decoded.claims)
}

pub fn get_access_claims(token: &str) -> Result<Claims, AppError> {
    let key = get_access_decoding_key();
    let decoded = decode::<Claims>(token, &key, &Validation::default())?;
    if decoded.claims.exp <= now() {
        return Err(AppError::JWTTokenExpired);
    }
    Ok(decoded.claims)
}

pub fn generate_access_and_refresh_tokens(uid: String) -> Result<(String, String), AppError> {
    let access_token = generate_access_token(uid.clone(), 15 * 60)?;
    let refresh_token = generate_refresh_token(uid, 60 * 60 * 24 * 30)?;
    Ok((access_token, refresh_token))
}

pub fn generate_access_token_from_refresh_token(refresh_token: &str) -> Result<String, AppError> {
    let claims = get_refresh_claims(refresh_token)?;
    generate_access_token(claims.uid, 15 * 60)
}

pub async fn get_user_id_from_token(token: String) -> Result<String, AppError> {
    let claims = get_access_claims(token.as_str())?;
    Ok(claims.uid)
}

pub fn get_user_id_from_refresh_token(token: &str) -> Result<String, AppError> {
    let claims = get_refresh_claims(token)?;
    Ok(claims.uid)
}
#[cfg(test)]
mod tests {
    use super::super::*;
    use jwt::{
        generate_access_and_refresh_tokens, generate_access_token,
        generate_access_token_from_refresh_token, generate_refresh_token, get_access_claims,
        get_refresh_claims, get_user_id_from_refresh_token, get_user_id_from_token, is_not_expired,
    };
    use time::now;
    use tokio::runtime::Runtime;

    // Helper function to create a test user ID
    fn test_user_id() -> String {
        "test_user_123".to_string()
    }

    #[test]
    fn test_is_not_expired() {
        let current_time = now();
        assert!(is_not_expired(current_time + 100));
        assert!(!is_not_expired(current_time - 100));
    }

    #[test]
    fn test_generate_access_token() {
        let rt = Runtime::new().unwrap();
        rt.block_on(async {
            let token = generate_access_token(test_user_id(), 900).unwrap();
            assert!(!token.is_empty());
        });
    }

    #[test]
    fn test_generate_refresh_token() {
        let rt = Runtime::new().unwrap();
        rt.block_on(async {
            let token = generate_refresh_token(test_user_id(), 2592000).unwrap();
            assert!(!token.is_empty());
        });
    }

    #[test]
    fn test_get_refresh_claims() {
        let token = generate_refresh_token(test_user_id(), 2592000).unwrap();
        let claims = get_refresh_claims(&token).unwrap();
        assert_eq!(claims.uid, test_user_id());
    }

    #[test]
    fn test_get_access_claims() {
        let token = generate_access_token(test_user_id(), 900).unwrap();
        let claims = get_access_claims(&token).unwrap();
        assert_eq!(claims.uid, test_user_id());
    }

    #[test]
    fn test_generate_access_and_refresh_tokens() {
        let (access_token, refresh_token) =
            generate_access_and_refresh_tokens(test_user_id()).unwrap();
        assert!(!access_token.is_empty());
        assert!(!refresh_token.is_empty());
    }

    #[test]
    fn test_generate_access_token_from_refresh_token() {
        let refresh_token = generate_refresh_token(test_user_id(), 2592000).unwrap();
        let access_token = generate_access_token_from_refresh_token(&refresh_token).unwrap();
        assert!(!access_token.is_empty());
    }

    #[tokio::test]
    async fn test_get_user_id_from_token() {
        let token = generate_access_token(test_user_id(), 900).unwrap();
        let user_id = get_user_id_from_token(token).await.unwrap();
        assert_eq!(user_id, test_user_id());
    }

    #[test]
    fn test_get_user_id_from_refresh_token() {
        let token = generate_refresh_token(test_user_id(), 2592000).unwrap();
        let user_id = get_user_id_from_refresh_token(&token).unwrap();
        assert_eq!(user_id, test_user_id());
    }

    #[test]
    fn test_token_expiration() {
        let token = generate_access_token(test_user_id(), 1).unwrap();
        std::thread::sleep(std::time::Duration::from_secs(2));
        assert!(get_access_claims(&token).is_err());
    }

    #[test]
    fn test_invalid_token() {
        let invalid_token = "invalid.token.here";
        assert!(get_access_claims(invalid_token).is_err());
        assert!(get_refresh_claims(invalid_token).is_err());
    }

    #[test]
    fn test_different_token_types() {
        let access_token = generate_access_token(test_user_id(), 900).unwrap();
        let refresh_token = generate_refresh_token(test_user_id(), 2592000).unwrap();

        assert!(get_access_claims(&access_token).is_ok());
        assert!(get_refresh_claims(&refresh_token).is_ok());

        assert!(get_access_claims(&refresh_token).is_err());
        assert!(get_refresh_claims(&access_token).is_err());
    }
}
