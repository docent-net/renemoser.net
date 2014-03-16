---
title : Test Ansible roles with Travis CI
updated_at: 2014-03-15
categories:
 - sysadmin
tags :
 - ansible
 - travis
 - ci

---
I usually test my projects automatically with [Travis](https://travis-ci.org) on every change or pull request. So I tried to figured out a way to test my [Ansible](http://www.ansibleworks.com/) roles on Ansible's [Galaxy](http://galaxy.ansibleworks.com) with Travis.

## Tests run on Ubuntu 12.04

[Travis is only using Ubuntu 12.04](http://about.travis-ci.org/docs/user/ci-environment/) for running the tests. I usually use [Debian](http://www.debian.org) as distribution for my servers. So at least the same OS family to test on, but it is sad, that Travis let us not choose the OS. However, better than nothing.

## Set up a playbook

First, we set up a simple playbook targeted to localhost and <del>include var files, tasks and handlers</del> the new role, because otherwise ansible does not handle it as a role (dependencies, defaults):

    ---
    - hosts: localhost
      remote_user: root
      roles:
      - ansible-role-ntp

<del>This base playbook can be used in every role with no change.</del> Use the name of your git repo for the role.

## ansible.cfg

Because ansible would use the default `role_path` to handle the role, the above playbook would not work. Therefore we make an ansible.cfg in the root path of the role in which we define the correct `role_path`.

    [defaults]
    roles_path = ../

As you can see, we define the roles path to be the one directory level above.

## Set up a .travis.yml

The travis file is also straigt forward. As we know, the test will run on [Ubuntu](http://www.ubuntu.com), we also install some known dependencices by default, like `python-apt` and `python-pycurl`.

We install latest released ansible and set up the inventory. Then we check first for syntax errors and after this, we run the playbook.

To gain root permissions on Travis, we must use `--sudo`, even though, `remote_user` is set as `root`.

Further we use the a local connection and set verbosity to maximum. Note, We only use python 2.7 as we do not want to test ansible by itself.

    ---
    language: python
    python: "2.7"
    before_install:
     - sudo apt-get update -qq
     - sudo apt-get install -qq python-apt python-pycurl
    install:
      - pip install ansible
    script:
      - echo localhost > inventory
      - ansible-playbook -i inventory --syntax-check role.yml
      - ansible-playbook -i inventory --connection=local --sudo -vvvv role.yml


If your role has dependendies defined in your `meta/main.yml` you can simply install the dependencies in your install step using `ansible-galaxy` like:

    ...
    install:
    - pip install ansible
    - ansible-galaxy install <rolename>
    ...

## Example Role ansible-role-ntp

As a working example, I show you my role for installing ntp, [ansible-role-ntp](https://github.com/resmo/ansible-role-ntp). As you can see, I also intgrated the build status image in readme.

## Summary

It is no magic using Travis to have a basic, automated test environment for Ubuntu. It gives you a good warm feeling if you change something and the tests pass, and this for free. 

In the future, It would be great if we could also run the tests on several different OS'. Maybe Travis or even Ansibleworks will bring us this feature. Hint, Hint.
