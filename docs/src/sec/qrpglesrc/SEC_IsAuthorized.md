# Procedure: **SEC_IsAuthorized**

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`SEC_IsAuthorized` determines whether an authenticated user is authorized to perform a specific secured action.

The procedure uses the supplied authentication token to resolve the associated user ID from the active session table (`SECSEST`). It then validates authorization by attempting to update the user/action authorization table (`SECUSAT`). If a matching authorization record exists, the procedure updates the `LAST_USED` date for the authorization and returns *ON.

If the token is invalid, the user is not authorized for the requested action, or a database error occurs, the procedure returns *OFF and logs detailed diagnostic and security audit information.

This procedure is intended to be called after successful authentication and before executing any secured business operation.

---

### Example Usage

```rpg
dcl-s token like(tpl_sdk4i_uuid);
dcl-s action_id like(tpl_sdk4i_secactt_ds.id);
dcl-ds log_user_info_ds likeds(tpl_sdk4i_log_user_info_ds) inz;

token     = '3F2504E0-4F89-11D3-9A0C-0305E82C3301';
action_id = 'ORDER_CREATE';

if SEC_IsAuthorized(token : action_id : log_user_info_ds);
   dsply ('User is authorized to perform action: ' + action_id);
else;
   dsply ('User is not authorized to perform action: ' + action_id);
endif;
```

---

### Parameters

| Parameter            | Type                               | Required | Description                                                                             |
| -------------------- | ---------------------------------- | -------- | --------------------------------------------------------------------------------------- |
| `i_token`            | LIKE(tpl_sdk4i_uuid)               | Yes      | Authentication token (UUID) identifying the active user session.                        |
| `i_action_id`        | LIKE(tpl_sdk4i_secactt_ds.id)      | Yes      | Action identifier representing the secured operation being requested.                   |
| `i_log_user_info_ds` | LIKEDS(tpl_sdk4i_log_user_info_ds) | Optional | Logging and auditing data structure used for security and authorization event tracking. |

---

### Related Procedures

| Procedure                     | Description                                                                     |
| ----------------------------- | ------------------------------------------------------------------------------- |
| `ERR_IsSQLError`              | Evaluates SQL diagnostics and determines whether an SQL error occurred.         |
| `LOG_LogMsg`                  | Writes diagnostic, warning, and error messages to the system logging framework. |
| `LOG_LogUse`                  | Records procedure execution statistics and success/failure state.               |
| `SEC_AuthenticateUserProfile` | Authenticates a user profile and creates a new session token.                   |
| `SEC_IsAuthenticated`         | Validates an authentication token and enforces session timeout rules.           |