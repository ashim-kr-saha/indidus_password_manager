use actix_web::{web, HttpMessage, HttpRequest, HttpResponse};
use rust_lib_password::{
    common::{
        errors::AppError,
        users::{create_user, login_user, my_profile},
    },
    models::{Claims, LoginData, RegisterData},
};

use crate::errors::MyAppError;

pub async fn register_user_handler(
    user: web::Json<RegisterData>,
) -> Result<HttpResponse, MyAppError> {
    let user = create_user(user.into_inner()).await;
    if user.is_err() {
        return Err(MyAppError(user.err().unwrap()));
    }
    Ok(HttpResponse::Ok().json(user.unwrap()))
}

pub async fn login_user_handler(user: web::Json<LoginData>) -> Result<HttpResponse, MyAppError> {
    let token = login_user(user.into_inner()).await;
    if token.is_err() {
        return Err(MyAppError(token.err().unwrap()));
    }
    Ok(HttpResponse::Ok().json(token.unwrap()))
}

pub async fn my_profile_handler(req: HttpRequest) -> Result<HttpResponse, MyAppError> {
    // Use the `extensions()` method on HttpRequest to get the Claims
    let claims: Claims = req
        .extensions()
        .get::<Claims>()
        .cloned()
        .ok_or_else(|| AppError::Unauthorized)?;

    let user_id = claims.uid.clone();
    let user = my_profile(user_id).await;
    if user.is_err() {
        return Err(MyAppError(user.err().unwrap()));
    }
    Ok(HttpResponse::Ok().json(user.unwrap()))
}
