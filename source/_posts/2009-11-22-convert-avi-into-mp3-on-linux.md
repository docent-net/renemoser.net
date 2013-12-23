---
title : Convert .avi into .mp3 on Linux
categories:
 - sysadmin
tags :
 - mp3
 - avi
 - ffmpeg
---

From time to time I have to google for this, now I am making a post so I know where I can find :)

This converts the complete avi into mp3:

~~~bash
ffmpeg -i movieSample.avi -ab 256k -vn autioSample.mp3
~~~

This extracts from 00:21:24 for 40s and converts avi into mp3:

~~~bash
ffmpeg -ss 00:21:24 -t 00:00:40 -i movieSample.avi -ab 256k -vn autioSample.mp3
~~~
