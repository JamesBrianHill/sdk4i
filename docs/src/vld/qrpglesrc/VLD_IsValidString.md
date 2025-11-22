# Procedure **VLD_IsValidString**

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

The `VLD_IsValidString` procedure validates a string value against a regular expression pattern using the SQL function `REGEXP_LIKE`.  
If the string matches the provided regular expression, the procedure returns `*ON` (true). If it does not match or an error occurs, the procedure returns `*OFF` (false).

The procedure includes detailed logging for:
- Missing or `NULL` parameters
- SQL execution errors
- Usage statistics and abnormal exits

This allows developers to integrate robust string validation logic with automatic error reporting.

## Example Usage
```rpgle
**FREE
// ----------------------------------------------------
// Example: Validating an email address format
// ----------------------------------------------------
DCL-PR VLD_IsValidString IND;
  i_str LIKE(tpl_sdk4i_sql_statement) OPTIONS(*NULLIND) CONST;
  i_rgx LIKE(tpl_sdk4i_vldrult_ds.rgx) OPTIONS(*NULLIND) CONST;
  i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds)
                     OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
END-PR;

DCL-S email LIKE(tpl_sdk4i_sql_statement) INZ('user@example.com');
DCL-S emailRegex LIKE(tpl_sdk4i_vldrult_ds.rgx) INZ('^[\\w._%+-]+@[\\w.-]+\\.[A-Za-z]{2,}$');
DCL-S isValid IND INZ(*OFF);
DCL-DS userInfo LIKEDS(tpl_sdk4i_log_user_info_ds) INZ(*LIKEDS);

userInfo.user_id = 42;
userInfo.username = 'ADMIN';

isValid = VLD_IsValidString(email : emailRegex : userInfo);

IF (isValid);
  // String is valid
  Dsply ('Email format is valid.');
ELSE;
  // String is invalid
  Dsply ('Email format is invalid.');
ENDIF;
```

## Parameters

| Parameter            | Type                                 | Required | Description                                                                                         |
| -------------------- | ------------------------------------ | -------- | --------------------------------------------------------------------------------------------------- |
| `i_str`              | `LIKE(tpl_sdk4i_sql_statement)`      | Yes      | The string value to validate. If `NULL`, the validation fails.                                      |
| `i_rgx`              | `LIKE(tpl_sdk4i_vldrult_ds.rgx)`     | Yes      | The regular expression pattern used for validation. If `NULL`, the validation fails.                |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)` | Optional | Optional structure containing user information for logging validation errors and activity tracking. |

## Related Procedures

| Procedure        | Description                                                                                          |
| ---------------- | ---------------------------------------------------------------------------------------------------- |
| [`LOG_LogMsg`](../../log/qrpglesrc/LOG_LogMsg.md)     | Logs error or informational messages with contextual details.                                        |
| [`LOG_LogUse`](../../log/qrpglesrc/LOG_LogUse.md)     | Logs usage statistics including success/failure and abnormal termination flags.                      |
| [`ERR_IsSQLError`](../../err/qrpglesrc/ERR_IsSQLError.md) | Checks whether an SQL operation resulted in an error and populates diagnostic information if it did. |