# **Procedure: SaveExtendedInfo**

### **Purpose:**
Captures extended job and environment information for the current IBM i job and stores it in the `LOGEXTT` table.
This information is linked to a specific log message record (`LOGMSGT_ID`) to provide detailed runtime and system context at the time of logging.

---

### Parameters

| Parameter | Type                            | Description                                                                                                                       |
| --------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `i_id`    | LIKE(`tpl_sdk4i_logmsgt_ds.id`) | The unique identifier of the log message record in the `LOGMSGT` table that the extended job information will be associated with. |

---

### Description

`SaveExtendedInfo` collects an extensive set of attributes from the current IBM i job using the **QSYS2.JOB_INFO** service and several environment-level special registers (via `SYSIBM.SYSDUMMY1`).
It then inserts this information into the `LOGEXTT` table, associating it with the provided `LOGMSGT_ID`.

The stored data allows for deep insight into the runtime conditions present when a message was logged — including job type, subsystem, queue information, message logging settings, CCSID details, and active SQL environment options.

This procedure is part of the **SDK4i logging framework** and is typically called automatically by higher-level logging functions such as `LOG_LogMsg` when diagnostic-level logging is enabled.

---

### Captured Information

`SaveExtendedInfo` inserts a rich collection of system attributes into the `LOGEXTT` table, including:

#### **Job Attributes**

* Job status, type, subsystem, and job date
* Job queue details (name, library, priority, status)
* Job description, accounting code, and submitter information
* ASP, routing, and temporary storage configuration
* Message queue configuration and message logging settings

#### **Environment & SQL Attributes**

* Current CCSID, sort sequence, language, and country ID
* Decimal, date, and time format specifications
* Time zone and logging output preferences
* Current debug mode, DECFLOAT rounding mode, SQL degree of parallelism, and XML parse options
* Current schema, SQL path, and user profiles (`CURRENT USER` and `SYSTEM USER`)
* Process and thread identifiers (`QSYS2.PROCESS_ID`, `QSYS2.THREAD_ID`)

All data is retrieved dynamically at runtime, ensuring the logged context reflects the exact environment when the log entry was written.

---

### Processing Logic

1. Performs a `SELECT` from `QSYS2.JOB_INFO` filtered for the current active job (`WHERE JOB_NAME = QSYS2.JOB_NAME`).
2. Enriches the data with current SQL environment values obtained from `SYSIBM.SYSDUMMY1`.
3. Executes a single `INSERT INTO LOGEXTT ... SELECT` statement to persist the combined dataset.
4. Associates all captured information with the given log message ID (`LOGMSGT_ID = i_id`).

This design minimizes database I/O while ensuring atomic insertion of environment data.

---

### Example Usage

This procedure is not exported from the LOG service program therefore is not accessible to external callers. The only way to trigger the SaveExtendedInfo procedure is by configuring it in the LOGCFGT table: `logextt` = 'Y'.

---

### Database Dependencies

| Table     | Description                                                                                 |
| --------- | ------------------------------------------------------------------------------------------- |
| `LOGEXTT` | Stores extended job, SQL environment, and system attributes linked to a log message record. |
| `LOGMSGT` | Primary log message table that references `LOGEXTT` through `LOGMSGT_ID`.                   |

---

### Notes

* This procedure is intended for internal use by the SDK4i logging subsystem.
* All data is collected from IBM i system views (`QSYS2.JOB_INFO`, `SYSIBM.SYSDUMMY1`) and special registers (`QSYS2.PROCESS_ID`, `QSYS2.THREAD_ID`).
* The caller must ensure the target `LOGMSGT_ID` exists prior to invocation.
* No data is returned to the caller; all output is written to the `LOGEXTT` table.

---

### **Related Procedures**

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