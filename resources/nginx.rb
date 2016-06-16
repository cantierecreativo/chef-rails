actions :create
default_action :create

attribute :domain, kind_of: String, required: true
attribute :user, kind_of: String, required: true
attribute :name, kind_of: String
attribute :path, kind_of: String
attribute :aliases, kind_of: String, default: []
attribute :cert_path, kind_of: String
attribute :cert_key_path, kind_of: String
attribute :ssl_policy, kind_of: [:only_http, :only_https, :both, :redirect_http_to_https], default: :http_only
