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
      aliases: []
    )
  end
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
