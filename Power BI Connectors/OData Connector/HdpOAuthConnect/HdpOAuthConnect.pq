// Power BI custom connector for Progress DataDirect Hybrid Data Pipeline (HDP) OData v4 API.
// Supports Basic, OAuth 2.0, OIDC (Confidential), and OIDC (Public) authentication.
[Version = "2.0.0"]
section HdpOAuthConnect;

response_type         = "code";
code_challenge_method = "S256";
windowWidth           = 1200;
windowHeight          = 1000;

// ============================================================
// Shared connector functions — one per auth type, one kind each
// ============================================================

[DataSource.Kind="HdpBasicConnect", Publish="HdpBasicConnect.Publish"]
shared HdpOAuthConnect.Basic = Value.ReplaceType(BasicImpl, BasicMeta);

[DataSource.Kind="HdpOAuth2Connect", Publish="HdpOAuth2Connect.Publish"]
shared HdpOAuthConnect.OAuth = Value.ReplaceType(OAuthImpl, OAuthMeta);

[DataSource.Kind="HdpOIDCConfidentialConnect", Publish="HdpOIDCConfidentialConnect.Publish"]
shared HdpOAuthConnect.OIDCConfidential = Value.ReplaceType(OIDCConfidentialImpl, OIDCConfidentialMeta);

[DataSource.Kind="HdpOIDCPublicConnect", Publish="HdpOIDCPublicConnect.Publish"]
shared HdpOAuthConnect.OIDCPublic = Value.ReplaceType(OIDCPublicImpl, OIDCPublicMeta);

// Unit test harness — not associated with a DataSource.Kind so PQTest can
// evaluate it without requiring OAuth credentials.
[Documentation.Hidden = true]
shared HdpOAuthConnect.UnitTests = [
    StartLoginImpl                 = StartLoginImpl,
    FinishLogin                    = FinishLogin,
    TokenMethod                    = TokenMethod,
    BuildTokenBody                 = BuildTokenBody,
    GetOIDCDataOptions             = GetOIDCDataOptions,
    ValidateODataServiceUrl        = ValidateODataServiceUrl,
    BasicTestConnection            = BasicTestConnection,
    OAuthTestConnection            = OAuthTestConnection,
    OIDCConfidentialTestConnection = OIDCConfidentialTestConnection,
    OIDCPublicTestConnection       = OIDCPublicTestConnection,
    IsPresent                      = IsPresent,
    Base64Url.Encode               = Base64Url.Encode
];

// ============================================================
// ConnectorMeta type definitions
// ============================================================

BasicMeta = type function (
    ODataServiceURL as (type text meta [
        Documentation.FieldCaption = "OData Access URI",
        Documentation.SampleValues = {"http://HdpServer:8080/api/odata4/EmployeeData"}
    ]))
    as table meta [
        Documentation.Name = "HDP OData — Basic Auth",
        Documentation.LongDescription = "Connect to a Progress DataDirect HDP OData v4 endpoint using Basic (username/password) authentication."
    ];

OAuthMeta = type function (
    ODataServiceURL as (type text meta [
        Documentation.FieldCaption = "OData Access URI",
        Documentation.SampleValues = {"http://HdpServer:8080/api/odata4/EmployeeData"}
    ]),
    IssuerAuthUrl as (type text meta [
        Documentation.FieldCaption = "Authorization URL",
        Documentation.SampleValues = {"https://dev.okta.com/oauth2/default/v1/authorize"}
    ]),
    IssuerTokenUrl as (type text meta [
        Documentation.FieldCaption = "Token URL",
        Documentation.SampleValues = {"https://dev.okta.com/oauth2/default/v1/token"}
    ]),
    ClientID as (type text meta [
        Documentation.FieldCaption = "Client ID",
        Documentation.SampleValues = {"uya4567adsf98"}
    ]),
    ClientSecret as (type text meta [
        Documentation.FieldCaption = "Client Secret",
        Documentation.SampleValues = {"adsf462adsf98sdgf7776"}
    ]),
    RedirectURL as (type text meta [
        Documentation.FieldCaption = "Redirect URL",
        Documentation.DefaultValue = "https://oauth.powerbi.com/views/oauthredirect.html",
        Documentation.SampleValues = {"https://oauth.powerbi.com/views/oauthredirect.html"}
    ]),
    Scope as (type text meta [
        Documentation.FieldCaption = "Scope",
        Documentation.SampleValues = {"api.access.odata"}
    ]))
    as table meta [
        Documentation.Name = "HDP OData — OAuth 2.0",
        Documentation.LongDescription = "Connect to a Progress DataDirect HDP OData v4 endpoint using OAuth 2.0 authorization code flow."
    ];

