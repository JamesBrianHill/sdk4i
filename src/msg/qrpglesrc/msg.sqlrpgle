**FREE
// -------------------------------------------------------------------------------------------------
//   This service program provides message-related procedures.
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
CTL-OPT TEXT('SDK4i - MSG - Messaging utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// MSGK - MSG constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/msgk.rpgleinc'
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
// Retrieve a message in JSON format.
//
// Create a JSON object based on a message code, optional severity and optional language then
// return it to the caller.
//
// @param REQUIRED. The message ID to be looked up in the database.
// @param OPTIONAL. The severity of the message. Defaults to SDK4I_C_LL_INF.
// @param OPTIONAL. The requested language of the message. Defaults to en (English).
// @param OPTIONAL. Information about the user associated with this event.
//
// @return The JSON object.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC MSG_MsgToJSON EXPORT;
  DCL-PI MSG_MsgToJSON LIKE(tpl_sdk4i_json_msg);
    i_msg_id LIKE(tpl_sdk4i_msgt_ds.id) CONST;
    i_severity LIKE(tpl_sdk4i_logmsgt_ds.loglvlt_id) OPTIONS(*NOPASS: *OMIT) CONST;
    i_lng_id LIKE(tpl_sdk4i_msgt_ds.lng_id) OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S lng_id LIKE(tpl_sdk4i_msgt_ds.lng_id) INZ('en');
  DCL-S msg LIKE(tpl_sdk4i_msgt_ds.msg);
  DCL-S severity LIKE(i_severity) INZ(C_SDK4I_LL_INF);
  DCL-S o_json LIKE(tpl_sdk4i_json_msg);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  IF (%PARMS >= %PARMNUM(i_severity) AND %ADDR(i_severity) <> *NULL);
    severity = i_severity;
  ENDIF;

  IF (%PARMS >= %PARMNUM(i_lng_id) AND %ADDR(i_lng_id) <> *NULL);
    lng_id = i_lng_id;
  ENDIF;

  EXEC SQL
    VALUES(
      SELECT IFNULL(msg, 'No message description found.')
      FROM msgt
      WHERE
        id = :i_msg_id AND
        lng_id = :lng_id
    )
    INTO :msg;

  o_json = %CHAR('{' +
    '"id":"' + i_msg_id + '",' +
    '"severity":"' + %CHAR(severity) + '",' +
    '"msg":"' + msg + '"' +
  '}' : *UTF8);

  RETURN o_json;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC MSG_MsgToJSON;

// -------------------------------------------------------------------------------------------------
///
// Retreive an array of messages in JSON format.
//
// This procedure will create a JSON string containing an array of error messages.
//
// @param REQUIRED. The number of elements in the i_msg_array.
// @param REQUIRED. An array of tpl_sdk4i_msg_ds data structures.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return A JSON string containing all the messages in i_msg_array.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC MSG_MsgArrayToJSON EXPORT;
  DCL-PI MSG_MsgArrayToJSON LIKE(tpl_sdk4i_json_msg_array);
    i_msg_count LIKE(tpl_sdk4i_msg_count) CONST;
    i_msg_array LIKEDS(tpl_sdk4i_msg_ds) DIM(C_SDK4I_MSG_ARRAY_COUNT) OPTIONS(*VARSIZE) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S o_json LIKE(tpl_sdk4i_json_msg_array);
  DCL-S x LIKE(i_msg_count) INZ(0);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  CLEAR o_json;

  o_json = %CHAR('[' : *UTF8);
  FOR x = 1 TO i_msg_count;
    IF (x > 1);
      o_json += %CHAR(',' : *UTF8);
    ENDIF;
    o_json += MSG_MsgToJSON(i_msg_array(x).id : i_msg_array(x).severity);
  ENDFOR;
  o_json += %CHAR(']' : *UTF8);

  RETURN o_json;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC MSG_MsgArrayToJSON;