FROM ruby:3.1-slim

# Build deps for native gems (eventmachine for livereload, ffi, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /site

# Install gems first so this layer is cached unless the Gemfile changes.
COPY Gemfile* ./
RUN gem install bundler && bundle install

EXPOSE 14000 35729

# Default command (compose overrides it, but this keeps `docker run` working too)
CMD ["bundle", "exec", "jekyll", "serve", \
     "--host", "0.0.0.0", \
     "--port", "14000", \
     "--livereload", \
     "--force_polling", \
     "--incremental"]
