**FREE
// -------------------------------------------------------------------------------------------------
//   This service program provides procedures to help work with NULLs.
//
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
CTL-OPT TEXT('SDK4i - NIL - NULL handling utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// LOGK - LOG constants, data structures, variables, and procedure definitions
// NILK - NIL constants, data structures, variables, and procedure definitions
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/logk.rpgleinc'
/COPY '../../qcpysrc/nilk.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'

// -------------------------------------------------------------------------------------------------
// Pull in column definitions.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Define global constants, template data structures, and template variables.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
///
// Convert an IND into an INT(5).
//
// This procedure can be used to convert an RPG indicator variable to a 2-byte integer usable with
// embedded SQL.
//
// @param REQUIRED. This is an IND value that indicates if a field is NULL or not.
//
// @return -1 if i_ind = *ON, 0 otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC NIL_IndToInt EXPORT;
  DCL-PI NIL_IndToInt LIKE(tpl_sdk4i_nil_null_int);
    i_ind IND CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  IF (i_ind = *ON);
    RETURN C_SDK4I_NULL;
  ELSE;
    RETURN C_SDK4I_NOT_NULL;
  ENDIF;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC NIL_IndToInt;

// -------------------------------------------------------------------------------------------------
///
// Convert an INT(5) into an IND.
//
// This procedure can be used to convert a 2-byte integer used by embedded SQL to indicate NULL to
// an RPG indicator variable.
//
// @param REQUIRED. This is an INT(5) value that indicates if a field is NULL or not.
//
// @return *ON if i_int < 0 (indicating NULL), *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC NIL_IntToInd EXPORT;
  DCL-PI NIL_IntToInd IND;
    i_int LIKE(tpl_sdk4i_nil_null_int) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  IF (i_int < C_SDK4I_NOT_NULL);
    RETURN *ON;
  ELSE;
    RETURN *OFF;
  ENDIF;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC NIL_IntToInd;

// -------------------------------------------------------------------------------------------------
///
// Convert an array of INT(5) to an array of IND.
//
// When using embedded SQL and fetching multiple rows, we use an array of INT(5) values to capture
// NULL values. This procedure will take an array of INT(5) values and return an array of IND values
// that can be used easily by RPG.
//
// @param REQUIRED. The number of values that need to be processed.
// @param REQUIRED. An array of INT(5) values, probably from a FETCH statement.
// @param REQUIRED. An array of IND values, probably associated to a data structure like this:
//   DCL-DS my_ds QUALIFIED NULLIND(my_ind_ds); Note that this procedure will set all of the
//   indicators in this array to *OFF before doing any processing.
//
// @return *ON if the procedure was successful, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC NIL_IntArrayToIndArray EXPORT;
  DCL-PI NIL_IntArrayToIndArray;
    i_int_array_size LIKE(tpl_sdk4i_nil_array_count) CONST;
    i_int_array_ds LIKEDS(tpl_sdk4i_nil_int_array_ds) CONST OPTIONS(*EXACT);
    o_indicator_array_ds LIKEDS(tpl_sdk4i_nil_indicator_array_ds) OPTIONS(*EXACT);
  END-PI;

  DCL-S x LIKE(i_int_array_size);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  o_indicator_array_ds.indicator_string = *ALL'0';

  FOR x = 1 TO %MIN(i_int_array_size: %SIZE(i_int_array_ds));
    IF (i_int_array_ds.int_array(x) < 0);
      o_indicator_array_ds.indicator_array(x) = *ON;
    ENDIF;
  ENDFOR;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC NIL_IntArrayToIndArray;