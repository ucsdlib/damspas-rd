# Horton
A digital collections application for the UC San Diego Library built using the [Hydra framework](https://projecthydra.org/), specifically using the [Hyrax front-end](https://github.com/projecthydra-labs/hyrax/), and the [Fedora Repository](http://fedorarepository.org/).

[![Coverage Status](https://coveralls.io/repos/github/ucsdlib/horton/badge.svg?branch=develop)](https://coveralls.io/github/ucsdlib/horton?branch=develop)
[![Dependency Status](https://gemnasium.com/ucsdlib/horton.svg)](https://gemnasium.com/ucsdlib/horton)

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
1. Clone Project: ```git clone https://github.com/ucsdlib/horton```
2. Open Project: ```cd horton```
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

### Running horton (demo only)
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

