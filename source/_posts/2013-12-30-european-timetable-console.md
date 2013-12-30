---
title : European timetable in your console
categories:
 - sysadmin
tags :
 - python
---

If you like to provide a geek looking time table of your train connections, or on events on a wallboard. Here is a way to do it :)

First you need the fahrplan application, which uses the api of the swiss national railway company to get the data. They not only have swiss connection data, they seems to have all european connection data. At least quite a lot.

    pip install fahrplan

Use the help `fahrplan -h` to see all options. E.g. 

    fahrplan -f from hamburg dammtor to ostermundingen

and you will get something like:

    #  | Station                        | Platform | Date          | Time  | Duration |
    -----------------------------------------------------------------------------------
    1  | Hamburg Dammtor                | 4        | Mon, 30.12.13 | 20:05 | 12:11    |
       | Basel SBB                      | 5        | Tue, 31.12.13 | 06:47 |          |
       | ------------------------------ | -------- | ------------- | ----- |          |
       | Basel SBB                      | 6        | Tue, 31.12.13 | 06:59 |          |
       | Bern                           | 4        | Tue, 31.12.13 | 07:56 |          |
       | ------------------------------ | -------- | ------------- | ----- |          |
       | Bern                           | 3        | Tue, 31.12.13 | 08:12 |          |
       | Ostermundigen                  | 2        | Tue, 31.12.13 | 08:16 |          |

Now you can use `watch` to realise a auto refresh after a certain amount of time (500 seconds):

    watch -n 500 fahrplan from hamburg dammtor to ostermundingen
