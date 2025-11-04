SHELL := /bin/bash

# --------- Variables (personalitzables) ---------
KUBECONFIG ?= $(HOME)/.kube/config
ANSIBLE ?= ansible-playbook
GALAXY ?= ansible-galaxy
VAULT ?= ansible-vault
KUBECTL ?= kubectl

# Namespace on despleguem Argo CD
ARGOCD_NAMESPACE ?= argocd

.PHONY: check-kubeconfig k3s-clean k3s-install check-kubeconfig argocd-deps argocd-install edit-vault help cloudflared-secret

check-kubeconfig:
	@if [ ! -f "$(KUBECONFIG)" ]; then \
	  echo "❌ KUBECONFIG not found in $(KUBECONFIG)"; \
	  echo "   set KUBECONFIG=... or create before to execute kubectl."; \
	  exit 1; \
	else \
	  echo "✅ $(KUBECONFIG) already exists"; \
	fi

k3s-install:
	@set -euo pipefail; \
	echo "🚀 Installing/updating K3s amb Ansible (playbooks/site.yml)"; \
	$(ANSIBLE) playbooks/k3s-install.yml

k3s-clean:
	@set -euo pipefail; \
	echo "🧹 Clean K3s (playbooks/k3s-clean.yml)"; \
	$(ANSIBLE) playbooks/k3s-clean.yml

argocd-install: check-kubeconfig argocd-deps
	@set -euo pipefail; \
	echo "🏗️  Installing/updating Argo CD (playbooks/argocd.yml)"; \
	$(ANSIBLE) playbooks/argocd.yml --ask-vault-pass

argocd-deps:
	@set -euo pipefail; \
  	echo "🏗️  Adding argo dependencies"; \
    $(GALAXY) collection install -r collections/requirements.yml --force

edit-vault:
	@set -euo pipefail; \
    echo "🏗️  Editing vault file"; \
   	$(VAULT) edit group_vars/all/vault.yml

cloudflared-secret:
	@set -euo pipefail; \
    echo "🏗️  Writing cloudflared secret"; \
    $(ANSIBLE) playbooks/cloudflared-secret.yml

help:
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:' Makefile | awk -F':' '{print "  - " $$1}'