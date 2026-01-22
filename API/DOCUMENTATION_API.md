# Documentation API SIGIF - Système d'Information Gestion de l'Inscription et des Filières

## Table des Matières
1. [Introduction](#introduction)
2. [Architecture](#architecture)
3. [Authentification](#authentification)
4. [Services API](#services-api)
5. [Formats des Réponses](#formats-des-réponses)
6. [Endpoints Auth Service](#endpoints-auth-service)
7. [Endpoints Students Service](#endpoints-students-service)
8. [Gestion des Erreurs](#gestion-des-erreurs)
9. [Codes de Statut HTTP](#codes-de-statut-http)
10. [Exemples d'Utilisation](#exemples-dutilisation)

---

## Introduction

SIGIF est un système de gestion intégré pour les inscriptions étudiantes et la gestion des filières académiques. L'API est conçue avec une architecture microservices composée de deux services principaux :

- **Auth Service** : Gestion de l'authentification et autorisation
- **Students Service** : Gestion des données académiques

### Caractéristiques principales
- ✅ Authentification JWT sécurisée
- ✅ API RESTful complète
- ✅ Gestion des erreurs standardisée
- ✅ Pagination intégrée
- ✅ Filtrage et recherche avancée
- ✅ Support CORS multi-domaine
- ✅ Logging complet des requêtes
- ✅ TypeScript pour la sécurité des types

### Stack Technologique
- **Runtime** : Node.js
- **Framework** : Express.js
- **Langage** : TypeScript
- **Base de données** : MySQL
- **Authentification** : JWT (JSON Web Tokens)
- **Hashing** : bcrypt
- **CORS** : cors middleware
- **Logging** : morgan

---

## Architecture

### Microservices Architecture

```
┌─────────────────────────────────────┐
│     Frontend (Gestionnaire)         │
│     - React + TypeScript            │
│     - UI pour gestion académique    │
└────────────────┬────────────────────┘
                 │
    ┌────────────┴────────────┐
    │                         │
┌───▼──────────────┐   ┌─────▼──────────────┐
│   Auth Service   │   │  Students Service  │
│   Port: 3003     │   │   Port: 3004       │
│   ├─ Login       │   │   ├─ Students      │
│   ├─ Register    │   │   ├─ Courses       │
│   ├─ Refresh     │   │   ├─ Notes         │
│   └─ Validate    │   │   ├─ Enrollments   │
└────────┬─────────┘   └──────┬────────────┘
         │                    │
         └────────┬───────────┘
                  │
          ┌───────▼──────┐
          │   MySQL DB   │
          │ (SIGIF_DB)   │
          └──────────────┘
```

### Structure des Services

```
API/
├── Auth/
│   ├── src/
│   │   ├── app.ts              # Point d'entrée
│   │   ├── types/api.ts        # Définitions de types
│   │   ├── Config/db.config.ts # Configuration DB
│   │   └── Middleware/Auth.ts  # Middleware d'auth
│   ├── package.json
│   └── tsconfig.json
│
└── Students/
    ├── src/
    │   ├── server.ts           # Point d'entrée
    │   ├── Controllers/        # Logique métier (15 contrôleurs)
    │   ├── Models/             # Couche données
    │   ├── types/              # Types TypeScript
    │   ├── routes/             # Définition des routes
    │   └── Config/db.config.ts # Configuration DB
    ├── package.json
    └── tsconfig.json
```

---

## Authentification

### Vue d'ensemble
L'authentification SIGIF utilise le standard JWT (JSON Web Tokens) pour sécuriser les endpoints.

### Flux d'Authentification

```
1. Client envoie credentials (username + password)
                ↓
2. Server valide les credentials
                ↓
3. Server génère un JWT token
                ↓
4. Client stocke le token localement
                ↓
5. Client inclut le token dans les headers (Authorization: Bearer <token>)
                ↓
6. Server valide le token pour chaque requête
```

### Requête d'Authentification

```http
POST /login
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}
```

### Réponse d'Authentification

```json
{
  "success": true,
  "status_code": 200,
  "message": "Authentification réussie.",
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "nom": "Admin",
    "prenom": "User",
    "role": "administrator",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Utilisation du Token

Tous les endpoints sécurisés nécessitent ce header :

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Rôles et Permissions

| Rôle | Permissions |
|------|------------|
| `administrator` | Accès complet à toutes les ressources |
| `teacher` | Lecture/écriture de ses cours et notes |
| `student` | Lecture de ses données académiques |
| `user` | Lecture basique |

---

## Services API

### Auth Service (Port 3003)

Le service d'authentification gère :
- ✅ Connexion des utilisateurs
- ✅ Génération de tokens JWT
- ✅ Validation des tokens
- ✅ Gestion des sessions

### Students Service (Port 3004)

Le service académique gère :
- ✅ Gestion des étudiants (CRUD)
- ✅ Gestion des cours et matières
- ✅ Gestion des notes et évaluations
- ✅ Gestion des inscriptions
- ✅ Gestion des présences
- ✅ Gestion des filières et spécialités
- ✅ Rapports et statistiques

---

## Formats des Réponses

### Réponse de Succès

```json
{
  "success": true,
  "status_code": 200,
  "message": "Opération réussie",
  "data": {}
}
```

### Réponse avec Pagination

```json
{
  "success": true,
  "status_code": 200,
  "message": "Liste récupérée",
  "data": [
    { "id": 1, "nom": "Dupont" },
    { "id": 2, "nom": "Martin" }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "totalPages": 3
  }
}
```

### Réponse d'Erreur Simple

```json
{
  "success": false,
  "status_code": 400,
  "message": "Erreur lors du traitement",
  "error": "Détails techniques optionnels"
}
```

### Réponse d'Erreur de Validation

```json
{
  "success": false,
  "status_code": 422,
  "message": "Erreurs de validation",
  "errors": {
    "email": "Format d'email invalide",
    "prenom": "Le champ prénom est requis"
  }
}
```

---

## Endpoints Auth Service

### 1. Connexion Utilisateur

```http
POST /login
Content-Type: application/json

Requête:
{ 
  "email": "super-sigif@univ.edu", 
  "password": "admin123"
}

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "message": "Authentification réussie.",
  "data": {
    "id": 1,
    "email": "super-sigif@univ.edu",
    "password_hash": "$2b$10$l.ITvGX37dw5XvS0nW6y7.zxYw8tYwe2zaA85lxD11lcatrrludAS",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiZW1haWwiOiJzdXBlci1zaWdpZkB1bml2LmVkdSIsImlhdCI6MTc2OTAzNTE5NSwiZXhwIjoxNzY5MTIxNTk1fQ.j_HX0hvre1yLtfR3wHRR8BK8OQjWPXfWvG_e6WNisFw"
  }
}

Erreur: 401 UNAUTHORIZED
{
  "success": false,
  "status_code": 401,
  "message": "login incorrect.",
  "error": "Mot de passe incorrect."
}
```

### 2. Valider Token

```http
GET /validate
Authorization: Bearer <token>

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "message": "Token valide",
  "data": {
    "id": 1,
    "username": "admin",
    "role": "administrator"
  }
}

Erreur: 401 UNAUTHORIZED
{
  "success": false,
  "status_code": 403,
  "message": "Error. Need a token",
  "error": "No token provided"
}
```

---

## Endpoints Students Service

### Étudiants

#### 1. Créer un étudiant

```http
POST /api/students
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "prenom": "Jean",
  "nom": "Dupont",
  "email": "jean.dupont@example.com",
  "date_naissance": "2000-05-15",
  "specialite_code": "SP001",
  "niveau": "L3"
}

Réponse: 201 CREATED
{
  "success": true,
  "status_code": 201,
  "message": "Création réussie",
  "data": {
    "id": 1,
    "prenom": "Jean",
    "nom": "Dupont",
    "email": "jean.dupont@example.com",
    "statut": "ACTIF"
  }
}
```

#### 2. Récupérer tous les étudiants

```http
GET /api/students?page=1&limit=10&filiere_code=FIL001&niveau=L3
Authorization: Bearer <token>

Paramètres de Query:
- page (int, défaut: 1)
- limit (int, défaut: 10, max: 100)
- filiere_code (string, optionnel)
- specialite_code (string, optionnel)
- niveau (string, optionnel)
- statut (string, optionnel)
- search (string, optionnel)

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "message": "Liste des étudiants récupérée avec succès",
  "data": [
    { "id": 1, "nom": "Dupont", "prenom": "Jean" },
    { "id": 2, "nom": "Martin", "prenom": "Marie" }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 45,
    "totalPages": 5
  }
}
```

#### 3. Récupérer un étudiant par ID

```http
GET /api/students/:id
Authorization: Bearer <token>

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "message": "Etudiant trouvé",
  "data": {
    "id": 1,
    "prenom": "Jean",
    "nom": "Dupont",
    "email": "jean.dupont@example.com",
    "date_naissance": "2000-05-15",
    "specialite_code": "SP001",
    "niveau": "L3",
    "statut": "ACTIF",
    "date_inscription": "2023-09-15"
  }
}

Erreur: 404 NOT FOUND
{
  "success": false,
  "status_code": 404,
  "message": "Étudiant non trouvé."
}
```

#### 4. Mettre à jour un étudiant

```http
PUT /api/students/:id
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "email": "jean.dupont.new@example.com",
  "niveau": "Master1"
}

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "message": "Mise à jour réussie",
  "data": { ...étudiant mis à jour... }
}
```

#### 5. Supprimer un étudiant

```http
DELETE /api/students/:id
Authorization: Bearer <token>

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "message": "Étudiant supprimé avec succès."
}
```

#### 6. Récupérer les cours d'un étudiant

```http
GET /api/students/:id/courses
Authorization: Bearer <token>

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "message": "Groupes UE (cours) récupérés avec succès",
  "data": [
    { "code": "GRP001", "nom": "Groupe 1", "semestre": 1 }
  ]
}
```

#### 7. Récupérer les notes d'un étudiant

```http
GET /api/students/:id/notes
Authorization: Bearer <token>

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "data": [
    {
      "matiere_code": "MAT001",
      "matiere_nom": "Mathématiques",
      "note": 15.5,
      "date_evaluation": "2024-01-15"
    }
  ]
}
```

#### 8. Récupérer la moyenne générale

```http
GET /api/students/:id/moyenne
Authorization: Bearer <token>

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "data": {
    "moyenne": 14.25,
    "nombre_matieres": 12,
    "credits_obtenus": 48,
    "credits_totaux": 60
  }
}
```

### Matières

#### 1. Créer une matière

```http
POST /api/matieres
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "code": "MAT001",
  "nom": "Mathématiques",
  "type_cours": "CM",
  "credits": 4,
  "coefficient": 1.5,
  "ue_code": "UE001"
}

