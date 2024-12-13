use sql::{Filter, Glue, HttpQuery};

use crate::models::IdentityCard;

use super::{errors::AppError, jwt::get_user_id_from_token};

pub async fn fetch_identity_card(id: String, token: String) -> anyhow::Result<IdentityCard> {
    let user = get_user_id_from_token(token).await?;
    let identity_card = IdentityCard::get(id).await.unwrap();
    if user != identity_card.created_by.clone().unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    Ok(identity_card)
}

pub async fn add_identity_card(
    mut data: IdentityCard,
    user: String,
) -> anyhow::Result<IdentityCard> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    data.created_by = Some(user.clone());
    data.created_at = Some(chrono::Utc::now().timestamp());
    let identity_card = IdentityCard::insert(data).await.unwrap();
    Ok(identity_card)
}

pub async fn update_identity_card(
    id: String,
    mut data: IdentityCard,
    user: String,
) -> anyhow::Result<IdentityCard> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    let identity_card = IdentityCard::get(id.clone()).await.unwrap();
    if user != identity_card.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    data.updated_by = Some(user.clone());
    data.updated_at = Some(chrono::Utc::now().timestamp());
    let identity_card = IdentityCard::update(id, data).await.unwrap();
    Ok(identity_card)
}

pub async fn remove_identity_card(id: String, user: String) -> anyhow::Result<IdentityCard> {
    let identity_card = IdentityCard::get(id.clone()).await.unwrap();
    if user != identity_card.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    let identity_card = IdentityCard::delete(id).await.unwrap();
    Ok(identity_card)
}

pub async fn get_all_identity_cards(
    query: String,
    user: String,
) -> anyhow::Result<Vec<IdentityCard>> {
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
    let identity_cards = IdentityCard::get_list(query).await.unwrap();
    Ok(identity_cards)
}
