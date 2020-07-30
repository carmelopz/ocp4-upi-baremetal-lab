data "template_file" "ocp_olm_catalog_source" {
  template = file(format("%s/olm/catalog-source.yml.tpl", path.module))

  vars = {
    ocp_registry_mirror = format("%s:%s", local.registry.fqdn, var.registry.port)
  }
}

resource "local_file" "ocp_olm_catalog_source" {
  filename             = format("%s/olm/catalog-source.yml", path.module)
  content              = data.template_file.ocp_olm_catalog_source.rendered
  file_permission      = "0644"
  directory_permission = "0755"
}
