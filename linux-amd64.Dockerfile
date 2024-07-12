# This Dockerfile is used to create a Docker image for Plex Media Server.
# It pulls an upstream image, sets up the environment, installs dependencies,
# installs Plex Media Server, and prepares the configuration.

# Define arguments for the upstream image and its digest for AMD64 architecture
ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_AMD64

# Use the upstream image as the base image for this Dockerfile
FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}

# Expose port 32400 for Plex Media Server
EXPOSE 32400

# Create a volume mount point for the transcode directory
VOLUME ["/transcode"]

# Define arguments and environment variables
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} \
    WEBUI_PORTS="32400/tcp,32400/udp" \
    PLEX_CLAIM_TOKEN="" \
    PLEX_ADVERTISE_URL="" \
    PLEX_NO_AUTH_NETWORKS="" \
    PLEX_BETA_INSTALL="false" \
    PLEX_PURGE_CODECS="false"

# Set the frontend for Debian package manager to noninteractive
ARG DEBIAN_FRONTEND="noninteractive"

# Update the package list and install required dependencies
RUN set -e ;\
    apt-get update ;\
    apt-get install -y --no-install-recommends --no-install-suggests \
        xmlstarlet ;\
    # Clean up unused packages and clear temporary files
    apt-get autoremove -y ;\
    apt-get clean ;\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Install Plex Media Server
ARG VERSION
RUN set -e ;\
    debfile="/tmp/plex.deb" ;\
    mkdir "${APP_DIR}/bin" ;\
    # Download Plex Media Server package for the specified version
    curl -fsSL "https://downloads.plex.tv/plex-media-server-new/${VERSION}/debian/plexmediaserver_${VERSION}_amd64.deb" -o "${debfile}" ;\
    # Extract the downloaded package
    dpkg-deb -x "${debfile}" "${APP_DIR}/bin" ;\
    # Remove the downloaded package file
    rm "${debfile}" ;\
    # Save the version information
    echo "${VERSION}" > "${APP_DIR}/version" ;\
    # Create a configuration directory for Plex Media Server
    mkdir "${APP_DIR}/config" ;\
    # Link the configuration directory to the Plex Media Server configuration path
    ln -s "${CONFIG_DIR}" "${APP_DIR}/config/Plex Media Server"

# Copy the contents of the root directory from the build context to the image
COPY root/ /
