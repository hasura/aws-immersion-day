import {
    CognitoIdentityProviderClient,
    GlobalSignOutCommand
} from "@aws-sdk/client-cognito-identity-provider";

const logOut = async function(access_token) {
    const cognito = new CognitoIdentityProviderClient();
    const command = new GlobalSignOutCommand({
        AccessToken: access_token
    });

    try {
        return await cognito.send(command);
    } catch (error) {
        return error;
    };
};

export { logOut };