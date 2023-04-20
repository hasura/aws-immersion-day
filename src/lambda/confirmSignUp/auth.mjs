import {
    CognitoIdentityProviderClient,
    ConfirmSignUpCommand
} from "@aws-sdk/client-cognito-identity-provider";

const confirmSignUp = async function(user) {
    const client = new CognitoIdentityProviderClient();
    const command = new ConfirmSignUpCommand({
        ClientId: process.env.CLIENT_ID,
        ConfirmationCode: user.code,
        Username: user.username
    });
    
    try {
        const status = await client.send(command);
        return {
            status: status["$metadata"].httpStatusCode,
            message: `user ${user.username} confirmed`
        };
    } catch (error) {
        console.log(error);
        return {
            status: error["$metadata"].httpStatusCode,
            message: error.name
        };
    }
};

export { confirmSignUp };