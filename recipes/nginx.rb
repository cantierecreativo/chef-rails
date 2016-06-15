include_recipe "nginx::default"

cookbook_file '/etc/nginx/sites-available/default' do
  source 'nginx_default.conf'
  owner "root"
  group "root"
  mode '0644'
  action :create
end
