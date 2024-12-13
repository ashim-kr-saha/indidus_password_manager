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
#[crudlf(table_name = "notes")]
#[frb(dart_metadata=("freezed"))]
pub struct Note {
    #[serde(rename = "id")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<String>,

    #[serde(rename = "created_at")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub created_at: Option<i64>,

    #[serde(rename = "created_by")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub created_by: Option<String>,

    #[serde(rename = "updated_at")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub updated_at: Option<i64>,

    #[serde(rename = "updated_by")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub updated_by: Option<String>,

    #[serde(rename = "name")]
    pub name: String,

    #[serde(rename = "note")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub note: Option<String>,

    #[serde(rename = "is_favorite")]
    pub is_favorite: Option<bool>,

    // CSV of tags
    #[serde(rename = "tags")]
    pub tags: Option<String>,
}
