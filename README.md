# NotSpot

NotSpot est une application de streaming musical permettant de creer un compte, se connecter, ecouter des musiques, rechercher des titres et organiser ses morceaux dans des playlists.

Ce depot contient le backend de l'application NotSpot. Il expose l'API utilisee par l'application mobile et gere l'authentification, les musiques, le streaming audio, les playlists et les parametres utilisateur.

## Telechargement

Le telechargement de l'application se fait depuis le hub de telechargement NotSpot :

[Acceder au hub de telechargement](https://thegesse.github.io/site-not-spot/)

Ce site redirige vers les versions disponibles de l'application et centralise les informations utiles pour installer NotSpot.

## Fonctionnement de l'application

### Creation de compte

L'utilisateur peut creer un compte avec :

- un nom d'utilisateur ;
- une adresse e-mail ;
- un mot de passe.

Apres l'inscription, l'application cree une session utilisateur et permet d'acceder aux fonctionnalites protegees.

### Connexion

L'utilisateur se connecte avec son nom d'utilisateur et son mot de passe. Une fois connecte, il peut consulter les musiques, ecouter des titres et gerer ses playlists.

### Ecoute de musique

Depuis l'accueil, l'utilisateur peut :

- consulter la liste des musiques disponibles ;
- rechercher une musique ;
- selectionner un titre ;
- lancer la lecture audio ;
- utiliser le mini lecteur pendant la navigation.

Le streaming audio est fourni par le backend, qui renvoie le fichier audio correspondant a la musique selectionnee.

### Recherche

La recherche permet de trouver rapidement une musique dans le catalogue. L'utilisateur saisit une requete, puis l'application affiche les titres correspondants.

### Playlists

L'utilisateur peut organiser ses musiques avec des playlists.

Fonctionnalites disponibles :

- creer une playlist ;
- consulter ses playlists ;
- ouvrir le detail d'une playlist ;
- renommer une playlist ;
- ajouter une musique dans une playlist ;
- retirer une musique d'une playlist ;
- supprimer une playlist.

### Parametres du compte

Depuis les parametres, l'utilisateur peut :

- modifier son nom d'utilisateur ;
- modifier son mot de passe ;
- supprimer son compte.

## Backend

Le backend NotSpot est developpe avec Spring Boot. Il gere :

- l'inscription et la connexion ;
- les tokens JWT et refresh tokens ;
- la protection des routes ;
- la persistance en base PostgreSQL ;
- le catalogue de musiques ;
- l'upload et le stockage des fichiers audio ;
- le streaming audio ;
- les playlists ;
- les parametres utilisateur.

Important : pour tester l'application frontend actuelle en local, il est recommande d'utiliser le backend suivant :

[https://github.com/thegesse/back-end-not-spot/tree/master](https://github.com/thegesse/back-end-not-spot/tree/master)

Le backend present dans ce depot est en cours de refonte. Il n'est pas encore termine ni entierement teste avec le frontend actuel. Le frontend n'a pas encore ete adapte a toutes les differences de ce backend local.

La documentation technique detaillee est disponible ici :

[DOCUMENTATION_TECHNIQUE.md](./DOCUMENTATION_TECHNIQUE.md)

Le cahier des charges est disponible ici :

[CAHIER_DES_CHARGES.md](./CAHIER_DES_CHARGES.md)

## Repos en lien avec ce projet

- [site-not-spot](https://github.com/thegesse/site-not-spot) : site web servant de hub de telechargement et de presentation du projet.
- [email-sender-CLI](https://github.com/thegesse/email-sender-CLI) : outil CLI lie a l'envoi d'e-mails pour l'ecosysteme du projet.
- [back-end-not-spot](https://github.com/thegesse/back-end-not-spot) : repository du backend NotSpot. Ce repo correspond aussi au backend utilise en production pour l'instant.

## Utilisation rapide

Pour utiliser l'application en tant qu'utilisateur :

1. Ouvrir le hub de telechargement.
2. Installer l'application disponible.(pas d'installable pour windows ou apple pour l'instant)
3. Creer un compte ou se connecter.
4. Parcourir les musiques.
5. Lancer une lecture.
6. Creer des playlists pour organiser ses titres.

## Lancer le projet en local pour tester

### Backend recommande

Pour tester le frontend actuel, cloner et lancer le backend stable :

```sh
git clone https://github.com/thegesse/back-end-not-spot.git
cd back-end-not-spot
git checkout master
```

Suivre ensuite les instructions dans la documentation technique pour configurer la base de donnees et lancer l'API.

### Frontend Flutter

Depuis ce depot :

```sh
cd frontend_mobile/not_spot
flutter pub get
flutter run
```

Pour tester la version web :

```sh
flutter run -d chrome --web-port 3000
```

Si le backend ne tourne pas sur l'URL par defaut du frontend, fournir l'URL au lancement :

```sh
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

### CORS pour Flutter web

Oui, CORS est necessaire pour tester avec `flutter run -d chrome`, car le frontend web est servi depuis une origine du type `http://localhost:3000` et appelle le backend sur une autre origine, par exemple `http://localhost:8080`.

Pour eviter les erreurs CORS :

- lancer Flutter web sur un port fixe autorise par le backend :

```sh
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

- verifier que le backend autorise cette origine dans sa configuration CORS.

Dans le backend de ce depot, la configuration se trouve dans :

```text
backend/notSpot/src/main/java/com/goose/notspot/configuration/SecurityConfig.java
```

L'origine `http://localhost:3000` est deja presente dans `setAllowedOrigins(...)`. Si vous lancez Flutter web sur un autre port, ajoutez cette origine a la liste ou utilisez `--web-port 3000`.

### Backend de ce depot

Le backend inclus dans ce depot peut etre lance pour developpement backend, mais il n'est pas le choix recommande pour tester le frontend actuel :

```sh
cd backend/notSpot
./mvnw spring-boot:run
```

Il peut necessiter des adaptations cote frontend car les contrats API ne sont pas encore totalement alignes.

## Notes

Certaines fonctionnalites avancees sont prevues comme evolutions, notamment les roles administrateur, et l'historique d'ecoute.
