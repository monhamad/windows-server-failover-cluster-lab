# Architecture de l'environnement

## 1. Vue d'ensemble

Le projet consiste à mettre en place une infrastructure de haute disponibilité sous **Windows Server 2022** dans un environnement virtualisé avec **VMware Workstation**.

L'infrastructure repose sur :

- un contrôleur de domaine et serveur DNS ;
- deux nœuds de cluster ;
- un serveur de stockage iSCSI ;
- une machine virtuelle modèle ;
- un Failover Cluster ;
- un rôle de serveur de fichiers clusterisé.

Le domaine Active Directory utilisé est :

`itintegration.local`

---

## 2. Machines virtuelles

L'environnement comprend cinq machines virtuelles.

| Machine | Fonction | Adresse IP |
|---|---|---|
| `DC01` | Contrôleur de domaine et DNS | `192.168.10.10` |
| `NODE1` | Nœud du cluster | `192.168.10.11` |
| `NODE2` | Nœud du cluster | `192.168.10.12` |
| `STORAGE` | Serveur de stockage iSCSI | `192.168.10.20` |
| `WIN2022-TEMPLATE` | Machine modèle | — |

Les deux nœuds `NODE1` et `NODE2` constituent le Failover Cluster.

---

## 3. Ressources clusterisées

### 3.1 Cluster

Le cluster est nommé :

`CLUSTER01`

Son adresse IP est :

`192.168.10.13`

Le cluster regroupe :

- `NODE1`
- `NODE2`

Les deux nœuds peuvent héberger le rôle de serveur de fichiers.

### 3.2 Serveur de fichiers clusterisé

Le rôle de serveur de fichiers est nommé :

`FILESERVER`

Son adresse IP virtuelle est :

`192.168.10.14`

L'utilisateur accède au service à travers le nom réseau `FILESERVER`, indépendamment du nœud qui héberge actuellement le rôle.

---

## 4. Réseaux

Deux réseaux principaux sont utilisés dans l'environnement.

### 4.1 Réseau principal

Le réseau principal utilise le sous-réseau :

`192.168.10.0/24`

Il permet notamment :

- la communication avec le contrôleur de domaine ;
- la communication avec le serveur de stockage ;
- les communications générales de l'infrastructure ;
- l'accès aux services par les clients.

### 4.2 Réseau Heartbeat

Le réseau dédié à la communication entre les nœuds utilise :

`10.0.0.0/24`

Les adresses sont :

| Nœud | Adresse Heartbeat |
|---|---|
| `NODE1` | `10.0.0.11` |
| `NODE2` | `10.0.0.12` |

Ce réseau est utilisé pour la communication interne entre les nœuds du cluster et le heartbeat.

---

## 5. Active Directory et DNS

Le contrôleur de domaine `DC01` fournit les services :

- Active Directory Domain Services ;
- DNS.

Le domaine utilisé est :

`itintegration.local`

Les nœuds `NODE1` et `NODE2` sont membres du domaine.

Le serveur DNS utilisé par les nœuds est :

`192.168.10.10`

La communication avec le contrôleur de domaine et la résolution du domaine ont été vérifiées depuis les nœuds.

---

## 6. Stockage partagé iSCSI

Le stockage partagé est fourni par le serveur :

`STORAGE`

Un second disque de 30 Go a été ajouté au serveur.

Il a été :

- initialisé en GPT ;
- formaté en NTFS ;
- attribué à la lettre `E:`;
- nommé `ISCSI`.

### Disque virtuel iSCSI

Un disque virtuel iSCSI de 20 Go a été créé avec le chemin :

`E:\iscsivirtualdisk\ClusterData.vhdx`

Le disque a été configuré en taille fixe.

### Cible iSCSI

La cible iSCSI est nommée :

`clusterdatatarget`

Les deux nœuds du cluster ont été autorisés à accéder à cette cible à partir de leurs IQN.

`NODE1` :

`iqn.1991-05.com.microsoft:node1.itintegration.local`

`NODE2` :

`iqn.1991-05.com.microsoft:node2.itintegration.local`

Le protocole CHAP n'a pas été utilisé dans cette configuration de laboratoire.

---

## 7. Intégration du stockage au cluster

Une fois le disque iSCSI connecté aux deux nœuds, il a été intégré au Failover Cluster.

Il apparaît dans le cluster sous le nom :

`Disque de cluster 1`

Le disque a ensuite été préparé pour être utilisé par le rôle de serveur de fichiers.

Le volume créé sur le disque partagé est :

`FILEDATA`

Le volume :

- utilise le système de fichiers NTFS ;
- possède une capacité d'environ 20 Go ;
- utilise la lettre de lecteur `F:`.

Le chemin utilisé pour les données du serveur de fichiers est :

`F:\Shares\DATA`

---

## 8. Quorum et File Share Witness

Le cluster utilise un **File Share Witness** pour son mécanisme de quorum.

Le témoin est configuré sur `DC01`.

Le dossier utilisé est :

`C:\ClusterWitness`

Le partage réseau correspondant est :

`\\DC01\ClusterWitness`

Le compte ordinateur du cluster :

`CLUSTER01$`

a reçu les permissions nécessaires sur le dossier et le partage.

La configuration du quorum s'est terminée avec succès.

---

## 9. Serveur de fichiers SMB

Le rôle `FILESERVER` utilise le volume partagé :

`FILEDATA`

Le chemin local utilisé pour les données est :

`F:\Shares\DATA`

Un partage SMB nommé :

`DATA`

a été créé.

Son chemin réseau est :

`\\FILESERVER\DATA`

La fonctionnalité **Continuous Availability** a été activée afin de favoriser la continuité du partage lors des opérations de basculement.

---

## 10. Fonctionnement du basculement

Le principe de fonctionnement est le suivant :

1. `NODE1` et `NODE2` appartiennent au cluster `CLUSTER01`.
2. Le stockage partagé `FILEDATA` est accessible par le cluster.
3. Le rôle `FILESERVER` peut être hébergé par `NODE1` ou `NODE2`.
4. Les utilisateurs accèdent au service à travers `\\FILESERVER\DATA`.
5. En cas de déplacement manuel du rôle, le cluster transfère le rôle vers l'autre nœud.
6. En cas de défaillance du nœud hébergeant le rôle, le cluster effectue automatiquement le basculement vers le nœud disponible.
7. Le partage et les données restent accessibles après le basculement.

---

## 11. Schéma d'architecture

![Architecture de l'environnement](../architecture/architecture.png)

---

## 12. Résumé de l'architecture

| Élément | Configuration |
|---|---|
| Domaine | `itintegration.local` |
| Contrôleur de domaine | `DC01` |
| Nœud 1 | `NODE1` — `192.168.10.11` |
| Nœud 2 | `NODE2` — `192.168.10.12` |
| Serveur iSCSI | `STORAGE` — `192.168.10.20` |
| Cluster | `CLUSTER01` — `192.168.10.13` |
| Rôle de fichiers | `FILESERVER` — `192.168.10.14` |
| Volume partagé | `FILEDATA` — ~20 Go |
| Partage SMB | `\\FILESERVER\DATA` |
| Witness | `\\DC01\ClusterWitness` |
| Réseau principal | `192.168.10.0/24` |
| Réseau Heartbeat | `10.0.0.0/24` |
