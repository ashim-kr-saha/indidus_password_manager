use crate::error::BackupError;
use aes::Aes256;
use cbc::{
    cipher::{BlockDecryptMut, BlockEncryptMut, KeyIvInit},
    Decryptor, Encryptor,
};
use rand::Rng;
use std::fs::File;
use std::io::{Read, Write};

pub fn encrypt_file(
    input_path: &str,
    output_path: &str,
    key: &[u8; 32],
) -> Result<(), BackupError> {
    let mut input = Vec::new();
    File::open(input_path)?.read_to_end(&mut input)?;

    let iv = rand::thread_rng().gen::<[u8; 16]>();
    let cipher = Encryptor::<Aes256>::new(key.into(), &iv.into());
    let mut buffer = vec![0u8; input.len() + 16]; // Add space for padding
    let ciphertext = cipher
        .encrypt_padded_b2b_mut::<aes::cipher::block_padding::Pkcs7>(&input, &mut buffer)
        .map_err(|e| BackupError::EncryptionError(e.to_string()))?;

    let mut output = File::create(output_path)?;
    output.write_all(&iv)?;
    output.write_all(ciphertext)?;
    Ok(())
}

pub fn decrypt_file(
    input_path: &str,
    output_path: &str,
    key: &[u8; 32],
) -> Result<(), BackupError> {
    let mut input = Vec::new();
    File::open(input_path)?.read_to_end(&mut input)?;

    let (iv, ciphertext) = input.split_at(16);
    let cipher = Decryptor::<Aes256>::new(key.into(), iv.into());
    let mut buffer = vec![0u8; ciphertext.len()];
    let decrypted_data = cipher
        .decrypt_padded_b2b_mut::<aes::cipher::block_padding::Pkcs7>(ciphertext, &mut buffer)
        .map_err(|e| BackupError::EncryptionError(e.to_string()))?;

    let mut output = File::create(output_path)?;
    output.write_all(decrypted_data)?;
    Ok(())
}
