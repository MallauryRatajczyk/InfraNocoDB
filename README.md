# InfraNocoDB 🚀

InfraNocoDB est une infrastructure complète et automatisée pour le déploiement de [NocoDB](https://www.nocodb.com/), une plateforme no-code de gestion de bases de données relationnelles.

Le projet met en œuvre une architecture DevOps moderne basée sur **Kubernetes**, **Terraform**, **Ansible**, **Docker** et **Certbot**, afin d’orchestrer le provisioning de l’infrastructure cloud, l’installation des outils, le déploiement de NocoDB et la sécurisation HTTPS avec un minimum d'intervention humaine.

---

## 🧠 Objectifs

- Fournir un **déploiement 100% automatisé** de NocoDB en environnement cloud.
- Mettre en pratique des **bonnes pratiques DevOps** (Infrastructure as Code, orchestration, sécurité, CI/CD).
- Créer une stack scalable, maintenable, et prête pour la production.

---

## ⚙️ Stack technique

| Composant         | Description |
|------------------|-------------|
| **Terraform**     | Provisioning de l'infrastructure (VM, réseau, DNS, etc.) |
| **Ansible**       | Configuration automatisée des machines et installation des dépendances |
| **Kubernetes**    | Orchestration des conteneurs (K3s) pour déployer NocoDB |
| **Docker**        | Conteneurisation de l’application |
| **NocoDB**        | Plateforme no-code sur base SQL |
| **Nginx**         | Proxy inverse pour gérer les connexions entrantes |
| **Certbot (Let’s Encrypt)** | Génération automatique de certificats SSL |
| **Linux (Debian)**| Système de base utilisé sur les VM cloud |
| **Cloud Provider**| GCP |

---

## 📦 Fonctionnalités

- Provisionnement d'une VM cloud avec Terraform.
- Installation automatique de Kubernetes (K3s) via Ansible.
- Déploiement de NocoDB sur Kubernetes.
- Génération automatique de certificats SSL avec Certbot.
- Configuration de Nginx comme proxy HTTPS sécurisé.
- Tout est automatisé : **1 seule commande Terraform suffit**.

---

## 📐 Architecture
[ Utilisateur ] | v [ HTTPS (Certbot + Nginx) ] | v [ NocoDB sur K3s (Kubernetes léger) ] | v [ Base de données distante (MySQL, PostgreSQL, etc.) ]


---

## 🔧 Prérequis

- Git
- Terraform
- Un accès API à un fournisseur cloud (ex : Scaleway)
- Un nom de domaine pointant vers l’IP publique de la future VM (requis pour HTTPS)
- Une base de données (locale ou cloud)

---

## 🚀 Déploiement (automatisé)

> Tout est géré automatiquement par Terraform + Ansible + Kubernetes.

### Étapes :

1. **Cloner le projet** :

git clone https://github.com/MallauryRatajczyk/InfraNocoDB.git
cd InfraNocoDB

2. **Configurer les variables Terraform**
(nom de domaine, clé SSH, cloud provider, etc.)

Fichier : terraform/variables.tf

3. **Lancer le déploiement** :
terraform init
terraform apply