Réponse: 201 CREATED
```

#### 2. Récupérer toutes les matières

```http
GET /api/matieres?page=1&limit=10&ue_code=UE001&type_cours=CM
Authorization: Bearer <token>

Réponse: 200 OK
{
  "success": true,
  "status_code": 200,
  "data": [...],
  "pagination": {...}
}
```

#### 3. Récupérer une matière

```http
GET /api/matieres/:code
Authorization: Bearer <token>
```

#### 4. Mettre à jour une matière

```http
PUT /api/matieres/:code
Authorization: Bearer <token>
Content-Type: application/json
```

#### 5. Supprimer une matière

```http
DELETE /api/matieres/:code
Authorization: Bearer <token>
```

### Notes

#### 1. Créer une note

```http
POST /api/notes
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "etudiant_id": 1,
  "matiere_code": "MAT001",
  "note_cc": 12.5,
  "note_exam": 14.0,
  "note_tp": 13.0
}

Réponse: 201 CREATED
```

#### 2. Récupérer toutes les notes

```http
GET /api/notes?page=1&etudiant_id=1
Authorization: Bearer <token>
```

#### 3. Récupérer les notes d'un étudiant

```http
GET /api/notes?etudiant_id=1
Authorization: Bearer <token>
```

### Unités d'Enseignement (UE)

#### 1. Créer une UE

```http
POST /api/ue
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "code": "UE001",
  "nom": "Fondamentaux",
  "type": "OBLIGATOIRE",
  "credits": 12
}
```

#### 2. Récupérer les UE

```http
GET /api/ue?page=1&limit=10
Authorization: Bearer <token>
```

### Inscriptions

#### 1. Créer une inscription

```http
POST /api/inscriptions
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "etudiant_id": 1,
  "filiere_code": "FIL001",
  "date_inscription": "2024-09-15",
  "statut": "VALIDE"
}

