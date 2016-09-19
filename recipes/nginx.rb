package "nginx-core"

cookbook_file '/etc/nginx/sites-enabled/default' do
  source 'nginx_default.conf'
  owner "root"
  group "root"
  mode '0644'
  action :create
end
