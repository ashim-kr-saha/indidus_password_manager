// Listen for messages from the background script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    switch (request.action) {
        case 'checkForLoginForm':
            handleCheckForLoginForm();
            break;
        case 'fillCredentials':
            handleFillCredentials(request);
            break;
        case 'generatePassword':
            handleGeneratePassword(request);
            break;
    }
});

// Detect login forms on the page
function handleCheckForLoginForm() {
    const forms = detectLoginForms();
    if (forms.length > 0) {
        chrome.runtime.sendMessage({
            action: 'checkLoginForm',
            url: window.location.href
        }, (response) => {
            if (response.hasCredentials) {
                showLoginPrompt();
            }
        });
    }
}

// Fill credentials into the form
async function handleFillCredentials(request) {
    try {
        const credentials = await getCredentialsForCurrentPage();
        if (credentials && credentials.length > 0) {
            const form = findLoginForm();
            if (form) {
                fillLoginForm(form, credentials[0]);
            }
        }
    } catch (error) {
        console.error('Error filling credentials:', error);
    }
}

// Handle password generation
function handleGeneratePassword(request) {
    const { targetElementId } = request;
    const targetElement = document.activeElement;
    
    if (targetElement && targetElement.tagName === 'INPUT' && 
        (targetElement.type === 'password' || targetElement.type === 'text')) {
        chrome.runtime.sendMessage({
            action: 'generatePassword'
        }, (response) => {
            if (response.success) {
                targetElement.value = response.password;
                // Trigger input event to notify the page of the change
                targetElement.dispatchEvent(new Event('input', { bubbles: true }));
            }
        });
    }
}

// Utility functions for form detection and manipulation
function detectLoginForms() {
    const forms = Array.from(document.forms);
    return forms.filter(form => {
        const inputs = Array.from(form.elements);
        const hasPassword = inputs.some(input => input.type === 'password');
        const hasUsername = inputs.some(input => 
            input.type === 'text' || 
            input.type === 'email' || 
            input.name.toLowerCase().includes('user') || 
            input.id.toLowerCase().includes('user') ||
            input.name.toLowerCase().includes('email') || 
            input.id.toLowerCase().includes('email')
        );
        return hasPassword && hasUsername;
    });
}

function findLoginForm() {
    const forms = detectLoginForms();
    return forms.length > 0 ? forms[0] : null;
}

function fillLoginForm(form, credentials) {
    const inputs = Array.from(form.elements);
    
    // Find username field
    const usernameField = inputs.find(input => 
        (input.type === 'text' || input.type === 'email') &&
        (input.name.toLowerCase().includes('user') ||
         input.id.toLowerCase().includes('user') ||
         input.name.toLowerCase().includes('email') ||
         input.id.toLowerCase().includes('email'))
    );

    // Find password field
    const passwordField = inputs.find(input => 
        input.type === 'password'
    );

    // Fill in the credentials
    if (usernameField && credentials.username) {
        usernameField.value = credentials.username;
        usernameField.dispatchEvent(new Event('input', { bubbles: true }));
    }

    if (passwordField && credentials.password) {
        passwordField.value = credentials.password;
        passwordField.dispatchEvent(new Event('input', { bubbles: true }));
    }
}

async function getCredentialsForCurrentPage() {
    return new Promise((resolve, reject) => {
        chrome.runtime.sendMessage({
            action: 'getCredentials',
            url: window.location.href
        }, (response) => {
            if (response.success) {
                resolve(response.credentials);
            } else {
                reject(new Error(response.error));
            }
        });
    });
}

// UI elements for interaction
function showLoginPrompt() {
    const promptDiv = document.createElement('div');
    promptDiv.className = 'indidus-prompt';
    promptDiv.innerHTML = `
        <div class="indidus-prompt-content">
            <p>Saved credentials found for this site</p>
            <button id="indidus-autofill">Auto-fill credentials</button>
            <button id="indidus-dismiss">Dismiss</button>
        </div>
    `;

    // Add styles
    const styles = document.createElement('style');
    styles.textContent = `
        .indidus-prompt {
            position: fixed;
            top: 20px;
            right: 20px;
            background: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            z-index: 999999;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        .indidus-prompt-content {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .indidus-prompt button {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            background: #4CAF50;
            color: white;
        }
        .indidus-prompt button#indidus-dismiss {
            background: #666;
        }
    `;

    document.head.appendChild(styles);
    document.body.appendChild(promptDiv);

    // Add event listeners
    document.getElementById('indidus-autofill').addEventListener('click', () => {
        handleFillCredentials({});
        promptDiv.remove();
    });

    document.getElementById('indidus-dismiss').addEventListener('click', () => {
        promptDiv.remove();
    });

    // Auto-remove after 10 seconds
    setTimeout(() => {
        if (document.body.contains(promptDiv)) {
            promptDiv.remove();
        }
    }, 10000);
}

// Monitor form submissions
document.addEventListener('submit', (event) => {
    const form = event.target;
    if (isLoginForm(form)) {
        const credentials = extractCredentials(form);
        if (credentials) {
            chrome.runtime.sendMessage({
                action: 'saveCredentials',
                credentials: {
                    ...credentials,
                    url: window.location.href
                }
            });
        }
    }
});

function isLoginForm(form) {
    return Array.from(form.elements).some(input => input.type === 'password');
}

function extractCredentials(form) {
    const inputs = Array.from(form.elements);
    
    const passwordField = inputs.find(input => input.type === 'password');
    const usernameField = inputs.find(input => 
        (input.type === 'text' || input.type === 'email') &&
        (input.name.toLowerCase().includes('user') ||
         input.id.toLowerCase().includes('user') ||
         input.name.toLowerCase().includes('email') ||
         input.id.toLowerCase().includes('email'))
    );

    if (passwordField && usernameField) {
        return {
            username: usernameField.value,
            password: passwordField.value
        };
    }

    return null;
} 