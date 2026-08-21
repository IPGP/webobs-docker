FROM debian:12-slim

LABEL org.opencontainers.image.authors="boissier@ipgp.fr"
LABEL version="1.2"
LABEL description="Docker image running WebObs on Debian 12."

## Environment variables

# Directories
ENV WORK_DIR=/opt
ENV INSTALL_DIR=/opt/webobs
# ENV DATA_DIR=/opt/rawdata

# Set system to non-interactive during build only
ARG DEBIAN_FRONTEND=noninteractive

# Simulate a chroot environment
ENV FAKE_CHROOT=1

# Ensures that the OpenGL graphics library will not try to direct access GPU in the container
ENV LIBGL_ALWAYS_INDIRECT=1

# Locale par défaut (générée plus bas)
ENV LANG=fr_FR.ISO-8859-1
ENV LANGUAGE=fr_FR:fr
ENV LC_ALL=fr_FR.ISO-8859-1

WORKDIR $WORK_DIR

## System upgrade and packages install
RUN apt-get update && apt-get dist-upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends \
        # Generic tools
        locales openssh-server openssl libssl-dev net-tools python3 python3-pip sudo wget \
        vim git pipx unzip less \
        # WebObs dependencies
        apache2 apache2-utils sqlite3 imagemagick pngquant qrencode jq mutt xvfb curl gawk \
        graphviz libdatetime-perl libdatetime-format-strptime-perl libdate-calc-perl \
        libcgi-session-perl libdbd-sqlite3-perl libgraphviz-perl libimage-info-perl gdal-bin \
        libtext-multimarkdown-perl libswitch-perl libintl-perl liblist-moreutils-perl \
        poppler-utils libjson-perl libjson-xs-perl libnet-ldap-perl libhtml-escape-perl \
        python-is-python3 libncurses5 wkhtmltopdf libsocket6-perl libdigest-perl-md5-perl \
        dvipng texlive-latex-extra texlive-fonts-recommended cm-super \
        python3-tk python3-venv python3-pip-whl build-essential \
    && apt-get autoremove -y --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Setup ssh access
RUN mkdir -p /var/run/sshd \
    # Generate SSH host keys
    && ssh-keygen -A \
    && sed -i -E 's/^#?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i -E 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i -E 's/^#?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config \
    && sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Expose SSH TCP port
EXPOSE 22
# Expose HTTP TCP port
EXPOSE 80
# Expose HTTPS TCP port
EXPOSE 443

## Directories
RUN mkdir -p $INSTALL_DIR

## Try to copy MCR download Matlab MCR to $INSTALL_DIR (will be installed during setup)
COPY MCR_R2011b* $INSTALL_DIR/
RUN if [ ! -f $INSTALL_DIR/MCR_R2011b_glnxa64_installer.zip ]; then \
        wget --no-check-certificate -O ${INSTALL_DIR}/MCR_R2011b_glnxa64_installer.zip http://www.ipgp.fr/~beaudu/webobs/MCR_Runtime/MCR_R2011b_glnxa64_installer.zip; \
      fi

## Set locales
RUN sed -i -e 's/^# \(en_US ISO-8859-1\)/\1/;s/^# \(fr_FR ISO-8859-1\)/\1/' /etc/locale.gen \
    && locale-gen fr_FR en_US

## Apache2 configuration
RUN a2dissite 000-default.conf \
    && a2enmod cgid

## Fix ImageMagick security policy
RUN sed -i'' -e's;\(<policy domain="coder" rights="none" pattern="PS" />\);<!-- \1 -->;' /etc/ImageMagick-6/policy.xml \
    && sed -i'' -e's;\(<policy domain="coder" rights="none" pattern="PS2" />\);<!-- \1 -->;' /etc/ImageMagick-6/policy.xml \
    && sed -i'' -e's;\(<policy domain="coder" rights="none" pattern="PS3" />\);<!-- \1 -->;' /etc/ImageMagick-6/policy.xml \
    && sed -i'' -e's;\(<policy domain="coder" rights="none" pattern="EPS" />\);<!-- \1 -->;' /etc/ImageMagick-6/policy.xml \
    && sed -i'' -e's;\(<policy domain="coder" rights="none" pattern="PDF" />\);<!-- \1 -->;' /etc/ImageMagick-6/policy.xml \
    && sed -i'' -e's;\(<policy domain="coder" rights="none" pattern="XPS" />\);<!-- \1 -->;' /etc/ImageMagick-6/policy.xml

