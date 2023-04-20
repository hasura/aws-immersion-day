import { logOut } from "./auth.mjs";

export const lambdaHandler = async function(event) {
    let body = {};
    
    if (event.headers["content-type"] !== "application/json") {
        body.status = 415;
    } else if (event.httpMethod !== "POST") {
        body.status = 405;
    } else {
        try {
            const response = await logOut(JSON.parse(event.body));
            body.status = response.status;
            body.message = response.message;
        } catch (error) {
            console.log(error);
            body.status = 400;
            body.message = "bad request";
        }
    }
    
    switch (body.status) {
        case 405:
            body.message = "method not allowed";
            body.path = event.path;
            break;
        case 415:
            body.message = "unsupported media type";
            body.path = event.path;
            break;
    }
    
    return {
        statusCode: body.status,
        body: JSON.stringify(body),
        headers: {
            "Content-Type": "application/json"
        }
    };
};
