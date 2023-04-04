import axios from "axios";

async function buildRequest (user) {
    let query = 
        `mutation SyncUser {
            insert_users(objects: [
                {
                    first_name: "${user.firstName}",
                    last_name: "${user.lastName}",
                    username: "${user.username}",
                    profiles: {
                        data: [
                            {
                                email: "${user.email}",
                                phone: ${user.phoneNumber}
                            }
                        ]
                    }
                }
            ])
            {
                affected_rows
            }
        }`;
    
    return query;
};

export const lambdaHandler = async (event) => {
    const user = {
        email: event.request.userAttributes.email,
        firstName: event.request.userAttributes["custom:first_name"],
        lastName: event.request.userAttributes["custom:last_name"],
        phoneNumber: event.request.userAttributes["custom:phone"],
        username: event.userName
    };
    
    let graphQuery = await buildRequest(user);

    await axios({
       method: "POST",
       url: process.env.HASURA_GRAPHQL_API,
       headers: {
           "Content-Type": "application/json",
           "X-Hasura-Admin-Secret": process.env.HASURA_ADMIN_SECRET
       },
       data: {
           query: graphQuery
       }
    });
    
    return event;
};