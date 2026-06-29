# Cahier des charges - NotSpot

## 1. Presentation du projet

NotSpot est une application de streaming musical centree sur une API backend Spring Boot et un client mobile Flutter. Le projet permet a un utilisateur de creer un compte, de se connecter, de consulter un catalogue de musiques, de lire les fichiers audio en streaming et de gerer ses playlists.

Le projet, repose principalement sur :

- un backend REST Spring Boot situe dans `notSpot/` ;
- une application mobile Flutter situee dans `frontend_mobile/not_spot/` ;
- une base de donnees PostgreSQL ;
- un stockage local des fichiers audio ;
- une securite basee sur Spring Security, JWT et refresh tokens.

Le site web PC et l'interface d'administration complete restent des evolutions possibles, mais ne sont pas representes comme livrables principaux dans l'etat actuel du depot.

## 2. Objectifs

### 2.1 Objectif principal

Fournir une application musicale fonctionnelle permettant a un utilisateur authentifie de parcourir des titres, les ecouter et organiser sa bibliotheque avec des playlists.

### 2.2 Objectifs secondaires

- proposer une API REST reutilisable par le client mobile et, plus tard, par un client web ;
- permettre la creation de compte, la connexion, le rafraichissement de session et la deconnexion ;
- proteger les routes sensibles avec un jeton JWT ;
- permettre l'ajout, la consultation, la recherche, la lecture et la suppression de musiques ;
- permettre la creation, consultation, modification et suppression de playlists ;
- permettre la modification du nom d'utilisateur, du mot de passe et la suppression du compte ;
- conserver les donnees en base PostgreSQL ;
- stocker les fichiers audio sur le serveur.

## 3. Public cible

Le service s'adresse principalement :

- aux utilisateurs qui souhaitent ecouter de la musique depuis l'application mobile ;
- aux utilisateurs qui veulent organiser leurs titres dans des playlists ;
- aux contributeurs du projet qui ajoutent et testent des musiques via l'API ou l'application.

## 4. Perimetre fonctionnel actuel

### 4.1 Authentification

L'utilisateur peut :

- creer un compte avec un nom d'utilisateur, une adresse e-mail et un mot de passe ;
- se connecter avec son nom d'utilisateur et son mot de passe ;
- recevoir un access token JWT et un refresh token ;
- rafraichir sa session avec un refresh token ;
- se deconnecter, ce qui supprime les refresh tokens associes a l'utilisateur.

Les mots de passe sont hashes avec BCrypt.

### 4.2 Gestion du compte

L'utilisateur peut :

- modifier son nom d'utilisateur ;
- modifier son mot de passe ;
- supprimer son compte.

Dans l'etat actuel du backend, ces routes sont exposees sous `/settings/users/{userId}` et utilisent encore l'identifiant utilisateur dans l'URL.

### 4.3 Catalogue musical

Le backend permet :

- d'ajouter une musique avec un titre, un artiste et un fichier audio ;
- de lister toutes les musiques ;
- de recuperer une musique par son identifiant ;
- de rechercher une musique avec une query ;
- de recuperer une musique aleatoire ;
- de streamer un fichier audio ;
- de supprimer une musique.

Les informations actuellement conservees pour une musique sont :

- `id` ;
- `title` ;
- `artist` ;
- `audioPath` ;
- `contentType` ;
- `fileSize`.


### 4.4 Playlists

Le backend permet :

- de creer une playlist pour un utilisateur ;
- de lister les playlists d'un utilisateur ;
- de consulter le detail d'une playlist ;
- de renommer une playlist ;
- de supprimer une playlist ;
- d'ajouter une musique a une playlist ;
- de retirer une musique d'une playlist.

Les playlists sont liees a un proprietaire (`User`) et a une liste de musiques via une relation many-to-many.

### 4.5 Application mobile Flutter

L'application mobile contient :

- des ecrans de connexion et d'inscription ;
- un ecran d'accueil ;
- une liste de musiques ;
- une recherche ;
- un mini lecteur ;
- des ecrans et widgets de playlists ;
- un formulaire d'ajout de musique ;
- des ecrans de parametres utilisateur ;
- une navigation adaptee mobile et desktop Flutter.

Le client Flutter consomme l'API backend via `AppConfig` et `ApiClient`.

### 4.6 Fonctionnalites hors perimetre actuel

