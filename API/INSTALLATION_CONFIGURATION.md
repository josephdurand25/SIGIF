# Guide d'Installation et de Configuration SIGIF

## Table des Matières
1. [Prérequis](#prérequis)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Démarrage des Services](#démarrage-des-services)
5. [Base de Données](#base-de-données)
6. [Développement](#développement)
7. [Production](#production)
8. [Dépannage](#dépannage)

---

## Prérequis

### Système d'Exploitation
- Windows 10/11 ou macOS ou Linux
- Au minimum 4 GB de RAM
- Connexion Internet

### Logiciels Requis
- **Node.js** : v16.x ou supérieur ([Télécharger](https://nodejs.org))
- **npm** : v7.x ou supérieur (inclus avec Node.js)
- **MySQL** : v5.7 ou supérieur ([Télécharger](https://www.mysql.com/downloads))
- **Git** : v2.x ou supérieur ([Télécharger](https://git-scm.com))

### Vérification des versions

```bash
node --version      # v16.x ou supérieur
npm --version       # v7.x ou supérieur
mysql --version     # v5.7 ou supérieur
git --version       # v2.x ou supérieur
```

---

## Installation

### 1. Cloner le Projet

```bash
# Cloner le repository
git clone --recursive https://github.com/your-org/sigif.git
cd sigif

# Ou pour un clone existant
cd d:\SIGIF
```

### 2. Installer les Dépendances

#### Auth Service

```bash
cd API/Auth
npm install
```

#### Students Service

```bash
cd API/Students
npm install
```

#### Frontend (Optionnel)

```bash
cd frontend/Gestionnaire
npm install
```

### 3. Vérifier l'Installation

```bash
# Vérifier que TypeScript est installé globalement
npm install -g typescript

# Compiler TypeScript
# cd API/Auth
# npm run build

# cd ../Students
# npm run build
```

---

## Configuration standar

### 1. Variables d'Environnement

#### Auth Service (.env)

```bash
# API/Auth/.env
PORT=3003
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your_very_secure_secret_key_here_at_least_32_characters
JWT_EXPIRE=3h

# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=password
DB_NAME=SIGIF_DB
DB_PORT=3306

# CORS Configuration
FRONTEND_ORIGIN=http://localhost:3001
```

#### Students Service (.env)

```bash
# API/Students/.env
PORT=3004
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=password
DB_NAME=SIGIF_DB
DB_PORT=3306

# Auth Service Configuration
AUTH_SERVICE_URL=http://localhost:3003

# Logging
LOG_LEVEL=info
```

#### Frontend (.env.local)

```bash
# frontend/Gestionnaire/.env.local
VITE_API_AUTH_URL=http://localhost:3003
VITE_API_STUDENTS_URL=http://localhost:3004
VITE_APP_NAME=SIGIF
VITE_APP_VERSION=1.0.0
```

### 2. Configuration MySQL

#### Créer la Base de Données

```sql
-- Ouvrir MySQL
mysql -u root -p

-- Créer la base de données
CREATE DATABASE SIGIF_DB 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- Créer un utilisateur
CREATE USER 'sigif_user'@'localhost' IDENTIFIED BY 'secure_password';

-- Accorder les permissions
GRANT ALL PRIVILEGES ON SIGIF_DB.* TO 'sigif_user'@'localhost';
FLUSH PRIVILEGES;

-- Vérifier la création
SHOW DATABASES;
USE SIGIF_DB;
SHOW TABLES;
```

#### Initialiser les Tables

```bash
# Depuis le répertoire API/Students
mysql -u root -p SIGIF_DB < src/Database/database_v3.sql
```

### 3. Configuration TypeScript

Les fichiers `tsconfig.json` sont déjà configurés. Vérifier les paramètres :

#### tsconfig.json (Auth)

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node"
  }
}
```

---

## Démarrage des Services

### Mode Développement

#### Auth Service

```bash
cd API/Auth

# Développement avec hot-reload
npm run dev

# Ou compilation et démarrage
npm run build
npm start

# Output attendu:
# [2026-01-21] Server is running on http://localhost:3003
```

#### Students Service

```bash
cd API/Students

# Développement
npm run dev

# Ou compilation et démarrage
npm run build
npm start

# Output attendu:
# Server running on http://localhost:3004
```

#### Frontend

```bash
cd frontend/Gestionnaire

# Développement avec Vite
npm run dev

# Output attendu:
# ➜  Local:   http://localhost:5173/
```

### Démarrage Complet (Tous les Services)

#### Option 1 : Terminals Séparés

```bash
# Terminal 1 - MySQL
# Vérifier que MySQL est démarré
mysql -u root -p

# Terminal 2 - Auth Service
cd API/Auth
npm run dev

# Terminal 3 - Students Service
cd API/Students
npm run dev

# Terminal 4 - Frontend
cd frontend/Gestionnaire
npm run dev
```

#### Option 2 : Script Bash (Unix/Linux/macOS)

```bash
#!/bin/bash
# start-all.sh

# Démarrer Auth Service en arrière-plan
cd API/Auth && npm run dev &
AUTH_PID=$!

# Démarrer Students Service en arrière-plan
cd ../../API/Students && npm run dev &
STUDENTS_PID=$!

# Démarrer Frontend
cd ../../frontend/Gestionnaire && npm run dev

# Nettoyage à la sortie
trap "kill $AUTH_PID $STUDENTS_PID" EXIT
```

#### Option 3 : Docker Compose (Si disponible)

```bash
# Assurez-vous que Docker est installé
docker-compose up -d

# Vérifier les services
docker-compose ps

# Voir les logs
docker-compose logs -f
```

### Vérification des Services

```bash
# Auth Service
curl http://localhost:3003/

# Students Service
curl http://localhost:3004/

# Frontend
open http://localhost:5173 # macOS
start http://localhost:5173 # Windows
xdg-open http://localhost:5173 # Linux
```

---

## Base de Données

### Structure des Principales Tables

#### Table: utilisateurs

```sql
CREATE TABLE utilisateurs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  nom VARCHAR(100),
  prenom VARCHAR(100),
  role ENUM('administrator', 'teacher', 'student', 'user'),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### Table: etudiants

```sql
CREATE TABLE etudiants (
  id INT PRIMARY KEY AUTO_INCREMENT,
  prenom VARCHAR(100) NOT NULL,
  nom VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  date_naissance DATE,
  specialite_code VARCHAR(50),
  niveau VARCHAR(20),
  statut ENUM('ACTIF', 'INACTIF', 'SUSPENDU', 'BLOQUE'),
  date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (specialite_code) REFERENCES specialites(code)
);
```

#### Table: matieres

```sql
CREATE TABLE matieres (
  code VARCHAR(50) PRIMARY KEY,
  nom VARCHAR(150) NOT NULL,
  type_cours ENUM('CM', 'TD', 'TP', 'AUTRE'),
  credits INT,
  coefficient DECIMAL(3,1),
  volume_horaire INT,
  ue_code VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (ue_code) REFERENCES unites_enseignement(code)
);
```

### Sauvegarde et Restauration

#### Sauvegarder la Base de Données

```bash
# Export complet
mysqldump -u root -p SIGIF_DB > backup_$(date +%Y%m%d_%H%M%S).sql

# Export sans données
mysqldump -u root -p --no-data SIGIF_DB > structure_backup.sql

# Export avec données compressées
mysqldump -u root -p SIGIF_DB | gzip > backup_$(date +%Y%m%d).sql.gz
```

#### Restaurer la Base de Données

```bash
# Restaurer depuis un backup
mysql -u root -p SIGIF_DB < backup_20260121_143000.sql

# Depuis un fichier compressé
gunzip < backup_20260121.sql.gz | mysql -u root -p SIGIF_DB
```

---

## Développement

### Scripts NPM Disponibles

#### Auth Service

```bash
npm run dev      # Démarrage en mode développement
npm run build    # Compilation TypeScript
npm run start    # Démarrage en production
npm run test     # Lancer les tests
npm run lint     # Vérifier la qualité du code
```

#### Students Service

```bash
npm run dev      # Démarrage en mode développement
npm run build    # Compilation TypeScript
npm run start    # Démarrage en production
npm run test     # Tests
npm run seed     # Initialiser la BD avec des données
```

### Structure du Projet

```
API/
├── Auth/
│   ├── src/
│   │   ├── app.ts              # Point d'entrée
│   │   ├── types/
│   │   │   └── api.ts          # Types TypeScript
│   │   ├── Config/
│   │   │   └── db.config.ts    # Config BD
│   │   ├── Middleware/
│   │   │   └── Auth.ts         # Middleware JWT
│   │   └── utils/
│   ├── dist/                   # Fichiers compilés
│   ├── package.json
│   ├── tsconfig.json
│   └── .env                    # Variables d'environnement
│
└── Students/
    ├── src/
    │   ├── server.ts           # Point d'entrée
    │   ├── Controllers/        # 15 contrôleurs métier
    │   ├── Models/             # Couche données
    │   ├── types/              # Interfaces TypeScript
    │   ├── routes/             # Définition routes
    │   ├── Database/
    │   │   └── database_v3.sql # Schéma BD
    │   ├── Config/
    │   │   └── db.config.ts    # Config BD
    │   └── scripts/
    │       └── seed.ts         # Données de test
    ├── dist/                   # Fichiers compilés
    ├── package.json
    ├── tsconfig.json
    └── .env
```

### Debugging

#### VS Code Debugger

Créer `.vscode/launch.json` :

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Auth Service Debug",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/API/Auth/src/app.ts",
      "preLaunchTask": "npm: build",
      "outFiles": ["${workspaceFolder}/**/dist/**/*.js"]
    },
    {
      "name": "Students Service Debug",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/API/Students/src/server.ts",
      "preLaunchTask": "npm: build",
      "outFiles": ["${workspaceFolder}/**/dist/**/*.js"]
    }
  ]
}
```

#### Console Logs

```typescript
// Debug logs
console.log('[DEBUG] Variable:', variableValue);
console.error('[ERROR] Erreur:', errorMessage);
console.warn('[WARN] Avertissement:', warning);
console.info('[INFO] Information:', info);
```

---

## Production

### Préparation

#### 1. Compilation

```bash
cd API/Auth
npm run build

cd ../Students
npm run build
```

#### 2. Vérifier les Dépendances

```bash
npm audit
npm audit fix --force  # Si nécessaire
```

#### 3. Tester la Build

```bash
# Installer node_modules en production
npm install --production

# Tester localement
NODE_ENV=production npm start
```

### Déploiement

#### Avec Heroku

```bash
# Créer une app Heroku
heroku create sigif-api

# Configurer les variables d'environnement
heroku config:set JWT_SECRET=your_secret_key
heroku config:set NODE_ENV=production

# Déployer
git push heroku main

# Voir les logs
heroku logs --tail
```

#### Avec Docker

```dockerfile
# Dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY dist ./dist

EXPOSE 3003
CMD ["node", "dist/app.js"]
```

```bash
# Builder et lancer
docker build -t sigif-auth .
docker run -p 3003:3003 sigif-auth
```

#### Avec PM2

```bash
# Installation globale
npm install -g pm2

# Démarrer l'app
pm2 start API/Auth/dist/app.js --name "auth-api"
pm2 start API/Students/dist/server.js --name "students-api"

# Configuration persistante
pm2 startup
pm2 save

# Voir les logs
pm2 logs
```

### Variables d'Environnement Production

```bash
# .env.production
NODE_ENV=production
PORT=3003
JWT_SECRET=generate_a_very_secure_random_string_here
JWT_EXPIRE=24h

# Database
DB_HOST=your-db-host.com
DB_USER=prod_user
DB_PASSWORD=strong_password_here
DB_NAME=SIGIF_DB_PROD

# CORS
FRONTEND_ORIGIN=https://sigif.yourdomain.com

# Logging
LOG_LEVEL=info
```

---

## Dépannage

### Problèmes Courants

#### 1. Erreur de Connexion MySQL

**Symptôme** :
```
Error: connect ECONNREFUSED 127.0.0.1:3306
```

**Solution** :
```bash
# Vérifier que MySQL est démarré
# Windows
net start MySQL80

# macOS
brew services start mysql

# Linux
sudo systemctl start mysql

# Vérifier la configuration .env
# S'assurer que DB_HOST, DB_USER, DB_PASSWORD sont corrects
```

#### 2. Port Déjà Utilisé

**Symptôme** :
```
Error: listen EADDRINUSE :::3003
```

**Solution** :
```bash
# Windows - Trouver le process utilisant le port 3003
netstat -ano | findstr :3003
taskkill /PID <PID> /F

# macOS/Linux
lsof -i :3003
kill -9 <PID>

# Ou changer le port dans .env
PORT=3005
```

#### 3. Erreur de Token JWT

**Symptôme** :
```
Error: invalid token
```

**Solution** :
```bash
# S'assurer que le JWT_SECRET est le même dans tous les services
# Vérifier que le token n'a pas expiré
# Vérifier le format: "Bearer <token>"
```

#### 4. Erreur de Compilation TypeScript

**Symptôme** :
```
error TS2307: Cannot find module
```

**Solution** :
```bash
# Réinstaller les dépendances
rm -rf node_modules package-lock.json
npm install

# Effacer le cache
npm cache clean --force

# Recompiler
npm run build
```

#### 5. Base de Données Non Initialisée

**Symptôme** :
```
Error: Table 'SIGIF_DB.utilisateurs' doesn't exist
```

**Solution** :
```bash
# Initialiser la BD
mysql -u root -p SIGIF_DB < API/Students/src/Database/database_v3.sql

# Vérifier les tables
mysql -u root -p SIGIF_DB -e "SHOW TABLES;"
```

### Logs et Debugging

#### Activer les Logs Détaillés

```bash
# Auth Service
DEBUG=* npm run dev

# Students Service  
LOG_LEVEL=debug npm run dev
```

#### Vérifier la Santé des Services

```bash
# Auth Service Health Check
curl -i http://localhost:3003/

# Students Service Health Check
curl -i http://localhost:3004/

# Avec token
curl -i -H "Authorization: Bearer <token>" http://localhost:3004/api/students
```

---

## Support

Pour toute assistance :
- 📧 Email: dev-support@sigif.com
- 💬 Slack: #deployment
- 🐛 Bugs: GitHub Issues

**Document Version**: 1.0
**Dernière mise à jour**: 21 janvier 2026
