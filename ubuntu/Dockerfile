FROM ubuntu:22.04

# Install sudo and create test user
RUN apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash ubuntu && \
    usermod -aG sudo ubuntu && \
    echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    apt-get clean

# Switch to test user
USER ubuntu
WORKDIR /home/ubuntu

# Run the setup script
CMD ["bash", "-c", "/app/ubuntu/setup.sh; sleep infinity"]
