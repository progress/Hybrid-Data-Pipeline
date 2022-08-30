section HdpOAuthConnect;
response_type = "code";
windowWidth = 1200;
windowHeight = 1000;
[DataSource.Kind="HdpOAuthConnect", Publish="HdpOAuthConnect.Publish"]
shared HdpOAuthConnect.Contents = Value.ReplaceType(ContentsImpl, AuthType);

AuthType = type function(
     ODataServiceURL as (type text meta [
        Documentation.FieldCaption = "OData Access URI",
        Documentation.SampleValues = {"http://HdpServer:8080/api/odata4/EmployeeData"}
     ]),
    AuthTypeValue as (type text meta[
        Documentation.FieldCaption = "Authentication Method",
        Documentation.FieldDescription = "Select the Authentication Method",
        Documentation.AllowedValues = {"Basic", "OAuth 2.0", "OIDC"}
    ]),
    IssuerAuthUrl as (type nullable text meta [
        Documentation.FieldCaption = "Authorization URL",
        Documentation.FieldDescription = "Required for OAuth 2.0 & OIDC",
        Documentation.SampleValues = {"https://dev.okta.com/oauth2/default/v1/authorize"}
    ]),
    IssuerTokenUrl as (type nullable text meta [
        Documentation.FieldCaption = "Token URL",
        Documentation.FieldDescription = "Required for OAuth 2.0 & OIDC",
        Documentation.SampleValues = {"https://dev.okta.com/oauth2/default/v1/token"}
    ]),
    ClientID as (type nullable text meta [
        Documentation.FieldCaption = "Client ID",
        Documentation.FieldDescription = "Required for OAuth 2.0 & OIDC",
        Documentation.SampleValues = {"uya4567adsf98"}
    ]),
    ClientSecret as (type nullable text meta [
        Documentation.FieldCaption = "Client Secret",
        Documentation.FieldDescription = "Required for OAuth 2.0 & OIDC",
        Documentation.SampleValues = {"adsf462adsf98sdgf7776"}
    ]),
    RedirectURL as (type nullable text meta [
        Documentation.FieldCaption = "Redirect URL",
        Documentation.FieldDescription = "Required for OAuth 2.0 & OIDC",
        Documentation.SampleValues = {"https://oauth.powerbi.com/views/oauthredirect.html"}
    ]),
    optional AuthServiceName as (type text meta [
        Documentation.FieldCaption = "HDP Auth Service",
        Documentation.FieldDescription = "Required for OIDC",
        Documentation.SampleValues = {"OktaAuthService. Applicable only for OIDC"}
    ])
    )
    as table meta [
        Documentation.Name = "Hybrid Data Pipeline OData Connector"
    ];
ContentsImpl = (ODataServiceURL as text, AuthTypeValue as text, IssuerAuthUrl as nullable text, IssuerTokenUrl as nullable text, ClientID as nullable text, ClientSecret as nullable text, RedirectURL as nullable text,
                    optional AuthServiceName as text) =>
let
    source = if(AuthTypeValue = "OIDC")
            then
             OData.Feed(
                ODataServiceURL,
                null,
                [ Headers = [#"x-datadirect-authService" = AuthServiceName], ODataVersion = 4, MoreColumns = true ])
            else
               OData.Feed(
                ODataServiceURL,
                null,
                [ ODataVersion = 4, MoreColumns = true ])
in
    source;
// Data Source definition
HdpOAuthConnect = [
    Authentication = [
        UsernamePassword=[],
        OAuth = [
            StartLogin = StartLogin,
            FinishLogin = FinishLogin,
            Label = "OAuth 2.0"
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];
StartLogin = (resourceUrl, state, display) =>
let
    inputData = Json.Document(resourceUrl),
    clientId = inputData[ClientID],
    clientSecret = inputData[ClientSecret],
    authUrl = inputData[IssuerAuthUrl],
    scope = "api.access.odata",
    redirectUrl = inputData[RedirectURL],
    AuthorizeUrl = Text.Combine({authUrl, "?"}) 
                    & Uri.BuildQueryString([
                        client_id = clientId,
                        state = state,
                        response_type = response_type,
                        scope = scope,
                        redirect_uri = redirectUrl])
in
    [
        LoginUri = AuthorizeUrl,
        CallbackUri = redirectUrl,
        WindowHeight = windowHeight,
        WindowWidth = windowWidth,
        Context = null
    ];
FinishLogin = (clientApplication, resourceUrl, context, callbackUri, state) =>
let
    inputData = Json.Document(resourceUrl),
    clientId = inputData[ClientID],
    clientSecret = inputData[ClientSecret],
    tokenUrl =  inputData[IssuerTokenUrl],
    redirectUrl = inputData[RedirectURL],
    parts = Uri.Parts(callbackUri)[Query],
    result = if (Record.HasFields(parts, {"error", "error_description"})) 
             then
                error Error.Record(parts[error], parts[error_description], parts)
             else
                TokenMethod("authorization_code", parts[code], clientId, clientSecret, tokenUrl, redirectUrl)
in
    result;
TokenMethod = (grantType, code, clientId, clientSecret, tokenUrl, redirectUrl) =>
let
    query = [
    client_id = clientId,
    client_secret = clientSecret,
    grant_type = "authorization_code",
    redirect_uri = redirectUrl],
    queryWithCode = if (grantType = "refresh_token") 
                    then [ refresh_token = code ] 
                    else [code = code],
    Response = Web.Contents(tokenUrl, [
                    Content = Text.ToBinary(Uri.BuildQueryString(query & queryWithCode)),
                    Headers=[#"Content-type" = "application/x-www-form-urlencoded",#"Accept" = "application/json"], ManualStatusHandling = {400}
                ]),
    Parts = Json.Document(Response),
    Result = if (Record.HasFields(Parts, {"error", "error_description"})) 
             then 
                error Error.Record(Parts[error], Parts[error_description], Parts)
             else
                Parts
    in
        Result;
Refresh = (resourceUrl, refresh_token) => 
let
    inputData = Json.Document(resourceUrl),
    clientId = inputData[ClientID],
    clientSecret = inputData[ClientSecret],
    tokenUrl = inputData[IssuerTokenUrl],
    redirectUrl = inputData[RedirectURL],
    result = TokenMethod("refresh_token", refresh_token, clientId, clientSecret, tokenUrl, redirectUrl)
in
    result;
// Data Source UI publishing description
HdpOAuthConnect.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = HdpOAuthConnect.Icons,
    SourceTypeImage = HdpOAuthConnect.Icons
];
HdpOAuthConnect.Icons = [
    Icon16 = { Extension.Contents("HdpOAuthConnect16.png"), Extension.Contents("HdpOAuthConnect20.png"), Extension.Contents("HdpOAuthConnect24.png"), Extension.Contents("HdpOAuthConnect32.png") },
    Icon32 = { Extension.Contents("HdpOAuthConnect32.png"), Extension.Contents("HdpOAuthConnect40.png"), Extension.Contents("HdpOAuthConnect48.png"), Extension.Contents("HdpOAuthConnect64.png") }
];