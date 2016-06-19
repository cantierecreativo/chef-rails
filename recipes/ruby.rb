if rbenv_ruby node["rails"]["global_ruby"]
  rbenv_ruby node["rails"]["global_ruby"]
  rbenv_gem "bundler" do
    rbenv_version node["rails"]["global_ruby"]
  end

  rbenv_global node["rails"]["global_ruby"]
end
