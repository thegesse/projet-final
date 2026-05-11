# Cahier des charges - NotSpot

## 1. Presentation du projet

NotSpot est une application de streaming musical inspiree de Spotify, disponible sur mobile et sur site web pour ordinateur. Le projet permet aux utilisateurs de creer un compte, se connecter, ecouter des musiques, rechercher des titres, consulter des playlists et gerer leur bibliotheque personnelle.

Le produit doit proposer une experience fluide sur deux supports :

- application mobile pour une utilisation quotidienne en deplacement ;
- site web PC pour une utilisation confortable sur grand ecran.

## 2. Objectifs

### 2.1 Objectif principal

Developper une plateforme musicale complete permettant l'ecoute de titres audio, la gestion de playlists et l'administration des contenus musicaux.

### 2.2 Objectifs secondaires

- proposer une interface moderne, simple et responsive ;
- permettre la creation et la gestion de comptes utilisateurs ;
- permettre la recherche de musiques ;
- permettre la lecture audio en streaming ;
- permettre la creation, consultation et suppression de playlists ;
- assurer la securite des comptes et des donnees ;
- fournir une API backend reutilisable par le site web et l'application mobile.

## 3. Public cible

Le service s'adresse principalement :

- aux utilisateurs qui souhaitent ecouter de la musique depuis un telephone ou un ordinateur ;
- aux utilisateurs qui veulent organiser leurs titres dans des playlists ;
- aux administrateurs ou contributeurs charges d'ajouter, modifier ou supprimer des musiques.

## 4. Perimetre fonctionnel

### 4.1 Fonctionnalites utilisateur

#### Creation de compte

L'utilisateur doit pouvoir creer un compte avec les informations suivantes :

- nom d'utilisateur ;
- adresse e-mail ;
- mot de passe.

Le systeme doit verifier que les donnees sont valides et que le compte n'existe pas deja.

#### Connexion

L'utilisateur doit pouvoir se connecter avec ses identifiants. Apres connexion, il accede aux fonctionnalites protegees de l'application.

#### Gestion du compte

L'utilisateur doit pouvoir :

- modifier son nom d'utilisateur ;
- modifier son mot de passe ;
- supprimer son compte.

La suppression du compte doit demander une confirmation.

### 4.2 Fonctionnalites musicales

#### Catalogue de musiques

L'application doit afficher une liste de musiques disponibles avec au minimum :

- titre ;
- artiste ;
- duree ;
- image ou couverture si disponible ;
- identifiant unique de la musique.

#### Recherche de musiques

L'utilisateur doit pouvoir rechercher une musique par :

- titre ;
- artiste ;
- mots-cles.

Les resultats doivent etre affiches rapidement et de maniere lisible.

#### Lecture audio

L'utilisateur doit pouvoir lire une musique en streaming depuis le backend.

Le lecteur audio doit proposer :

- lecture ;
- pause ;
- progression du morceau ;
- volume ;
- passage au titre suivant ou precedent si une file d'attente existe.

### 4.3 Fonctionnalites playlists

#### Creation de playlist

L'utilisateur doit pouvoir creer une playlist avec :

- un nom ;
- une description facultative ;
- une liste de musiques.

#### Consultation de playlist

L'utilisateur doit pouvoir consulter :

- ses playlists ;
- le detail d'une playlist ;
- les titres presents dans une playlist.

#### Modification de playlist

L'utilisateur doit pouvoir :

- ajouter une musique a une playlist ;
- retirer une musique d'une playlist ;
- modifier le nom d'une playlist ;
- supprimer une playlist.

### 4.4 Fonctionnalites administrateur

Un administrateur doit pouvoir :

- ajouter une musique au catalogue ;
- supprimer une musique ;
- consulter la liste complete des musiques ;
- gerer les contenus non valides ou obsoletes.

Ces fonctionnalites doivent etre protegees par des droits specifiques.

## 5. Interfaces attendues

### 5.1 Application mobile

L'application mobile doit proposer les ecrans suivants :

- ecran de connexion ;
- ecran d'inscription ;
- accueil avec recommandations ou musiques recentes ;
- recherche ;
- detail d'une musique ;
- lecteur audio ;
- liste des playlists ;
- detail d'une playlist ;
- profil utilisateur ;
- parametres du compte.

L'interface mobile doit etre adaptee a une navigation tactile avec des boutons suffisamment grands et une navigation simple.

### 5.2 Site web PC

Le site web doit proposer :

