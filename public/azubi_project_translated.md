## Firewall
1. Firewall wurde auf Werkseinstellungen zurückgesetzt & Admin Benutzer wurde eingerichtet
OS-Version (sw-version) 11.1.5

Firewall besitzt etwas wie grep: "match"

```sh
config show running | match ethernet1/1
```


### Interface Typen

#### Virtual Wire
+ Firewall arbeitet transparent, keine IP am Interface
+ Wird als "Durchleit-Filter" in Firmen genutzt.

#### Layer2
+ Firewall agiert wie ein Switch-Port
+ Kein eigenes Gateway

#### layer3
+ Firewall-Port bekommt eine IP
+ Firewall wird Gateway für Subnetze
=> Genau das was wir brauchen

Die Firewall hat interfaces, wir haben folgendes an spezifische interfaces angeschlossen:
### Ethernet1/1:
Internet von einer externen Fritzbox. Das Ziel ist vom DHCP der Fritzbox
eine IP zu bekommen.
+ DHCP-Client
+ Zone = Untrust
+ ethernet1/3 : Hier soll die Switch konfiguriert werden. 
```sh
configure
delete network virtual-wire default-vwire
commit
```
Damit sagen wir der Firewall
Behandeln Sie diese Ports nicht mehr als transparente Bridge – geben Sie sie frei, damit ich sie in einem anderen Modus (z. B. Layer 3) verwenden kann.“
Die Schnittstellen selbst werden dadurch nicht gelöscht, sondern nur entkoppelt
und das vwire-Objekt entfernt.

Diese nächsten Schritte sind erforderlich, da die Standardkonfiguration ethernet1/1 und ethernet1/2 als Standardports für vwire verwendet.

Schritt 1: Löschen Sie die Standardregel, die auf die Standardzonen *trust* und *untrust* verweist.
```sh
configure
delete rulebase security rules rule1
commit force
```
Schritt 2: Entferne die Zonen zuordnung in den Schichten
```sh
delete zone untrust network layer3 ethernet1/1
delete zone trust network layer3 ethernet1/1
commit force
```

Step3: Lösche die Zonen
```sh
configure 
delete zone Untrust
delete zone trust
commit force
```

Step4: Entbinde die interfaces von vwire
```sh
configure
set network interface ethernet ethernet1/1 layer3
set network interface ethernet ethernet1/3 layer3
commit
```

Überprüfe ob es funktioniert hat:
```sh
configure
show network interface ethernet ethernet1/1
show network interface ethernet ethernet1/1
exit
```
Du sollest layer3 hier sehen!

Jetzt können wir ethernet1/1 und ethernet1/2 für layer3 (networking) einstellen.

WAN
```sh
configure
set network interface ethernet ethernet1/1 layer3 dhcp-client enable yes
set network virtual-router default interface ethernet1/1
set zone untrust network layer3 ethernet1/1
```

LAN
```sh
configure
set network interface ethernet ethernet1/3 layer3 ip 10.10.200.1/24
set network virtual-router default interface ethernet1/3
set zone trust network layer3 ethernet1/3
commit
```

Zonen überprüfen:
```sh
configure
show zone trust
show zone Untrust
exit
show interface ethernet1/1
show Interface ethernet1/3
```

Das Interface auf ethernet1/1 soll DHCP als client benutzen um eine IP von der
DHCP der externen Fritzbox (Internet) anzufragen.

Virtual Router (VR) in Palto Alto ist eine Routing Instanz.
Sowol WAN als auch LAN werden in dieselbe routing Intanz,
die *default* Instanz gepackt. Dies erlaubt die Verbindung vom LAN ins WAN.


**Um die gui auf ethernet1/3 (LAN) verfügbar zu machen**
```sh
configure
set network interface ethernet ethernet1/3 layer3 interface-management-profile allow-ping-and-web
commit
```

**Network profiles**
Erstelle Objekt interface-management-profile:
```sh
configure
set network profiles interface-management-profile allow-gui ping yes
http yes https yes ssh yes
commit
```

Nutze das Profil fuer ethernet1/3
```sh
configure
set network interface ethernet ethernet1/3 layer3 interface-management-profile allow-gui
commit
```

## Interzone vs. Intrazone
Eine Interzone Regelung regelt die Kommunikation 
des Datenverkehrs innerhalb derselben Sicherheitszone.
Eine Interzone Regelung regelt die Kommunikation
des Datenverkehrs zwischen zwei Sicherheitszonen.

## Sessions
Eine TCP verbindung erstellt eine Session,
diese kann man nachschauen unter `show session all`

