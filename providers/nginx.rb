action :create do
  template upstream_path do
    source "nginx_upstream.erb"
    owner new_resource.user
    group new_resource.user
    mode 0644
    variables(upstream: upstream_name, path: new_resource.path)
  end

  template http_path do
    source "nginx_http.erb"
    owner new_resource.user
    group new_resource.user
    mode 0644
    variables(
      upstream: upstream_name,
      path: new_resource.path,
      domain: new_resource.domain,
    )
  end

  template https_path do
    source "nginx_https.erb"
    owner new_resource.user
    group new_resource.user
    mode 0644
    variables(
      upstream: upstream_name,
      path: new_resource.path,
      domain: new_resource.domain,
      cert_path: new_resource.cert_path,
      cert_key_path: new_resource.cert_key_path
    )
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

  directory public_path do
    owner new_resource.user
    group new_resource.user
    mode 0755
    recursive true
  end

  file ::File.join(public_path, "index.html") do
    owner new_resource.user
    group new_resource.user
    mode 0644
    content "Ciao bello\n"
  end
end

def public_path
  ::File.join(new_resource.path, "public")
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