# Try to copy ETOPO1 zip file from build context, if not found, download the latest release from GitHub
COPY etopo* /tmp/etopo.zip
RUN if [ ! -f /tmp/etopo.zip ]; then \
        curl https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/grid_registered/binary/etopo1_bed_g_i2.zip -o /tmp/etopo.zip; \
      fi

# Try to copy WebObs tarball from build context, if not found, download the latest release from GitHub
COPY WebObs-* $INSTALL_DIR/
COPY version $INSTALL_DIR/

RUN fichier=$(find "$INSTALL_DIR/" -maxdepth 1 -name "WebObs-*.tar.gz" -print -quit) \
    && if [ -n "$fichier" ]; then \
         fichier=$(basename "$fichier") \
         && WO_VERSION="${fichier#WebObs-}" \
         && WO_VERSION="${WO_VERSION%.tar.gz}"; \
       else \
         if [ -s "$INSTALL_DIR/version" ]; then \
           WO_ASKED=$(tr -d '[:space:]' < "$INSTALL_DIR/version"); \
         else \
           WO_ASKED="latest"; \
         fi \
         && if [ "$WO_ASKED" = "latest" ]; then \
              WO_LATEST=$(curl -s https://api.github.com/repos/IPGP/webobs/releases/latest | jq -r .tag_name) \
              && WO_VERSION=${WO_LATEST#v} \
              && wget -O "$INSTALL_DIR/WebObs-${WO_VERSION}.tar.gz" "https://github.com/IPGP/webobs/releases/download/${WO_LATEST}/WebObs-${WO_VERSION}.tar.gz"; \
            else \
              WO_VERSION="$WO_ASKED" \
              && wget -O "$INSTALL_DIR/WebObs-${WO_VERSION}.tar.gz" "https://github.com/IPGP/webobs/releases/download/v${WO_VERSION}/WebObs-${WO_VERSION}.tar.gz"; \
            fi; \
       fi \
    && rm -f "$INSTALL_DIR/version" \
    && tar xvfz "$INSTALL_DIR/WebObs-${WO_VERSION}.tar.gz" -C "$INSTALL_DIR" \
    && rm "$INSTALL_DIR/WebObs-${WO_VERSION}.tar.gz" \
    && cd "$INSTALL_DIR" \
    && "$INSTALL_DIR/WebObs-${WO_VERSION}/SETUP/setup" -a

    ## Install ETOPO1 worlwide topography and activate SRTM/ETOPO merge
RUN unzip -d /etc/webobs.d/../DATA/DEM/ETOPO /tmp/etopo.zip \
    && sed -i'' -e's;^ETOPO_NAME|.*;ETOPO_NAME|etopo1_bed_g_i2;' /etc/webobs.d/WEBOBS.rc \
    && sed -i'' -e's;^ETOPO_COPYRIGHT|.*;ETOPO_COPYRIGHT|DEM: ETOPO1 NGDC/NOOA;' /etc/webobs.d/WEBOBS.rc \
    && sed -i'' -e's;^ETOPO_SRTM_MERGE|.*;ETOPO_SRTM_MERGE|YES;' /etc/webobs.d/WEBOBS.rc \
    && rm /tmp/etopo.zip

## Copy entrypoint script and set permissions
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

## Healthcheck to verify that the SSH service is running
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD bash -c '</dev/tcp/localhost/22' || exit 1

USER root
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Start sshd in foreground - useful for "detached" mode
CMD /usr/sbin/sshd -D
