# webobs-docker
🐳 Docker containerization of [WebObs](https://github.com/IPGP/webobs) — an integrated web-based system for seismic and geophysical data monitoring and network management.

Provides a ready-to-use Docker image and `docker-compose` setup to deploy WebObs without complex manual installation. 
Ideal for observatories, research institutions, and geoscientists who want a portable, reproducible WebObs environment.

> **Work in progress** — This project is still under active development. Some features may not work as expected or may be incomplete. Contributions and bug reports are welcome!


## Features
- Pre-configured Docker image based on the official WebObs distribution
- docker-compose support for easy multi-service orchestration
- Persistent volumes for data, configuration, and logs
- Compatible with Linux/macOS/Windows (via Docker Desktop)

## Quick start
Install the [Docker Desktop](https://www.docker.com/products/docker-desktop).

From a terminal, clone the repository on your local disk:

```bash
git clone https://github.com/IPGP/webobs-docker.git
cd webobs-docker
```

### Create secrets
Sets manually the root and wo user passwords:
```bash
mkdir -p secrets
echo -n 'someStrongPassword' > secrets/root_password.txt
echo -n 'someOtherStrongPassword'   > secrets/wo_password.txt
chmod 600 secrets/*.txt
```

### Build the docker
```bash
docker compose up -d --build
```

### Change the web wo user password
By default, the http password is the same as login password defined in the secrets step above. To change the first:
```bash
docker exec -it webobs /usr/bin/htpasswd /opt/webobs/CONF/htpasswd wo
```

### Access the WebObs interface
Open the URL: [localhost:8080](http://localhost:8080) and login to access WebObs.

## Install a specific version of WebObs

You can install a specific version of WebObs by editing the `version` file located in the `webobs` folder of this repository and enter :

- `latest` : if you want to install the latest release (default)
- `MAJOR.MINOR.PATCH` : example : 2.8.3a

## Using local installation files (Matlab, WebObs, etopo1)

You can use local installation files to speed up the image build or to use specific versions.

This applies to:

- the [Matlab runtime (MCR)](https://fr.mathworks.com/products/compiler/matlab-runtime.html)
- the [WebObs archive](https://github.com/IPGP/webobs/releases)
- the [etopo1 archive](https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/grid_registered/binary/etopo1_bed_g_i2.zip)

The files should be placed in the `webobs` subfolder of this repository.

Example directory structure:

```bash
├── compose.yml
├── LICENSE
├── README.md
├── secrets
│   ├── root_password.txt
│   └── wo_password.txt
└── webobs
    ├── docker-entrypoint.sh
    ├── Dockerfile
    ├── etopo1.zip
    ├── MCR_R2011b_glnxa64_installer.zip
    ├── WebObs-2.8.3b.tar.gz
    └── version
```
