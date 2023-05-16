import url from "url";
import { createUser, setPassword } from "./auth.mjs";
import { httpGetRequest, httpPostRequest } from "./request.mjs";

const getUsers = async function() {
    const parsedUrl = url.parse(process.env.USERS_LIST);
    const options = {
        hostname: parsedUrl.hostname,
        method: "GET",
        path: parsedUrl.path,
        port: 443,
        secure: true
    };
    
    const response = await httpGetRequest(options);

    if (response.code === 200) {
        try {
            return response.data.users;
        } catch (error) {
            console.log(error);
            return;
        }
    } else {
        return;
    }
};

const sendResponse = async function(event, context, status, data) {
    const body = JSON.stringify({
        Data: data,
        LogicalResourceId: event.LogicalResourceId,
        PhysicalResourceId: context.logStreamName,
        Reason: `See details in CloudWatch Log Stream: ${context.logStreamName}`,
        RequestId: event.RequestId,
        StackId: event.StackId,
        Status: status
    });
    
    console.log("Event:\n", event);
    console.log("Context:\n", context);
    console.log("Response Body:\n", body);
    
    const parsedUrl = url.parse(event.ResponseURL);
    const options = {
        hostname: parsedUrl.hostname,
        headers: {
            "Content-Length": body.length,
            "Content-Type": ""
        },
        method: "PUT",
        path: parsedUrl.path,
        port: 443,
        secure: true
    };
    
    const response = await httpPostRequest(options, body);
    
    console.log(`Status: ${response.code}`);
    console.log(`Body: ${response.data}`);
    context.done();
};

export const lambdaHandler = async function(event, context) {
    let status = "", uuid = {};
    
    if (event.RequestType === "Delete") {
        await sendResponse(event, context, "SUCCESS");
        return;
    }
    
    const users = await getUsers();
    
    if (users) {
        for (const user of users) {
            const response = await createUser(user);
            if (response.status === 201) {
                status = "SUCCESS";
                uuid[user.username] = response.uuid;
                setPassword(user);
            } else {
                status = "FAILED";
            }
        }
    }
    
    await sendResponse(event, context, status, { Users: `${JSON.stringify(uuid)}` });
    return;
};