variable "search" { default = "/\\[(.*)\\]/" }

output "names" {
  value = openstack_compute_instance_v2.node.*.name
}

output "ipv4_addr" {
  value = openstack_compute_instance_v2.node.*.access_ip_v4
}

output "ipv6_addr" {
  value = [
    for node in openstack_compute_instance_v2.node :
    replace(node.access_ip_v6, var.search, "$1")
  ]
}

output "network_uuid" {
  value = openstack_compute_instance_v2.node.*.network.0.uuid
}

output "id" {
  value = openstack_compute_instance_v2.node.*.id
}


data "template_file" "ansible_host_v6" {
  template = "$${hostname} ansible_host=$${ip} ansible_ssh_user=$${user}"
  count    = var.node_count
  vars = {
    ip = replace(
      element(
        openstack_compute_instance_v2.node.*.access_ip_v6,
        count.index,
      ),
      var.search,
      "$1",
    )
    hostname = element(openstack_compute_instance_v2.node.*.name, count.index)
    user     = var.image_user
  }
}

data "template_file" "ansible_host_v4" {
  template = "$${hostname} ansible_host=$${ip} ansible_ssh_user=$${user}"
  count    = var.node_count
  vars = {
    ip = replace(
      element(
        openstack_compute_instance_v2.node.*.access_ip_v4,
        count.index,
      ),
      var.search,
      "$1",
    )
    hostname = element(openstack_compute_instance_v2.node.*.name, count.index)
    user     = var.image_user
  }
}

data "template_file" "ansible_inventory_v6" {
  template = "[$${name}]\n$${hosts}\n"
  vars = {
    name  = var.name
    hosts = join("\n", data.template_file.ansible_host_v6.*.rendered)
  }
}

data "template_file" "ansible_inventory_v4" {
  template = "[$${name}]\n$${hosts}\n"
  vars = {
    name  = var.name
    hosts = join("\n", data.template_file.ansible_host_v4.*.rendered)
  }
}

output "inventory_v6" {
  value = data.template_file.ansible_inventory_v6.rendered
}

output "inventory_v4" {
  value = data.template_file.ansible_inventory_v4.rendered
}

