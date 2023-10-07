---
categories:
- Guides
date: "2022-05-06T00:00:00Z"
tags:
- Packer
- WSL
- Virtualization
title: 'Packer on WSL: Just Use Linux'
---
# Figuring It All Out
Consider you have the following needs/limitations:
- A Windows host
- A desire to use [Packer](https://www.packer.io/) to build Windows VMs
- A desire to use [Ansible](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html) to provision Windows VMs
- No support for nested virtualization

In my personal case, I'm using a Windows 10 Home edition which lacks certain virtualization features you might find in the Pro version (like running Hyper-V). So I'm using [VirtualBox](https://www.virtualbox.org/) as the hypervisor. I also have Ubuntu running on WSL.

Ready to get started, I installed `packer` and `ansible`. I know Packer directly calls `VBoxManage.exe` (Windows) or `vboxmanage` (Linux) underneath, and that was installed on my Windows side. I verified I could see it in WSL:
```console
braheezy@homebase:~/windows-pipeline$ VBoxManage.exe --version
6.1.32r149290
```
Nice! Microsoft's [promise](https://docs.microsoft.com/en-us/windows/wsl/filesystems#interoperability-between-windows-and-linux-commands) holds up. Indeed, we can see in it our path:
```console
braheezy@homebase:~/windows-pipeline$ echo $PATH
blahblahblah:/mnt/c/Program Files/Oracle/VirtualBox
```
To get on the same page, here's what the working directory looks like.
```console
braheezy@homebase:~/windows-pipeline$ ls
floppy  template.pkr.hcl  windows10.iso
```
- `floppy/`: Directory of files Packer will upload as a floppy drive to help bootstrap Windows
- `template.pkr.hcl`: The Packer template
- `windows10.iso`: The Windows 10 install disc

Cool. Let's invoke the `packer build` command and see what happens.
```console
braheezy@homebase:~/windows-pipeline$ packer build template.pkr.hcl
virtualbox-iso.test: output will be in this color.

Build 'virtualbox-iso.test' errored after 43 milliseconds 621 microseconds: Failed creating VirtualBox driver: exec: "VBoxManage": executable file not found in $PATH

==> Wait completed after 43 milliseconds 753 microseconds

==> Some builds didn't complete successfully and had errors:
--> virtualbox-iso.test: Failed creating VirtualBox driver: exec: "VBoxManage": executable file not found in $PATH

==> Builds finished but no artifacts were created.
```
Oh...Fine. Let's create a symlink and trick `packer` into calling the executable.
```console
braheezy@homebase:~/windows-pipeline$ sudo ln -s /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe /usr/local/bin/VBoxManage

braheezy@homebase:~/windows-pipeline$ packer build template.pkr.hcl
==> virtualbox-iso.test: Retrieving ISO
==> virtualbox-iso.test: Trying windows10.iso
==> virtualbox-iso.test: Trying windows10.iso?checksum=md5%3A3e62ce57edcad33f89f1edb4f55fe24a
==> virtualbox-iso.test: windows10.iso?checksum=md5%3A3e62ce57edcad33f89f1edb4f55fe24a => /home/braheezy/z_drive/windows-pipeline/windows10.iso
==> virtualbox-iso.test: Creating floppy disk...
    virtualbox-iso.test: Copying files flatly from floppy_files
    virtualbox-iso.test: Copying directory: floppy
    virtualbox-iso.test: Adding file: floppy/Autounattend_bios.xml
    virtualbox-iso.test: Adding file: floppy/Autounattend_efi.xml
    virtualbox-iso.test: Adding file: floppy/ConfigureRemotingForAnsible.ps1
    virtualbox-iso.test: Adding file: floppy/fixnetwork.ps1
    virtualbox-iso.test: Done copying files from floppy_files
    virtualbox-iso.test: Collecting paths from floppy_dirs
    virtualbox-iso.test: Resulting paths from floppy_dirs : []
    virtualbox-iso.test: Done copying paths from floppy_dirs
    virtualbox-iso.test: Copying files from floppy_content
    virtualbox-iso.test: Done copying files from floppy_content
==> virtualbox-iso.test: Creating ephemeral key pair for SSH communicator...
==> virtualbox-iso.test: Created ephemeral SSH key pair for communicator
==> virtualbox-iso.test: Creating virtual machine...
==> virtualbox-iso.test: Creating hard drive output-test/packer-test-1651809462.vdi with size 40000 MiB...
==> virtualbox-iso.test: Mounting ISOs...
==> virtualbox-iso.test: Deleting any current floppy disk...
==> virtualbox-iso.test: Attaching floppy disk..
==> virtualbox-iso.test: Creating forwarded port mapping for communicator (SSH, WinRM, etc) (host port 3288)
==> virtualbox-iso.test: Starting the virtual machine...
==> virtualbox-iso.test: Waiting 5s for boot...
==> virtualbox-iso.test: Typing the boot command...
==> virtualbox-iso.test: Using WinRM communicator to connect: 127.0.0.1
==> virtualbox-iso.test: Waiting for WinRM to become available...
```
Success! At least for Packer. Here's hoping the answer file is correct...

# Other Failures
On my Windows computer, I have a `C:` drive on one physical SSD and another `Z:` drive on a different physical SSD. The `Z:` drive usually holds development projects, including the `windows-pipeline` project above originally.

VirtualBox did not like all this nonsense with different drive letters and WSL. It threw errors like this:

```
==> virtualbox-iso.test: Error attaching ISO: VBoxManage error: VBoxManage.exe: error: Could not find file for the medium 'Z:\mnt\z\windows-pipeline\windows10.iso' (VERR_PATH_NOT_FOUND)
```
Agreed, that path does not exist.

Even after doing more "tricks" to get VirtualBox to see the ISO, it would later fail to find the `floppy.vfd` that Packer had made  in the `/tmp` directory. This led me down the roundabout rabbit hole of finding/modifying this [script](https://github.com/braheezy/wsl-virtualbox) and eventually I getting everything to work on my beloved `Z:` drive. But all I had to do the whole time was copy it somewhere to the local WSL filesystem.

Due to terrible performance of the Windows VM, I thought about setting up GPU passthrough to give it a boost. That research let me find out it's impossible to do that on my Windows 10 Home computer and subsequently, re-installing Linux to that second SSD.

And so ends a naive attempt at virtualization at home with Windows. Just use Linux.
