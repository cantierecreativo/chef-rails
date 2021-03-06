actions :create
default_action :create

attribute :domains, kind_of: Hash, required: true
attribute :user, kind_of: String, required: true
attribute :name, kind_of: String
attribute :path, kind_of: String
attribute :test_ssl, kind_of: [TrueClass, FalseClass], default: false
attribute :admin_email, kind_of: String
attribute :protocol_policy,
          kind_of: Symbol,
          default: :only_http,
          equal_to: [
            :only_http, :only_https,
            :https_to_http, :http_to_https,
            :both
          ]
attribute :http_passwd, kind_of: String
