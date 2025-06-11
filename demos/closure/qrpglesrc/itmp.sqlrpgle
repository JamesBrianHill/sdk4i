**FREE
// -------------------------------------------------------------------------------------------------
//   This service program is a data mapper providing CRUD functionality for the ITMT table.
//
// @author James Brian Hill
// @copyright Copyright (c) 2025 by James Brian Hill
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
/COPY '../../../src/qcpysrc/ctloptspk.rpgleinc'
CTL-OPT TEXT('SDK4i - ITM - Data Mapper');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// ERRK - ERR constants, data structures, variables, and procedure definitions.
// LOGK - LOG constants, data structures, variables, and procedure definitions.
// MSGK - MSG constants, data structures, variables, and procedure definitions.
// NILK - NIL constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// TXTK - TXT constants, data structures, variables, and procedure definitions.
// VLDK - VLD constants, data structures, variables, and procedure definitions.
// -------------------------------------------------------------------------------------------------
/COPY '../../../src/qcpysrc/errk.rpgleinc'
/COPY '../../../src/qcpysrc/logk.rpgleinc'
/COPY '../../../src/qcpysrc/msgk.rpgleinc'
/COPY '../../../src/qcpysrc/nilk.rpgleinc'
/COPY '../../../src/qcpysrc/psdsk.rpgleinc'
/COPY '../../../src/qcpysrc/txtk.rpgleinc'
/COPY '../../../src/qcpysrc/vldk.rpgleinc'

// -------------------------------------------------------------------------------------------------
// Pull in column definitions.
// -------------------------------------------------------------------------------------------------
DCL-DS tpl_itmt_ds EXTNAME('ITMT') INZ(*EXTDFT) QUALIFIED TEMPLATE CCSID(*EXACT) END-DS;
DCL-DS tpl_itmt_null_ds EXTNAME('ITMT': *NULL) QUALIFIED TEMPLATE END-DS;

// -------------------------------------------------------------------------------------------------
// Define global constants, template data structures, and template variables.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Set SQL options before any executable code but after all global Definition Specifications.
// -------------------------------------------------------------------------------------------------
/COPY '../../../src/qcpysrc/sqloptk.rpgleinc'

