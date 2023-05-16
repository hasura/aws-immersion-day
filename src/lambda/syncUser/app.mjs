import url from "url";
import { httpGetRequest, httpPostRequest } from "./request.mjs";

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

const syncUser = async function(secrets, user) {
    const body = `mutation SyncUser {
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
    
    const parsedUrl = url.parse(secrets.graphql_api);
    const options = {
        hostname: parsedUrl.hostname,
        headers: {
            "Content-Type": "application/json",
            "X-Hasura-Admin-Secret": secrets.admin_secret
        },
        method: "POST",
        path: parsedUrl.path,
        port: 443,
        secure: true
    };
    
    const response = await httpPostRequest(options, JSON.stringify({ query: body }));
    console.log(response);
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

export const lambdaHandler = async function(event, context) {
    const user = {
        email: event.request.userAttributes.email,
        firstName: event.request.userAttributes["custom:first_name"],
        lastName: event.request.userAttributes["custom:last_name"],
        phoneNumber: event.request.userAttributes["custom:phone"],
        userId: event.request.userAttributes["sub"],
        username: event.userName
    };
    
    const secrets = await getSecrets();
    
    if (secrets) {
        const response = await syncUser(secrets, user);
        console.log(`Response: ${JSON.stringify(response)}`);
    }
    
    return event;
};