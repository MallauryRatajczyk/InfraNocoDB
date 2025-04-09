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
| **Prometheus**| Monitoring |
| **Grafana**| Monitoring |

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
[ Utilisateur ] ->  [ Bastion en HTTPS (Certbot + Nginx) ] -> [ NocoDB sur K3s (Kubernetes léger) ] -> [ Base de données distante (MySQL, PostgreSQL, etc.) ]

Ce schéma exlut l'instance de monitoring directement accessible via /monitoring
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

## ✅ En quelques minutes, vous aurez :

Une VM provisionnée
Kubernetes installé et prêt
NocoDB déployé

Certificat HTTPS actif via Let’s Encrypt

Accès disponible à https://votre-domaine.com

Une instance de monitoring sur https://votre-domaine.com/monitoring

## 🧪 Utilisation
Ouvrez votre navigateur sur https://votre-domaine.com

Connectez une base de données existante (MySQL, PostgreSQL, etc.)

Créez des vues, APIs REST, et interfaces no-code en quelques clics

Pour le monitoring, allez sur https://votre-domaine.com/monitoring

## 🤝 Contribution
Les contributions sont les bienvenues ! 🙌

Forkez ce dépôt

Créez une branche (git checkout -b feature/ma-feature)

Commitez vos changements (git commit -m 'Ajout de ma feature')

Poussez la branche (git push origin feature/ma-feature)

Ouvrez une Pull Request

## 👩‍💻 À propos
Mallaury Ratajczyk
Passionnée par le DevOps, l’automatisation, les architectures cloud et les outils open-source.
📧 mallaury.ratajczyk@gmail.com
🔗 LinkedIn : https://www.linkedin.com/in/mallaury-ratajczyk-12217131b/

