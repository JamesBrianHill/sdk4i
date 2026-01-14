# SEC (Security Utilities) Component

The `SEC` component of SDK4i provides the ***foundation*** for a robust, flexible security system. User information is stored in the `SECUSRT` table, actions that need to be secured are stored in the `SECACTT` table, and groups can be defined in the `SECGRPT` table to make it easier to manage related actions and users.

The most innovative aspect of this component is the Sliding Window Authorization security model. In this model, users requests access to the applications or functionality they want to use. Those requests are approved or denied by the application/function owner. Most importantly, if approved that permission is only granted for a _limited time_ - 30 days by default.

Each security action can have a different default number of days for which granted authority is valid and each action has a flag that indicates if the granted authority is automatically renewed or not.

If granted authority is allowed to be renewed, every time the user accesses the restricted application/function, the time for which they are authorized resets - you can think of it as a rolling 30-day window. If the user fails to use the application/function before that authorization ages out, they will have to request access again.

This model was developed because of multiple issues with typical "role-based" security models such as:

- Quite often users don't fit neatly into a single role. Many times a user needs _partial_ access to _multiple_ roles. In role-based systems, you either have to create a new role just for that user or grant them authority for both roles.

- There are many times a user needs additional authority - perhaps they are helping to cover for someone who is on vacation our out on medical leave. With SDK4i's Sliding Window Authorization model, the user can be given access to just the applications/functions they need and that access will automatically go away after they stop using those functions.

The requests for access, the approval/denial, and the automatic removal of access is logged so we meet compliance requirements. You will still want to regularly review users and their access but this Sliding Window Authorization model allows for tighter security with less

## Tables

Nearly all of the security related tables are defined as [system-period temporal tables](https://www.ibm.com/docs/en/i/7.6.0?topic=administration-working-system-period-temporal-tables) to allow us to automatically capture every change.

### SECACGT/SECACGTH
This table links security actions in `SECACTT` to groups in `SECGRPT`. Each row represents an [associative entity](https://en.wikipedia.org/wiki/Associative_entity), linking an action with a group.

### SECACTT/SECACTTH
This table holds information about actions that need to be secured. An example might be, "Purge accounting data" or "View full Social Security Number".

### SECGRPT/SECGRPTH
This table holds information about groups. Groups can be used to associate related actions or users.

### SECSEST
This table holds "session" information for users who are logged in.

### SECUSAT/SECUSATH
This table links security users in `SECUSRT` to actions in `SECACTT`. Like `SECACGT`, these are associative entities.

### SECUSGT/SECUSGTH
This table links security users in `SECUSRT` to groups in `SECGRPT`. Like `SECACGT` and `SECUSAT`, these are associative entities.

### SECUSRT/SECUSRTH
This table holds information about users - anyone who needs to perform an action on your IBM i system, whether they have an IBM i user profile or not. Stored passwords hashes are created using the [HASH_SHA512](https://www.ibm.com/docs/en/i/7.6.0?topic=sf-hash-md5-hash-sha1-hash-sha256-hash-sha512) function. It should be noted there are better hashing methods such as Argon2id, bcrypt, and PBKDF2. These other hashing methods are not currently available in either RPG or Db2 for i - though they are available in other technologies such as PHP, Node, and Java that are available on IBM i.

## Procedures

The [`SEC_Authenticate`](./qrpglesrc/SEC_Authenticate.md) procedure verifies a username and password provided by a user matches a user and password hash found in `SECUSRT`. If a match was found, a type 4 [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) is generated and a row is inserted into the `SECSEST` table. If no match was found, a reason code of D (User account is disabled) or U (Unknown user or invalid password) is available in a parameter.

The [`SEC_AuthenticateBypass`](./qrpglesrc/SEC_AuthenticateBypass.md) procedure will log in a user without doing any kind of authentication. This procedure is intended for systems that already have an existing authentication mechanism in place but want to use the SDK4i `SEC` component. Note that a username or user profile must be provided and must exist in the `SECUSRT` table. If a valid username or user profile are provided, a type 4 UUID is generated and a row is inserted into the `SECSEST` table.

The [`SEC_AuthenticateUserProfile`](./qrpglesrc/SEC_AuthenticateUserProfile.md) procedure allows a user to provide a valid user profile and password that can be authenticated against IBM i using the [`QSYGETPH`](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/apis/QSYGETPH.html) API. If the credentials provided are valid, a type 4 UUID is generated and a row is inserted into the `SECSEST` table. Note that the QSYGETPH API can cause a user profile to become disabled if an invalid password is provided and this procedure is called too many times - exactly as if a user attempts to login to a 5250 session too many times with an invalid password.

The [`SEC_CreateUUID`](./qrpglesrc/SEC_CreateUUID.md) procedure will create a type 4 UUID which is needed by the `SEC_Authenticate*` procedures.

The [`SEC_IsAuthenticated`](./qrpglesrc/SEC_IsAuthenticated.md) procedure, given a token, determines if the session exists and has not expired. This procedure is typically called as part of verifying a user has authority to perform a requested action.

The [`SEC_IsAuthorized`](./qrpglesrc/SEC_IsAuthorized.md) procedure, given a token and action id, determines if the associated user has the authority to perform the requested action. The procedure returns `*ON` if the user is authorized and `*OFF` otherwise.

The [`SEC_IsAuthorizedUserProfile`](./qrpglesrc/SEC_IsAuthorizedUserProfile.md) procedure is similar to the `SEC_IsAuthorized` procedure except it needs a user profile and action id instead of a UUID token and action id.