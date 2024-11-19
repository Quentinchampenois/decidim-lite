FROM ruby:3.2.2-slim as builder

ENV RAILS_ENV=production \
    SECRET_KEY_BASE=dummy

WORKDIR /decidim

RUN apt-get update && \
    apt-get -y install libpq-dev curl git libicu-dev build-essential openssl && \
    curl https://deb.nodesource.com/setup_18.x | bash && \
    apt-get install -y nodejs  && \
    npm install --global yarn && \
    gem install bundler:2.5.22

COPY Gemfile* ./
RUN bundle install -j"$(nproc)"

COPY package* ./
COPY packages packages
RUN npm install

COPY . .

RUN bundle exec rails shakapacker:compile

RUN rm -rf node_modules tmp/cache vendor/bundle spec \
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete \
    && find /usr/local/bundle/gems/ -type d -name "spec" -prune -exec rm -rf {} \; \
    && rm -rf log/*.log

FROM ruby:3.2.2-slim as runner

ENV RAILS_ENV=production \
    SECRET_KEY_BASE=dummy \
    RAILS_LOG_TO_STDOUT=true

RUN apt update && \
    apt install -y postgresql-client imagemagick libproj-dev proj-bin libjemalloc2 && \
    gem install bundler:2.5.22

WORKDIR /decidim

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /decidim /decidim

ENV LD_PRELOAD="libjemalloc.so.2" \
    MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:5000,muzzy_decay_ms:5000,narenas:2"

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]