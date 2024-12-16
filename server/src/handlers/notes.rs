use crate::errors::MyAppError;
use actix_web::{web, HttpResponse};
use rust_lib_password::{
    common::notes::{add_note, fetch_note, get_all_notes, remove_note, update_note},
    models::{Claims, Note},
};

pub async fn get_note(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let note = fetch_note(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(note))
}

pub async fn create_note(
    note: web::Json<Note>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let created_note = add_note(note.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(created_note))
}

pub async fn edit_note(
    id: web::Path<String>,
    note: web::Json<Note>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let updated_note = update_note(id.into_inner(), note.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(updated_note))
}

pub async fn delete_note(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let deleted_note = remove_note(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(deleted_note))
}

pub async fn list_notes(
    query: web::Query<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let notes = get_all_notes(query.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(notes))
}
