# Procedure: **SEC_AuthenticateBypass**

## **Overview**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`SEC_AuthenticateBypass` creates a security session for a user without validating a password.
It is intended for trusted or internal authentication flows where identity has already been verified by the operating system, an external identity provider, or an administrative process.

The procedure locates a user record in the `SECUSRT` table using either a username or an IBM i user profile. If the account is found and disabled, the procedure automatically re-enables it. A new session token is generated and inserted into the `SECSEST` session table.

On success, the procedure returns *ON and outputs a session token. On failure, it returns *OFF and provides a reason code indicating why the bypass authentication failed. All actions and abnormal conditions are logged using the standard logging framework.

---

## **Example Usage**

```rpg
//---------------------------------------------------------------------
// Example: Bypass authentication and create a session token
//---------------------------------------------------------------------
ctl-opt dftactgrp(*no) actgrp(*new);

// Prototypes
dcl-pr SEC_AuthenticateBypass ind;
  i_username like(tpl_sdk4i_secusrt_ds.usr) options(*omit:*trim) const;
  i_usrprf   like(tpl_sdk4i_secusrt_ds.usrprf) options(*omit:*trim) const;
  o_token    like(tpl_sdk4i_uuid);
  o_reason_code like(tpl_sdk4i_secusrt_ds.is_enabled);
  i_log_user_info_ds likeds(tpl_sdk4i_log_user_info_ds) options(*nopass:*nullind:*omit);
end-pr;

dcl-s sessionToken like(tpl_sdk4i_uuid);
dcl-s reasonCode   like(tpl_sdk4i_secusrt_ds.is_enabled);
dcl-ds userInfo likeds(tpl_sdk4i_log_user_info_ds);

dcl-s isAuthenticated ind;

// Authenticate by username (no password required)
isAuthenticated = SEC_AuthenticateBypass(
                    'jsmith'
                  : *omit
                  : sessionToken
                  : reasonCode
                  : userInfo
                  );

if (isAuthenticated);
  // User is authenticated. sessionToken contains the session UUID.
else;
  // Authentication failed. reasonCode indicates why (U = user not found).
endif;

return;
```

---

## **Parameters**

| Parameter            | Type                                  | Required | Description                                                                                                    |
| -------------------- | ------------------------------------- | -------- | -------------------------------------------------------------------------------------------------------------- |
| `i_username`         | LIKE(tpl_sdk4i_secusrt_ds.usr)        | Optional | Username used to locate the security account. Either this or `i_usrprf` must be provided.                      |
| `i_usrprf`           | LIKE(tpl_sdk4i_secusrt_ds.usrprf)     | Optional | IBM i user profile used to locate the security account. Either this or `i_username` must be provided.          |
| `o_token`            | LIKE(tpl_sdk4i_uuid)                  | Yes      | Output parameter that receives the generated session UUID when authentication succeeds.                        |
| `o_reason_code`      | LIKE(tpl_sdk4i_secusrt_ds.is_enabled) | Yes      | Output reason code when authentication fails. `'U'` indicates that the username or user profile was not found. |
| `i_log_user_info_ds` | LIKEDS(tpl_sdk4i_log_user_info_ds)    | Optional | Optional logging user context structure that is populated when authentication succeeds.                        |

---

## **Related Procedures**

| Procedure        | Description                                                                                         |
| ---------------- | --------------------------------------------------------------------------------------------------- |
| `ERR_IsSQLError` | Evaluates SQL diagnostics and returns *ON if an SQL error or warning condition exists.              |
| `LOG_LogMsg`     | Writes a detailed log entry containing message text, cause information, severity, and user context. |
| `LOG_LogUse`     | Records high-level usage and execution metrics for auditing and diagnostics.                        |
| `SEC_CreateUUID` | Generates a new UUID used as a security session token.                                              |