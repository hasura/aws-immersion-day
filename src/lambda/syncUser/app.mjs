import axios from "axios";

async function buildRequest (user) {
    const query = 
        `mutation SyncUser {
            insert_users(objects: [
                {
                    first_name: "${user.firstName}",
                    last_name: "${user.lastName}",
                    profiles: {
                        data: [
                            {
                                email: "${user.email}",
                                phone_number: ${user.phoneNumber}
                            }
                        ]
                    },
                    user_id: "${user.userId}",
                    username: "${user.username}"
                }
            ])
            {
                affected_rows
            }
        }`;
    
    return query;
}

export const lambdaHandler = async function (event) {
    const user = {
        email: event.request.userAttributes.email,
        firstName: event.request.userAttributes["custom:first_name"],
        lastName: event.request.userAttributes["custom:last_name"],
        phoneNumber: event.request.userAttributes["custom:phone"],
        userId: event.request.userAttributes["sub"],
        username: event.userName
    };
    
    const graphMutation = await buildRequest(user);

    await axios({
       method: "POST",
       url: process.env.HASURA_GRAPHQL_API,
       headers: {
           "Content-Type": "application/json",
           "X-Hasura-Admin-Secret": process.env.HASURA_ADMIN_SECRET
       },
       data: {
           query: graphMutation
       }
    });
    
    return event;
};
