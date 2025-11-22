# WEB (Web Service Utilities) Component

The `WEB` component of SDK4i provides utilities related to web services, both local and remote.

The ['WEB_CallWebService`](./qrpglesrc/WEB_CallWebService.md) procedure uses the [HTTP* functions](https://www.ibm.com/docs/en/i/7.6.0?topic=programming-http-functions-overview) provided by IBM in the `QSYS2` library to call web services.

The user must have `*USE` authority to `QSYS/QSQAXISC` service program and both `5770SS1 option 3` (Extended Base Directory Support) and `5770SS1 option 34` (Digital Certificate Manager) must be installed on the system.

If you have not yet used the HTTP* functions, you might want to read this support article: [SSL Considerations for QSYS2 HTTP Functions](https://www.ibm.com/support/pages/node/6567211?myns=swgother&mynp=OCSWG60&mync=R&cm_sp=swgother-_-OCSWG60-_-R).

More `WEB_` procedures, related to locally hosted web services, are forthcoming.