actions :create
default_action :create

attribute :domain, kind_of: String, required: true
attribute :user, kind_of: String, required: true
attribute :name, kind_of: String
attribute :path, kind_of: String
