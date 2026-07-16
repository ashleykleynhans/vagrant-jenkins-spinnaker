// Override the default gateHost (example.com) to use the same-origin
// reverse proxy.  Settings-local.js loads after settings.js so we
// can fix gateHost after it was set incorrectly.
window.spinnakerSettings.gateUrl = '/api/v1';
