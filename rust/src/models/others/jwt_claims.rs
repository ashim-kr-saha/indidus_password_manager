use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct RefreshTokenClaims {
    // Token ID
    pub jti: String,
    // Issued At
    pub iat: usize,
    // Expiration Time
    pub exp: usize,
    // User ID
    pub uid: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    // Issued At
    pub iat: usize,
    // Expiration Time
    pub exp: usize,
    // User ID
    pub uid: String,
}
