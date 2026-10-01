# Troubleshooting — Windows Server 2022 Failover Cluster

## Introduction

La mise en place du laboratoire a nécessité plusieurs opérations de diagnostic et de dépannage.

Cette page présente les principaux problèmes rencontrés pendant la configuration du cluster ainsi que les solutions appliquées.

Les problèmes sont présentés dans l'ordre général de leur apparition pendant la mise en œuvre.

---

## 1. Problème WMI — Erreur `0x80041014`

### Symptôme

Lors de certains contrôles liés au cluster, une erreur WMI `0x80041014` a été rencontrée.

Le namespace `root\MSCluster` était présent, mais certains éléments liés au fournisseur WMI du cluster ne répondaient pas comme attendu.

### Diagnostic

Plusieurs vérifications ont été effectuées afin de déterminer si le problème provenait de la connectivité ou de la configuration du cluster.

La connectivité WMI générale fonctionnait entre les machines.

Par exemple, une requête WMI générale vers `NODE1` a réussi.

Le port RPC `135` était également accessible.

### Cause identifiée

Le service **Failover Clustering** n'était pas encore opérationnel sur le nœud concerné.

Le service `ClusSvc` était initialement arrêté et désactivé sur une installation fraîche du nœud.

### Solution

La fonctionnalité **Failover Clustering** a été installée sur les nœuds.

Le service de cluster a ensuite été configuré afin de permettre la mise en place du cluster.

### Résultat

Après la poursuite de la configuration, le cluster `CLUSTER01` a pu être créé avec `NODE1` et `NODE2`.

---

## 2. Erreur de validation liée à Hyper-V

### Symptôme

La validation du cluster a signalé une erreur concernant la vérification de configurations d'équipe compatibles avec le commutateur.

### Diagnostic

Une vérification de la fonctionnalité Hyper-V a montré que celle-ci n'était pas installée sur les nœuds.

La validation faisait référence à des éléments liés à Hyper-V et à la virtualisation.

### Analyse

Cette vérification était liée à des fonctionnalités spécifiques à Hyper-V qui n'étaient pas nécessaires pour le fonctionnement du cluster de serveurs de fichiers mis en place dans ce laboratoire.

Le projet n'utilisait pas Hyper-V pour héberger les machines virtuelles : les machines étaient exécutées avec VMware Workstation.

### Solution

Cette erreur a été considérée comme non bloquante pour le scénario du laboratoire.

La configuration du cluster a donc été poursuivie avec VMware Workstation et les fonctionnalités nécessaires au Failover Cluster.

### Résultat

Le cluster a finalement été créé et fonctionnel malgré cette alerte de validation.

---

## 3. Erreur QFE `0x8024402C`

### Symptôme

La validation du cluster a également signalé une erreur QFE avec le code :

`0x8024402C`

### Analyse

Cette erreur était liée à la vérification de certains éléments Windows Update.

Elle ne concernait pas directement la configuration du stockage partagé, du réseau heartbeat ou du rôle `FILESERVER`.

### Solution

Cette erreur a été considérée comme indépendante du fonctionnement principal du cluster.

La configuration du cluster a donc été poursuivie.

### Résultat

Le cluster a pu être créé et les tests fonctionnels ont ensuite été réalisés avec succès.

---

## 4. Identification du serveur STORAGE

### Symptôme

Lors de la configuration du stockage iSCSI, le serveur de stockage n'était pas identifié comme prévu dans certaines étapes de configuration.

### Diagnostic

Le nom d'hôte du serveur n'avait pas encore été configuré correctement.

Le serveur devait être identifié comme :

`STORAGE`

### Solution

Le nom du serveur a été modifié afin d'utiliser :

`STORAGE`

Le serveur a ensuite été redémarré lorsque nécessaire.

### Résultat

Le disque de stockage et les fonctionnalités iSCSI ont ensuite pu être configurés correctement.

---

## 5. Service Microsoft iSCSI arrêté

### Symptôme

Lors de la configuration des connexions iSCSI sur `NODE1` et `NODE2`, le service Microsoft iSCSI n'était pas opérationnel.

### Service concerné

`MSiSCSI`

### Solution

Le service Microsoft iSCSI a été démarré sur les deux nœuds.

Il a également été configuré pour démarrer automatiquement avec Windows.

### Résultat

Les deux nœuds ont ensuite pu se connecter à la cible iSCSI :

`clusterdatatarget`

Les IQN des deux nœuds ont été autorisés sur la cible.

---

## 6. Problème lors du formatage du disque clusterisé

### Symptôme

Lors de la tentative de formatage du disque partagé directement avec PowerShell, l'opération a échoué avec une erreur liée au stockage WMI.

Le code rencontré était :

`41018`

### Analyse

Le disque était déjà intégré au Failover Cluster.

Il était donc géré par le cluster, ce qui empêchait certaines opérations directes de gestion du disque.

### Solution

Le disque a été placé temporairement en **mode maintenance du cluster** afin de permettre l'opération de formatage.

Le volume a ensuite été formaté en NTFS.

### Résultat

Le volume a été créé correctement avec :

`FILEDATA`

Le système de fichiers utilisé est :

`NTFS`

La capacité est d'environ :

`20 Go`

---

## 7. Attribution d'une lettre au volume FILEDATA

### Symptôme

Le volume `FILEDATA` avait été correctement créé mais ne possédait initialement pas de lettre de lecteur.

Cette situation posait problème lors de la création du rôle de serveur de fichiers, qui nécessitait un chemin local accessible.

### Solution

La lettre :

`F:`

a été attribuée au volume.

Le chemin utilisé pour les données du serveur de fichiers est devenu :

`F:\Shares\DATA`

### Résultat

Le rôle `FILESERVER` a ensuite pu être créé en utilisant le volume `FILEDATA`.

---

## 8. Vérification après dépannage

Après résolution des différents problèmes, plusieurs vérifications ont été effectuées.

### Cluster

Le cluster `CLUSTER01` fonctionnait avec :

- `NODE1`
- `NODE2`

Les deux nœuds étaient opérationnels.

### Stockage

Le volume partagé :

`FILEDATA`

était disponible dans le cluster.

### Serveur de fichiers

Le rôle :

`FILESERVER`

était opérationnel avec l'adresse :

`192.168.10.14`

### Partage SMB

Le partage :

`\\FILESERVER\DATA`

était accessible.

### Basculement

Le rôle `FILESERVER` a été déplacé manuellement entre les deux nœuds.

Un scénario de basculement automatique a également été testé en rendant indisponible le nœud qui hébergeait le rôle.

Dans les deux cas, le service de fichiers est resté accessible.

---

## Conclusion

Les difficultés rencontrées pendant la mise en œuvre ont principalement concerné la validation du cluster, les services Windows, la configuration iSCSI et la gestion du stockage clusterisé.

Le diagnostic progressif de ces problèmes a permis de poursuivre la configuration jusqu'à l'obtention d'une infrastructure fonctionnelle.

Cette phase de dépannage a également permis de vérifier les différents composants indépendamment avant de valider le fonctionnement global du cluster.
