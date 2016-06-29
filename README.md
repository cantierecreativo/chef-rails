# rails Cookbook

This cookbook is designed to build a server with full configuration for Ruby on Rails applications deployed through [Capistrano](http://capistranorb.com/)


The default recipe will install and configure:

* Configure the sshd with a custom port
* Install a swap area
* Nginx, with server configuration for many domains. HTTP requests will redirected on HTTPs
* Letsencrypt, providing a valid ssl certificate for each domain
* Postgresql, creating an user for each application and e database for each environment
* Rbenv, with a specific ruby version for each app environment
* Nodejs
* Configure machine users with custom files, sudo access (using cookbook [Users](https://bitbucket.org/joeyates/users-cookbook.git))
* Capistrano directory structure with basic shared folders (log, config) and some secret
* Supervisord to ensure the puma server is running


## Requirements

### Platforms

- Ubuntu 16.04

### Chef

- Chef 12.0 or later

### Cookbooks
Add this to your **Cheffile** in order to install correct versions of cookbooks

```
cookbook "postgresql",       git: "https://github.com/hbda/chef-postgresql", ref: "rmoriz/pg9.5"
cookbook "capistrano-rails", git: "https://github.com/joeyates/chef-capistrano-rails"
cookbook "nginx",            "2.7.6"
cookbook "users",            git: 'https://bitbucket.org/joeyates/users-cookbook.git'
cookbook "rails"
```

## Attributes

### rails::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['rails']['machine_nane']</tt></td>
    <td>String</td>
    <td>Machine name in ssh banner during login</td>
    <td><tt>Rails machine</tt></td>
  </tr>
  <tr>
    <td><tt>['rails']['sshd']['port']</tt></td>
    <td>Integer</td>
    <td>Ssh port</td>
    <td><tt>22</tt></td>
  </tr>
  <tr>
    <td><tt>['rails']['swap']['size']</tt></td>
    <td>Integer</td>
    <td><The swapfile filesize/td>
    <td><tt>1024</tt></td>
  </tr>
  <tr>
    <td><tt>['rails']['swap']['filepath']</tt></td>
    <td>String</td>
    <td>The path of the swapfile</td>
    <td><tt>/mnt/swapfile</tt></td>
  </tr>
  <tr>
    <td><tt>['rails']['apps_root']</tt></td>
    <td>String</td>
    <td>The directory where applications root will be installed</td>
    <td><tt>/srv</tt></td>
  </tr>
  <tr>
    <td><tt>['rails']['apps_user']</tt></td>
    <td>String</td>
    <td>The application owner</td>
    <td><tt>"root"</tt></td>
  </tr>
  <tr>
    <td><tt>['rails']['extra_packages']</tt></td>
    <td>Array</td>
    <td>Additional packages to install into the machine</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['rails']['apps']</tt></td>
    <td>Hash</td>
    <td>An hash with configuration for the machine (with this you can create all stuffs for many application just running default recipe)</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

Before running the cookbook, if you want to generate an ssl valid certificate with letsencrypt, ensure that your machine is reachable. If you can't do this for now, set

`"test_env": true`

into "apps" settings in order to use a self signed ssl certificate
=======

`"test_env": true`

into "apps" settings in order to use a self signed ssl certificate.

Then, you need to create an encrypted data bag with application properties.

`bundle exec knife solo data bag create apps rails_app`

to create the empty.

Paste the following content into the editor setting variables with your needs

```
{
  "id": "rails_app",
  "config": {
    "dbpassword": "a_user_db_password",
    "staging": {
      "secret_key_base": "a_secret_value",
      "other_secrets": {
        "a_key": {
          "a_subkey": "a value"
        }
      }
    },
    "production": {
      "secret_key_base": "a_secret_value",
      "other_secrets": {
        "another_key": {
          "another_subkey": "another value"
        }
      }
    }
  }
}
```

you will find "other_secrets" inside the file

`config/secrets.yml`

### rails::default

```json
{
  "name":"my_node",
  "rails": {
    "machine_name": "My fantastic server",
    "ssh": {
      "port": 1022
    },
    "global_ruby": "2.3.1",
    "apps_user": "deploy",
    "apps": {
      "rails_app": {
        "staging": {
          "ruby_version": "2.3.1",
          "domain": "staging.example.com",
          "aliases": ["staging1.example.com", "staging2.example.com"],
          "admin_email": "admin@example.com",
          "test_env": true
        },
        "production": {
          "ruby_version": "2.3.1",
          "domain": "www.example.com",
          "aliases": ["example.com"],
          "admin_email": "admin@example.com"
        }
      }
    },
    "extra_packages": [
      ["unzip", nil],
      ["nodejs-legacy", nil]
    ]
  },
  "postgresql": {
    "pg_hba_defaults": false,
    "pg_hba": [
      { "type": "local", "db": "all", "user": "postgres", "addr": "",             "method": "peer" },
      { "type": "local", "db": "all", "user": "all",      "addr": "",             "method": "md5" },
      { "type": "host",  "db": "all", "user": "all",      "addr": "127.0.0.1/32", "method": "md5" },
      { "type": "host",  "db": "all", "user": "all",      "addr": "::1/128",      "method": "md5" }
    ]
  },
  "run_list": [
    "recipe[rails]"
  ]
}
```


## Resources/Providers

### rails_nginx
Generates configuration files for nginx

##### Actions
<table>
    <tr>
        <th>Action</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td>:install</td>
        <td>Install an nginx configuration for provided domain</td>
        <td>true</td>
    </tr>
</table>

##### Attributes
<table>
    <tr>
        <th>Attribute</th>
        <th>Description</th>
        <th>Default value</th>
        <th>Required</th>
    </tr>
    <tr>
        <td>domain</td>
        <td>The domain to listen</td>
        <td>nil</td>
        <td>true</td>
    </tr>
    <tr>
        <td>user</td>
        <td>User that own the nginx configuration files</td>
        <td>nil</td>
        <td>true</td>
    </tr>
    <tr>
        <td>name</td>
        <td>The name of nginx configuration</td>
        <td>nil</td>
        <td>true</td>
    </tr>
    <tr>
        <td>path</td>
        <td>The root path of the application (directory that contain public)</td>
        <td>nil</td>
        <td>false</td>
    </tr>
    <tr>
        <td>aliases</td>
        <td>Additional domain names that redirect to the main domain with 301</td>
        <td>[]</td>
        <td>false</td>
    </tr>
    <tr>
        <td>test_ssl</td>
        <td>If true, used a self signed certifiate generated through amce-staging server</td>
        <td>false</td>
        <td>false</td>
    </tr>
    <tr>
        <td>admin_email</td>
        <td>The email address to provide during letsencrypt user registration</td>
        <td></td>
        <td>false</td>
    </tr>
    <tr>
        <td>key_path</td>
        <td>File system path of the private key file you want to use</td>
        <td>nil</td>
        <td>true</td>
    </tr>
    <tr>
        <td>protocol_policy</td>
        <td>
          Specifies what configuration files need to be installed:
          <ul>
            <li>:only_http  - install only configuration for http</li>
            <li>:only_https - install only configuration for https</li>
            <li>:both - install both configuration</li>
            <li>:http_to_https - force all requests through https protocol/li>
            <li>:https_to_http - force all requests through http protocol/li>
          </ul>
        </td>
        <td>:only_http</td>
        <td>false</td>
    </tr>
    <tr>
        <td>key_path</td>
        <td>File system path of the private key file you want to use</td>
        <td>nil</td>
        <td>true</td>
    </tr>
</table>

### rails_app
This resource install all the stack (nginx/postgresql/rails directory) for a single environment of an application.

##### Actions
<table>
    <tr>
        <th>Action</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td>:install</td>
        <td>Install all configuration and directory for a rails application</td>
        <td>true</td>
    </tr>
</table>

##### Attributes
<table>
    <tr>
        <td>name</td>
        <td>The name of nginx configuration</td>
        <td>nil</td>
        <td>true</td>
    </tr>
    <tr>
        <td>admin_email</td>
        <td>The email address to provide during letsencrypt user registration</td>
        <td></td>
        <td>false</td>
    </tr>
    <tr>
        <td>environment</td>
        <td>The application environment (staging, production, ecc)</td>
        <td>nil</td>
        <td>production</td>
    </tr>
    <tr>
        <td>domain</td>
        <td>The domain to listen</td>
        <td>nil</td>
        <td>true</td>
    </tr>
    <tr>
        <td>aliases</td>
        <td>Additional domain names that redirect to the main domain with 301</td>
        <td>[]</td>
        <td>false</td>
    </tr>
    <tr>
        <td>user</td>
        <td>User that own the nginx configuration files</td>
        <td>nil</td>
        <td>true</td>
    </tr>
    <tr>
        <td>path</td>
        <td>The root path of the application (directory that contain public)</td>
        <td>nil</td>
        <td>false</td>
    </tr>
    <tr>
        <td>test_ssl</td>
        <td>If true, used a self signed certifiate generated through amce-staging server</td>
        <td>false</td>
        <td>false</td>
    </tr>
    <tr>
        <td>directory</td>
        <td>Additional directories to create under capistrano shared in addition to log - public directories</td>
        <td>[]</td>
        <td>false</td>
    </tr>
    <tr>
        <td>protocol_policy</td>
        <td>
          Specifies what configuration files need to be installed:
          <ul>
            <li>:only_http  - install only configuration for http</li>
            <li>:only_https - install only configuration for https</li>
            <li>:both - install both configuration</li>
            <li>:http_to_https - force all requests through https protocol/li>
            <li>:https_to_http - force all requests through http protocol/li>
          </ul>
        </td>
        <td>:only_http</td>
        <td>false</td>
    </tr>
</table>


## TODO

* Support for backup data (database and directories)
* Multi domain name for a same application (for example a localized application through domain name)
* Possibility to pass parameters to extra_packages
* Use supervisord for boot daemon

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors:

* David Librera
* Joe Yates
