use crate::models::{FinancialCard, IdentityCard, Login, Note, Tag};

use serde_json::json;

pub async fn export_all_data_to_json() -> anyhow::Result<String> {
    let mut all_data = json!({});

    let query = sql::HttpQuery::default();

    // Export FinancialCards
    let financial_cards: Vec<FinancialCard> = FinancialCard::get_list(query.clone()).await?;
    all_data["financial_cards"] = serde_json::to_value(financial_cards)?;

    // Export IdentityCards
    let identity_cards: Vec<IdentityCard> = IdentityCard::get_list(query.clone()).await?;
    all_data["identity_cards"] = serde_json::to_value(identity_cards)?;

    // Export Logins
    let logins: Vec<Login> = Login::get_list(query.clone()).await?;
    all_data["logins"] = serde_json::to_value(logins)?;

    // Export Notes
    let notes: Vec<Note> = Note::get_list(query.clone()).await?;
    all_data["notes"] = serde_json::to_value(notes)?;

    // Export Tags
    let tags: Vec<Tag> = Tag::get_list(query).await?;
    all_data["tags"] = serde_json::to_value(tags)?;

    Ok(all_data.to_string())
}

pub async fn restore_data_from_json(data: String) -> anyhow::Result<()> {
    let json_data: serde_json::Value = serde_json::from_str(&data)?;

    if let Some(tags) = json_data.get("tags").and_then(|v| v.as_array()) {
        for record in tags {
            let record: Tag = serde_json::from_value(record.clone())?;
            restore_tags(record).await?;
        }
    }

    if let Some(financial_cards) = json_data.get("financial_cards").and_then(|v| v.as_array()) {
        for record in financial_cards {
            let record: FinancialCard = serde_json::from_value(record.clone())?;
            restore_financial_cards(record).await?;
        }
    }

    if let Some(identity_cards) = json_data.get("identity_cards").and_then(|v| v.as_array()) {
        for record in identity_cards {
            let record: IdentityCard = serde_json::from_value(record.clone())?;
            restore_identity_cards(record).await?;
        }
    }

    if let Some(logins) = json_data.get("logins").and_then(|v| v.as_array()) {
        for record in logins {
            let record: Login = serde_json::from_value(record.clone())?;
            restore_logins(record).await?;
        }
    }

    if let Some(notes) = json_data.get("notes").and_then(|v| v.as_array()) {
        for record in notes {
            let record: Note = serde_json::from_value(record.clone())?;
            restore_notes(record).await?;
        }
    }

    Ok(())
}

async fn restore_logins(login: Login) -> anyhow::Result<()> {
    if let Some(existing_record) = Login::get(login.id.clone().unwrap()).await.ok() {
        if login.created_at >= existing_record.created_at
            || login.updated_at >= existing_record.updated_at
        {
            Login::update(login.id.clone().unwrap(), login.clone()).await?;
        }
    } else {
        Login::insert(login.clone()).await?;
    }

    Ok(())
}

async fn restore_financial_cards(financial_card: FinancialCard) -> anyhow::Result<()> {
    if let Some(existing_record) = FinancialCard::get(financial_card.id.clone().unwrap())
        .await
        .ok()
    {
        if financial_card.created_at >= existing_record.created_at
            || financial_card.updated_at >= existing_record.updated_at
        {
            FinancialCard::update(financial_card.id.clone().unwrap(), financial_card.clone())
                .await?;
        }
    } else {
        FinancialCard::insert(financial_card.clone()).await?;
    }

    Ok(())
}

async fn restore_identity_cards(identity_card: IdentityCard) -> anyhow::Result<()> {
    if let Some(existing_record) = IdentityCard::get(identity_card.id.clone().unwrap())
        .await
        .ok()
    {
        if identity_card.created_at >= existing_record.created_at
            || identity_card.updated_at >= existing_record.updated_at
        {
            IdentityCard::update(identity_card.id.clone().unwrap(), identity_card.clone()).await?;
        }
    } else {
        IdentityCard::insert(identity_card.clone()).await?;
    }

    Ok(())
}

async fn restore_notes(note: Note) -> anyhow::Result<()> {
    if let Some(existing_record) = Note::get(note.id.clone().unwrap()).await.ok() {
        if note.created_at >= existing_record.created_at
            || note.updated_at >= existing_record.updated_at
        {
            Note::update(note.id.clone().unwrap(), note.clone()).await?;
        }
    } else {
        Note::insert(note.clone()).await?;
    }

    Ok(())
}

async fn restore_tags(tag: Tag) -> anyhow::Result<()> {
    if let Some(existing_record) = Tag::get(tag.id.clone().unwrap()).await.ok() {
        if tag.created_at >= existing_record.created_at
            || tag.updated_at >= existing_record.updated_at
        {
            Tag::update(tag.id.clone().unwrap(), tag.clone()).await?;
        }
    } else {
        Tag::insert(tag.clone()).await?;
    }

    Ok(())
}

mod tests {

    #[tokio::test]
    async fn test_export_and_restore_json() {
        let temp_db = tempfile::NamedTempFile::new().unwrap();
        let db_path = temp_db.path().to_str().unwrap();

        sql::migrate_sqlite(db_path).await.unwrap();
        let json_data = crate::common::backup_and_restore::export_all_data_to_json()
            .await
            .unwrap();
        crate::common::backup_and_restore::restore_data_from_json(json_data)
            .await
            .unwrap();
        println!("Data restored successfully");

        // The temporary file will be automatically deleted when it goes out of scope
    }
}
