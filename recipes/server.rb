#
# Cookbook Name:: rails-machine
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "rails-machine::swap"
include_recipe "rails-machine::nginx"
include_recipe "rails-machine::postgresql"
