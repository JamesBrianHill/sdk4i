**FREE
// -------------------------------------------------------------------------------------------------
//   Because of ON DELETE clauses associated with foreign key definitions in LOGCSIT, LOGEXTT,
// LOGWBLT, and LOGWBRT we will not need to purge those tables directly. Instead, the appropriate
// rows will be deleted from those tables as we delete rows from LOGMSGT.
//
// @author James Brian Hill
// @copyright Copyright (c) 2015 - 2025 by James Brian Hill
// @license GNU General Public License version 3
// @link https://www.gnu.org/licenses/gpl-3.0.html
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
//   This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses/gpl-3.0.html.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Control Specifications.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/ctloptpgmk.rpgleinc'
CTL-OPT MAIN(LOGPURP);
CTL-OPT TEXT('SDK4i - LOG - Purge log data');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// ERRK - ERR constants, data structures, variables, and procedure definitions.
// LOGK - LOG constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/errk.rpgleinc'
/COPY '../../qcpysrc/logk.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'

// -------------------------------------------------------------------------------------------------
// Pull in column definitions.
// -------------------------------------------------------------------------------------------------
DCL-DS tpl_sdk4i_logpurt_ds EXTNAME('LOGPURT') INZ(*EXTDFT) QUALIFIED TEMPLATE CCSID(*EXACT) END-DS;

// -------------------------------------------------------------------------------------------------
// Define global constants, template data structures, and template variables.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Set SQL options before any executable code but after all global Definition Specifications.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/sqloptk.rpgleinc'

// -------------------------------------------------------------------------------------------------
///
//   Main logic.
//
//   Program execution begins here.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC LOGPURP;
  DCL-PI LOGPURP;
  END-PI;

  DCL-S lvl0 LIKE(tpl_sdk4i_logpurt_ds.purge_0);
  DCL-S lvl1 LIKE(tpl_sdk4i_logpurt_ds.purge_1);
  DCL-S lvl2 LIKE(tpl_sdk4i_logpurt_ds.purge_2);
  DCL-S lvl3 LIKE(tpl_sdk4i_logpurt_ds.purge_3);
  DCL-S lvl4 LIKE(tpl_sdk4i_logpurt_ds.purge_4);
  DCL-S lvl5 LIKE(tpl_sdk4i_logpurt_ds.purge_5);
  DCL-S lvl6 LIKE(tpl_sdk4i_logpurt_ds.purge_6);
  DCL-S lvl7 LIKE(tpl_sdk4i_logpurt_ds.purge_7);
  DCL-S met_days LIKE(tpl_sdk4i_logpurt_ds.purge_met);
  DCL-S use_days LIKE(tpl_sdk4i_logpurt_ds.purge_use);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  IF (GetConfiguredDays(lvl0: lvl1: lvl2: lvl3: lvl4: lvl5: lvl6: lvl7: met_days: use_days));
    PurgeLOGMETT(met_days);
    PurgeLOGMSGT(lvl0: lvl1: lvl2: lvl3: lvl4: lvl5: lvl6: lvl7);
    PurgeLOGUSET(use_days);
  ENDIF;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC LOGPURP;

// -------------------------------------------------------------------------------------------------
///
//   Get purge configuration.
//
//   Get the configured number of days to retain log data from the LOGPURT table.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC GetConfiguredDays;
  DCL-PI GetConfiguredDays IND;
    o_lvl0 LIKE(tpl_sdk4i_logpurt_ds.purge_0);
    o_lvl1 LIKE(tpl_sdk4i_logpurt_ds.purge_1);
    o_lvl2 LIKE(tpl_sdk4i_logpurt_ds.purge_2);
    o_lvl3 LIKE(tpl_sdk4i_logpurt_ds.purge_3);
    o_lvl4 LIKE(tpl_sdk4i_logpurt_ds.purge_4);
    o_lvl5 LIKE(tpl_sdk4i_logpurt_ds.purge_5);
    o_lvl6 LIKE(tpl_sdk4i_logpurt_ds.purge_6);
    o_lvl7 LIKE(tpl_sdk4i_logpurt_ds.purge_7);
    o_met LIKE(tpl_sdk4i_logpurt_ds.purge_met);
    o_use LIKE(tpl_sdk4i_logpurt_ds.purge_use);
  END-PI;

  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  EXEC SQL
    SELECT purge_0, purge_1, purge_2, purge_3, purge_4, purge_5, purge_6, purge_7, purge_met, purge_use
    INTO :o_lvl0, :o_lvl1, :o_lvl2, :o_lvl3, :o_lvl4, :o_lvl5, :o_lvl6, :o_lvl7, :o_met, :o_use
    FROM logpurt
    WHERE id = (SELECT host_name FROM qsys2.system_status_info)
    WITH NC;

  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'PREPARE failed. '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  RETURN log_is_successful;

  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_GetConfiguredDays; // Guarantee our SQL cursor gets closed.
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC GetConfiguredDays;

