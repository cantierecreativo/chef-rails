action :create do
  directory app_path do
    owner new_resource.user
    group new_resource.user
    mode 0755
    action :create
    recursive true
  end


  postgresql_user new_resource.name do
    superuser new_resource.postgresql_superuser
    createdb false
    login true
    password secret_config["dbpassword"]
    replication false
    action :update
  end

  postgresql_database app_name do
    owner new_resource.name
    action :create
  end

  new_resource.postgresql_extensions.each do |ext|
    postgresql_extension ext do
      database app_name
    end
  end

  capistrano_rails_application app_path do
    user new_resource.user
    group new_resource.user
    environment new_resource.environment
    extra_shared ["public", "log", "config"] + new_resource.directories
    database app_name
    username new_resource.name
    password secret_config["dbpassword"]
    secret_key_base secret_config_env["secret_key_base"]
    other_secrets secret_config_env["other_secrets"]
    adapter "postgresql"
    action :create
  end

  rails_nginx app_name do
    domains new_resource.domains
    test_ssl new_resource.test_env
    path current_path
    user new_resource.user
    protocol_policy new_resource.protocol_policy
    admin_email new_resource.admin_email
    http_passwd new_resource.http_login ? secret_config["http_passwd"] : false
  end
end

def secret_config
  @secret_config ||= Chef::EncryptedDataBagItem.load('apps', new_resource.name).to_hash["config"]
end

def secret_config_env
  secret_config[new_resource.environment]
end

def current_path
  rails_capistrano_current_path(new_resource.name, new_resource.environment)
end

def app_name
  "#{new_resource.name}_#{new_resource.environment}"
end

def app_path
  rails_capistrano_root_path(new_resource.name, new_resource.environment)
end
