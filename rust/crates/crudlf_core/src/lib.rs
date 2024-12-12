mod tests;
use proc_macro2::{Ident, TokenStream};
use quote::{format_ident, quote, ToTokens};
use syn::{parse2, Expr, ItemStruct};

struct CrudlfField {
    struct_field_name: String,
    db_field_name: String,
    // is_optional: bool,
    // select_query: String,
    skip: bool,
}

pub fn crudlf_insert(input: TokenStream) -> TokenStream {
    let input: ItemStruct = match parse2::<ItemStruct>(input) {
        Ok(syntax_tree) => syntax_tree,
        Err(error) => return error.to_compile_error(),
    };

    let name = input.ident.clone();

    let db_fields: Vec<CrudlfField> = input
        .fields
        .iter()
        .map(|field| get_db_field_name(field))
        .filter(|field| !field.skip)
        .collect();

    let db_fields_names: Vec<String> = db_fields
        .iter()
        .map(|field| field.db_field_name.clone())
        .collect::<Vec<String>>();

    let struct_fields_names: Vec<Ident> = db_fields
        .iter()
        .map(|field| format_ident!("{}", field.struct_field_name.clone()))
        .collect::<Vec<Ident>>();

    let db_insert_fields: String = db_fields_names.join(", ");
    let db_field_placeholders: String = (0..db_fields_names.len())
        .map(|_| "?")
        .collect::<Vec<_>>()
        .join(", ");
    let db_table_name: String = get_db_table_name(input.clone());
    let query = format!(
        "INSERT INTO {} ({}) VALUES ({})",
        db_table_name, db_insert_fields, db_field_placeholders
    );

    let t = TokenStream::from(quote! {
        impl #name {
            pub async fn insert(mut data: #name) -> Result<#name, sql::SqlError> {
                let mut conn = sql::get_db_connection()?;
                let tx = conn.transaction()?;

                if data.id.is_none() {
                    let id = sql::get_ulid();
                    data.id = Some(id);
                }

                let result = tx.execute(
                    #query,
                    rusqlite::params![#(data.#struct_fields_names),*],
                )?;

                if result == 1 {
                    tx.commit()?;
                    Ok(data)
                } else {
                    tx.rollback()?;
                    Err(sql::SqlError::QueryReturnedNoRows)
                }
            }
        }
    });
    t
}

pub fn crudlf_update(input: TokenStream) -> TokenStream {
    let input: ItemStruct = match parse2::<ItemStruct>(input) {
        Ok(syntax_tree) => syntax_tree,
        Err(error) => return error.to_compile_error(),
    };

    let name = input.ident.clone();

    let db_fields: Vec<CrudlfField> = input
        .fields
        .iter()
        .map(|field| get_db_field_name(field))
        .filter(|field| !field.skip)
        .collect();

    let db_fields_names: Vec<String> = db_fields
        .iter()
        .filter(|field| field.db_field_name != "id")
        .map(|field| field.db_field_name.clone())
        .collect::<Vec<String>>();

    let struct_fields_names: Vec<Ident> = db_fields
        .iter()
        .filter(|field| field.db_field_name != "id")
        .map(|field| format_ident!("{}", field.struct_field_name.clone()))
        .collect::<Vec<Ident>>();

    // let db_return_fields = db_fields
    //     .iter()
    //     .map(|field| field.select_query.clone())
    //     .collect::<Vec<String>>()
    //     .join(", ");

    let mut db_update_fields: String = db_fields_names.join(" = ?, ");
    db_update_fields.push_str(" = ?");
    let db_table_name: String = get_db_table_name(input.clone());
    let query = format!(
        "UPDATE {} SET {} WHERE id = ?",
        db_table_name, db_update_fields
    );

    let t = TokenStream::from(quote! {
        impl #name {
            pub async fn update(
                id: String,
                mut data: #name,
            ) -> Result<#name, sql::SqlError> {
                let mut conn = sql::get_db_connection()?;
                let tx = conn.transaction()?;

                data.id = Some(id);

                let result = tx.execute(
                    #query,
                    rusqlite::params![#(data.#struct_fields_names,)* data.id],
                )?;

                if result == 1 {
                    tx.commit()?;
                    Ok(data)
                } else {
                    tx.rollback()?;
                    Err(sql::SqlError::QueryReturnedNoRows)
                }
            }
        }
    });
    t
}