// -------------------------------------------------------------------------------------------------
///
//   Purge LOGMETT.
//
//   Purge metric data we have collected by getting the number of days to be retained, calculating
// the date for that many days in the past, and delete all rows in LOGMETT where beg_ts is less than
// that calculated date.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC PurgeLOGMETT;
  DCL-PI PurgeLOGMETT;
    i_days LIKE(tpl_sdk4i_logpurt_ds.purge_met) CONST;
  END-PI;

  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S permit_sqlstates_array LIKE(tpl_sdk4i_err_sqlstate) DIM(1);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  EXEC SQL
    DELETE FROM logmett
    WHERE beg_ts <= TIMESTAMP(NOW()) - :i_days DAYS;
  
  permit_sqlstates_array(1) = '02000'; // It is OK if we did not find any rows to delete.
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of LOGMETT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1')) +' rows from LOGMETT';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    EXEC SQL COMMIT;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC PurgeLOGMETT;

// -------------------------------------------------------------------------------------------------
///
//   Purge LOGMSGT.
//
//   Purge messages we have collected. Because of the wide range of messages - some are security
// related which we might want to keep longer, some are debug-level messages which we might not
// want to keep very long, etc. this procedure is a bit more complex than others.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC PurgeLOGMSGT;
  DCL-PI PurgeLOGMSGT;
    i_lvl0 LIKE(tpl_sdk4i_logpurt_ds.purge_0) CONST;
    i_lvl1 LIKE(tpl_sdk4i_logpurt_ds.purge_1) CONST;
    i_lvl2 LIKE(tpl_sdk4i_logpurt_ds.purge_2) CONST;
    i_lvl3 LIKE(tpl_sdk4i_logpurt_ds.purge_3) CONST;
    i_lvl4 LIKE(tpl_sdk4i_logpurt_ds.purge_4) CONST;
    i_lvl5 LIKE(tpl_sdk4i_logpurt_ds.purge_5) CONST;
    i_lvl6 LIKE(tpl_sdk4i_logpurt_ds.purge_6) CONST;
    i_lvl7 LIKE(tpl_sdk4i_logpurt_ds.purge_7) CONST;
  END-PI;

  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S permit_sqlstates_array LIKE(tpl_sdk4i_err_sqlstate) DIM(1);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  permit_sqlstates_array(1) = '02000'; // It is OK if we did not find any rows to delete.

  // Purge level 0 (Emergency) messages.
  EXEC SQL
    DELETE FROM logmsgt
    WHERE ts <= TIMESTAMP(NOW()) - :i_lvl0 DAYS AND loglvlt_id = 0;
  
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of Emergency (level 0) messages from LOGMSGT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_cause_info_ds;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1'))+
    ' EMERGENCY level rows from LOGMSGT and '+
    %TRIM(%EDITC(s_diagnostics_ds.db2_row_count_secondary: '1'))+
    ' rows from other tables (LOGCSIT, LOGEXTT, LOGWBLT, LOGWBRT, etc.)';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  RESET log_event_info_ds;

  // Purge level 1 (Alert) messages.
  EXEC SQL
    DELETE FROM logmsgt
    WHERE ts <= TIMESTAMP(NOW()) - :i_lvl1 DAYS AND loglvlt_id = 1;
  
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of Alert (level 1) messages from LOGMSGT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_cause_info_ds;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1'))+
    ' ALERT level rows from LOGMSGT and '+
    %TRIM(%EDITC(s_diagnostics_ds.db2_row_count_secondary: '1'))+
    ' rows from other tables (LOGCSIT, LOGEXTT, LOGWBLT, LOGWBRT, etc.)';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  RESET log_event_info_ds;

  // Purge level 2 (Critical) messages.
  EXEC SQL
    DELETE FROM logmsgt
    WHERE ts <= TIMESTAMP(NOW()) - :i_lvl2 DAYS AND loglvlt_id = 2;
  
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of Critical (level 2) messages from LOGMSGT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_cause_info_ds;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1'))+
    ' CRITICAL level rows from LOGMSGT and '+
    %TRIM(%EDITC(s_diagnostics_ds.db2_row_count_secondary: '1'))+
    ' rows from other tables (LOGCSIT, LOGEXTT, LOGWBLT, LOGWBRT, etc.)';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  RESET log_event_info_ds;

  // Purge level 3 (Error) messages.
  EXEC SQL
    DELETE FROM logmsgt
    WHERE ts <= TIMESTAMP(NOW()) - :i_lvl3 DAYS AND loglvlt_id = 3;
  
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of Error (level 3) messages from LOGMSGT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_cause_info_ds;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1'))+
    ' ERROR level rows from LOGMSGT and '+
    %TRIM(%EDITC(s_diagnostics_ds.db2_row_count_secondary: '1'))+
    ' rows from other tables (LOGCSIT, LOGEXTT, LOGWBLT, LOGWBRT, etc.)';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  RESET log_event_info_ds;

  // Purge level 4 (Warning) messages.
  EXEC SQL
    DELETE FROM logmsgt
    WHERE ts <= TIMESTAMP(NOW()) - :i_lvl4 DAYS AND loglvlt_id = 4;
  
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of Warning (level 4) messages from LOGMSGT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_cause_info_ds;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1'))+
    ' WARNING level rows from LOGMSGT and '+
    %TRIM(%EDITC(s_diagnostics_ds.db2_row_count_secondary: '1'))+
    ' rows from other tables (LOGCSIT, LOGEXTT, LOGWBLT, LOGWBRT, etc.)';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  RESET log_event_info_ds;

  // Purge level 5 (Notice) messages.
  EXEC SQL
    DELETE FROM logmsgt
    WHERE ts <= TIMESTAMP(NOW()) - :i_lvl5 DAYS AND loglvlt_id = 5;
  
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of Notice (level 5) messages from LOGMSGT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_cause_info_ds;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1'))+
    ' NOTICE level rows from LOGMSGT and '+
    %TRIM(%EDITC(s_diagnostics_ds.db2_row_count_secondary: '1'))+
    ' rows from other tables (LOGCSIT, LOGEXTT, LOGWBLT, LOGWBRT, etc.)';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  RESET log_event_info_ds;

  // Purge level 6 (Informational) messages.
  EXEC SQL
    DELETE FROM logmsgt
    WHERE ts <= TIMESTAMP(NOW()) - :i_lvl6 DAYS AND loglvlt_id = 6;
  
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of Informational (level 6) messages from LOGMSGT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_cause_info_ds;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1'))+
    ' INFORMATIONAL level rows from LOGMSGT and '+
    %TRIM(%EDITC(s_diagnostics_ds.db2_row_count_secondary: '1'))+
    ' rows from other tables (LOGCSIT, LOGEXTT, LOGWBLT, LOGWBRT, etc.)';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  RESET log_event_info_ds;

  // Purge level 7 (Debug) messages.
  EXEC SQL
    DELETE FROM logmsgt
    WHERE ts <= TIMESTAMP(NOW()) - :i_lvl7 DAYS AND loglvlt_id = 7;
  
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of Debug (level 7) messages from LOGMSGT encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1'))+
    ' DEBUG level rows from LOGMSGT and '+
    %TRIM(%EDITC(s_diagnostics_ds.db2_row_count_secondary: '1'))+
    ' rows from other tables (LOGCSIT, LOGEXTT, LOGWBLT, LOGWBRT, etc.)';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  RESET log_event_info_ds;

  ON-EXIT log_is_abend;
    EXEC SQL COMMIT;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC PurgeLOGMSGT;

