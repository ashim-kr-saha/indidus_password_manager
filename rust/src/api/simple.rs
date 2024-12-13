use security::{decrypt, encrypt};

use crate::{
    common::{
        financial_cards::{
            add_financial_card, fetch_financial_card, get_all_financial_cards,
            remove_financial_card, update_financial_card,
        },
        identity_cards::{
            add_identity_card, fetch_identity_card, get_all_identity_cards, remove_identity_card,
            update_identity_card,
        },
        jwt::get_user_id_from_token,
        logins::{add_login, fetch_login, get_all_logins, remove_login, update_login},
        notes::{add_note, fetch_note, get_all_notes, remove_note, update_note},
        tags::{add_tag, fetch_tag, get_all_tags, remove_tag, update_tag},
        users::{create_user, login_user},
    },
    models::{FinancialCard, IdentityCard, JwtTokens, Login, LoginData, Note, RegisterData, Tag},
};

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[tokio::main(flavor = "current_thread")]
pub async fn encrypt_data(data: String, password: String) -> anyhow::Result<String> {
    let encrypted = encrypt(data.as_str(), password.as_str())?;
    Ok(encrypted)
}

#[tokio::main(flavor = "current_thread")]
pub async fn decrypt_data(data: String, password: String) -> anyhow::Result<String> {
    let decrypted = decrypt(data.as_str(), password.as_str())?;
    Ok(decrypted)
}

#[tokio::main(flavor = "current_thread")]
pub async fn init(db_path: String) -> (bool, String) {
    match sql::migrate_sqlite(db_path.as_str()).await {
        Ok(_) => (true, "".to_string()),
        Err(e) => {
            println!("Error: {}", e);
            (false, e.to_string())
        }
    }
}

#[tokio::main(flavor = "current_thread")]
pub async fn is_database_initialized() -> anyhow::Result<bool> {
    let initialized = sql::is_database_initialized().await?;
    Ok(initialized)
}

#[tokio::main(flavor = "current_thread")]
pub async fn register(user: RegisterData) -> anyhow::Result<JwtTokens> {
    let tokens = create_user(user).await?;
    Ok(tokens)
}

#[tokio::main(flavor = "current_thread")]
pub async fn login(user: LoginData) -> anyhow::Result<JwtTokens> {
    let user = login_user(user).await?;
    Ok(user)
}

#[tokio::main(flavor = "current_thread")]
pub async fn get_financial_card(id: String, token: String) -> anyhow::Result<FinancialCard> {
    let user = get_user_id_from_token(token).await?;
    let financial_card = fetch_financial_card(id, user).await?;
    Ok(financial_card)
}

#[tokio::main(flavor = "current_thread")]
pub async fn post_financial_card(
    data: FinancialCard,
    token: String,
) -> anyhow::Result<FinancialCard> {
    let user = get_user_id_from_token(token).await?;
    let financial_card = add_financial_card(data, user).await?;
    Ok(financial_card)
}

#[tokio::main(flavor = "current_thread")]
pub async fn put_financial_card(
    id: String,
    data: FinancialCard,
    token: String,
) -> anyhow::Result<FinancialCard> {
    let user = get_user_id_from_token(token).await?;
    let financial_card = update_financial_card(id, data, user).await?;
    Ok(financial_card)
}

#[tokio::main(flavor = "current_thread")]
pub async fn delete_financial_card(id: String, token: String) -> anyhow::Result<FinancialCard> {
    let user = get_user_id_from_token(token).await?;
    let financial_card = remove_financial_card(id, user).await?;
    Ok(financial_card)
}

#[tokio::main(flavor = "current_thread")]
pub async fn list_financial_card(
    query: String,
    token: String,
) -> anyhow::Result<Vec<FinancialCard>> {
    let user = get_user_id_from_token(token).await?;
    let financial_cards = get_all_financial_cards(query, user).await?;
    Ok(financial_cards)
}