// -------------------------------------------------------------------------------------------------
///
//   Create a resource.
//
//   If the data provided is valid and all required data is provided, a row will be inserted into
// the table and a 201 (CREATED) response will be returned with a JSON payload containing the newly
// created resource.
//
//   If the caller does not provide all required data or the data they provide is invalid, a 400 BAD
// REQUEST response will be returned with information about what is required and what is considered
// valid.
//
//   If an unexpected error occurs, a 550 (INTERNAL SERVER ERROR) response will be returned.
//
// @param REQUIRED. The payload sent by the caller.
// @param REQUIRED. An HTTP Response code indicating the status (succuss/failure) of this request.
// @param REQUIRED. A JSON string containing the newly created resource will be returned on success,
//   else a JSON string containing error/warning/informational messages will be returned.
// @param OPTIONAL. Information about the user associated with this transaction.
//
// @return *ON if the resource was successfully created, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC CreateITMT;
  DCL-PI CreateITMT IND;
    i_payload LIKE(tpl_sdk4i_varchar_1M_utf8) CONST;
    o_rsp_code LIKE(tpl_sdk4i_http_status_code);
    o_payload LIKE(tpl_sdk4i_varchar_1K_utf8);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS data_ds LIKEDS(tpl_itmt_ds) NULLIND(data_null_ds) INZ(*LIKEDS);
  DCL-DS data_null_ds LIKEDS(tpl_itmt_null_ds) INZ(*LIKEDS);
  DCL-DS msg_array LIKEDS(tpl_sdk4i_msg_ds) DIM(*VAR: C_SDK4I_MSG_ARRAY_COUNT);
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S cnt LIKE(tpl_sdk4i_binary4);
  DCL-S column_array LIKE(tpl_sdk4i_db2_column_name) DIM(C_SDK4I_COLUMN_COUNT);
  DCL-S column_count LIKE(tpl_sdk4i_column_count);
  DCL-S msg_count LIKE(tpl_sdk4i_msg_count);
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S x LIKE(tpl_sdk4i_unsigned_binary4);

  //   For every nullable column in the underlying table, we must define a flag that indicates if
  // the variable is NULL or not for use in our SQL statement.
  // DCL-S x_null LIKE(tpl_sdk4i_nil_null_int) INZ(C_SDK4I_NOT_NULL);

  // Bring in variables associated with logging.
  /COPY '../../../src/qcpysrc/logvark.rpgleinc'

  // Validate the data given to us.
  %ELEM(msg_array: *ALLOC) = C_SDK4I_MSG_ARRAY_COUNT;
  IF (NOT ValidateITMT(i_payload: data_ds: column_count: column_array: msg_count: msg_array: log_user_info_ds));
    %ELEM(msg_array: *KEEP) = msg_count;
  ENDIF;

  // Update our NULL flags based on the results of the Validate procedure.
  // x_null = NIL_IndToInt(%NULLIND(data_ds.x));

  // Make sure we are not about to violate any uniqueness constraints.
  EXEC SQL
    SELECT COUNT(*)
    INTO :cnt
    FROM itmt
    WHERE name = :data_ds.name;
  IF (cnt > 0);
    msg_count += 1;
    %ELEM(msg_array: *KEEP) = msg_count;
    msg_array(msg_count).id = 'ITMT_DUPLICATE_NAME';
    msg_array(msg_count).severity = C_SDK4I_LL_ERR;
  ENDIF;

  //   If any data was invalid, required data was not provided, or a uniqueness constraint would be
  // violated, return a 400 (BAD REQUEST) response and exit this procedure.
  IF (msg_count > 0);
    log_is_successful = *OFF;
    o_payload = TXT_CreateJSONObject('messages': MSG_MsgArrayToJSON(msg_count: msg_array));
    o_rsp_code = 400;
    log_msg = 'Invalid data was found or required data was not provided. New ITMT not created.';
    FOR x=1 to msg_count;
      log_msg += ' (' + %TRIM(%EDITC(x: '1')) + ') ' + msg_array(x);
    ENDFOR;
    log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  //   If we made it here, all the required data is present and all data is valid. Create the
  // resource and return it as a JSON string.
  s_stmt = 'SELECT ' +
    'JSON_OBJECT(' +
      TXT_Q('data') + ' VALUE ' +
      'JSON_OBJECT(' +
        TXT_Q('id') + ' VALUE id, ' +
        TXT_Q('name') + ' VALUE name'+
      ') ' +
    ') ' +
    'FROM FINAL TABLE (INSERT INTO ITMT(name) '+
    'VALUES(?))';

  EXEC SQL PREPARE s_CreateITMT FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    o_rsp_code = 550;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL DECLARE c_CreateITMT CURSOR FOR s_CreateITMT;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'DECLARE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    o_rsp_code = 550;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL OPEN c_CreateITMT USING
    :data_ds.name;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'OPEN failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    o_rsp_code = 550;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL FETCH c_CreateITMT INTO :o_payload;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'FETCH failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    o_rsp_code = 550;
    RETURN log_is_successful;
  ENDIF;

  o_rsp_code = 201;

  RETURN log_is_successful;

  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_CreateITMT;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds:log_user_info_ds);
      o_rsp_code = 999;
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC CreateITMT;

