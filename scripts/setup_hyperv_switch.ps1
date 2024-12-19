<#
.SYNOPSIS
    Hyper-V network switch selector and IP updater for Ubuntu VM.

.REQUIREMENTS
    - Windows OS with Hyper-V enabled
    - Hyper-V PowerShell module
    - SSH config file at $HOME\.ssh\config
    - $vmName must exist
#>

Import-Module Hyper-V

# Define the VM name
$vmName = "ubuntu-server"

# Verify requirements
if (-not (Get-Module -ListAvailable -Name Hyper-V)) {
    Write-Error "Hyper-V PowerShell module not found."
    exit 1
}

if (-not (Get-VM -Name $vmName -ErrorAction SilentlyContinue)) {
    Write-Error "VM '$vmName' not found. Please verify the VM name."
    exit 1
}

# List available network switches
$vmSwitches = Get-VMSwitch | Select-Object -Property Id, Name

# Display available switches with numbered options
Write-Output "Available Network Switches:"
for ($i = 0; $i -lt $vmSwitches.Count; $i++) {
    Write-Output "$($i + 1) - $($vmSwitches[$i].Name)"
}

# Prompt user to choose a switch by entering the option number
$switchOption = Read-Host "Enter the number of the network switch to use"

# Validate user input
if ($switchOption -match '^\d+$' -and $switchOption -gt 0 -and $switchOption -le $vmSwitches.Count) {
    $selectedSwitch = $vmSwitches[$switchOption - 1]
    Write-Output "You selected: $($selectedSwitch.Name)"
} else {
    Write-Output "Invalid selection. Exiting..."
    exit
}

# Apply the selected switch to the VM's network adapter
try {
    Connect-VMNetworkAdapter -VMName $vmName -SwitchName $selectedSwitch.Name
    Write-Output "Successfully connected VM '$vmName' to switch '$($selectedSwitch.Name)'."
} catch {
    Write-Output "Failed to connect VM '$vmName' to switch '$($selectedSwitch.Name)'. Error: $_"
    exit
}

# Continuously scan for the VM's IPv4 address
$sshConfigFile = "$HOME\.ssh\config"
$foundIp = $false

Write-Output "Scanning for the new IPv4 address..."

while (-not $foundIp) {
    $vmNetworkAdapter = Get-VMNetworkAdapter -VMName $vmName
    $ipv4Addresses = $vmNetworkAdapter.IPAddresses | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}$' }

    if ($ipv4Addresses) {
        Write-Output "New IPv4 address found: $ipv4Addresses."

        # Update the IP address in the SSH config file
        if (Test-Path -Path $sshConfigFile) {
            $configContent = Get-Content -Path $sshConfigFile
            $updatedConfig = $configContent -replace '(\s\sHostName)\s\d{1,3}(\.\d{1,3}){3}', "`$1 $ipv4Addresses"
            Set-Content -Path $sshConfigFile -Value $updatedConfig
            Write-Output "Updated IP address in SSH config file."
        } else {
            Write-Output "SSH config file not found. Unable to update."
        }

        $foundIp = $true
    } else {
        Start-Sleep -Seconds 5  # Wait for 5 seconds before checking again
    }
}

Write-Output "Script completed."
