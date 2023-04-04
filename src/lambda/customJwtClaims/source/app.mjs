export const lambdaHandler = async (event) => {
    event.response = {
        claimsOverrideDetails: {
            claimsToAddOrOverride: {
                "https://hasura.io/jwt/claims": JSON.stringify({
                    "X-Hasura-User-Id": event.userName,
                    "X-Hasura-Default-Role": "user",
                    "X-Hasura-Allowed-Roles": ["user"],
                }),
            },
        },
    };
    
    return event;
};