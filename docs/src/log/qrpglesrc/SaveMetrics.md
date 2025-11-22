# **Procedure: SaveMetrics**

## **Purpose:**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

Records performance and execution metrics for a specific program, module, or procedure invocation on IBM i.
This information is stored in the `LOGMETT` table and is used for analyzing execution success, runtime duration, user context, and abnormal termination indicators (abend flags).

---

## Parameters

| Parameter        | Type                                 | Description                                                                                                                                         |
| ---------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `i_psds_ds`      | LIKEDS(`tpl_sdk4i_psds_ds`)          | The Program Status Data Structure (PSDS) information captured at runtime, including job name, job number, library, program, and module identifiers. |
| `i_proc`         | LIKE(`tpl_sdk4i_logmett_ds.prc`)     | The procedure name for which metrics are being recorded.                                                                                            |
| `i_beg_ts`       | LIKE(`tpl_sdk4i_logmett_ds.beg_ts`)  | The timestamp marking the start of the operation or monitored activity.                                                                             |
| `i_successful`   | LIKE(`tpl_sdk4i_is_successful`)      | Optional flag indicating whether the operation completed successfully (`*ON` = success, `*OFF` = failure).                                          |
| `i_abend`        | LIKE(`tpl_sdk4i_is_abend`)           | Optional flag indicating whether an abnormal end (abend) occurred during execution.                                                                 |
| `i_user_info_ds` | LIKEDS(`tpl_sdk4i_log_user_info_ds`) | Optional structure containing user identity information such as user ID and username.                                                               |
| `i_end_ts`       | LIKE(`tpl_sdk4i_logmett_ds.end_ts`)  | Optional timestamp marking the end of the operation. If omitted, the current system timestamp (`*SYS`) is used.                                     |

---

## Description

`SaveMetrics` is responsible for persisting runtime measurement and outcome data for an individual procedure or process execution.
It is a core component of SDK4i’s metrics subsystem, which supports performance tracking, success/failure auditing, and operational observability across IBM i business applications.

When invoked, `SaveMetrics` consolidates job information from the PSDS, user context data, and timing details.
It then performs an SQL `INSERT` into the `LOGMETT` table, associating all relevant information with the execution instance defined by `i_proc` and `i_beg_ts`.

Optional parameters allow flexible usage—callers may choose to include success flags, abend indicators, user details, and explicit end timestamps depending on the logging requirements.

---

## Captured Information

The following fields are inserted into the `LOGMETT` table:

| Field        | Description                                                                                    |
| ------------ | ---------------------------------------------------------------------------------------------- |
| `SYS`        | System name where the job executed.                                                            |
| `LIB`        | Library name of the running program or module.                                                 |
| `PGM`        | Program name under execution.                                                                  |
| `MOD`        | Module name within the program.                                                                |
| `PRC`        | Procedure name being monitored.                                                                |
| `JOB_NUMBER` | Unique job number associated with the current process.                                         |
| `JOB_USER`   | The user profile under which the job is running.                                               |
| `JOB_NAME`   | Full job name (`number/user/name`) of the executing job.                                       |
| `BEG_TS`     | Timestamp representing the beginning of execution.                                             |
| `END_TS`     | Timestamp representing the end of execution (defaults to current system time if not provided). |
| `SUCCESS`    | Indicator showing whether the operation was successful.                                        |
| `ABEND`      | Indicator showing whether an abnormal termination occurred.                                    |
| `USER_ID`    | Numeric user identifier, if supplied.                                                          |
| `USERNAME`   | Textual username associated with the user ID.                                                  |
| `USRPRF_CUR` | Current user profile active during execution.                                                  |

Each field may be nullable to allow flexibility when optional information is not available.

---

## Processing Logic

1. **Extract PSDS Data:**
   Copies job name, job number, library, module, program, and user context from `i_psds_ds`.

2. **Handle Success and Abend Flags:**
   If provided, converts the Boolean-style indicators (`*ON`/`*OFF`) to SQL-compatible numeric/textual forms.
   If not provided, defaults are used (`SUCCESS = *ON`, `ABEND = *OFF`).

3. **Handle User Information:**
   If a `i_user_info_ds` structure is provided, extracts `USER_ID` and `USERNAME` fields for auditing purposes.

4. **Determine End Timestamp:**
   Uses the current system timestamp (`*SYS`) unless `i_end_ts` is explicitly provided.

5. **Insert into Database:**
   Executes an `INSERT INTO LOGMETT` statement to record all values, using null indicators as needed for omitted or optional parameters.

6. **Transaction Handling:**
   The SQL is executed with `WITH NC` (No Commit), allowing the caller to control commit or rollback behavior.

---

## Example Usage

This procedure is not exported from the LOG service program therefore is not accessible to external callers. The only way to trigger the SaveMetrics procedure is by configuring it in the LOGCFGT table: `logmett` = 'Y'.

---

## Database Dependencies

| Table           | Description                                                                      |
| --------------- | -------------------------------------------------------------------------------- |
| `LOGMETT`       | Stores process metrics and execution outcome data.                               |
| `LOG_USER_INFO` | (Optional) Provides reference data for user identifiers and names, if available. |

---

## Notes

* Designed for SDK4i internal use within performance and operational monitoring components.
* Fields and data structures are fully compatible with the SDK4i metrics schema.
* SQL execution errors are not internally trapped and should be handled by the caller.
* The procedure should be invoked near the conclusion of a monitored operation to ensure accurate duration and status capture.
* Uses null indicators for optional parameters to maintain flexibility across varied environments.

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