pub fn crudlf_select(input: TokenStream) -> TokenStream {
    let input: ItemStruct = match parse2::<ItemStruct>(input) {
        Ok(syntax_tree) => syntax_tree,
        Err(error) => return error.to_compile_error(),
    };

    let name = input.ident.clone();

    let db_fields: Vec<CrudlfField> = input
        .fields
        .iter()
        .map(|field| get_db_field_name(field))
        .filter(|field| !field.skip)
        .collect();

    let struct_fields_names: Vec<Ident> = db_fields
        .iter()
        .map(|field| format_ident!("{}", field.struct_field_name.clone()))
        .collect::<Vec<Ident>>();

    let db_return_fields = db_fields
        .iter()
        .map(|field| field.db_field_name.clone())
        .collect::<Vec<String>>()
        .join(", ");

    let db_table_name: String = get_db_table_name(input.clone());
    let query = format!(
        "SELECT {} FROM {} WHERE id = ?",
        db_return_fields, db_table_name
    );

    let t = TokenStream::from(quote! {
        impl #name {
            pub async fn get(id: String) -> Result<#name, sql::SqlError> {
                let conn = sql::get_db_connection()?;

                let mut stmt = conn.prepare(#query)?;
                let mut rows = stmt.query(rusqlite::params![id])?;

                if let Some(row) = rows.next()? {
                    Ok(#name {
                        #(
                            #struct_fields_names: row.get(stringify!(#struct_fields_names))?,
                        )*
                        ..Default::default()
                    })
                } else {
                    Err(sql::SqlError::QueryReturnedNoRows)
                }
            }
        }
    });
    t
}

pub fn crudlf_delete(input: TokenStream) -> TokenStream {
    let input: ItemStruct = match parse2::<ItemStruct>(input) {
        Ok(syntax_tree) => syntax_tree,
        Err(error) => return error.to_compile_error(),
    };

    let name = input.ident.clone();

    let db_fields: Vec<CrudlfField> = input
        .fields
        .iter()
        .map(|field| get_db_field_name(field))
        .filter(|field| !field.skip)
        .collect();

    let db_return_fields = db_fields
        .iter()
        .map(|field| field.db_field_name.clone())
        .collect::<Vec<String>>()
        .join(", ");

    // let struct_fields_names: Vec<Ident> = db_fields
    //     .iter()
    //     .map(|field| format_ident!("{}", field.struct_field_name.clone()))
    //     .collect::<Vec<Ident>>();

    let db_table_name: String = get_db_table_name(input.clone());
    let query = format!(
        "DELETE FROM {} WHERE id = ? RETURNING {}",
        db_table_name, db_return_fields
    );

    let t = TokenStream::from(quote! {
        impl #name {
            pub async fn delete(id: String) -> Result<#name, sql::SqlError> {
                let mut conn = sql::get_db_connection()?;
                let tx = conn.transaction()?;

                let result = tx.execute(#query, rusqlite::params![id])?;

                if result == 1 {
                    tx.commit()?;
                    Ok(#name {
                        id: Some(id),
                        ..Default::default()
                    })
                } else {
                    tx.rollback()?;
                    Err(sql::SqlError::QueryReturnedNoRows)
                }
            }
        }
    });
    t
}

