# ============================================================
# Windows Server 2022 Failover Cluster Lab
# Cluster verification script
# ============================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Windows Server Failover Cluster - Check " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 1. Cluster
# ------------------------------------------------------------

Write-Host "=== CLUSTER ===" -ForegroundColor Yellow

try {
    Get-Cluster | Select-Object Name
}
catch {
    Write-Host "Unable to retrieve cluster information." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# 2. Cluster nodes
# ------------------------------------------------------------

Write-Host "=== CLUSTER NODES ===" -ForegroundColor Yellow

try {
    Get-ClusterNode |
        Select-Object Name, State, NodeWeight |
        Format-Table -AutoSize
}
catch {
    Write-Host "Unable to retrieve cluster nodes." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# 3. Cluster roles
# ------------------------------------------------------------

Write-Host "=== CLUSTER ROLES ===" -ForegroundColor Yellow

try {
    Get-ClusterGroup |
        Select-Object Name, State, OwnerNode |
        Format-Table -AutoSize
}
catch {
    Write-Host "Unable to retrieve cluster roles." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# 4. Cluster resources
# ------------------------------------------------------------

Write-Host "=== CLUSTER RESOURCES ===" -ForegroundColor Yellow

try {
    Get-ClusterResource |
        Select-Object Name, ResourceType, State, OwnerGroup |
        Format-Table -AutoSize
}
catch {
    Write-Host "Unable to retrieve cluster resources." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# 5. Cluster networks
# ------------------------------------------------------------

Write-Host "=== CLUSTER NETWORKS ===" -ForegroundColor Yellow

try {
    Get-ClusterNetwork |
        Select-Object Name, Address, AddressMask, Role, State |
        Format-Table -AutoSize
}
catch {
    Write-Host "Unable to retrieve cluster networks." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# 6. Volumes
# ------------------------------------------------------------

Write-Host "=== VOLUMES ===" -ForegroundColor Yellow

try {
    Get-Volume |
        Where-Object {
            $_.FileSystem -eq "NTFS" -or
            $_.FileSystemLabel -eq "FILEDATA"
        } |
        Select-Object DriveLetter, FileSystemLabel, FileSystem, HealthStatus, Size |
        Format-Table -AutoSize
}
catch {
    Write-Host "Unable to retrieve volume information." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# 7. SMB share
# ------------------------------------------------------------

Write-Host "=== SMB SHARE ===" -ForegroundColor Yellow

try {
    Get-SmbShare -Name "DATA" -ErrorAction Stop |
        Select-Object Name, Path, Description |
        Format-Table -AutoSize
}
catch {
    Write-Host "SMB share DATA was not found on this server." -ForegroundColor Red
}

Write-Host ""

# ------------------------------------------------------------
# 8. Network connectivity
# ------------------------------------------------------------

Write-Host "=== NETWORK CONNECTIVITY ===" -ForegroundColor Yellow

$Targets = @(
    "DC01",
    "NODE1",
    "NODE2",
    "STORAGE",
    "FILESERVER"
)

foreach ($Target in $Targets) {

    $Result = Test-Connection -ComputerName $Target -Count 1 -Quiet -ErrorAction SilentlyContinue

    if ($Result) {
        Write-Host "$Target : OK" -ForegroundColor Green
    }
    else {
        Write-Host "$Target : FAILED" -ForegroundColor Red
    }
}

Write-Host ""

# ------------------------------------------------------------
# 9. SMB connectivity
# ------------------------------------------------------------

Write-Host "=== SMB CONNECTIVITY ===" -ForegroundColor Yellow

try {
    $SMBTest = Test-NetConnection -ComputerName "FILESERVER" -Port 445 -WarningAction SilentlyContinue

    if ($SMBTest.TcpTestSucceeded) {
        Write-Host "FILESERVER TCP/445 : OK" -ForegroundColor Green
    }
    else {
        Write-Host "FILESERVER TCP/445 : FAILED" -ForegroundColor Red
    }
}
catch {
    Write-Host "Unable to test SMB connectivity." -ForegroundColor Red
}

Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Verification completed." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
