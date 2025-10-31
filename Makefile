SHELL := /bin/bash

# --------- Variables (personalitzables) ---------
KUBECONFIG ?= $(HOME)/.kube/config
ANSIBLE ?= ansible-playbook
GALAXY ?= ansible-galaxy
VAULT ?= ansible-vault
KUBECTL ?= kubectl

# Namespace on despleguem Argo CD
ARGOCD_NAMESPACE ?= argocd

# --------- Helpers ---------
.PHONY: help
help:
	@echo "Objectius disponibles:"
	@echo "  make k3s-install      -> Installing/updating K3s with Ansible (playbooks/site.yml)"
	@echo "  make k3s-clean        -> Clean fully K3s (playbooks/k3s-clean.yml)"
	@echo "  make argocd-install   -> Installing/updating Argo CD (playbooks/argocd.yml)"
	@echo "  make edit-vault       -> Read vault file"
	@echo ""
	@echo "Variables útils (override en línia):"
	@echo "  INVENTORY=<path al inventari>   (defecte: $(INVENTORY))"
	@echo "  KUBECONFIG=<path kubeconfig>    (defecte: $(KUBECONFIG))"
	@echo "  ARGOCD_NAMESPACE=<ns>           (defecte: $(ARGOCD_NAMESPACE))"

# Comprovar que existeix el kubeconfig quan calga kubectl
.PHONY: check-kubeconfig
check-kubeconfig:
	@if [ ! -f "$(KUBECONFIG)" ]; then \
	  echo "❌ KUBECONFIG not found in $(KUBECONFIG)"; \
	  echo "   set KUBECONFIG=... or create before to execute kubectl."; \
	  exit 1; \
	fi

# --------- K3s ---------
.PHONY: k3s-install
k3s-install:
	@set -euo pipefail; \
	echo "🚀 Installing/updating K3s amb Ansible (playbooks/site.yml)"; \
	$(ANSIBLE) playbooks/k3s-install.yml

.PHONY: k3s-clean
k3s-clean:
	@set -euo pipefail; \
	echo "🧹 Clean K3s (playbooks/k3s-clean.yml)"; \
	$(ANSIBLE) playbooks/k3s-clean.yml

# --------- Argo CD ---------
.PHONY: argocd-install
argocd-install: check-kubeconfig argocd-deps
	@set -euo pipefail; \
	echo "🏗️  Installing/updating Argo CD (playbooks/argocd.yml)"; \
	$(ANSIBLE) playbooks/argocd.yml

.PHONY: argocd-deps
argocd-deps:
	@set -euo pipefail; \
  	echo "🏗️  Adding argo dependencies"; \
    $(GALAXY) collection install -r collections/requirements.yml --force

.PHONY: edit-vault
edit-vault:
	@set -euo pipefail; \
    echo "🏗️  Editing vault file"; \
   	$(VAULT) edit group_vars/all/vault.yml