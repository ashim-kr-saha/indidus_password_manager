use crudlf_derive::{SqliteDelete, SqliteInsert, SqliteListFilter, SqliteSelect, SqliteUpdate};
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

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
#[crudlf(table_name = "tags")]
#[frb(dart_metadata=("freezed"))]
pub struct Tag {
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
}
