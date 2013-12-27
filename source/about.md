---
layout: default
title: About

---
# About the Author

Hi, my name is René Moser, I work as Linux System Engineer and develop Open Source Software in my free time. Why I use Open Source Software? I just took the best tool I could get!

## Address
René Moser<br/>
Grundmattstrasse 4<br/>
CH-4565 Recherswil<br/>

<div id="map"></div>

<script>
var map = L.map('map').setView([47.161045, 7.591968], 13);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
  maxZoom: 18,
  attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>'
}).addTo(map);

L.marker([47.161045, 7.591968]).addTo(map);
</script>


## Contact
<ul>
  <li>Phone: <a href="tel:+41326810171">+41 32 681 01 71</a></li>
  <li>Mobile: <a href="tel:+41763321367">+41 76 332 13 67</a></li>
  <script type="text/javascript">
  <!-- 
  var tail='renemoser.net';
  var head='mail';
  var buildedEmail=(head + '@' + tail)
  document.write('<li>E-Mail: <a href="mailto:' + buildedEmail + '">' + buildedEmail + '</a></li>')
  //-->
  </script>
</ul>

## PGP and SSH Keys
* PGP Fingerprint: 5826 19B1 A4F6 AE8B C58A  D848 8306 965B E6D6 331D
* PGP Public Key: <a href="/downloads/rene.moser_public-key.asc">rene.moser_public-key.asc</a>
* SSH Public Key: <a href="/downloads/renemoser.ssh.pub">renemoser.ssh.pub</a>

