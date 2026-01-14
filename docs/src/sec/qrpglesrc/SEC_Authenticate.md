# Procedure: **SEC_Authenticate**

## **Overview**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`SEC_Authenticate` validates a user's credentials against the `SECUSRT` security table and, if authentication is successful, creates a new security session record in the `SECSEST` table.

The procedure verifies the supplied username and password (using a SHA-512 hash comparison), checks whether the user account is enabled, generates a unique session token, and inserts a new session record containing user identity, localization, and time zone information.

On success, the procedure returns *ON and outputs a generated session token. On failure, it returns *OFF and provides a reason code indicating why authentication failed. All failures and abnormal conditions are logged using the standard logging framework.

---

## **Example Usage**

```rpg
//---------------------------------------------------------------------
// Example: Authenticate a user and obtain a session token
//---------------------------------------------------------------------
ctl-opt dftactgrp(*no) actgrp(*new);

// Prototypes
dcl-pr SEC_Authenticate ind;
  i_username like(tpl_sdk4i_secusrt_ds.usr) options(*trim) const;
  i_password like(tpl_sdk4i_secusrt_ds.usr) options(*trim) const;
  o_token    like(tpl_sdk4i_uuid);
  o_reason_code like(tpl_sdk4i_secusrt_ds.is_enabled);
  i_log_user_info_ds likeds(tpl_sdk4i_log_user_info_ds) options(*nopass:*nullind:*omit);
end-pr;

dcl-s sessionToken like(tpl_sdk4i_uuid);
dcl-s reasonCode   like(tpl_sdk4i_secusrt_ds.is_enabled);
dcl-ds userInfo likeds(tpl_sdk4i_log_user_info_ds);

dcl-s isAuthenticated ind;

isAuthenticated = SEC_Authenticate(
                    'jsmith'
                  : 'MySecretPassword'
                  : sessionToken
                  : reasonCode
                  : userInfo
                  );

if (isAuthenticated);
  // User is authenticated. sessionToken contains the session UUID.
else;
  // Authentication failed. reasonCode indicates why (U = invalid, D = disabled).
endif;

return;
```

---

## **Parameters**

| Parameter            | Type                                  | Required | Description                                                                                                            |
| -------------------- | ------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------- |
| `i_username`         | LIKE(tpl_sdk4i_secusrt_ds.usr)        | Yes      | Username to authenticate. Trimmed before use.                                                                          |
| `i_password`         | LIKE(tpl_sdk4i_secusrt_ds.usr)        | Yes      | Password to authenticate. The password is hashed and compared to the stored value.                                     |
| `o_token`            | LIKE(tpl_sdk4i_uuid)                  | Yes      | Output parameter that receives the generated session UUID when authentication succeeds.                                |
| `o_reason_code`      | LIKE(tpl_sdk4i_secusrt_ds.is_enabled) | Yes      | Output reason code when authentication fails. `'U'` indicates invalid credentials, `'D'` indicates a disabled account. |
| `i_log_user_info_ds` | LIKEDS(tpl_sdk4i_log_user_info_ds)    | Optional | Optional logging user context structure that is populated when authentication succeeds.                                |

---

## **Related Procedures**

| Procedure        | Description                                                                                         |
| ---------------- | --------------------------------------------------------------------------------------------------- |
| `ERR_IsSQLError` | Evaluates SQL diagnostics and returns *ON if an SQL error or warning condition exists.              |
| `LOG_LogMsg`     | Writes a detailed log entry containing message text, cause information, severity, and user context. |
| `LOG_LogUse`     | Records high-level usage and execution metrics for auditing and diagnostics.                        |
| `SEC_CreateUUID` | Generates a new UUID used as a security session token.                                              |