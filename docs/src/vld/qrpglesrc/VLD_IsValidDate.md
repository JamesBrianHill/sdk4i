# Procedure: **VLD_IsValidDate**

## **Overview**

The `VLD_IsValidDate` procedure validates whether a given date value falls within a specified minimum and maximum date range.

If the input date value is null, the procedure immediately returns `*OFF`. If the date is outside the defined range, it also returns `*OFF`. When the value is valid and within the range, the procedure returns `*ON`.

The procedure includes error logging for abnormal endings and records usage statistics, making it suitable for use in applications where input date validation and auditability are required.

---

## **Example Usage**

```rpgle
**free
ctl-opt dftactgrp(*no) actgrp(*new);

dcl-s isValid ind;
dcl-s minDate date inz(d'2000-01-01');
dcl-s maxDate date inz(d'2099-12-31');
dcl-ds userInfo likeds(tpl_sdk4i_log_user_info_ds) inz(*likeds);

// Example: Validate user-supplied date
isValid = VLD_IsValidDate(
            %date('2025-10-09'):    // i_date - the date to validate
            minDate:               // i_min_date - minimum allowed date
            maxDate:               // i_max_date - maximum allowed date
            userInfo               // i_log_user_info_ds - user info for logging (optional)
          );

if (isValid);
   dsply 'Date is valid.';
else;
   dsply 'Date is invalid.';
endif;

*inlr = *on;
return;
```

---

## **Parameters**

| Parameter            | Type                                  | Required | Description                                                                                |
| -------------------- | ------------------------------------- | -------- | ------------------------------------------------------------------------------------------ |
| `i_date`             | `LIKE(tpl_sdk4i_vldrult_ds.max_date)` | Yes      | The input date value to be validated. If null, the procedure returns `*OFF`.               |
| `i_min_date`         | `LIKE(tpl_sdk4i_vldrult_ds.min_date)` | Yes      | The minimum allowed date value. If `i_date` is earlier than this date, validation fails.   |
| `i_max_date`         | `LIKE(tpl_sdk4i_vldrult_ds.max_date)` | Yes      | The maximum allowed date value. If `i_date` is later than this date, validation fails.     |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)`  | Optional | A data structure containing user information for logging purposes. Can be omitted or null. |

---

## **Related Procedures**

| Procedure    | Description                                                                                           |
| ------------ | ----------------------------------------------------------------------------------------------------- |
| `LOG_LogMsg` | Logs messages to the centralized logging facility, including abnormal termination details.            |
| `LOG_LogUse` | Records procedure usage statistics such as execution time, success/abend flags, and user information. |