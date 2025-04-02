**FREE
// -------------------------------------------------------------------------------------------------
// Description: This service program provides a consistent way to create HTTP requests and
//              responses.
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
CTL-OPT ALLOC(*TERASPACE);
CTL-OPT TEXT('SDK4i - WEB - Web service utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// CCSID0037K - EBCDIC definitions for codepage 37.
// ERRK - ERR constants, data structures, variables, and procedure definitions
// IBMAPIK - IBM API constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// TXTK - TXT constants, data structures, variables, and procedure definitions
// WEBK - WEB constants, data structures, variables, and procedure definitions
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/ccsid0037k.rpgleinc'
/COPY '../../qcpysrc/errk.rpgleinc'
/COPY '../../qcpysrc/ibmapik.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'
/COPY '../../qcpysrc/txtk.rpgleinc'
/COPY '../../qcpysrc/webk.rpgleinc'

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
//   Populate an array of data structures to describe the Apache environment variables to be
// retrieved for logging.
//
//   This procedure is called by our web services which will later call the LOG_LogMsg procedure.
//
// @param REQUIRED. An empty array that will be filled with environment variables to be retrieved.
// @param OPTIONAL. Information about the user associated with this event.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_BuildLOGWBLTEnvVarArray EXPORT;
  DCL-PI WEB_BuildLOGWBLTEnvVarArray LIKE(tpl_sdk4i_unsigned_binary4);
    o_env_var_array LIKEDS(tpl_sdk4i_web_env_var_ds) DIM(C_SDK4I_WEB_ENV_VAR_ARRAY_COUNT) OPTIONS(*NULLIND: *OMIT);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS env_var_ds LIKEDS(tpl_sdk4i_web_env_var_ds) INZ(*LIKEDS);
  DCL-S env_var_count LIKE(tpl_sdk4i_unsigned_binary4) INZ(0);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  RESET env_var_ds;
  env_var_ds.name = 'SERVER_ADDR';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'SERVER_PORT';
  env_var_ds.type = 'I';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'REMOTE_ADDR';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'REMOTE_PORT';
  env_var_ds.type = 'I';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'SERVER_PROTOCOL';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'REQUEST_METHOD';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'DOCUMENT_URI';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'QUERY_STRING';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'SCRIPT_NAME';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RESET env_var_ds;
  env_var_ds.name = 'QIBM_CGI_LIBRARY_LIST';
  env_var_count += 1;
  o_env_var_array(env_var_count) = env_var_ds;

  RETURN env_var_count;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_BuildLOGWBLTEnvVarArray;

// -------------------------------------------------------------------------------------------------
///
// Get an environment variable of type int.
//
// Call the getenv procedure to get an HTTP Server environment variable of type int.
//
// @param REQUIRED. The environment variable to be retrieved.
// @param OPTIONAL. If the environment variable is not set, this is the value the caller would like
//   returned instead. If not passed, the default is 0.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return the value retrieved if available, else the default if provided, or 0 if no value was
//   retrieved and no default value was provided.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_GetEnvVarInt EXPORT;
  DCL-PI WEB_GetEnvVarInt LIKE(tpl_sdk4i_binary4);
    i_var LIKE(tpl_sdk4i_web_env_var_name) OPTIONS(*TRIM) CONST;
    i_default LIKE(tpl_sdk4i_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S o_value LIKE(i_default) INZ(0);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  MONITOR;
    o_value = %INT(%STR(GetEnv(i_var)));
  ON-ERROR;
    IF (%PARMS >= %PARMNUM(i_default) AND %ADDR(i_default) <> *NULL);
      o_value = i_default;
    ELSE;
      o_value = 0;
    ENDIF;
    log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
    log_msg = 'Error getting environment variable ('+ i_var +'). Setting value to: '+
      %TRIM(%EDITC(o_value: '1'));
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  ENDMON;

  RETURN o_value;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      o_value = 0;
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_GetEnvVarInt;

// -------------------------------------------------------------------------------------------------
///
// Get an environment variable of type string.
//
// To get the Authorization header from Apache, the following line needs to be added to the config:
// SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
// @link https://axellarsson.com/blog/rpgle-cgi-authorization-header/ (thank you Axel Larsson!)
//
// @param REQUIRED. The environment variable to be retrieved.
// @param OPTIONAL. If the environment variable is not set, this is the value the caller would like
//   returned instead. If not passed, the default is *BLANKS.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return the value retrieved if available, else the default if provided, or blanks if no value
//   was retrieved and no default value was provided.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_GetEnvVarStr EXPORT;
  DCL-PI WEB_GetEnvVarStr LIKE(tpl_sdk4i_web_env_var_string_value);
    i_var LIKE(tpl_sdk4i_web_env_var_name) OPTIONS(*TRIM) CONST;
    i_default LIKE(tpl_sdk4i_web_env_var_string_value) OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S o_value LIKE(i_default);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  MONITOR;
    o_value = %STR(GetEnv(i_var));
  ON-ERROR;
    IF (%PARMS >= %PARMNUM(i_default) AND %ADDR(i_default) <> *NULL);
      o_value = i_default;
    ELSE;
      CLEAR o_value;
    ENDIF;
    log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
    log_msg = 'Error getting environment variable ('+ i_var +'). Setting value to: ' +
      o_value;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  ENDMON;

  RETURN o_value;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      CLEAR o_value;
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_GetEnvVarStr;

// -------------------------------------------------------------------------------------------------
///
// This procedure will get the HTTP Request from the web server.
//
// Note that if this procedure fails for any reason, it will attempt to return a response to the
// client - either a 415 Unsupported Media Type or a 500 Internal Server Error. This means the
// calling procedure does not need to send an HTTP Response if this procedure fails.
//
// @param REQUIRED. The HTTP Request Method for this request.
// @param REQUIRED. The body of this request.
// @param REQUIRED. The authentication token associated with this request.
// @param OPTIONAL. The URI being called.
// @param OPTIONAL. The query string associated with this request.
// @param OPTIONAL. The number of elements in o_env_var_array.
// @param OPTIONAL. An array of environment variables the caller wants values for.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the HTTP Request was retrieved successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_GetHTTPRequest EXPORT;
  DCL-PI WEB_GetHTTPRequest IND;
    o_method LIKE(tpl_sdk4i_web_method);
    o_body LIKE(tpl_sdk4i_varchar_1M_utf8);
    o_token LIKE(tpl_sdk4i_uuid);
    o_uri LIKE(tpl_sdk4i_web_uri) OPTIONS(*NOPASS: *OMIT);
    o_query_string LIKE(tpl_sdk4i_web_query_string) OPTIONS(*NOPASS: *OMIT);
    i_env_var_array_count PACKED(3: 0) OPTIONS(*NOPASS: *OMIT) CONST;
    o_env_var_array LIKEDS(tpl_sdk4i_web_env_var_ds) DIM(C_SDK4I_WEB_ENV_VAR_ARRAY_COUNT) OPTIONS(*NOPASS: *OMIT: *VARSIZE);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS error_ds LIKEDS(tpl_sdk4i_errc0100_ds);

  DCL-S available_length LIKE(tpl_sdk4i_binary4) INZ(0);
  DCL-S env_var_content_length LIKE(tpl_sdk4i_binary4);
  DCL-S env_var_content_type LIKE(tpl_sdk4i_web_env_var_string_value);
  DCL-S env_var_query_string LIKE(tpl_sdk4i_web_query_string);
  DCL-S env_var_remote_addr LIKE(tpl_sdk4i_web_env_var_string_value);
  DCL-S env_var_request_uri LIKE(tpl_sdk4i_web_uri);
  DCL-S temp_data POINTER INZ(*NULL);
  DCL-S temp_data2 CHAR(C_SDK4I_SIZE_2MI) CCSID(*UTF8);
  DCL-S temp_str LIKE(tpl_sdk4i_web_env_var_string_value);
  DCL-S x LIKE(i_env_var_array_count) INZ(1);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // Get the environment variables we require.
  o_method = WEB_GetEnvVarStr('REQUEST_METHOD': '*NONE');
  temp_str = WEB_GetEnvVarStr('HTTP_AUTHORIZATION');

  IF (%LEN(temp_str) > 8 AND 'BEARER ' = %UPPER(%SUBST(temp_str: 1: 7)));
    o_token = %SUBST(temp_str: 8);
  ENDIF;
  env_var_request_uri = WEB_GetEnvVarStr('REQUEST_URI': '*NONE');
  env_var_content_length = WEB_GetEnvVarInt('CONTENT_LENGTH');
  env_var_content_type = %LOWER(WEB_GetEnvVarStr('CONTENT_TYPE'));
  env_var_query_string = WEB_GetEnvVarStr('QUERY_STRING');
  env_var_remote_addr = %LOWER(WEB_GetEnvVarStr('REMOTE_ADDR'));

  // Log debugging information.
  log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
  log_msg = 'Token: ' + o_token;
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  log_msg = 'REQUEST_METHOD: ' + o_method;
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  log_msg = 'REQUEST_URI: ' + env_var_request_uri;
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  log_msg = 'CONTENT_TYPE: ' + env_var_content_type;
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  log_msg = 'CONTENT_LENGTH: ' + %TRIM(%EDITC(env_var_content_length: '1'));
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  log_msg = 'REMOTE_ADDR:' + env_var_remote_addr;
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  log_msg = '%PARMS = ' + %TRIM(%EDITC(%PARMS: '1'));
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  // If the caller wants the requested URI, give it to them.
  IF (%PARMS >= %PARMNUM(o_uri) AND %ADDR(o_uri) <> *NULL);
    o_uri = env_var_request_uri;
    log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
    log_msg = 'o_uri set to: ' + o_uri;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  ENDIF;

  // If the caller wants the query string, give it to them.
  IF (%PARMS >= %PARMNUM(o_query_string) AND %ADDR(o_query_string) <> *NULL);
    o_query_string = env_var_query_string;
    log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
    log_msg = 'o_query_string set to: ' + o_query_string;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  ENDIF;

  // If the caller wants environment variables (headers), provide them.
  IF (%PARMS >= %PARMNUM(o_env_var_array) AND %ADDR(o_env_var_array) <> *NULL);
    log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
    log_msg = 'Caller requested environment variables.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    FOR x = 1 TO i_env_var_array_count;
      IF (o_env_var_array(x).type = 'I');
        o_env_var_array(x).int_value = WEB_GetEnvVarInt(o_env_var_array(x).name);
      ELSE;
        o_env_var_array(x).string_value = WEB_GetEnvVarStr(o_env_var_array(x).name);
      ENDIF;
    ENDFOR;
  ENDIF;

  IF (env_var_content_length > 0);
    IF (%SCAN(%CHAR('application/json': *UTF8): env_var_content_type) > 0);
      MONITOR;
        temp_data = %ALLOC(env_var_content_length); // We DEALLOC temp_data in the ON-EXIT section.
      ON-ERROR 00425;
        log_event_info_ds.ll_id = C_SDK4I_LL_ERR;
        log_msg = '00425: failed to allocate '+ %TRIM(%EDITC(env_var_content_length: '1')) +' bytes to process HTTP Request. Request allocation size is out of range.';
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
        log_is_successful = *OFF;
        RETURN log_is_successful;
      ON-ERROR 00426;
        log_event_info_ds.ll_id = C_SDK4I_LL_ERR;
        log_msg = '00426: failed to allocate '+ %TRIM(%EDITC(env_var_content_length: '1')) +' bytes to process HTTP Request. Error occurred during memory allocation.';
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
        log_is_successful = *OFF;
        RETURN log_is_successful;
      ON-ERROR;
        log_event_info_ds.ll_id = C_SDK4I_LL_ERR;
        log_msg = 'Error allocating ' + %TRIM(%EDITC(env_var_content_length: '1')) +
          ' bytes of heap storage.';
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
        log_is_successful = *OFF;
        RETURN log_is_successful;
      ENDMON;
    ELSE;
      log_event_info_ds.ll_id = C_SDK4I_LL_ERR;
      log_msg = 'The content type ('+ env_var_content_type + ') sent from ' +
        env_var_remote_addr + ' is not supported.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      WEB_SendHTTP415Response();
      log_is_successful = *OFF;
      RETURN log_is_successful;
    ENDIF;
  ENDIF;

  // The client says they sent data we understand and we have successfully allocated memory to hold
  // that data - so now we will read it from STDIN (Standard Input).
  // QtmhRdStin(temp_data: env_var_content_length: available_length: error_ds);
  QtmhRdStin2(temp_data2: %LEN(temp_data2): available_length: error_ds);
  IF (error_ds.bytes_available > 0);
    log_event_info_ds.ll_id = C_SDK4I_LL_ERR;
    log_msg = 'QtmhRdStin failed ('+ error_ds.exception_id +'): ' +
      error_ds.exception_data;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    WEB_SendHTTP500Response();
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;
  IF (temp_data <> *NULL AND available_length > 0);
    o_body = %TRIM(temp_data2);
  ENDIF;

  // Log some debug information.
  log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
  log_msg = 'Bytes read from STDIN (available_length): ' + %TRIM(%EDITC(available_length: '1'));
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  RETURN log_is_successful;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    DEALLOC(N) temp_data; // DO NOT MOVE THIS LINE OUTSIDE OF THIS ON-EXIT SECTION.
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_GetHTTPRequest;

// -------------------------------------------------------------------------------------------------
///
// This procedure will send an HTTP Response back to a client. HTTP Responses have the following
// components:
//
// 1) Status line (REQUIRED) - the protocol version (like HTTP/1.1), a status code (like 404), and
//   status text like Not Found.
// 2) Headers (REQUIRED) - the sdk4i WEB service program will allow you to return up to
//   C_SDK4I_WEB_HEADER_ARRAY_COUNT headers.
// 3) Body (OPTIONAL) - the sdk4i WEB service program will either send a JSON string in the body
//   (for a successful GET request for example) or nothing (for a successful DELETE request for
//   example).
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages
//
// @param REQUIRED. This is an HTTP Status Code like 200 OK or 404 Not Found. Use the constants
//   defined in the QCPYSRC/HTTPSTSK.RPGLEINC member.
// @param OPTIONAL. This is the length of the payload.
// @param OPTIONAL. This is the payload to return to the caller. No payload is allowed for a status
//   code of 204 (No Content) but all other statuses can have a payload. This is the *DATA part of a
//   VARCHAR CCSID(*UTF8) or CLOB variable.
// @param OPTIONAL. This is the type of data in the payload such as json, html, etc. This parameter
//   is used to define the Content-Type returned to the caller and will default to json which sends
//   Content-Type: application/json.
// @param OPTIONAL. If you want to send additional headers, this is a count of elements in the
//   following i_header_ds_array.
// @param OPTIONAL. If you want to send additional headers, you can add tpl_http_header_ds data
//   structures to this array.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTPResponse EXPORT;
  DCL-PI WEB_SendHTTPResponse IND;
    i_status_code VARCHAR(50) CONST; // 200 OK, etc. See QCPYSRC/HTTPSTSK.RPGLEINC.
    i_payload_length LIKE(tpl_sdk4i_binary4) OPTIONS(*NOPASS: *OMIT) CONST; // length of i_payload
    i_payload POINTER OPTIONS(*NOPASS: *OMIT) CONST; // The *DATA part of a VARCHAR or xLOB.
    i_payload_type VARCHAR(50) OPTIONS(*NOPASS: *OMIT) CONST; // json (default), html, etc.
    i_header_ds_array_count PACKED(2: 0) OPTIONS(*NOPASS: *OMIT) CONST;
    i_header_ds_array LIKEDS(tpl_sdk4i_web_http_header_ds) DIM(C_SDK4I_WEB_HEADER_ARRAY_COUNT)
      OPTIONS(*NOPASS: *OMIT: *VARSIZE) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS error_ds LIKEDS(tpl_sdk4i_errc0100_ds);
  DCL-S header VARCHAR(500); // Use native CCSID (job CCSID), not UTF-8 for the header.
  DCL-S x LIKE(i_header_ds_array_count) INZ(0);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // Make sure we were given a status code.
  IF (%LEN(i_status_code) = 0);
    log_event_info_ds.ll_id = C_SDK4I_LL_ERR;
    log_msg = 'No HTTP Status Code was provided.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
  log_msg = 'Status code: ' + i_status_code;
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  // Write out the headers.
  header = 'status: ' + i_status_code + C_SDK4I_EBCDIC_CRLF;

  IF (%PARMS >= %PARMNUM(i_header_ds_array) AND %ADDR(i_header_ds_array) <> *NULL);
    FOR x=1 TO i_header_ds_array_count;
      header += i_header_ds_array(x).key + ': ' + i_header_ds_array(x).val + C_SDK4I_EBCDIC_CRLF;
    ENDFOR;
  ENDIF;

  SELECT;
    WHEN (%PARMS >= %PARMNUM(i_payload_type) AND %ADDR(i_payload_type) <> *NULL);
      SELECT;
        WHEN (%LOWER(i_payload_type) = 'json');
          header += 'Content-Type: application/json';
        WHEN (%LOWER(i_payload_type) = 'text_html');
          header += 'Content-Type: text/html;charset=utf-8';
        WHEN (%LOWER(i_payload_type) = 'text_plain');
          header += 'Content-Type: text/plain;charset=utf-8';
        OTHER;
          header += 'Content-Type: application/octet-stream';
      ENDSL;
    OTHER;
      header += 'Content-Type: application/json';
  ENDSL;
  header += C_SDK4I_EBCDIC_CRLF + C_SDK4I_EBCDIC_CRLF;
  QtmhWrStout(%ADDR(header: *DATA): %LEN(header): error_ds);
  IF (error_ds.bytes_available > 0);
    log_event_info_ds.ll_id = C_SDK4I_LL_ALT;
    log_msg = 'QtmhWrStout failed when writing headers ('+ error_ds.exception_id +'): ' + error_ds.exception_data;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // Write out a payload if there is one.
  RESET error_ds;
  IF (%PARMS >= %PARMNUM(i_payload) AND %PARMS >= %PARMNUM(i_payload_length) AND
      %ADDR(i_payload) <> *NULL AND %ADDR(i_payload_length) <> *NULL AND i_payload_length > 0);
    QtmhWrStout(i_payload: i_payload_length: error_ds);
    IF (error_ds.bytes_available > 0);
      log_event_info_ds.ll_id = C_SDK4I_LL_ALT;
      log_msg = 'QtmhWrStout failed when writing payload (' + error_ds.exception_id +'): ' + error_ds.exception_data;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      log_is_successful = *OFF;
      RETURN log_is_successful;
    ENDIF;
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
END-PROC WEB_SendHTTPResponse;

// -------------------------------------------------------------------------------------------------
///
// This procedure will send an HTTP 200 OK response.
//
// 200 OK indicates success.
//
// @param OPTIONAL. The length of i_payload in bytes. (Use the %LEN BIF)
// @param OPTIONAL. The information, such as an error or warning message, to be sent back to the
//   caller.
// @param OPTIONAL. The payload type being returned to the caller. Defaults to application/json.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP200Response EXPORT;
  DCL-PI WEB_SendHTTP200Response IND;
    i_payload_length LIKE(tpl_sdk4i_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_payload POINTER OPTIONS(*NOPASS: *OMIT) CONST; // The *DATA part of a VARCHAR.
    i_payload_type LIKE(tpl_sdk4i_web_header_val) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S payload_length LIKE(i_payload_length) INZ(0);
  DCL-S payload_type LIKE(i_payload_type) INZ('json');

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // We default to sending a payload length of 0 but the caller can send something else.
  IF (%PARMS >= %PARMNUM(i_payload_length) AND %ADDR(i_payload_length) <> *NULL);
    payload_length = i_payload_length;
  ENDIF;

  // We default to sending JSON payloads but the caller can send something else if they want.
  IF (%PARMS >= %PARMNUM(i_payload_type) AND %ADDR(i_payload_type) <> *NULL);
    payload_type = i_payload_type;
  ENDIF;

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_200_OK: i_payload_length: i_payload: payload_type: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP200Response;

// -------------------------------------------------------------------------------------------------
///
// This procedure will send an HTTP 201 Created response.
//
// 201 Created indicates the request succeeded and a new resource was created.
//
// @param OPTIONAL. The URI where the new resource can be found.
// @param OPTIONAL. The length of i_payload in bytes. (Use the %LEN BIF)
// @param OPTIONAL. The information, such as an error or warning message, to be sent back to the
//   caller.
// @param OPTIONAL. The payload type being returned to the caller. Defaults to application/json.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/201
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP201Response EXPORT;
  DCL-PI WEB_SendHTTP201Response IND;
    i_location LIKE(tpl_sdk4i_web_header_val) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_payload_length LIKE(tpl_sdk4i_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_payload POINTER OPTIONS(*NOPASS: *OMIT) CONST; // The *DATA part of a VARCHAR.
    i_payload_type LIKE(tpl_sdk4i_web_header_val) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS header_ds LIKEDS(tpl_sdk4i_web_http_header_ds);
  DCL-DS header_ds_array LIKEDS(tpl_sdk4i_web_http_header_ds) DIM(*AUTO: C_SDK4I_WEB_HEADER_ARRAY_COUNT);

  DCL-S payload_length LIKE(i_payload_length) INZ(0);
  DCL-S payload_type LIKE(i_payload_type) INZ('json');

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  IF (%PARMS >= %PARMNUM(i_location) AND %ADDR(i_location) <> *NULL);
    header_ds.key = 'Location';
    header_ds.val = i_location;
    header_ds_array(*NEXT) = header_ds;
  ENDIF;

  // We default to sending a payload length of 0 but the caller can send something else.
  IF (%PARMS >= %PARMNUM(i_payload_length) AND %ADDR(i_payload_length) <> *NULL);
    payload_length = i_payload_length;
  ENDIF;

  // We default to sending JSON payloads but the caller can send something else if they want.
  IF (%PARMS >= %PARMNUM(i_payload_type) AND %ADDR(i_payload_type) <> *NULL);
    payload_type = i_payload_type;
  ENDIF;

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_201_CREATED: i_payload_length: i_payload: payload_type:
    %ELEM(header_ds_array): header_ds_array: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP201Response;

// -------------------------------------------------------------------------------------------------
///
// This procedure will send an HTTP 204 No Content response. This means the Request was processed
// successfully.
//
// 204 No Content indicates the request succeeded and this response has no content, only headers.
//
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/204
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP204Response EXPORT;
  DCL-PI WEB_SendHTTP204Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_204_NO_CONTENT: 0: *NULL: *OMIT: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP204Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 400.
//
// This procedure will send an HTTP 400 Bad Request response. An example of when this response
// might be sent is if the caller provides invalid or incomplete data in a POST or PUT request.
//
// @param OPTIONAL. The length of i_payload in bytes. (Use the %LEN BIF)
// @param OPTIONAL. The information, such as an error or warning message, to be sent back to the
//   caller.
// @param OPTIONAL. The payload type being returned to the caller. Defaults to application/json.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/400
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP400Response EXPORT;
  DCL-PI WEB_SendHTTP400Response IND;
    i_payload_length LIKE(tpl_sdk4i_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_payload POINTER OPTIONS(*NOPASS: *OMIT) CONST; // The *DATA part of a VARCHAR.
    i_payload_type LIKE(tpl_sdk4i_web_header_val) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S payload_length LIKE(i_payload_length) INZ(0);
  DCL-S payload_type LIKE(i_payload_type) INZ('json');

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // We default to sending a payload length of 0 but the caller can send something else.
  IF (%PARMS >= %PARMNUM(i_payload_length) AND %ADDR(i_payload_length) <> *NULL);
    payload_length = i_payload_length;
  ENDIF;

  // We default to sending JSON payloads but the caller can send something else if they want.
  IF (%PARMS >= %PARMNUM(i_payload_type) AND %ADDR(i_payload_type) <> *NULL);
    payload_type = i_payload_type;
  ENDIF;

  // Log debugging information
  log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
  log_msg = 'payload_length: ' + %TRIM(%EDITC(payload_length: '1'));
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
  log_msg = 'payload_type: ' + payload_type;
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_400_BAD_REQUEST: i_payload_length: i_payload:
    payload_type: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP400Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 401.
//
// This procedure will send an HTTP 401 Unauthorized response. This means the client is not
// currently authenticated or the authentication token provided is invalid.
//
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP401Response EXPORT;
  DCL-PI WEB_SendHTTP401Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_401_UNAUTHORIZED: 0: *NULL: *OMIT: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP401Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 403.
//
// This procedure will send an HTTP 403 Forbidden response. This means the user is not authorized
// to perform the requested procedure.
//
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/403
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP403Response EXPORT;
  DCL-PI WEB_SendHTTP403Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_403_FORBIDDEN: 0: *NULL: *OMIT: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP403Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 404.
//
// This procedure will send an HTTP 404 Not Found response. An example of when this response might
// be sent is if the caller attempts to delete or update a resource that does not exist.
//
// @param OPTIONAL. The length of i_payload in bytes. (Use the %LEN BIF)
// @param OPTIONAL. The information, such as an error or warning message, to be sent back to the
//   caller.
// @param OPTIONAL. The payload type being returned to the caller. Defaults to application/json.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP404Response EXPORT;
  DCL-PI WEB_SendHTTP404Response IND;
    i_payload_length LIKE(tpl_sdk4i_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_payload POINTER OPTIONS(*NOPASS: *OMIT) CONST; // The *DATA part of a VARCHAR.
    i_payload_type LIKE(tpl_sdk4i_web_header_val) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S payload_length LIKE(i_payload_length);
  DCL-S payload_type LIKE(i_payload_type) INZ('json');

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // We default to sending a payload length of 0 but the caller can send something else.
  IF (%PARMS >= %PARMNUM(i_payload_length) AND %ADDR(i_payload_length) <> *NULL);
    payload_length = i_payload_length;
  ENDIF;

  // We default to sending JSON payloads but the caller can send something else if they want.
  IF (%PARMS >= %PARMNUM(i_payload_type) AND %ADDR(i_payload_type) <> *NULL);
    payload_type = i_payload_type;
  ENDIF;

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_404_NOT_FOUND: i_payload_length: i_payload :
    payload_type: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP404Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 405.
//
// This procedure will send an HTTP 405 Method Not Allowed response. The client has sent an HTTP
// Request Method that is not allowed.
//
// @param REQUIRED. The Request Method(s) supported by the web service - this is a comma delimited
//   list of methods like: DELETE, GET, POST
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/405
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages#http_responses
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP405Response EXPORT;
  DCL-PI WEB_SendHTTP405Response IND;
    i_allow LIKE(tpl_sdk4i_web_header_val) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS header_ds LIKEDS(tpl_sdk4i_web_http_header_ds);
  DCL-DS header_ds_array LIKEDS(tpl_sdk4i_web_http_header_ds)
    DIM(*AUTO: C_SDK4I_WEB_HEADER_ARRAY_COUNT);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  header_ds.key = 'Allow';
  header_ds.val = i_allow;

  header_ds_array(*NEXT) = header_ds;

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_405_METHOD_NOT_ALLOWED: 0: *NULL: *OMIT :
    %ELEM(header_ds_array): header_ds_array: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP405Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 409.
//
// This procedure will send an HTTP 409 Conflict response. This is usually triggered by a caller
// attempting to create a resource that would violate a uniqueness constraint in a table.
//
// @param OPTIONAL. The length of i_payload in bytes. (Use the %LEN BIF)
// @param OPTIONAL. The information, such as an error or warning message, to be sent back to the
//   caller.
// @param OPTIONAL. The payload type being returned to the caller. Defaults to application/json.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/409
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP409Response EXPORT;
  DCL-PI WEB_SendHTTP409Response IND;
    i_payload_length LIKE(tpl_sdk4i_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_payload POINTER OPTIONS(*NOPASS: *OMIT) CONST; // The *DATA part of a VARCHAR or CLOB.
    i_payload_type LIKE(tpl_sdk4i_web_header_val) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S payload_length LIKE(i_payload_length) INZ(0);
  DCL-S payload_type LIKE(i_payload_type) INZ('json');

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // We default to sending a payload length of 0 but the caller can send something else.
  IF (%PARMS >= %PARMNUM(i_payload_length) AND %ADDR(i_payload_length) <> *NULL);
    payload_length = i_payload_length;
  ENDIF;

  // We default to sending JSON payloads but the caller can send something else if they want.
  IF (%PARMS >= %PARMNUM(i_payload_type) AND %ADDR(i_payload_type) <> *NULL);
    payload_type = i_payload_type;
  ENDIF;

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_409_CONFLICT: i_payload_length: i_payload:
    payload_type: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP409Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 415.
//
// This procedure will send an HTTP 415 Unsupported Media Type response. The client has sent a
// Request using a media type our web service does not support - for example, they sent a header
// indicating the associated data is application/xml but we only support application/json.
//
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/415
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP415Response EXPORT;
  DCL-PI WEB_SendHTTP415Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_415_UNSUPPORTED_MEDIA_TYPE: 0: *NULL: *OMIT: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP415Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 500.
//
// This procedure will send an HTTP 500 Internal Server Error response. This means something went
// wrong in our code or on the IBM i itself, there is nothing the client can do to fix it.
//
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
//
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/500
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP500Response EXPORT;
  DCL-PI WEB_SendHTTP500Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_500_INTERNAL_SERVER_ERROR: 0: *NULL: *OMIT: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP500Response;

// -------------------------------------------------------------------------------------------------
///
// Send response code 550.
//
// This procedure will send an HTTP 550 Web Service Error response. This means something went
// wrong in OUR code, there is nothing the client can do to fix it.
//
// @param OPTIONAL. The length of i_payload in bytes. (Use the %LEN BIF)
// @param OPTIONAL. The information, such as an error or warning message, to be sent back to the
//   caller.
// @param OPTIONAL. The payload type being returned to the caller. Defaults to application/json.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the response was sent successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP550Response EXPORT;
  DCL-PI WEB_SendHTTP550Response IND;
    i_payload_length LIKE(tpl_sdk4i_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_payload POINTER OPTIONS(*NOPASS: *OMIT) CONST; // The *DATA part of a VARCHAR.
    i_payload_type LIKE(tpl_sdk4i_web_header_val) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S payload_length LIKE(i_payload_length);
  DCL-S payload_type LIKE(i_payload_type) INZ('json');

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // We default to sending a payload length of 0 but the caller can send something else.
  IF (%PARMS >= %PARMNUM(i_payload_length) AND %ADDR(i_payload_length) <> *NULL);
    payload_length = i_payload_length;
  ENDIF;

  // We default to sending JSON payloads but the caller can send something else if they want.
  IF (%PARMS >= %PARMNUM(i_payload_type) AND %ADDR(i_payload_type) <> *NULL);
    payload_type = i_payload_type;
  ENDIF;

  RETURN WEB_SendHTTPResponse(C_SDK4I_HTTP_550_WEB_SERVICE_ERROR: i_payload_length: i_payload :
    payload_type: *OMIT: *OMIT: log_user_info_ds);

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP550Response;