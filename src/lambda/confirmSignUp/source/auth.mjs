import {
    CognitoIdentityProviderClient,
    ConfirmSignUpCommand
} from "@aws-sdk/client-cognito-identity-provider";

const confirmSignUp = async function(code, username) {
    const cognito = new CognitoIdentityProviderClient();
    const command = new ConfirmSignUpCommand({
        ClientId: process.env.CLIENT_ID,
        ConfirmationCode: code,
        Username: username
    });
    
    try {
        return await cognito.send(command);
    } catch (error) {
        return error;
    };
};

export { confirmSignUp };