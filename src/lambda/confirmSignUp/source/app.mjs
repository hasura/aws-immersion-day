import { confirmSignUp } from "./auth.mjs";

export const lambdaHandler = async(event) => {
    const {code, username} = JSON.parse(event.body);
    const status = await confirmSignUp(code, username);
    
    return {
        statusCode: status["$metadata"].httpStatusCode,
        body: JSON.stringify({ status: status.name }),
        headers: {
            "Content-Type": "application/json"
        }
    };
};