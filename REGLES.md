# Règles de l'Équipe & Standard Git — FindPharma

### Règle n°1 : Nommage des Branches

INTERDICTION DE CODER SUR LE `main`. Chaque développeur crée une branche pour sa tâche.

Le nom de la branche doit suivre ce format : `type/nom-de-la-tache`

    feat/... (Pour une nouvelle fonctionnalité ou de l'UI)
        Exemples : feat/home-page, feat/hive-setup, feat/map-widget

    fix/... (Pour réparer un bug)
        Exemple : fix/map-crash

    chore/... (Pour des configurations ou tâches de fond)
        Exemple : chore/add-dependencies

### Règle n°2 : Nommage des Commits

Un message de commit doit expliquer clairement ce qui a été fait. Pas de commit appelés "test", "mise à jour" ou "ça marche".

Format attendu : `type: description courte`

    feat: ajoute le bouton pour appeler la pharmacie
    fix: corrige le filtre des pharmacies de garde
    style: change la couleur de fond en vert
    docs: met à jour le README avec les rôles

### Règle n°3 : Le Workflow de l'équipe (Très important)

1. Le développeur crée sa branche (`feat/mon-bouton`).
2. Il code, il fait ses commits.
3. Quand c'est fini, il pousse (push) sa branche sur GitHub et ouvre une Pull Request (PR) vers la branche `dev`.
4. Une fois la PR émise, le développeur informe le chef d'équipe.
5. Le mentor ou le chef de groupe regarde le code sur GitHub. S'il n'y a pas de problème, il clique sur le bouton "Merge PR" pour l'intégrer au `dev`.
6. Les autres développeurs font un `git pull origin dev` pour récupérer les nouveautés avant de commencer une nouvelle tâche.