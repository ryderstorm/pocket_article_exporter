# Start with the latest Ruby image
FROM ruby:latest

# Create a new user to run the app
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Switch to the app user
USER appuser

# Set the working directory to /app
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the image and run bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application code into the image
COPY --chown=appuser:appgroup . .

# Expose the port for the Sinatra web server
EXPOSE 8999

# Start the application
CMD "bin/start.sh"
