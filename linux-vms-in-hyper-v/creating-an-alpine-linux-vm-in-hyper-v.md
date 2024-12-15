# Linux VMs in Hyper-V

Hyper-V supports the creation and running of Linux as well as Windows VMs. This directory documents the important practices for running Linux VMs on Hyper-V as well as some scripts to make running VMs easier.

## VM Switch

Any VM you create will need network access. In Hyper-V, this means creating a *VM Switch* that the VM will be connected to. There are three types of VM switches in Hyper-V:

- **External** - This is the switch type you will use most often.  This links the VM Switch (and all the VMs connected to it) the a network card on the host and enabled VMs to have network access to the host, your local network, and the Internet.
- **Internal** - This switch type enables VMs to talk to each other and to the Hyper-V host.
- **Private** - VMs can only talk to each other but cannot talk to the Hyper-V host of the network.  This is used when you need a completely isolated VM network

Typically, setting up a VM Switch is a one time activity when you start using Hyper-V on a machine.  You will most likely create a, *External* VM Switch linked to your network adapter so your VMs can talk to your network and the Internet.

To create a VM switch, you will need the name of the Network Adapter to attach the switch to.  You can find this using the PowerShell [`Get-NetAdapter`](https://learn.microsoft.com/en-us/powershell/module/netadapter/get-netadapter) cmdlet and looking at the *Name* column.

```PowerShell
Get-NetAdapter
```

You can then create a VM switch using the [`New-VMSwitch`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/new-vmswitch) cmdlet. By specifying the `-NetAdapterName`, Hyper-V automatically creates the VM switch as an *External* VM switch.

```PowerShell
New-VMSwitch "vm-switch" -NetAdapterName "Ethernet"
```

To list the VM switches, use the [`Get-VMSwitch`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/get-vmswitch) cmdlet.

```PowerShell
Get-VMSwitch
```

## Hard Disk Block Size

One of ***the most important things to do*** when creating Linux VMs on Hyper-V is to set the block size correctly for virtual hard disk (VHDX) files.  Failure to set the block size correctly and just using the default will result in VHDX sizes that are much larger than they should be.  This is explained in detail in the article [Best Practices for Running Linux on Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/best-practices-for-running-linux-on-hyper-v) on Microsoft Learn.

The most important implication of this is that you ***cannot*** use the Hyper-V GUI to create hard disks for Linux machines becasue there is no mechanism to override the default block size in the UI, either in the *New Virtual Machine* wizard or *New Virtual Hard Disk* wizard. This means ***you must*** use PowerShell to create your VHDX files for Linux VMs.  

My preferred approach to creating Linux VMs in Hyper-V is to:

- Create the VM without a hard disk
- Create a VHDX file using PowerShell
- Attach the VHDX to the VM
- Boot the VM and install the operating system of choice

To create a VHDX file using PowerShell, use the [`New-VHD`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/new-vhd) cmdlet.  In this command, Microsoft reccomends setting the BlockSizeBytes value to `1MB`.

```PowerShell
New-VHD -Path $VhdxFileName -SizeBytes 127GB -Dynamic -BlockSizeBytes 1MB
```

This VHDX can now be attached to a VM in the Hyper-V GUI or via PowerShell

```PowerShell
Add-VMHardDiskDrive -VMName $VmName -Path $VhdxFileName -ControllerType SCSI -ControllerNumber 0
```

## VM Creation Script

The script [`Create-VirtualMachine.ps1`](./Create-VirtualMachine.ps1) in this folder is intended to make creating VMs in PowerShell easier by bringing together all the needed cmdlets into a single script.  This script will:

- Create the directory for the VM files
- Create the VM with the appropriate number of CPUs and memory
- Create 1-4 VHDX files for the VVM with the correct block size depending on the OS and add them to the VM
- Add a DVD drive to the VM and optionally mount an ISO file in that VM
- Attach the VM to the specified VM switch

The script takes the following parameters:

| **Parameter**   | **Required** | **Default Value**             | **Description**                                                   |
|-----------------|:------------:|-------------------------------|-------------------------------------------------------------------|
| `VmName`        | Yes          |                               | Name of the Virtual Machine                                       |
| `BasePath`      | No           | `C:\hyper-v\virtual-machines` | The folder where the directory for the VM will be created.        |
| `CpuCount`      | No           | 2                             | The number of CPUs to give the VM.                                |
| `Memory`        | No           | 2 GB                          | The amount of memory for the virtual machine                      |
| `VmSwitchName`  | Yes          |                               | The name of the network switch to connect the VM to               |
| `VhdxSizes`     | No           | 60 GB                         | An array of the hard disk sizes to create.  To create a VM with a 60GB and 120GB hard drive, pass the value `@(60GB,120GB)` to this parameter |
| `OS`            | Yes          |                               | Either `Windows` or `Linux`.  This parameter will set the correct block size for Linux hard drives (1 MB0 and name the VHDX files appropriately for the operating system) |
| `IsoFilePath`   | No           |                               | The path of the ISO file to mount to the DVD of the VM.           |
