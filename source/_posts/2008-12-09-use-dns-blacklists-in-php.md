---
title : Use DNS Blacklists in PHP
categories:
 - programming
tags :
 - dnsbl
 - php
---
The following snippet is a quick and simple way to use dnsbl in PHP code (or for CLI use), if an IP is listed the code will return 1:

~~~php
<?php
/*
* Simple DNSBL check
* Author: René Moser
*/
// Check this IP
$ip = '201.2.6.141';

// List of DNSBL DNS Servers
$dns_black_lists = file('./dnsbl.txt', FILE_IGNORE_NEW_LINES);

// Reverse the IP
$rev_ip = implode(array_reverse(explode('.', $ip)), '.');
$response = array();
foreach ($dns_black_lists as $dns_black_list) {
    $response = (gethostbynamel($rev_ip . '.' . $dns_black_list));
    if (!empty($response)) {
        echo "1\n";
        exit;
    }
}
echo "0\n";
~~~

The corresponding dnsbl.txt:
~~~txt
asiaspam.spamblocked.com
bl.deadbeef.com
bl.emailbasura.org
bl.spamcop.net
blackholes.five-ten-sg.com
blacklist.woody.ch
bogons.cymru.com
cbl.abuseat.org	cdl.anti-spam.org.cn
combined.abuse.ch
combined.rbl.msrbl.net
db.wpbl.info
dnsbl-1.uceprotect.net
dnsbl-2.uceprotect.net
dnsbl-3.uceprotect.net
dnsbl.abuse.ch
dnsbl.ahbl.org
dnsbl.cyberlogic.net
dnsbl.inps.de
dnsbl.njabl.org
dnsbl.sorbs.net
drone.abuse.ch
duinv.aupads.org
dul.dnsbl.sorbs.net
dul.ru
dyna.spamrats.com
dynip.rothen.com
eurospam.spamblocked.com
fl.chickenboner.biz
http.dnsbl.sorbs.net
images.rbl.msrbl.net
ips.backscatterer.org
isps.spamblocked.com
ix.dnsbl.manitu.net
korea.services.net
lacnic.spamblocked.com
misc.dnsbl.sorbs.net
noptr.spamrats.com
ohps.dnsbl.net.au
omrs.dnsbl.net.au
orvedb.aupads.org
osps.dnsbl.net.au
osrs.dnsbl.net.au
owfs.dnsbl.net.au
owps.dnsbl.net.au
pbl.spamhaus.org
phishing.rbl.msrbl.net
probes.dnsbl.net.au
proxy.bl.gweep.ca
proxy.block.transip.nl
psbl.surriel.com
rbl.interserver.net
rdts.dnsbl.net.au
relays.bl.gweep.ca
relays.bl.kundenserver.de
relays.nether.net
residential.block.transip.nl
ricn.dnsbl.net.au
rmst.dnsbl.net.au
sbl.spamhaus.org
short.rbl.jp
smtp.dnsbl.sorbs.net
socks.dnsbl.sorbs.net
spam.dnsbl.sorbs.net
spam.rbl.msrbl.net
spam.spamrats.com
spamlist.or.kr
spamrbl.imp.ch
t3direct.dnsbl.net.au
tor.ahbl.org
tor.dnsbl.sectoor.de
torserver.tor.dnsbl.sectoor.de
ubl.lashback.com
ubl.unsubscore.com
virbl.bit.nl
virus.rbl.jp
virus.rbl.msrbl.net
web.dnsbl.sorbs.net
wormrbl.imp.ch
xbl.spamhaus.org
zen.spamhaus.org
~~~
