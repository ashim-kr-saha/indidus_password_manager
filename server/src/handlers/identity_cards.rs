use crate::errors::MyAppError;
use actix_web::{web, HttpResponse};
use rust_lib_password::{
    common::identity_cards::{
        add_identity_card, fetch_identity_card, get_all_identity_cards, remove_identity_card,
        update_identity_card,
    },
    models::{Claims, IdentityCard},
};

pub async fn get_identity_card(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let identity_card = fetch_identity_card(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(identity_card))
}

pub async fn create_identity_card(
    identity_card: web::Json<IdentityCard>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let created_identity_card =
        add_identity_card(identity_card.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(created_identity_card))
}

pub async fn edit_identity_card(
    id: web::Path<String>,
    identity_card: web::Json<IdentityCard>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let updated_identity_card = update_identity_card(
        id.into_inner(),
        identity_card.into_inner(),
        claims.uid.clone(),
    )
    .await?;
    Ok(HttpResponse::Ok().json(updated_identity_card))
}

pub async fn delete_identity_card(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let deleted_identity_card = remove_identity_card(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(deleted_identity_card))
}

pub async fn list_identity_cards(
    query: web::Query<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let identity_cards = get_all_identity_cards(query.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(identity_cards))
}
