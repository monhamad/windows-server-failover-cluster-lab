# Windows Server 2022 Failover Cluster Lab

## 📌 Overview

This project documents the design, deployment, configuration and testing of a high-availability infrastructure based on **Windows Server 2022**.

The laboratory environment was implemented using **VMware Workstation** and combines:

- Active Directory Domain Services (AD DS)
- DNS
- Windows Server Failover Clustering
- iSCSI shared storage
- File Share Witness
- SMB file server
- PowerShell administration
- Manual and automatic failover testing

The main objective is to provide a highly available file server whose services remain accessible when one of the cluster nodes becomes unavailable.

---

## 🏗️ Architecture

The laboratory consists of five virtual machines and two clustered resources.

| Server / Resource | Role | IP Address |
|---|---|---|
| `DC01` | Active Directory / DNS | `192.168.10.10` |
| `NODE1` | Cluster Node | `192.168.10.11` |
| `NODE2` | Cluster Node | `192.168.10.12` |
| `STORAGE` | iSCSI Storage Server | `192.168.10.20` |
| `CLUSTER01` | Failover Cluster | `192.168.10.13` |
| `FILESERVER` | Clustered File Server | `192.168.10.14` |

The Active Directory domain used in the laboratory is:

`itintegration.local`

### Network Configuration

Two networks are used by the cluster nodes:

| Network | Subnet | Purpose |
|---|---|---|
| LAN | `192.168.10.0/24` | Management, domain communication and client access |
| Heartbeat | `10.0.0.0/24` | Cluster communication and node heartbeat |

The heartbeat interfaces are configured as follows:

| Node | Heartbeat IP |
|---|---|
| `NODE1` | `10.0.0.11` |
| `NODE2` | `10.0.0.12` |

---

## 🔧 Technologies

- Windows Server 2022
- VMware Workstation
- Active Directory Domain Services
- DNS
- Failover Clustering
- iSCSI
- SMB
- PowerShell
- NTFS
- File Share Witness

---

## 🧩 Cluster Components

### Failover Cluster

The cluster is named:

`CLUSTER01.itintegration.local`

It contains two nodes:

- `NODE1`
- `NODE2`

Both nodes are configured to host the clustered file server role.

### Shared Storage

The cluster uses an iSCSI shared disk provided by:

`STORAGE`

The shared storage is presented to both cluster nodes and integrated into the Failover Cluster.

The cluster volume is:

`FILEDATA`

### Quorum

A **File Share Witness** is configured on `DC01`:

`\\DC01\ClusterWitness`

The witness contributes to quorum management and helps the cluster maintain an appropriate voting configuration.

### Clustered File Server

A clustered file server role named:

`FILESERVER`

is configured with the virtual IP address:

`192.168.10.14`

The SMB share is:

`\\FILESERVER\DATA`

The share uses the shared `FILEDATA` volume.

---

## 🧪 Tests Performed

Several tests were performed to verify the operation and availability of the infrastructure.

### Network Tests

- Connectivity between cluster nodes
- Connectivity with the domain controller
- DNS resolution
- Heartbeat network connectivity

### Cluster Tests

- Cluster validation
- Cluster node status
- Cluster network status
- Cluster storage status
- Cluster role status

### Storage Tests

- iSCSI target connectivity
- Shared disk visibility from both nodes
- Integration of the disk into the cluster
- Creation and formatting of the `FILEDATA` volume

### SMB Tests

The following share was tested:

`\\FILESERVER\DATA`

File creation and access were successfully tested through the clustered file server.

### Manual Failover

The `FILESERVER` role was manually moved from one node to the other.

The SMB share remained accessible after the role migration.

### Automatic Failover

A node hosting the `FILESERVER` role was made unavailable.

The cluster automatically transferred the role to the remaining node.

The SMB share remained available after the failover.

---

## 📊 Results

The laboratory successfully demonstrated the following:

- Two-node Windows Server failover cluster
- Shared iSCSI storage accessible by both nodes
- File Share Witness configuration
- Clustered SMB file server
- Manual role migration
- Automatic failover
- Continued access to the shared data after failover

The project provides a practical demonstration of high availability using native Windows Server technologies in a virtualized environment.

---

## 📚 Documentation

The repository contains the technical documentation, architecture diagrams, configuration screenshots, PowerShell scripts and troubleshooting notes.

### Technical Report

The complete technical report is available in:

`docs/rapport-technique.pdf`

### Architecture

Architecture documentation and diagrams are available in:

`architecture/`

`docs/`

### Screenshots

Configuration and testing screenshots are organized by topic:

`01-domain/`  
`02-cluster/`  
`03-iscsi/`  
`04-fileserver/`  
`05-tests/`

### PowerShell

PowerShell scripts used for configuration and verification are available in:

`powershell/`

### Troubleshooting

Problems encountered during the implementation and their solutions are documented in:

`troubleshooting/`

---

## 🎯 Learning Objectives

This project was carried out to develop practical skills in:

- Windows Server administration
- Active Directory and DNS
- High-availability infrastructure
- Failover Clustering
- Shared storage with iSCSI
- SMB file services
- Network configuration
- PowerShell administration
- Infrastructure troubleshooting
- Virtualized laboratory environments

---

## ⚠️ Disclaimer

This project was implemented in a virtualized laboratory environment using VMware Workstation.

It is intended for **educational, testing and demonstration purposes** and does not represent a production deployment.

---

## 👤 Author

**Monhamad**

GitHub:

`https://github.com/monhamad`
