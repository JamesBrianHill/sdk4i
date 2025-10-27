# Procedure: **VLD_IsValid**

## **Overview**

`VLD_IsValid` is a general-purpose validation procedure that validates data values based on metadata-driven validation rules stored in a rules table (`VLDRULT`). This procedure supports validation of **strings**, **numbers**, **dates**, **times**, and **timestamps**, as well as **foreign key relationships**.

The procedure dynamically determines applicable validation rules for a specific table column, including regular expressions, length constraints, min/max ranges, and foreign key references. It also supports column nullability, retrieving the `IS_NULLABLE` attribute from system catalogs.

The procedure logs errors, warnings, and debugging information using the common logging framework. It returns a Boolean indicator (`*ON` for valid, `*OFF` for invalid).


✅ **Notes for Developers**

* If both `i_str` and a regular expression rule are provided, the string is validated with the generated regex pattern that includes min/max length constraints.
* If the column is nullable and the input value is `NULL`, the procedure automatically returns success without further validation.
* If no applicable rule is found in the `VLDRULT` table, an error is logged and the procedure returns failure.
* The procedure uses `QSYS2.SYSCOLUMNS` to check column nullability and `QSYS2.LIBRARY_LIST_INFO` when no library is provided.
* Logging is centralized through `LOG_LogMsg` and `LOG_LogUse`.

---

## **Example Usage**

```rpgle
// ---------------------------------------------------------------------
// Example: Validate a customer email address against column rules
// ---------------------------------------------------------------------
ctl-opt dftactgrp(*no) actgrp(*new);

dcl-pr VLD_IsValid ind;
  i_tbl varchar(128) const;
  i_col varchar(128) const;
  o_vldmsgt_id varchar(50);
  i_str varchar(256) const options(*nopass:*nullind:*omit);
  i_num packed(15:5) const options(*nopass:*nullind:*omit);
  i_date date const options(*nopass:*nullind:*omit);
  i_time time const options(*nopass:*nullind:*omit);
  i_ts timestamp const options(*nopass:*nullind:*omit);
  i_lib varchar(128) const options(*nopass:*nullind:*omit);
  i_log_user_info_ds likeds(tpl_sdk4i_log_user_info_ds) const options(*nopass:*nullind:*omit);
end-pr;

dcl-s isValid ind;
dcl-s validationMsgId varchar(50);
dcl-ds userInfo likeds(tpl_sdk4i_log_user_info_ds) inz;

// Validate email column in CUSTOMER table
isValid = VLD_IsValid(
  'CUSTOMER' :
  'EMAIL' :
  validationMsgId :
  'test@example.com' :
  *omit :
  *omit :
  *omit :
  *omit :
  'MYLIB' :
  userInfo
);

if (isValid);
  dsply ('Email address is valid');
else;
  dsply ('Invalid email address. MsgID=' + validationMsgId);
endif;
```

---

## **Parameters**

| Parameter            | Type                                  | Required | Description                                                                                     |
| -------------------- | ------------------------------------- | -------- | ----------------------------------------------------------------------------------------------- |
| `i_tbl`              | LIKE(tpl_sdk4i_vldrult_ds.tbl)        | Yes      | Table name associated with the column to be validated.                                          |
| `i_col`              | LIKE(tpl_sdk4i_vldrult_ds.col)        | Yes      | Column name to be validated.                                                                    |
| `o_vldmsgt_id`       | LIKE(tpl_sdk4i_vldrult_ds.vldmsgt_id) | Yes      | Output parameter containing the validation message ID associated with the rule or a default ID. |
| `i_str`              | LIKE(tpl_sdk4i_sql_statement)         | Optional | String value to validate against length and/or regular expression rules.                        |
| `i_num`              | LIKE(tpl_sdk4i_vldrult_ds.max_num)    | Optional | Numeric value to validate against min/max rules.                                                |
| `i_date`             | LIKE(tpl_sdk4i_vldrult_ds.max_date)   | Optional | Date value to validate against min/max rules.                                                   |
| `i_time`             | LIKE(tpl_sdk4i_vldrult_ds.max_time)   | Optional | Time value to validate against min/max rules.                                                   |
| `i_ts`               | LIKE(tpl_sdk4i_vldrult_ds.max_ts)     | Optional | Timestamp value to validate against min/max rules.                                              |
| `i_lib`              | LIKE(tpl_sdk4i_vldrult_ds.lib)        | Optional | Library/schema name. If omitted, the library list is used to locate the table and column.       |
| `i_log_user_info_ds` | LIKEDS(tpl_sdk4i_log_user_info_ds)    | Optional | Structure containing user information for logging and auditing.                                 |

---

## **Related Procedures**

| Procedure              | Description                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| `LOG_LogMsg`           | Logs informational, warning, or error messages with context, including cause and event information. |
| `LOG_LogUse`           | Records usage of the procedure including start/end time, success/failure status, and ABEND state.   |
| `ERR_IsSQLError`       | Evaluates whether an SQL operation encountered an error and populates diagnostic structures.        |
| `VLD_GetMsg`           | Retrieves an error message in the requested language based on an error code.                        |
| `VLD_IsValidDate`      | Validates a date value against minimum and maximum thresholds.                                      |
| `VLD_IsValidFK`        | Validates a foreign key relationship between the given column and the referenced table/column.      |
| `VLD_IsValidNumber`    | Validates a numeric value against minimum and maximum thresholds.                                   |
| `VLD_IsValidString`    | Validates a string against a provided regular expression pattern.                                   |
| `VLD_IsValidTime`      | Validates a time value against minimum and maximum thresholds.                                      |
| `VLD_IsValidTimestamp` | Validates a timestamp value against minimum and maximum thresholds.                                 |