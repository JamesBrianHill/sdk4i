# Procedure: **VLD_IsValidTime**

## **Overview**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

The `VLD_IsValidTime` procedure validates whether a given time value falls within a specified minimum and maximum time range. If the time is null or outside the valid range, the procedure returns *OFF (false). If the time is valid, it returns *ON (true).

This procedure also integrates with the system logging framework to record abnormal terminations and usage information, ensuring traceability and ease of troubleshooting.

---

## **Example Usage**

```rpgle
// --------------------------------------------------
// Example: Validate a time value using VLD_IsValidTime.
// --------------------------------------------------
DCL-S isValid IND;
DCL-S inputTime TIME;
DCL-S minTime   TIME;
DCL-S maxTime   TIME;

// Initialize values
inputTime = %TIME('13:45:00');
minTime   = %TIME('08:00:00');
maxTime   = %TIME('17:00:00');

// Validate time
isValid = VLD_IsValidTime(
            inputTime:
            minTime:
            maxTime:
            *OMIT
          );

IF (isValid);
  // Proceed with normal logic
ELSE;
  // Handle invalid time
ENDIF;
```

---

## **Parameters**

| Parameter            | Type                                  | Required | Description                                                                                       |
| -------------------- | ------------------------------------- | -------- | ------------------------------------------------------------------------------------------------- |
| `i_time`             | `LIKE(tpl_sdk4i_vldrult_ds.max_time)` | Yes      | The time value to be validated. If null, the procedure immediately returns *OFF.                  |
| `i_min_time`         | `LIKE(tpl_sdk4i_vldrult_ds.min_time)` | Yes      | The minimum allowable time. The time must not be earlier than this value.                         |
| `i_max_time`         | `LIKE(tpl_sdk4i_vldrult_ds.max_time)` | Yes      | The maximum allowable time. The time must not be later than this value.                           |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)`  | Optional | Optional structure containing user-related logging information. Can be passed as `*OMIT` or null. |

---

## **Related Procedures**

| Procedure    | Description                                                                                             |
| ------------ | ------------------------------------------------------------------------------------------------------- |
| `LOG_LogMsg` | Logs an error or informational message including details about the procedure, cause, and event context. |
| `LOG_LogUse` | Logs usage information, including execution timestamps, success status, and abnormal end indicators.    |