## DHCP state
Die Anzeige des DHCP-Status ermöglicht es uns zu sehen, welche IP-Adresse der DHCP-Client usw. erhalten hat.
`show dhcp client state ethernet1/1`
Wir sehen nun die IP-Adresse von Ethernet1/1 sowie des Gateways.
Damit können wir testen, ob die Firewall den Google-DNS-Server erreichen kann.
Die erhaltenen Werte:
IP: 192.168.0.25 (IP von eth1/1 vom DHCP der Fritzbox)
Gateway: 192.168.0.1 (externe Fritzbox)
`ping source 192.168.0.25 host 8.8.8.8`
-> Wir haben 64 Bytes von 8.8.8.8 erhalten, also besteht eine Verbindung.

## Routing Table
Um die Routing-Tabelle anzuzeigen, geben wir „show routing route“ ein.
Die Ausgabe ist eine Tabelle mit Ziel, Nexthop, Metrik,
Alter und Schnittstelle.


## Creating a policy from LAN into WAN
Um vom lokalen Netzwerk in das Weitverkehrsnetz zu gelangen, erstellen wir eine Richtlinie aus unserer Zone „Vertrauen“, die wir dem LAN (Ethernet 1/3) zugewiesen haben, und eine Richtlinie „Nicht vertrauen“, die wir dem WAN (Ethernet 1/1) zugewiesen haben.

## NAT - Network Adress Translation
Übersetzt Adressen eines Netzwerks N1, 
sodass sie für die Geräte in einem Netzwerk N2
ansprechbar sind. 

Unsere NAT soll eine SNAT sein, die die Adressen von trust
in untrust so übersetzt, das die Fritzbox sie erkennt.

## Access Point (Fritzbox)
Der Access Point ist eine Fritzbox. Standardmaessig dient diese 
als Router. Damit sie als Access Point agiert machen wir folgendes:

Heimnetz -> Netzwerk -> Netzwerkeinstellungen.
Betriebsart: IP-Client - per LAN
Verbindungseinstellungen:
IP-Adresse: 10.10.200.3
Subnetzmaske: 255.255.255.0
Standard-Gateway: 10.10.200.1
Primärer-DNS: 8.8.8.8

Fritzbox macht DHCP und vergiebt *leases*: Mietvertrag fuer IP's.
Problem: Fritzbox vergiebt als DNS sich selbst,
kann aber anscheinend nicht weiterleiten.
-> IP-Adressen erreichen das Internet, aber nicht domains!
-> Man müsste den DNS der Verbindungen manuell einstellen.

Problem: Fritzbox macht kein DHCP mehr 
(ging davor mit ip client aber Einstellung aufeinmal weg)

Loesung: Windows Server jetzt konfigurieren:
+ DHCP
+ DNS

## Installation DHCP
1. Rollen und Funktionen hinzufügen
2. Rollenbasierte oder funktionsbasierte Installation
3. DHCP-Server
4. DHCP-Konfiguration abschließen (Menü nach der Installation)
dann
### Konfiguration DHCP
starte dhcpmgmt.msc
-> IPv4 -> new Scope
Name: "LAN"
Bereich: 10.10.200.50 - 10.10.200.250
Subnetzmaske: 255.255.255.0
Gateway: 10.10.200.1 (Firewall)
DNS-Server: 10.10.200.4 (Windows-Server selbst)
Lease Time: 8h

## Installation DNS
1. Rollen und Funktionen hinzufügen
2. Rollenbasierte oder funktionsbasierte Installation
3. DNS-Server

### Konfiguration DNS
starte dnsmgmt.msc
->Rechtsklick Servername -> Properties -> Forwarders:
Eintragen: 8.8.8.8, 8.8.4.4, 1.1.1.1

Parent -> new primary zone "intranet.local"
Hängt an domains ohne top level domain:
azubi -> azubi.intranet.local (DNS suffix)

## Beschränkung auf Tagesschau

### Adresse erstellen
```sh
configure
set address TS fqdn tagesschau.de
set address TS-SUB fqdn www.tagesschau.de
commit
```

Die Firewall benötigt einen DNS für die fdqn-Auflösung.

Erlauben Sie zunächst alle konfigurierten DNS-Server:
Geht schneller über GUI -> Objekte -> Adressen

- 8.8.8.8 (GOOGLE-DNS)
- 8.8.4.4 (GOOGLE-DNS-FALLBACK)
- 1.1.1.1 (CLOUDFLARE)

Wir müssen einige Dinge tun:
->Gerät->Dienste
DNS mit dem Rad auf 10.10.200.4 einstellen
->Dienstroutenkonfiguration
DNS konfigurieren:
Quellschnittstelle Ethernet1/3, Quelladresse 10.10.200.1/24
Gehen Sie dann zu Ziel und geben Sie 10.10.200.4 als Ziel ein.

Richtlinie aktualisieren!

Zu diesem Zeitpunkt ist die einzige Website, die Sie besuchen können, tagesschau.de!
-> Damit sind wir mit den formalen Anforderungen fertig

## Intranet


