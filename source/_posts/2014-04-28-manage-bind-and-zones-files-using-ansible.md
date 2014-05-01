---
title: Manage Bind and zone files using Ansible
draft: yes
categories:
 - sysadmin
tags :
 - ansible
 - bind
 - dns
---

You might have seen my quite simple role [ansible-bind-role](https://github.com/resmo/ansible-role-bind) which lets you manage your bind configs and syncs your zone files.

This means your zones files must exist before using this role. You can either have your zone files as plain text file, which is absolutely okay but might become unhandy if the amount of managed zones grow.

First let me explain: My precondition is, that zones might come from different sources. They may be generated from an application or rsynced from anywhere else. So to us it does not matter where they come from, we are managing just the sync in ansible-bind-role to the nameservers.

One method the generate the zones is oviously by using Ansible. Let me show you how I do it.

## Base Template

I make use of the template module and the template extension in [Jinja2](http://jinja.pocoo.org):

My base template looks like:

~~~
{% verbatim %}{% set domain = item.name %}
{% set serial = '2014030301' %}
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

As you can see, quite generic. We have blocks and some variables. Blocks are useful, so we can override or extend the content of it in templates which extends the base template. `item.name` is used for the domain.

## Zone yourdomain.tld

For a default zone, just extend the base. The template looks as simple as that:
~~~
{% verbatim %}; template files/dns/tempaltes/db.yourdomain.tld
{% extends "base" %}{% endverbatim %}
~~~

## Zone yourotherdomain.tld
Now, for another domain `yourotherdomain.tld` if we have to setup diffrent NS records, other MX records, so we can simply change the block contents:
~~~
{% verbatim %}; template files/dns/tempaltes/db.yourotherdomain.tld
{% extends "base" %}
{% set serial = '2014030201' %}

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
{{ parent() }}

; and add those ones
echolon			IN	CNAME		yourdomain.tld.
{% endblock %}{% endverbatim %}
~~~

## Playbook
~~~
{% verbatim %}---
# file: nameservers.yml
- name: generating the master zones
  hosts: localhost
  gather_facts: no
  tasks:
  - name: generate zones from template
    local_action: template src=files/dns/tempaltes/db.{{ item.name }} dest=files/dns/masterzones/
    with_items:
      - name: yourdomain.tld
{% endverbatim %}
~~~

## Generated Zone

The generated zone looks like this:

~~~
; template files/dns/tempaltes/db.yourotherdomain.tld
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


