use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
#[frb(dart_metadata=("freezed"))]
pub struct RegisterData {
    pub name: String,
    pub email: String,
    pub password: String,
    pub re_password: String,
}

impl RegisterData {
    pub fn is_valid(&self) -> bool {
        self.password == self.re_password
            && !self.password.is_empty()
            && !self.re_password.is_empty()
            && !self.name.is_empty()
            && !self.email.is_empty()
    }
}

#[derive(Debug, Deserialize)]
#[frb(dart_metadata=("freezed"))]
pub struct LoginData {
    pub email: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
#[frb(dart_metadata=("freezed"))]
pub struct JwtTokens {
    pub access_token: String,
    pub refresh_token: String,
}
