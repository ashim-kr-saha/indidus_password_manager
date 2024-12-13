pub fn now() -> usize {
    chrono::Utc::now().timestamp() as usize
}
mod tests {
    #[test]
    fn test_now() {
        let now = super::now();
        assert!(now > 0);
    }
}
