# Procedure: **VLD_IsValidNumber**

## **Overview**

The `VLD_IsValidNumber` procedure validates whether a given numeric value is within an allowed minimum and maximum range.

The procedure first checks whether the provided numeric value is `NULL`. If so, the validation fails. If the value is not `NULL`, it is compared against the defined minimum and maximum bounds. If it falls outside the valid range, the procedure returns `*OFF` to indicate failure.

If the value is within the defined range, the procedure returns `*ON`. All procedure executions are logged, and abnormal endings are captured through the centralized logging mechanism.

---

## **Example Usage**

```rpgle
**free
ctl-opt dftactgrp(*no) actgrp(*new);

dcl-s isValid ind;
dcl-s value packed(15:5) inz(123.45);
dcl-s minValue packed(15:5) inz(0);
dcl-s maxValue packed(15:5) inz(500);
dcl-ds userInfo likeds(tpl_sdk4i_log_user_info_ds) inz(*likeds);

// Validate the number
isValid = VLD_IsValidNumber(
            value:       // i_num
            minValue:    // i_min_num
            maxValue:    // i_max_num
            userInfo    // i_log_user_info_ds
          );

if (isValid);
   dsply 'Number is within the valid range.';
else;
   dsply 'Number is invalid or out of range.';
endif;

*inlr = *on;
return;
```

---

## **Parameters**

| Parameter            | Type                                 | Required | Description                                                                                |
| -------------------- | ------------------------------------ | -------- | ------------------------------------------------------------------------------------------ |
| `i_num`              | `LIKE(tpl_sdk4i_vldrult_ds.max_num)` | Yes      | The numeric value to validate. If `NULL`, validation fails immediately.                    |
| `i_min_num`          | `LIKE(tpl_sdk4i_vldrult_ds.min_num)` | Yes      | The minimum allowed numeric value.                                                         |
| `i_max_num`          | `LIKE(tpl_sdk4i_vldrult_ds.max_num)` | Yes      | The maximum allowed numeric value.                                                         |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)` | Optional | A data structure containing user information for logging purposes. Can be omitted or null. |

---

## **Related Procedures**

| Procedure    | Description                                                                                |
| ------------ | ------------------------------------------------------------------------------------------ |
| `LOG_LogMsg` | Logs detailed error messages, including abnormal endings, to the centralized log facility. |
| `LOG_LogUse` | Records procedure usage statistics, including success status and execution details.        |