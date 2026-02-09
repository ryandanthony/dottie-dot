FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies needed for the setup
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a user 'testuser' with sudo privileges (similar to a laptop setup)
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER testuser
WORKDIR /home/testuser

# Add ~/bin to PATH for the user
ENV PATH="/home/testuser/bin:${PATH}"

# Copy the entire repo to ~/.dottie
COPY --chown=testuser:testuser . /home/testuser/.dottie

# Make scripts executable
RUN chmod +x /home/testuser/.dottie/update-dottie.sh /home/testuser/.dottie/test-setup.sh

# Set the default command to run the test script
CMD ["/bin/bash", "/home/testuser/.dottie/test-setup.sh"]
