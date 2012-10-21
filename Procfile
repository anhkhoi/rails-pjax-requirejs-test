mongo: mongod --config /usr/local/etc/mongod.conf
app: bundle exec rails s
cache: memcached -l localhost
redis: redis-server /usr/local/etc/redis.conf
worker: bundle exec sidekiq -C config/sidekiq.yml