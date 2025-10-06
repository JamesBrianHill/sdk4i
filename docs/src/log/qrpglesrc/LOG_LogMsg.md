# Procedure: **LOG_LogMsg**

### Overview

The `LOG_LogMsg` procedure records diagnostic and operational messages to the logging subsystem.
It writes entries to the `LOGMSGT` database table and, based on configuration, may also log call stack, extended runtime, and web service context information.
The procedure automatically respects log-level configuration settings and executes optional event commands when specific message levels occur.

It is designed to provide a **centralized, configurable, and extensible** logging mechanism for all components of the SDK4i toolkit.

---

### Prototype

```rpg
DCL-PROC LOG_LogMsg EXPORT;
  DCL-PI LOG_LogMsg;
    i_psds_ds LIKEDS(tpl_sdk4i_psds_ds) CONST;
    i_proc LIKE(tpl_sdk4i_logmsgt_ds.prc) CONST;
    i_msg LIKE(tpl_sdk4i_logmsgt_ds.msg) CONST;
    i_cause_info_ds LIKEDS(tpl_sdk4i_log_cause_info_ds)
                    OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_event_info_ds LIKEDS(tpl_sdk4i_log_event_info_ds)
                    OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds)
                       OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_logwblt_ds LIKEDS(tpl_sdk4i_logwblt_ds)
                 OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_logwbrt_ds LIKEDS(tpl_sdk4i_logwbrt_ds)
                 OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;
END-PROC;
```

---

### Parameters

| Parameter                      | Type                          | Attributes               | Description                                                                           |
| ------------------------------ | ----------------------------- | ------------------------ | ------------------------------------------------------------------------------------- |
| **i_psds_ds**                  | `tpl_sdk4i_psds_ds`           | `CONST`                  | Program status data structure (PSDS). Provides job, user, program, and error context. |
| **i_proc**                     | `CHAR`                        | `CONST`                  | Procedure or routine name that generated the message.                                 |
| **i_msg**                      | `CHAR`                        | `CONST`                  | Message text to be logged.                                                            |
| **i_cause_info_ds** *(opt)*    | `tpl_sdk4i_log_cause_info_ds` | `*NULLIND, *OMIT, CONST` | Additional cause details such as SQLSTATE or statement identifiers.                   |
| **i_event_info_ds** *(opt)*    | `tpl_sdk4i_log_event_info_ds` | `*OMIT, CONST`           | Specifies event attributes including facility and log level.                          |
| **i_log_user_info_ds** *(opt)* | `tpl_sdk4i_log_user_info_ds`  | `*NULLIND, *OMIT, CONST` | User context information (user ID, username).                                         |
| **i_logwblt_ds** *(opt)*       | `tpl_sdk4i_logwblt_ds`        | `*NULLIND, *OMIT, CONST` | Local web service logging information.                                                |
| **i_logwbrt_ds** *(opt)*       | `tpl_sdk4i_logwbrt_ds`        | `*NULLIND, *OMIT, CONST` | Remote web service logging information.                                               |

---

### Functionality Summary

`LOG_LogMsg` performs the following major functions:

1. **Extracts Context**

   * Gathers system, library, program, module, job, and user information from `i_psds_ds`.
   * Merges optional context from cause, event, and user data structures.

2. **Determines Logging Configuration**

   * Queries the `LOGCFGT` configuration table using multiple precedence levels (1–6):

     1. User
     2. Procedure
     3. Module
     4. Program
     5. Library
     6. System
   * The configuration with the **highest priority (lowest number)** is applied.

3. **Respects Log Level**

   * If the message’s log level exceeds the configured level (e.g., DEBUG message when only ERROR level is allowed), the message is not logged.

4. **Inserts Log Message**

   * Inserts a new row into the `LOGMSGT` table and captures the generated log ID (`new_id`).
   * Fields include: program context, facility, log level, message text, SQL cause data, and exception data.

5. **Conditional Extended Logging**

   * If configured in `LOGCFGT`:

     * `logcsit = 'Y'`: saves call stack info.
     * `logextt = 'Y'`: saves extended system info.
     * `logwblt = 'Y'`: logs local web service info.
     * `logwbrt = 'Y'`: logs remote web service info.

6. **Triggers Event Commands**

   * If an event command is defined for the log level in `LOGCFGT` (`emgcmd`, `altcmd`, etc.), it executes that command.
   * Replaces any `&SDK4I_ID` token in the command string with the generated log message ID.

7. **Logs Usage**

   * Calls `LOG_LogUse` on exit to record execution metrics and outcome.

---

### Log Level Reference

| Constant         | Level | Meaning       |
| ---------------- | ----- | ------------- |
| `C_SDK4I_LL_EMG` | 1     | Emergency     |
| `C_SDK4I_LL_ALT` | 2     | Alert         |
| `C_SDK4I_LL_CRT` | 3     | Critical      |
| `C_SDK4I_LL_ERR` | 4     | Error         |
| `C_SDK4I_LL_WRN` | 5     | Warning       |
| `C_SDK4I_LL_INF` | 6     | Informational |
| `C_SDK4I_LL_DBG` | 7     | Debug         |

---

### Example Usage

#### Example 1: Log a simple error

```rpg
/COPY '/opt/sdk4i/src/qcpysrd/psds.rpgleinc'

DCL-PROC my_procedure;
  DCL-PI my_procedure;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-S widget_number PACKED(9:0);

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

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  IF (NOT IsWidgetAvailable(widget_number));
    log_msg = 'Widget ('+ %EDITC(widget_number: '3') +') not available.';
    LOG_LogMsg(psds_ds: log_proc: log_msg);
  ENDIF;
```

#### Example 2: Log an SQL-related warning with cause and event details

```rpg
/COPY '/opt/sdk4i/src/qcpysrc/logvark.rpgleinc'

// Execute some really important SQL statement that fails.
log_cause_info_ds.sstate = SQLSTATE;
log_event_info_ds.ll_id = C_SDK4I_LL_EMG; // Emergency
log_msg = 'Company payroll balance is negative!';

LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
```

---

### Error Handling and Logging Behavior

* If an **abnormal termination** occurs (`log_is_abend = *ON`), the procedure logs
  `"Procedure ended abnormally."` via `LOG_LogMsg` and still records usage metrics.
* All database inserts are performed via `INSERT INTO LOGMSGT` with `FINAL TABLE` semantics to retrieve the generated ID atomically.
* Event handler commands (if defined in configuration) execute using `IBM_ExecuteCommand` (which is `QCMDEXC`).

---

### Notes

* The `LOGCFGT` configuration controls the logging behavior for users, programs, modules, and systems.
* The procedure is idempotent for identical calls but will create distinct log entries for each invocation.
* For web service transactions, local and remote trace data are captured conditionally based on configuration flags.
* The command execution feature enables automation, such as alert emails or job notifications, when specific log levels occur.

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