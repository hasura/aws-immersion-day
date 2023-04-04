import { logOut } from "./auth.mjs";

export const lambdaHandler = async(event) => {
    const {access_token} = JSON.parse(event.body);
    const status = await logOut(access_token);

    return {
        statusCode: status["$metadata"].httpStatusCode,
        body: JSON.stringify(status.name),
        headers: {
            "Content-Type": "application/json"
        }
    };
};