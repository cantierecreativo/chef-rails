action :create do
  directory root_path do
    owner new_resource.user
    group new_resource.user
    mode 0755
    action :create
    recursive true
  end

  postgresql_user new_resource.name do
    superuser false
    createdb false
    login true
    replication false
    password new_resource.dbpassword
    action :create
  end

  postgresql_database app_name do
    owner new_resource.name
    action :create
  end

  capistrano_rails_application app_path do
    user new_resource.user
    group new_resource.user
    environment new_resource.environment
    extra_shared ["public", "log"]
    database app_name
    username new_resource.name
    password new_resource.dbpassword
    secret_key_base new_resource.secret
    adapter "postgresql"
    action :create
  end

  rails_nginx app_name do
    domain new_resource.domain
    test_ssl new_resource.test_env
    path shared_path
    user new_resource.user
    cert_path certbot_fullchain_path_for(new_resource.domain)
    cert_key_path certbot_privatekey_path_for(new_resource.domain)
    protocol_policy :http_to_https
    admin_email new_resource.admin_email
  end
end

def certificate_base_path
  certbot_certificate_dir new_resource.domain
end

def certificate_path
  ::File.join(certificate_base_path, "fullchain.pem")
end

def certificate_key_path
  ::File.join(certificate_base_path, "privkey.pem")
end

def shared_path
  ::File.join(app_path, "shared")
end

def app_name
  "#{new_resource.name}_#{new_resource.environment}"
end

def app_path
  ::File.join(root_path, new_resource.environment)
end

def root_path
  ::File.join(new_resource.root_dir, new_resource.name)
end
