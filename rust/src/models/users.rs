use crudlf_derive::{SqliteDelete, SqliteInsert, SqliteListFilter, SqliteSelect, SqliteUpdate};
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

use super::RegisterData;

#[derive(
    Debug,
    Clone,
    PartialEq,
    Serialize,
    Deserialize,
    SqliteInsert,
    SqliteSelect,
    SqliteUpdate,
    SqliteDelete,
    SqliteListFilter,
    Default,
)]
#[crudlf(table_name = "users")]
#[frb(dart_metadata=("freezed"))]
pub struct User {
    #[serde(rename = "id")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<String>,

    #[serde(rename = "created_at")]
    pub created_at: Option<i64>,

    #[serde(rename = "created_by")]
    pub created_by: Option<String>,

    #[serde(rename = "updated_at")]
    pub updated_at: Option<i64>,

    #[serde(rename = "updated_by")]
    pub updated_by: Option<String>,

    #[serde(rename = "name")]
    pub name: String,

    #[serde(rename = "email")]
    pub email: String,

    #[serde(rename = "password_hash")]
    pub password_hash: String,

    #[serde(rename = "role")]
    pub role: String,

    #[serde(rename = "two_factor_secret")]
    pub two_factor_secret: Option<String>, // New field for 2FA secret
}

impl From<RegisterData> for User {
    fn from(data: RegisterData) -> Self {
        User {
            id: None,
            created_at: None,
            created_by: None,
            updated_at: None,
            updated_by: None,
            name: data.name,
            email: data.email,
            password_hash: data.password,
            role: "user".to_string(),
            two_factor_secret: None,
        }
    }
}
