actions :create
default_action :create

attribute :domain, kind_of: String, required: true
attribute :user, kind_of: String, required: true
attribute :name, kind_of: String
attribute :path, kind_of: String
attribute :aliases, kind_of: String, default: []
attribute :cert_path, kind_of: String
attribute :cert_key_path, kind_of: String
attribute :protocol_policy, kind_of: Symbol, default: :only_http, equal_to: [:only_http, :only_https, :http_to_https, :both]
