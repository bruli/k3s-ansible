# Makefile — Operacions K3s + Argo CD amb Ansible i kubectl
# Ús bàsic:
#   make k3s-install        # Instal·lació de K3s (playbooks/site.yml)
#   make k3s-clean          # Neteja completa de K3s (playbooks/k3s-clean.yml)
#   make argocd-install     # Instal·lar/actualitzar Argo CD (playbooks/argocd.yml)
#   make argocd-password    # Mostrar password admin d'Argo CD
#
# Pots sobreescriure variables en línia:
#   make k3s-install INVENTORY=inventory/hosts.yml KUBECONFIG=~/.kube/config

SHELL := /bin/bash

# --------- Variables (personalitzables) ---------
KUBECONFIG ?= $(HOME)/.kube/config
ANSIBLE ?= ansible-playbook
GALAXY ?= ansible-galaxy
KUBECTL ?= kubectl

# Namespace on despleguem Argo CD
ARGOCD_NAMESPACE ?= argocd

# --------- Helpers ---------
.PHONY: help
help:
	@echo "Objectius disponibles:"
	@echo "  make k3s-install      -> Instal·lar/actualitzar K3s amb Ansible (playbooks/site.yml)"
	@echo "  make k3s-clean        -> Netejar completament K3s (playbooks/k3s-clean.yml)"
	@echo "  make argocd-install   -> Instal·lar/actualitzar Argo CD (playbooks/argocd.yml)"
	@echo "  make argocd-password  -> Llegir el password admin d'Argo CD"
	@echo ""
	@echo "Variables útils (override en línia):"
	@echo "  INVENTORY=<path al inventari>   (defecte: $(INVENTORY))"
	@echo "  KUBECONFIG=<path kubeconfig>    (defecte: $(KUBECONFIG))"
	@echo "  ARGOCD_NAMESPACE=<ns>           (defecte: $(ARGOCD_NAMESPACE))"

# Comprovar que existeix el kubeconfig quan calga kubectl
.PHONY: check-kubeconfig
check-kubeconfig:
	@if [ ! -f "$(KUBECONFIG)" ]; then \
	  echo "❌ No s'ha trobat KUBECONFIG a $(KUBECONFIG)"; \
	  echo "   Passa KUBECONFIG=... o crea'l abans d'executar kubectl."; \
	  exit 1; \
	fi

# --------- K3s ---------
.PHONY: k3s-install
k3s-install:
	@set -euo pipefail; \
	echo "🚀 Instal·lant/actualitzant K3s amb Ansible (playbooks/site.yml)"; \
	$(ANSIBLE) playbooks/k3s-install.yml

.PHONY: k3s-clean
k3s-clean:
	@set -euo pipefail; \
	echo "🧹 Netejant K3s (playbooks/k3s-clean.yml)"; \
	$(ANSIBLE) playbooks/k3s-clean.yml

# --------- Argo CD ---------
.PHONY: argocd-install
argocd-install: check-kubeconfig argocd-deps
	@set -euo pipefail; \
	echo "🏗️  Instal·lant/actualitzant Argo CD (playbooks/argocd.yml)"; \
	$(ANSIBLE) playbooks/argocd.yml

.PHONY: argocd-password
argocd-password: check-kubeconfig
	@set -euo pipefail; \
	echo "🔐 Password d'admin d'Argo CD (ns=$(ARGOCD_NAMESPACE)):"; \
	$(KUBECTL) --kubeconfig="$(KUBECONFIG)" -n "$(ARGOCD_NAMESPACE)" get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' \
	| base64 -d; echo

.PHONY: argocd-deps
argocd-deps:
	@set -euo pipefail; \
  	echo "🏗️  Adding argo dependencies"; \
    $(GALAXY) collection install -r collections/requirements.yml --force