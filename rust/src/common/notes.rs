use sql::{Filter, Glue, HttpQuery};

use crate::models::Note;

use super::errors::AppError;

pub async fn fetch_note(id: String, user: String) -> anyhow::Result<Note> {
    let note = Note::get(id).await.unwrap();
    if user != note.created_by.clone().unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    Ok(note)
}

pub async fn add_note(mut data: Note, user: String) -> anyhow::Result<Note> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    data.created_by = Some(user.clone());
    data.created_at = Some(chrono::Utc::now().timestamp());
    let note = Note::insert(data).await.unwrap();
    Ok(note)
}

pub async fn update_note(id: String, mut data: Note, user: String) -> anyhow::Result<Note> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    let note = Note::get(id.clone()).await.unwrap();
    if user != note.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    data.updated_by = Some(user.clone());
    data.updated_at = Some(chrono::Utc::now().timestamp());
    let note = Note::update(id, data).await.unwrap();
    Ok(note)
}

pub async fn remove_note(id: String, user: String) -> anyhow::Result<Note> {
    let note = Note::get(id.clone()).await.unwrap();
    if user != note.created_by.unwrap() {
        return Err(AppError::Unauthorized.into());
    }
    let note = Note::delete(id).await.unwrap();
    Ok(note)
}

pub async fn get_all_notes(query: String, user: String) -> anyhow::Result<Vec<Note>> {
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
    let notes = Note::get_list(query).await.unwrap();
    Ok(notes)
}
