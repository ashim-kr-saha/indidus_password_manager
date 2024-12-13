use regex::Regex;
use std::sync::OnceLock;

const EMAIL_REGEX_STR: &str = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";

// Use once_cell::sync::Lazy to initialize the regex
static EMAIL_REGEX: OnceLock<Regex> = OnceLock::new();

pub fn is_valid_email_regex(email: &str) -> bool {
    let regex = EMAIL_REGEX.get_or_init(|| Regex::new(EMAIL_REGEX_STR).unwrap());
    regex.is_match(email)
}

const PASSWORD_MIN_LENGTH: usize = 8; // Minimum password length
const PASSWORD_MAX_LENGTH: usize = 64; // Maximum password length (optional)

pub fn is_valid_password(password: &str) -> bool {
    let len = password.len();
    if len < PASSWORD_MIN_LENGTH || len > PASSWORD_MAX_LENGTH {
        return false;
    }
    let mut criteria = 0b0000;

    for &byte in password.as_bytes() {
        match byte {
            b'A'..=b'Z' => criteria |= 0b0001,
            b'a'..=b'z' => criteria |= 0b0010,
            b'0'..=b'9' => criteria |= 0b0100,
            b'!' | b'@' | b'#' | b'$' | b'%' | b'^' | b'&' | b'*' | b'_' | b'-' => {
                criteria |= 0b1000
            }
            _ => return false, // Invalid character
        }
    }
    criteria == 0b1111
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_invalid_emails() {
        let invalid_emails = vec![
            "test@re.@com",
            "example",
            "example.test@",
            "example test@example.com",
            "example@-example.com",
            "example test@example!com",
            "example@exam ple.com",
            "example@example,com",
            "user@exam_ple.com",
            "user@example..com",
            "user@-example.com",
            "user@example-.com",
            "user@.com",
            // "user@example",
            "user@.com",
            "user@example..com",
            "user@-example.com",
            "user@example-.com",
            "user@exam_ple.com",
            // ".user@example.com",
            // "user.@example.com",
            // "user..name@example.com",
            "@example.com",
            "user@example.com.",
            "us er@example.com",
            "user@exam ple.com",
            "user@example.com@example.com",
            "user@example,com",
            "",
            "@",
            "user@",
            "user@.",
            "user@.com.",
            // ".@example.com",
            "user@example_domain.com",
            "user@example.com.",
            "user name@example.com",
            "user@exam ple.com",
            "user@@example.com",
            "us@er@example.com",
        ];
        for email in invalid_emails {
            println!("Email: {}", email);
            assert!(
                !super::is_valid_email_regex(email),
                "Email should be invalid: {}",
                email
            );
        }
    }

    #[test]
    fn test_is_valid_password() {
        assert_eq!(super::is_valid_password("AshimTest@1234"), true);
        assert_eq!(super::is_valid_password("Password123"), false);
        assert_eq!(super::is_valid_password("password123"), false);
        assert_eq!(super::is_valid_password("password123!"), false);
        assert_eq!(super::is_valid_password(""), false);
    }
}
