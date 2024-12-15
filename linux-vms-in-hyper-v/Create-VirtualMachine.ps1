[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $VmName,

    [Parameter()]
    [String]
    $BasePath = "C:\hyper-v\virtual-machines",

    [Parameter()]
    [int]
    $CpuCount = 2,

    [Parameter()]
    [long]
    $Memory = 2GB,

    [Parameter()]
    [String]
    $VmSwitchName,

    [Parameter()]
    [ValidateCount(1,4)]
    [ValidateRange(10GB,1024GB)]
    [long[]]
    $VhdxSizes = @(60GB),

    [Parameter()]
    [ValidateSet('Linux','Windows')]
    $OS,

    [Parameter()]
    [String]
    $IsoFilePath
)

$ErrorActionPreference = 'Stop'

#--------------------------------------------------------------------------------------------------
#  Parameter Validation
#--------------------------------------------------------------------------------------------------

$CurrentVM = Get-Vm -Name $VmName -ErrorAction SilentlyContinue
if ($CurrentVM) {
    Write-Host "ERROR:" -ForegroundColor red -NoNewLine; Write-Host " A VM with the name $VMName already exists.  Exiting"
    exit 1
}

if ($CpuCount -gt [Environment]::ProcessorCount) {
    Write-Host "ERROR:" -ForegroundColor red -NoNewLine; Write-Host " Requested CPU count of $CpuCount greater than number of logical cores available ($([Environment]::ProcessorCount))"
    exit 2
}

# Make sure the switch name provided by the user exists
$CurrentSwitch = Get-VmSwitch -Name $VmSwitchName -ErrorAction SilentlyContinue    
if (-not $CurrentSwitch) {
    Write-Host "ERROR:" -ForegroundColor red -NoNewLine; Write-Host " A VM Switch with the name $VmSwitchName does not exist.  Exiting"
    exit 3
}

# If the user provided an iso file, make sure it exists
if ($IsoFilePath) {
    if ((-not ($IsoFilePath.EndsWith('.iso'))) -or (-not (Test-Path -Path $IsoFilePath))  ) {
        Write-Host "ERROR:" -ForegroundColor red -NoNewLine; Write-Host " The file $IsoFilePath does not exist or is not an ISO file"
        exit 4        
    }
}

#--------------------------------------------------------------------------------------------------
#  Directories
#--------------------------------------------------------------------------------------------------

# Create a VM name without spaces and all lower case - this is useful for directories and filenames
$SafeVmName = $VmName.ToLower().Replace(' ', '-')

# Make sure the Base Directory Exists
if ( -not (Test-Path -Path $BasePath)) {
    New-Item -Path $BasePath -ItemType Directory | Out-Null
}

# Now make sure a directory for the VM exists in the base directory
$VmFolderName = Join-Path -Path $BasePath -ChildPath $SafeVmName
if ( -not (Test-Path -Path $VmFolderName) ) {
    Write-Host "INFO:" -ForegroundColor yellow -NoNewLine; Write-Host "  Creating directory $VmFolderName for the VM"
    New-Item -Path $VmFolderName -ItemType Directory | Out-Null
}

#--------------------------------------------------------------------------------------------------
#  Create the VHDX File for the VM
#--------------------------------------------------------------------------------------------------

$VmParameters = @{
    Name = $VmName
    MemoryStartupBytes = $Memory
    SwitchName = $VmSwitchName
    Path = $VmFolderName
    Generation = 2
}
New-VM @VmParameters
Write-Host "INFO:" -ForegroundColor yellow -NoNewLine; Write-Host "  Creating virtual machine $VmName"

#--------------------------------------------------------------------------------------------------
#  Create the VHDX File for the VM
#--------------------------------------------------------------------------------------------------

# How we name the VHDX files depends on if it is Windows or Linux
# I like to give the VHDX file a name representitive of teh drive in the OS
if ($OS -eq 'Windows') { $DriveNames = @('c-drive', 'd-drive', 'g-drive', 'h-drive') } else { $DriveNames = @('sda', 'sdb', 'sdc', 'sdd') }

# For Linux, we need to set the block size at 1MB, otherwise Hyper-V wastes a lot of space and we fill up VHDX files fast
if ($OS -eq 'Windows') { $BlockSizeBytes = 32MB } else { $BlockSizeBytes = 1MB }

$ControllerNumber = 0
foreach ($Size in $VhdxSizes) {
    # VHDX filename will be of the form of vm-name-c-drive.vhdx for Windows or vm-name-sda-drive.vhdx for Linux
    $VhdxFileName = Join-Path -Path $VmFolderName -ChildPath "$SafeVmName-$($DriveNames[0]).vhdx"
    
    $VhdxParamaters = @{
        Path = $VhdxFileName
        SizeBytes = $Size
        Dynamic = $True
        BlockSizeBytes = $BlockSizeBytes    # Needs to be 1MB for Linux otherwise drives get very big
    }
    New-VHD @VhdxParamaters | Out-Null
    Add-VMHardDiskDrive -VMName $VmName -Path $VhdxFileName -ControllerType SCSI -ControllerNumber $ControllerNumber | Out-Null
    Write-Host "INFO:" -ForegroundColor yellow -NoNewLine; Write-Host "  Creating VHDX $VhdxFileName and added it to VM"

    $ControllerNumber++
}

#--------------------------------------------------------------------------------------------------
#  Add a DVD Drive to the VM
#--------------------------------------------------------------------------------------------------

if ($IsoFilePath) {
    Add-VMDvdDrive -VmName $VmName -Path $IsoFilePath
}
else {
    Add-VMDvdDrive -VmName $VmName
}

#--------------------------------------------------------------------------------------------------
#  Wrap up - CPU Count, Secure Boot, and Boot Order
#--------------------------------------------------------------------------------------------------

# Set the processor count and turn off automatic checkpoints
Set-Vm -VMName $VmName -ProcessorCount $CpuCount -AutomaticCheckpointsEnabled $False | Out-Null

# Turn off Secure Boot
Set-VMFirmware $VmName -EnableSecureBoot Off 

# Set Boot order to First HDD First, then DVD
$VmFirstHardDisk = Get-VMHardDiskDrive -VmName $VmName -ControllerType SCSI -ControllerNumber 0
$VmDvdDrive = Get-VMDvdDrive -VmName $VmName
Set-VMFirmware $VmName -BootOrder $VmFirstHardDisk, $VmDvdDrive