OIDCConfidentialMeta = type function (
    ODataServiceURL as (type text meta [
        Documentation.FieldCaption = "OData Access URI",
        Documentation.SampleValues = {"http://HdpServer:8080/api/odata4/EmployeeData"}
    ]),
    IssuerAuthUrl as (type text meta [
        Documentation.FieldCaption = "Authorization URL",
        Documentation.SampleValues = {"https://dev.okta.com/oauth2/default/v1/authorize"}
    ]),
    IssuerTokenUrl as (type text meta [
        Documentation.FieldCaption = "Token URL",
        Documentation.SampleValues = {"https://dev.okta.com/oauth2/default/v1/token"}
    ]),
    ClientID as (type text meta [
        Documentation.FieldCaption = "Client ID",
        Documentation.SampleValues = {"uya4567adsf98"}
    ]),
    ClientSecret as (type text meta [
        Documentation.FieldCaption = "Client Secret",
        Documentation.SampleValues = {"adsf462adsf98sdgf7776"}
    ]),
    RedirectURL as (type text meta [
        Documentation.FieldCaption = "Redirect URL",
        Documentation.DefaultValue = "https://oauth.powerbi.com/views/oauthredirect.html",
        Documentation.SampleValues = {"https://oauth.powerbi.com/views/oauthredirect.html"}
    ]),
    Scope as (type text meta [
        Documentation.FieldCaption = "Scope",
        Documentation.SampleValues = {"api.access.odata"}
    ]),
    AuthServiceName as (type text meta [
        Documentation.FieldCaption = "HDP Auth Service",
        Documentation.SampleValues = {"OktaAuthService"}
    ]))
    as table meta [
        Documentation.Name = "HDP OData — OIDC Confidential",
        Documentation.LongDescription = "Connect to a Progress DataDirect HDP OData v4 endpoint using OIDC with a confidential client (client secret). Requires a Web redirect URI in your identity provider."
    ];

OIDCPublicMeta = type function (
    ODataServiceURL as (type text meta [
        Documentation.FieldCaption = "OData Access URI",
        Documentation.SampleValues = {"http://HdpServer:8080/api/odata4/EmployeeData"}
    ]),
    IssuerAuthUrl as (type text meta [
        Documentation.FieldCaption = "Authorization URL",
        Documentation.SampleValues = {"https://dev.okta.com/oauth2/default/v1/authorize"}
    ]),
    IssuerTokenUrl as (type text meta [
        Documentation.FieldCaption = "Token URL",
        Documentation.SampleValues = {"https://dev.okta.com/oauth2/default/v1/token"}
    ]),
    ClientID as (type text meta [
        Documentation.FieldCaption = "Client ID",
        Documentation.SampleValues = {"uya4567adsf98"}
    ]),
    RedirectURL as (type text meta [
        Documentation.FieldCaption = "Redirect URL",
        Documentation.DefaultValue = "https://oauth.powerbi.com/views/oauthredirect.html",
        Documentation.SampleValues = {"https://oauth.powerbi.com/views/oauthredirect.html"}
    ]),
    Scope as (type text meta [
        Documentation.FieldCaption = "Scope",
        Documentation.SampleValues = {"api.access.odata"}
    ]),
    AuthServiceName as (type text meta [
        Documentation.FieldCaption = "HDP Auth Service",
        Documentation.SampleValues = {"OktaAuthService"}
    ]))
    as table meta [
        Documentation.Name = "HDP OData — OIDC Public",
        Documentation.LongDescription = "Connect to a Progress DataDirect HDP OData v4 endpoint using OIDC with PKCE (public client). Requires a Single-Page Application (SPA) redirect URI in your identity provider."
    ];