pub fn crudlf_list_filter(input: TokenStream) -> TokenStream {
    let input: ItemStruct = match parse2::<ItemStruct>(input) {
        Ok(syntax_tree) => syntax_tree,
        Err(error) => return error.to_compile_error(),
    };

    let name = input.ident.clone();

    let db_table_name: String = get_db_table_name(input.clone());

    let db_fields: Vec<CrudlfField> = input
        .fields
        .iter()
        .map(|field| get_db_field_name(field))
        .filter(|field| !field.skip)
        .collect();

    let struct_fields_names: Vec<Ident> = db_fields
        .iter()
        .map(|field| format_ident!("{}", field.struct_field_name.clone()))
        .collect::<Vec<Ident>>();

    let t = TokenStream::from(quote! {
        impl #name {
            pub async fn get_list(query: sql::HttpQuery) -> Result<Vec<#name>, sql::SqlError> {
                let conn = sql::get_db_connection()?;

                let mut query = sql::SqLiteQueryBuilder::new(#db_table_name.to_string(), query);
                let (query_string, params) = query.build_sqlite_query();

                let mut stmt = conn.prepare(&query_string)?;

                let param_refs: Vec<&dyn rusqlite::ToSql> = params.iter().map(|p| p as &dyn rusqlite::ToSql).collect();
                let rows = stmt.query_map(param_refs.as_slice(), |row| {
                    Ok(#name {
                        #(
                            #struct_fields_names: row.get(stringify!(#struct_fields_names))?,
                        )*
                        ..Default::default()
                    })
                })?;

                let mut results = Vec::new();
                for row in rows {
                    results.push(row?);
                }

                Ok(results)
            }
        }
    });
    t
}

fn get_db_table_name(item: ItemStruct) -> String {
    let mut name = "".to_string();
    item.attrs.iter().for_each(|attr| {
        if attr.path().is_ident("crudlf") {
            let t: Expr = attr.parse_args().unwrap();
            match t {
                Expr::Assign(e) => {
                    if e.left.to_token_stream().to_string() == "table_name" {
                        name = e.right.to_token_stream().to_string();
                        name = name.replace("\"", "");
                    } else {
                        panic!("Attribute expression must be in the form of #[crudlf(table_name=\"table_name\")]");
                    }
                }
                _ => {
                    panic!("Not a valid attribute expression for table name");
                }
            }
        }
    });
    if name == "" {
        name = item.ident.to_string();
    }
    name
}

// Get the attributes of the field
fn get_db_field_name(field: &syn::Field) -> CrudlfField {
    let mut name = "".to_string();
    let mut skip = false;
    field.attrs.iter().for_each(|attr| {
        if attr.path().is_ident("crudlf") {
            let t: Expr = attr.parse_args().unwrap();
            match t {
                Expr::Assign(e) => {
                    let left = e.left.to_token_stream().to_string();
                    if left == "rename" {
                        name = e.right.to_token_stream().to_string();
                        name = name.replace("\"", "");
                    } else {
                        panic!("Attribute expression must be in the form of #[crudlf(rename=\"field_name\")] or #[crudlf(skip=\"true\")]");
                    }
                }
                Expr::Path(e) => {
                    name = e.path.to_token_stream().to_string();
                    if name == "skip" {
                        skip = true;
                    }
                }
                _ => {
                    panic!("Not a valid attribute expression for field");
                }
            }
        }
    });
    let struct_field_name = field.ident.as_ref().unwrap().to_string();
    if name == "" {
        name = struct_field_name.clone();
    }
    if skip {
        return CrudlfField {
            db_field_name: "".to_string(),
            struct_field_name: struct_field_name,
            // select_query: "".to_string(),
            skip: true,
        };
    }
    let is_optional = field
        .ty
        .clone()
        .into_token_stream()
        .to_string()
        .starts_with("Option");

    if is_optional {
        return CrudlfField {
            db_field_name: name.clone(),
            struct_field_name,
            // select_query: format!("{} as \"{}?\"", name, name),
            skip,
        };
    }
    CrudlfField {
        db_field_name: name.clone(),
        struct_field_name,
        // select_query: format!("{} as \"{}!\"", name, name),
        skip,
    }
}

// fn get_db_field_placeholders(vec: Vec<String>) -> String {
//     let mut placeholders = String::new();
//     vec.iter().for_each(|_| {
//         placeholders.push_str("?, ");
//     });
//     placeholders.pop();
//     placeholders.pop();
//     placeholders
// }