// -------------------------------------------------------------------------------------------------
///
//   Purge LOGUSET.
//
//   Purge usage data we have collected by getting the number of days to be retained, calculating
// the date for that many days in the past, and delete all rows in LOGUSET where yr, mnth, d, hr,
// or mn are less than that calculated date.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC PurgeLOGUSET;
  DCL-PI PurgeLOGUSET;
    i_days LIKE(tpl_sdk4i_logpurt_ds.purge_use) CONST;
  END-PI;

  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S permit_sqlstates_array LIKE(tpl_sdk4i_err_sqlstate) DIM(1);
  DCL-S temp_day LIKE(tpl_sdk4i_loguset_ds.d) INZ(-1);
  DCL-S temp_hour LIKE(tpl_sdk4i_loguset_ds.hr) INZ(-1);
  DCL-S temp_minute LIKE(tpl_sdk4i_loguset_ds.mn) INZ(-1);
  DCL-S temp_month LIKE(tpl_sdk4i_loguset_ds.mnth) INZ(-1);
  DCL-S temp_timestamp TIMESTAMP INZ(*SYS);
  DCL-S temp_year LIKE(tpl_sdk4i_loguset_ds.yr);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  EXEC SQL
    VALUES(
      TIMESTAMP(NOW()) - :i_days DAYS
    )
    INTO :temp_timestamp;

  temp_year = %SUBDT(temp_timestamp: *YEARS: 4);
  temp_month = %SUBDT(temp_timestamp: *MONTHS: 2);
  temp_day = %SUBDT(temp_timestamp: *DAYS: 2);
  temp_hour = %SUBDT(temp_timestamp: *HOURS: 2);
  temp_minute = %SUBDT(temp_timestamp: *MINUTES: 2);

  EXEC SQL
    DELETE FROM loguset
    WHERE yr < :temp_year OR
          yr = :temp_year AND mnth < :temp_month OR
          yr = :temp_year AND mnth = :temp_month AND d < :temp_day OR
          yr = :temp_year AND mnth = :temp_month AND d = :temp_day AND hr < :temp_hour OR
          yr = :temp_year AND mnth = :temp_month AND d = :temp_day AND hr < :temp_hour AND mn < :temp_minute;

  permit_sqlstates_array(1) = '02000'; // It is OK if we did not find any rows to delete.
  IF (ERR_IsSQLError(s_diagnostics_ds: %ELEM(permit_sqlstates_array): permit_sqlstates_array: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Purge of LOGUSET encountered a failure: '+ s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'Purged '+ %TRIM(%EDITC(s_diagnostics_ds.row_count: '1')) +' rows from LOGUSET';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    EXEC SQL COMMIT;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC PurgeLOGUSET;