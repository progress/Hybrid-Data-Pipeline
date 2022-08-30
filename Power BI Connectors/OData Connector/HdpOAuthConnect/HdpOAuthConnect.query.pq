// Use this file to write queries to test your data connector
let
    // For OAuth 
   // result = HdpOAuthConnect.Contents()

    // For OIDC
     result = HdpOAuthConnect.Contents("OIDC", "<clientid>", "<clientsecret>", "api.odata.access",
                 "https://dev-<instance>.okta.com/oauth2/default/v1/authorize",
                 "https://dev-<instance>.okta.com/oauth2/default/v1/token",
                 "https://oauth.powerbi.com/views/oauthredirect.html",
                 "http://hdp.server.com:8080/api/odata4/Oracle", "okta")
in
    result
