// Use this file to write queries to test your data connector
let
    // For OAuth 
    // result = HdpOAuthConnect.Contents()

    // For OIDC
     result = HdpOAuthConnect.Contents(
        // OData Service URL
        "{{ your OData Service URL }}",
        // Auth Type
        "OIDC", 
        // Issuer Auth URL
        "{{ your Issuer Auth URL }}",
        // Issuer Token URL
        "{{ your Issuer Token URL }}",
        // Client ID
        "{{ your Client ID }}", 
        // Client Secret
        "{{ your Client Secret }}", 
        // Redirect URL
        "https://oauth.powerbi.com/views/oauthredirect.html",
        // Scope
        "{{ your Scope }}",
        // Auth Service Name
        "{{ your Auth Service Name }}",
     )
in
    result
