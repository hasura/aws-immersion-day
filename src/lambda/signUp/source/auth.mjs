import {
    CognitoIdentityProviderClient,
    SignUpCommand
} from "@aws-sdk/client-cognito-identity-provider";

const signUp = async function(email, firstName, lastName, password, phoneNumber, username) {
    const cognito = new CognitoIdentityProviderClient();
    const command = new SignUpCommand({
        ClientId: process.env.CLIENT_ID,
        Username: username,
        Password: password,
        UserAttributes: [
            { Name: "email", Value: email },
            { Name: "custom:first_name", Value: firstName },
            { Name: "custom:last_name", Value: lastName },
            { Name: "custom:phone", Value: phoneNumber }
        ]
    });

    try {
        return await cognito.send(command);
    } catch (error) {
        return error;
    };
};

export { signUp };