actions :create
default_action :create

attribute :name, kind_of: String, required: true
attribute :admin_email, kind_of: String, required: true
attribute :environment, kind_of: String, default: "production"
attribute :user, kind_of: String
attribute :domains, kind_of: Hash, default: {}
attribute :test_env, kind_of: [TrueClass, FalseClass], default: false
attribute :directories, kind_of: Array, default: []
attribute :protocol_policy, kind_of: Symbol, equal_to: [:http_to_https, :only_https, :only_http, :both, :https_to_http], default: :http_to_https
attribute :postgresql_extensions, kind_of: Array, default: []
attribute :postgresql_superuser, kind_of: [TrueClass, FalseClass], default: false
attribute :http_login, kind_of: [TrueClass, FalseClass], default: false
