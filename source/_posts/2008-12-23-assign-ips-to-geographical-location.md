---
title : Assign IPs to geographical Location
categories:
 - programming
tags: 
 - geoip
 - networking
 - oss
 - php
 - security
---
Assign IPs to geographical Location is quite interessting: if you know where visitors come from. you can redirect them to the web shop of their country, you can keep some countries away of your SSH daemon or showing special offers or events of this country.

Of course this is not bullet proof. If your visitors using proxies located in a different country, anonymizer like TOR or accessing the internet by VPN so GeoIP won't work as expected.

Geo location of an IP is also known as GeoIP, because the only service most of the people know is named GeoIP by MaxMind.

GeoIP of MaxMind
---

<a href="http://www.maxmind.com/app/ip-location">GeoIP</a> is a very popular service and often in open source software used. MaxMind, the company behind GeoIP provides a binary database monthly updated for free use (but is not open source). Most of the modern programming languages have <a href="http://www.maxmind.com/app/api">APIs</a> to this service. Try out the <a href="http://www.maxmind.com/app/locate_ip">demo</a>.

On modern Linux systems there is a package named geoip-bin:
~~~bash
aptitude install geoip-bin
~~~

Download the binary database.
~~~bash
mkdir /usr/local/share/GeoIP
cd /usr/local/share/GeoIP
wget http://www.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
gunzip GeoLiteCity.dat.gz
ln -s /usr/local/share/GeoIP/GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
~~~

use it
~~~bash
geoiplookup 84.226.106.171
~~~

NetOp - DNS based IP location service
---

DNS is always a good solutions if you want resolve a hostname or ip to something. <a href="http://www.netop.org/">NetOP.org</a> provides such a DNS based location service. So the website says:
> Existing approaches to IP geolocation chose to invent their own non-standard APIs. We feel that is not necessary. DNS is a highly efficient way to export IP-to- datasets.</blockquote>
> This is so true.
>...

Serving data via DNS, rather than a flat file, guarantees that answers to queries remain fresh.

With the country.netop.org service, NetOp demonstrates here that no special APIs are needed. All you need is a standard DNS resolver API.

NetOp runs a service that allows the public Internet to make DNSBL-style queries for a given IPv4 address's ISO 3166 country code, as stored in a TXT RR</blockquote>
You can simply lookup a IP like this.

If you have a IP <em>84.226.106.171</em>, make it reverse <em>171.106.226.84</em>. And then use your preferred dns lookup tool:

~~~bash
dig 171.106.226.84.country.netop.org TXT
~~~

You will get a answer like

~~~bash
;; ANSWER SECTION:
171.106.226.84.country.netop.org. 604800 IN TXT    "CH"
~~~

As you can see, the IP is located in CH which stands for Switzerland. This service is not very detailed, it only shows countries for IP addresses. But very fast and easy to use.

With PHP this can be used like the following snippet on Linux/Unix. This snippet shows how you can use it:

~~~php
<?php
// Nameserver we want to ask
$nameserver = 'country.netop.org';

// IP which we want to be check
// Normally use: $ip = $_SERVER['REMOTE_ADDR'];
$ip = "201.2.6.141"; // example IP

// Make IP reverse
$rev_ip = implode(array_reverse(explode('.', $ip)), '.');

// Default result
$country = "unknown";

// dns_get_record my not exist on some systems
if (is_callable("dns_get_record")) {
    $result = dns_get_record($rev_ip.'.'.$nameserver, TXT);
    if (!empty($result)) {
        // FIX: Not 100% sure if this works
        $country = $result[0];
    }

// dns_get_record is not available
} else {
    // we use dig on command line instead
    $command = 'dig '.$rev_ip.'.'.$nameserver.' TXT | grep ^[^\;]';
    $result = shell_exec($command);

    // Parse the dig output to only show the 2 letters of country code
    if (preg_match('/"([a-zA-Z]{2,2})"/',$result, $matches)) {
        $country = $matches[1];
    }
}
echo $country;
~~~

NetOp is still beta but works great for me. Hope you like it too.

HostIP
---
<a href="http://www.hostip.info/">HostIP</a> is an open project. See the <a href="http://www.hostip.info/use.html">examples</a> which show how to use this service, the API uses HTTP GET. But you are also able to <a href="http://www.hostip.info/dl/index.html">download the database</a> (MYSQL DUMP ~25 MB GZIP) by HTTP or even better by RSYNC (MySQL, BDB, CSV) from mirrors.

> Note: we are actively looking for rsync mirrors so please shoot us an email if you're interested!

If you wish to <a href="http://www.hostip.info/contrib/index.html">contribute</a>, there is a  GIT repo to pull from and of course an e-mail address to send patches to. On this site, you can also find some API Extensions, Firefox extensions, etc.

So, time for a quick example. To only show a flag of the country of your visitors, it is simple as:

~~~html
<a href="http://www.hostip.info">
<img src="http://api.hostip.info/flag.php" alt="IP Address Lookup" />
</a>
~~~

<h2>InfoSniper</h2>
Another nice service I found is <a href="http://www.infosniper.net/">infosniper</a>. But consider:

> We offer you 15 location queries per day for free. Interested in using this service commercially? We charge 10 EUR for 50,000 successful location queries. So a single location query costs you just 0.0002 EUR.</blockquote>

They provide a lot of scripts, <a href="http://www.infosniper.net/geolocate-ip-addresses-api.php">API access examples</a> and gadgets on their website. The IP geolocation query also does a whois query too go get more information. 

Have phun.
