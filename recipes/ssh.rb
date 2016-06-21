template "/etc/ssh/sshd_config" do
  source "ssh/sshd_config.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/etc/ssh/banner" do
  source "ssh/banner_tiny"
end

execute "service ssh reload"
