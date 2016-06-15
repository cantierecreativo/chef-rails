actions :create
default_action :create

attribute :name, kind_of: String, required: true
attribute :environment, kind_of: String
attribute :root_dir, kind_of: String
attribute :user, kind_of: String
attribute :dbpassword, kind_of: String
attribute :secret, kind_of: String
attribute :domain, kind_of: String
