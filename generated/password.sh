#!/bin/bash

kubectl -n argocd get --kubeconfig /tmp/kubeconfig secret argocd-secret -o jsonpath="{.data.clearPassword}" | base64 -d