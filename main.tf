resource "digitalocean_droplet" "wireguard" {
    count = var.amount_of_vms
    image  = var.image
    name   = "${var.name}-${format("%02s", count.index + 1)}"
    region = var.region
    size   = var.size
    ssh_keys = [
        var.ssh_key_fingerprint,
    ]

    provisioner "local-exec" {
        command = "echo The server's IP address is ${self.ipv4_address}"
    }

    connection {
        host = self.ipv4_address
        user = var.user
        type = var.type
        private_key = file(var.pvt_key)
        timeout = var.timeout
    }

    provisioner "file" {
        source = "wireguard.yml"
        destination = "/root/wireguard.yml"
    }

    provisioner "file" {
        source = "local_inventory"
        destination = "/root/local_inventory"
    }

    provisioner "remote-exec" {
        inline = var.use_local_ansible ? [
            "sudo apt update",
            "sudo apt install -y software-properties-common",
            "sudo add-apt-repository --yes --update ppa:ansible/ansible",
            "sudo apt install -y ansible",
            "ansible-playbook wireguard.yml -i local_inventory -c local",
        ] : [
            "echo done",
        ]
    }

    provisioner "local-exec" {
        command =  var.use_local_ansible ? "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.pvt_key} root@${self.ipv4_address}:/etc/wireguard/client.conf client-${format("%02s", count.index + 1)}.conf" : "echo done"
    }

    
    provisioner "remote-exec" {
        inline = var.use_local_ansible ? [
            "rm /etc/wireguard/client.conf",
        ] : [
            "echo done",
        ]
    }

}

resource "local_file" "ansible_inventory" {
    count = var.use_local_ansible ? 0 : 1
    content = templatefile("inventory.tmpl",
        {
            host_name = digitalocean_droplet.wireguard.*.ipv4_address
        }
    )
    filename = "inventory"
}