Réponse: 201 CREATED
```

#### 2. Récupérer les inscriptions

```http
GET /api/inscriptions?page=1&statut=VALIDE
Authorization: Bearer <token>
```

### Présences

#### 1. Enregistrer une présence

```http
POST /api/presences
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "etudiant_id": 1,
  "seance_id": 10,
  "statut_presence": "PRESENT",
  "date": "2024-01-15"
}

Réponse: 201 CREATED
```

#### 2. Récupérer les présences

```http
GET /api/presences?page=1&etudiant_id=1
Authorization: Bearer <token>
```

### Filières

#### 1. Créer une filière

```http
POST /api/filieres
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "code": "FIL001",
  "nom": "Informatique",
  "description": "Licence en Informatique"
}
```

#### 2. Récupérer les filières

```http
GET /api/filieres
Authorization: Bearer <token>
```

### Spécialités

#### 1. Créer une spécialité

```http
POST /api/specialites
Authorization: Bearer <token>
Content-Type: application/json

Requête:
{
  "code": "SP001",
  "nom": "Développement Web",
  "filiere_code": "FIL001",
  "niveau": "L3"
}
```

#### 2. Récupérer les spécialités

```http
GET /api/specialites?filiere_code=FIL001
Authorization: Bearer <token>
```

---

## Gestion des Erreurs

### Codes d'Erreur Courants

| Code | Message | Cause |
|------|---------|-------|
| `400` | Bad Request | Données invalides ou paramètres manquants |
| `401` | Unauthorized | Token manquant ou invalide |
| `403` | Forbidden | Permissions insuffisantes |
| `404` | Not Found | Ressource non trouvée |
| `409` | Conflict | Conflit (ex: email déjà existant) |
| `422` | Unprocessable Entity | Erreurs de validation des données |
| `500` | Internal Server Error | Erreur serveur |

### Exemple de Gestion d'Erreur

```javascript
try {
  const response = await fetch('http://localhost:3004/api/students', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });

  const result = await response.json();

  if (!result.success) {
    console.error('Erreur:', result.message);
    if (result.errors) {
      // Erreurs de validation
      Object.entries(result.errors).forEach(([field, message]) => {
        console.error(`${field}: ${message}`);
      });
    }
  } else {
    console.log('Succès:', result.data);
  }
} catch (error) {
  console.error('Erreur réseau:', error);
}
```

---

## Codes de Statut HTTP

### 2xx - Succès

| Code | Description |
|------|-------------|
| `200` | OK - Requête réussie |
| `201` | Created - Ressource créée |
| `202` | Accepted - Requête acceptée |
| `204` | No Content - Pas de contenu à retourner |

### 4xx - Erreurs Client

| Code | Description |
|------|-------------|
| `400` | Bad Request - Requête invalide |
| `401` | Unauthorized - Authentification requise |
| `403` | Forbidden - Accès refusé |
| `404` | Not Found - Ressource non trouvée |
| `409` | Conflict - Conflit avec l'état actuel |
| `422` | Unprocessable Entity - Validation échouée |
| `429` | Too Many Requests - Trop de requêtes |

### 5xx - Erreurs Serveur

| Code | Description |
|------|-------------|
| `500` | Internal Server Error - Erreur serveur |
| `501` | Not Implemented - Non implémenté |
| `502` | Bad Gateway - Mauvaise passerelle |
| `503` | Service Unavailable - Service indisponible |

---

## Exemples d'Utilisation

### Exemple 1 : Authentification et Récupération des Étudiants

```javascript
// 1. Se connecter
const loginResponse = await fetch('http://localhost:3003/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'admin',
    password: 'password123'
  })
});

