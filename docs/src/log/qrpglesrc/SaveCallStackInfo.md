# **Procedure: SaveCallStackInfo**

## **Purpose:**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

Captures the current job’s call stack information and stores it in the `LOGCSIT` table, associating the captured data with a specific log message record.
This provides detailed runtime context for debugging, tracing, and post-event analysis of application behavior at the time a log entry was created.

---

## Parameters

| Parameter | Type                            | Description                                                                                                                 |
| --------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `i_id`    | LIKE(`tpl_sdk4i_logmsgt_ds.id`) | The unique identifier of the log message record in the `LOGMSGT` table to which this call stack information will be linked. |

---

## Description

`SaveCallStackInfo` retrieves the complete call stack for the current job — including all active threads — using the IBM i service `QSYS2.STACK_INFO('*', 'ALL')`.
It then inserts each stack entry into the `LOGCSIT` table, tagging all rows with the supplied log message ID (`i_id`).
This allows the SDK4i logging framework to associate every log message with the exact call path that produced it.

Each record inserted into `LOGCSIT` includes:

* Thread ID and type
* Program, module, and procedure names
* Activation group names and numbers
* Source-level details for PASE and Java frames
* Instruction offsets for LIC-level calls

The captured data provides developers and support teams with a detailed snapshot of the program’s execution path, which is critical for troubleshooting and performance diagnostics.

---

## Processing Logic

1. Calls `QSYS2.STACK_INFO('*', 'ALL')` to retrieve active call stack entries.
2. Performs an `INSERT INTO LOGCSIT ... SELECT` to populate stack data linked to the given `LOGMSGT_ID`.
3. Returns control to the caller — the `LOG_LogMsg` procedure.

The procedure does not return a value and does not perform explicit error handling.
Any SQL errors are propagated to the caller.

---

## Example Usage

This procedure is not exported from the LOG service program therefore is not accessible to external callers. The only way to trigger the SaveCallStackInfo procedure is by configuring it in the LOGCFGT table: `logcsit` = 'Y'.

---

## Database Dependencies

| Table     | Description                                                                     |
| --------- | ------------------------------------------------------------------------------- |
| `LOGCSIT` | Stores detailed call stack entries for all threads, linked to a log message ID. |
| `LOGMSGT` | Stores primary log message records referenced by `LOGCSIT.LOGMSGT_ID`.          |

---

## Notes

* Intended for internal use by SDK4i logging procedures.
* Stack data is retrieved directly from IBM i system services and may include sensitive module or path details.
* The caller is responsible for ensuring commitment control and proper transaction handling.

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