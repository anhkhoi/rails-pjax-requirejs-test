mongo: mongod --config /usr/local/etc/mongod.conf
app: bundle exec puma --port=3000 --environment=development --pidfile=tmp/pids/puma.pid
cache: memcached -l localhost
redis: redis-server /usr/local/etc/redis.conf
worker: bundle exec sidekiq -C config/sidekiq.yml