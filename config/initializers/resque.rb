rails_env = ENV['RAILS_ENV'] || 'development'

#config = YAML.load_file(rails_root + '/config/redis.yml')
#Resque.redis = config[rails_env]
config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)['resque'].to_h
Resque.redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true)

