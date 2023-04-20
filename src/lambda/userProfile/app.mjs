import { userData } from "./auth.mjs";

export const lambdaHandler = async function(event) {
    let body = {};
    
    if (typeof event.queryStringParameters.access_token === "undefined") {
        body.status = 401;
        body.message = "unauthorized";
    } else if (event.httpMethod !== "GET") {
        body.status = 405;
        body.message = "method not allowed";
    } else {
        try {
            const response = await userData(event.queryStringParameters.access_token);
            body.status = response.status;
            body.message = response.message;
            body.user = response.user;
        } catch (error) {
            console.log(error);
            body.status = 400;
            body.message = "bad request";
        }
    }
    
    return {
        statusCode: body.status,
        body: JSON.stringify(body),
        headers: {
            "Content-Type": "application/json"
        }
    };
};
