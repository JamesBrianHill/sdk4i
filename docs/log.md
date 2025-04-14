# LOG module

## Available Procedures

### LOG_LogMsg
```rpgle
DCL-PR LOG_LogMsg EXTPROC(*DCLCASE);
  i_psds_ds LIKEDS(tpl_sdk4i_psds_ds) CONST;
  i_prc LIKE(tpl_sdk4i_logmsgt_ds.prc) CONST;
  i_msg LIKE(tpl_sdk4i_logmsgt_ds.msg) CONST;
  i_cause_info_ds LIKEDS(tpl_sdk4i_log_cause_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  i_event_info_ds LIKEDS(tpl_sdk4i_log_event_info_ds) OPTIONS(*NOPASS: *OMIT) CONST;
  i_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  i_logwblt_ds LIKEDS(tpl_sdk4i_logwblt_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  i_logwbrt_ds LIKEDS(tpl_sdk4i_logwbrt_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
END-PR LOG_LogMsg;
```
- `i_psds_ds` is required and is a Program Status Data Structure defined in the `qcpysrc/logk.rpgleinc` source file.
- `i_prc` is required and is the name of the calling procedure as returned from the [%PROC](https://www.ibm.com/docs/en/i/7.5.0?topic=functions-proc-return-name-current-procedure) built-in function. If you are calling LOG_LogMsg from a subroutine, you would hardcode the name of the subroutine in the call. If you are calling LOG_LogMsg from outside of a procedure or subroutine, this will default to the name of the program - though you could hardcode the string "main", blanks, or any other string that makes sense to you.
- `i_msg` is required and is the message to be logged.
- `i_cause_info_ds` is optional and is a tpl_sdk4i_log_cause_info_ds data structure which might contain information such as an SQLSTATE or an SQL statement.
- `i_event_info_ds` is optional and is a tpl_sdk4i_log_event_info_ds data structure which contains a "facility" code and a "severity" code. See `src/log/qddlsrc/logfact.table` and `src/log/qddlsrc/loglvlt.table` or RFC 5424.
- `i_user_info_ds` is optional and is a tpl_sdk4i_log_user_info_ds data structure which might contain a numeric user_id or alphanumeric username from some external system that you might want to log.
- `i_logwblt_ds` is optional and is a tpl_sdk4i_logwblt_ds data structure which will contain information about a local web service - meaning a web service served by the IBM i LPAR where the LOG service program resides. See `src/log/qddlsrc/logwblt.table` for more information.
- `i_logwbrt_ds` is optional and is a tpl_sdk4i_logwbrt_ds data structure which will contain information about a remote web service - meaning a web service NOT served by the IBM i LPAR where the LOG service program resides. See `src/log/qddlsrc/logwbrt.table` for more information.

#### LOG_LogMsg and LOG_LogUse Basic Example
Here is complete, compilable source code to demonstrate the LOG_LogMsg and LOG_LogUse procedures in action. Create a source member called TEST1 of type RPGLE, paste the following source code into it, compile, and run it.

`CALL TEST1 PARM(9)` should add a row to tables LOGUSET and LOGMETT but not LOGMSGT.
`CALL TEST1 PARM(-1)` should add a row to tables LOGMETT, LOGMSGT, and LOGUSET.

```rpgle
// We only use completely free-form.
**FREE

// We allow nulls and we need the SDK4I binding directory so we can use the LOG module.
CTL-OPT ALWNULL(*USRCTL);
CTL-OPT BNDDIR('SDK4I');
//--------------------------------------------------------------------------------------------------

// We bring in the SDK4i definition for the Program Status Data Structure (PSDS) and the constants,
// data structures, variables, and procedure definitions for the LOG module.
/COPY '/home/hillb/sdk4i/src/qcpysrc/psdsk.rpgleinc'
/COPY '/home/hillb/sdk4i/src/qcpysrc/logk.rpgleinc'

//--------------------------------------------------------------------------------------------------
// We define the program interface for our test program and allow one parameter.
//--------------------------------------------------------------------------------------------------
DCL-PI TEST1;
  i_value PACKED(15: 10);
END-PI TEST1;

//--------------------------------------------------------------------------------------------------
// This is our "mainline" logic. All we do is call the get_square_root procedure, turn on LR, and
// leave.
//--------------------------------------------------------------------------------------------------
get_square_root(i_value);
*INLR = *ON;

//--------------------------------------------------------------------------------------------------
///
// Get the square root of a number.
//
// Given a number, we use the built-in function %SQRT to return it's square root.
//
// @param REQUIRED. The value we want to find the square root of.
// @return The square root of the value given or -1 if an error is encountered.
///
//--------------------------------------------------------------------------------------------------
DCL-PROC get_square_root;
  DCL-PI get_square_root PACKED(15: 10);
    i_value PACKED(15: 10) CONST;
  END-PI;

  // Define a variable to hold our return value.
  DCL-S return_value PACKED(15: 10);

  // This copybook will bring in various log_xxx data structures and variables.
  // See the logvar2k.rpgleinc source file for details.
  /COPY '/home/hillb/sdk4i/src/qcpysrc/logvar2k.rpgleinc'

  // Wrap our process in a MONITOR block so we can fail gracefully if there are any errors.
  MONITOR;
    return_value = %SQRT(i_value);
  ON-EXCP 'RNX0101'; // The caller gave us a negative number which is not allowed by %SQRT.
    return_value = -1;
    log_is_successful = *OFF; // This value is stored in the logmett table.
    LOG_LogMsg(psds_ds: log_proc: 'Negative numbers not allowed.'); // Log our message.
  ON-ERROR;
    return_value = -1;
    log_is_successful = *OFF;
    // Do yourself a favor - when an error occurs, log information that will help you figure out
    // what went wrong...
    LOG_LogMsg(psds_ds: log_proc: 'Unknown error occurred for ' + %TRIM(%EDITC(i_value: '1')));
  ENDMON;

  // Return whatever value we found.
  RETURN return_value;

  // The ON-EXIT section is always executed, no matter what.
  ON-EXIT log_is_abend; // log_is_abend will have a '1' if something abnormal happened, else a '0'.
    IF (log_is_abend);
      return_value = -1;
      log_is_successful = *OFF;
      LOG_LogMsg(psds_ds: log_proc: 'Procedure ended abnormally.');
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend); // Log we were here.
END-PROC get_square_root;
```

Here are links to relevant IBM documentation:
[**FREE](https://www.ibm.com/docs/en/i/7.5?topic=statements-fully-free-form)
[CTL-OPT ALWNULL(*USRCTL)](https://www.ibm.com/docs/en/i/7.5.0?topic=keywords-alwnullno-inputonly-usrctl)
[CTL-OPT BNDDIR()](https://www.ibm.com/docs/en/i/7.5.0?topic=keywords-bnddirbinding-directory-name-binding-directory-name)
[/COPY](https://www.ibm.com/docs/en/i/7.5?topic=directives-copy-include#cdcopy)
[DCL-PI](https://www.ibm.com/docs/en/i/7.5.0?topic=statement-free-form-procedure-interface-definition)
[DCL-PROC](https://www.ibm.com/docs/en/i/7.5.0?topic=specifications-free-form-procedure-statement)
[DCL-S](https://www.ibm.com/docs/en/i/7.5.0?topic=statement-free-form-standalone-field-definition)
[MONITOR](https://www.ibm.com/docs/en/i/7.5.0?topic=codes-monitor-begin-monitor-group#zzmonit)
[ON-EXCP](https://www.ibm.com/docs/en/i/7.5.0?topic=codes-excp-exception#zzonexcp)
[ON-ERROR](https://www.ibm.com/docs/en/i/7.5.0?topic=codes-error-error#zzonerr)
[%SQRT](https://www.ibm.com/docs/en/i/7.5.0?topic=functions-sqrt-square-root-expression)
[%TRIM](https://www.ibm.com/docs/en/i/7.5.0?topic=functions-trim-trim-characters-edges)
[%EDITC](https://www.ibm.com/docs/en/i/7.5.0?topic=functions-editc-edit-value-using-editcode)
[RETURN](https://www.ibm.com/docs/en/i/7.5.0?topic=codes-return-return-caller)
[ON-EXIT](https://www.ibm.com/docs/en/i/7.5.0?topic=codes-exit-exit)

#### Further Examples
You can find more examples of LOG_LogMsg in various SDK4i source files. Look at the `SEC_Authenticate` procedure in `src/sec/qrpglesrc/sec.sqlrpgle` to see examples of using the `log_cause_info_ds` and `log_event_info_ds` data structures to log information about SQLSTATE, SQL statements, changing the default "facility" from 1 (User Level Messages) to 4 (Security/Authorization Messages). Procedure `SEC_CreateUUID` in that same source file also shows changing the "severity" from the default of "Error" to "Emergency" - the highest level.