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

First let me explain: My precondition is, that zones might come from different sources. They may be generated from an application or rsynced from anywhere else. So to us it does not matter where they come from, we are managing just the sync to the nameservers.

One method the generate the zones is oviously by using Ansible. Let me show you how I do it.

I make use of the template module and the template extension in Jinja2:

Our base template looks like:

~~~
{% set domain = item.name %}
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
{% endblock %}
~~~

As you can see, quite basic. We have blocks and some variables.

~~~
---
- hosts: localhost
  gather_facts: no
  tasks:
  - name: generate zones from template
    local_action: template src={{ generate_zones_src_path }}/db.{{ item.name }} dest={{ generate_zones_dest_path }}
    with_items: generate_zones

- hosts: nameservers
  remote_user: root
  serial: 1
  roles:
  - resmo.bind
~~~
