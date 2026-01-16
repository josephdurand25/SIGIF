local http = require("resty.http")
local cjson = require("cjson")
local permissions = require("permissions").map

-- Normalize URI: prefer ngx.var.uri (no query) and strip trailing slashes
local raw_uri = ngx.var.uri or ngx.var.request_uri or ""
local uri = raw_uri:match("^[^%?]+") or raw_uri
uri = uri:gsub("/+$", "")
local method = ngx.var.request_method
local auth_header = ngx.var.http_authorization or ""
ngx.log(ngx.DEBUG, "Route à vérifier: ", uri)

-- Liste des routes publiques qui ne nécessitent PAS de vérification de token
local public_routes = {
    ["/v1/auth/login"] = true,
    ["/v1/auth/register"] = true,
    ["/v1/auth/verify-token"] = true,
    ["/v1/certificat/verify-code"] = true,
    ["/v1/centres/public-info"] = true
}

-- Vérifier si c'est une route publique
if public_routes[uri] then
    ngx.log(ngx.DEBUG, "Route publique détectée, accès direct: ", uri)
    
    -- Déterminer le backend approprié pour les routes publiques
    if uri:match("^/v1/auth/") then
        ngx.var.upstream = "http://auth-service"
    end
    if uri:match("^/v1/centres/") then
        ngx.var.upstream = "http://center-service"
    end
    if uri:match("^/v1/certificat/") then
        ngx.var.upstream = "http://request-service"
    end
    
    ngx.log(ngx.DEBUG, "Route publique ", uri, " redirigée vers: ", ngx.var.upstream)
    return
end

-- Vérifier si la route existe dans permissions.lua
local route_config = permissions[uri] or {}
local route_found = false

-- Recherche par pattern si pas de correspondance exacte
if not route_config.permissions then
    for pattern, config in pairs(permissions) do
        if uri:match(pattern) then
            route_config = config
            route_found = true
            ngx.log(ngx.DEBUG, "Route trouvée par pattern: ", pattern, " -> ", cjson.encode(route_config))
            break
        end
    end
end

-- Si pas de permissions requises OU route non trouvée, passer directement
if not route_config or not route_config.permissions then
    local backend = route_config.backend or "http://auth-service"
    ngx.var.upstream = backend
    ngx.log(ngx.DEBUG, "Aucune permission requise pour ", uri, " -> ", backend)
    return
end

-- À partir d'ici, on sait que la route nécessite des permissions
-- Vérifier la présence du token
if auth_header == "" or not auth_header:match("^Bearer ") then
    ngx.log(ngx.ERR, "Token manquant pour la route protégée: ", uri)
    ngx.header["Content-Type"] = "application/json"
    return ngx.exit(401)
end

-- Extraire le token
local token = auth_header:gsub("Bearer ", "")
ngx.log(ngx.DEBUG, "Validation du token pour: ", uri)

-- Valider le token avec le service d'authentification
local httpc = http.new()
local res, err = httpc:request_uri("http://127.0.0.1:8006/api/validate-token-front", {
    method = "GET",
    body = cjson.encode({ token = token }),
    headers = { 
        ["Content-Type"] = "application/json", 
        ["Authorization"] = auth_header 
    }
})

-- Gestion des erreurs de connexion
if not res then
    ngx.log(ngx.ERR, "Erreur de connexion au service d'authentification: ", err)
    ngx.header["Content-Type"] = "application/json"
    return ngx.exit(503)
end

-- Vérifier la réponse du service d'authentification
if res.status ~= 200 then
    ngx.log(ngx.ERR, "Token invalide - Status: ", res.status, " pour URI: ", uri)
    ngx.header["Content-Type"] = "application/json"
    return ngx.exit(401)
end

-- Décoder la réponse
local ok, user_data = pcall(cjson.decode, res.body)
if not ok then
    ngx.log(ngx.ERR, "Erreur de décodage JSON de la réponse d'authentification")
    ngx.header["Content-Type"] = "application/json"
    return ngx.exit(500)
end

-- Vérifier la structure des données utilisateur
if not user_data or not user_data.data then
    ngx.log(ngx.ERR, "Structure de données utilisateur invalide")
    ngx.header["Content-Type"] = "application/json"
    return ngx.exit(500)
end

-- Extraire les informations utilisateur
local user = user_data.data.user or {}
local user_role = user_data.data.role or {}
local user_permissions = user_data.data.permissions or {}
local required_permissions = route_config.permissions

ngx.log(ngx.DEBUG, "Utilisateur authentifié: ", user.email or "unknown")
ngx.log(ngx.DEBUG, "Permissions requises: ", cjson.encode(required_permissions))
ngx.log(ngx.DEBUG, "Permissions utilisateur: ", cjson.encode(user_permissions))

-- Vérifier les permissions
for _, req_perm in ipairs(required_permissions) do
    local has_permission = false
    
    for _, user_perm in ipairs(user_permissions) do
        if user_perm == req_perm then
            has_permission = true
            ngx.log(ngx.DEBUG, "Permission trouvée: ", req_perm)
            break
        end
    end
    
    if not has_permission then
        ngx.log(ngx.ERR, "Permission manquante: ", req_perm, " pour l'utilisateur: ", user.email or "unknown")
        ngx.header["Content-Type"] = "application/json"
        return ngx.exit(403)
    end
end

-- Ajouter les headers utilisateur pour les services backend
ngx.req.set_header("X-Check-User", cjson.encode(user))
ngx.req.set_header("X-Check-User-Permissions", table.concat(user_permissions, ","))
ngx.req.set_header("X-Check-User-Role", cjson.encode(user_role))
ngx.req.set_header("X-Required-Permission", cjson.encode(required_permissions))

-- Définir l'upstream
ngx.var.upstream = route_config.backend or "http://auth-service"
ngx.log(ngx.DEBUG, "Accès autorisé pour ", uri, " vers ", ngx.var.upstream)