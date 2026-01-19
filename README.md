# LuckyWaveHeist

A Roblox game project built with Rojo for live synchronization between VS Code and Roblox Studio.

## Project Structure

```
LuckyWaveHeist/
├── src/
│   ├── server/      # Server-side scripts (*.server.lua)
│   ├── shared/      # Shared modules (*.lua)
│   └── client/      # Client-side scripts (*.client.lua)
├── default.project.json
└── README.md
```

## Getting Started

### Prerequisites
- Rojo installed (`npm install -g rojo`)
- Roblox Studio installed
- VS Code with Rojo extension

### Setup

1. Start the Rojo server:
```bash
rojo serve
```

2. Open Roblox Studio
3. In Roblox Studio, use the Rojo plugin to connect to the running server
4. Begin developing!

## Development

- **Server Scripts**: Place files in `src/server/` (e.g., `main.server.lua`)
- **Client Scripts**: Place files in `src/client/` (e.g., `main.client.lua`)
- **Shared Modules**: Place files in `src/shared/` (e.g., `utilities.lua`)

Rojo will automatically sync your changes to Roblox Studio.