- une barre laterale de navigation ;
- une page d'accueil ;
- une page de recherche ;
- une page catalogue ;
- une page playlists ;
- un lecteur audio persistant en bas de l'ecran ;
- une page profil ;
- une interface d'administration si l'utilisateur a les droits.

Le site doit etre responsive afin de rester utilisable sur tablette et petits ecrans.

## 6. Exigences techniques

### 6.1 Backend

Le backend est une API REST developpee avec Spring Boot.

Technologies prevues ou deja presentes :

- Java 21 ;
- Spring Boot ;
- Spring Web MVC ;
- Spring Security ;
- Spring Data JPA ;
- PostgreSQL ;
- Lombok ;
- Maven.

Le backend doit exposer des endpoints pour :

- l'authentification ;
- la gestion des utilisateurs ;
- la gestion des musiques ;
- le streaming audio ;
- la gestion des playlists.

### 6.2 Base de donnees

La base de donnees doit stocker :

- les utilisateurs ;
- les musiques ;
- les playlists ;
- les relations entre playlists et musiques ;
- les roles ou droits des utilisateurs si necessaire.

Base de donnees utilisee : PostgreSQL.

### 6.3 Frontend web

Le frontend web PC est developpe avec :

- JavaScript ;
- HTML ;
- CSS ;
- React ;

Il doit consommer l'API REST du backend.

### 6.4 Application mobile

L'application mobile est developpee avec :

- Dart ;
- Flutter ;

Elle doit consommer la meme API REST que le site web.

## 7. Architecture generale

Architecture cible :

- client mobile Flutter/Dart ;
- client web PC React, HTML, CSS et JavaScript ;
- API backend Spring Boot ;
- base de donnees PostgreSQL ;
- stockage des fichiers audio ;
- service de streaming audio.

Le backend doit centraliser les regles metier afin que le web et le mobile utilisent le meme comportement.

## 8. Securite

Le projet doit respecter les principes suivants :

- mots de passe hashes, jamais stockes en clair ;
- routes sensibles protegees par authentification ;
- validation des donnees envoyees par les clients ;
- controle des droits pour les actions administrateur ;
- protection contre les acces non autorises aux comptes et playlists ;
- configuration CORS controlee pour le web et le mobile ;
- messages d'erreur clairs sans fuite d'informations sensibles.

## 9. Contraintes non fonctionnelles

### 9.1 Performance

- Le temps de chargement des pages principales doit rester court.
- La lecture audio doit commencer rapidement.
- La recherche doit retourner les resultats sans delai excessif.
- Le backend doit eviter de charger des fichiers audio complets en memoire si un streaming par flux est possible.

### 9.2 Ergonomie

- Interface claire et moderne.
- Navigation simple.
- Boutons et controles audio accessibles.
- Design coherent entre mobile et web.
- Lecteur visible pendant la navigation.

### 9.3 Compatibilite

- Site web compatible avec les navigateurs modernes.
- Application mobile compatible Android au minimum.
- Possibilite d'etendre a iOS selon le temps disponible.

### 9.4 Maintenabilite

- Code organise par couches : controller, service, repository, model.
- DTO utilises pour separer l'API des entites internes.
- Nommage clair des classes, methodes et routes.
- Tests sur les fonctionnalites principales.

## 10. Donnees principales

### 10.1 Utilisateur

Champs possibles :

- id ;
- username ;
- email ;
- passwordHash ;
- role ;
- dateCreation.

### 10.2 Musique

Champs possibles :

- id ;
- title ;
- artist ;
- album ;
- duration ;
- audioPath ;
- coverPath ;
- createdAt.

### 10.3 Playlist

Champs possibles :

- id ;
- name ;
- description ;
- ownerId ;
- songs ;
- createdAt ;
- updatedAt.

## 11. API attendue

Les routes exactes peuvent evoluer, mais l'API doit couvrir les besoins suivants :

### 11.1 Authentification

- `POST /auth/register` : creer un compte ;
- `POST /auth/login` : connecter un utilisateur ;
- `POST /auth/logout` : deconnecter un utilisateur si necessaire.

### 11.2 Utilisateurs

- `GET /users/me` : recuperer le profil connecte ;
- `PATCH /users/me/name` : modifier le nom ;
- `PATCH /users/me/password` : modifier le mot de passe ;
- `DELETE /users/me` : supprimer le compte.

### 11.3 Musiques

