use actix_web::{
    middleware::Logger,
    web::{self},
    App, HttpResponse, HttpServer, Responder,
};
use handlers::{
    financial_cards::{
        create_financial_card, delete_financial_card, edit_financial_card, get_financial_card,
        list_financial_cards,
    },
    identity_cards::{
        create_identity_card, delete_identity_card, edit_identity_card, get_identity_card,
        list_identity_cards,
    },
    logins::{create_login, delete_login, edit_login, get_login, list_logins},
    notes::{create_note, delete_note, edit_note, get_note, list_notes},
    tags::{create_tag, delete_tag, edit_tag, get_tag, list_tags},
    users::{login_user_handler, my_profile_handler, register_user_handler},
};
use pnet::datalink;
use rcgen::{generate_simple_self_signed, CertifiedKey};
use rustls::ServerConfig;
use serde_json::json;
use std::env;
use std::fs::File;
use std::io::BufReader;
use std::{
    // fs::File,
    // io::BufReader,
    net::{IpAddr, Ipv4Addr, UdpSocket},
};

mod errors;
mod handlers;
mod middleware;
use middleware::auth::AuthMiddleware;

async fn index() -> impl Responder {
    HttpResponse::Ok().body("API is running!")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv::dotenv().ok();
    let db_path = env::var("DB_PATH").unwrap_or_else(|_| "/Users/ashim/Desktop/Repo/github.com/indidus/new/indidus_password_manager/rust/db.sqlite".to_string());
    sql::migrate_sqlite(db_path.as_str())
        .await
        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e.to_string()))?;

    let config = MyServerConfig::load_from_env()?;

    println!(
        "{}",
        json!({
            "server_ip": config.ip,
            "server_port": config.port,
            "server_url": format!("https://{}:{}", config.ip, config.port)
        })
    );

    HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .service(
                web::scope("/auth")
                    .route("/", web::get().to(index))
                    .route("/register", web::post().to(register_user_handler))
                    .route("/login", web::post().to(login_user_handler)),
            )
            .service(
                web::scope("/api")
                    .wrap(AuthMiddleware)
                    .route("/me", web::get().to(my_profile_handler))
                    // Logins
                    .route("/logins", web::post().to(create_login))
                    .route("/logins", web::get().to(list_logins))
                    .route("/logins/{id}", web::get().to(get_login))
                    .route("/logins/{id}", web::put().to(edit_login))
                    .route("/logins/{id}", web::delete().to(delete_login))
                    // Notes
                    .route("/notes", web::post().to(create_note))
                    .route("/notes", web::get().to(list_notes))
                    .route("/notes/{id}", web::get().to(get_note))
                    .route("/notes/{id}", web::put().to(edit_note))
                    .route("/notes/{id}", web::delete().to(delete_note))
                    // Financial Cards
                    .route("/financial-cards", web::post().to(create_financial_card))
                    .route("/financial-cards", web::get().to(list_financial_cards))
                    .route("/financial-cards/{id}", web::get().to(get_financial_card))
                    .route("/financial-cards/{id}", web::put().to(edit_financial_card))
                    .route(
                        "/financial-cards/{id}",
                        web::delete().to(delete_financial_card),
                    )
                    // Identity Cards
                    .route("/identity-cards", web::post().to(create_identity_card))
                    .route("/identity-cards", web::get().to(list_identity_cards))
                    .route("/identity-cards/{id}", web::get().to(get_identity_card))
                    .route("/identity-cards/{id}", web::put().to(edit_identity_card))
                    .route(
                        "/identity-cards/{id}",
                        web::delete().to(delete_identity_card),
                    )
                    // Tags
                    .route("/tags", web::post().to(create_tag))
                    .route("/tags", web::get().to(list_tags))
                    .route("/tags/{id}", web::get().to(get_tag))
                    .route("/tags/{id}", web::put().to(edit_tag))
                    .route("/tags/{id}", web::delete().to(delete_tag)),
            )
    })
    .workers(4) // Set the number of workers here
    .shutdown_timeout(30) // Set shutdown timeout in seconds
    .bind_rustls_0_23((config.ip, config.port), config.tls_config)?
    .run()
    .await
}

struct MyServerConfig {
    ip: Ipv4Addr,
    port: u16,
    tls_config: ServerConfig,
}

