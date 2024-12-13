use sql::{Filter, Glue, HttpQuery};

use crate::models::FinancialCard;

use super::errors::AppError;

pub async fn fetch_financial_card(id: String, user: String) -> anyhow::Result<FinancialCard> {
    let financial_card = FinancialCard::get(id).await.unwrap();
    if user != financial_card.created_by.clone().unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    Ok(financial_card)
}

pub async fn add_financial_card(
    mut data: FinancialCard,
    user: String,
) -> anyhow::Result<FinancialCard> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    data.created_by = Some(user.clone());
    data.created_at = Some(chrono::Utc::now().timestamp());
    let financial_card = FinancialCard::insert(data).await.unwrap();
    Ok(financial_card)
}

pub async fn update_financial_card(
    id: String,
    mut data: FinancialCard,
    user: String,
) -> anyhow::Result<FinancialCard> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    let financial_card = FinancialCard::get(id.clone()).await.unwrap();
    if user != financial_card.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    data.updated_by = Some(user.clone());
    data.updated_at = Some(chrono::Utc::now().timestamp());
    let financial_card = FinancialCard::update(id, data).await.unwrap();
    Ok(financial_card)
}

pub async fn remove_financial_card(id: String, user: String) -> anyhow::Result<FinancialCard> {
    let financial_card = FinancialCard::get(id.clone()).await.unwrap();
    if user != financial_card.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    let financial_card = FinancialCard::delete(id).await.unwrap();
    Ok(financial_card)
}

pub async fn get_all_financial_cards(
    query: String,
    user: String,
) -> anyhow::Result<Vec<FinancialCard>> {
    let mut query = serde_json::from_str::<HttpQuery>(&query).unwrap();
    query = if query.filters.is_none() {
        query.filters = Some(vec![Filter::equal("created_by", user, None)]);
        query
    } else {
        query
            .filters
            .as_mut()
            .unwrap()
            .push(Filter::equal("created_by", user, Some(Glue::And)));
        query
    };
    let financial_cards = FinancialCard::get_list(query).await.unwrap();
    Ok(financial_cards)
}
