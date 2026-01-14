# Procedure: **SEC_IsAuthenticated**

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`SEC_IsAuthenticated` validates an existing authentication token and determines whether the associated user session is still active.

The procedure checks the `SECSEST` session table for the supplied token, retrieves the associated user ID and username for logging and auditing purposes, and updates the session’s `LAST_USED` timestamp if the session has not exceeded the configured automatic timeout window.

If the token is valid and the session is still active, the procedure returns *ON. If the token is not found, has expired, or a database error occurs, the procedure returns *OFF and logs detailed diagnostic information.

This procedure is typically called by application entry points and service APIs to enforce session-based authentication.

---

### Example Usage

```rpg
dcl-s token like(tpl_sdk4i_uuid);
dcl-ds log_user_info_ds likeds(tpl_sdk4i_log_user_info_ds) inz;

token = '3F2504E0-4F89-11D3-9A0C-0305E82C3301';

if SEC_IsAuthenticated(token : log_user_info_ds);
   dsply ('User is authenticated: ' + log_user_info_ds.username);
else;
   dsply ('User is not authenticated or session expired.');
endif;
```

---

### Parameters

| Parameter            | Type                               | Required | Description                                                                                |
| -------------------- | ---------------------------------- | -------- | ------------------------------------------------------------------------------------------ |
| `i_token`            | LIKE(tpl_sdk4i_uuid)               | Yes      | Authentication token (UUID) identifying the user session.                                  |
| `i_log_user_info_ds` | LIKEDS(tpl_sdk4i_log_user_info_ds) | Yes      | Logging and auditing data structure populated with the authenticated user ID and username. |

---

### Related Procedures

| Procedure                     | Description                                                                     |
| ----------------------------- | ------------------------------------------------------------------------------- |
| `ERR_IsSQLError`              | Evaluates SQL diagnostics and determines whether an SQL error occurred.         |
| `LOG_LogMsg`                  | Writes diagnostic, warning, and error messages to the system logging framework. |
| `LOG_LogUse`                  | Records procedure execution statistics and success/failure state.               |
| `SEC_AuthenticateUserProfile` | Authenticates a user profile and creates a new session token.                   |
| `SEC_CreateUUID`              | Generates a new UUID token for session and security use.                        |