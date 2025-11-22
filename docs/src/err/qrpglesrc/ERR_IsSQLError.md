# Procedure: **ERR_IsSQLError**

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

The `ERR_IsSQLError` procedure analyzes the SQL diagnostics from the most recent SQL operation to determine whether an SQL error occurred. It retrieves detailed information from the SQL diagnostics area using `GET DIAGNOSTICS` and populates the provided diagnostics data structure with message, SQLSTATE, and context details.

The procedure returns an indicator value:

* `*ON` → an SQL error occurred
* `*OFF` → no error or an allowed (permitted) SQLSTATE occurred

Optional parameters allow specifying a list of SQLSTATE codes that are permitted (i.e., not treated as errors).

---

## Prototype

```rpg
DCL-PROC ERR_IsSQLError EXPORT;
  DCL-PI ERR_IsSQLError IND;
    o_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) OPTIONS(*EXACT);
    i_permit_sqlstates_count LIKE(tpl_sdk4i_err_sqlstate_count)
                             OPTIONS(*NOPASS: *OMIT) CONST;
    i_permit_sqlstates LIKE(tpl_sdk4i_err_sqlstate)
                       DIM(C_SDK4I_ERR_PERMIT_SQLSTATE_COUNT)
                       OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds)
                       OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;
END-PROC;
```

---

## Parameters

| Name                                 | Type                               | Attributes        | Description                                                                      |
| ------------------------------------ | ---------------------------------- | ----------------- | -------------------------------------------------------------------------------- |
| **o_diagnostics_ds**                 | `tpl_sdk4i_err_sql_diagnostics_ds` | `*EXACT`          | Output structure that receives diagnostic details from the SQL diagnostics area. |
| **i_permit_sqlstates_count** *(opt)* | `tpl_sdk4i_err_sqlstate_count`     | `CONST, *OMIT`    | Number of permitted SQLSTATEs passed in `i_permit_sqlstates`.                    |
| **i_permit_sqlstates** *(opt)*       | `tpl_sdk4i_err_sqlstate` array     | `CONST, *OMIT`    | Array of SQLSTATE codes that should not be treated as errors.                    |
| **i_log_user_info_ds** *(opt)*       | `tpl_sdk4i_log_user_info_ds`       | `*NULLIND, *OMIT` | Optional logging context data structure.                                         |

---

## Return Value

* **Type:** `IND` (Indicator variable)
* **Meaning:**

  * `*OFF` — No SQL error occurred, or the SQLSTATE is permitted.
  * `*ON` — An unexpected SQL error occurred.

---

## Processing Logic

1. **Retrieve SQL Diagnostics**

   * Calls `EXEC SQL GET DIAGNOSTICS CONDITION 1` to populate `o_diagnostics_ds` fields with SQL message, SQLSTATE, catalog, schema, table, and constraint details.
   * Calls a second `GET DIAGNOSTICS` to capture statement-level information such as `ROW_COUNT`, `DB2_NUMBER_ROWS`, and other counters.

2. **Evaluate SQLSTATE**

   * If `RETURNED_SQLSTATE = '00000'`, the SQL operation was successful — returns `*OFF`.
   * Otherwise, checks whether `RETURNED_SQLSTATE` matches any SQLSTATEs listed in `i_permit_sqlstates`.

     * If matched, the state is permitted → returns `*OFF`.
     * If not matched, the state is treated as an error → returns `*ON`.

3. **Construct Error Message**

   * Builds a detailed `err_msg` in the diagnostics data structure:

     * Includes `DB2_MESSAGE_ID` and `MESSAGE_TEXT`.
     * Appends parameter info (name and ordinal position) if available.
     * Adds constraint info (catalog/schema/table/owner) if present.

4. **Logging and Cleanup**

   * Integrates with the application’s logging system.
   * On abnormal termination (`log_is_abend = *ON`), logs “Procedure ended abnormally.”
   * Always records execution via `LOG_LogUse`.

---

## Example Usage

#### Example 1: Simple SQL Error Check

```rpg
DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds);

// ...

EXEC SQL DELETE FROM CUSTOMER WHERE CUSTNO = :custNo;
IF (ERR_IsSQLError(s_diagnostics_ds));
  DSPLY ('SQL error: ' + %TRIM(s_diagnostics_ds.err_msg));
ENDIF;
```

#### Example 2: Ignore “No Data” Condition (SQLSTATE 02000)

```rpg
DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds);
DCL-S permit_sqlstates_count INT(10) INZ(1);
DCL-S permit_sqlstates CHAR(5) DIM(1) INZ('02000');

// ...

EXEC SQL FETCH NEXT FROM CURSOR INTO :data;
IF (ERR_IsSQLError(s_diagnostics_ds: permit_sqlstates_count: permit_sqlstates)):
  // Handle unexpected SQL error
  DSPLY ('Unexpected SQLSTATE: ' + s_diagnostics_ds.returned_sqlstate);
ENDIF;
```

---

## Notes

* Use this procedure after **any embedded SQL operation** to safely check for errors and capture diagnostic info.
* The `o_diagnostics_ds` structure is fully populated for logging or display.
* Permitted SQLSTATEs (e.g., `'02000'` for “No Data”) let you handle expected conditions without flagging them as errors.
* Designed for use in production-quality RPG applications using IBM i DB2 SQL.

---

## Related Procedures

| Procedure         | Description                                                                                                                 |
| ----------------- | 
| [**`LOG_LogMsg`**](../../log/qrpglesrc/LOG_LogMsg.md)      | Writes a log message including cause data, event data, and context derived from the caller and runtime environment.         |
| [**`LOG_LogUse`**](../../log/qrpglesrc/LOG_LogUse.md)      | Logs usage metrics for the procedure, including start time, end time, success indicators, and abend status.                 |