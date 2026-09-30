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

The laboratory consists of five virtual machines:

| Server | Role | IP Address |
|---|---|---|
| `DC01` | Active Directory / DNS | `192.168.10.10` |
| `NODE1` | Cluster Node | `192.168.10.11` |
| `NODE2` | Cluster Node | `192.168.10.12` |
| `STORAGE` | iSCSI Storage Server | `192.168.10.20` |
| `CLUSTER01` | Failover Cluster | `192.168.10.13` |
| `FILESERVER` | Clustered File Server | `192.168.10.14` |

The Active Directory domain used in the laboratory is:

```text
itintegration.local
Network configuration

Two networks are used by the cluster nodes:

Network	Subnet	Purpose
LAN	192.168.10.0/24	Management, domain communication and client access
Heartbeat	10.0.0.0/24	Cluster communication and node heartbeat

The heartbeat interfaces are configured as follows:
