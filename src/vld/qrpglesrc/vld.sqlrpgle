**FREE
// -------------------------------------------------------------------------------------------------
//   This service program provides functionality to validate strings, numbers, phone numbers,
// dates, times, and timestamps.
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
// not, see https://www.gnu.org/licenses/gpl-3.0.html
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Control Specifications.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/ctloptspk.rpgleinc'
CTL-OPT TEXT('SDK4i - VLD - Validation procedures');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// ERRK - ERR constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// VLDK - VLD constants, data structures, variables, and procedure definitions.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/errk.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'
/COPY '../../qcpysrc/vldk.rpgleinc'

// -------------------------------------------------------------------------------------------------
// Pull in column definitions.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Define global constants, template data structures, and template variables.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Set SQL options before any executable code but after all global Definition Specifications.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/sqloptk.rpgleinc'

// -------------------------------------------------------------------------------------------------
///
// Validate a value.
//
// This procedure will validate a value for any column in any table that has a validation rule
// defined in VLDT.
//
// Examples:
// DCL-S my_name LIKE(tpl_my_table_ds.fname) INZ('James');
// DCL-S my_age LIKE(tpl_my_table_ds.age) INZ(18);
//
// IF (NOT VLD_IsValid('MY_TABLE': 'FNAME': my_name));
//   // Log error and handle appropriately.
// ENDIF;
//
// IF (NOT VLD_IsValid('MY_TABLE': 'AGE': *OMIT: my_age));
//   // Log error and handle appropriately.
// ENDIF;
//
// @param REQUIRED. The table where the column resides.
// @param REQUIRED. The column to validate against.
// @param REQUIRED. The message ID associated with this i_tbl/i_col.
// @param OPTIONAL. The string to be validated.
// @param OPTIONAL. The number to be validated.
// @param OPTIONAL. The date to be validated.
// @param OPTIONAL. The time to be validated.
// @param OPTIONAL. The timestamp to be validated.
// @param OPTIONAL. The library where the column resides.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the value is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC VLD_IsValid EXPORT;
  DCL-PI VLD_IsValid IND;
    i_tbl LIKE(tpl_sdk4i_vldt_ds.tbl) OPTIONS(*TRIM) CONST;
    i_col LIKE(tpl_sdk4i_vldt_ds.col) OPTIONS(*TRIM) CONST;
    o_msg_id LIKE(tpl_sdk4i_vldt_ds.msg_id);
    i_str LIKE(tpl_sdk4i_sql_statement) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_num LIKE(tpl_sdk4i_vldt_ds.max_num) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_date LIKE(tpl_sdk4i_vldt_ds.max_date) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_time LIKE(tpl_sdk4i_vldt_ds.max_time) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_ts LIKE(tpl_sdk4i_vldt_ds.max_ts) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_lib LIKE(tpl_sdk4i_vldt_ds.lib) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ;

  DCL-S fcol LIKE(tpl_sdk4i_vldt_ds.fcol) NULLIND;
  DCL-S fhost LIKE(tpl_sdk4i_vldt_ds.fhost) NULLIND;
  DCL-S flib LIKE(tpl_sdk4i_vldt_ds.flib) NULLIND;
  DCL-S ftbl LIKE(tpl_sdk4i_vldt_ds.ftbl) NULLIND;
  DCL-S full_rgx LIKE(tpl_sdk4i_vldt_ds.rgx) NULLIND;
  DCL-S is_nullable CHAR(1) INZ('N');
  DCL-S max_date LIKE(tpl_sdk4i_vldt_ds.max_date) NULLIND INZ(*HIVAL);
  DCL-S max_len LIKE(tpl_sdk4i_vldt_ds.max_len) NULLIND INZ(*HIVAL);
  DCL-S max_num LIKE(tpl_sdk4i_vldt_ds.max_num) NULLIND INZ(*HIVAL);
  DCL-S max_time LIKE(tpl_sdk4i_vldt_ds.max_time) NULLIND INZ(*HIVAL);
  DCL-S max_ts LIKE(tpl_sdk4i_vldt_ds.max_ts) NULLIND INZ(*HIVAL);
  DCL-S min_date LIKE(tpl_sdk4i_vldt_ds.min_date) NULLIND INZ(*LOVAL);
  DCL-S min_len LIKE(tpl_sdk4i_vldt_ds.min_len) NULLIND INZ(*LOVAL);
  DCL-S min_num LIKE(tpl_sdk4i_vldt_ds.min_num) NULLIND INZ(*LOVAL);
  DCL-S min_time LIKE(tpl_sdk4i_vldt_ds.min_time) NULLIND INZ(*LOVAL);
  DCL-S min_ts LIKE(tpl_sdk4i_vldt_ds.min_ts) NULLIND INZ(*LOVAL);
  DCL-S msg_id LIKE(tpl_sdk4i_vldt_ds.msg_id) NULLIND;
  DCL-S rgx LIKE(tpl_sdk4i_vldt_ds.rgx) NULLIND;
  DCL-S rgx_id LIKE(tpl_sdk4i_vldt_ds.rgx_id) NULLIND;
  DCL-S temp_date LIKE(i_date) NULLIND;
  DCL-S temp_lib LIKE(i_lib) NULLIND;
  DCL-S temp_num LIKE(i_num) NULLIND INZ(*LOVAL);
  DCL-S temp_rgx LIKE(tpl_sdk4i_vldt_ds.rgx) NULLIND;
  DCL-S temp_str LIKE(i_str) NULLIND;
  DCL-S temp_time LIKE(i_time) NULLIND;
  DCL-S temp_ts LIKE(i_ts) NULLIND;

  DCL-S fcol_null     INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S fhost_null    INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S flib_null     INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S ftbl_null     INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S max_date_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S min_date_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S max_len_null  INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S min_len_null  INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S max_num_null  INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S min_num_null  INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S max_time_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S min_time_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S max_ts_null   INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S min_ts_null   INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S msg_id_null   INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S rgx_null      INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S rgx_id_null   INT(5) INZ(C_SDK4I_NULL); // Default to NULL

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // ---------------------------------------------
  // Main logic.
  // ---------------------------------------------

  // Set our variables to NULL.
  %NULLIND(temp_str) = *ON;
  %NULLIND(temp_lib) = *OFF;
  %NULLIND(temp_num) = *ON;
  %NULLIND(temp_date) = *ON;
  %NULLIND(temp_time) = *ON;
  %NULLIND(temp_ts) = *ON;

  // If we were given a string to validate, set the NULL indicator and temp variable.
  IF (%PARMS >= %PARMNUM(i_str) AND %ADDR(i_str) <> *NULL);
    %NULLIND(temp_str) = %NULLIND(i_str);
    temp_str = i_str;
  ENDIF;

  // If we were given a number to validate, set the NULL indicator and temp variable.
  IF (%PARMS >= %PARMNUM(i_num) AND %ADDR(i_num) <> *NULL);
    %NULLIND(temp_num) = %NULLIND(i_num);
    temp_num = i_num;
  ENDIF;

  // If we were given a date to validate, set the NULL indicator and temp variable.
  IF (%PARMS >= %PARMNUM(i_date) AND %ADDR(i_date) <> *NULL);
    %NULLIND(temp_date) = %NULLIND(i_date);
    temp_date = i_date;
  ENDIF;

  // If we were given a time to validate, set the NULL indicator and temp variable.
  IF (%PARMS >= %PARMNUM(i_time) AND %ADDR(i_time) <> *NULL);
    %NULLIND(temp_time) = %NULLIND(i_time);
    temp_time = i_time;
  ENDIF;

  // If we were given a timestamp to validate, set the NULL indicator and temp variable.
  IF (%PARMS >= %PARMNUM(i_ts) AND %ADDR(i_ts) <> *NULL);
    %NULLIND(temp_ts) = %NULLIND(i_ts);
    temp_ts = i_ts;
  ENDIF;

  // If we were given a library, set the NULL indicator and temp variable.
  IF (%PARMS >= %PARMNUM(i_lib) AND %ADDR(i_lib) <> *NULL);
    %NULLIND(temp_lib) = %NULLIND(i_lib);
    temp_lib = %TRIM(i_lib); // We have to %TRIM here because we can't use OPTIONS(*TRIM).
  ENDIF;

  // Get the rules for validating this lib/tbl/col.
  EXEC SQL
    SELECT rgx, rgx_id, min_len, max_len, min_num, max_num, min_date, max_date, min_time, max_time,
      min_ts, max_ts, fhost, flib, ftbl, fcol, msg_id
    INTO :rgx :rgx_null, :rgx_id :rgx_id_null, :min_len :min_len_null, :max_len :max_len_null,
      :min_num :min_num_null, :max_num :max_num_null,
      :min_date :min_date_null, :max_date :max_date_null,
      :min_time :min_time_null, :max_time :max_time_null,
      :min_ts :min_ts_null, :max_ts :max_ts_null,
      :fhost :fhost_null, :flib :flib_null, :ftbl :ftbl_null, :fcol :fcol_null, :msg_id :msg_id_null
    FROM vldt
    WHERE lib = :temp_lib AND tbl = :i_tbl AND col = :i_col;

  // If we were unable to retrieve the rules for validating the requested lib/tbl/col, write out a
  // log message and return failure.
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    RESET log_cause_info_ds;
    RESET log_event_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = 'See source member.';
    log_msg = 'Failed to retrieve validation rules from vldt ('+ temp_lib +'/'+ i_tbl +'/'+ i_col +'). ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // If there is a msg_id associated with this validation rule (there should be!), return it to the
  // caller. If the one we retrieved is blank or NULL, return a generic ID.
  IF (msg_id_null = C_SDK4I_NULL);
    o_msg_id = 'GENERIC_FAILURE';
  ELSE;
    o_msg_id = msg_id;
  ENDIF;

  //   We need to know if the column being validated is nullable - so we will query the information
  // available to us in the QSYS2/SYSCOLUMNS view. If we were not given a specific library/schema,
  // we will only consider the libraries in the job's library list - which we can obtain from the
  // QSYS2/LIBRARY_LIST_INFO view.
  //
  //   The is_nullable column will always have a value of 'N' or 'Y'.
  //
  //   We look at system_* columns and non system_* columns which allows the programmer to use the
  // usual 10-character system names, or if they prefer, the long names which can be up to 128
  // characters long (as of IBM i 7.5).
  IF (temp_lib <> *BLANKS);
    EXEC SQL
      SELECT is_nullable
      INTO :is_nullable
      FROM qsys2.syscolumns
      WHERE (table_schema = :temp_lib OR system_table_schema = :temp_lib) AND
            (table_name = :i_tbl OR system_table_name = :i_tbl) AND
            (column_name = :i_col OR system_column_name = :i_col)
      FETCH FIRST 1 ROWS ONLY;
  ELSE;
    EXEC SQL
      SELECT is_nullable
      INTO :is_nullable
      FROM qsys2.syscolumns
      WHERE (table_name = :i_tbl OR system_table_name = :i_tbl) AND
            (column_name = :i_col OR system_column_name = :i_col) AND
            (
              table_schema IN (
                SELECT schema_name
                FROM qsys2.library_list_info
                ORDER BY ordinal_position
              ) OR
              system_table_schema IN (
                SELECT system_schema_name
                FROM qsys2.library_list_info
                ORDER BY ordinal_position
              )
            )
      FETCH FIRST 1 ROWS ONLY;
  ENDIF;

  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    RESET log_cause_info_ds;
    RESET log_event_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = 'See source member.';
    log_msg = 'Failed to retrieve nullable flag for ('+ temp_lib +'/'+ i_tbl + '/'+
      i_col +'). ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // If we are validating a date and no maximum was provided, log a message and default to *HIVAL.
  IF (%PARMS >= %PARMNUM(i_date) AND max_date_null = -1);
    RESET log_event_info_ds;
    log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
    log_msg = 'Max date is NULL, defaulting to *HIVAL.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    max_date = *HIVAL;
  ENDIF;

  // If we are validating a date and no minimum was provided, log a message and default to *LOVAL.
  IF (%PARMS >= %PARMNUM(i_date) AND min_date_null = -1);
    RESET log_event_info_ds;
    log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
    log_msg = 'Min date is NULL, defaulting to *LOVAL.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    min_date = *LOVAL;
  ENDIF;

  // If we are validating a number and no maximum was provided, log a message and default to *HIVAL.
  IF (%PARMS >= %PARMNUM(i_num) AND max_num_null = -1);
    RESET log_event_info_ds;
    log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
    log_msg = 'Max num is NULL, defaulting to *HIVAL.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    max_num = *HIVAL;
  ENDIF;

  // If we are validating a number and no maximum was provided, log a message and default to *LOVAL.
  IF (%PARMS >= %PARMNUM(i_num) AND min_num_null = -1);
    RESET log_event_info_ds;
    log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
    log_msg = 'Min num is NULL, defaulting to *LOVAL.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    min_num = *LOVAL;
  ENDIF;

  // If we are validating a time and no maximum was provided, log a message and default to *HIVAL.
  IF (%PARMS >= %PARMNUM(i_time) AND max_time_null = -1);
    RESET log_event_info_ds;
    log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
    log_msg = 'Max time is NULL, defaulting to *HIVAL.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    max_time = *HIVAL;
  ENDIF;

  // If we are validating a time and no maximum was provided, log a message and default to *LOVAL.
  IF (%PARMS >= %PARMNUM(i_time) AND min_time_null = -1);
    RESET log_event_info_ds;
    log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
    log_msg = 'Min time is NULL, defaulting to *LOVAL.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    min_time = *LOVAL;
  ENDIF;

  // If we are validating a timestamp and no maximum was provided, log a message and default to
  // *HIVAL.
  IF (%PARMS >= %PARMNUM(i_ts) AND max_ts_null = -1);
    RESET log_event_info_ds;
    log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
    log_msg = 'Max timestamp is NULL, defaulting to *HIVAL.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    max_ts = *HIVAL;
  ENDIF;

  // If we are validating a timestamp and no maximum was provided, log a message and default to
  // *LOVAL.
  IF (%PARMS >= %PARMNUM(i_ts) AND min_ts_null = -1);
    RESET log_event_info_ds;
    log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
    log_msg = 'Min timestamp is NULL, defaulting to *LOVAL.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    min_ts = *LOVAL;
  ENDIF;

  // Validate a foreign key.
  IF (ftbl_null = C_SDK4I_NOT_NULL AND fcol_null = C_SDK4I_NOT_NULL);
    log_is_successful = VLD_IsValidFK(ftbl: fcol: temp_str: temp_num: temp_date: temp_time: temp_ts: fhost: flib);
    RETURN log_is_successful;
  ENDIF;

  // If we were given a string and we have a regex, validate the string.
  // We set the log_is_successful value and RETURN it rather than doing:
  // RETURN VLD_IsValidString(temp_str: rgx);
  // because we capture the value of log_is_successful in the LOG_LogUse procedure in ON-EXIT below.
  IF (%PARMS >= %PARMNUM(i_str) AND %ADDR(i_str) <> *NULL AND (rgx_null = C_SDK4I_NOT_NULL OR rgx_id_null = C_SDK4I_NOT_NULL));
    // If the column we are validating can be NULL and i_str is NULL, we can return right now.
    IF (is_nullable = 'Y' AND %NULLIND(i_str));
      log_is_successful = *ON;
      RETURN log_is_successful;
    ENDIF;

    // Get the rules for validating this lib/tbl/col.
    IF (rgx_id_null = C_SDK4I_NOT_NULL);
      EXEC SQL
        SELECT rgx
        INTO :temp_rgx
        FROM rgxt
        WHERE id = :rgx_id;

      // If we were unable to retrieve the rules for validating the requested lib/tbl/col, write out
      // a log message and return failure.
      IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
        RESET log_cause_info_ds;
        RESET log_event_info_ds;
        log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
        log_cause_info_ds.sstmt = 'See source member.';
        log_msg = 'Failed to retrieve regex from rgxt ('+ rgx_id +'). ' + s_diagnostics_ds.err_msg;
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
        log_is_successful = *OFF;
        RETURN log_is_successful;
      ENDIF;
      // If we have something in the rgx field, append it to the regex we got from rgxt.
      full_rgx = %CHAR('^[': *UTF8);
      IF (rgx_null <> -1);
        full_rgx += temp_rgx + rgx;
      ELSE;
        full_rgx += temp_rgx;
      ENDIF;
      full_rgx += %CHAR(']{': *UTF8) +
        %TRIM(%EDITC(min_len: '1')) + ',' +
        %TRIM(%EDITC(max_len: '1')) +
        %CHAR('}$': *UTF8);
      rgx = full_rgx;

    ENDIF;
    log_is_successful = VLD_IsValidString(temp_str: rgx);
    RETURN log_is_successful;
  ENDIF;

  // If we were given a number, validate the value.
  IF (%PARMS >= %PARMNUM(i_num) AND %ADDR(i_num) <> *NULL);
    IF (is_nullable = 'Y' AND %NULLIND(i_num));
      log_is_successful = *ON;
    ELSE;
      log_is_successful = VLD_IsValidNumber(temp_num: min_num: max_num);
    ENDIF;
    RETURN log_is_successful;
  ENDIF;

  // If we were given a date, validate the value.
  IF (%PARMS >= %PARMNUM(i_date) AND %ADDR(i_date) <> *NULL);
    IF (is_nullable = 'Y' AND %NULLIND(i_date));
      log_is_successful = *ON;
    ELSE;
      log_is_successful = VLD_IsValidDate(temp_date: min_date: max_date);
    ENDIF;
    RETURN log_is_successful;
  ENDIF;

  // If we were given a time, validate the value.
  IF (%PARMS >= %PARMNUM(i_time) AND %ADDR(i_time) <> *NULL);
    IF (is_nullable = 'Y' AND %NULLIND(i_time));
      log_is_successful = *ON;
    ELSE;
      log_is_successful = VLD_IsValidTime(temp_time: min_time: max_time);
    ENDIF;
    RETURN log_is_successful;
  ENDIF;

  // If we were given a timestamp, validate the value.
  IF (%PARMS >= %PARMNUM(i_ts) AND %ADDR(i_ts) <> *NULL);
    IF (is_nullable = 'Y' AND %NULLIND(i_ts));
      log_is_successful = *ON;
    ELSE;
      log_is_successful = VLD_IsValidTimestamp(temp_ts: min_ts: max_ts);
    ENDIF;
    RETURN log_is_successful;
  ENDIF;

  // If we weren't given anything to validate, return failure.
  log_is_successful = *OFF;
  RETURN log_is_successful;

  // The ON-EXIT section will always be executed so we do our clean up and logging here.
  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC VLD_IsValid;

