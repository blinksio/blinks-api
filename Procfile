web: bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: bundle exec sidekiq -c $SIDEKIQ_WORKERS
release: rails db:migrate
