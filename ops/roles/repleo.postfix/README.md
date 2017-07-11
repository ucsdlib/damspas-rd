repleo.postfix - Ansible role for installing postfix SMTP with SSL and Spam filter support
==============

[![Build Status](http://img.shields.io/travis/repleo/ansible-role-postfix.svg?style=flat-square)](https://travis-ci.org/repleo/ansible-role-postfix)
[![Ansible Galaxy](http://img.shields.io/badge/galaxy-repleo.postfix-660198.svg?style=flat)](https://galaxy.ansible.com/repleo/postfix)

Ansible role which manage postfix. It allows you to create a full SMTP server with TLS/SSL and STARTSSL support. Spamassassin is also installed for filtering SPAM. It comes with a bayesian db with 10 year Spam experience.

#### Requirements

Only tested on ubuntu and debian for now.

#### Variables

```yaml
postfix_enabled: yes # The role is enabled

postfix_smtpd_use_tls: yes
postfix_myhostname: "{{inventory_hostname}}"
postfix_myorigin: $myhostname
postfix_smtp_sasl_auth_enable:
postfix_smtp_tls_cafile: "/etc/ssl/certs/Thawte_Premium_Server_CA.pem"
postfix_smtp_use_tls: yes

#Define to enable auth_sasl
#postfix_smtpd_auth_sasl_enable

postfix_relayhost:
postfix_mynetworks: "127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
postfix_inet_interfaces: loopback-only
postfix_mydestination: $mydomain, $myhostname, localhost.$mydomain, localhost
postfix_local_recipient_map: ""

postfix_generic_maps: ""

# Mail delivery options
postfix_use_maildrop: no
postfix_use_procmail: no

# Install opendkim and setup postfix to use DKIM
postfix_dkim: no
postfix_dkim_domain: "{{inventory_hostname}}"

# Relay all mail going to local users (e.g. root or cron) to another mail address
postfix_local_user_relay_address: ""

# Useful if you use a SMTP server for relay that doesn't allow
# arbitrary sender addresses.
postfix_rewrite_sender_address: ""

# Send a test mail to this address when Postfix configuration changes
postfix_send_test_mail_to: ""

postfix_smtp_sasl_user: "{{ansible_ssh_user}}"
postfix_smtp_sasl_password: ""
```

# Queue
bounce_queue_lifetime: 1h
maximal_queue_lifetime: 1h
maximal_backoff_time: 15m
minimal_backoff_time: 5m
queue_run_delay: 5m

postfix_tls_generate: False
postfix_ssl_subject: ""
postfix_tls_cert_file: "/etc/ssl/certs/ssl-cert-snakeoil.pem"
postfix_tls_key_file: "/etc/ssl/private/ssl-cert-snakeoil.key"


#### Usage

Add `repleo.postfix` to your roles and set vars in your playbook file.

Example:

```yaml

- hosts: all

  roles:
    - repleo.postfix

  vars:
    # Example configuration for gmail
    postfix_relayhost: "[smtp.gmail.com]:587"
    postfix_smtp_sasl_user: myemail@gmail.com
    postfix_smtp_sasl_password: mypassword
```

```yaml
 - { role: repleo.postfix,
     postfix_mydestination: "repleo.nl, $mydomain, $myhostname, localhost.$mydomain, localhost",
     postfix_mynetworks: "127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128",
     postfix_inet_interfaces: all,
     postfix_use_maildrop: yes,
     postfix_smtpd_use_tls: yes,
     postfix_tls_key_file: /etc/postfix/tls/smtp.repleo.nl.key,
     postfix_tls_cert_file: /etc/postfix/tls/smtp.repleo.nl_chain.pem,
     postfix_smtpd_auth_sasl_enable: yes,
     postfix_send_test_mail_to: jeroen@repleo.nl
   }
```

#### License

Licensed under the MIT License. See the LICENSE file for details.

#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/repleo/repleo.postfix/issues)!
