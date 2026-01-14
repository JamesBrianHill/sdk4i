# Procedure: **SEC_AuthenticateUserProfile**

## **Overview**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`SEC_AuthenticateUserProfile` authenticates a user by validating an IBM i user profile and password, then creates a security session within the SDK4i security framework.

The procedure uses the IBM i profile authentication APIs to validate the provided user profile and password. If authentication succeeds, it locates the corresponding security user record in the `SECUSRT` table, verifies that the account is enabled, generates a new session UUID, and inserts a session record into the `SECSEST` table.

On success, the procedure returns *ON and outputs a session token. On failure, it returns *OFF and provides a reason code indicating why authentication failed. All authentication attempts, errors, and abnormal conditions are logged using the standard logging framework.

This procedure is intended for environments where IBM i user profile authentication is required in addition to SDK4i security enforcement.

---

## **Example Usage**

```rpg
//---------------------------------------------------------------------
// Example: Authenticate using IBM i user profile and password
//---------------------------------------------------------------------
ctl-opt dftactgrp(*no) actgrp(*new);

// Prototypes
dcl-pr SEC_AuthenticateUserProfile ind;
  i_usrprf like(tpl_sdk4i_secusrt_ds.usrprf) options(*trim) const;
  i_password char(512) options(*trim) const;
  o_token like(tpl_sdk4i_uuid);
  o_reason_code like(tpl_sdk4i_secusrt_ds.is_enabled);
  i_log_user_info_ds likeds(tpl_sdk4i_log_user_info_ds) options(*nopass:*nullind:*omit);
end-pr;

dcl-s sessionToken like(tpl_sdk4i_uuid);
dcl-s reasonCode   like(tpl_sdk4i_secusrt_ds.is_enabled);
dcl-ds userInfo likeds(tpl_sdk4i_log_user_info_ds);

dcl-s isAuthenticated ind;

// Authenticate using IBM i user profile credentials
isAuthenticated = SEC_AuthenticateUserProfile(
                    'JSMITH'
                  : 'MySecretPassword'
                  : sessionToken
                  : reasonCode
                  : userInfo
                  );

if (isAuthenticated);
  // User is authenticated. sessionToken contains the session UUID.
else;
  // Authentication failed. reasonCode indicates why (U = user not found, D = disabled).
endif;

return;
```

---

## **Parameters**

| Parameter            | Type                                  | Required | Description                                                                                                                                      |
| -------------------- | ------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `i_usrprf`           | LIKE(tpl_sdk4i_secusrt_ds.usrprf)     | Yes      | IBM i user profile name used for authentication.                                                                                                 |
| `i_password`         | CHAR(512)                             | Yes      | Password for the IBM i user profile. The value is trimmed before authentication.                                                                 |
| `o_token`            | LIKE(tpl_sdk4i_uuid)                  | Yes      | Output parameter that receives the generated session UUID when authentication succeeds.                                                          |
| `o_reason_code`      | LIKE(tpl_sdk4i_secusrt_ds.is_enabled) | Yes      | Output reason code when authentication fails. `'U'` indicates that the user profile was not found. `'D'` indicates that the account is disabled. |
| `i_log_user_info_ds` | LIKEDS(tpl_sdk4i_log_user_info_ds)    | Optional | Optional logging user context structure that is populated when authentication succeeds.                                                          |

---

## **Related Procedures**

| Procedure                  | Description                                                                                           |
| -------------------------- | ----------------------------------------------------------------------------------------------------- |
| `API_GetProfileHandle`     | Validates an IBM i user profile and password and returns a profile handle if authentication succeeds. |
| `API_ReleaseProfileHandle` | Releases a previously allocated IBM i user profile handle.                                            |
| `ERR_IsSQLError`           | Evaluates SQL diagnostics and returns *ON if an SQL error or warning condition exists.                |
| `LOG_LogMsg`               | Writes a detailed log entry containing message text, cause information, severity, and user context.   |
| `LOG_LogUse`               | Records high-level usage and execution metrics for auditing and diagnostics.                          |
| `SEC_CreateUUID`           | Generates a new UUID used as a security session token.                                                |