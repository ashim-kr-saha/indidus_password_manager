use crate::errors::MyAppError;
use actix_web::{web, HttpResponse};
use rust_lib_password::{
    common::logins::{add_login, fetch_login, get_all_logins, remove_login, update_login},
    models::{Claims, Login},
};

pub async fn get_login(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let login = fetch_login(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(login))
}

pub async fn create_login(
    login: web::Json<Login>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let created_login = add_login(login.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Created().json(created_login))
}

pub async fn edit_login(
    id: web::Path<String>,
    login: web::Json<Login>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let updated_login =
        update_login(id.into_inner(), login.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(updated_login))
}

pub async fn delete_login(
    id: web::Path<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let deleted_login = remove_login(id.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(deleted_login))
}

pub async fn list_logins(
    query: web::Query<String>,
    claims: web::ReqData<Claims>,
) -> Result<HttpResponse, MyAppError> {
    let logins = get_all_logins(query.into_inner(), claims.uid.clone()).await?;
    Ok(HttpResponse::Ok().json(logins))
}