const loginData = await loginResponse.json();
const token = loginData.data.token;

// 2. Récupérer les étudiants
const studentsResponse = await fetch(
  'http://localhost:3004/api/students?page=1&limit=20',
  {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  }
);

const studentsData = await studentsResponse.json();
console.log('Étudiants:', studentsData.data);
```

### Exemple 2 : Créer un Étudiant

```javascript
const createResponse = await fetch('http://localhost:3004/api/students', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    prenom: 'Marie',
    nom: 'Martin',
    email: 'marie.martin@example.com',
    date_naissance: '2002-03-20',
    specialite_code: 'SP001',
    niveau: 'L2'
  })
});

const newStudent = await createResponse.json();
if (newStudent.success) {
  console.log('Étudiant créé:', newStudent.data);
}
```

### Exemple 3 : Gestion des Erreurs

```javascript
async function createStudentWithErrorHandling(token, studentData) {
  try {
    const response = await fetch('http://localhost:3004/api/students', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(studentData)
    });

    const result = await response.json();

    if (!result.success) {
      if (result.errors) {
        // Erreurs de validation
        throw new Error(`Validation: ${JSON.stringify(result.errors)}`);
      } else {
        // Erreur générale
        throw new Error(result.message);
      }
    }

    return result.data;
  } catch (error) {
    console.error('Erreur lors de la création:', error.message);
    throw error;
  }
}
```

### Exemple 4 : Utiliser avec TypeScript

```typescript
interface LoginRequest {
  username: string;
  password: string;
}

