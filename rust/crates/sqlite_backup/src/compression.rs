use crate::error::BackupError;
use flate2::write::GzEncoder;
use flate2::Compression;
use std::fs::File;
use std::io::prelude::*;

pub fn compress_file(input_path: &str, output_path: &str) -> Result<(), BackupError> {
    let mut input = File::open(input_path)?;
    let mut encoder = GzEncoder::new(File::create(output_path)?, Compression::default());
    let mut buffer = Vec::new();
    input.read_to_end(&mut buffer)?;
    encoder.write_all(&buffer)?;
    encoder.finish()?;
    Ok(())
}

pub fn decompress_file(input_path: &str, output_path: &str) -> Result<(), BackupError> {
    use flate2::read::GzDecoder;
    use std::io::copy;

    let input = File::open(input_path)?;
    let mut decoder = GzDecoder::new(input);
    let mut output = File::create(output_path)?;
    copy(&mut decoder, &mut output)?;
    Ok(())
}
