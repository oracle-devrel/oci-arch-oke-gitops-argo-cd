#!/bin/bash

kubectl -n argocd  get --kubeconfig /tmp/kubeconfig svc argo-demo-argo-cd-server  -o jsonpath='{.status.loadBalancer.ingress[0]}'