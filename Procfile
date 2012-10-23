mongo: mongod --config /usr/local/etc/mongod.conf
app: bundle exec rails s Puma
cache: memcached -l localhost
redis: redis-server /usr/local/etc/redis.conf
worker: bundle exec sidekiq -C config/sidekiq.yml