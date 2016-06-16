action :create do
  package "letsencrypt" do
    action :install
  end

  directory well_known_dir do
    owner "root"
    group "root"
    mode 755
    recursive true
  end

  template "/etc/nginx/sites-enabled/letsencrypt-#{new_resource.domain}.conf" do
    source "nginx_letsencrypt.erb"
    owner "root"
    group "root"
    mode 0644
    variables(domain: new_resource.domain, webroot_dir: webroot_dir)
    notifies :restart, "service[nginx]", :immediately
  end

  service "nginx" do
    action :nothing
  end

  base_command = "letsencrypt certonly --keep-until-expiring --non-interactive --domain #{new_resource.domain} --webroot -w #{webroot_dir}"

  execute "letsencrypt-certonly" do
    command "#{base_command} --email info@cantierecreativo.net --agree-tos"
  end
end

def webroot_dir
  "/var/www/letsencrypt/#{new_resource.domain}"
end

def well_known_dir
  "#{webroot_dir}/.well-known"
end