#[tokio::main(flavor = "current_thread")]
pub async fn get_identity_card(id: String, token: String) -> anyhow::Result<IdentityCard> {
    let user = get_user_id_from_token(token).await?;
    let identity_card = fetch_identity_card(id, user).await?;
    Ok(identity_card)
}

#[tokio::main(flavor = "current_thread")]
pub async fn post_identity_card(data: IdentityCard, token: String) -> anyhow::Result<IdentityCard> {
    let user = get_user_id_from_token(token).await?;
    let identity_card = add_identity_card(data, user).await?;
    Ok(identity_card)
}

#[tokio::main(flavor = "current_thread")]
pub async fn put_identity_card(
    id: String,
    data: IdentityCard,
    token: String,
) -> anyhow::Result<IdentityCard> {
    let user = get_user_id_from_token(token).await?;
    let identity_card = update_identity_card(id, data, user).await?;
    Ok(identity_card)
}

#[tokio::main(flavor = "current_thread")]
pub async fn delete_identity_card(id: String, token: String) -> anyhow::Result<IdentityCard> {
    let user = get_user_id_from_token(token).await?;
    let identity_card = remove_identity_card(id, user).await?;
    Ok(identity_card)
}

#[tokio::main(flavor = "current_thread")]
pub async fn list_identity_card(query: String, token: String) -> anyhow::Result<Vec<IdentityCard>> {
    let user = get_user_id_from_token(token).await?;
    let identity_cards = get_all_identity_cards(query, user).await?;
    Ok(identity_cards)
}

#[tokio::main(flavor = "current_thread")]
pub async fn get_login(id: String, token: String) -> anyhow::Result<Login> {
    let user = get_user_id_from_token(token).await?;
    let login = fetch_login(id, user).await?;
    Ok(login)
}

#[tokio::main(flavor = "current_thread")]
pub async fn post_login(mut data: Login, token: String) -> anyhow::Result<Login> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    let user = get_user_id_from_token(token).await?;
    let login = add_login(data, user).await?;
    Ok(login)
}

#[tokio::main(flavor = "current_thread")]
pub async fn put_login(id: String, mut data: Login, token: String) -> anyhow::Result<Login> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    let user = get_user_id_from_token(token).await?;
    let login = update_login(id, data, user).await?;
    Ok(login)
}

#[tokio::main(flavor = "current_thread")]
pub async fn delete_login(id: String, token: String) -> anyhow::Result<Login> {
    let user = get_user_id_from_token(token).await?;
    let login = remove_login(id, user).await?;
    Ok(login)
}

#[tokio::main(flavor = "current_thread")]
pub async fn list_login(query: String, token: String) -> anyhow::Result<Vec<Login>> {
    let user = get_user_id_from_token(token).await?;
    let logins = get_all_logins(query, user).await?;
    Ok(logins)
}

#[tokio::main(flavor = "current_thread")]
pub async fn get_note(id: String, token: String) -> anyhow::Result<Note> {
    let user = get_user_id_from_token(token).await?;
    let note = fetch_note(id, user).await?;
    Ok(note)
}

#[tokio::main(flavor = "current_thread")]
pub async fn post_note(data: Note, token: String) -> anyhow::Result<Note> {
    let user = get_user_id_from_token(token).await?;
    let note = add_note(data, user).await?;
    Ok(note)
}

#[tokio::main(flavor = "current_thread")]
pub async fn put_note(id: String, mut data: Note, token: String) -> anyhow::Result<Note> {
    data.is_favorite = Some(data.is_favorite.unwrap_or(false));
    let user = get_user_id_from_token(token).await?;
    let note = update_note(id, data, user).await?;
    Ok(note)
}

#[tokio::main(flavor = "current_thread")]
pub async fn delete_note(id: String, token: String) -> anyhow::Result<Note> {
    let user = get_user_id_from_token(token).await?;
    let note = remove_note(id, user).await?;
    Ok(note)
}

