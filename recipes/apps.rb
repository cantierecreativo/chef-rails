node["apps"].each do |app, environments|
  environments.each do |environment, config|
    rails_app app do
      environment environment
      root_dir node["apps_root"]
      user node["apps_user"]
      dbpassword "antanigogo"
      secret "AGreatSecret"
      domain config["domain"]
    end
  end
end
