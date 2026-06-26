# Documentation technique - Architecture et implementation NotSpot

## 1. Objectif du document

Ce document decrit l'architecture technique de NotSpot et les choix d'implementation observes dans l'etat actuel du projet.

Il complete le cahier des charges en detaillant :

- l'organisation du backend Spring Boot ;
- l'organisation du client mobile Flutter ;
- les flux principaux entre le client, l'API, la base de donnees et le stockage audio ;
- la securite ;
- la persistance ;
- les points techniques a stabiliser.

## 2. Vue d'ensemble de l'architecture

NotSpot suit une architecture client-serveur.

Composants principaux :

- application mobile Flutter : interface utilisateur et appels API ;
- API REST Spring Boot : logique metier, securite et exposition des routes ;
- PostgreSQL : stockage des donnees relationnelles ;
- systeme de fichiers : stockage des fichiers audio ;
- Spring Security + JWT : authentification des routes protegees.

Flux general d'une requete :

1. L'utilisateur effectue une action dans l'application Flutter.
2. Le client construit une requete HTTP avec `ApiClient` et les URLs definies dans `AppConfig`.
3. Le backend recoit la requete dans un controller.
4. Si la route est protegee, `JwtAuthFilter` tente de valider le token JWT.
5. Le controller appelle un service metier.
6. Le service utilise un repository JPA ou un service de stockage fichier.
7. Le backend retourne une reponse HTTP, generalement sous forme de DTO.

## 3. Structure du backend

Le backend est situe dans :

```text
notSpot/src/main/java/com/goose/notspot
```

Organisation principale :

```text
configuration/
controller/
model/
repository/
service/
```

Role des dossiers :

- `configuration` contient la configuration Spring Security, CORS et le filtre JWT ;
- `controller` contient les points d'entree HTTP de l'API REST ;
- `model` contient les entites JPA, DTO, objets de requete et objets de reponse ;
- `repository` contient les interfaces Spring Data JPA ;
- `service` contient la logique metier.

## 4. Controllers backend

### 4.1 AuthController

Route de base :

```text
/auth
```

Responsabilites :

- inscription ;
- connexion ;
- rafraichissement de session ;
- deconnexion.

Endpoints :

- `POST /auth/register` ;
- `POST /auth/login` ;
- `POST /auth/refresh` ;
- `POST /auth/logout`.

### 4.2 SongController

Route de base :

```text
/songs
```

Responsabilites :

- ajout d'une musique ;
- liste du catalogue ;
- consultation d'une musique ;
- recherche ;
- recuperation aleatoire ;
- streaming ;
- suppression.

Endpoints :

- `POST /songs` ;
- `GET /songs` ;
- `GET /songs/{songId}` ;
- `GET /songs/search?query=...` ;
- `GET /songs/random` ;
- `GET /songs/{songId}/stream` ;
- `DELETE /songs/{songId}`.

### 4.3 PlaylistController

Route de base :

```text
/playlists
```

Responsabilites :

- creation de playlist ;
- liste des playlists d'un utilisateur ;
- detail d'une playlist ;
- renommage ;
- suppression ;
- ajout d'une musique ;
- retrait d'une musique.

Endpoints :

- `POST /playlists?userId=...` ;
- `GET /playlists?username=...` ;
- `GET /playlists/{playlistId}?username=...` ;
- `PATCH /playlists/{playlistId}?username=...` ;
- `DELETE /playlists/{playlistId}?username=...` ;
- `POST /playlists/{playlistId}/song?username=...` ;
- `DELETE /playlists/{playlistId}/song?username=...`.

### 4.4 UserSettingsController

Route de base :

```text
/settings
```

Responsabilites :

- modification du nom d'utilisateur ;
- modification du mot de passe ;
- suppression du compte.

Endpoints :

- `PATCH /settings/users/{userId}/username` ;
- `PATCH /settings/users/{userId}/password` ;
- `DELETE /settings/users/{userId}`.

