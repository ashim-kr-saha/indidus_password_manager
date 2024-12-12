pub fn get_ulid() -> String {
    let ulid = ulid::Ulid::new();
    ulid.to_string()
}
