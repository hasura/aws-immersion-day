import {
    AdminCreateUserCommand,
    AdminSetUserPasswordCommand,
    CognitoIdentityProviderClient,
} from "@aws-sdk/client-cognito-identity-provider";

const client = new CognitoIdentityProviderClient();

const createUser = async function(user) {
    const command = new AdminCreateUserCommand({
        MessageAction: "SUPPRESS",
        TemporaryPassword: user.password,       
        UserAttributes: [
            { Name: "email", Value: user.email },
            { Name: "email_verified", Value: "true" },
            { Name: "custom:first_name", Value: user.first_name },
            { Name: "custom:last_name", Value: user.last_name },
            { Name: "custom:phone", Value: user.phone_number }
        ],
        Username: user.username,
        UserPoolId: process.env.USER_POOL_ID
    });
    
    try {
        let status = await client.send(command);
        for (const attribute of status.User.Attributes) {
            if (attribute.Name === "sub") {
                return {
                    status: 201,
                    message: `user ${user.username} created`,
                    uuid: attribute.Value
                };
            }
        }
    } catch (error) {
        console.log(error);
        return {
            status: error["$metadata"].httpStatusCode,
            message: error.name
        };
    }
};

const setPassword = async function(user) {
    const command = new AdminSetUserPasswordCommand({
        Password: user.password,
        Permanent: true,
        Username: user.username,
        UserPoolId: process.env.USER_POOL_ID
    });
    
    try {
        await client.send(command);
        return {
            status: 200,
            message: `user ${user.username} password set`
        };
    } catch (error) {
        console.log(error);
        return {
            status: error["$metadata"].httpStatusCode,
            message: error.name
        };
    }
};

export { createUser, setPassword };