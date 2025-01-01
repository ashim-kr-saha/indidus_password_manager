// Handle installation and update events
chrome.runtime.onInstalled.addListener((details) => {
    if (details.reason === 'install') {
        // First time installation
        chrome.storage.local.set({
            isSetup: false,
            settings: {
                autoFill: true,
                autoSave: true,
                lockTimeout: 5, // minutes
                notificationsEnabled: true
            }
        });
    }
});

// Listen for messages from content scripts and popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    switch (request.action) {
        case 'getCredentials':
            handleGetCredentials(request, sender, sendResponse);
            return true;
        case 'saveCredentials':
            handleSaveCredentials(request, sender, sendResponse);
            return true;
        case 'generatePassword':
            handleGeneratePassword(request, sender, sendResponse);
            return true;
        case 'checkLoginForm':
            handleCheckLoginForm(request, sender, sendResponse);
            return true;
    }
});

// Auto-fill credentials when a page loads
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.status === 'complete') {
        chrome.storage.local.get(['settings'], (result) => {
            if (result.settings?.autoFill) {
                chrome.tabs.sendMessage(tabId, { action: 'checkForLoginForm' });
            }
        });
    }
});

// Handle credential retrieval
async function handleGetCredentials(request, sender, sendResponse) {
    try {
        const { url } = request;
        // Here you would typically fetch credentials from your secure storage
        // and communicate with your main application
        const credentials = await fetchCredentialsForUrl(url);
        sendResponse({ success: true, credentials });
    } catch (error) {
        sendResponse({ success: false, error: error.message });
    }
}

// Handle credential saving
async function handleSaveCredentials(request, sender, sendResponse) {
    try {
        const { credentials } = request;
        // Here you would typically save credentials to your secure storage
        // and sync with your main application
        await saveCredentialsToStorage(credentials);
        sendResponse({ success: true });
    } catch (error) {
        sendResponse({ success: false, error: error.message });
    }
}

// Handle password generation
function handleGeneratePassword(request, sender, sendResponse) {
    const { length = 16, includeNumbers = true, includeSymbols = true } = request;
    const password = generateSecurePassword(length, includeNumbers, includeSymbols);
    sendResponse({ success: true, password });
}

// Handle login form detection
function handleCheckLoginForm(request, sender, sendResponse) {
    const { url } = request;
    chrome.storage.local.get(['credentials'], (result) => {
        const matchingCredentials = findMatchingCredentials(url, result.credentials || []);
        sendResponse({ success: true, hasCredentials: matchingCredentials.length > 0 });
    });
}

// Utility functions
function generateSecurePassword(length, includeNumbers, includeSymbols) {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#$%^&*()_+-=[]{}|;:,.<>?';

    let chars = lowercase + uppercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    let password = '';
    for (let i = 0; i < length; i++) {
        password += chars.charAt(Math.floor(Math.random() * chars.length));
    }

    return password;
}

async function fetchCredentialsForUrl(url) {
    // Implement credential fetching logic here
    // This should communicate with your main application
    return [];
}

async function saveCredentialsToStorage(credentials) {
    // Implement credential saving logic here
    // This should communicate with your main application
    return true;
}

function findMatchingCredentials(url, credentials) {
    // Implement credential matching logic here
    return credentials.filter(cred => {
        try {
            const credentialHost = new URL(cred.url).host;
            const currentHost = new URL(url).host;
            return credentialHost === currentHost;
        } catch {
            return false;
        }
    });
}

// Setup context menu
chrome.contextMenus.create({
    id: 'indidusPasswordManager',
    title: 'Indidus Password Manager',
    contexts: ['page', 'editable']
});

chrome.contextMenus.create({
    id: 'generatePassword',
    parentId: 'indidusPasswordManager',
    title: 'Generate Password',
    contexts: ['editable']
});

chrome.contextMenus.create({
    id: 'fillCredentials',
    parentId: 'indidusPasswordManager',
    title: 'Fill Credentials',
    contexts: ['editable']
});

// Handle context menu clicks
chrome.contextMenus.onClicked.addListener((info, tab) => {
    switch (info.menuItemId) {
        case 'generatePassword':
            chrome.tabs.sendMessage(tab.id, {
                action: 'generatePassword',
                targetElementId: info.targetElementId
            });
            break;
        case 'fillCredentials':
            chrome.tabs.sendMessage(tab.id, {
                action: 'fillCredentials',
                targetElementId: info.targetElementId
            });
            break;
    }
}); 