---
layout: ../../layouts/MarkdownLayout.astro
title: 'My First Blog Post'
pubDate: 2022-07-01
description: 'This is the first post of my new Astro blog.'
author: 'Astro Learner'
image:
    url: 'https://docs.astro.build/assets/rose.webp'
    alt: 'The Astro logo on a dark background with a pink glow.'
tags: ["astro", "blogging", "learning in public"]
---
Wir haben folgendes Projekt als Azubis bekommen:  
Wir müssen einen internes Netzwerk aufsetzen, wir haben bekommen:  
+ Eine Hardware Firewall (Balo Alto)  
+ Einen Switch  
+ Einen Access Point (Fritzbox)  
+ Einen Server (Windows Server)

Das Ziel: tagesschau.de soll aufrufbar sein, von einem Gerät im Netzwerk.  
Zusätzliche Ziele:  
+ Ein Intranet mit einer ~={purple}Astro=~ Website

Was ich denke was wir dafür machen müssen:  
+ DHCP auf dem Windows Server konfigurieren  
+ DNS auf dem Windows Server konfigurieren  
+ AD auf dem Windows Server konfigurieren

~={purple}Passwort=~: IBM-Arthur23
# IP Zuteilung  

| Netzgerät                   | IP                        |
| --------------------------- | ------------------------- |
| Netzwerkadresse  <br>       | 10.10.200.0               |
| Broadcast                   | 10.10.200.255             |
| Firewall                    | 10.10.200.255             |
| Switch                      | 10.10.200.2               |
| Access Point                | 10.10.200.3               |
| Server                      | 10.10.200.4 - 10.10.200.? |
| Laptop (direkt im Netzwerk) | 10.10.200.20              |
| Lan1                        | 10.10.200.21              |
| Lan2                        | 10.10.200.22              |


# TODO  
+ Herausfinden was gerade DHCP macht  
+ DNS Server konfigurieren  
+ Firewall einstellen

## Tagesschau  
Wir müssen tagesschau.de aufrufen können:  
Laptop -> DNS (Server) -> Firewall -> Internet  
Laptop -> AccessPoint -> DNS -> Firewall -> Internet