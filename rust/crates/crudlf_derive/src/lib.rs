use crudlf_core::{crudlf_delete, crudlf_insert, crudlf_list_filter, crudlf_select, crudlf_update};
use proc_macro::TokenStream;
use proc_macro_error::proc_macro_error;

#[proc_macro_error]
#[proc_macro_derive(SqliteInsert, attributes(crudlf))]
pub fn sqlite_insert(input: TokenStream) -> TokenStream {
    crudlf_insert(proc_macro2::TokenStream::from(input)).into()
}

#[proc_macro_error]
#[proc_macro_derive(SqliteUpdate, attributes(crudlf))]
pub fn sqlite_update(input: TokenStream) -> TokenStream {
    crudlf_update(proc_macro2::TokenStream::from(input)).into()
}

#[proc_macro_error]
#[proc_macro_derive(SqliteSelect, attributes(crudlf))]
pub fn sqlite_select(input: TokenStream) -> TokenStream {
    crudlf_select(proc_macro2::TokenStream::from(input)).into()
}

#[proc_macro_error]
#[proc_macro_derive(SqliteDelete, attributes(crudlf))]
pub fn sqlite_delete(input: TokenStream) -> TokenStream {
    crudlf_delete(proc_macro2::TokenStream::from(input)).into()
}

#[proc_macro_error]
#[proc_macro_derive(SqliteListFilter, attributes(crudlf))]
pub fn sqlite_list_filter(input: TokenStream) -> TokenStream {
    crudlf_list_filter(proc_macro2::TokenStream::from(input)).into()
}
