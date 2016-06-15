actions :create
default_action :create

attribute :name, kind_of: String, required: true
attribute :environments, kind_of: Array
attribute :root_dir, kind_of: String
attribute :user, kind_of: String