## 5. Services backend

Les services portent la logique metier afin de garder les controllers simples.

Services d'authentification :

- `AuthService` gere l'inscription, la connexion, le refresh et la deconnexion ;
- `UserCreationService` cree les utilisateurs ;
- `AppUserDetailsService` recharge un utilisateur pour Spring Security ;
- `JwtService` genere et valide les access tokens ;
- `RefreshTokenService` cree, verifie et supprime les refresh tokens.

Services de musiques :

- `GetAllSongs` liste les musiques ;
- `GetSong` recupere une musique ;
- `SearchSongService` recherche dans le catalogue ;
- `GetRandomSong` retourne une musique aleatoire ;
- `AddSongService` orchestre l'ajout d'une musique ;
- `StoreSongService` stocke, charge et supprime les fichiers audio ;
- `DeleteSong` supprime une musique et son fichier ;
- `StreamSongService` prepare la ressource audio a streamer.

Services de playlists :

- `GetAllPlaylists` liste les playlists d'un utilisateur ;
- `GetPlaylist` recupere le detail d'une playlist ;
- `PlaylistCreationService` cree une playlist ;
- `ChangePlaylistNameService` renomme une playlist ;
- `PlaylistDeleteService` supprime une playlist ;
- `AddSongToPlaylistService` ajoute une musique ;
- `RemoveSongInPlaylistService` retire une musique.

Services de parametres utilisateur :

- `ChangeNameService` modifie le nom d'utilisateur ;
- `ChangePasswordService` modifie le mot de passe ;
- `DeleteAccService` supprime le compte.

## 6. Modele de donnees

La persistance est geree avec Spring Data JPA et PostgreSQL.

### 6.1 User

Table :

```text
app_users
```

Champs principaux :

- `id` ;
- `username` ;
- `password` ;
- `email` ;
- `playlists`.

Relations :

- un utilisateur possede plusieurs playlists.

### 6.2 Song

Table :

```text
songs
```

Champs principaux :

- `id` ;
- `title` ;
- `artist` ;
- `audioPath` ;
- `contentType` ;
- `fileSize`.

### 6.3 Playlist

Table :

```text
playlists
```

Champs principaux :

- `id` ;
- `title` ;
- `owner` ;
- `songs`.

Relations :

- une playlist appartient a un utilisateur ;
- une playlist contient plusieurs musiques ;
- la relation playlist/musique est materialisee par la table `playlist_songs`.

### 6.4 RefreshToken

Table :

```text
refresh_token
```

Champs principaux :

- `id` ;
- `user` ;
- `token` ;
- `expiryDate`.

## 7. Repositories

Les repositories isolent l'acces aux donnees.

Repositories actuels :

- `UserRepository` ;
- `SongRepository` ;
- `PlaylistRepository` ;
- `RefreshTokenRepository`.

Ils sont utilises par les services pour rechercher, creer, modifier ou supprimer les entites.

## 8. Securite

La securite est configuree dans `SecurityConfig`.

Principes :

- API stateless ;
- CSRF desactive ;
- mots de passe hashes avec BCrypt ;
- access tokens JWT ;
- refresh tokens stockes en base ;
- filtre JWT execute avant `UsernamePasswordAuthenticationFilter`.

Routes publiques :

```text
/auth/**
```

Routes protegees :

```text
/songs/**
/playlists/**
/settings/**
```

Toutes les autres routes demandent aussi une authentification.

Origines CORS configurees actuellement :

- `http://localhost:3000` ;
- `http://localhost:8080` ;
- `https://your-notspot-app.com`.

Methodes CORS autorisees :

- `GET` ;
- `POST` ;
- `PUT` ;
- `DELETE` ;
- `OPTIONS` ;
- `PATCH`.

En-tetes autorises :

- `Authorization` ;
- `Content-Type` ;
- `Cache-Control`.

## 9. Flux d'authentification

