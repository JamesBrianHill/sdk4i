# **Procedure: SaveUseInfo**

### **Purpose:**
Tracks and records execution frequency of individual procedures, programs, or modules on IBM i systems.
This procedure maintains cumulative usage statistics by configurable time intervals (year, month, week, day, hour, or minute) and writes or updates records in the `LOGUSET` table.

---

### Parameters

| Parameter   | Type                                 | Description                                                                                                         |
| ----------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| `i_psds_ds` | LIKEDS(`tpl_sdk4i_psds_ds`)          | Program Status Data Structure containing current job’s system, library, program, and module information.            |
| `i_proc`    | LIKE(`tpl_sdk4i_loguset_ds.prc`)     | Procedure name or identifier for the unit being tracked.                                                            |
| `i_loguset` | LIKE(`tpl_sdk4i_logcfgt_ds.loguset`) | Logging granularity indicator that determines the time dimension for aggregation (`Y`, `M`, `W`, `D`, `H`, or `I`). |

---

### Description

`SaveUseInfo` is part of the SDK4i operational analytics subsystem.
It captures **usage metrics** for monitored procedures and components, incrementing a counter that represents how often a specific procedure, program, or module is executed.

Each invocation of `SaveUseInfo` aggregates usage into a **time bucket** determined by the `i_loguset` parameter, which can represent:

| Code | Granularity | Example Record Key |
| ---- | ----------- | ------------------ |
| `Y`  | Yearly      | 2025               |
| `M`  | Monthly     | 2025-10            |
| `W`  | Weekly      | 2025-W40           |
| `D`  | Daily       | 2025-10-05         |
| `H`  | Hourly      | 2025-10-05-16      |
| `I`  | Per Minute  | 2025-10-05-16:42   |

This allows SDK4i to report and visualize usage trends at different resolutions, enabling administrators and developers to understand how often specific components are being executed.

The procedure uses an **SQL MERGE statement** to perform an UPSERT (update/insert) operation into the `LOGUSET` table:

* If a matching record already exists for the same **system, library, program, module, procedure**, and **time bucket**, the **counter (`CNT`) is incremented**.
* If no record exists, a new one is inserted with an initial count of `1`.

All timestamp values are derived from the IBM i system clock at runtime, ensuring consistent temporal grouping across all components using SDK4i logging.

---

### Processing Logic

1. **Extract Context**
   Retrieves system, library, program, and module identifiers from the provided `i_psds_ds` structure.

2. **Initialize Current Timestamp**
   Captures the current timestamp (`*SYS`) and decomposes it into year, month, week, day, hour, and minute components as needed.

3. **Determine Logging Granularity**
   Uses the `i_loguset` flag to determine how detailed the aggregation should be:

   * `Y` logs yearly counts only.
   * `M` includes month within the key.
   * `W` calculates the week of year using SQL `WEEK(:timestamp)`.
   * `D` includes day of month.
   * `H` includes the current hour.
   * `I` includes the current minute.

4. **Execute SQL MERGE (UPSERT)**
   Performs a single SQL `MERGE INTO LOGUSET` operation to either increment the existing counter or insert a new record.
   The `WITH NC` clause ensures that transaction control is deferred to the caller’s environment.

---

### Example Usage

This procedure is not exported from the LOG service program therefore is not accessible to external callers. The only way to trigger the SaveUseInfo procedure is by configuring it in the LOGCFGT table: `loguset` = 'Y', 'M', 'W', 'D', 'H', or 'I'.
---

### Database Dependencies

| Table     | Description                                                                                               |
| --------- | --------------------------------------------------------------------------------------------------------- |
| `LOGUSET` | Stores aggregated usage counts by system, library, program, module, procedure, and timestamp granularity. |

**Key Fields:**

* `SYS`, `LIB`, `PGM`, `MOD`, `PRC` – identify the executable unit.
* `YR`, `MNTH`, `WK`, `D`, `HR`, `MN` – represent time dimensions.
* `CNT` – cumulative execution counter.

---

### Notes

* `SaveUseInfo` supports both operational and analytical logging without performance impact; UPSERT operations are efficient even under high call volumes.
* The granularity (`i_loguset`) should be configured via SDK4i settings (`LOGCFGT.LOGUSET`) for consistency across the environment.
* The `WEEK()` function is database-dependent; it uses the SQL definition based on ISO week numbering.
* This procedure does **not** commit transactions — the caller is responsible for commit control.
* Null handling is managed automatically for unused time dimensions.

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