Les elements suivants ne sont pas finalises dans l'etat actuel :

- roles administrateur ;
- controle de droits fin par role ;
- recommandations musicales ;
- historique d'ecoute ;
- mode hors ligne ;
- pochettes d'albums et metadonnees avancees ;

## 5. Interfaces attendues

### 5.1 Application mobile

L'application mobile est le client principal actuel. Elle doit couvrir les parcours suivants :

- inscription ;
- connexion ;
- accueil et consultation des titres ;
- recherche de musiques ;
- lecture audio avec mini lecteur ;
- consultation des playlists ;
- creation et modification de playlists ;
- ajout et retrait de musiques dans une playlist ;
- ajout d'une musique au catalogue ;
- parametres du compte.


## 6. Exigences techniques

### 6.1 Backend

Le backend est une API REST developpee avec Spring Boot.

Technologies presentes :

- Java 21 ;
- Spring Boot 4.0.6 ;
- Spring Web MVC ;
- Spring Security ;
- Spring Data JPA ;
- Spring Validation ;
- PostgreSQL ;
- Lombok ;
- Maven ;
- JJWT pour les tokens JWT.

Le backend est organise par couches :

- `controller` pour les routes HTTP ;
- `service` pour la logique metier ;
- `repository` pour l'acces aux donnees ;
- `model` pour les entites, DTO, requetes et reponses ;
- `configuration` pour la securite et les filtres.

### 6.2 Base de donnees

La base de donnees utilisee est PostgreSQL.

Les entites actuelles sont :

- `User`, stockee dans `app_users` ;
- `Song`, stockee dans `songs` ;
- `Playlist`, stockee dans `playlists` ;
- table de liaison `playlist_songs` ;
- `RefreshToken`, stockee dans `refresh_token`.

La configuration de connexion est parametrable via variables d'environnement :

- `SPRING_DATASOURCE_URL` ;
- `SPRING_DATASOURCE_USERNAME` ;
- `SPRING_DATASOURCE_PASSWORD` ;
- `SPRING_JPA_HIBERNATE_DDL_AUTO`.

### 6.3 Stockage audio

Les fichiers audio sont stockes cote serveur dans un dossier configurable :

- propriete : `app.song-storage.dir` ;
- variable possible : `SONG_STORAGE_DIR` ;
- valeur par defaut : `${user.dir}/uploads/songs`.

La taille maximale d'upload est configuree a 25 MB par defaut.

### 6.4 Application mobile

Le client mobile est developpe avec :

- Dart ;
- Flutter ;
- Provider pour une partie de l'etat applicatif ;
- HTTP et Dio pour les appels API et l'upload multipart.

L'URL de l'API est centralisee dans `AppConfig`, avec une valeur par defaut pointee vers `https://notspot.kaillou.de`.

## 7. Architecture generale

Architecture actuelle :

- client mobile Flutter ;
- API backend Spring Boot ;
- authentification Spring Security + JWT ;
- base de donnees PostgreSQL ;
- stockage serveur des fichiers audio ;
- service de streaming audio expose par l'API.

Les clients doivent consommer l'API REST du backend. La logique metier principale doit rester cote backend afin de garder un comportement coherent entre les futures interfaces.

## 8. Securite

La configuration actuelle de securite est definie dans `SecurityConfig.java`.

Principes appliques :

- API stateless avec `SessionCreationPolicy.STATELESS` ;
- CSRF desactive, adapte a une API REST stateless ;
- mots de passe hashes avec BCrypt ;
- authentification par JWT via `JwtAuthFilter` ;
- routes `/auth/**` publiques ;
- routes `/songs/**`, `/playlists/**` et `/settings/**` protegees ;
- CORS configure pour `http://localhost:3000`, `http://localhost:8080` et `https://app.kaillou.de` ;
- methodes CORS autorisees : `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`, `PATCH` ;
- en-tetes autorises : `Authorization`, `Content-Type`, `Cache-Control`.

Points d'attention securite restants :

- la cle JWT est actuellement codee en dur dans `JwtService` et doit etre externalisee en variable d'environnement avant production ;
- les roles administrateur ne sont pas encore modelises ;
- certaines routes utilisent encore `userId` ou `username` en parametre au lieu de deduire l'utilisateur depuis le JWT ;
- l'ajout et la suppression de musiques sont actuellement proteges par authentification, mais pas par role administrateur.