// ============================================================
// Helper functions
// ============================================================

// Returns true if the value is a non-empty string, treating "" the same as null.
IsPresent = (value as text) => value <> "";

// Normalizes a parameter value: treats the sentinel "none" (case-insensitive) as "".
NormalizeParam = (value as text) as text =>
    if Text.Lower(value) = "none" then "" else value;

// Validates that the OData service URL has an http or https scheme.
ValidateODataServiceUrl = (url as text) =>
    let
        trimmed    = Text.Trim(url),
        normalized = Text.Lower(trimmed),
        isValid    = Text.StartsWith(normalized, "http://") or Text.StartsWith(normalized, "https://")
    in
        if not isValid
        then error Error.Record(
            "DataSource.Error",
            "Invalid OData Service URL: the URL must start with http:// or https://.",
            [Url = trimmed])
        else trimmed;

// Encodes a binary value as a Base64URL string (RFC 4648 §5).
Base64Url.Encode = (value as binary) as text =>
    Text.Replace(
        Text.Replace(
            Text.BeforeDelimiter(Binary.ToText(value, BinaryEncoding.Base64), "="),
            "+", "-"),
        "/", "_");

// Builds the OData options record for OIDC connectors.
// Injects the x-datadirect-authService header when AuthServiceName is provided.
GetOIDCDataOptions = (AuthServiceName as text) =>
    if IsPresent(AuthServiceName)
    then [ Headers = [#"x-datadirect-authService" = AuthServiceName], ODataVersion = 4, MoreColumns = true ]
    else [ ODataVersion = 4, MoreColumns = true ];

// ============================================================
// Connector implementation functions
// ============================================================

BasicImpl = (ODataServiceURL as text) =>
let
    validatedUrl = ValidateODataServiceUrl(ODataServiceURL),
    source = OData.Feed(validatedUrl, null, [ ODataVersion = 4, MoreColumns = true ])
in
    source;

OAuthImpl = (
    ODataServiceURL as text,
    IssuerAuthUrl   as text,
    IssuerTokenUrl  as text,
    ClientID        as text,
    ClientSecret    as text,
    RedirectURL     as text,
    Scope           as text
) =>
let
    validatedUrl = ValidateODataServiceUrl(ODataServiceURL),
    source = OData.Feed(validatedUrl, null, [ ODataVersion = 4, MoreColumns = true ])
in
    source;

OIDCConfidentialImpl = (
    ODataServiceURL as text,
    IssuerAuthUrl   as text,
    IssuerTokenUrl  as text,
    ClientID        as text,
    ClientSecret    as text,
    RedirectURL     as text,
    Scope           as text,
    AuthServiceName as text
) =>
let
    validatedUrl = ValidateODataServiceUrl(ODataServiceURL),
    source = OData.Feed(validatedUrl, null, GetOIDCDataOptions(AuthServiceName))
in
    source;

OIDCPublicImpl = (
    ODataServiceURL as text,
    IssuerAuthUrl   as text,
    IssuerTokenUrl  as text,
    ClientID        as text,
    RedirectURL     as text,
    Scope           as text,
    AuthServiceName as text
) =>
let
    validatedUrl = ValidateODataServiceUrl(ODataServiceURL),
    source = OData.Feed(validatedUrl, null, GetOIDCDataOptions(AuthServiceName))
in
    source;

// ============================================================
// TestConnection functions (one per kind)
// ============================================================

BasicTestConnection = (dataSourcePath) =>
let
    json = Json.Document(dataSourcePath)
in
    {"HdpOAuthConnect.Basic", json[ODataServiceURL]};

OAuthTestConnection = (dataSourcePath) =>
let
    json = Json.Document(dataSourcePath)
in
    {
        "HdpOAuthConnect.OAuth",
        json[ODataServiceURL], json[IssuerAuthUrl], json[IssuerTokenUrl],
        json[ClientID], json[ClientSecret], json[RedirectURL], json[Scope]
    };

OIDCConfidentialTestConnection = (dataSourcePath) =>
let
    json = Json.Document(dataSourcePath)
in
    {
        "HdpOAuthConnect.OIDCConfidential",
        json[ODataServiceURL], json[IssuerAuthUrl], json[IssuerTokenUrl],
        json[ClientID], json[ClientSecret], json[RedirectURL], json[Scope], json[AuthServiceName]
    };

OIDCPublicTestConnection = (dataSourcePath) =>
let
    json = Json.Document(dataSourcePath)
in
    {
        "HdpOAuthConnect.OIDCPublic",
        json[ODataServiceURL], json[IssuerAuthUrl], json[IssuerTokenUrl],
        json[ClientID], json[RedirectURL], json[Scope], json[AuthServiceName]
    };

// ============================================================
// DataSource kind definitions
// ============================================================

HdpBasicConnect = [
    TestConnection = BasicTestConnection,
    Authentication = [ UsernamePassword = [] ],
    Label = Extension.LoadString("DataSourceLabel_Basic")
];

HdpOAuth2Connect = [
    TestConnection = OAuthTestConnection,
    Authentication = [
        OAuth = [ StartLogin = StartLoginOAuth2, FinishLogin = FinishLogin, Refresh = Refresh, Label = Extension.LoadString("OAuthLabel") ]
    ],
    Label = Extension.LoadString("DataSourceLabel_OAuth")
];

HdpOIDCConfidentialConnect = [
    TestConnection = OIDCConfidentialTestConnection,
    Authentication = [
        OAuth = [ StartLogin = StartLoginOIDCConfidential, FinishLogin = FinishLogin, Refresh = Refresh, Label = Extension.LoadString("OAuthLabel") ]
    ],
    Label = Extension.LoadString("DataSourceLabel_OIDCConfidential")
];

HdpOIDCPublicConnect = [
    TestConnection = OIDCPublicTestConnection,
    Authentication = [
        OAuth = [ StartLogin = StartLoginOIDCPublic, FinishLogin = FinishLogin, Refresh = Refresh, Label = Extension.LoadString("OAuthLabel") ]
    ],
    Label = Extension.LoadString("DataSourceLabel_OIDCPublic")
];

// ============================================================
// OAuth flow functions (shared across all OAuth kinds)
// ============================================================

// Core StartLogin implementation. isPkce=true adds PKCE challenge params and
// returns the code_verifier in Context for FinishLogin to use.
StartLoginImpl = (resourceUrl, state, display, isPkce as logical) =>
let
    _traceRaw = Diagnostics.Trace(TraceLevel.Information,
        "HdpOAuthConnect.StartLogin: resourceUrl=" & resourceUrl,
        resourceUrl),

    inputData   = Json.Document(_traceRaw),
    clientId    = NormalizeParam(Record.FieldOrDefault(inputData, "ClientID",      null) ?? ""),
    authUrl     = NormalizeParam(Record.FieldOrDefault(inputData, "IssuerAuthUrl", null) ?? ""),
    scope       = NormalizeParam(Record.FieldOrDefault(inputData, "Scope",         null) ?? ""),
    redirectUrl = NormalizeParam(Record.FieldOrDefault(inputData, "RedirectURL",   null) ?? ""),

    _traceFields = Diagnostics.Trace(TraceLevel.Information,
        "HdpOAuthConnect.StartLogin: isPkce=" & Text.From(isPkce)
            & " authUrl='"      & authUrl
            & "' clientId='"    & clientId
            & "' redirectUrl='" & redirectUrl
            & "' scope='"       & scope & "'",
        null),

    plainTextCodeVerifier = Text.NewGuid() & Text.NewGuid(),
    codeChallenge = Base64Url.Encode(
        Crypto.CreateHash(CryptoAlgorithm.SHA256, Text.ToBinary(plainTextCodeVerifier))
    ),

    baseParams = [
        client_id     = clientId,
        state         = state,
        response_type = response_type,
        scope         = scope,
        redirect_uri  = redirectUrl
    ],
    pkceParams = if isPkce then [
        code_challenge_method = code_challenge_method,
        code_challenge        = codeChallenge
    ] else [],

    AuthorizeUrl = Text.Combine({authUrl, "?"}) & Uri.BuildQueryString(baseParams & pkceParams),

    tracedUrl = Diagnostics.Trace(TraceLevel.Information,
        "HdpOAuthConnect.StartLogin: LoginUri=" & AuthorizeUrl,
        AuthorizeUrl)
in
    [
        LoginUri     = tracedUrl,
        CallbackUri  = redirectUrl,
        WindowHeight = windowHeight,
        WindowWidth  = windowWidth,
        Context      = if isPkce then plainTextCodeVerifier else null
    ];

// Per-kind wrappers — bake isPkce into the closure so Power BI calls the right variant.
StartLoginOAuth2           = (resourceUrl, state, display) => StartLoginImpl(resourceUrl, state, display, false);
StartLoginOIDCConfidential = (resourceUrl, state, display) => StartLoginImpl(resourceUrl, state, display, false);
StartLoginOIDCPublic       = (resourceUrl, state, display) => StartLoginImpl(resourceUrl, state, display, true);

FinishLogin = (clientApplication, resourceUrl, context, callbackUri, state) =>
let
    inputData    = Json.Document(resourceUrl),
    clientId     = NormalizeParam(Record.FieldOrDefault(inputData, "ClientID",       null) ?? ""),
    clientSecret = NormalizeParam(Record.FieldOrDefault(inputData, "ClientSecret",   null) ?? ""),
    tokenUrl     = NormalizeParam(Record.FieldOrDefault(inputData, "IssuerTokenUrl", null) ?? ""),
    redirectUrl  = NormalizeParam(Record.FieldOrDefault(inputData, "RedirectURL",    null) ?? ""),
    parts        = Uri.Parts(callbackUri)[Query],

    tracedParts = Diagnostics.Trace(TraceLevel.Information,
        "HdpOAuthConnect.FinishLogin:"
            & " hasCode="    & Text.From(Record.HasFields(parts, "code"))
            & " hasError="   & Text.From(Record.HasFields(parts, "error"))
            & " hasContext=" & Text.From(context <> null),
        parts),

    result = if (Record.HasFields(tracedParts, "error"))
             then
                error Error.Record(tracedParts[error], Record.FieldOrDefault(tracedParts, "error_description", "Authorization failed"), tracedParts)
             else if (not Record.HasFields(tracedParts, "code")) then
                error Error.Record("DataSource.Error", "Authorization callback did not contain a 'code' parameter. Check your IdP configuration.", tracedParts)
             else
                TokenMethod("authorization_code", tracedParts[code], clientId, clientSecret, tokenUrl, redirectUrl, context)
in
    result;

BuildTokenBody = (grantType, code, clientId, clientSecret, redirectUrl, optional codeVerifier) =>
let
    base = [
        client_id    = clientId,
        grant_type   = grantType,
        redirect_uri = redirectUrl
    ],
    withSecret   = if IsPresent(clientSecret) then [ client_secret = clientSecret ] else [],
    withCode     = if (grantType = "refresh_token")
                   then [ refresh_token = code ]
                   else [ code = code ],
    withVerifier = if (codeVerifier <> null) then [ code_verifier = codeVerifier ] else []
in
    base & withSecret & withCode & withVerifier;

TokenMethod = (grantType, code, clientId, clientSecret, tokenUrl, redirectUrl, optional codeVerifier) =>
let
    body   = BuildTokenBody(grantType, code, clientId, clientSecret, redirectUrl, codeVerifier),
    origin = let p = Uri.Parts(redirectUrl) in p[Scheme] & "://" & p[Host],
    isPkce = (codeVerifier <> null),
    headers = if isPkce then [
        #"Content-type" = "application/x-www-form-urlencoded",
        #"Accept"       = "application/json",
        #"Origin"       = origin
    ] else [
        #"Content-type" = "application/x-www-form-urlencoded",
        #"Accept"       = "application/json"
    ],

    tracedBody = Diagnostics.Trace(TraceLevel.Information,
        "HdpOAuthConnect.TokenMethod: grantType=" & grantType
            & " tokenUrl="    & tokenUrl
            & " hasVerifier=" & Text.From(isPkce)
            & " hasSecret="   & Text.From(Record.HasFields(body, "client_secret"))
            & " origin="      & (if isPkce then origin else "n/a"),
        body),

    Response = Web.Contents(tokenUrl, [
                    Content              = Text.ToBinary(Uri.BuildQueryString(tracedBody)),
                    Headers              = headers,
                    ManualStatusHandling = {400}
                ]),
    Parts = Json.Document(Response),

    tracedParts = Diagnostics.Trace(TraceLevel.Information,
        "HdpOAuthConnect.TokenMethod: response hasError=" & Text.From(Record.HasFields(Parts, "error"))
            & " hasAccessToken=" & Text.From(Record.HasFields(Parts, "access_token")),
        Parts),

    Result = if (Record.HasFields(tracedParts, "error"))
             then
                error Error.Record(tracedParts[error], Record.FieldOrDefault(tracedParts, "error_description", "Token request failed"), tracedParts)
             else
                tracedParts
in
    Result;

Refresh = (resourceUrl, refresh_token) =>
let
    inputData    = Json.Document(resourceUrl),
    clientId     = NormalizeParam(Record.FieldOrDefault(inputData, "ClientID",       null) ?? ""),
    clientSecret = NormalizeParam(Record.FieldOrDefault(inputData, "ClientSecret",   null) ?? ""),
    tokenUrl     = NormalizeParam(Record.FieldOrDefault(inputData, "IssuerTokenUrl", null) ?? ""),
    redirectUrl  = NormalizeParam(Record.FieldOrDefault(inputData, "RedirectURL",    null) ?? ""),
    result = TokenMethod("refresh_token", refresh_token, clientId, clientSecret, tokenUrl, redirectUrl)
in
    result;

// ============================================================
// Publish records
// ============================================================

HdpBasicConnect.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { Extension.LoadString("DataSourceLabel_Basic"), Extension.LoadString("ButtonHelp_Basic") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = HdpOAuthConnect.Icons,
    SourceTypeImage = HdpOAuthConnect.Icons
];

HdpOAuth2Connect.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { Extension.LoadString("DataSourceLabel_OAuth"), Extension.LoadString("ButtonHelp_OAuth") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = HdpOAuthConnect.Icons,
    SourceTypeImage = HdpOAuthConnect.Icons
];

HdpOIDCConfidentialConnect.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { Extension.LoadString("DataSourceLabel_OIDCConfidential"), Extension.LoadString("ButtonHelp_OIDCConfidential") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = HdpOAuthConnect.Icons,
    SourceTypeImage = HdpOAuthConnect.Icons
];

HdpOIDCPublicConnect.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { Extension.LoadString("DataSourceLabel_OIDCPublic"), Extension.LoadString("ButtonHelp_OIDCPublic") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = HdpOAuthConnect.Icons,
    SourceTypeImage = HdpOAuthConnect.Icons
];

HdpOAuthConnect.Icons = [
    Icon16 = { Extension.Contents("HdpOAuthConnect16.png"), Extension.Contents("HdpOAuthConnect20.png"), Extension.Contents("HdpOAuthConnect24.png"), Extension.Contents("HdpOAuthConnect32.png") },
    Icon32 = { Extension.Contents("HdpOAuthConnect32.png"), Extension.Contents("HdpOAuthConnect40.png"), Extension.Contents("HdpOAuthConnect48.png"), Extension.Contents("HdpOAuthConnect64.png") }
];
