check:
  cargo check --manifest-path=./rust/crates/crudlf_core/Cargo.toml
  cargo check --manifest-path=./rust/crates/crudlf_derive/Cargo.toml
  cargo check --manifest-path=./rust/crates/security/Cargo.toml
  cargo check --manifest-path=./rust/crates/sql/Cargo.toml
  cargo check --manifest-path=./rust/crates/sqlite_backup/Cargo.toml
  cargo check --manifest-path=./rust/Cargo.toml

test:
  cargo test --manifest-path=./rust/crates/crudlf_core/Cargo.toml
  cargo test --manifest-path=./rust/crates/crudlf_derive/Cargo.toml
  cargo test --manifest-path=./rust/crates/security/Cargo.toml
  cargo test --manifest-path=./rust/crates/sql/Cargo.toml
  cargo test --manifest-path=./rust/crates/sqlite_backup/Cargo.toml
  cargo test --manifest-path=./rust/Cargo.toml

frb:
  # cargo install flutter_rust_bridge_codegen
  flutter_rust_bridge_codegen generate