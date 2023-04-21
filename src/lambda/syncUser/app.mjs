import http from "http";
import https from "https";
import url from "url";

const getSecrets = async function() {
    return new Promise(function(resolve, reject) {
        const options = {
            hostname: "localhost",
            headers: {
                "X-AWS-Parameters-Secrets-Token": process.env.AWS_SESSION_TOKEN
            },
            method: "GET",
            path: `/secretsmanager/get?secretId=${process.env.HASURA_SECRETS_ARN}`,
            port: 2773
        };
        
        http.request(options, function(res) {
            let data ="";
            res.on("data", function(chunk) {
                data += chunk;
            });
            
            res.on("end", function() {
                resolve(JSON.parse(JSON.parse(data).SecretString));
            });
        }).on("error", function(error) {
            console.log(error);
            reject();
        }).end();
    });
};

const graphqlRequest = async function(address, secret, body) {
    console.log("Sending Request...");
    
    return new Promise(function(resolve, reject) {
        const parsedUrl = url.parse(address);
        const options = {
            hostname: parsedUrl.hostname,
            headers: {
                "Content-Type": "application/json",
                "X-Hasura-Admin-Secret": secret
            },
            method: "POST",
            path: parsedUrl.path,
            port: 443
        };
        
        const req = https.request(options, function(res) {
            let data ="";
            res.on("data", function(chunk) {
                data += chunk;
            });
            
            res.on("end", function() {
                resolve(JSON.parse(data));
            });
        }).on("error", function(error) {
            console.log(error);
            reject();
        });
        
        req.write(JSON.stringify({ query: body }));
        req.end();
    });
};

const syncUserMutation = async function(user) {
    return `mutation SyncUser {
        insert_profiles(objects: {
            first_name: "${user.firstName}",
            last_name: "${user.lastName}",
            email: "${user.email}",
            user: {
                data: {
                    user_id: "${user.userId}",
                    username: "${user.username}"
                }, on_conflict: {constraint: users_pkey, update_columns: [username]}
            },
            phones: {
                data: {
                    phone_number: ${user.phoneNumber}
                }, on_conflict: {constraint: phones_pkey, update_columns: [phone_number]}
            }
        }) {
            affected_rows
        }
    }`;
};

export const lambdaHandler = async function(event, context) {
    const user = {
        email: event.request.userAttributes.email,
        firstName: event.request.userAttributes["custom:first_name"],
        lastName: event.request.userAttributes["custom:last_name"],
        phoneNumber: event.request.userAttributes["custom:phone"],
        userId: event.request.userAttributes["sub"],
        username: event.userName
    };
    
    const hasura = await getSecrets();
    const mutation = await syncUserMutation(user);
    const response = await graphqlRequest(hasura.graphql_api, hasura.admin_secret, mutation);
    
    console.log(`Response: ${JSON.stringify(response)}`);
    
    return event;
};