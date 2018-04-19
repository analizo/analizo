FROM debian:stretch

# Creates analizo user and group inside container
RUN useradd -ms /bin/bash analizo

# Set the working directory to /home/analizo
WORKDIR /home/analizo

# Copy the current directory contents into the container at /home/analizo
ADD . /home/analizo

# Install any needed packages running development-setup.sh script
RUN apt-get -y update && apt-get -y install sudo apt-utils && apt-get -y clean
RUN ./development-setup.sh

# Disable password input to run sudo commands
RUN sed -i 's/%sudo\tALL=(ALL:ALL) ALL/%analizo\tALL=(ALL) NOPASSWD:ALL/' /etc/sudoers

# Define analizo user as owner of all files under /home/analizo
RUN chown -R analizo:analizo /home/analizo

# Switch from root user to analizo user
USER analizo:analizo

# Add analizo bin to $PATH
ENV PATH $PATH:/home/analizo/bin

# By default show the analizo version
CMD ./bin/analizo --version
