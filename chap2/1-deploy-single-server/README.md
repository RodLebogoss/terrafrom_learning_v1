# Déploiement d’un serveur EC2 avec Terraform

### **1. Préparation de l’environnement Terraform**

- **Fichier principal** : `main.tf`
- **Langage utilisé** : HCL (HashiCorp Configuration Language)
- **Objectif** : Décrire l’infrastructure désirée de manière déclarative

### **2. Configuration du fournisseur (provider)**

```hcl
h
CopyEdit
provider "aws" {
  region = "us-east-2"
}

```

- Indique à Terraform d’utiliser AWS et de travailler dans la région `us-east-2` (Ohio).

---

### **3. Création d’une instance EC2**

```hcl
hcl
CopyEdit
resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"  # Ubuntu 20.04 dans us-east-2
  instance_type = "t2.micro"              # Type gratuit (Free Tier)
}

```

### **4. Ajout d’un tag pour nommer l’instance**

```hcl
h
CopyEdit
tags = {
  Name = "terraform-example"
}

```

---

### **5. Commandes Terraform de base**

- `terraform init`
    
    → Initialise le projet et télécharge les plugins nécessaires.
    
- `terraform plan`
    
    → Affiche ce que Terraform va faire (ajouter, modifier, supprimer).
    
- `terraform apply`
    
    → Applique les changements (nécessite confirmation).
    
- `terraform destroy` *(optionnel)*
    
    → Supprime les ressources créées.
    

---

### **6. Gestion de l’état**

- Terraform garde une trace des ressources créées dans des fichiers `.tfstate`.
- Cela permet d’identifier ce qui existe déjà et de faire des mises à jour plutôt que tout redéployer.

---

### **7. Versionnage avec Git**

```bash
bash
CopyEdit
git init
git add main.tf .terraform.lock.hcl
git commit -m "Initial commit"

```

- Fichier `.gitignore` recommandé :
    
    ```
    markdown
    CopyEdit
    .terraform
    *.tfstate
    *.tfstate.backup
    
    ```
    
- Utilisation de GitHub pour le travail en équipe :
    
    ```bash
    bash
    CopyEdit
    git remote add origin git@github.com:<USERNAME>/<REPO>.git
    git push origin main
    
    ```
    

---

### 📌 **Résumé des avantages**

- Terraform vous permet d’automatiser la création et la gestion d’infrastructure.
- Les fichiers `.tf` sont versionnables et lisibles par toute l’équipe.
- Les commandes `plan` et `apply` permettent un contrôle précis des modifications.