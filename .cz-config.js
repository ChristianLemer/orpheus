//
// Extend the global config
//
const globalConfig = `${require('node:os').homedir()}/.config/cz-config.js`;
const config = require(globalConfig);

// Override with project-specific scopes
config.scopes = [
    'dz',
    'epomaker',
    'epomaker-th40-black',
    'epomaker-th40-purple',
    'keychron-q0',
    'keychron-q4',
    'keychron-q9',
    'keychron-q9-plus',
    'README/LICENSE',
    'git'
];

// You can also add project-specific types or other customizations
// config.types.push({ value: 'custom', name: '🔮 custom:   Project-specific type' });

module.exports = config

