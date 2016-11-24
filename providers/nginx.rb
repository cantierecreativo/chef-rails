action :create do
  template upstream_path do
    source "nginx/nginx_upstream.erb"
    owner new_resource.user
    group new_resource.user
    mode 0644
    cookbook "rails"
    variables(upstream: upstream_name, path: new_resource.path)
  end

  service "nginx" do
    supports    [:start, :stop, :status, :restart]
    action      :nothing
  end

  new_resource.domains.each do |main_domain, aliases|
    if new_resource.http_passwd && new_resource.http_passwd != ""
      http_login_file = http_auth_filepath(main_domain)
      file http_login_file do
        owner new_resource.user
        group new_resource.user
        mode 0644
        content new_resource.http_passwd
      end
    else
      http_login_file = nil
    end

    certbot_self_signed_certificate "#{main_domain}" do
      domain main_domain
    end

    use_https = [:only_https, :both, :http_to_https].include? new_resource.protocol_policy

    if new_resource.protocol_policy == :http_to_https
      template_source = "nginx/nginx_http_to_https.erb"
    elsif [:only_http, :both].include? new_resource.protocol_policy
      template_source = "nginx_http.erb"
    else
      template_source = "http_404.erb"
    end

    template http_path(main_domain) do
      source template_source
      owner new_resource.user
      group new_resource.user
      mode 0644
      variables(
        domain: main_domain,
        upstream: upstream_name,
        path: new_resource.path,
        http_login_file: http_login_file
      )
      cookbook "rails"
      notifies :reload, 'service[nginx]', :immediately
    end


    if use_https
      template https_path(main_domain) do
        source "nginx/nginx_https.erb"
        owner new_resource.user
        group new_resource.user
        mode 0644
        variables(
          upstream: upstream_name,
          path: new_resource.path,
          domain: main_domain,
          cert_path: certbot_current_cert_path_for(main_domain),
          cert_key_path: certbot_current_key_path_for(main_domain),
          http_login_file: http_login_file
        )
        cookbook "rails"
        notifies :reload, 'service[nginx]', :immediately
      end
    end

    certbot_certificate "#{main_domain}_certbot" do
      domain main_domain
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

    if aliases.any?
      aliases.each do |alias_domain|
        certbot_self_signed_certificate "#{alias_domain}" do
          domain alias_domain
        end
      end

      template aliases_path(main_domain) do
        source "nginx/nginx_aliases.erb"
        owner new_resource.user
        group new_resource.user
        mode 0644
        variables(
          domain: main_domain,
          use_https: use_https,
          aliases: aliases.map { |alias_domain|
            {
              domain: alias_domain,
              cert_path: certbot_current_cert_path_for(alias_domain),
              cert_key_path: certbot_current_key_path_for(alias_domain)
            }
          }
        )
      end
    end
  end
end

def http_auth_filepath(domain)
  "/etc/nginx/#{domain}.passwd"
end

def aliases_path(domain)
  "/etc/nginx/sites-enabled/003-aliases-#{domain}.conf"
end

def https_path(domain)
  "/etc/nginx/sites-enabled/002-https-#{domain}.conf"
end

def http_path(domain)
  "/etc/nginx/sites-enabled/001-http-#{domain}.conf"
end

def upstream_path
  "/etc/nginx/sites-enabled/000-upstream-#{new_resource.name}.conf"
end

def upstream_name
  "rails_upstream_#{new_resource.name}"
end
