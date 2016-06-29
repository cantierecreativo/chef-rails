node["rails"]["apps"].each do |app, environments|
  environments.each do |environment, config|
    rbenv_ruby config[:ruby_version]
    rbenv_gem "bundler" do
      rbenv_version config[:ruby_version]
    end

    rails_app app do
      environment environment
      user node["rails"]["apps_user"]
      domain config["domain"]
      aliases config["aliases"]
      admin_email config["admin_email"]
      test_env config["test_env"]
      directories config["directories"]
    end

    execute "enable_#{app}_#{environment}" do
      command "systemctl enable #{app}_#{environment}.service"
      action :nothing
    end

    execute "reload_systemd" do
      command "systemctl daemon-reload"
      notifies :run, "execute[enable_#{app}_#{environment}]"
      action :nothing
    end

    template "/lib/systemd/system/#{app}_#{environment}.service" do
      source "puma.service"
      owner "root"
      group "root"
      mode 0644
      variables(
        app_name: "#{app}_#{environment}",
        app_path: rails_capistrano_current_path(app, environment),
        app_user: node["rails"]["apps_user"],
        rails_env: environment,
        ruby_version: config[:ruby_version]
      )
      notifies :run, "execute[reload_systemd]", :immediately
    end
  end
end
