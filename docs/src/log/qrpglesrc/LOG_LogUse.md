# **Procedure: LOG_LogUse**

## **Purpose**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

The `LOG_LogUse` procedure records metrics and usage information for a program or procedure execution within the IBM i SDK logging framework.
It determines — based on configuration settings in the **LOGCFGT** table — whether execution metrics and/or usage events should be logged.
If logging is enabled, it writes records to the appropriate log tables by invoking **`SaveMetrics`** and/or **`SaveUseInfo`**.

---

## **Prototype Definition**

```rpg
DCL-PROC LOG_LogUse EXPORT;
  DCL-PI LOG_LogUse;
    i_psds_ds             LIKEDS(tpl_sdk4i_psds_ds) CONST;
    i_proc                LIKE(tpl_sdk4i_logmett_ds.prc) CONST;
    i_beg_ts              LIKE(tpl_sdk4i_logmett_ds.beg_ts) CONST;
    i_successful          LIKE(tpl_sdk4i_is_successful) CONST OPTIONS(*NOPASS: *OMIT);
    i_abend               LIKE(tpl_sdk4i_is_abend) CONST OPTIONS(*NOPASS: *OMIT);
    i_user_info_ds        LIKEDS(tpl_sdk4i_log_user_info_ds) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
    i_end_ts              LIKE(tpl_sdk4i_logmett_ds.end_ts) CONST OPTIONS(*NOPASS: *OMIT);
  END-PI;
END-PROC LOG_LogUse;
```

---

## **Parameters**

| Parameter            | Type / Definition                    | Required | Description                                                                                                                                                                                               |
| -------------------- | ------------------------------------ | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`i_psds_ds`**      | `LIKEDS(tpl_sdk4i_psds_ds)`          | **Yes**  | The program status data structure (PSDS) containing job, module, and program-level runtime information. Used to extract context such as job name, user profile, library, system, and program identifiers. |
| **`i_proc`**         | `LIKE(tpl_sdk4i_logmett_ds.prc)`     | **Yes**  | The name of the procedure or routine whose execution is being logged.                                                                                                                                     |
| **`i_beg_ts`**       | `LIKE(tpl_sdk4i_logmett_ds.beg_ts)`  | **Yes**  | Timestamp indicating when execution began. Typically captured at the start of a procedure or program.                                                                                                     |
| **`i_successful`**   | `LIKE(tpl_sdk4i_is_successful)`      | Optional | Indicates whether the operation completed successfully (`*ON`) or failed (`*OFF`).                                                                                                                        |
| **`i_abend`**        | `LIKE(tpl_sdk4i_is_abend)`           | Optional | Indicates whether the procedure ended abnormally.                                                                                                                                                         |
| **`i_user_info_ds`** | `LIKEDS(tpl_sdk4i_log_user_info_ds)` | Optional | Contains user-related data such as user ID and username. If omitted or null, defaults are used from the current session.                                                                                  |
| **`i_end_ts`**       | `LIKE(tpl_sdk4i_logmett_ds.end_ts)`  | Optional | Timestamp indicating when execution ended. If omitted, the system timestamp (`*SYS`) is used.                                                                                                             |

---

## **Description**

The `LOG_LogUse` procedure performs configurable logging of both **metrics** (execution times, success/failure state) and **usage** (when and by whom a procedure is called).

Logging behavior is controlled by configuration settings in the **LOGCFGT** table.
The configuration hierarchy determines logging precedence as follows (lowest to highest priority):

1. System (`SYS`)
2. Library (`LIB`)
3. Program (`PGM`)
4. Module (`MOD`)
5. Procedure (`PRC`)
6. User (`USR`)

The first non-null configuration found at the highest priority level determines the logging settings applied.
If neither metrics nor usage logging is enabled, the procedure exits immediately without performing any database inserts.

---

## **Processing Steps**

1. **Extract runtime context**

   * Retrieves job name, job number, user profile, program, module, library, and system information from `i_psds_ds`.

2. **Determine configuration settings**

   * Queries **LOGCFGT** to determine whether metric logging (`LOGMETT`) and/or usage logging (`LOGUSET`) is enabled for the current procedure or user.

