---
title: Manage Bind and zone files using Ansible
updated_at: 2014-08-11
categories:
 - sysadmin
tags :
 - ansible
 - bind
 - dns
---

You might have seen my quite simple role [ansible-bind-role](https://github.com/resmo/ansible-role-bind) which lets you manage your bind configs and syncs your zone files.

## Precondition
First let me explain why zones files are not generated in this role: My precondition was, that zones might come from different sources. They may be generated from an application or rsynced from anywhere else.

Further I don't wanted to force people handle zone files _the_ one way. It does not matter where they come from, the role is just managing the sync to the nameservers.

In short, your zones files must exist before using this role. You can have your zone files as plain text file, which is absolutely okay but might become unhandy if the amount of managed zones grow.

Another method is oviously to generate the zones by using Ansible. Let me show you how I do it.

## Base Template
I make use of the template module and the template extension in [Jinja2](http://jinja.pocoo.org):

My base template looks like:

~~~
{% verbatim %}{% set domain = item.name %}
; {{ ansible_managed }}
{% block head %}
$TTL 4h
$ORIGIN {{ domain }}.
@			IN	SOA		ns1.example.com.	hostmaster.example.com. (
				{{ serial }}	; serial
				4h		; refresh (4 hours)
				1h		; retry (4 hours)
				2w		; expire (2 weeks)
				1h		; minimum (1 hour)
				)
{% endblock %}

{% block ns %}
			IN	NS		ns1.example.com.
			IN	NS		ns2.example.com.
{% endblock %}

{% block mx %}
			IN	MX	10	mx1.example.com.
			IN	MX	10	mx2.example.com.
{% endblock %}

{% block spf %}
			IN	TXT		"v=spf1 a mx -all"
{% endblock %}

{% block records %}
			IN	A		1.2.3.4
www			IN	CNAME		@
{% endblock %}{% endverbatim %}
~~~

As you can see, quite generic. We have blocks and some variables. Blocks are useful, so we can override or extend the content of it in templates which extends the base template. The varialbe `item.name` is used for the domain.

## Zone yourdomain.tld

For a default zone, just extend the base. The template looks as simple as that:
~~~
{% verbatim %}; template files/dns/templates/db.yourdomain.tld
{% extends "base" %}
{% set serial = '2014030301' %}{% endverbatim %}
~~~

## Zone yourotherdomain.tld
Now, for another domain `yourotherdomain.tld` if want to have a diffrent setup. We would like to have different NS records, other MX records and a new CNAME `echolon` beside the existing ones of the base template. To achieve that all, we change the block contents where needed or extend them by calling the function `super()` within the block:
~~~
{% verbatim %}; template files/dns/templates/db.yourotherdomain.tld
{% extends "base" %}
{% set serial = '2014030301' %}

{% block ns %}
			IN	NS		ns1.easydns.tld.
			IN	NS		ns2.easydns.tld.
			IN	NS		ns3.easydns.tld.
			IN	NS		ns4.easydns.tld.
{% endblock %}

{% block mx %}
			IN	MX	10	aspmx1.googlemail.com.
			IN	MX	30	aspmx2.googlemail.com.
			IN	MX	20	aspmx3.googlemail.com.
			IN	MX	30	aspmx4.googlemail.com.
			IN	MX	40	aspmx5.googlemail.com.
{% endblock %}

{% block spf %}
; clear out spf
{% endblock %}

{% block records %}
; take everything from the base zone.
{{ super() }}

; and add those ones
echolon			IN	CNAME		yourdomain.tld.
{% endblock %}{% endverbatim %}
~~~

## Generated Zone

The resulting generated zone would then looks like this one below. Also look at the comments in the zone to see what happend in the block.

~~~
; template files/dns/templates/db.yourotherdomain.tld
; Warning: File is managed by Ansible
$TTL 4h
$ORIGIN yourotherdomain.tld.
@           IN  SOA     ns1.example.com.    hostmaster.example.com. (
                2014030301    ; serial
                4h      ; refresh (4 hours)
                1h      ; retry (4 hours)
                2w      ; expire (2 weeks)
                1h      ; minimum (1 hour)
                )

            IN  NS      ns1.easydns.tld.
            IN  NS      ns2.easydns.tld.
            IN  NS      ns3.easydns.tld.
            IN  NS      ns4.easydns.tld.

            IN  MX  10  aspmx1.googlemail.com.
            IN  MX  30  aspmx2.googlemail.com.
            IN  MX  20  aspmx3.googlemail.com.
            IN  MX  30  aspmx4.googlemail.com.
            IN  MX  40  aspmx5.googlemail.com.

; clear out spf

; take everything from the base zone.
            IN  A       1.2.3.4
www         IN  CNAME       @


; and add those ones
echolon         IN  CNAME       yourdomain.tld.
~~~

## Playbook

The play is farly simple, just a template task. But notice the task is set up to run on localhost, so it would only run once at a time and on your local machine.

~~~
{% verbatim %}---
# file: generate_zones.yml
- name: generating the master zones
  hosts: localhost
  gather_facts: no
  tasks:
  - name: generate zones from template
    local_action: template src=files/dns/templates/db.{{ item.name }} dest=files/dns/masterzones/
    with_items:
      - name: yourotherdomain.tld
{% endverbatim %}
~~~

In the next step, we can use our role `ansible-role-bind` for syncing the generated zone to the nameservers.

To achieve that, the variable `bind_masterzones_path` must point to the destination path of our generated templates and the `bind_config_master_zones` must have at least all identical domain items just like we used in the generate play.

In an production setup, I would recommend to use variables for all domain items and put them in the `group_vars/all/zones` and `group_vars/nameservers`.

~~~
{% verbatim %}---
# file: nameservers.yml
- hosts: nameservers
  remote_user: root
  vars:
    bind_masterzones_path: files/dns/masterzones/
    bind_config_master_zones:
      - name: yourotherdomain.tld
  roles:
  - resmo.bind
{% endverbatim %}
~~~

## Summary

Two simple plays and the template module can be a huge time saver when handling with bind zone files.
Ansible can help to make DNS zone management fun again.

