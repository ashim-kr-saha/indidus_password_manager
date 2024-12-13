use sql::{Filter, Glue, HttpQuery};

use crate::models::Tag;

use super::errors::AppError;

pub async fn fetch_tag(id: String, user: String) -> anyhow::Result<Tag> {
    let tag = Tag::get(id).await.unwrap();
    if user != tag.created_by.clone().unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    Ok(tag)
}

pub async fn add_tag(mut data: Tag, user: String) -> anyhow::Result<Tag> {
    data.created_by = Some(user.clone());
    data.created_at = Some(chrono::Utc::now().timestamp());
    let tag = Tag::insert(data).await.unwrap();
    Ok(tag)
}

pub async fn update_tag(id: String, mut data: Tag, user: String) -> anyhow::Result<Tag> {
    let tag = Tag::get(id.clone()).await.unwrap();
    if user != tag.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    data.updated_by = Some(user.clone());
    data.updated_at = Some(chrono::Utc::now().timestamp());
    let tag = Tag::update(id, data).await.unwrap();
    Ok(tag)
}

pub async fn remove_tag(id: String, user: String) -> anyhow::Result<Tag> {
    let tag = Tag::get(id.clone()).await.unwrap();
    if user != tag.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    let tag = Tag::delete(id).await.unwrap();
    Ok(tag)
}

pub async fn get_all_tags(query: String, user: String) -> anyhow::Result<Vec<Tag>> {
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
    let tags = Tag::get_list(query).await.unwrap();
    Ok(tags)
}
