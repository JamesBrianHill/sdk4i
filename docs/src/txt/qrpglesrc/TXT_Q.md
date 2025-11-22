# Procedure: **TXT_Q**

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

The `TXT_Q` procedure prepares and returns a properly quoted SQL string literal from an input string, optionally adding a prefix and/or suffix. It ensures that embedded single quotes are properly escaped by doubling them, making the resulting string safe for SQL usage.

This procedure also integrates with the SDK4i’s logging component to record execution details and abnormal termination events.

---

## Prototype

```rpg
DCL-PROC TXT_Q EXPORT;
  DCL-PI TXT_Q LIKE(tpl_sdk4i_sql_statement);
    i_str LIKE(tpl_sdk4i_sql_statement) OPTIONS(*TRIM) CONST;
    i_prefix LIKE(tpl_sdk4i_sql_statement) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_suffix LIKE(tpl_sdk4i_sql_statement) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) 
                       OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;
END-PROC;
```

---

## Parameters

| Name                         | Type                         | Attributes               | Description                                                                           |
| ---------------------------- | ---------------------------- | ------------------------ | ------------------------------------------------------------------------------------- |
| `i_str`                      | `tpl_sdk4i_sql_statement`    | `CONST, *TRIM`           | The main string to be quoted and SQL-escaped.                                         |
| `i_prefix` *(opt)*           | `tpl_sdk4i_sql_statement`    | `CONST, *TRIM, *OMIT`    | Optional prefix to insert before the quoted string. If omitted, no prefix is applied. |
| `i_suffix` *(opt)*           | `tpl_sdk4i_sql_statement`    | `CONST, *TRIM, *OMIT`    | Optional suffix to append after the quoted string. If omitted, no suffix is applied.  |
| `i_log_user_info_ds` *(opt)* | `tpl_sdk4i_log_user_info_ds` | `CONST, *NULLIND, *OMIT` | Optional user context for logging. If omitted, default logging context is used.       |

---

## Return Value

* **Type:** `tpl_sdk4i_sql_statement`
* **Description:**
  A string literal formatted for safe SQL use.

  * Enclosed in single quotes (`'... '`).
  * Optional prefix and suffix included.
  * Embedded single quotes in the source string are doubled (`O'Brien → 'O''Brien'`).

---

## Processing Logic

1. **Initialize Output String**
   Begins with an opening single quote.

2. **Prefix Handling (optional)**

   * If a prefix parameter is passed and not `*NULL`, append it immediately after the opening quote.

3. **Escape Input String**

   * Uses `%SCANRPL` to find all single quotes (`'`) in the input string (`i_str`) and replace them with doubled quotes (`''`).
   * Ensures the string is SQL-safe.
   * Reference: [IBM `%SCANRPL` function](https://www.ibm.com/docs/en/i/7.6.0?topic=functions-scanrpl-scan-replace-characters#bbscanrp)

4. **Suffix Handling (optional)**

   * If a suffix parameter is passed and not `*NULL`, append it before the closing quote.

5. **Finalize Output String**

   * Appends the closing single quote.
   * Returns the final result trimmed of trailing blanks.

---

## Logging and Error Handling

* The procedure is integrated with the `LOG_LogMsg` and `LOG_LogUse` routines from the application’s logging framework.
* On abnormal termination:

  * `log_is_abend` is set.
  * `log_is_successful` is marked `*OFF`.
  * A log message `"Procedure ended abnormally."` is recorded.
* Whether successful or failed, a usage log entry is recorded at exit.

---

## Example Usage

#### Example 1: Basic Quoting

```rpg
DCL-S result VARCHAR(256);

result = TXT_Q('O''Brien');  
// Returns:  'O''Brien'
```

#### Example 2: With Prefix and Suffix

```rpg
DCL-S result VARCHAR(256);

result = TXT_Q('123', 'ID=', ')');  
// Returns:  'ID=123)'
```

#### Example 3: Embedded Quotes

```rpg
DCL-S result VARCHAR(256);

result = TXT_Q('He said ''Hello''.');
// Returns:  'He said ''Hello''.'
```

---

## Notes

* **Safety:** Always use this procedure when embedding user input into SQL statements to avoid malformed SQL.
* **Performance:** `%SCANRPL` is efficient for string substitution but should be used with awareness of very large strings.
* **Optional Parameters:** Both `i_prefix` and `i_suffix` are optional and safe to omit.

---

## Related Procedures

| Procedure      | Description                                                                                                                                                   |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [**`LOG_LogMsg`**](../../log/qrpglesrc/LOG_LogMsg.md) | Writes error, warning, or informational messages to the logging subsystem, including details about the procedure, caller context, and diagnostic information. |
| [**`LOG_LogUse`**](../../log/qrpglesrc/LOG_LogUse.md) | Records usage statistics for the procedure on normal or abnormal termination (success flag, abend flag, timestamps).                                          |