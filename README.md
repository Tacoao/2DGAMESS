
# Crimson Cloak Echoes of the Enchanted Forest

Ce dépôt contient un jeu 2.5D développé avec le moteur Godot 4.2 et l'intégration C#.

## Pour Commencer

### Prérequis

1. **Godot Engine 4.2**:
   - Assurez-vous d'avoir installé la version C# de Godot 4.2.
   - Téléchargez-la depuis le [site officiel de Godot](https://godotengine.org/download).

2. **.NET SDK**:
   - Installez le SDK .NET nécessaire pour compiler les scripts C#.
   - Téléchargez-le depuis le [site officiel de .NET](https://dotnet.microsoft.com/download).

### Installation

1. **Cloner le dépôt**:
   ```sh
   git clone https://github.com/Tacoao/2DGAMESS.git
   cd 2DGAMESS
   ```

2. **Ouvrir le projet dans Godot**:
   - Lancez Godot Engine.
   - Cliquez sur "Import" et sélectionnez le fichier `project.godot` dans le répertoire cloné.
   - Cliquez sur "Open".

3. **Configurer l'environnement C#**:
   - Dans Godot, allez dans `Editor > Editor Settings`.
   - Sous `Mono`, assurez-vous que les chemins vers le SDK .NET et MSBuild sont correctement configurés.

4. **Compilation**:
   - Allez dans `Project > Project Settings`.
   - Sous `Mono > Builds`, assurez-vous que le chemin vers MSBuild est correct.
   - Compilez le projet en cliquant sur `Build`.

### Exécution
1.**Lancer votre Docker**:
    - Suivre d'abbord les étapes du repository https://github.com/2soum/ApiCrimson
2. **Lancer le jeu**:
   - Vous pouvez exécuter le jeu directement depuis l'éditeur Godot en cliquant sur le bouton de lecture ("Play").

### Fichiers Exécutables

- Les fichiers exécutables (.exe) du jeu sont disponibles via un lien WeTransfer inclus dans la documentation du projet. Téléchargez-les pour exécuter le jeu sans passer par Godot.
- https://we.tl/t-8sldpzewSs

## Contributions

Les contributions sont les bienvenues! Veuillez suivre les étapes suivantes pour contribuer :

1. **Forker le dépôt**:
   - Cliquez sur le bouton "Fork" en haut à droite de la page GitHub du projet.

2. **Créer une branche de fonctionnalité**:
   ```sh
   git checkout -b ma-nouvelle-fonctionnalité
   ```

3. **Effectuer les modifications souhaitées**.

4. **Commiter vos changements**:
   ```sh
   git commit -m "Ajout d'une nouvelle fonctionnalité"
   ```

5. **Pousser vers le dépôt distant**:
   ```sh
   git push origin ma-nouvelle-fonctionnalité
   ```

6. **Ouvrir une Pull Request**:
   - Allez sur votre dépôt forké sur GitHub.
   - Cliquez sur "New Pull Request" et suivez les instructions.

## Licence

Ce projet est sous licence MIT. Veuillez vous référer au fichier LICENSE pour plus de détails.

## Remerciements

La team Crimson Studio (Tacoao, 2soum)

---
