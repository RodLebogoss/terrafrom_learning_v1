# Déployer un serveur web

![Capture d’écran 2025-06-27 à 18.19.32.png](attachment:fba7800d-17b0-4cbe-98eb-0ec5ca2698a1:Capture_decran_2025-06-27_a_18.19.32.png)

Cette étape consiste a faire tourner un serveur web sur aws, donc sur notre instance.
L’objectif est de déployer l’architecture web la plus simple possible : un serveur web unique, capable de répondre aux requêtes HTTP, comme sur la figure plus haut.

## Objectif

Déployer un **serveur web simple** sur une **instance EC2**, accessible via **HTTP** sur le port `8080`, à l’aide de **Terraform**.

---

## Configuration de l'instance EC2

### 1. **Création d'une instance**

- Utilisation d'une AMI Ubuntu standard (`ami-0fb653ca2d3203ac1`).
- Type d’instance : `t2.micro`.
- Ajout d’un tag `Name = "terraform-example"` pour identification dans la console AWS.

### 2. **Ajout d’un script User Data**

- Script shell lancé à la création de l’instance via `user_data`.
- Démarre un serveur HTTP avec **BusyBox** sur le port `8080` :

```bash
bash
CopyEdit
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p 8080 &

```

- Utilisation de `user_data_replace_on_change = true` pour forcer la recréation de l’instance si le script change.

---

## Configuration réseau (sécurité)

### 3. **Security Group**

Par défaut, AWS n'autorise aucun trafic entrant ou sortant depuis une instance EC2. Pour permettre à l'instance EC2 de recevoir du trafic sur le port 8080, vous devez créer un groupe de sécurité :

- Ouverture du port `8080` en **TCP** depuis **toutes les IPs (0.0.0.0/0)** :

```hcl
hcl
CopyEdit
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

```

- Attachement de ce Security Group à l’instance via `vpc_security_group_ids = [aws_security_group.instance.id]`.

---

## Comportement de Terraform

### 4. **Détection de changements**

- Terraform **compare l’état actuel avec la configuration** (`terraform apply`).
- Affiche un plan indiquant ce qui sera **ajouté, modifié ou remplacé**.
- Le symbole `/+` dans le plan signifie "remplacement" (ex : nouvelle instance si `user_data` change).

### 5. **Gestion des dépendances**

- Références croisées entre ressources (ex: `aws_security_group.instance.id`) créent des **dépendances implicites**.
- Terraform construit un **graphe de dépendance** pour gérer l’ordre de création.

---

## 🌐 Accès au serveur web

- Après déploiement, on peut tester le serveur avec :

```bash
bash
CopyEdit
curl http://<EC2_PUBLIC_IP>:8080
# Output: Hello, World

```

---

## 🔐 Bonnes pratiques de sécurité réseau

- Les exemples utilisent des **sous-réseaux publics** pour simplifier.
- En production :
    - **Éviter les sous-réseaux publics pour les serveurs et les bases de données**.
    - Utiliser des **sous-réseaux privés**.
    - Exposer uniquement un **load balancer ou reverse proxy**, bien sécurisé.