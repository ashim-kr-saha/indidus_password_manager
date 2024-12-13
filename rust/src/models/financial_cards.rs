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
#[crudlf(table_name = "financial_cards")]
#[frb(dart_metadata=("freezed"))]
pub struct FinancialCard {
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

    #[serde(rename = "card_holder_name")]
    pub card_holder_name: String,

    #[serde(rename = "card_number")]
    pub card_number: String,

    #[serde(rename = "card_provider_name")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub card_provider_name: Option<String>,

    #[serde(rename = "card_type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub card_type: Option<String>,

    #[serde(rename = "cvv")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cvv: Option<String>,

    #[serde(rename = "expiry_date")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub expiry_date: Option<String>,

    #[serde(rename = "issue_date")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub issue_date: Option<String>,

    #[serde(rename = "name")]
    pub name: String,

    #[serde(rename = "note")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub note: Option<String>,

    #[serde(rename = "pin")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub pin: Option<String>,

    #[serde(rename = "is_favorite")]
    pub is_favorite: Option<bool>,

    // CSV of tags
    #[serde(rename = "tags")]
    pub tags: Option<String>,
}
