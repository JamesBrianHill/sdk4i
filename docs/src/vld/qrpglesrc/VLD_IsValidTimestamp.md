# Procedure: **VLD_IsValidTimestamp**

## **Overview**

The `VLD_IsValidTimestamp` procedure validates whether a given timestamp value falls within a defined minimum and maximum range. If the timestamp is null or falls outside the valid range, the procedure returns *OFF (false). If the timestamp is valid, it returns *ON (true).

This procedure also integrates with the logging framework to record abnormal terminations and usage information. This ensures that timestamp validations can be audited and monitored effectively.

---

## **Example Usage**

```rpgle
// --------------------------------------------------
// Example: Validate a timestamp using VLD_IsValidTimestamp.
// --------------------------------------------------
DCL-S isValid IND;
DCL-S inputTs  TIMESTAMP;
DCL-S minTs    TIMESTAMP;
DCL-S maxTs    TIMESTAMP;

// Initialize timestamp values
inputTs = %TIMESTAMP('2025-10-09-13.45.00.000000');
minTs   = %TIMESTAMP('2025-01-01-00.00.00.000000');
maxTs   = %TIMESTAMP('2025-12-31-23.59.59.999999');

// Validate timestamp
isValid = VLD_IsValidTimestamp(
            inputTs:
            minTs:
            maxTs:
            *OMIT
          );

IF (isValid);
  // Proceed with normal logic
ELSE;
  // Handle invalid timestamp
ENDIF;
```

---

## **Parameters**

| Parameter            | Type                                 | Required | Description                                                                                       |
| -------------------- | ------------------------------------ | -------- | ------------------------------------------------------------------------------------------------- |
| `i_ts`               | `LIKE(tpl_sdk4i_vldrult_ds.max_ts)`  | Yes      | The timestamp value to validate. If null, the procedure immediately returns *OFF.                 |
| `i_min_ts`           | `LIKE(tpl_sdk4i_vldrult_ds.min_ts)`  | Yes      | The minimum allowable timestamp. The value must not be earlier than this.                         |
| `i_max_ts`           | `LIKE(tpl_sdk4i_vldrult_ds.max_ts)`  | Yes      | The maximum allowable timestamp. The value must not be later than this.                           |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)` | Optional | Optional structure containing user-related logging information. May be passed as `*OMIT` or null. |

---

## **Related Procedures**

| Procedure    | Description                                                                                             |
| ------------ | ------------------------------------------------------------------------------------------------------- |
| `LOG_LogMsg` | Logs an error or informational message including details about the procedure, cause, and event context. |
| `LOG_LogUse` | Logs usage information, including execution timestamps, success status, and abnormal end indicators.    |