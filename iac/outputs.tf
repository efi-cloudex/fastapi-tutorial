output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip,":8000"])
}