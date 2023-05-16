export const lambdaHandler = async function(event) {
    event.response = {
        claimsOverrideDetails: {
            claimsToAddOrOverride: {
                "https://hasura.io/jwt/claims": JSON.stringify({
                    "X-Hasura-Allowed-Roles": ["user"],
                    "X-Hasura-Default-Role": "user",
                    "X-Hasura-User-Id": event.request.userAttributes.sub
                    /* use "event.userName" for username */
                }),
            },
        },
    };
    
    return event;
};