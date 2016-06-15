action :create do
  directory root_path do
    owner new_resource.user
    group new_resource.user
    mode 0755
    action :create
    recursive true
  end
end

def root_path
  ::File.join(new_resource.root_dir, new_resource.name)
end