### 9.1 Inscription

1. Le client appelle `POST /auth/register`.
2. `AuthController` transmet la requete a `AuthService`.
3. `UserCreationService` cree l'utilisateur.
4. Le mot de passe est hashe avec BCrypt.
5. `JwtService` genere un access token.
6. `RefreshTokenService` genere un refresh token.
7. Le backend retourne une `LoginResponse`.

### 9.2 Connexion

1. Le client appelle `POST /auth/login`.
2. `AuthService` recherche l'utilisateur par son nom.
3. Le mot de passe fourni est compare au hash stocke.
4. Un access token et un refresh token sont generes.
5. Le backend retourne les informations de session.

### 9.3 Requete protegee

1. Le client envoie une requete avec l'en-tete `Authorization: Bearer <token>`.
2. `JwtAuthFilter` extrait le token.
3. `JwtService` extrait le username et verifie l'expiration.
4. `AppUserDetailsService` recharge l'utilisateur.
5. Spring Security place l'utilisateur dans le contexte de securite.
6. La requete atteint le controller.

### 9.4 Refresh token

1. Le client appelle `POST /auth/refresh`.
2. Le backend recherche le refresh token en base.
3. `RefreshTokenService` verifie son expiration.
4. Un nouvel access token est genere.
5. Le meme refresh token est conserve dans la reponse.

## 10. Flux des musiques

### 10.1 Ajout d'une musique

1. Le client envoie une requete multipart sur `POST /songs`.
2. La requete contient `title`, `artist` et `file`.
3. `SongController` construit un `CreateSongRequest`.
4. `AddSongService` orchestre la creation.
5. `StoreSongService` verifie que le fichier est audio.
6. Le fichier est sauvegarde dans le dossier configure par `app.song-storage.dir`.
7. Les metadonnees sont sauvegardees dans PostgreSQL.
8. Le backend retourne un `SongDTO`.

### 10.2 Streaming

1. Le client appelle `GET /songs/{songId}/stream`.
2. `StreamSongService` recherche la musique en base.
3. `StoreSongService` charge le fichier depuis `audioPath`.
4. Le backend retourne une ressource Spring `Resource`.
5. La reponse contient le type MIME et la taille du fichier.

### 10.3 Suppression

1. Le client appelle `DELETE /songs/{songId}`.
2. Le service recherche la musique.
3. Le fichier audio est supprime du disque si possible.
4. L'entite `Song` est supprimee de la base.

## 11. Flux des playlists

### 11.1 Creation

1. Le client appelle `POST /playlists?userId=...`.
2. Le backend recherche l'utilisateur.
3. Une playlist est creee avec un titre.
4. La playlist est associee a son proprietaire.
5. Le backend retourne un DTO court.

### 11.2 Consultation

1. Le client appelle `GET /playlists?username=...` pour la liste.
2. Le client appelle `GET /playlists/{playlistId}?username=...` pour le detail.
3. Les services verifient que la playlist correspond a l'utilisateur demande.
4. Le backend retourne les DTO `ShortPlaylistVisuals` ou `PlaylistVisuals`.

### 11.3 Ajout et retrait de musique

1. Le client appelle `/playlists/{playlistId}/song`.
2. Le corps contient l'identifiant de la musique.
3. Le backend recherche la playlist et la musique.
4. La relation many-to-many est modifiee.
5. Le backend retourne le detail mis a jour.

## 12. Structure du client Flutter

Le client mobile est situe dans :

```text
frontend_mobile/not_spot/lib
```

Organisation principale :

```text
core/
features/
ui/
```

### 12.1 core

Responsabilites :

- configuration globale ;
- client HTTP ;
- routage applicatif ;
- erreurs communes.

Fichiers importants :

- `core/config/app_config.dart` ;
- `core/network/api_client.dart` ;
- `core/router/app_router.dart`.

### 12.2 features

Le dossier `features` regroupe la logique par domaine.

