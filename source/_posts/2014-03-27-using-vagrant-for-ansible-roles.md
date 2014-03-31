---
title : Using Vagrant for Ansible roles
categories:
 - sysadmin
tags :
 - ansible
 - vagrant
---

You may have read my [post](/blog/2014/01/01/test-ansible-roles-with-travis-ci) about testing roles. In this post I want to show you how you can use your virtualisation software locally installed like [VirtualBox](https://www.virtualbox.org) to test your [Ansible](http://www.ansibleworks.com) roles.

## Vagrant

[Vagrant ](http://www.vagrantup.com) acts as a wrapper of your virtualisation software. It is used to minimize the complexity to download the base VM, set it up, provisioning, using and destroying the VM over and over again. To handle this, vagrant uses a file where you define the way, how the VM is going to be created: the Vagrantfile.

But first [install vagrant](http://www.vagrantup.com/downloads.html).


## Vagrantfile for ansible role

You can set up a base and heavily commented default Vagrantfile running `vagrant init`. 

But below we go directly to the customized Vagrantfile, we will use for the role `ansible-role-ntp`:

~~~
# Vagrantfile
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.network "public_network"

  config.vm.define "localhost" do |l|
    l.vm.hostname = "localhost"
  end

  config.vm.provider :virtualbox do |vb|
    vb.name = "ansible-role-ntp"
  end

  # This should already be in the box.
$script = <<SCRIPT
apt-get update
apt-get -qq install python python-pycurl python-apt
SCRIPT

  config.vm.provision "shell", inline: $script

  config.vm.provision "ansible" do |ansible|
    ansible.sudo = true
    ansible.playbook = "role.yml"
    ansible.verbose = "v"
    ansible.host_key_checking = false
  end
end
~~~

Now, let me explain, what it does.

### Vagrantfile: Box

I defined the box to be a Ubuntu precise, which will be automatically downloaded if it is not already locally available.

~~~
config.vm.box = "precise32"
config.vm.box_url = "http://files.vagrantup.com/precise32.box"
~~~

### Vagrantfile: Network

~~~
config.vm.network "public_network"
~~~

We want to have connection to the world. So we setup the public network.

If you like to have a private network too, where you can set a static ip and e.g. running another ansible playbook against or test if the service is available, this could also be done easily:

~~~
config.vm.network "private_network",ip: "192.168.56.10", virtualbox__intnet: "vboxnet0"
config.vm.network "forwarded_port", guest: 8080, host: 8080
~~~

### Vagrantfile: Define

The following part is related to the ansible role. As the `role.yml` is applied to `localhost`. The VM must be named `localhost`.

~~~
config.vm.define "localhost" do |l|
  l.vm.hostname = "localhost"
end
~~~


### Vagrantfile: Provider

For better readabilty in the virtualbox GUI , we set our VM to be named like the role:

~~~
config.vm.provider :virtualbox do |vb|
  vb.name = "ansible-role-ntp"
end
~~~

### Vagrantfile: provision

The following shell provision code is only there, because in the box we use didn't have pyhton installed. Later We should make a box having pyhton ready so this part can be skipped. But it is also good to know, you can do this as well.

~~~bash
# This should already be in the box.
$script = <<SCRIPT
apt-get update
apt-get -qq install python python-pycurl python-apt
SCRIPT

config.vm.provision "shell", inline: $script
~~~

Now the interessting part: we provision using ansible:

~~~
config.vm.provision "ansible" do |ansible|
ansible.sudo = true
ansible.playbook = "role.yml"
ansible.verbose = "v"
ansible.host_key_checking = false
~~~

That's it.

## Run vagrant

After the setup we run our role with help of vagrant:

~~~bash
$ vagrant up
~~~

Check everything is ok using ssh:

~~~bash
$ vagrant ssh
~~~

Or run the provision part again:

~~~bash
$ vagrant provision
~~~

Destroy the VM:

~~~bash
$ vagrant destroy
~~~

## Example

My [ansible-role-ntp](https://github.com/resmo/ansible-role-ntp) has been updated to integrate vagrant. If you would like to see the full example. There it is.
