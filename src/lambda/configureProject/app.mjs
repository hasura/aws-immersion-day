import url from "url";
import { httpGetRequest, httpPostRequest } from "./request.mjs";

const getMetadata = async function() {
    const parsedUrl = url.parse(process.env.METADATA_URL);
    const options = {
        hostname: parsedUrl.hostname,
        method: "GET",
        path: parsedUrl.path,
        port: 443,
        secure: true
    };
    
    const response = await httpGetRequest(options);
    
    if (response.code === 200) {
        try {
            return response.data;
        } catch (error) {
            console.log(error);
            return;
        }
    } else {
        return;
    }
};

const getSecrets = async function() {
    const options = {
        hostname: "localhost",
        headers: {
            "X-AWS-Parameters-Secrets-Token": process.env.AWS_SESSION_TOKEN
        },
        method: "GET",
        path: `/secretsmanager/get?secretId=${process.env.HASURA_SECRETS_ARN}`,
        port: 2773,
        secure: false
    };
    
    const response = await httpGetRequest(options);
    
    if (response.code === 200) {
        try {
            return JSON.parse(response.data.SecretString);
        } catch (error) {
            console.log(error);
            return;
        }
    } else {
        return;
    }
};

const getTenantEnv = async function(options, tenantId) {
    const body = `query getTenantEnv {
        getTenantEnv(tenantId: "${tenantId}") {
            hash
            envVars
        }
    }`;
    
    const response = await httpPostRequest(options, JSON.stringify({ query: body }));
    
    if (response.code === 200) {
        try {
            return response.data.data.getTenantEnv;
        } catch (error) {
            console.log(error);
            return;
        }
    } else {
        return;
    }
};

const getTenantId = async function(options, projectId) {
    const body = `query getProjectTenantId {
        projects_by_pk(id: "${projectId}") {
            tenant {
                id
            }
        }
    }`;
    
    const response = await httpPostRequest(options, JSON.stringify({ query: body }));
    
    if (response.code === 200) {
        try {
            return response.data.data.projects_by_pk.tenant.id;
        } catch (error) {
            console.log(error);
            return;
        }
    } else {
        return;
    }
};

const updateTenantEnv = async function(options, tenantId, tenantEnv, variables) {
    const body = `mutation updateTenantEnv {
        updateTenantEnv(
            currentHash: "${tenantEnv.hash}",
            tenantId: "${tenantId}",
            envs: ${JSON.stringify(variables)}
        ) {
            hash
            envVars
        }
    }`;
    
    const response = await httpPostRequest(options, JSON.stringify({ query: body} )
        .replace(/\\\"key\\\"/g, "key")
        .replace(/\\\"value\\\"/g, "value"));
    
    if (response.code === 200) {
        try {
            return response.data;
        } catch (error) {
            console.log(error);
            return;
        }
    } else {
        return;
    }
};

export const lambdaHandler = async function(event) {
    const variables = [
        { key: "CMS_URL", value: `${process.env.CMS_URL}` },
        { key: "HASURA_GRAPHQL_JWT_SECRET", value: `${process.env.HASURA_GRAPHQL_JWT_SECRET}` },
        { key: "HASURA_GRAPHQL_UNAUTHORIZED_ROLE", value: "anonymous" },
        { key: "PG_DATABASE_ACCOUNTS", value: `${process.env.PG_DATABASE_URL}/accounts` },
        { key: "PG_DATABASE_CREDIT_HISTORY", value: `${process.env.PG_DATABASE_URL}/credit_history` },
        { key: "PG_DATABASE_CRYPTO", value: `${process.env.PG_DATABASE_URL}/crypto` },
        { key: "PG_DATABASE_INVESTMENTS", value: `${process.env.PG_DATABASE_URL}/investments` },
        { key: "PG_DATABASE_TRADES", value: `${process.env.PG_DATABASE_URL}/trades` },
        { key: "PG_DATABASE_TRANSACTIONS", value: `${process.env.PG_DATABASE_URL}/transactions` },
        { key: "PG_DATABASE_USERS", value: `${process.env.PG_DATABASE_URL}/users` }
    ];
    
    const secrets = await getSecrets();
    
    if (secrets) {
        const options = {
            hostname: "data.pro.hasura.io",
            headers: {
                "Authorization": `pat ${secrets.access_token}`,
                "Content-Type": "application/json"
            },
            method: "POST",
            path: "/v1/graphql",
            port: 443,
            secure: true
        };
        
        const tenantId = await getTenantId(options, secrets.project_id);
        
        if (tenantId) {
            const tenantEnv = await getTenantEnv(options, tenantId);
            
            if (tenantEnv) {
                const updateEnv = await updateTenantEnv(options, tenantId, tenantEnv, variables);
                
                if (updateEnv) {
                    let metadata = await getMetadata();
                    
                    if (metadata) {
                        for (let i = 0; i < metadata.metadata.actions.length; i++) {
                            metadata.metadata.actions[i].definition.handler = process.env.OPENAPI_SERVER_URL;
                        }
                        
                        return {
                            statusCode: 200,
                            body: JSON.stringify(metadata, null, 2),
                            headers: {
                                "Content-Type": "application/octet-stream"
                            }
                        };
                    }
                }
            }
        }
    }
    
    return {
        statusCode: 500,
        body: JSON.stringify({ status: 500, message: "internal server error" }),
        headers: {
            "Content-Type": "application/json"
        }
    };
};