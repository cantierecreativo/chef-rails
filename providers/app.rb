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

  new_resource.environments.each do |environment|
    postgresql_database app_name(environment) do
      owner new_resource.name
      action :create
    end

    capistrano_rails_application app_path(environment) do
      user new_resource.user
      group new_resource.user
      environment environment
      extra_shared ["public", "log"]
      database app_name(environment)
      username new_resource.name
      password new_resource.dbpassword
      secret_key_base new_resource.secret
      adapter "postgresql"
      action :create
    end
  end
end

def app_name(env)
  "#{new_resource.name}_#{env}"
end

def app_path(env)
  ::File.join(root_path, env)
end

def root_path
  ::File.join(new_resource.root_dir, new_resource.name)
end
