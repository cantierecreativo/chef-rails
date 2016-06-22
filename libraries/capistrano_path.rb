def rails_capistrano_current_path(app, environment)
  ::File.join(
    rails_capistrano_root_path(app, environment),
    "current"
  )
end

def rails_capistrano_root_path(app, environment)
  ::File.join(
    node["rails"]["apps_root"],
    app,
    environment
  )
end
