import http from "http";
import https from "https";

const httpGetRequest = async function(options) {
    return new Promise(function(resolve) {
        let data = "";
        if (options.secure === false) {
            http.request(options, function(res) {
                res.on("data", function(chunk) {
                    data += chunk;
                });
                res.on("end", function() {
                    try {
                        resolve({ code: res.statusCode, data: JSON.parse(data) });
                    } catch (error) {
                        resolve({ code: 400 });
                    }
                });
            }).on("error", function(error) {
                console.log(error);
                resolve({ code: 400 });
            }).end();
        } else {
            https.request(options, function(res) {
                res.on("data", function(chunk) {
                    data += chunk;
                });
                res.on("end", function() {
                    try {
                        resolve({ code: res.statusCode, data: JSON.parse(data) });
                    } catch (error) {
                        resolve({ code: 400 });
                    }
                });
            }).on("error", function(error) {
                console.log(error);
                resolve({ code: 400 });
            }).end();
        }
    });
};

const httpPostRequest = async function(options, body) {
    return new Promise(function(resolve) {
        let data = "";
        if (options.secure === false) {
            const req = http.request(options, function(res) {
                res.on("data", function(chunk) {
                    data += chunk;
                });
                
                res.on("end", function() {
                    try {
                        resolve({ code: res.statusCode, data: JSON.parse(data) });
                    } catch (error) {
                        resolve({ code: 400 });
                    }
                });
            }).on("error", function(error) {
                console.log(error);
                resolve({ code: 400 });
            });
            
            req.write(body);
            req.end();
        } else {
            const req = https.request(options, function(res) {
                res.on("data", function(chunk) {
                    data += chunk;
                });
                
                res.on("end", function() {
                    try {
                        resolve({ code: res.statusCode, data: JSON.parse(data) });
                    } catch (error) {
                        resolve({ code: 400 });
                    }
                });
            }).on("error", function(error) {
                console.log(error);
                resolve({ code: 400 });
            });
            
            req.write(body);
            req.end();
        }
    });
};

export { httpGetRequest, httpPostRequest };