// -------------------------------------------------------------------------------------------------
///
// Validate a date.
//
// Determine if a date is valid. The caller can provide a minimum and maximum date to test if the
// date to be validated falls in the range: min_date <= test_date <= max_date. If no minimum or
// maximum value is provided, they default to '0000-00-00' and '9999-12-31' respectively.
//
// @param i_date REQUIRED. The date to be validated.
// @param i_min_date OPTIONAL. A minimum date - the date value must be after or equal to this.
// @param i_max_date OPTIONAL. A maximum date - the date value must be before or equal to this.
// @param i_log_user_info_ds OPTIONAL. Information about the user associated with this event.
//
// @return *ON if date is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC VLD_IsValidDate EXPORT;
  DCL-PI VLD_IsValidDate IND;
    i_date LIKE(tpl_sdk4i_vldt_ds.max_date) OPTIONS(*NULLIND) CONST;
    i_min_date LIKE(tpl_sdk4i_vldt_ds.min_date) OPTIONS(*NULLIND) CONST;
    i_max_date LIKE(tpl_sdk4i_vldt_ds.max_date) OPTIONS(*NULLIND) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  IF (%NULLIND(i_date));
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // Perform the validation.
  IF (i_date < i_min_date OR i_date > i_max_date);
    log_is_successful = *OFF;
  ENDIF;

  RETURN log_is_successful;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC VLD_IsValidDate;

