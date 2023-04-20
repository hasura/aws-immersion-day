import {
    CognitoIdentityProviderClient,
    SignUpCommand
} from "@aws-sdk/client-cognito-identity-provider";

const signUp = async function(user) {
    const client = new CognitoIdentityProviderClient();
    const command = new SignUpCommand({
        ClientId: process.env.CLIENT_ID,
        Password: user.password,
        Username: user.username,
        UserAttributes: [
            { Name: "email", Value: user.email },
            { Name: "custom:first_name", Value: user.first_name },
            { Name: "custom:last_name", Value: user.last_name },
            { Name: "custom:phone", Value: user.phone_number }
        ]
    });
    
    try {
        await client.send(command);
        return {
            status: 201,
            message: `user ${user.username} created`
        };
    } catch (error) {
        console.log(error);
        return {
            status: error["$metadata"].httpStatusCode,
            message: error.name
        };
    }
};

export { signUp };