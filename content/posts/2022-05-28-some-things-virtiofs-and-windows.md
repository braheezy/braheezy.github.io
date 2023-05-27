---
categories:
- Guides
date: "2022-05-28T22:49:38Z"
tags:
- QEMU
- Virtualization
title: Some Things Virtiofs and Windows
---
This post hopes to explain how to enable a shared folder with a Windows guest on Libvirt/QEMU using Virtiofs.

An official [Windows Guide](https://virtio-fs.gitlab.io/howto-windows.html) is provided that generally covers everything needed. This post has snippets that help automate the process.

## Virtiofs
A newer approach to shared file systems between virtual machines and hosts. From the [main site](https://virtio-fs.gitlab.io/):

>  Virtiofs is a shared file system that lets virtual machines access a directory tree on the host. Unlike existing approaches, it is designed to offer local file system semantics and performance.
>
> Virtiofs was started at Red Hat and is being developed in the Linux, QEMU, FUSE, and Kata Containers open source communities.

I liked the idea of a dedicated solution instead of network based ones like NFS or Samba that have historically been repurposed for such things. Plus the boast of better performance.

There are minimum requirements for a host computer to use Virtiofs:

| Software | Version | Check Method         |
| -------- | ------- | -------------------- |
| Linux    | 5.4     | `uname -r`           |
| QEMU     | 5.0     | `qemu-kvm --version` |
| Libvirt  | 6.2     | `libvirtd --version` |

## How To Setup Virtiofs on Windows
We'll install some tools to the Windows guest and then configure the VM to use the shared filesystem.

### WinFsp
As explained in [Windows Guide](https://virtio-fs.gitlab.io/howto-windows.html), [WinFsp](https://winfsp.dev/) is needed inside the guest.

Download and install the application.

**PowerShell**
```powershell
PS C:\> Invoke-WebRequest https://github.com/winfsp/winfsp/releases/download/v1.10/winfsp-1.10.22006.msi -OutFile winfsp-1.10.22006.msi
PS C:\> winfsp-1.10.22006.msi /qn /norestart
```

**Ansible**
```yaml
- name: Check services
  win_service:
    name: WinFsp.Launcher
  register: winfspservice_result

- name: Install winfsp
  block:
    - name: Download winfsp
      win_get_url:
        url: "https://github.com/winfsp/winfsp/releases/download/v1.10/winfsp-1.10.22006.msi"
        dest: "{{ ansible_env.TEMP }}\\winfsp-1.10.22006.msi"

    - name: Install winfsp
      win_package:
        path: "{{ ansible_env.TEMP }}\\winfsp-1.10.22006.msi"
        state: present

  when: winfspservice_result.state is not defined or winfspservice_result.name is not defined
```

### Viofs Driver and Service
The virtual filesystem is attached to the guest as device so a proper driver is required.

VirtIO drivers for Windows deserve their own post. I'll quickly point out the ISO containing everything can be downloaded from [the Github](https://github.com/virtio-win/virtio-win-pkg-scripts) page and that it needs to be mounted somewhere so you can grab the `viofs` drivers within.

Assuming it's been mounted on the `D:` drive in the Windows VM, install the driver:
```
PS C:\> pnputil /install /add-driver D:\viofs\w10\amd64\viofs.inf
```

Let's also install the `virtiofs.exe` service.

**PowerShell**
```powershell
PS C:\> cp D:\viofs\w10\amd64\virtiofs.exe C:\Windows\virtiofs.exe

PS C:\> New-Service -Name "VirtioFsSvc" -BinaryPathName "C:\Windows\virtiofs.exe" -DisplayName "Virtio FS Service" -Description "Enables Windows virtual machines to access directories on the host that have been shared with them using virtiofs." -StartupType Automatic -DependsOn "WinFsp.Launcher"
```

**Ansible**
```yaml
- name: Create virtiofs service
  win_service:
    name: VirtioFsSvc
    path: C:\Windows\virtiofs.exe
    description: Enables Windows virtual machines to access directories on the host that have been shared with them using virtiofs.
    display_name: Virtio FS Service
    start_mode: auto
    dependencies:
      - WinFsp.Launcher
```

### Define Synced Folder
As of this writing, it seems you can only share 1 folder at a time. If you define multiple, it appears to use the one is defined last.

**Manual method**:
* In virt-manager, in the details section for the Windows guest, click **Add Hardware**.
* Choose **Filesystem** and supply a **Source path** and **Target path**.

The XML snippet should look something like this:
```xml
<filesystem type="mount" accessmode="passthrough">
  <driver type="virtiofs"/>
  <binary path="/usr/libexec/virtiofsd"/>
  <source dir="/tmp"/>
  <target dir="tmp"/>
  <address type="pci" domain="0x0000" bus="0x07" slot="0x00" function="0x0"/>
</filesystem>
```

The virt-manager GUI interface may not offer the ability to set the `passthrough` as an access mode, or to set `driver` and `binary` information for `virtiofs`. The XML can be manually edited with these settings.

**Vagrant (automated) way**:
* You'll need the [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt) plugin.
* The virtiofs blurb in the [synced folders](https://github.com/vagrant-libvirt/vagrant-libvirt#synced-folders) section of the documentation should work.

  ```ruby
  config.vm.provider :libvirt do |l, override|
    l.driver = "kvm"
    ...

    l.memorybacking :access, :mode => "shared"
    override.vm.synced_folder ".", "/vagrant", disabled: false, type: "virtiofs"

    ...
  end
  ```

If everything is working, you'll find a new mapped drive for your shared folder.