3. **Exit early if logging is disabled**

   * If both `LOGMETT = 'N'` and `LOGUSET = 'N'`, the procedure returns immediately.

4. **Log Metrics (if enabled)**

   * If metrics logging is configured (`LOGMETT = 'Y'`), the procedure:

     * Validates and applies nullable indicators for parameters such as success, abend, user info, and end timestamp.
     * Calls **`SaveMetrics`** to record execution timing, success status, and user data in the metrics table.

5. **Log Usage (if enabled)**

   * If usage logging is configured (`LOGUSET` ≠ `'N'`), the procedure:

     * Calls **`SaveUseInfo`** to log user access details (procedure name, time of use, user ID, etc.).

6. **Return control to caller**

   * No value is returned. Logging is handled via SQL inserts into the SDK’s database logging tables.

---

## **Error Handling**

* The procedure does not raise exceptions directly.
* SQL operations use `WITH NC` to avoid commitment control issues.
* If an invalid or missing parameter is detected, null indicators ensure database integrity.

---

## **Example Usage**

```rpg
DCL-PROC my_procedure;
  DCL-PI my_procedure;
  END-PI;

  /COPY '/opt/sdk4i/src/qcpysrc/logvark.rpgleinc'

  // The above copybook will define these log-related data structures and variables and initialize them.
  // DCL-DS log_cause_info_ds LIKEDS(tpl_sdk4i_log_cause_info_ds) INZ(*LIKEDS);
  // DCL-DS log_event_info_ds LIKEDS(tpl_sdk4i_log_event_info_ds) INZ(*LIKEDS);
  // DCL-DS log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) INZ(*LIKEDS);
  // DCL-S log_is_abend LIKE(tpl_sdk4i_is_abend) INZ(*OFF); // Assume the procedure will end normally.
  // DCL-S log_is_successful LIKE(tpl_sdk4i_is_successful) INZ(*ON); // Assume proc will be successful.
  // DCL-S log_beg_ts LIKE(tpl_sdk4i_logmett_ds.beg_ts) INZ(*SYS);
  // DCL-S log_msg LIKE(tpl_sdk4i_logmsgt_ds.msg) INZ('');
  // DCL-S log_proc LIKE(tpl_sdk4i_logmsgt_ds.prc) INZ('');
  //
  // %NULLIND(log_cause_info_ds.sstate) = *ON;
  // %NULLIND(log_cause_info_ds.sstmt) = *ON;
  // %NULLIND(log_user_info_ds.user_id) = *ON;
  // %NULLIND(log_user_info_ds.username) = *ON;
  // log_proc = %PROC();

  // ... procedure logic ...

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
```

---

## **Notes**

* The **LOGCFGT** table must be properly configured for this procedure to perform any logging.
* When both metrics and usage logging are disabled, this procedure executes with negligible performance impact.
* Designed for integration with the SDK4i logging subsystem, which unifies message, event, metric, and usage tracking.

---

## **Related Procedures**

| Procedure                      | Description                                                                         |
| ------------------------------ | ----------------------------------------------------------------------------------- |
| [**`LOG_LogMsg`**](./LOG_LogMsg.md)               | Logs messages, warnings, and error events to the LOGMSGT table.                     |
| [**`LOG_LogUse`**](./LOG_LogUse.md)               | Logs usage and metrics.                                                             |
| [**`SaveCallStackInfo`**](./SaveCallStackInfo.md)        | Inserts callstack information into the LOGCSIT table.                               |
| [**`SaveExtendedInfo`**](./SaveExtendedInfo.md)         | Inserts extended application information into the LOGEXTT table.                    |
| [**`SaveLocalWebServiceInfo`**](./SaveLocalWebServiceInfo.md)  | Inserts local web service information into the LOGWBLT table.                       |
| [**`SaveMetrics`**](./SaveMetrics.md)              | Inserts execution metrics (duration, success/failure, etc.) into the LOGMETT table. |
| [**`SaveRemoteWebServiceInfo`**](./SaveRemoteWebServiceInfo.md) | Inserts remote web service information into the LOGWBRT table.                      |
| [**`SaveUseInfo`**](./SaveUseInfo.md)              | Inserts usage records into the LOGUSET table.                                       |