impl MyServerConfig {
    fn load_from_env() -> std::io::Result<Self> {
        let ip = env::var("SERVER_IP")
            .map(|s| s.parse().expect("Invalid IP address"))
            .unwrap_or_else(|_| get_lan_ip());
        let port = env::var("SERVER_PORT")
            .unwrap_or_else(|_| "8443".to_string())
            .parse()
            .unwrap_or(8443);

        let tls_config = if let (Ok(cert_path), Ok(key_path)) =
            (env::var("CERT_PEM_PATH"), env::var("KEY_PEM_PATH"))
        {
            println!(
                "{}",
                json!({
                    "message": "Using user-defined certificate",
                    "cert_path": cert_path,
                    "key_path": key_path
                })
            );
            create_tls_config_from_file(&cert_path, &key_path)?
        } else {
            println!(
                "{}",
                json!({
                    "message": "Using self-signed certificate"
                })
            );
            self_signed_create_tls_config(ip)?
        };

        Ok(Self {
            ip,
            port,
            tls_config,
        })
    }
}

fn self_signed_create_tls_config(ip: Ipv4Addr) -> std::io::Result<ServerConfig> {
    let (pem_serialized, key_pair) = generate_self_signed_cert(ip)
        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))?;

    let tls_certs = rustls_pemfile::certs(&mut pem_serialized.as_slice())
        .collect::<Result<Vec<_>, _>>()
        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))?;

    let tls_key = rustls_pemfile::pkcs8_private_keys(&mut key_pair.as_slice())
        .next()
        .ok_or_else(|| {
            std::io::Error::new(std::io::ErrorKind::Other, "Failed to parse private key")
        })??;

    ServerConfig::builder()
        .with_no_client_auth()
        .with_single_cert(tls_certs, rustls::pki_types::PrivateKeyDer::Pkcs8(tls_key))
        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))
}

fn generate_self_signed_cert(ip: Ipv4Addr) -> Result<(Vec<u8>, Vec<u8>), rcgen::Error> {
    let cert: CertifiedKey = generate_simple_self_signed(vec![
        "localhost".to_string(),
        ip.to_string(),
        "127.0.0.1".to_string(),
    ])?;

    let key_pair = cert.key_pair;
    let pem_serialized = cert.cert.pem();

    Ok((
        pem_serialized.as_bytes().to_vec(),
        key_pair.serialize_pem().as_bytes().to_vec(),
    ))
}

fn get_lan_ip() -> Ipv4Addr {
    get_lan_ip_from_udp().unwrap_or_else(get_lan_ip_from_interfaces)
}

fn get_lan_ip_from_udp() -> Option<Ipv4Addr> {
    const DNS_SERVERS: &[&str] = &["1.1.1.1", "1.0.0.1", "9.9.9.9", "149.112.112.112"];

    DNS_SERVERS.iter().find_map(|&dns_server| {
        UdpSocket::bind("0.0.0.0:0")
            .ok()
            .and_then(|socket| socket.connect(dns_server).ok().map(|_| socket))
            .and_then(|socket| socket.local_addr().ok())
            .and_then(|addr| {
                if let IpAddr::V4(ipv4) = addr.ip() {
                    Some(ipv4)
                } else {
                    None
                }
            })
    })
}

fn get_lan_ip_from_interfaces() -> Ipv4Addr {
    datalink::interfaces()
        .iter()
        .flat_map(|interface| interface.ips.iter())
        .find_map(|ip| {
            if let IpAddr::V4(ipv4) = ip.ip() {
                if !ipv4.is_loopback() && !ipv4.is_link_local() {
                    return Some(ipv4);
                }
            }
            None
        })
        .unwrap_or(Ipv4Addr::new(127, 0, 0, 1))
}

fn create_tls_config_from_file(cert_path: &str, key_path: &str) -> std::io::Result<ServerConfig> {
    let cert_file = &mut BufReader::new(File::open(cert_path)?);
    let key_file = &mut BufReader::new(File::open(key_path)?);

    let cert_chain = rustls_pemfile::certs(cert_file)
        .collect::<Result<Vec<_>, _>>()
        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))?;

    let mut keys = rustls_pemfile::pkcs8_private_keys(key_file)
        .collect::<Result<Vec<_>, _>>()
        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))?;

    if keys.is_empty() {
        return Err(std::io::Error::new(
            std::io::ErrorKind::Other,
            "No PKCS8 private keys found in the key file",
        ));
    }

    ServerConfig::builder()
        .with_no_client_auth()
        .with_single_cert(
            cert_chain,
            rustls::pki_types::PrivateKeyDer::Pkcs8(keys.remove(0)),
        )
        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))
}

mod test {
    // use crate::*;
    // use rcgen::Certificate;

    #[test]
    fn test_generate_self_signed_cert() {
        let ip = std::net::Ipv4Addr::new(192, 168, 1, 1);
        let (pem_serialized, der_serialized) = crate::generate_self_signed_cert(ip).unwrap();
        assert_ne!(pem_serialized.len(), 0);
        assert_ne!(der_serialized.len(), 0);
    }
}