Domaines actuels :

- `auth` ;
- `songs` ;
- `playlist` ;
- `settings`.

Chaque domaine contient selon le cas :

- `data` pour les appels API ;
- `models/domain` pour les modeles utilises dans l'application ;
- `models/dto` pour les objets recus ou envoyes a l'API ;
- `models/requests` ou `requests` pour les corps de requete ;
- `state` pour les controllers d'etat.

### 12.3 ui

Le dossier `ui` contient :

- les ecrans principaux ;
- les ecrans secondaires ;
- les widgets reutilisables.

Exemples :

- ecran d'accueil ;
- ecran de connexion ;
- ecran d'inscription ;
- ecran de playlist ;
- mini lecteur ;
- widgets de formulaire.

### 12.4 Lecture audio Flutter

La lecture audio est pilotee par :

```text
frontend_mobile/not_spot/lib/features/songs/state/song_controller.dart
```

Le controller utilise `just_audio` pour charger les URLs de streaming exposees par le backend. Le mini lecteur et l'ecran de lecture lisent l'etat courant depuis `SongController`.

Points d'attention :

- les commandes audio sont serialisees pour eviter les conflits entre chargement, pause, skip et stop ;
- il ne faut pas attendre `AudioPlayer.play()` dans cette file de commandes : sur Flutter web, l'appel peut rester en attente pendant la lecture et bloquer les actions suivantes comme pause ou skip ;
- la lecture doit donc etre lancee sans bloquer la file, via un appel non attendu (`unawaited`) ;
- sur web, le controller recrée le `AudioPlayer` lors d'un changement de morceau pour eviter qu'un element audio du navigateur reste attache a l'ancien flux ;
- sur mobile et Linux, le controller conserve une source concatenee (`ConcatenatingAudioSource`) afin de garder le comportement de playlist natif.

## 13. Communication Flutter/backend

`AppConfig` centralise les URLs de l'API.

Exemples :

- `loginUri()` vers `/auth/login` ;
- `registerUri()` vers `/auth/register` ;
- `songsUri()` vers `/songs` ;
- `songUri(songId)` vers `/songs/{songId}` ;
- `songStreamUri(songId)` vers `/songs/{songId}/stream` ;
- `playlistsUri(username: ...)` vers `/playlists?username=...` ;
- `playlistSongUri(...)` vers `/playlists/{playlistId}/song?username=...`.

`ApiClient` centralise les requetes JSON.

Dio est utilise pour l'upload multipart des fichiers audio.

Point d'attention : les routes protegees du backend demandent un JWT. Le client doit donc transmettre l'en-tete suivant pour les appels authentifies :

```text
Authorization: Bearer <accessToken>
```

## 14. Configuration

### 14.1 Backend

Fichier principal :

```text
notSpot/src/main/resources/application.properties
```

Variables disponibles :

- `SERVER_PORT` : port du serveur, `8080` par defaut ;
- `SPRING_DATASOURCE_URL` : URL PostgreSQL ;
- `SPRING_DATASOURCE_USERNAME` : utilisateur PostgreSQL ;
- `SPRING_DATASOURCE_PASSWORD` : mot de passe PostgreSQL ;
- `SPRING_JPA_HIBERNATE_DDL_AUTO` : mode Hibernate ;
- `SONG_STORAGE_DIR` : dossier de stockage des fichiers audio ;
- `SPRING_SERVLET_MULTIPART_MAX_FILE_SIZE` : taille maximale d'un fichier ;
- `SPRING_SERVLET_MULTIPART_MAX_REQUEST_SIZE` : taille maximale d'une requete multipart.

### 14.2 Mobile

La configuration mobile se trouve dans :

```text
frontend_mobile/not_spot/lib/core/config/app_config.dart
```

La variable `API_BASE_URL` peut etre fournie au build Flutter. Sinon, l'application utilise l'URL par defaut declaree dans `AppConfig`.

