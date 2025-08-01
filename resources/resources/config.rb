# Cookbook:: mem2incident
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'redborder-mem2incident'
attribute :cdomain, kind_of: String, default: 'redborder.cluster'

# redborder-mem2incident config.yml
attribute :redis_hosts, kind_of: Array, default: []
attribute :redis_port, kind_of: Integer, default: 26379
attribute :redis_db, kind_of: Integer, default: 0
attribute :redis_secrets, kind_of: Hash, default: {}
attribute :api_endpoint, kind_of: String, default: 'https://webui.service/api/v1/incidents'
attribute :insecure_skip_verify, kind_of: [TrueClass, FalseClass], default: true
attribute :loop_interval, kind_of: Integer, default: 60
attribute :auth_token, kind_of: String, default: 'your_auth_token_here'
