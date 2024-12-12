# Indidus Password Manager

Indidus Password Manager is an open-source password management application that prioritizes user control and security. It stores data locally and is designed to be private and transparent.

## Core Features

*   **Local Data Storage:** All password data is stored locally on your device and encrypted, initially using the local storage and later user-provided databases will be supported.
*   **Rust Backend:** High-performance, secure core written in Rust.
*   **Flutter Frontend:** Cross-platform application built with Flutter for consistent user experience across Android, iOS, Web, and Desktop platforms.
*   **FFI Based Connection:** Initial communication is done using Flutter FFI for fast and local communication.
*   **Browser Extensions:**  Browser extensions using JavaScript/TypeScript (will be able to connect once Rust server is setup).
*   **Open Source:** Released under the Apache 2.0 license.

## Technology Stack

*   **Backend:** Rust (using `ring` crate for encryption, and `rusqlite` for SQLite connectivity etc.), FFI via `flutter_rust_bridge`
*   **Client:** Flutter (Material/Cupertino widgets)
*   **Browser Extensions:** JavaScript or TypeScript
*   **Data Storage:** Local encrypted files initially, and user database selection in later stages.

## Architecture

*   Initially, communication between Flutter and Rust is done using FFI for a local, client-only experience.
*   In later stages, a Rust server will be created to provide a REST API or gRPC endpoints that can be used by the Flutter client and the browser extensions.

## Development Workflow

*   Git Version Control.
*   GitHub flow Branching strategy.
*   Issue tracking with GitHub Issues.
*   Unit testing.

## Contributing

We welcome contributions! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file for details.

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.

## Code of Conduct

Please review our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) file.
