use crate::errors::MyAppError;
use actix_web::{web, HttpResponse};
use rust_lib_password::{
    common::tags::{add_tag, fetch_tag, get_all_tags, remove_tag, update_tag},
    models::{Claims, Tag},
};

pub async fn get_tag(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let tag = fetch_tag(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(tag))
}

pub async fn create_tag(
    tag: web::Json<Tag>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let created_tag = add_tag(tag.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Created().json(created_tag))
}

pub async fn edit_tag(
    id: web::Path<String>,
    tag: web::Json<Tag>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let updated_tag = update_tag(id.into_inner(), tag.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(updated_tag))
}

pub async fn delete_tag(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let deleted_tag = remove_tag(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(deleted_tag))
}

pub async fn list_tags(
    query: web::Query<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let tags = get_all_tags(query.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(tags))
}