interface LoginResponse {
  success: boolean;
  status_code: number;
  message: string;
  data: {
    id: number;
    username: string;
    email: string;
    token: string;
  };
}

async function login(credentials: LoginRequest): Promise<LoginResponse> {
  const response = await fetch('http://localhost:3003/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(credentials)
  });

  return response.json();
}

// Utilisation
const result = await login({ username: 'admin', password: 'password123' });
if (result.success) {
  console.log('Token:', result.data.token);
}
```

---

## Pagination et Filtrage

### Paramètres de Pagination

Tous les endpoints de liste supportent ces paramètres:

```
GET /api/students?page=2&limit=25

page    : Numéro de page (défaut: 1, min: 1)
limit   : Nombre d'éléments par page (défaut: 10, min: 1, max: 100)
```

### Exemple de Réponse Paginée

```json
{
  "success": true,
  "status_code": 200,
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 25,
    "total": 127,
    "totalPages": 6
  }
}
```

### Recherche et Filtrage

```
GET /api/students?search=dupont&filiere_code=FIL001&niveau=L3

Paramètres de filtrage disponibles:
- search        : Recherche textuelle
- filiere_code  : Code de la filière
- specialite_code : Code de la spécialité
- niveau        : Niveau académique
- statut        : Statut de l'étudiant
```

---

## Environnement et Configuration

### Variables d'Environnement (Auth Service)

```bash
PORT=3003
JWT_SECRET=your_jwt_secret_key
FRONTEND_ORIGIN=http://localhost:3001
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=password
DB_NAME=SIGIF_DB
```

### Variables d'Environnement (Students Service)

```bash
PORT=3004
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=password
DB_NAME=SIGIF_DB
AUTH_SERVICE_URL=http://localhost:3003
```

---

## Best Practices

### 1. Sécurité

✅ **Toujours utiliser HTTPS en production**
```
https://api.sigif.com/api/students
```

✅ **Inclure le token dans chaque requête**
```javascript
headers: {
  'Authorization': `Bearer ${token}`,
  'Content-Type': 'application/json'
}
```

✅ **Valider les données côté client et serveur**
```javascript
// Client
if (!email.includes('@')) {
  throw new Error('Email invalide');
}

// Server
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
if (!emailRegex.test(email)) {
  return errorResponse('Email invalide');
}
```

### 2. Performance

✅ **Utiliser la pagination pour les listes grandes**
```javascript
// ❌ À éviter
GET /api/students

// ✅ À utiliser
GET /api/students?page=1&limit=50
```

✅ **Cacher les réponses fréquentes**
```javascript
const students = await fetch(url, { 
  headers: { 'Cache-Control': 'max-age=300' } 
});
```

### 3. Gestion des Erreurs

✅ **Toujours vérifier `success`**
```javascript
if (!result.success) {
  handleError(result);
}
```

✅ **Implémenter des retry automatiques**
```javascript
async function fetchWithRetry(url, options, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, options);
      if (response.ok) return response.json();
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(r => setTimeout(r, 1000 * Math.pow(2, i)));
    }
  }
}
```

---

## Support et Contact

Pour toute question ou problème :

📧 **Email** : support@sigif.com
📞 **Téléphone** : +33 (0)1 XX XX XX XX
🌐 **Site Web** : https://www.sigif.com
💬 **Slack** : #api-support

---

**Documentation Version** : 1.0
**Dernière mise à jour** : 21 janvier 2026
**Statut** : Production
