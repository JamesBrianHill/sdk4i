# Procedure: **VLD_GetMsg**

## Overview
The `VLD_GetMsg` procedure retrieves a localized validation message from the `VLDMSGT` table based on the provided message ID and optional language code.  
If no language code is provided, the procedure defaults to `'en'` (English).  
If any error occurs during SQL processing, the procedure logs the error details using the logging framework and returns a fallback error message.

This procedure is useful for internationalized applications that need to display error, warning, or informational messages in the user’s preferred language.

## Example Usage
```rpgle
**FREE
// ----------------------------------------------------
// Example: Retrieving a localized validation message
// ----------------------------------------------------
DCL-PR VLD_GetMsg LIKE(tpl_sdk4i_vldmsgt_ds.msg);
  i_id LIKE(tpl_sdk4i_vldmsgt_ds.id) CONST;
  i_lng_id LIKE(tpl_sdk4i_vldmsgt_ds.lng_id) OPTIONS(*NOPASS: *OMIT) CONST;
  i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds)
                     OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
END-PR;

DCL-S message LIKE(tpl_sdk4i_vldmsgt_ds.msg);
DCL-S messageId LIKE(tpl_sdk4i_vldmsgt_ds.id) INZ('VAL001');
DCL-S language LIKE(tpl_sdk4i_vldmsgt_ds.lng_id) INZ('es');
DCL-DS userInfo LIKEDS(tpl_sdk4i_log_user_info_ds) INZ(*LIKEDS);

userInfo.user_id = 12345;
userInfo.username = 'JDOE';

// Retrieve the Spanish message for VAL001
message = VLD_GetMsg(messageId : language : userInfo);

// If language is omitted, defaults to English
message = VLD_GetMsg(messageId : *OMIT : *OMIT);
```

## Parameters

| Parameter            | Type                                 | Required | Description                                                                            |
| -------------------- | ------------------------------------ | -------- | -------------------------------------------------------------------------------------- |
| `i_id`               | `LIKE(tpl_sdk4i_vldmsgt_ds.id)`      | Yes      | The unique message identifier used to look up the message text in the `VLDMSGT` table. |
| `i_lng_id`           | `LIKE(tpl_sdk4i_vldmsgt_ds.lng_id)`  | Optional | Optional language code (e.g., `'en'`, `'es'`). If omitted, defaults to `'en'`.         |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)` | Optional | User information structure used for logging SQL or processing errors.                  |

## Additional Notes

* The procedure uses embedded SQL with error handling at each step (PREPARE, DECLARE, OPEN, FETCH).
* Errors are logged using `LOG_LogMsg` with cause and event information.
* If the message cannot be retrieved, the procedure returns a default fallback message:

  ```
  An error occurred retrieving a message.
  ```
* The procedure also logs usage statistics with `LOG_LogUse` on exit.

## Related Procedures

| Procedure        | Description                                                         |
| ---------------- | ------------------------------------------------------------------- |
| `LOG_LogMsg`     | Logs structured error or informational messages.                    |
| `LOG_LogUse`     | Logs usage metrics including success/abend state.                   |
| `ERR_IsSQLError` | Checks for SQL error conditions and returns diagnostic information. |