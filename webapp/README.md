# weebi webapp

Billing and licences: lifetime licence purchase (no subscriptions) + pay-as-you-go credits — see [../docs/commercial-model.md](../docs/commercial-model.md).

``` shell
# main / main_local: use lib/config/api_url.dart (kApiUrl)
flutter run -t lib/main_local.dart
flutter run -d web-server -t lib/main_local.dart
flutter run

# main_dev: always dev Envoy (kApiUrlDev), regardless of kApiUrl
flutter run -t lib/main_dev.dart
flutter run -d web-server -t lib/main_dev.dart
```

If `flutter run -d edge ...` fails while launching Edge, use the `web-server`
device and open the printed local URL manually. You can pin host/port when
needed with `--web-hostname=127.0.0.1 --web-port=50858`.

## Configuration

The webapp calls the **Envoy proxy** (gRPC-Web), which forwards to weebi_server. API_URL is set in `lib/config/api_url.dart` (`kApiUrl`). Change it when merging dev ↔ prod. Use `lib/main_dev.dart` to hit dev while `kApiUrl` is prod (or vice versa). See [SECRETS.md](SECRETS.md).

## Localization (intl)

| | Path |
|---|------|
| **Source (edit these)** | `lib/l10n/` — `intl_en.arb` (main locale), `intl_fr.arb`, `intl_zh_Hans.arb`, … |
| **Generated (do not edit by hand)** | `lib/generated/` — `l10n.dart`, `intl/messages_*.dart` |

1. Change strings in **`lib/l10n/*.arb`** only.
2. Regenerate: **Flutter Intl** extension → command palette → **Flutter Intl: Generate** (refreshes **`lib/generated/`** from the ARBs).  
   *Optional CLI (no pubspec entry):* `dart pub global activate intl_utils` then `dart pub global run intl_utils:generate` from the project root.
3. Commit **both** `lib/l10n/` and `lib/generated/`.

At runtime the app reads **`Lang`** from **`lib/generated/`**; the `.arb` files are not loaded by the app.


## web packages to consider

- DataCell View : https://github.com/caduandrade/davi_flutter
- Responsive : https://pub.dev/packages/responsive_builder

## Other open source flutter-web projects

Depending on your need, you might also want to look at :

- Invoice tracking - https://github.com/invoiceninja/admin-portal
- ERP & Apache OFBiz - https://github.com/growerp/growerp
- personnal finance - https://github.com/jogboms/ovavue

****

## Flutter Web Admin Portal

Responsive web with light/dark mode and multi language supported. The objective of this project is to develop an admin portal website with Flutter v3 (SDK version 3.19.3).
https://user-images.githubusercontent.com/12734486/174944388-5b80f3c6-187a-4e98-89e3-34180ac61379.mp4

Flutter Web Admin Portal [Website Demo](https://kcflutterwebadmin.surge.sh)

Login with demo account:\
Username: admin
Password: admin

## README : Déploiement d'une application Flutter web avec Docker

### Introduction

Ce document explique comment utiliser Docker pour construire et exécuter une application Flutter web. Les deux commandes clés sont :

- **`docker build -t flutter-web-app .`** : Construit une image Docker à partir du contexte actuel (le point "." représente le répertoire courant) et lui attribue le nom `flutter-web-app`.
- **`docker run -d -p 8080:80 --name flutter-web-app flutter-web-app`** : Exécute l'image Docker en mode détaché (`-d`), expose le port 80 du conteneur sur le port 8080 de votre hôte (`-p 8080:80`) et donne au conteneur le nom `flutter-web-app`.

### Détail des commandes

#### `docker build -t flutter-web-app .`

- **`docker build`** : Cette commande lance le processus de construction d'une image Docker.
- **`-t flutter-web-app`** : Cet argument spécifie le nom de l'image Docker à créer. Vous pouvez remplacer `flutter-web-app` par un nom plus descriptif si vous le souhaitez.
- **`.`** : Ce point indique que le contexte de construction est le répertoire courant. Docker va rechercher votre fichier `Dockerfile` dans ce répertoire pour obtenir les instructions de construction.

#### `docker run -d -p 8080:80 --name flutter-web-app flutter-web-app`

- **`docker run`** : Cette commande exécute un conteneur à partir d'une image Docker.
- **`-d`** : Cet argument démarre le conteneur en mode détaché, c'est-à-dire en arrière-plan.
- **`-p 8080:80`** : Cet argument mappe le port 80 du conteneur (celui sur lequel votre application Flutter web écoute) au port 8080 de votre machine hôte. Cela vous permet d'accéder à votre application en vous rendant sur `http://localhost:8080` dans votre navigateur.
- **`--name flutter-web-app`** : Cet argument donne un nom au conteneur. Cela facilite sa gestion et son identification.
- **`flutter-web-app`** : C'est le nom de l'image Docker que vous avez construite à l'étape précédente.

### Prérequis

- **Docker installé** : Assurez-vous que Docker est installé et en cours d'exécution sur votre machine.
- **Un fichier Dockerfile** : Ce fichier, situé à la racine de votre projet Flutter, contient les instructions pour construire l'image Docker. Il spécifie généralement l'image de base, les dépendances à installer et le point d'entrée de votre application.

### Utilisation

1. **Ouvrez votre terminal** et placez-vous dans le répertoire racine de votre projet Flutter.
2. **Exécutez la première commande** pour construire l'image Docker :
   - `docker build -t flutter-web-app . --dart-define=ENVIRONMENT=development`
3. Exécutez la deuxième commande pour démarrer le conteneur (API_URL from env/secret):
   - `docker run -d -p 8080:8080 -e API_URL=$ENVOY_URL --name weebi-web-dev weebi-web-dev`
4. Accédez à votre application en ouvrant votre navigateur et en vous rendant sur http://localhost:8080.

## debug 
proto tip check https://github.com/RexSkz/proto-message-helper