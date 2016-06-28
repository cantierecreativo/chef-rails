name             'rails'
maintainer       'David Librera - Cantiere Creativo'
maintainer_email 'd.librera@cantierecreativo.net'
license          'All rights reserved'
description      'Installs/Configures rails'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.4'

depends "swap"
depends "certbot"
depends "nginx",    ">= 2.7.6"
depends "postgresql"
depends "capistrano-rails"
depends "ruby_rbenv"
depends "users"
depends "nodejs"
