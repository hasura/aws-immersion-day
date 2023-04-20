import https from "https";
import url from "url";
import { createUser, setPassword } from "./auth.mjs";

const getUsers = async function(url) {
    return new Promise(function(resolve) {
        let data = "";
        https.get(url, function(res) {
            res.on("data", function(chunk) {
                data += chunk;
            });
            
            res.on("end", function() {
                resolve(JSON.parse(data).users);
            });
        });
    });
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
        requestUnauthorized: false,
        requestCert: false
    };
    
    console.log(`Sending Response...\n`);
    
    return new Promise(function(resolve, reject) {
        let data = "";
        const request = https.request(options, function(res) {
            console.log(`Status: ${res.statusCode}`);
            console.log(`Headers: ${JSON.stringify(res.headers)}`);
            
            res.on("data", function(chunk) {
                data += chunk;
            });
            
            res.on("end", function() {
                console.log(`Body: ${JSON.stringify(data)}`);
                resolve();
                context.done();
            });
        });
        
        request.on("error", function(error) {
            console.log(`Error: ${error}`);
            reject();
            context.done();
        });
        
        request.write(body);
        request.end();
    });
};

export const lambdaHandler = async function(event, context) {
    let status = "", uuid = {};
    
    if (event.RequestType === "Delete") {
        await sendResponse(event, context, "SUCCESS");
        return;
    }
    
    await getUsers(process.env.USERS_LIST).then(async function(users) {
        for (const user of users) {
            await createUser(user).then(function(response) {
                if (response.status === 201) {
                    status = "SUCCESS";
                    uuid[user.username] = response.uuid;
                    setPassword(user);
                } else {
                    status = "FAILED";
                }
            });
        }
    });
    
    await sendResponse(event, context, status, { Users: uuid });
    return;
};