## 9. Contraintes non fonctionnelles

### 9.1 Performance

- La lecture audio doit demarrer rapidement.
- Les recherches doivent repondre sans delai excessif.
- Le backend doit eviter autant que possible de charger inutilement les fichiers audio complets en memoire.
- Les endpoints listes doivent retourner des DTO plutot que les entites JPA completes.

### 9.2 Ergonomie

- L'application mobile doit rester simple a utiliser.
- Les actions principales doivent etre accessibles depuis l'accueil : recherche, lecture, playlists.
- Le mini lecteur doit rester disponible pendant la navigation.
- Les messages d'erreur doivent etre comprehensibles cote client.

### 9.3 Compatibilite

- Backend executable avec Java 21.
- Base PostgreSQL requise.
- Application mobile compatible Android en priorite.
- Extension iOS et web possible si le temps le permet.

### 9.4 Maintenabilite

- Conserver l'organisation controller/service/repository/model.
- Utiliser les DTO pour separer l'API des entites internes.
- Garder les routes documentees et stables pour le client Flutter.
- Ajouter des tests sur l'authentification, les playlists, les musiques et le streaming.

## 10. Donnees principales

### 10.1 Utilisateur

Champs actuels :

- `id` ;
- `username` ;
- `password` ;
- `email` ;
- `playlists`.

### 10.2 Refresh token

Champs actuels :

- `id` ;
- `user` ;
- `token` ;
- `expiryDate`.

### 10.3 Musique

Champs actuels :

- `id` ;
- `title` ;
- `artist` ;
- `audioPath` ;
- `contentType` ;
- `fileSize`.

### 10.4 Playlist

Champs actuels :

- `id` ;
- `title` ;
- `owner` ;
- `songs`.

## 11. API actuelle

### 11.1 Authentification

- `POST /auth/register` : creer un compte et retourner une session ;
- `POST /auth/login` : connecter un utilisateur ;
- `POST /auth/refresh` : generer un nouvel access token depuis un refresh token ;
- `POST /auth/logout` : deconnecter un utilisateur.

### 11.2 Parametres utilisateur

- `PATCH /settings/users/{userId}/username` : modifier le nom d'utilisateur ;
- `PATCH /settings/users/{userId}/password` : modifier le mot de passe ;
- `DELETE /settings/users/{userId}` : supprimer le compte.

### 11.3 Musiques

- `POST /songs` : ajouter une musique en multipart avec `title`, `artist` et `file` ;
- `GET /songs` : lister les musiques ;
- `GET /songs/{songId}` : recuperer une musique ;
- `GET /songs/search?query=...` : rechercher une musique ;
- `GET /songs/random` : recuperer une musique aleatoire ;
- `GET /songs/{songId}/stream` : streamer le fichier audio ;
- `DELETE /songs/{songId}` : supprimer une musique.

### 11.4 Playlists

- `POST /playlists?userId=...` : creer une playlist ;
- `GET /playlists?username=...` : lister les playlists d'un utilisateur ;
- `GET /playlists/{playlistId}?username=...` : consulter une playlist ;
- `PATCH /playlists/{playlistId}?username=...` : renommer une playlist ;
- `DELETE /playlists/{playlistId}?username=...` : supprimer une playlist ;
- `POST /playlists/{playlistId}/song?username=...` : ajouter une musique a une playlist ;
- `DELETE /playlists/{playlistId}/song?username=...` : retirer une musique d'une playlist.

## 12. Parcours utilisateur principaux

### 12.1 Connexion

1. L'utilisateur ouvre l'application mobile.
2. Il saisit son nom d'utilisateur et son mot de passe.
3. Le backend valide les identifiants.
4. Le backend retourne une session avec access token et refresh token.
5. L'utilisateur accede aux fonctionnalites protegees.

### 12.2 Ecouter une musique

1. L'utilisateur accede a l'accueil.
2. L'application charge les musiques depuis `GET /songs`.
3. L'utilisateur selectionne une musique.
4. Le lecteur utilise l'URL de streaming de la musique.
5. Le backend renvoie la ressource audio.

### 12.3 Creer et utiliser une playlist

1. L'utilisateur ouvre la section playlists.
2. Il cree une playlist avec un titre.
3. Il ajoute des musiques via l'endpoint de liaison playlist/musique.
4. Il peut consulter, renommer ou supprimer la playlist.

