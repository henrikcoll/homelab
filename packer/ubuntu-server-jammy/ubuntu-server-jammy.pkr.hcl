# Ubuntu Server jammy

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "github_repository" {
    type = string
    sensitive = true
}



source "proxmox" "ubuntu-server-jammy" {
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    
    node = "pve"
    vm_id = "900"
	pool = "templates"
    vm_name = "ubuntu-server-jammy"
    template_description = "Ubuntu Server Jammy Jellyfish"

    iso_file = "local:iso/ubuntu-22.04-live-server-amd64.iso"
    iso_storage_pool = "local"
    unmount_iso = true

    qemu_agent = true

    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "20G"
        format = "qcow2"
        storage_pool = "local-lvm"
        storage_pool_type = "lvm"
        type = "virtio"
    }

    cores = "2"
    
    memory = "2048" 

    network_adapters {
        model = "virtio"
        bridge = "vmbr1"
        firewall = "false"
    } 

    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=https://raw.githubusercontent.com/",
		var.github_repository,
		"/main/packer/ubuntu-server-jammy/http/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "10s"

    ssh_username = "administrator"
    ssh_password = "administrator"

    ssh_timeout = "20m"
}

build {

    name = "ubuntu-server-jammy"
    sources = ["source.proxmox.ubuntu-server-jammy"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt-get -y autoremove --purge",
            "sudo apt-get -y clean",
            "sudo apt-get -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}
