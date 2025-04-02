**FREE
// -------------------------------------------------------------------------------------------------
//   This service program provides procedures to get information about, and handle, warnings and
// errors.
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
// Control Specificiations.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/ctloptspk.rpgleinc'
CTL-OPT TEXT('SDK4i - ERR - Error handling procedures');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// ERRK - ERR constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/errk.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'

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
//   Determine if an unexpected SQL error has occurred.
//
//   Using information from SQL DIAGNOSTICS we check the SQLSTATE for the most recently executed SQL
// statement.
//
// @param REQUIRED. A data structure to hold information retrieved from GET DIAGNOSTICS.
// @param OPTIONAL. The number of entries in the i_permit_sqlstates array.
// @param OPTIONAL. A list of SQLSTATEs that should be permitted or ignored.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if an SQLSTATE besides 00000 or one found in i_permit_sqlstates, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC ERR_IsSQLError EXPORT;
  DCL-PI ERR_IsSQLError IND;
    o_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) OPTIONS(*EXACT);
    i_permit_sqlstates_count LIKE(tpl_sdk4i_err_sqlstate_count) OPTIONS(*NOPASS: *OMIT) CONST;
    i_permit_sqlstates LIKE(tpl_sdk4i_err_sqlstate) DIM(C_SDK4I_ERR_PERMIT_SQLSTATE_COUNT)
    OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  DCL-S is_error LIKE(tpl_sdk4i_is_successful) INZ(*OFF); // Assume there will be no errors.

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  EXEC SQL GET DIAGNOSTICS CONDITION 1
    :o_diagnostics_ds.db2_message_id = DB2_MESSAGE_ID,
    :o_diagnostics_ds.db2_message_id1 = DB2_MESSAGE_ID1,
    :o_diagnostics_ds.db2_message_id2 = DB2_MESSAGE_ID2,
    :o_diagnostics_ds.message_length = MESSAGE_LENGTH,
    :o_diagnostics_ds.message_text = MESSAGE_TEXT,
    :o_diagnostics_ds.returned_sqlstate = RETURNED_SQLSTATE,
    :o_diagnostics_ds.catalog_name = CATALOG_NAME,
    :o_diagnostics_ds.schema_name = SCHEMA_NAME,
    :o_diagnostics_ds.table_name = TABLE_NAME,
    :o_diagnostics_ds.constraint_catalog = CONSTRAINT_CATALOG,
    :o_diagnostics_ds.constraint_schema = CONSTRAINT_SCHEMA,
    :o_diagnostics_ds.constraint_name = CONSTRAINT_NAME,
    :o_diagnostics_ds.trigger_catalog = TRIGGER_CATALOG,
    :o_diagnostics_ds.trigger_schema = TRIGGER_SCHEMA,
    :o_diagnostics_ds.trigger_name = TRIGGER_NAME,
    :o_diagnostics_ds.routine_catalog = ROUTINE_CATALOG,
    :o_diagnostics_ds.routine_schema = ROUTINE_SCHEMA,
    :o_diagnostics_ds.routine_name = ROUTINE_NAME,
    :o_diagnostics_ds.parameter_name = PARAMETER_NAME,
    :o_diagnostics_ds.parameter_ordinal_position = PARAMETER_ORDINAL_POSITION,
    :o_diagnostics_ds.db2_offset = DB2_OFFSET;

  // You cannot retrieve ROW_COUNT or any of the other values listed in the
  // "statement-information-item" section of the documentation using the GET DIAGNOSTICS CONDITION 1
  // above. Instead, you must retrieve them as below.
  EXEC SQL GET DIAGNOSTICS
    :o_diagnostics_ds.db2_last_row = DB2_LAST_ROW,
    :o_diagnostics_ds.db2_number_rows = DB2_NUMBER_ROWS,
    :o_diagnostics_ds.db2_row_count_secondary = DB2_ROW_COUNT_SECONDARY,
    :o_diagnostics_ds.db2_row_length = DB2_ROW_LENGTH,
    :o_diagnostics_ds.number = NUMBER,
    :o_diagnostics_ds.row_count = ROW_COUNT;

  // If we have an SQLSTATE = '00000' (success) return *OFF indicating no error occurred.
  IF (C_SDK4I_SQLSTATE_OK = o_diagnostics_ds.returned_sqlstate);
    is_error = *OFF;
    RETURN is_error;
  ENDIF;

  // If we have an SQLSTATE other than '00000', see if there are other SQLSTATEs we should ignore.
  IF (%PARMS >= %PARMNUM(i_permit_sqlstates) AND %ADDR(i_permit_sqlstates) <> *NULL AND
      %LOOKUP(o_diagnostics_ds.returned_sqlstate: i_permit_sqlstates) > 0);
    is_error = *OFF;
    RETURN is_error;
  ENDIF;

  // We have encountered an SQLSTATE we were not expecting.
  is_error = *ON;
  log_is_successful = *OFF;
  IF (o_diagnostics_ds.db2_message_id <> *BLANKS);
    o_diagnostics_ds.err_msg = o_diagnostics_ds.db2_message_id + ': ' +
      o_diagnostics_ds.message_text;
  ENDIF;

  // If we have information about a parameter, add it to the err_msg.
  IF (o_diagnostics_ds.parameter_ordinal_position > 0 OR o_diagnostics_ds.parameter_name <>*BLANKS);
    o_diagnostics_ds.err_msg += ' Parameter ' +
      %EDITC(o_diagnostics_ds.parameter_ordinal_position: '1');
    o_diagnostics_ds.err_msg += ' (' + o_diagnostics_ds.parameter_name + ')';
  ENDIF;

  // If we have information about a constraint, add it to the err_msg.
  IF (o_diagnostics_ds.constraint_catalog <> *BLANKS);
    o_diagnostics_ds.err_msg += ' Constraint info: ' + o_diagnostics_ds.constraint_catalog + '/' +
      o_diagnostics_ds.constraint_schema + '/' + o_diagnostics_ds.constraint_name +
      ' owned by ' + o_diagnostics_ds.catalog_name + '/' +
      o_diagnostics_ds.schema_name + '/' + o_diagnostics_ds.table_name;
  ENDIF;

  RETURN is_error;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC ERR_IsSQLError;