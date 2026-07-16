// Override the upstream gateHost (which defaults to example.com).
// The same-origin reverse proxy routes /api/v1/ to gate, so the
// relative path is all that's needed.
window.spinnakerSettings = window.spinnakerSettings || {};
window.spinnakerSettings.gateUrl = '/api/v1';
