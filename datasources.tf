data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

data "oci_containerengine_cluster_option" "FoggyKitchenOKEClusterOption" {
  provider          = oci.targetregion
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "FoggyKitchenOKEClusterNodePoolOption" {
  provider          = oci.targetregion
  node_pool_option_id = "all"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  provider       = oci.targetregion
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "FoggyKitchenAllOCIServices" {
  provider       = oci.targetregion

  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


data "oci_identity_regions" "oci_regions" {
  filter {
    name   = "name"
    values = [var.region]
  }

}

data "oci_objectstorage_namespace" "test_namespace" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "nginx_deployment" {

  template = "${file("${path.module}/templates/nginx.template.yaml")}"
  vars     = {
      number_of_nginx_replicas = var.number_of_nginx_replicas
      image_url                = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/fknginx:latest" 
      is_arm_node_shape        = local.is_arm_node_shape
  }
}

data "template_file" "service_deployment" {

  template = "${file("${path.module}/templates/service.template.yaml")}"
  vars     = {
      lb_shape          = var.lb_shape
      flex_lb_min_shape = var.flex_lb_min_shape 
      flex_lb_max_shape = var.flex_lb_max_shape  
      lb_listener_port  = var.lb_listener_port
      lb_nsg            = var.lb_nsg
      lb_nsg_id         = var.lb_nsg ? oci_core_network_security_group.FoggyKitchenOKELBSecurityGroup[0].id : ""
  }
}

data "template_file" "dockerfile_deployment" {

  template = "${file("${path.module}/templates/dockerfile.template")}"
  vars     = {
  }
}

data "template_file" "indexhtml_deployment" {

  template = "${file("${path.module}/templates/index.template.html")}"
  vars     = {
    image_url = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/fknginx:latest" 
  }
}