#[tokio::main(flavor = "current_thread")]
pub async fn list_note(query: String, token: String) -> anyhow::Result<Vec<Note>> {
    let user = get_user_id_from_token(token).await?;
    let notes = get_all_notes(query, user).await?;
    Ok(notes)
}

#[tokio::main(flavor = "current_thread")]
pub async fn get_tag(id: String, token: String) -> anyhow::Result<Tag> {
    let user = get_user_id_from_token(token).await?;
    let tag = fetch_tag(id, user).await?;
    Ok(tag)
}

#[tokio::main(flavor = "current_thread")]
pub async fn create_tag(tag: Tag, token: String) -> anyhow::Result<Tag> {
    let user = get_user_id_from_token(token).await?;
    let tag = add_tag(tag, user).await?;
    Ok(tag)
}

#[tokio::main(flavor = "current_thread")]
pub async fn put_tag(id: String, tag: Tag, token: String) -> anyhow::Result<Tag> {
    let user = get_user_id_from_token(token).await?;
    let tag = update_tag(id, tag, user).await?;
    Ok(tag)
}

#[tokio::main(flavor = "current_thread")]
pub async fn delete_tag(id: String, token: String) -> anyhow::Result<Tag> {
    let user = get_user_id_from_token(token).await?;
    let tag = remove_tag(id, user).await?;
    Ok(tag)
}

#[tokio::main(flavor = "current_thread")]
pub async fn list_tags(query: String, token: String) -> anyhow::Result<Vec<Tag>> {
    let user = get_user_id_from_token(token).await?;
    let tags = get_all_tags(query, user).await?;
    Ok(tags)
}

#[tokio::main(flavor = "current_thread")]
pub async fn toggle_favorite(id: String, item_type: String) -> anyhow::Result<Option<bool>> {
    let result = match item_type.as_str() {
        "login" => {
            let mut login = Login::get(id).await.unwrap();
            login.is_favorite = Some(!login.is_favorite.unwrap_or(false));
            Login::update(login.id.clone().unwrap(), login)
                .await
                .unwrap()
                .is_favorite
        }
        "note" => {
            let mut note = Note::get(id).await.unwrap();
            note.is_favorite = Some(!note.is_favorite.unwrap_or(false));
            Note::update(note.id.clone().unwrap(), note)
                .await
                .unwrap()
                .is_favorite
        }
        "financial_card" => {
            let mut card = FinancialCard::get(id).await.unwrap();
            card.is_favorite = Some(!card.is_favorite.unwrap_or(false));
            FinancialCard::update(card.id.clone().unwrap(), card)
                .await
                .unwrap()
                .is_favorite
        }
        "identity_card" => {
            let mut card = IdentityCard::get(id).await.unwrap();
            card.is_favorite = Some(!card.is_favorite.unwrap_or(false));
            IdentityCard::update(card.id.clone().unwrap(), card)
                .await
                .unwrap()
                .is_favorite
        }
        _ => return Err(anyhow::anyhow!("Invalid item type")),
    };
    Ok(result)
}

#[tokio::main(flavor = "current_thread")]
pub async fn export_all_data_to_json() -> anyhow::Result<String> {
    let all_data = crate::common::backup_and_restore::export_all_data_to_json().await?;

    Ok(all_data.to_string())
}

#[tokio::main(flavor = "current_thread")]
pub async fn restore_data_from_json(data: String) -> anyhow::Result<()> {
    let _ = crate::common::backup_and_restore::restore_data_from_json(data).await?;

    Ok(())
}

#[tokio::main(flavor = "current_thread")]
pub async fn backup_data_to_server() -> anyhow::Result<()> {
    // let user = User::get(token).await?;
    // let data = crate::common::backup_and_restore::export_all_data_to_json().await?;
    // let _ = crate::common::backup_and_restore::backup_data_to_server(user.email, data).await?;

    Ok(())
}
