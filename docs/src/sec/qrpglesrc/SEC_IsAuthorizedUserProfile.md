# Procedure: **SEC_IsAuthorizedUserProfile**

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`SEC_IsAuthorizedUserProfile` determines whether a specific IBM i user profile is authorized to perform a secured action.

The procedure resolves the internal user ID from the Security User table (`SECUSRT`) using the supplied user profile name and then validates authorization by attempting to update the Security User Authorization table (`SECUSAT`). If a matching authorization record exists, the procedure updates the `LAST_USED` date for the authorization and returns *ON.

If the user profile does not exist, is not authorized for the requested action, or a database error occurs, the procedure returns *OFF and logs detailed diagnostic and security audit information.

This procedure is intended for authorization checks that are based directly on IBM i user profiles rather than session tokens.

---

### Example Usage

```rpg
dcl-s usrprf    like(tpl_sdk4i_secusrt_ds.usrprf);
dcl-s action_id like(tpl_sdk4i_secactt_ds.id);
dcl-ds log_user_info_ds likeds(tpl_sdk4i_log_user_info_ds) inz;

usrprf    = 'JSMITH';
action_id = 'REPORT_RUN';

if SEC_IsAuthorizedUserProfile(usrprf : action_id : log_user_info_ds);
   dsply ('User profile is authorized for action: ' + action_id);
else;
   dsply ('User profile is NOT authorized for action: ' + action_id);
endif;
```

---

### Parameters

| Parameter            | Type                               | Required | Description                                                                             |
| -------------------- | ---------------------------------- | -------- | --------------------------------------------------------------------------------------- |
| `i_usrprf`           | LIKE(tpl_sdk4i_secusrt_ds.usrprf)  | Yes      | IBM i user profile name to validate for authorization.                                  |
| `i_action_id`        | LIKE(tpl_sdk4i_secactt_ds.id)      | Yes      | Action identifier representing the secured operation being requested.                   |
| `i_log_user_info_ds` | LIKEDS(tpl_sdk4i_log_user_info_ds) | Optional | Logging and auditing data structure used for security and authorization event tracking. |

---

### Related Procedures

| Procedure             | Description                                                                                  |
| --------------------- | -------------------------------------------------------------------------------------------- |
| `ERR_IsSQLError`      | Evaluates SQL diagnostics and determines whether an SQL error occurred.                      |
| `LOG_LogMsg`          | Writes diagnostic, warning, and error messages to the system logging framework.              |
| `LOG_LogUse`          | Records procedure execution statistics and success/failure state.                            |
| `SEC_IsAuthorized`    | Determines whether an authenticated session token is authorized to perform a secured action. |
| `SEC_IsAuthenticated` | Validates an authentication token and enforces session timeout rules.                        |