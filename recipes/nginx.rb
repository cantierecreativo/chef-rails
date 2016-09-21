package "nginx-core"

nginx_enabled_path = "/etc/nginx/sites-enabled"
nginx_default_conf = File.join(nginx_enabled_path, "default")
nginx_default_404_conf = File.join(nginx_enabled_path, "default_404")

file nginx_default_conf do
  action :delete
end

cookbook_file nginx_default_404_conf do
  source "nginx_default.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
end
