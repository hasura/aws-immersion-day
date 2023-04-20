import {
    AuthFlowType,
    CognitoIdentityProviderClient,
    InitiateAuthCommand,
} from "@aws-sdk/client-cognito-identity-provider";

const logIn = async function(user) {
    const client = new CognitoIdentityProviderClient();
    const command = new InitiateAuthCommand({
        AuthFlow: AuthFlowType.USER_PASSWORD_AUTH,
        AuthParameters: {
            USERNAME: user.username,
            PASSWORD: user.password,
        },
        ClientId: process.env.CLIENT_ID
    });
    
    try {
        const status = await client.send(command);
        return {
            status: status["$metadata"].httpStatusCode,
            message: "log in successful",
            token: {
                access: status.AuthenticationResult.AccessToken,
                id: status.AuthenticationResult.IdToken
            }
        };
    } catch (error) {
        console.log(error);
        return {
            status: error["$metadata"].httpStatusCode,
            message: error.name
        };
    }
};

export { logIn };