#![cfg(test)]

use crate::crudlf_insert;
use quote::quote;

#[test]
fn test_crudlf_insert() {
    let before = quote! {
        #[crudlf(table_name="logins")]
        pub struct Login {
            pub id: Option<i64>,
            #[crudlf(rename="full_name")]
            pub name: String,
            pub username: String,
            pub password: String,
            pub url: Option<String>,
            pub notes: Option<String>,
            pub deleted: Option<bool>,
            pub created_at: Option<chrono::DateTime<chrono::Utc>>,
            pub updated_at: Option<chrono::DateTime<chrono::Utc>>,
            pub deleted_at: Option<chrono::DateTime<chrono::Utc>>,
        }
    };
    crudlf_insert(before);
}