// -------------------------------------------------------------------------------------------------
///
// Validate a foreign key.
// 
// Determine if a value is valid as a foreign key on this host or any other Db2 for i host 
// configured for remote connections.
//
// @param REQUIRED. The foreign table we need to check.
// @param REQUIRED. The foreign column we need to check.
// @param OPTIONAL. The string to be validated.
// @param OPTIONAL. The number to be validated.
// @param OPTIONAL. The date to be validated.
// @param OPTIONAL. The time to be validated.
// @param OPTIONAL. The timestamp to be validated.
// @param OPTIONAL. The foreign host we need to check.
// @param OPTIONAL. The foreign library we need to check.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the value is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC VLD_IsValidFK EXPORT;
  DCL-PI VLD_IsValidFK IND;
    i_ftbl LIKE(tpl_sdk4i_vldt_ds.ftbl) OPTIONS(*TRIM) CONST;
    i_fcol LIKE(tpl_sdk4i_vldt_ds.fcol) OPTIONS(*TRIM) CONST;
    i_str LIKE(tpl_sdk4i_sql_statement) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_num LIKE(tpl_sdk4i_vldt_ds.max_num) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_date LIKE(tpl_sdk4i_vldt_ds.max_date) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_time LIKE(tpl_sdk4i_vldt_ds.max_time) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_ts LIKE(tpl_sdk4i_vldt_ds.max_ts) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_fhost LIKE(tpl_sdk4i_vldt_ds.fhost) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_flib LIKE(tpl_sdk4i_vldt_ds.flib) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ;

  DCL-S cnt LIKE(tpl_sdk4i_binary4);
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  s_stmt = 'SELECT COUNT(*) FROM ';

  // If we were given a library, add it to the SQL statement.
  IF (%PARMS >= %PARMNUM(i_flib) AND %ADDR(i_flib) <> *NULL AND i_flib <> *BLANKS);
    // If we were also given a host, use it to form a "three-part-naming" query.
    IF (%PARMS >= %PARMNUM(i_fhost) AND %ADDR(i_fhost) <> *NULL AND i_fhost <> *BLANKS);
      s_stmt += i_fhost + '.';
    ENDIF;
    s_stmt += i_flib + '.';
  ENDIF;

  s_stmt += i_ftbl + ' WHERE ' + i_fcol + ' = ? WITH NC';

  EXEC SQL PREPARE s_IsValidFK FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    RESET log_event_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL DECLARE c_IsValidFK CURSOR FOR s_IsValidFK;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    RESET log_event_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'DECLARE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  SELECT;
    WHEN (%PARMS >= %PARMNUM(i_str) AND %ADDR(i_str) <> *NULL AND NOT %NULLIND(i_str));
      EXEC SQL OPEN c_IsValidFK USING :i_str;
    WHEN (%PARMS >= %PARMNUM(i_num) AND %ADDR(i_num) <> *NULL AND NOT %NULLIND(i_num));
      EXEC SQL OPEN c_IsValidFK USING :i_num;
    WHEN (%PARMS >= %PARMNUM(i_date) AND %ADDR(i_date) <> *NULL AND NOT %NULLIND(i_date));
      EXEC SQL OPEN c_IsValidFK USING :i_date;
    WHEN (%PARMS >= %PARMNUM(i_time) AND %ADDR(i_time) <> *NULL AND NOT %NULLIND(i_time));
      EXEC SQL OPEN c_IsValidFK USING :i_time;
    WHEN (%PARMS >= %PARMNUM(i_ts) AND %ADDR(i_ts) <> *NULL AND NOT %NULLIND(i_ts));
      EXEC SQL OPEN c_IsValidFK USING :i_ts;
    OTHER;
      log_is_successful = *OFF;
      RESET log_cause_info_ds;
      RESET log_event_info_ds;
      log_cause_info_ds.sstmt = s_stmt;
      log_msg = 'No foreign key value was provided. ';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RETURN log_is_successful;
  ENDSL;

  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    RESET log_event_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'OPEN failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL FETCH c_IsValidFK INTO :cnt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    RESET log_event_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'FETCH failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  IF (cnt = 0);
    log_is_successful = *OFF;
  ENDIF;

  RETURN log_is_successful;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_IsValidFK;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC VLD_IsValidFK;