### 12.4 Modifier son compte

1. L'utilisateur ouvre les parametres.
2. Il choisit de modifier son nom, son mot de passe ou de supprimer son compte.
3. Le backend valide la requete.
4. Les donnees sont mises a jour ou supprimees en base.

## 13. Priorites de developpement

### Version actuelle

- backend REST Spring Boot ;
- authentification avec JWT et refresh token ;
- creation de compte et connexion ;
- catalogue musical ;
- recherche ;
- streaming audio ;
- upload et suppression de musiques ;
- creation et gestion de playlists ;
- application mobile Flutter avec ecrans principaux.

### Prochaines priorites

- utiliser l'utilisateur authentifie depuis le JWT au lieu de `userId` ou `username` dans les routes sensibles ;
- externaliser la cle JWT ;
- ajouter une gestion de roles pour reserver l'ajout et la suppression de musiques a un administrateur ;
- corriger et aligner le client Flutter avec la forme exacte des reponses backend si necessaire ;
- ajouter des tests automatises ;
- documenter les erreurs API ;
- finaliser une configuration CORS de production.

### Evolutions possibles

- interface administrateur ;
- pochettes, albums, durees et autres metadonnees musicales ;
- favoris dedies ;
- recommandations ;
- historique d'ecoute ;
- partage de playlists ;
- mode hors ligne.

## 14. Criteres d'acceptation

Le projet est considere fonctionnel pour son etat actuel si :

- un utilisateur peut creer un compte ;
- un utilisateur peut se connecter ;
- les routes protegees refusent les requetes non authentifiees ;
- un utilisateur authentifie peut consulter la liste des musiques ;
- un utilisateur authentifie peut rechercher une musique ;
- un utilisateur authentifie peut lancer le streaming d'une musique ;
- un utilisateur authentifie peut creer une playlist ;
- un utilisateur authentifie peut ajouter et retirer des musiques d'une playlist ;
- un utilisateur authentifie peut renommer et supprimer une playlist ;
- un utilisateur peut modifier ses parametres de compte ;
- les donnees sont persistantes en base PostgreSQL ;
- les fichiers audio ajoutes sont stockes et accessibles par l'endpoint de streaming.

## 15. Livrables attendus

Livrables actuels ou attendus pour la version presente :

- backend Spring Boot fonctionnel ;
- configuration PostgreSQL ;
- application mobile Flutter ;
- documentation des routes API ;
- cahier des charges a jour ;
- scenario de demonstration ;
- jeux de tests ou tests automatises principaux.

Livrables non prioritaires dans l'etat actuel :

- site web PC ;
- interface d'administration complete ;
- systeme de roles avance.

## 16. Risques et points d'attention

- La securite doit etre renforcee avant production, notamment la cle JWT et les droits administrateur.
- Les routes qui prennent `userId` ou `username` doivent etre migrees vers l'utilisateur authentifie.
- Le client Flutter doit envoyer l'en-tete `Authorization: Bearer ...` pour les routes protegees.
- Le format des reponses d'authentification doit rester coherent entre backend et client mobile.
- Le streaming audio doit etre surveille pour eviter les problemes de memoire ou de performance.
- La gestion des fichiers audio doit rester robuste en cas de suppression de musique ou de deplacement du dossier de stockage.
- Le CORS doit etre adapte aux domaines reels de deploiement.

## 17. Planning indicatif

| Phase | Contenu | Duree estimee |
| --- | --- | --- |
| Stabilisation backend | JWT, routes utilisateur, erreurs API, roles | 1 semaine |
| Stabilisation mobile | alignement auth, headers JWT, parcours playlists | 1 semaine |
| Tests | auth, musiques, playlists, streaming | 1 semaine |
| Documentation | routes API, installation, demonstration | 2 a 3 jours |
| Evolutions | web, admin, metadonnees, favoris | selon priorite |

## 18. Conclusion

NotSpot est actuellement une application musicale orientee mobile, avec un backend Spring Boot securise par JWT et une base PostgreSQL. Le coeur fonctionnel est deja centre sur les parcours essentiels : creer un compte, se connecter, consulter des musiques, streamer un titre et organiser des playlists. Les prochains efforts doivent surtout stabiliser la securite, aligner totalement le client mobile avec les reponses backend et documenter les routes existantes.
