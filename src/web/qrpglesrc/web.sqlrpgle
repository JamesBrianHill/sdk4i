**FREE
// -------------------------------------------------------------------------------------------------
//   This service program provides utilities for calling remote web services and processing locally
// hosted web services.
//
//   Note that this service program uses the *TERASPACE storage model. It is not uncommon to work
// with data large enough it surpasses the 16MB limit inherent in the *SNGLVL storage model. If you
// are unfamiliar with using the *TERASPACE storage model, you should read more about it in the
// official documentation:
// https://www.ibm.com/docs/en/i/7.6.0?topic=procedures-storage-model
//
//   In particular, you will want to be aware of the potential problems of mixing Single Level and
// Teraspace programs and service programs within the same activation group. You can read more about
// that here:
// https://www.ibm.com/docs/en/i/7.6.0?topic=model-recommendations-storage-programs-service-programs
//
//   It is recommended that all programs that use this WEB service program use a named activation
// group and use ALLOC(*TERASPACE). For example:
// CTL-OPT ACTGRP(MyTSGroup);
// CTL-OPT ALLOC(*TERASPACE);
//
// Or, if you must use the default activation groups:
// CTL-OPT ACTGRP(*STGMDL);
// CTL-OPT ALLOC(*TERASPACE);
//
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
// @link https://www.ibm.com/docs/en/i/7.6.0?topic=concepts-teraspace-single-level-storage
// @link https://www.ibm.com/docs/en/i/7.6.0?topic=keywords-allocstgmdl-teraspace-snglvl
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/ctloptspk.rpgleinc'
CTL-OPT ALLOC(*TERASPACE);
CTL-OPT TEXT('SDK4i - WEB - Web service utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// ERRK - ERR constants, data structures, variables, and procedure definitions.
// IBMAPIK - constants, data structures, variables, and procedure definitions for IBM APIs.
// LOGK - LOG constants, data structures, variables, and procedure definitions.
// NILK - NIL constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// TXTK - TXT constants, data structures, variables, and procedure definitions.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/errk.rpgleinc'
/COPY '../../qcpysrc/ibmapik.rpgleinc'
/COPY '../../qcpysrc/logk.rpgleinc'
/COPY '../../qcpysrc/nilk.rpgleinc'
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
// WEB_CallWebService
//
//   This procedure will call a web service using the indicated method (GET, POST, etc.). The
// i_http_options parameter is probably the string you got back from the BuildHTTPOptions
// procedure.
//
//   By default we use the VERBOSE version of the HTTP functions: HTTP_GET_VERBOSE,
// HTTP_POST_VERBOSE, etc. We allow you to pass a parameter (i_verbose) with a value of 'N' if you
// do NOT want to use the VERBOSE version of the HTTP function. When using the non VERBOSE version
// of the function, we do not receive any information back from the web service regarding success or
// failure.
//
// Security note:
//   The user calling this procedure must have at least *USE authority to the QSYS/QSQAXISC service
// program.
//
// Parameters:
// @param REQUIRED. Db2 for i currently supports the DELETE, GET, PATCH, POST, and PUT methods.
// @param REQUIRED. The URL to be called.
// @param REQUIRED. The length of data pointed to by i_http_options.
// @param REQUIRED. A POINTER to an HTTP options JSON string with headers, SSL and proxy options, etc.
// @param REQUIRED. A variable to hold the HTTP Response Status received from calling the API.
// @param REQUIRED. The length of data pointed to by o_rsp_headers. When calling this procedure you
// should send the maximum size io_rsp_headers will allow. When this procedure returns to the caller
// this parameter will hold the length of data put into o_rsp_headers.
// @param REQUIRED. A POINTER to a variable to hold response headers (a JSON string).
// @param REQUIRED. The length of data pointed to by o_rsp_payload. When calling this procedure you
// should send the maximum size io_rsp_payload will allow. When this procedure returns to the caller
// this parameter will hold the length of data put into o_rsp_payload.
// @param REQUIRED. A POINTER to a variable to hold a response payload (a JSON string). This can be
// empty if the web service does not return a body in the response which is valid behavior for
// certain methods.
// @param OPTIONAL. The length of data pointed to by i_req_payload.
// @param OPTIONAL. A POINTER to a variable containing the payload to be sent with the call to the
// web service. Some methods do not require a request body which is why this parameter is optional.
// @param OPTIONAL. A Y indicates we should use the BLOB version of the HTTP function. Defaults to N
// @param OPTIONAL. A N indicates we should use the non-VERBOSE version of the requested HTTP
// function. By default, we use the VERBOSE versions.
// @return *ON if the procedure successfully called the web service, *OFF otherwise. NOTE that just
// because we successfully called a web service does not mean the service itself was successful -
// it might have returned an error code. Please check o_rsp_code to see the HTTP Status Code
// returned by the web service to determine if it was successful or not.
//
// References:
// @link https://www.ibm.com/docs/en/i/7.6.0?topic=programming-http-functions-overview
// @link https://www.ibm.com/docs/en/i/7.6.0?topic=dlhviiratus-lob-host-variables-in-ile-rpg-applications-that-use-sql
// @link https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_CallWebService EXPORT;
  DCL-PI WEB_CallWebService IND;
    i_method LIKE(tpl_sdk4i_web_method) CONST;
    i_url LIKE(tpl_sdk4i_web_uri) CONST;
    i_http_options_length LIKE(tpl_sdk4i_ibm_len) CONST;
    i_http_options POINTER VALUE; // UTF-8
    o_rsp_code LIKE(tpl_sdk4i_web_http_status_code);
    io_rsp_headers_length LIKE(tpl_sdk4i_ibm_len);
    o_rsp_headers POINTER VALUE; // UTF-8
    io_rsp_payload_length LIKE(tpl_sdk4i_ibm_len);
    o_rsp_payload POINTER VALUE; // UTF-8
    i_req_payload_length LIKE(tpl_sdk4i_ibm_len) OPTIONS(*NOPASS) CONST;
    i_req_payload POINTER VALUE OPTIONS(*NOPASS); // UTF-8
    i_blob CHAR(1) OPTIONS(*NOPASS) CONST;
    i_verbose CHAR(1) OPTIONS(*NOPASS) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS logwbrt_ds LIKEDS(tpl_sdk4i_logwbrt_ds) INZ(*LIKEDS);
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S blob LIKE(i_blob) INZ('N');
  DCL-S local_http_options SQLTYPE(CLOB: 4096) CCSID(*UTF8); // Can be up to 2G.
  DCL-S local_req_blob_payload SQLTYPE(BLOB: 8192); // Can be up to 2G.
  DCL-S local_req_clob_payload SQLTYPE(CLOB: 8192) CCSID(*UTF8); // Can be up to 2G.
  DCL-S local_rsp_headers SQLTYPE(CLOB: 4096) CCSID(*UTF8); // Can be up to 2G.
  DCL-S local_rsp_blob SQLTYPE(BLOB: 1048576); // Can be up to 2G.
  DCL-S local_rsp_clob SQLTYPE(CLOB: 1048576) CCSID(*UTF8); // Can be up to 2G.
  DCL-S verbose LIKE(i_verbose) INZ('Y');

  DCL-S local_rsp_blob_null LIKE(tpl_sdk4i_nil_null_int) INZ(C_SDK4I_NOT_NULL);
  DCL-S local_rsp_clob_null LIKE(tpl_sdk4i_nil_null_int) INZ(C_SDK4I_NOT_NULL);
  DCL-S local_rsp_headers_null LIKE(tpl_sdk4i_nil_null_int) INZ(C_SDK4I_NOT_NULL);
  DCL-S o_rsp_code_null LIKE(tpl_sdk4i_nil_null_int) INZ(C_SDK4I_NOT_NULL);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  // Make sure we received the required parameters and they are valid.
  IF (i_url = *BLANKS);
    log_is_successful = *OFF;
    log_msg = 'i_url is blank, aborting.';
    LOG_LogMsg(psds_ds: log_proc: log_msg);
    RETURN log_is_successful;
  ENDIF;

  IF (i_http_options_length <= 0 OR i_http_options = *NULL);
    log_is_successful = *OFF;
    log_msg = 'i_http_options is blank, aborting.';
    LOG_LogMsg(psds_ds: log_proc: log_msg);
    RETURN log_is_successful;
  ENDIF;

  // We CLEAR these so that later we can use %TRIM on them.
  CLEAR local_http_options_data;
  CLEAR local_req_blob_payload_data;
  CLEAR local_req_clob_payload_data;
  CLEAR local_rsp_blob_data;
  CLEAR local_rsp_clob_data;
  CLEAR local_rsp_headers_data;

  IBM_CopyMemory(%ADDR(local_http_options_data): i_http_options: i_http_options_length);
  local_http_options_len = i_http_options_length;

  IF ((i_method = 'PATCH' OR i_method = 'POST' OR i_method = 'PUT') AND
    (%PARMS < %PARMNUM(i_req_payload) OR i_req_payload = *NULL OR i_req_payload_length = 0));
    log_is_successful = *OFF;
    log_msg = 'i_method is PATCH, POST, or PUT but no request payload was provided. Aborting.';
    LOG_LogMsg(psds_ds: log_proc: log_msg);
    RETURN log_is_successful;
  ENDIF;

  //   By default, we use the non-BLOB HTTP functions. The caller can tell us to use BLOB by passing
  // a Y in the i_blob parameter.
  IF (%PARMS >= %PARMNUM(i_blob) AND %ADDR(i_blob) <> *NULL AND %UPPER(i_blob) = 'Y');
    blob = 'Y';
  ENDIF;

  //   By default, we use the VERBOSE HTTP functions. The caller can tell us to use the non-VERBOSE
  // functions by passing an N in the i_verbose parameter.
  IF (%PARMS >= %PARMNUM(i_verbose) AND %ADDR(i_verbose) <> *NULL AND %UPPER(i_verbose) = 'N');
    verbose = 'N';
  ENDIF;

  //   If the caller is providing a Request Payload, copy it to our local variable.
  IF (%PARMS >= %PARMNUM(i_req_payload) AND i_req_payload <> *NULL AND i_req_payload_length > 0);
    IF (blob = 'N');
      IBM_CopyMemory(%ADDR(local_req_clob_payload_data): i_req_payload: i_req_payload_length);
      local_req_clob_payload_len = i_req_payload_length;
    ELSE;
      IBM_CopyMemory(%ADDR(local_req_blob_payload_data): i_req_payload: i_req_payload_length);
      local_req_blob_payload_len = i_req_payload_length;
    ENDIF;
  ENDIF;

  // Initialize our return parameters.
  CLEAR o_rsp_code;

  //   Micro-optimization: the order in which the WHEN options are defined below is in order of
  // most commonly used to least commonly used HTTP methods for restful web services. GET, POST,
  // PUT, DELETE, PATCH, HEAD, OPTIONS, CONNECT, and TRACE.
  SELECT;
      // --------------------------------------------------
      // GET functions.
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'GET' AND blob = 'N' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_clob :local_rsp_clob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_get_verbose (
            :i_url,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'GET' AND blob = 'Y' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_blob :local_rsp_blob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_get_blob_verbose (
            :i_url,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'GET' AND blob = 'N' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_get(
          :i_url,
          :local_http_options
        )
        INTO :local_rsp_clob :local_rsp_clob_null;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'GET' AND blob = 'Y' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_get_blob(
          :i_url,
          :local_http_options
        )
        INTO :local_rsp_blob :local_rsp_blob_null;
      // --------------------------------------------------

      // --------------------------------------------------
      // POST functions.
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'POST' AND blob = 'N' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_clob :local_rsp_clob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_post_verbose (
            :i_url,
            :local_req_clob_payload,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'POST' AND blob = 'Y' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_blob :local_rsp_blob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_post_blob_verbose (
            :i_url,
            :local_req_blob_payload,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'POST' AND blob = 'N' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_post(
          :i_url,
          :local_req_clob_payload,
          :local_http_options
        )
        INTO :local_rsp_clob :local_rsp_clob_null;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'POST' AND blob = 'Y' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_post_blob(
          :i_url,
          :local_req_blob_payload,
          :local_http_options
        )
        INTO :local_rsp_blob :local_rsp_blob_null;
      // --------------------------------------------------

      // --------------------------------------------------
      // PUT functions.
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'PUT' AND blob = 'N' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_clob :local_rsp_clob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_put_verbose (
            :i_url,
            :local_req_clob_payload,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'PUT' AND blob = 'Y' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_blob :local_rsp_blob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_put_blob_verbose (
            :i_url,
            :local_req_blob_payload,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'PUT' AND blob = 'N' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_put(
          :i_url,
          :local_req_clob_payload,
          :local_http_options
        )
        INTO :local_rsp_clob :local_rsp_clob_null;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'PUT' AND blob = 'Y' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_put_blob(
          :i_url,
          :local_req_blob_payload,
          :local_http_options
        )
        INTO :local_rsp_blob :local_rsp_blob_null;
      // --------------------------------------------------

      // --------------------------------------------------
      // DELETE functions.
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'DELETE' AND blob = 'N' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_clob :local_rsp_clob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_delete_verbose (
            :i_url,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'DELETE' AND blob = 'Y' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_blob :local_rsp_blob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_delete_blob_verbose (
            :i_url,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'DELETE' AND blob = 'N' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_delete(
          :i_url,
          :local_http_options
        )
        INTO :local_rsp_clob :local_rsp_clob_null;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'DELETE' AND blob = 'Y' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_delete_blob(
          :i_url,
          :local_http_options
        )
        INTO :local_rsp_blob :local_rsp_blob_null;
      // --------------------------------------------------

      // --------------------------------------------------
      // PATCH functions.
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'PATCH' AND blob = 'N' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_clob :local_rsp_clob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_patch_verbose (
            :i_url,
            :local_req_clob_payload,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'PATCH' AND blob = 'Y' AND verbose = 'Y');
      EXEC SQL
        SELECT response_message, response_http_header
        INTO :local_rsp_blob :local_rsp_blob_null, :local_rsp_headers :local_rsp_headers_null
        FROM TABLE (
          qsys2.http_patch_blob_verbose (
            :i_url,
            :local_req_blob_payload,
            :local_http_options
          )
        ) AS x;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'PATCH' AND blob = 'N' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_patch(
          :i_url,
          :local_req_clob_payload,
          :local_http_options
        )
        INTO :local_rsp_clob :local_rsp_clob_null;
      // --------------------------------------------------
    WHEN (%UPPER(i_method) = 'PATCH' AND blob = 'Y' AND verbose = 'N');
      EXEC SQL
        VALUES qsys2.http_patch_blob(
          :i_url,
          :local_req_blob_payload,
          :local_http_options
        )
        INTO :local_rsp_blob :local_rsp_blob_null;
      // --------------------------------------------------

    OTHER; // We were given an invalid method.
      log_is_successful = *OFF;
      log_msg = 'The method requested ('+ i_method +') is invalid.';
      LOG_LogMsg(psds_ds: log_proc: log_msg);
      RETURN log_is_successful;
  ENDSL;

  // See if we encountered an error while executing the above SQL statement. If so, log some
  // information and leave this procedure.
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_msg = 'Error executing HTTP function. i_method = '+ i_method + ', i_url = '+ i_url +
      ', i_http_options = '+ %TRIM(local_http_options_data) + ', i_req_payload = '+
      %TRIM(local_req_clob_payload_data) + ', blob = '+ blob +', verbose = '+ verbose +'. err_msg = '+
      s_diagnostics_ds.err_msg;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds);
    RETURN log_is_successful;
  ENDIF;

  //   If we made it here, the call to the web service completed normally. That does NOT mean the
  // web service was successful, only that we called it successfully. Grab the HTTP Status Code to
  // see if the web service was successful.
  IF (verbose = 'Y');
    EXEC SQL
      SELECT http_status_code
      INTO :o_rsp_code :o_rsp_code_null
      FROM JSON_TABLE(
        :local_rsp_headers,
        'strict $'
        COLUMNS(
          http_status_code DECIMAL(3,0) PATH '$.HTTP_STATUS_CODE' DEFAULT 0 ON EMPTY
        )
      ) AS x;
    IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
      log_msg = 'Error parsing response headers to obtain HTTP Status Code: '+
        s_diagnostics_ds.err_msg +'. local_rsp_headers = '+ %TRIM(local_rsp_headers);
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds);
    ENDIF;

    // Copy response header data back to the caller.
    local_rsp_headers_len = %LEN(%TRIM(local_rsp_headers_data));
    io_rsp_headers_length = %MIN(io_rsp_headers_length: local_rsp_headers_len);
    IBM_CopyMemory(o_rsp_headers: %ADDR(local_rsp_headers_data): io_rsp_headers_length);
  ELSE;
    io_rsp_headers_length = 0;
  ENDIF;

  // Copy response payload data back to the caller.
  IF (blob = 'N');
    IF (local_rsp_clob_null = C_SDK4I_NOT_NULL AND local_rsp_clob_len > 0);
      local_rsp_clob_len = %LEN(%TRIM(local_rsp_clob_data));
      io_rsp_payload_length = %MIN(io_rsp_payload_length: local_rsp_clob_len);
      IBM_CopyMemory(o_rsp_payload: %ADDR(local_rsp_clob_data): io_rsp_payload_length);
    ENDIF;
  ELSE;
    IF (local_rsp_blob_null = C_SDK4I_NOT_NULL AND local_rsp_blob_len > 0);
      local_rsp_blob_len = %LEN(%TRIM(local_rsp_blob_data));
      io_rsp_payload_length = %MIN(io_rsp_payload_length: local_rsp_blob_len);
      IBM_CopyMemory(o_rsp_payload: %ADDR(local_rsp_blob_data): io_rsp_payload_length);
    ENDIF;
  ENDIF;

  // Capture information related to the call to the remote web service so we can log it.
  logwbrt_ds.req_url = i_url;
  logwbrt_ds.req_method = i_method;
  logwbrt_ds.req_opt = %TRIM(local_http_options_data);
  IF (%PARMS >= %PARMNUM(i_req_payload) AND %ADDR(i_req_payload) <> *NULL AND blob = 'N');
    logwbrt_ds.req_body = %TRIM(local_req_clob_payload_data);
    %NULLIND(logwbrt_ds.req_body) = *OFF;
  ENDIF;
  logwbrt_ds.rsp_code = o_rsp_code;
  logwbrt_ds.rsp_head = %TRIM(local_rsp_headers_data);
  IF (blob = 'N');
    logwbrt_ds.rsp_body = %TRIM(local_rsp_clob_data);
  ENDIF;

  // Log an informational message.
  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'A web service was called. If you have configured SDK4i to do so (check LOGCFGT), information was logged to LOGWBRT.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds: *OMIT: logwbrt_ds);
  RESET log_event_info_ds;

  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    IF (log_is_abend); // Log a message if we end abnormally.
      log_is_successful = *OFF;
      log_msg = 'Procedure '+ log_proc +' ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds:log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_CallWebService;

// -------------------------------------------------------------------------------------------------
///
// WEB_EncodeCredentials
//
//   To use some APIs, we need to provide credentials. Usually, the API is expecting a base 64
// encoded UTF-8 string of the form username:password.
//
//   This procedure will generate that string so we can easily use it anywhere else in this
// program.
//
// Note:
//   Previously, this procedure used the base64encode scalar function in SYSTOOLS. IBM documentation
// for that function states a maximum input of 2,732 characters. We know that for every 3 bytes of
// data, we will need 4 base64 characters. Therefore, the maximum length string that could come out
// of the base64encode function is 3,643 characters.
//
//   This procedure now uses the base64_encode scalar function in QSYS2. The documentation for that
// function does not mention any size limitations, only that the result of the function is a CLOB.
// Since CLOB variables can be up to 2 147 483 647 bytes in length, a theoretical maximum input
// would be 1 610 612 735 characters.
//
//   We have chosen to continue using the template variables tpl_sdk4i_ibm_base64_input and
// tpl_sdk4i_ibm_base64_result with their previously defined lengths (2732 and 3643 respectively)
// since we feel they are more than adequate. If you would like to change those values, do so in the
// src/qcpysrc/ibmapik.rpgleinc source file.
//
// Parameters:
// @param REQUIRED. The username which will automatically be trimmed.
// @param REQUIRED. The password which will automatically be trimmed.
//
// References:
// @link https://www.ibm.com/docs/en/i/7.6.0?topic=overview-base64encode-scalar-function
// @link https://www.ibm.com/docs/en/i/7.6.0?topic=functions-base64-encode
// @link https://www.ibm.com/docs/en/i/7.6.0?topic=expressions-cast-specification
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_EncodeCredentials EXPORT;
  DCL-PI WEB_EncodeCredentials LIKE(tpl_sdk4i_ibm_base64_result);
    i_username LIKE(tpl_sdk4i_ibm_base64_input) OPTIONS(*TRIM) CONST;
    i_password LIKE(tpl_sdk4i_ibm_base64_input) OPTIONS(*TRIM) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local data structures and variables.
  // -----------------------------------------------
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S o_base64_encoded_string LIKE(tpl_sdk4i_ibm_base64_result);
  DCL-S temp_str LIKE(tpl_sdk4i_ibm_base64_input); // Will hold username:password in UTF-8 encoding.

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  temp_str = i_username + ':' + i_password;

  EXEC SQL
    VALUES(
      CAST(qsys2.base64_encode(:temp_str) AS VARCHAR(3643))
    )
    INTO :o_base64_encoded_string;

  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = 'See source';
    log_msg = 'Failed to generate base64_encode credentials.' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  RETURN o_base64_encoded_string;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    IF (log_is_abend); // Log a message if we end abnormally.
      log_is_successful = *OFF;
      log_msg = 'Procedure '+ log_proc +' ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds:log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_EncodeCredentials;

// -------------------------------------------------------------------------------------------------
///
// WEB_GetEnvVarInt
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
  DCL-PI WEB_GetEnvVarInt LIKE(tpl_sdk4i_ibm_binary4);
    i_var LIKE(tpl_sdk4i_web_env_var_name) OPTIONS(*TRIM) CONST;
    i_default LIKE(tpl_sdk4i_ibm_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-S o_value LIKE(i_default) INZ(0);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  MONITOR;
    o_value = %INT(%STR(IBM_GetEnv(i_var)));
  ON-ERROR;
    IF (%PARMS >= %PARMNUM(i_default) AND %ADDR(i_default) <> *NULL);
      o_value = i_default;
    ELSE;
      o_value = 0;
    ENDIF;
    log_event_info_ds.ll_id = C_SDK4I_LL_INF;
    log_msg = 'Error getting environment variable ('+ i_var +'). Setting value to: '+
      %TRIM(%EDITC(o_value: 'P'));
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
  ENDMON;

  RETURN o_value;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_GetEnvVarStr
//
// Get an environment variable of type string.
//
// To get the Authorization header from Apache, the following line needs to be added to the config:
// SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
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

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-S o_value LIKE(i_default);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  MONITOR;
    o_value = %STR(IBM_GetEnv(i_var));
  ON-ERROR;
    IF (%PARMS >= %PARMNUM(i_default) AND %ADDR(i_default) <> *NULL);
      o_value = i_default;
    ELSE;
      CLEAR o_value;
    ENDIF;
    log_event_info_ds.ll_id = C_SDK4I_LL_INF;
    log_msg = 'Error getting environment variable ('+ i_var +'). Setting value to: ' +
      o_value;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
  ENDMON;

  RETURN o_value;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_GetHTTPRequest
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_GetHTTPRequest EXPORT;
  DCL-PI WEB_GetHTTPRequest IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_GetHTTPRequest;

// -------------------------------------------------------------------------------------------------
///
// WEB_SendHTTPResponse
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTPResponse EXPORT;
  DCL-PI WEB_SendHTTPResponse IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP200Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP200Response EXPORT;
  DCL-PI WEB_SendHTTP200Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP201Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP201Response EXPORT;
  DCL-PI WEB_SendHTTP201Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP204Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP204Response EXPORT;
  DCL-PI WEB_SendHTTP204Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP400Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP400Response EXPORT;
  DCL-PI WEB_SendHTTP400Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP401Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP401Response EXPORT;
  DCL-PI WEB_SendHTTP401Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP403Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP403Response EXPORT;
  DCL-PI WEB_SendHTTP403Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP404Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP404Response EXPORT;
  DCL-PI WEB_SendHTTP404Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP405Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP405Response EXPORT;
  DCL-PI WEB_SendHTTP405Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP409Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP409Response EXPORT;
  DCL-PI WEB_SendHTTP409Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP415Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP415Response EXPORT;
  DCL-PI WEB_SendHTTP415Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP500Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP500Response EXPORT;
  DCL-PI WEB_SendHTTP500Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
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
// WEB_SendHTTP550Response
//
// Coming soon.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC WEB_SendHTTP550Response EXPORT;
  DCL-PI WEB_SendHTTP550Response IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC WEB_SendHTTP550Response;