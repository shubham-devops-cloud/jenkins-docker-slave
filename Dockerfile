FROM ubuntu:22.04
LABEL maintainer="Shubham Lad <shubham.devops.cloud@gmail.com>"

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git

# Install a basic SSH server
RUN apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd

# Install curl
RUN apt-get install -qy curl && \
# Install JDK 8 (latest stable edition at 2019-04-01)
    apt-get install -qy openjdk-18-jdk
    
# Install maven
RUN cd /opt && \
    wget https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz && \
    mkdir maven && tar -xvzf apache-maven-3.8.8-bin.tar.gz -C maven --strip-components 1 && \
    rm -rf apache-maven-3.8.8-bin.tar.gz

# Creating dir for settings.xml
RUN cd /var && \
    mkdir -p jenkins_home/repository

# Cleanup old packages
RUN apt-get -qy autoremove

# Add user jenkins to the image
RUN adduser --quiet jenkins && \
# Set password for the jenkins user (you may want to alter this).
    echo "jenkins:jenkins" | chpasswd && \
    mkdir /home/jenkins/.m2

#Docker install
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    chmod +x get-docker.sh
RUN /get-docker.sh
RUN usermod -aG docker jenkins

#aws-cli install
RUN apt-get install zip unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip
RUN ./aws/install

# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]    
