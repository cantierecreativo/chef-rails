node["rails"]["apps"].each do |app, environments|
  environments.each do |environment, config|
    rbenv_ruby config[:ruby_version]
    rbenv_gem "bundler" do
      rbenv_version config[:ruby_version]
    end

    rails_app app do
      environment environment
      root_dir node["rails"]["apps_root"]
      user node["rails"]["apps_user"]
      dbpassword "antanigogo"
      secret "AGreatSecret"
      domain config["domain"]
      admin_email config["admin_email"]
    end
  end
end
