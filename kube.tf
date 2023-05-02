provider "kubernetes" {
    config_path = "/tmp/kubeconfig"
}


resource "time_sleep" "wait_1min_demo" {
  depends_on = [
  local_file.kubeconfig
  ]
  create_duration = "60s"
}


resource "null_resource" "create_ns" {
  
  depends_on = [time_sleep.wait_1min_demo]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig /tmp/kubeconfig create ns argocd" 

}

}

resource "time_sleep" "wait_3min" {
  depends_on = [
  helm_release.argo_cd
  ]
  create_duration = "180s"
}




resource "null_resource" "example1" {
   depends_on = [time_sleep.wait_3min]
  provisioner "local-exec" {
    command = "/bin/bash ./generated/kube.sh > /tmp/ip_addr" 
    
  }
}

data "local_file" "ip_addr" {
    depends_on = [null_resource.example1]
    filename = "/tmp/ip_addr"
}

output "ip_endpoint" {
  value       = "Endpoint is ${data.local_file.ip_addr.content}"
  description = "Endpoint for website"
}



resource "null_resource" "password" {
   depends_on = [time_sleep.wait_3min]
  provisioner "local-exec" {
    command = "/bin/bash ./generated/password.sh > /tmp/password" 
    
  }
}

data "local_file" "password" {
    depends_on = [null_resource.example1]
    filename = "/tmp/password"
}

output "password" {
  value       = "Username=admin  password= ${data.local_file.password.content}"
  description = "password"
}
