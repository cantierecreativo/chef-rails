node["apps"].each do |app, environments|
  rails_app app do
    environments environments.keys
    root_dir node["apps_root"]
    user node["apps_user"]
    dbpassword "antanigogo"
    secret "AGreatSecret"
  end
end
