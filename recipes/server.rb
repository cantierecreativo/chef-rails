["build-essential", "libreadline-dev"].each do |pkg|
  package "build-essential" do
    action :install
  end
end

include_recipe "rails::swap"

include_recipe "certbot::default"
include_recipe "rails::nginx"

include_recipe "rails::postgresql"

include_recipe "ruby_rbenv::system_install"
include_recipe "ruby_build::default"
include_recipe "rails::ruby"
