# 1: Use ruby 2.4.3 as base:
FROM ruby:2.6.3-alpine3.9 AS runtime

#RUN adduser -S $USER 
RUN addgroup -g 1000 -S username && \
    adduser -u 1000 -S username -G username

# 2: We'll set the application path as the working directory
RUN mkdir /sample_app
WORKDIR /sample_app


# 6: Install the development & runtime packages:
RUN set -ex && apk add --no-cache \
  build-base \
  ca-certificates \
  less \
  libpq \
  openssl \
  postgresql-dev \
  tzdata \
  libxslt-dev libxml2-dev imagemagick libxml2-dev curl-dev

# 7: Install node & testing packages - I separated these apart to share as many layers as possible
# with inventory services' container image:
RUN set -ex && apk add --no-cache \
  chromium \
  chromium-chromedriver \
  nodejs

RUN apk add --update bash && rm -rf /var/cache/apk/*

# 8: Copy the project's Gemfile + lock:
ADD Gemfile /sample_app/Gemfile
ADD Gemfile.lock /sample_app/Gemfile.lock

# 9: Install the current project gems - they can be safely changed later during
# development via `bundle install` or `bundle update`:
RUN set -ex && bundle install --jobs=4 --retry=3

ADD . /sample_app
