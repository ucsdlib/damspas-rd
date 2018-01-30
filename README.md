# DAMSPAS-RD

> Frankly, my dear, I don't GIVE A DAMS!

R&D project for a future DAMS5. A digital collections application for the UC San Diego Library built using the [Hydra framework](https://projecthydra.org/), specifically using the [Hyrax front-end](https://github.com/projecthydra-labs/hyrax/), and the [Fedora Repository](http://fedorarepository.org/).

[![Coverage Status](https://coveralls.io/repos/github/ucsdlib/damspas-rd/badge.svg?branch=develop)](https://coveralls.io/github/ucsdlib/damspas-rd?branch=develop)
[![Dependency Status](https://gemnasium.com/ucsdlib/damspas-rd.svg)](https://gemnasium.com/ucsdlib/damspas-rd)

## Prerequisites

The following software are required:

1. Solr
1. [Fedora Commons](http://www.fedora-commons.org/) digital repository
1. A SQL RDBMS (MySQL, PostgreSQL), though **note** that SQLite will be used by default if you're looking to get up and running quickly.
1. [Redis](http://redis.io/), a key-value store. The `redlock` gem requires Redis >= 2.6.
1. [ImageMagick](http://www.imagemagick.org/) with JPEG-2000 support.
1. [LibreOffice](https://www.libreoffice.org/download/libreoffice-fresh/)
1. [FITS](http://projects.iq.harvard.edu/fits/downloads) version 0.8.5.
1. [FFMPEG](https://ffmpeg.org/)

Please visit [Curation Concerns](https://github.com/projecthydra/curation_concerns) for installation guide.

### Check out DAMSPAS from GIT
1. Clone Project: ```git clone https://github.com/ucsdlib/damspas-rd```
2. Open Project: ```cd damspas-rd```
3. Install gems: ```bundle install```
4. Update DB: ```bundle exec rake db:migrate```
5. Edit config/browse_everything_providers.yml file_system home for server side files ingest.

### Start Redis
```
redis-server
```

### Running Tests
```bash
# Start the test servers
rake hydra:test_server
```

Or do it in the following steps:

```bash
solr_wrapper -p 8985 -d solr/config/ --collection_name hydra-test

# in another window
fcrepo_wrapper -p 8986 --no-jms
```

```bash
# run the test suits
bundle exec rake spec
```

### Running damspas-rd (demo only)
```rake hydra:server```

Or do it in the following steps:

```bash
solr_wrapper -p 8983 -d solr/config/ --collection_name hydra-development

# in another window
fcrepo_wrapper -p 8984 --no-jms

# and in another window
rails s
```
Go to http://localhost:3000/ and register to start

### Start Sidekiq in another window
```
bundle exec sidekiq
```

### Adding an admin role to the last user
```bash
rake add_admin_role
```

### Import Local Authority records for control values
```bash
bin/import-authorities
```

### Create an admin set to start ingest
```rake hyrax:default_admin_set:create```



# Deployment
Deployment is handled via ansible, allows rollback and can be used to provision new machines

```bash
./bin/deploy production 
```

```bash
./bin/rollback production 
```

## Provisioning and testing of provisioning
The following 4 scripts are provided to make server maintanence easier.  Each can be run in both production and development mode (see note about development).

./bin/deploy  - Deploy a release to the servers. Can be production or development
./bin/provision - Run the configuration script, which will attempt to install and configure all software. Configuration is idempotent, so running it on a configured server is acceptable.  Can be run in production or development
./bin/cleanup - development only.  This script closes down the docker images used by the scripts to test provisioning
./bin/rollback - Roll back the last deploy. Can be production or development


## Development environment for ansible scripts
In order to facilitate development and modification of the ansible scripts, a development config has been established.  This requires Docker be running on the dev machine and that the proper docker python packages are installed.  If using ansible >= 2.4 install python packages with "pip install docker docker-compose". For older versions of ansible "pip install docker-py".  Please note that docker-py and docker-compose Python packages do not get along.

If you run in to problems with systemd (specifically hanging process starts or restarts) then you may need to update the docker image. Systemd upgrades can not be done on the fly in a running docker instance, see: https://github.com/geerlingguy/ansible-role-security/issues/21 
To do an update run "docker rmi notch8/systemd" then run the ./bin/provision development as normal.  This will clear your existing containers. Note that all containers must be stopped to do this, so you may want to run ./bin/cleanup development first.

