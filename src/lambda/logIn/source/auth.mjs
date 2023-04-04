import {
    AuthFlowType,
    CognitoIdentityProviderClient,
    InitiateAuthCommand,
} from "@aws-sdk/client-cognito-identity-provider";

const logIn = async function(password, username) {
    const cognito = new CognitoIdentityProviderClient();
    const command = new InitiateAuthCommand({
        AuthFlow: AuthFlowType.USER_PASSWORD_AUTH,
        AuthParameters: {
            USERNAME: username,
            PASSWORD: password,
        },
        ClientId: process.env.CLIENT_ID
    });
    
    try {
        return await cognito.send(command);
    } catch (error) {
        return error;
    };
};

export { logIn };