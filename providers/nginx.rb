action :create do
  template upstream_path do
    source "nginx/nginx_upstream.erb"
    owner new_resource.user
    group new_resource.user
    mode 0644
    cookbook "rails"
    variables(upstream: upstream_name, path: new_resource.path)
  end

  certbot_self_signed_certificate "#{new_resource.domain}" do
    domain new_resource.domain
  end

  if new_resource.protocol_policy == :http_to_https
    template_source = "nginx/nginx_http_to_https.erb"
  elsif [:only_http, :both].include? new_resource.protocol_policy
    template_source = "nginx_http.erb"
  else
    template_source = "http_404.erb"
  end

  template http_path do
    source template_source
    owner new_resource.user
    group new_resource.user
    mode 0644
    variables(
      domain: new_resource.domain,
      upstream: upstream_name,
      path: new_resource.path
    )
    cookbook "rails"
    notifies :reload, 'service[nginx]', :immediately
  end


  if [:only_https, :both, :http_to_https].include? new_resource.protocol_policy
    template https_path do
      source "nginx/nginx_https.erb"
      owner new_resource.user
      group new_resource.user
      mode 0644
      variables(
        upstream: upstream_name,
        path: new_resource.path,
        domain: new_resource.domain,
        cert_path: certbot_current_cert_path_for(new_resource.domain),
        cert_key_path: certbot_current_key_path_for(new_resource.domain)
      )
      cookbook "rails"
      notifies :reload, 'service[nginx]', :immediately
    end
  end

  certbot_certificate "#{new_resource.domain}_certbot" do
    domain new_resource.domain
    email new_resource.admin_email
    test new_resource.test_ssl
    renew_policy new_resource.test_ssl ? :renew_by_default : :keep_until_expiring
    install_cron true
    action :create
  end

  case new_resource.protocol_policy
  when :only_http
    file https_path do
      action :delete
    end
  when :only_https
    file http_path do
      action :delete
    end
  end

  if new_resource.aliases.any?
    template aliases_path do
      source "nginx_aliases.erb"
      owner new_resource.user
      group new_resource.user
      mode 0644
      variables(aliases: new_resource.aliases, domain: new_resource.domain)
    end
  end
end

def aliases_path
  "/etc/nginx/sites-enabled/003-aliases-#{new_resource.domain}.conf"
end

def https_path
  "/etc/nginx/sites-enabled/002-https-#{new_resource.domain}.conf"
end

def http_path
  "/etc/nginx/sites-enabled/001-http-#{new_resource.domain}.conf"
end

def upstream_path
  "/etc/nginx/sites-enabled/000-upstream-#{new_resource.domain}.conf"
end

def upstream_name
  "rails_upstream_#{new_resource.name}"
end
