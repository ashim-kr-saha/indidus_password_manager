use crate::errors::MyAppError;
use actix_web::{web, HttpResponse};
use rust_lib_password::{
    common::financial_cards::{
        add_financial_card, fetch_financial_card, get_all_financial_cards, remove_financial_card,
        update_financial_card,
    },
    models::{Claims, FinancialCard},
};

pub async fn get_financial_card(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let financial_card = fetch_financial_card(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(financial_card))
}

pub async fn create_financial_card(
    financial_card: web::Json<FinancialCard>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let created_financial_card =
        add_financial_card(financial_card.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Created().json(created_financial_card))
}

pub async fn edit_financial_card(
    id: web::Path<String>,
    financial_card: web::Json<FinancialCard>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let updated_financial_card = update_financial_card(
        id.into_inner(),
        financial_card.into_inner(),
        claims.uid.clone(),
    )
    .await?;
    Ok(HttpResponse::Ok().json(updated_financial_card))
}

pub async fn delete_financial_card(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let deleted_financial_card = remove_financial_card(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(deleted_financial_card))
}

pub async fn list_financial_cards(
    query: web::Query<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let financial_cards = get_all_financial_cards(query.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(financial_cards))
}