// -------------------------------------------------------------------------------------------------
///
// Validate a number.
//
// Determine if a number is valid. The caller can provide a minimum and maximum value to test if the
// number to be validated falls in the range: min_value <= test_value <= max_value. If no minimum
// or maximum value is provided, they default to *LOVAL and *HIVAL respectively.
//
// @param REQUIRED. The number to be validated.
// @param OPTIONAL. A minimum number - the num value must be >= this number. Defaults to *LOVAL.
// @param OPTIONAL. A maximum number - the num value must be <= this number. Defaults to *HIVAL.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the number is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC VLD_IsValidNumber EXPORT;
  DCL-PI VLD_IsValidNumber IND;
    i_num LIKE(tpl_sdk4i_vldt_ds.max_num) OPTIONS(*NULLIND) CONST;
    i_min_num LIKE(tpl_sdk4i_vldt_ds.min_num) OPTIONS(*NULLIND) CONST;
    i_max_num LIKE(tpl_sdk4i_vldt_ds.max_num) OPTIONS(*NULLIND) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  IF (%NULLIND(i_num));
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // Perform the validation.
  IF (i_num < i_min_num OR i_num > i_max_num);
    log_is_successful = *OFF; // The value is invalid.
  ENDIF;

  RETURN log_is_successful;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC VLD_IsValidNumber;

