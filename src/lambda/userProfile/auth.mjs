import {
    CognitoIdentityProviderClient,
    GetUserCommand
} from "@aws-sdk/client-cognito-identity-provider";

const userData = async function(bearer) {
    const client = new CognitoIdentityProviderClient();
    const command = new GetUserCommand({
        AccessToken: bearer
    });
    
    try {
        const status = await client.send(command);
        let data = { username: status.Username };
        
        for (const key of status.UserAttributes) {
            switch (key.Name) {
                case "custom:first_name":
                    data.first_name = key.Value;
                    break;
                case "custom:last_name":
                    data.last_name = key.Value;
                    break;
                case "custom:phone":
                    data.phone_number = key.Value;
                    break;
                case "sub":
                    data.id = key.Value;
                default:
                    data[key.Name] = key.Value;
            }
        }
        
        return {
            status: 200,
            message: `user data for ${status.Username}`,
            user: data
        };
    } catch (error) {
        console.log(error);
        return {
            status: error["$metadata"].httpStatusCode,
            message: error.name
        };
    }
};

export { userData };