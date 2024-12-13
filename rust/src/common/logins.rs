use sql::{Filter, Glue, HttpQuery};

use crate::models::Login;

use super::errors::AppError;

pub async fn fetch_login(id: String, user: String) -> anyhow::Result<Login> {
    let login = Login::get(id).await.unwrap();
    if user != login.created_by.clone().unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    Ok(login)
}

pub async fn add_login(mut data: Login, user: String) -> anyhow::Result<Login> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    data.created_by = Some(user.clone());
    data.created_at = Some(chrono::Utc::now().timestamp());
    let login = Login::insert(data).await.unwrap();
    Ok(login)
}

pub async fn update_login(id: String, mut data: Login, user: String) -> anyhow::Result<Login> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    let login = Login::get(id.clone()).await.unwrap();
    if user != login.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    data.updated_by = Some(user.clone());
    data.updated_at = Some(chrono::Utc::now().timestamp());
    let login = Login::update(id, data).await.unwrap();
    Ok(login)
}

pub async fn remove_login(id: String, user: String) -> anyhow::Result<Login> {
    let login = Login::get(id.clone()).await.unwrap();
    if user != login.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    let login = Login::delete(id).await.unwrap();
    Ok(login)
}

pub async fn get_all_logins(query: String, user: String) -> anyhow::Result<Vec<Login>> {
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
    let logins = Login::get_list(query).await.unwrap();
    Ok(logins)
}