- `GET /songs` : lister les musiques ;
- `GET /songs/{id}` : recuperer une musique ;
- `GET /songs/search?q=...` : rechercher une musique ;
- `POST /songs` : ajouter une musique ;
- `DELETE /songs/{id}` : supprimer une musique ;
- `GET /songs/{id}/stream` : streamer le fichier audio.

### 11.4 Playlists

- `GET /playlists` : lister les playlists de l'utilisateur ;
- `GET /playlists/{id}` : consulter une playlist ;
- `POST /playlists` : creer une playlist ;
- `PATCH /playlists/{id}` : modifier une playlist ;
- `POST /playlists/{id}/songs` : ajouter une musique ;
- `DELETE /playlists/{id}/songs/{songId}` : retirer une musique ;
- `DELETE /playlists/{id}` : supprimer une playlist.

## 12. Parcours utilisateur principaux

### 12.1 Ecouter une musique

1. L'utilisateur ouvre l'application.
2. Il se connecte ou accede a l'accueil si deja connecte.
3. Il recherche ou selectionne une musique.
4. Il appuie sur lecture.
5. Le lecteur audio demarre le streaming.

### 12.2 Creer une playlist

1. L'utilisateur ouvre la page playlists.
2. Il clique sur creer une playlist.
3. Il saisit un nom.
4. Il ajoute des musiques.
5. La playlist est sauvegardee et consultable.

### 12.3 Modifier son compte

1. L'utilisateur ouvre son profil.
2. Il choisit l'option a modifier.
3. Il confirme la modification.
4. Le backend valide et sauvegarde le changement.

## 13. Priorites de developpement

### Version 1 - MVP

- creation de compte ;
- connexion ;
- liste des musiques ;
- recherche ;
- streaming audio ;
- creation et consultation de playlists ;
- site web responsive ;
- application mobile basique.

### Version 2

- modification complete des playlists ;
- lecteur audio avance ;
- file d'attente ;
- favoris ;
- interface administrateur ;
- amelioration du design.

### Version 3

- recommandations ;
- historique d'ecoute ;
- mode hors ligne si faisable ;
- statistiques d'ecoute ;
- partage de playlists.

## 14. Criteres d'acceptation

Le projet sera considere comme fonctionnel si :

- un utilisateur peut creer un compte et se connecter ;
- un utilisateur peut consulter une liste de musiques ;
- un utilisateur peut lancer la lecture d'une musique ;
- un utilisateur peut rechercher une musique ;
- un utilisateur peut creer une playlist ;
- un utilisateur peut ajouter des musiques dans une playlist ;
- le site web est utilisable sur ordinateur ;
- l'application mobile est utilisable sur smartphone ;
- les routes sensibles sont protegees ;
- les donnees sont persistantes en base de donnees.

## 15. Livrables attendus

- backend Spring Boot fonctionnel ;
- base de donnees configuree ;
- documentation des routes API ;
- site web PC ;
- application mobile ;
- cahier des charges ;
- maquettes ou captures des interfaces ;
- guide d'installation ;
- jeux de tests ou scenario de demonstration.

## 16. Risques et points d'attention

- Gestion du streaming audio : attention aux performances et a la memoire.
- Securite des comptes : le hashage des mots de passe est obligatoire.
- Synchronisation web/mobile : les deux clients doivent utiliser les memes routes API.
- Gestion des fichiers audio : definir clairement ou sont stockes les fichiers.
- Droits administrateur : eviter que tous les utilisateurs puissent ajouter ou supprimer des musiques.
- Ergonomie du lecteur : le controle audio doit rester accessible pendant la navigation.

## 17. Planning indicatif

| Phase | Contenu | Duree estimee |
| --- | --- | --- |
| Analyse | Besoins, cahier des charges, modelisation | 1 semaine |
| Backend MVP | Utilisateurs, musiques, playlists, streaming | 2 a 3 semaines |
| Frontend web | Interface PC et integration API | 2 semaines |
| Mobile | Interface mobile et integration API | 2 semaines |
| Tests | Correction, securite, validation | 1 semaine |
| Finalisation | Documentation, demo, rendu final | 1 semaine |

## 18. Conclusion

NotSpot a pour objectif de fournir une plateforme musicale simple, moderne et multi-support. Le coeur du projet repose sur une API backend stable, reutilisee par le site web et l'application mobile. La priorite doit etre donnee au parcours principal : creer un compte, trouver une musique, l'ecouter et organiser ses titres dans des playlists.
