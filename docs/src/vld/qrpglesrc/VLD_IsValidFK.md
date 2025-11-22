# Procedure: **VLD_IsValidFK**

## **Overview**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

The `VLD_IsValidFK` procedure validates whether a provided value exists in a target table and column, effectively performing a foreign key existence check.

The procedure dynamically builds and prepares a SQL statement using the provided foreign table, column, and optional host/library values. It then executes a `SELECT COUNT(*)` against the specified table and determines if at least one matching record exists.

The procedure supports multiple data types for the foreign key value, including string, numeric, date, time, and timestamp. If no value is provided, or if the value does not exist in the target table, the procedure returns `*OFF`. If the value exists, it returns `*ON`.

All SQL operations are logged, and any SQL errors are captured and recorded through centralized logging procedures.

---

## **Example Usage**

```rpgle
**free
ctl-opt dftactgrp(*no) actgrp(*new);

dcl-s isValid ind;
dcl-s fkValue char(10) inz('CUST001');
dcl-s fkTable varchar(128) inz('CUSTOMERS');
dcl-s fkColumn varchar(128) inz('CUSTOMER_ID');
dcl-s fkLib varchar(128) inz('MYLIB');
dcl-ds userInfo likeds(tpl_sdk4i_log_user_info_ds) inz(*likeds);

// Example 1: Validate a string-based foreign key
isValid = VLD_IsValidFK(
            fkTable:                  // i_ftbl
            fkColumn:                 // i_fcol
            fkValue:                  // i_str
            *omit:                    // i_num
            *omit:                    // i_date
            *omit:                    // i_time
            *omit:                    // i_ts
            *omit:                    // i_fhost
            fkLib:                    // i_flib
            userInfo                  // i_log_user_info_ds
          );

if (isValid);
   dsply 'Foreign key value exists in table.';
else;
   dsply 'Foreign key value is invalid.';
endif;

// Example 2: Numeric or date-based foreign key values can be validated
// by passing them in the appropriate parameter (i_num, i_date, etc.).

*inlr = *on;
return;
```

---

## **Parameters**

| Parameter            | Type                                  | Required | Description                                                                                |
| -------------------- | ------------------------------------- | -------- | ------------------------------------------------------------------------------------------ |
| `i_ftbl`             | `LIKE(tpl_sdk4i_vldrult_ds.ftbl)`     | Yes      | The name of the foreign table to be queried.                                               |
| `i_fcol`             | `LIKE(tpl_sdk4i_vldrult_ds.fcol)`     | Yes      | The column name within the foreign table used for validation.                              |
| `i_str`              | `LIKE(tpl_sdk4i_sql_statement)`       | Optional | A character/string value to be checked for existence in the foreign key table.             |
| `i_num`              | `LIKE(tpl_sdk4i_vldrult_ds.max_num)`  | Optional | A numeric value to be checked for existence in the foreign key table.                      |
| `i_date`             | `LIKE(tpl_sdk4i_vldrult_ds.max_date)` | Optional | A date value to be checked for existence in the foreign key table.                         |
| `i_time`             | `LIKE(tpl_sdk4i_vldrult_ds.max_time)` | Optional | A time value to be checked for existence in the foreign key table.                         |
| `i_ts`               | `LIKE(tpl_sdk4i_vldrult_ds.max_ts)`   | Optional | A timestamp value to be checked for existence in the foreign key table.                    |
| `i_fhost`            | `LIKE(tpl_sdk4i_vldrult_ds.fhost)`    | Optional | The relational database host name. Used when performing a three-part naming query.         |
| `i_flib`             | `LIKE(tpl_sdk4i_vldrult_ds.flib)`     | Optional | The library containing the foreign table.                                                  |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)`  | Optional | A data structure containing user information for logging purposes. Can be omitted or null. |

---

## **Related Procedures**

| Procedure        | Description                                                                                                |
| ---------------- | ---------------------------------------------------------------------------------------------------------- |
| `ERR_IsSQLError` | Checks if an SQL error occurred during execution and populates diagnostic information if applicable.       |
| `LOG_LogMsg`     | Logs detailed error messages, including SQL state and executed statement, to the centralized log facility. |
| `LOG_LogUse`     | Records procedure usage statistics, including success status and execution details.                        |