// -------------------------------------------------------------------------------------------------
///
//   Delete a resource.
//
//   Given an id, if we find that resource in the table we will delete it and a 204 (NO CONTENT)
// response code will be returned and the procedure will return *ON. In all other cases, the
// procedure will return *OFF.
//
//   If the caller does not provide a valid id, a 404 (NOT FOUND) response code will be returned.
//
//   If an unexpected error occurs, a 550 (INTERNAL SERVER ERROR) response code will be returned.
//
// @param REQUIRED. The id of the resource to be deleted.
// @param REQUIRED. An HTTP response code indicating the status of this procedure.
// @param REQUIRED. A JSON string containing the newly created resource will be returned on success,
//   else a JSON string containing error/warning/informational messages will be returned.
// @param OPTIONAL. Information about the user associated with this transaction.
//
// @return *ON if the resource was successfully deleted, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC DeleteITMT;
  DCL-PI DeleteITMT IND;
    i_id LIKE(tpl_itmt_ds.id) CONST;
    o_rsp_code LIKE(tpl_sdk4i_http_status_code);
    o_payload LIKE(tpl_sdk4i_varchar_1K_utf8);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  DCL-DS msg_array LIKEDS(tpl_sdk4i_msg_ds) INZ(*LIKEDS) DIM(*VAR: C_SDK4I_MSG_ARRAY_COUNT);
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S msg_count LIKE(tpl_sdk4i_msg_count);
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);

  // Bring in variables associated with logging.
  /COPY '../../../src/qcpysrc/logvark.rpgleinc'

  s_stmt = 'DELETE FROM itmt WHERE id = ?';

  EXEC SQL PREPARE s_DeleteITMT FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    o_rsp_code = 550;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL EXECUTE c_DeleteITMT USING :i_id;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'EXECUTE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    IF (s_diagnostics_ds.returned_sqlstate = C_SDK4I_SQLSTATE_NOT_FOUND);
      msg_count += 1;
      msg_array(msg_count).id = 'DM_ID_NOT_FOUND';
      msg_array(msg_count).severity = C_SDK4I_LL_ERR;
      o_rsp_code = 404;
      o_payload = TXT_CreateJSONObject('messages': MSG_MsgArrayToJSON(msg_count: msg_array));
    ELSE;
      o_rsp_code = 550;
    ENDIF;
    RETURN log_is_successful;
  ENDIF;

  o_rsp_code = 204;

  RETURN log_is_successful;

  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_DeleteITMT;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds:log_user_info_ds);
      o_rsp_code = 999;
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC DeleteITMT;

// -------------------------------------------------------------------------------------------------
///
//   Parse data.
//
//   Parse the JSON data sent to the Create and Update procedures. Note that any unexpected "key"
// values will be ignored.
//
// @param REQUIRED. The JSON string to be parsed.
// @param REQUIRED. The data structure to be populated. Note that this data structure will be
//   CLEARed when this procedure is called.
// @param REQUIRED. The number of elements in the o_column_array.
// @param REQUIRED. An array of column names found in i_json_string.
// @param OPTIONAL. Information about the user associated with this transaction.
//
// @return *ON if the JSON data was successfully parse, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC ParseITMT;
  DCL-PI ParseITMT IND;
    i_json_string LIKE(tpl_sdk4i_varchar_1K_utf8) OPTIONS(*TRIM) CONST;
    o_data_ds LIKEDS(tpl_itmt_ds) OPTIONS(*NULLIND);
    o_column_count LIKE(tpl_sdk4i_column_count);
    o_column_array LIKE(tpl_sdk4i_db2_column_name) DIM(C_SDK4I_COLUMN_COUNT);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S permit_sqlstates_count LIKE(tpl_sdk4i_err_sqlstate_count);
  DCL-S permit_sqlstates LIKE(tpl_sdk4i_err_sqlstate) DIM(C_SDK4I_ERR_PERMIT_SQLSTATE_COUNT);
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);

  // Define NULL flags for every column because the JSON data may not have a value for every column.
  DCL-S id_null LIKE(tpl_sdk4i_nil_null_int) INZ(C_SDK4I_NULL);
  DCL-S name_null LIKE(tpl_sdk4i_nil_null_int) INZ(C_SDK4I_NULL);

  // Bring in variables associated with logging.
  /COPY '../../../src/qcpysrc/logvark.rpgleinc'

  // Initialize data structures and parameters we will be returning.
  CLEAR o_data_ds;
  CLEAR o_column_array;
  o_column_count = 0;

  //   In cases where the caller provides string data that is too long for a particular column, Db2
  // will truncate everything to the right of the maximum length expected and throw an error.
  //
  //   To allow the truncation of string data without throwing an error, we must permit an SQLSTATE
  // of 01004 (truncation of string data). We have judged that for this program, truncating data is
  // preferable to throwing an error.
  //
  //   If you are using this program as an example or guide for your own web service, you must
  // decide if you want to permit truncation of data or not. If you elect not to allow it, simply
  // delete the first two lines below.
  //
  //   In the event the caller provides invalid data - for instance, the JSON itself is malformed,
  // execution of the SQL statement will return a 02000 which means "row not found".
  //
  // @see https://www.ibm.com/docs/en/i/7.5?topic=codes-listing-sqlstate-values
  permit_sqlstates_count += 1;
  permit_sqlstates(permit_sqlstates_count) = C_SDK4I_SQLSTATE_TRUNCATION_STRING_DATA;

  //   Build the SQL to parse the JSON string. We will try to get every column that exists in the
  // table though the caller may not have sent every column. If the caller sent columns that are
  // not listed here, they will be ignored completely.
  //
  //   For default values on empty, we have elected to use -1 for numeric fields and '*' for
  // character fields because they are not valid values for their respective columns. You might
  // need to adjust these defaults in your own data mappers - using NULL ON EMPTY,
  // assuming the column isn't allowed to be NULL, would probably be a good solution.
  s_stmt = 'SELECT id, name '+
    'FROM JSON_TABLE('+
      TXT_Q(i_json_string) + ', '+
      TXT_Q('strict $') + ' '+
      'COLUMNS('+
        'id DECIMAL(5,0) PATH '+ TXT_Q('$.data.id')+
          ' DEFAULT -1 ON EMPTY, '+
        'name VARCHAR(50) PATH '+ TXT_Q('$.data.id')+
          ' DEFAULT '+ TXT_Q('*') +' ON EMPTY'+
      ')'+
    ') AS x';
  
  EXEC SQL PREPARE s_ParseITMT FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL DECLARE c_ParseITMT CURSOR FOR s_ParseITMT;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'DECLARE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL OPEN c_ParseITMT;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'OPEN failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL FETCH c_ParseITMT INTO
    :o_data_ds.id :id_null,
    :o_data_ds.name :name_null;
  IF (ERR_IsSQLError(s_diagnostics_ds: permit_sqlstates_count: permit_sqlstates: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'FETCH failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  //   If we see default values, CLEAR the respective field in o_data_ds. Otherwise, add the column
  // name to o_column_array. Set NULL indicators for columns that are nullable.
  IF (o_data_ds.id = -1);
    CLEAR o_data_ds.id;
  ELSE;
    o_column_count += 1;
    o_column_array(o_column_count) = 'id';
  ENDIF;

  IF (o_data_ds.name = '*');
    CLEAR o_data_ds.name;
  ELSE;
    o_column_count += 1;
    o_column_array(o_column_count) = 'name';
  ENDIF;

  RETURN log_is_successful;

  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_ParseITMT;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds:log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC ParseITMT;

// -------------------------------------------------------------------------------------------------
///
//   Update a resource.
//
//   If the data provided is valid and all required data is provided, update the table and return
// a 204 (NO CONTENT) response.
//
//   If the caller does not provide all required data or the data they provide is invalid, a 400 
// (BAD REQUEST) response will be returned with information about what is required and what is
// considered valid.
//
//   If the caller provided an ID that does not exist, a 404 (NOT FOUND) response will be returned.
//
//   If an unexpected error occurs, a 550 (INTERNAL SERVER ERROR) response will be returned.
//
// @param REQUIRED. The payload sent by the caller.
// @param REQUIRED. An HTTP Response code indicating the status (succuss/failure) of this request.
// @param REQUIRED. A JSON string containing error/warning/informational messages will be returned
//   if the procedure fails, otherwise the string will be empty.
// @param OPTIONAL. Information about the user associated with this transaction.
//
// @return *ON if the resource was successfully created, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC UpdateITMT;
  DCL-PI UpdateITMT IND;
    i_payload LIKE(tpl_sdk4i_varchar_1K_utf8) CONST;
    o_rsp_code LIKE(tpl_sdk4i_http_status_code);
    o_payload LIKE(tpl_sdk4i_varchar_1K_utf8);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  DCL-DS current_ds LIKEDS(tpl_itmt_ds) NULLIND(current_null_ds) INZ(*LIKEDS);
  DCL-DS current_null_ds LIKEDS(tpl_itmt_null_ds) INZ(*LIKEDS);
  DCL-DS data_ds LIKEDS(tpl_itmt_ds) NULLIND(data_null_ds) INZ(*LIKEDS);
  DCL-DS data_null_ds LIKEDS(tpl_itmt_null_ds) INZ(*LIKEDS);
  DCL-DS msg_array LIKEDS(tpl_sdk4i_msg_ds) INZ(*LIKEDS) DIM(*VAR: C_SDK4I_MSG_ARRAY_COUNT);
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S cnt LIKE(tpl_sdk4i_column_count);
  DCL-S column_array LIKE(tpl_sdk4i_db2_column_name) DIM(C_SDK4I_COLUMN_COUNT);
  DCL-S column_count LIKE(tpl_sdk4i_column_count);
  DCL-S msg_count LIKE(tpl_sdk4i_msg_count);
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S temp_col_name LIKE(tpl_sdk4i_db2_column_name);
  DCL-S x LIKE(msg_count);

  //   For every nullable column in the underlying table, we must define a flag that indicates if
  // the variable is NULL or not for use in our SQL statement.
  // DCL-S x_null LIKE(tpl_sdk4i_nil_null_int) INZ(C_SDK4I_NOT_NULL);

  // Bring in variables associated with logging.
  /COPY '../../../src/qcpysrc/logvark.rpgleinc'

  // Validate the data given to us.
  %ELEM(msg_array: *ALLOC) = C_SDK4I_MSG_ARRAY_COUNT;
  IF (NOT ValidateITMT(i_payload: data_ds: column_count: column_array: msg_count: msg_array: log_user_info_ds));
    %ELEM(msg_array: *KEEP) = msg_count;
  ENDIF;

  // Update our NULL flags based on the results of the Validate procedure.
  // x_null = NIL_IndToInt(%NULLIND(data_ds.x));

  // Make sure we are not about to violate any uniqueness constraints.
  EXEC SQL
    SELECT COUNT(*)
    INTO :cnt
    FROM itmt
    WHERE name = :data_ds.name;
  IF (cnt > 0);
    msg_count += 1;
    %ELEM(msg_array: *KEEP) = msg_count;
    msg_array(msg_count).id = 'ITMT_DUPLICATE_NAME';
    msg_array(msg_count).severity = C_SDK4I_LL_ERR;
  ENDIF;

  //   If any data was invalid, required data was not provided, or a uniqueness constraint would be
  // violated, return a 400 (BAD REQUEST) response and exit this procedure.
  IF (msg_count > 0);
    log_is_successful = *OFF;
    o_payload = TXT_CreateJSONObject('messages': MSG_MsgArrayToJSON(msg_count: msg_array));
    o_rsp_code = 400;
    log_msg = 'Invalid data was found or required data was not provided. New ITMT not created.';
    FOR x=1 to msg_count;
      log_msg += ' (' + %TRIM(%EDITC(x: '1')) + ') ' + msg_array(x);
    ENDFOR;
    log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  //   We need to get the current data for the row we're about to update because the caller may not
  // have provided values for every column - i.e., this may be a partial update.
  EXEC SQL
    SELECT id, name
    INTO :current_ds.id, :current_ds.name
    FROM itmt
    WHERE id = :data_ds.id;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'Unable to retrieve current_ds for id = '+ %TRIM(%EDITC(data_ds.id: '1'))+ '. ' + s_diagnostics_ds.err_msg;
    log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    IF (s_diagnostics_ds.returned_sqlstate = C_SDK4I_SQLSTATE_NOT_FOUND);
      o_rsp_code = 404;
      msg_count += 1;
      msg_array(msg_count).id = 'DM_ID_NOT_FOUND';
      msg_array(msg_count).severity = C_SDK4I_LL_ERR;
      o_payload = TXT_CreateJSONObject('messages': MSG_MsgArrayToJSON(msg_count: msg_array));
    ELSE;
      o_rsp_code = 550;
    ENDIF;
    RETURN log_is_successful;
  ENDIF;

  //   We may or may not be given data for all the columns in the table so we will update the
  // current_ds data structure with values given to us in the data_ds data structure. Be sure to
  // update NULL indicators as well if a column is nullable.
  temp_col_name = 'name';
  IF (%LOOKUP(temp_col_name: column_array: 1: column_count) > 0);
    current_ds.name = data_ds.name;
  ENDIF;

  // Build our SQL statement.
  s_stmt = 'UPDATE itmt SET name=? WHERE id=?';

  EXEC SQL PREPARE s_UpdateITMT FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    o_rsp_code = 550;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL EXECUTE c_UpdateITMT USING
    :current_ds.name,
    :current_ds.id;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    RESET log_cause_info_ds;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_msg = 'EXECUTE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    IF (s_diagnostics_ds.returned_sqlstate = C_SDK4I_SQLSTATE_NOT_FOUND);
      msg_count += 1;
      msg_array(msg_count).id = 'DM_ID_NOT_FOUND';
      msg_array(msg_count).severity = C_SDK4I_LL_ERR;
      o_rsp_code = 404;
      o_payload = TXT_CreateJSONObject('messages': MSG_MsgArrayToJSON(msg_count: msg_array));
    ELSE;
      o_rsp_code = 550;
    ENDIF;
    RETURN log_is_successful;
  ENDIF;

  // If we made it here, we successfully updated the resource.
  o_rsp_code = 204;

  RETURN log_is_successful;

  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_UpdateITMT;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds:log_user_info_ds);
      o_rsp_code = 999;
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC UpdateITMT;

// -------------------------------------------------------------------------------------------------
///
//   Validate data.
//
//   Validate the data sent to the Create and Update procedures.
//
//   Note on temp_col_name: when specifying CTL-OPT CCSID(*EXACT), literal values in the source code
// can have a different CCSID than one specified by the TGTCCSID parameter of the CRTBNDRPG command
// and this might be different than the CCSID of your job.
// 
//   This situation can arise when you are working on a server where the QCCSID is 65535 but you
// need your software to be something sane like 37 (or frankly, anything other than 65535).
//
// @param REQUIRED. The JSON payload to be validated.
// @param REQUIRED. A data structure that will hold data provided.
// @param REQUIRED. The number of elements in o_column_array.
// @param REQUIRED. An array of column names found in i_payload.
// @param REQUIRED. The number of messages being returned in o_msg_array.
// @param REQUIRED. An array of error, warning, or informational messages for the caller.
// @param OPTIONAL. Information about the user associated with this transaction.
//
// @return *ON if all data is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC ValidateITMT;
  DCL-PI ValidateITMT IND;
    i_payload LIKE(tpl_sdk4i_varchar_1K_utf8) CONST;
    o_data_ds LIKEDS(tpl_itmt_ds) OPTIONS(*NULLIND);
    o_column_count LIKE(tpl_sdk4i_column_count);
    o_column_array LIKE(tpl_sdk4i_db2_column_name) DIM(C_SDK4I_COLUMN_COUNT);
    o_msg_count LIKE(tpl_sdk4i_msg_count);
    o_msg_array LIKEDS(tpl_sdk4i_msg_ds) DIM(C_SDK4I_MSG_ARRAY_COUNT) OPTIONS(*VARSIZE);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  DCL-S msg_id LIKE(tpl_sdk4i_vldt_ds.msg_id);
  DCL-S temp_col_name LIKE(tpl_sdk4i_db2_column_name);
  DCL-S temp_str LIKE(tpl_sdk4i_sql_statement) NULLIND;

  // Bring in variables associated with logging.
  /COPY '../../../src/qcpysrc/logvark.rpgleinc'

  // Initialize data structures and parameters we will be returning.
  CLEAR o_msg_array;
  o_msg_count = 0;

  // Parse the data given to us.
  IF (NOT ParseITMT(i_payload: o_data_ds: o_column_count: o_column_array: log_user_info_ds));
    log_is_successful = *OFF;
    o_msg_count += 1;
    o_msg_array(o_msg_count).id = 'DM_PARSE_FAILED';
    o_msg_array(o_msg_count).severity = C_SDK4I_LL_ERR;
    log_msg = 'Unable to parse JSON data: '+ i_payload;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  ENDIF;

  // Validate the name.
  temp_str = o_data_ds.name;
  %NULLIND(temp_str) = *OFF; // name cannot be NULL.
  temp_col_name = 'name';
  IF (%LOOKUP(temp_col_name: o_column_array: 1: o_column_count) > 0 AND
      NOT VLD_IsValid('ITMT': 'NAME': msg_id: temp_str: *OMIT: *OMIT: *OMIT: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    o_msg_count += 1;
    o_msg_array(o_msg_count).id = msg_id;
    o_msg_array(o_msg_count).severity = C_SDK4I_LL_WRN;
  ENDIF;

  RETURN log_is_successful;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds:log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC ValidateITMT;