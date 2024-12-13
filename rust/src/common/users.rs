use sql::{FilterOperator, HttpQuery};

use crate::models::{JwtTokens, LoginData, RegisterData, User};

use super::{
    errors::AppError,
    jwt::generate_access_and_refresh_tokens,
    password::{password_hash, verify_password},
    time::now,
    validation::{is_valid_email_regex, is_valid_password},
};

pub async fn create_user(data: RegisterData) -> Result<JwtTokens, AppError> {
    if data.password != data.re_password {
        return Err(AppError::PasswordsDoNotMatch);
    }
    if !is_valid_password(&data.password) {
        return Err(AppError::PasswordTooWeak);
    }
    if !is_valid_email_regex(&data.email) {
        return Err(AppError::InvalidEmail);
    }

    let email = data.email.to_lowercase();
    let password_hash = password_hash(&data.password)?;

    let mut user = User::from(data);
    user.password_hash = password_hash;
    let id = ulid::Ulid::new().to_string();
    user.id = Some(id.clone());
    user.created_at = Some(now() as i64);
    user.email = email;

    // TODO: Change this to the actual user id of the user who created the user
    user.created_by = Some(id);

    let user = User::insert(user).await?;

    // Login the user after registration
    let (access_token, refresh_token) = generate_access_and_refresh_tokens(user.id.unwrap())?;
    Ok(JwtTokens {
        access_token,
        refresh_token,
    })
}

pub async fn my_profile(user_id: String) -> Result<User, AppError> {
    let query = HttpQuery::builder()
        .filter(|filter| {
            filter
                .column("id")
                .operator(FilterOperator::Eq)
                .value(user_id)
                .build()
        })
        .build();
    let users = User::get_list(query).await?;
    if users.is_empty() {
        return Err(AppError::UserNotFound);
    }
    Ok(users.first().unwrap().to_owned())
}

pub async fn login_user(data: LoginData) -> Result<JwtTokens, AppError> {
    let email = data.email.to_lowercase();
    let query = HttpQuery::builder()
        .filter(|filter| {
            filter
                .column("email")
                .operator(FilterOperator::Eq)
                .value(email)
                .build()
        })
        .limit(1)
        .build();

    let users = User::get_list(query)
        .await?
        .into_iter()
        .collect::<Vec<User>>();

    if users.is_empty() {
        return Err(AppError::InvalidCredentials);
    }
    let user = users.first().unwrap();
    let match_password = verify_password(&data.password, &user.password_hash)?;
    if !match_password {
        return Err(AppError::InvalidCredentials);
    }

    let (access_token, refresh_token) =
        generate_access_and_refresh_tokens(user.id.clone().unwrap())?;
    Ok(JwtTokens {
        access_token,
        refresh_token,
    })
}
