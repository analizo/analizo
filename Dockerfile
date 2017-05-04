FROM debian:stretch

RUN useradd -ms /bin/bash analizo

# Set the working directory to /app
WORKDIR /home/analizo

# Copy the current directory contents into the container at /home/analizo
ADD . /home/analizo

# Install any needed packages specified in requirements.txt
RUN apt-get -y update && apt-get -y install sudo apt-utils && apt-get -y clean
RUN ./development-setup.sh

RUN chown -R analizo:analizo /home/analizo

# Run tests
CMD sudo -u analizo rake
