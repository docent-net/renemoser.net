---
title : Postfix: Host not found, try again
categories:
 - sysadmin
tags :
 - postfix
---
Small hint from me: If you set up Postfix to relay your mails and your relay host does not have an MX record (anymore), mailq has a lot of mails on standby and you see something like:

~~~txt
Jul 14 12:45:39 myhostname postfix/smtp[2349]: 74FBF30501:
        to=<recip@recip.domain> relay=none, delay=3944,
        status=deferred (Name service error for name=recip.domain
        type=MX: Host not found, try again)
~~~

And found this <a href="http://www.postfix.org/faq.html#dns-again">FAQ on Posfix.org</a> and you say: "Yeah, the FAQ is right but so what now?". Just boot your VI editor and open 

~~~bash
editor /etc/postfix/main.cf
~~~

and change 

~~~bash
relayhost = smtp.example.com:587
~~~

to
~~~bash
relayhost = [smtp.example.com]:587
~~~

and perform

~~~bash
/etc/init.d/posfitx reload
~~~

so Postfix will not looking for a valid MX record anymore. After this, go to the important work again...
