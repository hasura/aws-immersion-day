import { logIn } from "./auth.mjs";

export const lambdaHandler = async(event) => {
    const {password, username} = JSON.parse(event.body);
    const status = await logIn(password, username);
    
    const body = (status) => {
        if (status["$metadata"].httpStatusCode === 200) {
            return ({
                access_token: status.AuthenticationResult.AccessToken,
                id_token: status.AuthenticationResult.IdToken
            });
        } else {
            return { status: status.name };
        }
    };
    
    return {
        statusCode: status["$metadata"].httpStatusCode,
        body: JSON.stringify(body(status)),
        headers: {
            "Content-Type": "application/json"
        }
    };
};