// -------------------------------------------------------------------------------------------------
///
// Validate a string.
//
// Determine if a string is valid. The caller must provide a regex (regular expression) to be used
// to validate the string.
//
// @param REQUIRED. The string to be validated.
// @param REQUIRED. The regex (regular expression) to be used to validate str.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the string is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC VLD_IsValidString EXPORT;
  DCL-PI VLD_IsValidString IND;
    i_str LIKE(tpl_sdk4i_sql_statement) OPTIONS(*NULLIND) CONST;
    i_rgx LIKE(tpl_sdk4i_vldt_ds.rgx) OPTIONS(*NULLIND) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ;
  DCL-S cnt PACKED(5: 0);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // We cannot validate a string if it or the regular expression are NULL so return failure.
  IF (%NULLIND(i_str) OR %NULLIND(i_rgx));
    log_is_successful = *OFF;
    RESET log_event_info_ds;
    SELECT;
      WHEN (%NULLIND(i_str) AND %NULLIND(i_rgx));
        log_msg = 'Unable to validate a string because the value and regular expression are NULL.';
      WHEN (%NULLIND(i_str));
        log_msg = 'Unable to validate a string because the value is NULL.';
      WHEN (%NULLIND(i_rgx));
        log_msg = 'Unable to validate a string because the regular expression is NULL.';
      OTHER;
        log_msg = 'Unable to validate a string due to one or more NULL values.';
    ENDSL;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  // Perform validation.
  EXEC SQL
    WITH cte1(src) AS (
      VALUES(:i_str)
    )
    SELECT COUNT(*)
    INTO :cnt
    FROM cte1
    WHERE REGEXP_LIKE(src, :i_rgx, 1);

  // If there was an error executing the SQL statement, log a message and return failure.
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    RESET log_event_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = 'See source member.';
    log_msg = 'Unable to validate a string with REGEXP_LIKE. '+
      s_diagnostics_ds.err_msg + %CHAR(' i_str = |': *UTF8) + i_str + %CHAR('| i_rgx = |': *UTF8) + i_rgx;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  IF (cnt <> 1);
    log_is_successful = *OFF; // The value is invalid.
  ENDIF;

  RETURN log_is_successful;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC VLD_IsValidString;

