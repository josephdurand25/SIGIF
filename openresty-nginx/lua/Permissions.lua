local permissions = {
    map = {
        ["/v1/users"] = { permissions = { "users:read", "users:view" }, backend = "http://auth-service" },
        ["/v1/users/loadUsers"] = { permissions = { "users:read", "users:view" }, backend = "http://auth-service" },
        ["/v1/users/assign/permissions"] = { permissions = { "permissions:assign" }, backend = "http://auth-service" },
        ["/v1/users/revoke/permissions"] = { permissions = { "permissions:revoke" }, backend = "http://auth-service" },
        ["/v1/users/assign/role"] = { permissions = { "roles:assign" }, backend = "http://auth-service" },
        ["/v1/users/revoke/role"] = { permissions = { "roles:revoke" }, backend = "http://auth-service" },
        ["/v1/users/profile"] = { permissions = { "users:profile-own" }, backend = "http://auth-service" },
        ["/v1/users/change-status"] = { permissions = { "users:manage-status" }, backend = "http://auth-service" },
        ["/v1/permissions/read"] = { permissions = { "permissions:read" }, backend = "http://auth-service" },
        ["/v1/permission/create"] = { permissions = { "permissions:create" }, backend = "http://auth-service" },
        ["/v1/permissions/(%d+)$"] = { permissions = { "permissions:update", "permissions:delete" }, backend = "http://auth-service" },
        ["/v1/roles"] = { permissions = { "roles:read" }, backend = "http://auth-service" },
        ["/v1/roles/read"] = { permissions = { "roles:read" }, backend = "http://auth-service" },
        ["/v1/roles/create"] = { permissions = { "roles:create" }, backend = "http://auth-service" },
        ["/v1/roles/(%d+)$"] = { permissions = { "roles:update", "roles:delete" }, backend = "http://auth-service" },
        ["/v1/users/agents"] = { permissions = { "agents:view" }, backend = "http://auth-service" },
        ["/v1/agents/create"] = { permissions = { "agents:create" }, backend = "http://auth-service" },
        ["/v1/agents/(%d+)$"] = { permissions = { "agents:update", "agents:delete" }, backend = "http://auth-service" },
        ["/v1/requests-service"] = { permissions = { "requests:view" }, backend = "http://requests-service" },
       
        ["/v1/centres"] = { permissions = { "centers:view", "centers:read" }, backend = "http://center-service" },
        ["/v1/centres/(%d+)$"] = { permissions = { "centers:view" }, backend = "http://center-service" },
        ["/v1/centres/(%d+)$/toggle"] = { permissions = { "centers:active", "centers:inactive" }, backend = "http://center-service" },
        ["/v1/centres/(%d+)$/details"] = { permissions = { "centers:view" }, backend = "http://center-service" },
        ["/v1/centres/(%d+)$/agents"] = { permissions = { "centers:view", "centers:view-details" }, backend = "http://center-service" },
        ["/v1/centres/stats"] = { permissions = { "centers:view", "centers:read" }, backend = "http://center-service" },
        
        ["/v1/affectations"] = { permissions = { "assignments:view", "assignments:read" }, backend = "http://center-service" },
        ["/v1/affectations/(%d+)$"] = { permissions = { "assignments:view" }, backend = "http://center-service" },
        ["/v1/affectations/(%d+)$/toggle"] = { permissions = { "assignments:active", "assignments:inactive" }, backend = "http://center-service" },
        ["/v1/affectations/(%d+)$/details"] = { permissions = { "assignments:view" }, backend = "http://center-service" },
        ["/v1/affectations/(%d+)$/agents"] = { permissions = { "assignments:view", "assignments:view-details" }, backend = "http://center-service" },
    }
}
return permissions