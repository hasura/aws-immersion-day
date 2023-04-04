import { signUp } from "./auth.mjs";

export const lambdaHandler = async (event) => {
    const {email, first_name, last_name, password, phone, username} = JSON.parse(event.body);
    const status = await signUp(email, first_name, last_name, password, phone, username);
    
    return {
        statusCode: status["$metadata"].httpStatusCode,
        body: JSON.stringify({ status: status.name }),
        headers: {
            "Content-Type": "application/json"
        }
    };
};