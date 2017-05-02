# Use an official Python runtime as a base image
FROM debian:stretch

# Set the working directory to /app
WORKDIR /analizo

# Copy the current directory contents into the container at /app
ADD . /analizo

# Install any needed packages specified in requirements.txt
RUN apt-get update && apt-get install sudo
RUN ./development-setup.sh

# Run tests
RUN rake

# Make port 80 available to the world outside this container
#EXPOSE 80

# Define environment variable
#ENV NAME World

# Run app.py when the container launches
#CMD ["python", "app.py"]
