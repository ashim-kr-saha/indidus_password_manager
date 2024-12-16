use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    error::ErrorUnauthorized,
    Error, HttpMessage,
};
use futures_util::future::LocalBoxFuture;
use rust_lib_password::common::{jwt::get_access_claims, time::now};
use std::{
    future::{ready, Ready},
    rc::Rc,
};

pub struct AuthMiddleware;

impl<S, B> Transform<S, ServiceRequest> for AuthMiddleware
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type InitError = ();
    type Transform = AuthMiddlewareService<S>;
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(AuthMiddlewareService {
            service: Rc::new(service),
        }))
    }
}

pub struct AuthMiddlewareService<S> {
    service: Rc<S>,
}

impl<S, B> Service<ServiceRequest> for AuthMiddlewareService<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let service = self.service.clone();

        Box::pin(async move {
            let auth_header = req
                .headers()
                .get("Authorization")
                .and_then(|header| header.to_str().ok());

            match auth_header {
                Some(auth_str) if auth_str.starts_with("Bearer ") => {
                    let token = &auth_str[7..];
                    let claims = get_access_claims(token);

                    // Check if the token is expired
                    if claims.is_err() {
                        return Err(ErrorUnauthorized("Invalid token"));
                    }
                    let claims = claims.unwrap();
                    if claims.exp < now() {
                        return Err(ErrorUnauthorized("Token expired"));
                    }
                    req.extensions_mut().insert(claims);
                    service.call(req).await
                }
                _ => Err(ErrorUnauthorized("Missing or invalid Authorization header")),
            }
        })
    }
}
