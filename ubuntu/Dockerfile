ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}

# Install sudo and create test user
RUN apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash testuser && \
    usermod -aG sudo testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch to test user
USER testuser
WORKDIR /app

# Run the setup script
CMD ["bash", "-c", "/app/setup.sh; sleep infinity"]
