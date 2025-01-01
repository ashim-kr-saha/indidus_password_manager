# Indidus Password Manager Chrome Extension

A secure and user-friendly Chrome extension for the Indidus Password Manager that helps you manage your passwords across the web.

## Features

- **Automatic Form Detection**: Automatically detects login forms on web pages
- **Auto-fill Credentials**: Quickly fill in saved usernames and passwords
- **Password Generation**: Generate strong, secure passwords
- **Secure Storage**: All data is encrypted and securely stored
- **Auto-save**: Automatically save new credentials when you sign up on websites
- **Context Menu Integration**: Right-click access to password manager features
- **Password Health Check**: Monitor password strength and security
- **Sync Support**: Synchronize with the main Indidus Password Manager application
- **Dark Mode Support**: Automatic theme switching based on system preferences

## Installation

1. Clone this repository or download the source code
2. Open Chrome and navigate to `chrome://extensions/`
3. Enable "Developer mode" in the top right corner
4. Click "Load unpacked" and select the extension directory
5. The extension icon should appear in your Chrome toolbar

## Usage

1. **First-time Setup**
   - Click the extension icon in the toolbar
   - Enter your master password to access your passwords
   - Configure your preferences in the settings

2. **Auto-fill Passwords**
   - Visit a website with a login form
   - Click the extension icon or use the context menu
   - Select the credentials to auto-fill

3. **Save New Passwords**
   - When you log in to a new website
   - The extension will prompt to save your credentials
   - Click "Save" to store them securely

4. **Generate Passwords**
   - Click the extension icon
   - Select "Generate Password"
   - Customize the password requirements
   - Click "Copy" to use the generated password

5. **Manage Passwords**
   - Click the extension icon
   - View, edit, or delete saved passwords
   - Search for specific credentials
   - Check password health and security

## Security

- All sensitive data is encrypted using industry-standard encryption
- Master password is required for access
- Automatic locking after period of inactivity
- Secure communication with the main application
- No sensitive data is stored in plain text

## Development

### Project Structure

```
├── manifest.json           # Extension manifest
├── popup.html             # Popup interface
├── popup.js               # Popup logic
├── popup.css             # Popup styles
├── background.js         # Background service worker
├── content.js            # Content script
├── content.css          # Content styles
└── icons/               # Extension icons
```

### Building

1. Install dependencies:
   ```bash
   npm install
   ```

2. Build the extension:
   ```bash
   npm run build
   ```

3. The built extension will be in the `dist` directory

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please contact the Indidus Password Manager team or open an issue in this repository.
