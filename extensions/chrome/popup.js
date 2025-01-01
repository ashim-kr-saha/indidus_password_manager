class PasswordManager {
    constructor() {
        this.isLoggedIn = false;
        this.initializeEventListeners();
    }

    initializeEventListeners() {
        document.getElementById('login-btn').addEventListener('click', () => this.handleLogin());
        document.getElementById('logout').addEventListener('click', () => this.handleLogout());
        document.getElementById('add-password').addEventListener('click', () => this.showAddPasswordForm());
        document.getElementById('generate-password').addEventListener('click', () => this.generatePassword());
        document.getElementById('search').addEventListener('input', (e) => this.handleSearch(e));
        document.getElementById('sync').addEventListener('click', () => this.syncPasswords());
        document.getElementById('settings').addEventListener('click', () => this.showSettings());
    }

    async handleLogin() {
        const masterPassword = document.getElementById('master-password').value;
        if (!masterPassword) {
            this.showNotification('Please enter master password', 'error');
            return;
        }

        try {
            // Here you would typically verify the master password with your backend
            const isValid = await this.verifyMasterPassword(masterPassword);
            if (isValid) {
                this.isLoggedIn = true;
                document.getElementById('login-section').classList.add('hidden');
                document.getElementById('main-section').classList.remove('hidden');
                this.loadPasswords();
            } else {
                this.showNotification('Invalid master password', 'error');
            }
        } catch (error) {
            this.showNotification('Login failed', 'error');
        }
    }

    async verifyMasterPassword(password) {
        // Implement master password verification logic here
        // This should connect to your backend service
        return true; // Temporary for testing
    }

    handleLogout() {
        this.isLoggedIn = false;
        document.getElementById('master-password').value = '';
        document.getElementById('login-section').classList.remove('hidden');
        document.getElementById('main-section').classList.add('hidden');
    }

    async loadPasswords() {
        try {
            const passwords = await this.getStoredPasswords();
            const passwordsList = document.getElementById('passwords-list');
            passwordsList.innerHTML = '';

            passwords.forEach(pwd => {
                const item = document.createElement('div');
                item.className = 'password-item';
                item.innerHTML = `
                    <div>${pwd.website}</div>
                    <div>${pwd.username}</div>
                `;
                item.addEventListener('click', () => this.showPasswordDetails(pwd));
                passwordsList.appendChild(item);
            });
        } catch (error) {
            this.showNotification('Failed to load passwords', 'error');
        }
    }

    async getStoredPasswords() {
        // Implement password fetching logic here
        // This should connect to your backend service
        return [
            { website: 'example.com', username: 'user@example.com', password: '********' },
            // Add more dummy data for testing
        ];
    }

    generatePassword(length = 16) {
        const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+';
        let password = '';
        for (let i = 0; i < length; i++) {
            password += charset.charAt(Math.floor(Math.random() * charset.length));
        }
        
        // Copy to clipboard
        navigator.clipboard.writeText(password).then(() => {
            this.showNotification('Password copied to clipboard', 'success');
        });

        return password;
    }

    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        const items = document.querySelectorAll('.password-item');
        
        items.forEach(item => {
            const text = item.textContent.toLowerCase();
            item.style.display = text.includes(searchTerm) ? 'block' : 'none';
        });
    }

    showAddPasswordForm() {
        // Implement add password form logic
        // This could be a modal or a new view
    }

    showPasswordDetails(passwordData) {
        // Implement password details view
        // This could be a modal or a new view
    }

    async syncPasswords() {
        try {
            // Implement sync logic here
            this.showNotification('Sync completed', 'success');
            await this.loadPasswords();
        } catch (error) {
            this.showNotification('Sync failed', 'error');
        }
    }

    showSettings() {
        // Implement settings view
        // This could be a modal or a new view
    }

    showNotification(message, type = 'info') {
        // Implement notification logic
        console.log(`${type}: ${message}`);
    }
}

// Initialize the password manager when the popup loads
document.addEventListener('DOMContentLoaded', () => {
    window.passwordManager = new PasswordManager();
}); 