// -------------------------------------------------------------------------------------------------
///
// Validate a time.
//
// Determine if a time is valid. The caller can provide a minimum and maximum value to test if the
// time to be validated falls in the range: min_time <= test_time <= max_time. If no minimum or
// maximum time is provided, they default to *LOVAL and *HIVAL respectively.
//
// @param REQUIRED. The time to be validated.
// @param REQUIRED. A minimum time - the time value must be after or equal to this.
// @param REQUIRED. A maximum time - the time value must be before or equal to this.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the time is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC VLD_IsValidTime EXPORT;
  DCL-PI VLD_IsValidTime IND;
    i_time LIKE(tpl_sdk4i_vldt_ds.max_time) OPTIONS(*NULLIND) CONST;
    i_min_time LIKE(tpl_sdk4i_vldt_ds.min_time) OPTIONS(*NULLIND) CONST;
    i_max_time LIKE(tpl_sdk4i_vldt_ds.max_time) OPTIONS(*NULLIND) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  IF (%NULLIND(i_time));
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // Perform the validation.
  IF (i_time < i_min_time OR i_time > i_max_time);
    log_is_successful = *OFF;
  ENDIF;

  RETURN log_is_successful;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC VLD_IsValidTime;

// -------------------------------------------------------------------------------------------------
///
// Validate a timestamp.
//
// Determine if a timestamp is valid. The caller can provide a minimum and maximum value to test if
// the timestamp to be validated falls in the range: min_ts <= test_ts <= max_ts. If no minimum or
// maximum timestamp is provided, they default to *LOVAL and *HIVAL respectively.
//
// @param REQUIRED. The timestamp to be validated.
// @param OPTIONAL. A minimum timestamp - the ts value must be after or equal to this.
// @param OPTIONAL. A maximum timestamp - the ts value must be before or equal to this.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the timestamp is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC VLD_IsValidTimestamp EXPORT;
  DCL-PI VLD_IsValidTimestamp IND;
    i_ts LIKE(tpl_sdk4i_vldt_ds.max_ts) OPTIONS(*NULLIND) CONST;
    i_min_ts LIKE(tpl_sdk4i_vldt_ds.min_ts) OPTIONS(*NULLIND) CONST;
    i_max_ts LIKE(tpl_sdk4i_vldt_ds.max_ts) OPTIONS(*NULLIND) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  IF (%NULLIND(i_ts));
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // Perform the validation.
  IF (i_ts < i_min_ts OR i_ts > i_max_ts);
    log_is_successful = *OFF;
  ENDIF;

  RETURN log_is_successful;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC VLD_IsValidTimestamp;