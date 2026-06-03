# webobs-docker
🐳 Docker containerization of [WebObs](https://github.com/IPGP/webobs) — an integrated web-based system for seismic and geophysical data monitoring and network management.

Provides a ready-to-use Docker image and `docker-compose` setup to deploy WebObs without complex manual installation. 
Ideal for observatories, research institutions, and geoscientists who want a portable, reproducible WebObs environment.

> **Work in progress** — This project is still under active development. Some features may not work as expected or may be incomplete. Contributions and bug reports are welcome!


**Features:**
- Pre-configured Docker image based on the official WebObs distribution
- docker-compose support for easy multi-service orchestration
- Persistent volumes for data, configuration, and logs
- Compatible with Linux/macOS/Windows (via Docker Desktop)

**Quick start:**
```bash
git clone https://github.com/IPGP/webobs-docker.git
cd webobs-docker
docker compose up -d
```