## 15. Lancement du projet

### 15.1 Backend recommande pour tester le frontend

Pour tester le frontend Flutter actuel, il est recommande d'utiliser le backend stable maintenu dans le repository suivant :

[https://github.com/thegesse/back-end-not-spot/tree/master](https://github.com/thegesse/back-end-not-spot/tree/master)

Le backend present dans ce depot est en cours de refonte. Il n'est pas encore termine ni entierement teste avec le frontend actuel. Le frontend n'a pas encore ete adapte a toutes les differences de ce backend local.

Exemple de recuperation :

```sh
git clone https://github.com/thegesse/back-end-not-spot.git
cd back-end-not-spot
git checkout master
```

Suivre ensuite les instructions de ce repository pour configurer PostgreSQL et lancer l'API.

### 15.2 Backend de ce depot

Depuis la racine du backend :

```sh
cd notSpot
./mvnw spring-boot:run
```

Pre-requis :

- Java 21 ;
- PostgreSQL disponible ;
- variables de connexion configurees ou valeurs par defaut utilisables.

Ce backend est utile pour travailler sur la refonte backend, mais il ne doit pas etre considere comme la reference pour tester le frontend actuel tant que les contrats API ne sont pas totalement alignes.

### 15.3 Application Flutter

Depuis la racine du projet :

```sh
cd ../frontend_mobile/not_spot
flutter pub get
flutter run
```

Pour tester en web :

```sh
flutter run -d chrome --web-port 3000
```

Pour pointer le frontend vers un backend local specifique :

```sh
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

Pre-requis :

- Flutter installe ;
- backend accessible depuis l'URL configuree dans `AppConfig`.

### 15.4 CORS avec Flutter web

CORS est necessaire lorsque le frontend est lance avec Chrome, car le navigateur applique la politique same-origin. Par exemple :

- frontend Flutter web : `http://localhost:3000` ;
- backend API : `http://localhost:8080`.

Ces deux URLs ont des origines differentes, donc le backend doit autoriser l'origine du frontend.

Dans le backend de ce depot, la configuration CORS est definie dans :

```text
backend/notSpot/src/main/java/com/goose/notspot/configuration/SecurityConfig.java
```

La liste `setAllowedOrigins(...)` contient deja `http://localhost:3000`. Il est donc recommande de lancer Flutter web avec un port fixe :

```sh
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

Si un autre port est utilise par Flutter web, il faut ajouter l'origine correspondante dans la configuration CORS du backend, par exemple `http://localhost:54321`.

## 16. Choix d'implementation

Choix principaux :

- Spring Boot pour exposer une API REST structuree ;
- Spring Security pour centraliser les regles d'authentification ;
- JWT pour eviter les sessions serveur ;
- refresh tokens en base pour prolonger une session ;
- PostgreSQL pour la persistance relationnelle ;
- DTO pour separer l'API des entites JPA ;
- stockage local des fichiers audio pour simplifier la premiere version ;
- Flutter pour fournir un client mobile multiplateforme.

## 17. Limites techniques et ameliorations

Limites actuelles :

- les roles administrateur ne sont pas encore modelises ;
- certaines routes sensibles dependent encore de `userId` ou `username` fournis par le client ;
- l'ajout et la suppression de musiques ne sont pas reserves a un administrateur ;
- les erreurs API ne sont pas encore uniformisees dans un format commun ;
- le stockage local des fichiers audio peut devenir limitant en production ;
- la configuration CORS contient encore une URL generique de production.

Ameliorations recommandees :

- deduire l'utilisateur courant depuis le JWT pour les routes sensibles ;
- ajouter des roles et permissions ;
- uniformiser les reponses d'erreur ;
- ajouter des tests d'integration sur l'authentification, les playlists, les musiques et le streaming ;
- documenter l'API avec OpenAPI ou une collection de requetes ;
- prevoir un stockage objet ou un volume persistant pour les fichiers audio en production.
