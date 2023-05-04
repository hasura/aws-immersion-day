import {
    CognitoIdentityProviderClient,
    GlobalSignOutCommand
} from "@aws-sdk/client-cognito-identity-provider";

const logOut = async function(user) {
    const client = new CognitoIdentityProviderClient();
    const command = new GlobalSignOutCommand({
        AccessToken: user.access_token
    });

    try {
        const status = await client.send(command);
        return {
            status: status["$metadata"].httpStatusCode,
            message: "log out successful"
        }
    } catch (error) {
        console.log(error);
        return {
            status: error["$metadata"].httpStatusCode,
            message: error.name
        }
    }
};

export { logOut };