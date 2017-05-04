FROM debian:stretch

# Set the working directory to /app
WORKDIR /analizo

# Copy the current directory contents into the container at /app
ADD . /analizo

# Install any needed packages specified in requirements.txt
RUN apt-get -y update && apt-get -y install sudo apt-utils && apt-get -y clean
RUN ./development-setup.sh

# Run tests
CMD ["rake"]
