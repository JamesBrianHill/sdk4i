**FREE
// -------------------------------------------------------------------------------------------------
// Description: This service program provides security-related procedures.
//
// NOTE: most of the procedures in this service program perform database transactions - none of them
// execute a COMMIT. The calling program is responsible for ensuring a COMMIT is executed at some
// point.
//
//   We use the Db2 for i function HASH_SHA512 for password hashing because it is the strongest
// available at the time this was written. An alternative to using the Db2 for i function would be
// to use the QC3CALHA API provided by IBM i:
// https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/apis/qc3calha.html
//
// @author James Brian Hill
// @copyright Copyright (c) 2015 - 2026 by James Brian Hill
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
CTL-OPT TEXT('SDK4i - SEC - Security utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// APIK - API constants, data structures, variables, and procedure definitions.
// ERRK - ERR constants, data structures, variables, and procedure definitions.
// NILK - NIL constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// SECK - SEC constants, data structures, variables, and procedure definitions.
// VLDK - VLD constants, data structures, variables, and procedure definitions.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/apik.rpgleinc'
/COPY '../../qcpysrc/errk.rpgleinc'
/COPY '../../qcpysrc/nilk.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'
/COPY '../../qcpysrc/seck.rpgleinc'
/COPY '../../qcpysrc/vldk.rpgleinc'

// -------------------------------------------------------------------------------------------------
// Pull in column definitions.
//
// NOTE:
// tpl_sdk4i_secusrt_ds cannot be initialized (INZ(*EXTDFT)) because it causes an error - the compiler
// attempts to initialize the pwd column, defined as VARBINARY(64) (which is CCSID 65535), with an
// empty string ('') - but the empty string has a CCSID equal to the job CCSID which (hopefully) is
// not 65535 (*HEX).
// -------------------------------------------------------------------------------------------------
DCL-DS tpl_sdk4i_secsest_ds EXTNAME('SECSEST') INZ(*EXTDFT) QUALIFIED TEMPLATE CCSID(*EXACT) END-DS;

// -------------------------------------------------------------------------------------------------
// Define global constants, template data structures, and template variables.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Set SQL options before any executable code but after all global Definition Specifications.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/sqloptk.rpgleinc'

// -------------------------------------------------------------------------------------------------
///
// Authenticate a user.
//
// Verify the provided username and password are valid credentials. If so, return a token (a UUID)
// that will be used for subsequent requests.
//
// Example:
// DCL-S username LIKE(tpl_sdk4i_secusrt_ds.usr);
// DCL-S password LIKE(tpl_sdk4i_secusrt_ds.usr); // Yes, like tpl_sdk4i_secusrt_ds.usr!
// DCL-S token LIKE(tpl_sdk4i_uuid);
// IF (NOT SEC_Authenticate(username : password : token));
//   // Log a message and inform user the credentials were not valid.
// ENDIF;
//
// @param REQUIRED. The username of the user.
// @param REQUIRED. The password of the user.
// @param REQUIRED. This will hold a token (UUID) that can be used for subsequent requests.
// @param REQUIRED. This will hold a U/D/blank flag. U=Unauthenticated, D=Disabled, Blank=error.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the user authenticated successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SEC_Authenticate EXPORT;
  DCL-PI SEC_Authenticate IND;
    i_username LIKE(tpl_sdk4i_secusrt_ds.usr) OPTIONS(*TRIM) CONST;
    i_password LIKE(tpl_sdk4i_secusrt_ds.usr) OPTIONS(*TRIM) CONST; // Yes, LIKE usr, not LIKE pwd.
    o_token LIKE(tpl_sdk4i_uuid);
    o_reason_code LIKE(tpl_sdk4i_secusrt_ds.is_enabled);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S fname LIKE(tpl_sdk4i_secusrt_ds.fname);
  DCL-S hon_id LIKE(tpl_sdk4i_secusrt_ds.hon_id);
  DCL-S is_enabled LIKE(tpl_sdk4i_secusrt_ds.is_enabled);
  DCL-S lname LIKE(tpl_sdk4i_secusrt_ds.lname);
  DCL-S lng_id LIKE(tpl_sdk4i_secusrt_ds.lng_id);
  DCL-S mname LIKE(tpl_sdk4i_secusrt_ds.mname) NULLIND;
  DCL-S pname LIKE(tpl_sdk4i_secusrt_ds.pname) NULLIND;
  DCL-S suffix_id LIKE(tpl_sdk4i_secusrt_ds.suffix_id) NULLIND;
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S tz_code LIKE(tpl_sdk4i_secsest_ds.tz_code);
  DCL-S tz_dsc LIKE(tpl_sdk4i_secsest_ds.tz_dsc);
  DCL-S tz_offset LIKE(tpl_sdk4i_secsest_ds.tz_offset);
  DCL-S usr_id LIKE(tpl_sdk4i_secusrt_ds.id);
  DCL-S username LIKE(tpl_sdk4i_secsest_ds.username);

  DCL-S mname_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S pname_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S suffix_id_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  // Validate the credentials we have been given and grab data we need for SECSEST.
  // @link https://www.ibm.com/docs/en/i/7.6.0?topic=statement-isolation-clause
  s_stmt = 'SELECT a.id, a.usr, a.hon_id, a.fname, a.mname, a.lname, a.pname, a.suffix_id, ' +
             'a.is_enabled, a.lng_id, b.code, b.dsc, b.offset ' +
           'FROM secusrt a ' +
           'LEFT JOIN tmetznt b ON a.tz_id = b.id ' +
           'WHERE a.usr = ? AND a.pwd = HASH_SHA512(CAST(? AS VARCHAR(128))) ' +
           'WITH NC';

  EXEC SQL PREPARE s_Authenticate FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg + ' ' + s_stmt;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL DECLARE c_Authenticate CURSOR FOR s_Authenticate;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'DECLARE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL OPEN c_Authenticate USING :i_username, :i_password;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'OPEN failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL
    FETCH c_Authenticate
    INTO :usr_id, :username, :hon_id, :fname, :mname :mname_null, :lname, :pname :pname_null,
         :suffix_id :suffix_id_null, :is_enabled, :lng_id, :tz_code, :tz_dsc, :tz_offset;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    IF (s_diagnostics_ds.returned_sqlstate = '02000');
      o_reason_code = 'U'; // User did not authenticate successfully.
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
      log_msg = 'Unable to authenticate user ('+ i_username +') - credentials are invalid.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ELSE;
      o_reason_code = *BLANKS;
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'FETCH failed. ' + s_diagnostics_ds.err_msg;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ENDIF;
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  IF (is_enabled <> 'Y');
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
    log_msg = 'A disabled user account ('+ i_username +') attempted to login.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    o_reason_code = 'D'; // User account is disabled.
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // Populate the user_info_ds data structure.
  IF (%PARMS >= %PARMNUM(i_log_user_info_ds) AND %ADDR(i_log_user_info_ds) <> *NULL);
    i_log_user_info_ds.user_id = usr_id;
    %NULLIND(i_log_user_info_ds.user_id) = *OFF;
    i_log_user_info_ds.username = username;
    %NULLIND(i_log_user_info_ds.username) = *OFF;
    log_user_info_ds.user_id = i_log_user_info_ds.user_id;
    %NULLIND(log_user_info_ds.user_id) = *OFF;
    log_user_info_ds.username = i_log_user_info_ds.username;
    %NULLIND(log_user_info_ds.username) = *OFF;
  ENDIF;

  IF (is_enabled = 'Y' AND SEC_CreateUUID(o_token: log_user_info_ds));
    EXEC SQL
      INSERT INTO secsest(id, usr_id, username, hon_id, fname, mname, lname, pname, suffix_id,
        lng_id, tz_code, tz_dsc, tz_offset, last_used)
      VALUES(:o_token, :usr_id, :username, :hon_id, :fname, :mname :mname_null, :lname,
        :pname :pname_null, :suffix_id :suffix_id_null, :lng_id, :tz_code, :tz_dsc, :tz_offset, TIMESTAMP(NOW()));
    IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'Error inserting row into SECSEST. ' + s_diagnostics_ds.err_msg;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ENDIF;
  ELSE; // We failed to create a token or the user is not enabled.
    log_is_successful = *OFF;
  ENDIF;

  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_Authenticate;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_event_info_ds.ll_id = C_SDK4I_LL_ALT; // Alert because people may not be able to log in.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC SEC_Authenticate;

// -------------------------------------------------------------------------------------------------
///
// SEC_AuthenticateBypass
//
//   Bypass SDK4i authentication methods and login the provided username or user profile. This
// procedure provides an easy way to integrate SDK4i into an existing environment - the already
// existing authentication method (SSO, JWT, IBM i authentication, or whatever) can be used and we
// can also use the SDK4i security system.
//
//   Note that the username or user profile must be set up in the SECUSRT table.
//
// @param OPTIONAL. The username of the user.
// @param OPTIONAL. The user profile of the user.
// @param REQUIRED. This will hold a token (UUID) that can be used for subsequent requests.
// @param REQUIRED. This will hold a U/D/blank flag. U=Unauthenticated, D=Disabled, Blank=error.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the user was logged in successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SEC_AuthenticateBypass EXPORT;
  DCL-PI SEC_AuthenticateBypass IND;
    i_username LIKE(tpl_sdk4i_secusrt_ds.usr) OPTIONS(*OMIT: *TRIM) CONST;
    i_usrprf LIKE(tpl_sdk4i_secusrt_ds.usrprf) OPTIONS(*OMIT: *TRIM) CONST;
    o_token LIKE(tpl_sdk4i_uuid);
    o_reason_code LIKE(tpl_sdk4i_secusrt_ds.is_enabled);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S fname LIKE(tpl_sdk4i_secusrt_ds.fname);
  DCL-S hon_id LIKE(tpl_sdk4i_secusrt_ds.hon_id);
  DCL-S is_enabled LIKE(tpl_sdk4i_secusrt_ds.is_enabled);
  DCL-S lname LIKE(tpl_sdk4i_secusrt_ds.lname);
  DCL-S lng_id LIKE(tpl_sdk4i_secusrt_ds.lng_id);
  DCL-S mname LIKE(tpl_sdk4i_secusrt_ds.mname) NULLIND;
  DCL-S pname LIKE(tpl_sdk4i_secusrt_ds.pname) NULLIND;
  DCL-S suffix_id LIKE(tpl_sdk4i_secusrt_ds.suffix_id) NULLIND;
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S tz_code LIKE(tpl_sdk4i_secsest_ds.tz_code);
  DCL-S tz_dsc LIKE(tpl_sdk4i_secsest_ds.tz_dsc);
  DCL-S tz_offset LIKE(tpl_sdk4i_secsest_ds.tz_offset);
  DCL-S usr_id LIKE(tpl_sdk4i_secusrt_ds.id);
  DCL-S username LIKE(tpl_sdk4i_secsest_ds.username);

  DCL-S mname_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S pname_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S suffix_id_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  // We must have a username or a user profile.
  IF (%ADDR(i_username) = *NULL AND %ADDR(i_usrprf) = *NULL);
    log_is_successful = *OFF;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'A username or user profile is required but neither was provided.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN log_is_successful;
  ENDIF;

  // Grab data we need for SECSEST.
  IF (%ADDR(i_username) <> *NULL);
    s_stmt = 'SELECT a.id, a.usr, a.hon_id, a.fname, a.mname, a.lname, a.pname, a.suffix_id, ' +
              'a.is_enabled, a.lng_id, b.code, b.dsc, b.offset ' +
            'FROM secusrt a ' +
            'LEFT JOIN tmetznt b ON b.id = a.tz_id ' +
            'WHERE a.usr = ? ' +
            'WITH NC';
  ELSE;
    s_stmt = 'SELECT a.id, a.usr, a.hon_id, a.fname, a.mname, a.lname, a.pname, a.suffix_id, ' +
              'a.is_enabled, a.lng_id, b.code, b.dsc, b.offset ' +
            'FROM secusrt a ' +
            'LEFT JOIN tmetznt b ON b.id = a.tz_id ' +
            'WHERE a.usrprf = ? ' +
            'WITH NC';
  ENDIF;

  EXEC SQL PREPARE s_AuthenticateBypass FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg + ' ' + s_stmt;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL DECLARE c_AuthenticateBypass CURSOR FOR s_AuthenticateBypass;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'DECLARE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  IF (%ADDR(i_username) <> *NULL);
    EXEC SQL OPEN c_AuthenticateBypass USING :i_username;
  ELSE;
    EXEC SQL OPEN c_AuthenticateBypass USING :i_usrprf;
  ENDIF;

  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'OPEN failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL
    FETCH c_AuthenticateBypass
    INTO :usr_id, :username, :hon_id, :fname, :mname :mname_null, :lname, :pname :pname_null,
         :suffix_id :suffix_id_null, :is_enabled, :lng_id, :tz_code, :tz_dsc, :tz_offset;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    IF (s_diagnostics_ds.returned_sqlstate = '02000');
      o_reason_code = 'U'; // Username or user profile not found.
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
      log_msg = 'Provided username/usrprf ('+ i_username +'/'+ i_usrprf +') does not exist in Security User table SECUSRT.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ELSE;
      o_reason_code = *BLANKS;
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'FETCH failed. ' + s_diagnostics_ds.err_msg;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ENDIF;
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // Since we are bypassing the SDK4i authentication, if we find the user account is not enabled we
  // will re-enable it.
  IF (is_enabled <> 'Y');
    EXEC SQL
      UPDATE secusrt
      SET is_enabled = 'Y'
      WHERE usr_id = :usr_id;
    is_enabled = 'Y';
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_event_info_ds.ll_id = C_SDK4I_LL_NTF;
    log_msg = 'Username/User Profile ('+ i_username +'/'+ i_usrprf +') bypassed login while SDK4i account was disabled. is_enabled flag was changed to Y.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
  ENDIF;

  // Populate the user_info_ds data structure.
  IF (%PARMS >= %PARMNUM(i_log_user_info_ds) AND %ADDR(i_log_user_info_ds) <> *NULL);
    i_log_user_info_ds.user_id = usr_id;
    %NULLIND(i_log_user_info_ds.user_id) = *OFF;
    i_log_user_info_ds.username = username;
    %NULLIND(i_log_user_info_ds.username) = *OFF;
    log_user_info_ds.user_id = i_log_user_info_ds.user_id;
    %NULLIND(log_user_info_ds.user_id) = *OFF;
    log_user_info_ds.username = i_log_user_info_ds.username;
    %NULLIND(log_user_info_ds.username) = *OFF;
  ENDIF;

  IF (is_enabled = 'Y' AND SEC_CreateUUID(o_token: log_user_info_ds));
    EXEC SQL
      INSERT INTO secsest(id, usr_id, username, hon_id, fname, mname, lname, pname, suffix_id,
        lng_id, tz_code, tz_dsc, tz_offset, last_used)
      VALUES(:o_token, :usr_id, :username, :hon_id, :fname, :mname :mname_null, :lname,
        :pname :pname_null, :suffix_id :suffix_id_null, :lng_id, :tz_code, :tz_dsc, :tz_offset, TIMESTAMP(NOW()));
    IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'Error inserting row into SECSEST. ' + s_diagnostics_ds.err_msg;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ENDIF;
  ELSE; // We failed to create a token or the user is not enabled.
    log_is_successful = *OFF;
  ENDIF;

  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_AuthenticateBypass;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_event_info_ds.ll_id = C_SDK4I_LL_ALT; // Alert because people may not be able to log in.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC SEC_AuthenticateBypass;

// -------------------------------------------------------------------------------------------------
///
// Authenticate a user profile.
//
// Verify the provided user profile and password are valid credentials. If so, return a token
// (a UUID) that can be used for subsequent requests and add this user to the SECSEST table.
//
// WARNING: be aware that calling this procedure multiple times with an incorrect password for a
// user profile can result in that user profile being disabled.
//
// Example:
// DCL-S usrprf LIKE(tpl_sdk4i_secusrt_ds.usrprf);
// DCL-S password LIKE(tpl_sdk4i_secusrt_ds.usr); // Yes, like tpl_sdk4i_secusrt_ds.usr!
// DCL-S token LIKE(tpl_sdk4i_uuid);
// IF (NOT SEC_AuthenticateUserProfile(usrprf : password : token));
//   // Log a message and inform user the credentials were not valid.
// ENDIF;
//
// @param REQUIRED. The user profile.
// @param REQUIRED. The password for the user profile.
// @param REQUIRED. This will hold a token (UUID) that can be used for subsequent requests.
// @param REQUIRED. This will hold a U/D/blank flag. U=Unauthenticated, D=Disabled, Blank=error.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the user authenticated successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SEC_AuthenticateUserProfile EXPORT;
  DCL-PI SEC_AuthenticateUserProfile IND;
    i_usrprf LIKE(tpl_sdk4i_secusrt_ds.usrprf) OPTIONS(*TRIM) CONST;
    i_password CHAR(512) OPTIONS(*TRIM) CONST;
    o_token LIKE(tpl_sdk4i_uuid);
    o_reason_code LIKE(tpl_sdk4i_secusrt_ds.is_enabled);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS error_ds LIKEDS(tpl_sdk4i_errc0100_ds) INZ(*LIKEDS);
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S fname LIKE(tpl_sdk4i_secusrt_ds.fname);
  DCL-S handle CHAR(12);
  DCL-S hon_id LIKE(tpl_sdk4i_secusrt_ds.hon_id);
  DCL-S is_enabled LIKE(tpl_sdk4i_secusrt_ds.is_enabled);
  DCL-S lname LIKE(tpl_sdk4i_secusrt_ds.lname);
  DCL-S lng_id LIKE(tpl_sdk4i_secusrt_ds.lng_id);
  DCL-S mname LIKE(tpl_sdk4i_secusrt_ds.mname) NULLIND;
  DCL-S pname LIKE(tpl_sdk4i_secusrt_ds.pname) NULLIND;
  DCL-S pwd_ccsid LIKE(tpl_sdk4i_ccsid) INZ(-1);
  DCL-S pwd_len LIKE(tpl_sdk4i_binary4);
  DCL-S suffix_id LIKE(tpl_sdk4i_secusrt_ds.suffix_id) NULLIND;
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S tz_code LIKE(tpl_sdk4i_secsest_ds.tz_code);
  DCL-S tz_dsc LIKE(tpl_sdk4i_secsest_ds.tz_dsc);
  DCL-S tz_offset LIKE(tpl_sdk4i_secsest_ds.tz_offset);
  DCL-S usr_id LIKE(tpl_sdk4i_secusrt_ds.id);
  DCL-S username LIKE(tpl_sdk4i_secsest_ds.username);

  DCL-S mname_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S pname_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL
  DCL-S suffix_id_null INT(5) INZ(C_SDK4I_NULL); // Default to NULL

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  pwd_len = %LEN(%TRIM(i_password));
  MONITOR;
    API_GetProfileHandle(i_usrprf: i_password: handle: error_ds: pwd_len: pwd_ccsid);
  ON-EXCP 'CPF2203';
    log_msg = 'User profile ('+ %TRIM(i_usrprf) +') not correct.';
    o_reason_code = 'U';
  ON-EXCP 'CPF2213';
    log_msg = 'Not able to allocate user profile ('+ %TRIM(i_usrprf) +').';
  ON-EXCP 'CPF2225';
    log_msg = 'Not able to allocate internal system object.';
  ON-EXCP 'CPF22E2';
    log_msg = 'Authentication information for user profile ('+ %TRIM(i_usrprf) +') not correct.';
  ON-EXCP 'CPF22E3';
    log_msg = 'User profile ('+ %TRIM(i_usrprf) +') is disabled.';
    o_reason_code = 'D';
  ON-EXCP 'CPF22E4';
    log_msg = 'Password for user profile ('+ %TRIM(i_usrprf) +') has expired.';
  ON-EXCP 'CPF22E5';
    log_msg = 'No password associated with user profile ('+ %TRIM(i_usrprf) +').';
  ON-EXCP 'CPF22E6';
    log_msg = 'Maximum number of profile handles have been generated.';
  ON-EXCP 'CPF22E9';
    log_msg = '*USE authority to user profile ('+ %TRIM(i_usrprf) +') required.';
  ON-EXCP 'CPF24B4';
    log_msg = 'Severe error while address parameter list.';
  ON-EXCP 'CPF3BC7';
    log_msg = 'CCSID ('+ %CHAR(pwd_ccsid) +') outside of valid range.';
  ON-EXCP 'CPF3BDE';
    log_msg = 'CCSID ('+ %CHAR(pwd_ccsid) +') not supported by API.';
  ON-EXCP 'CPF3C1D';
    log_msg = 'Length specified is not valid.';
  ON-EXCP 'CPF3C3C';
    log_msg = 'Value for parameter is not valid.';
  ON-EXCP 'CPF3C36';
    log_msg = 'Number of parameters entered for this API was not valid.';
  ON-EXCP 'CPF3C90';
    log_msg = 'Literal value cannot be changed.';
  ON-EXCP 'CPF3CF1';
    log_msg = 'Error code parameter not valid.';
  ON-EXCP 'CPF4AB8';
    log_msg = 'Insufficient authority for user profile ('+ i_usrprf +').';
  ON-EXCP 'CPF4AF1';
    log_msg = 'Operation not allowed for user profile ('+ i_usrprf +').';
  ON-EXCP 'CPF9872';
    log_msg = 'Program or service program ended. See job log.';
  ON-ERROR;
    log_msg = 'An unexpected error occurred and we were unable to validate the user profile ('+ i_usrprf +') and password.';
  ENDMON;

  IF (log_msg <> *BLANKS OR error_ds.bytes_available > 0);
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    LOG_LogMsg(psds_ds: log_proc: log_msg: *OMIT: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  // Grab data we need for SECSEST.
  s_stmt = 'SELECT a.id, a.usr, a.hon_id, a.fname, a.mname, a.lname, a.pname, a.suffix_id, ' +
             'a.is_enabled, a.lng_id, b.code, b.dsc, b.offset ' +
           'FROM secusrt a ' +
           'LEFT JOIN tmetznt b ON a.tz_id = b.id ' +
           'WHERE a.usrprf = ? ' +
           'WITH NC';

  EXEC SQL PREPARE s_AuthenticateUserProfile FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg + ' ' + s_stmt;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL DECLARE c_AuthenticateUserProfile CURSOR FOR s_AuthenticateUserProfile;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'DECLARE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL OPEN c_AuthenticateUserProfile USING :i_usrprf;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'OPEN failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL
    FETCH c_AuthenticateUserProfile
    INTO :usr_id, :username, :hon_id, :fname, :mname :mname_null, :lname, :pname :pname_null,
         :suffix_id :suffix_id_null, :is_enabled, :lng_id, :tz_code, :tz_dsc, :tz_offset;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    IF (s_diagnostics_ds.returned_sqlstate = '02000');
      o_reason_code = 'U'; // User profile not found.
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
      log_msg = 'User profile ('+ i_usrprf +') does not exist in Security User table SECUSRT.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ELSE;
      o_reason_code = *BLANKS;
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'FETCH failed. ' + s_diagnostics_ds.err_msg;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ENDIF;
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  IF (is_enabled <> 'Y');
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
    log_msg = 'User profile ('+ i_usrprf +') attempted to login but is disabled. Check SECUSRT.IS_ENABLED.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    o_reason_code = 'D'; // User account is disabled.
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  // Populate the user_info_ds data structure.
  IF (%PARMS >= %PARMNUM(i_log_user_info_ds) AND %ADDR(i_log_user_info_ds) <> *NULL);
    i_log_user_info_ds.user_id = usr_id;
    %NULLIND(i_log_user_info_ds.user_id) = *OFF;
    i_log_user_info_ds.username = username;
    %NULLIND(i_log_user_info_ds.username) = *OFF;
    log_user_info_ds.user_id = i_log_user_info_ds.user_id;
    %NULLIND(log_user_info_ds.user_id) = *OFF;
    log_user_info_ds.username = i_log_user_info_ds.username;
    %NULLIND(log_user_info_ds.username) = *OFF;
  ENDIF;

  IF (is_enabled = 'Y' AND SEC_CreateUUID(o_token: log_user_info_ds));
    EXEC SQL
      INSERT INTO secsest(id, usr_id, username, hon_id, fname, mname, lname, pname, suffix_id,
        lng_id, tz_code, tz_dsc, tz_offset, last_used)
      VALUES(:o_token, :usr_id, :username, :hon_id, :fname, :mname :mname_null, :lname,
        :pname :pname_null, :suffix_id :suffix_id_null, :lng_id, :tz_code, :tz_dsc, :tz_offset, TIMESTAMP(NOW()));
    IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'Error inserting row into SECSEST. ' + s_diagnostics_ds.err_msg;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ENDIF;
  ELSE; // We failed to create a token or the user is not enabled.
    log_is_successful = *OFF;
  ENDIF;

  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_AuthenticateUserProfile;
    IF (handle <> *BLANKS);
      MONITOR;
        API_ReleaseProfileHandle(handle);
      ON-EXCP 'CPF2225';
        log_msg = 'Not able to allocate internal system object.';
      ON-EXCP 'CPF3C90';
        log_msg = 'Literal value cannot be changed.';
      ON-EXCP 'CPF3CF1';
        log_msg = 'Error code parameter not valid.';
      ON-EXCP 'CPF9872';
        log_msg = 'Program or service program ended. See job log.';
      ON-ERROR;
        log_msg = 'Unexpected error occurred when attempting to release profile handle.';
      ENDMON;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_event_info_ds.ll_id = C_SDK4I_LL_ALT; // Alert because people may not be able to log in.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC SEC_AuthenticateUserProfile;

// -------------------------------------------------------------------------------------------------
///
// Create a UUID (token).
//
// This procedure will create a type 4 Universally Unique IDentifier (UUID) which is currently in
// common use.
//
// Example:
// DCL-S token LIKE(tpl_sdk4i_uuid);
// IF (NOT SEC_CreateUUID(token));
//   // Log error and handle gracefully.
// ENDIF;
//
// @param REQUIRED. This will hold a token (UUID) that can be used for subsequent requests.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the token was created successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SEC_CreateUUID EXPORT;
  DCL-PI SEC_CreateUUID IND;
    o_token LIKE(tpl_sdk4i_uuid);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS uuid_ds LIKEDS(tpl_sdk4i_uuid_ds) INZ(*LIKEDS); // MUST be initialized with *LIKEDS.
  DCL-S uuid_hex_string CHAR(32);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  // Call the _GENUUID API and pass the address of our uuid_ds data structure.
  // To get the MCHxxxx error code, you must convert the hexadecimal error code found in the IBM
  // documentation to decimal on a byte-by-byte basis. So for a Pointer Does Not Exist error (2401):
  // hexadecimal 24 = decimal 36
  // hexadecimal 01 = decimal 01
  // Put those two bytes back together and you get 3601 - so check for MCH3601.
  MONITOR;
    API_GenerateUUID(%ADDR(uuid_ds));
  ON-EXCP 'MCH0601';
    log_msg = 'MCH0601 (0601): Space Addressing Violation';
  ON-EXCP 'MCH0602';
    log_msg = 'MCH0602 (0602): Boundary Alignment';
  ON-EXCP 'MCH0801';
    log_msg = 'MCH0801 (0801): Parameter Reference Violation';
  ON-EXCP 'MCH3202';
    log_msg = 'MCH3202 (2002): Machine Check';
  ON-EXCP 'MCH3203';
    log_msg = 'MCH3203 (2003): Function Check';
  ON-EXCP 'MCH3601';
    log_msg = 'MCH3601 (2401): Pointer Does Not Exist';
  ON-EXCP 'MCH3602';
    log_msg = 'MCH3601 (2402): Pointer Type Invalid';
  ON-EXCP 'MCH5001';
    log_msg = 'MCH5001 (3201): Scalar Type Invalid';
  ON-EXCP 'MCH5601';
    log_msg = 'MCH5601 (3801): Template value is invalid.';
  ON-EXCP 'MCH5602';
    log_msg = 'MCH5602 (3802): Template size is invalid. Did you initialize the data structure using INZ(*LIKEDS)?';
  ON-EXCP 'MCH6801';
    log_msg = 'MCH6801 (4401): Object Domain or Hardware Storage Protection Violation';
  ON-EXCP 'MCH6602';
    log_msg = 'MCH6602 (4402): Literal Values Cannot Be Changed';
  ON-ERROR;
    log_msg = 'Unknown error occurred when executing IBM API _GENUUID. Check LOGMSGT for clues.';
  ENDMON;

  IF (log_msg <> *BLANKS);
    log_is_successful = *OFF;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_event_info_ds.ll_id = C_SDK4I_LL_EMG; // This is an emergency because no one can log in.
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_msg = 'uuid_ds size is: ' + %TRIM(%EDITC(%SIZE(uuid_ds): 'P')) +
      '. bytes_provided: '+ %TRIM(%EDITC(uuid_ds.bytes_provided: 'P')) +
      '. bytes_available: '+ %TRIM(%EDITC(uuid_ds.bytes_available: 'P')) +
      '. version: ' + %TRIM(%EDITC(uuid_ds.version: 'P')) +
      '. uuid: ' + uuid_ds.uuid;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  // Convert the binary character string to hexadecimal so we can display it.
  API_CharToHex(%ADDR(uuid_hex_string): %ADDR(uuid_ds.uuid): %LEN(uuid_hex_string));

  // Now format our hexadecimal UUID for display.
  o_token = %SUBST(uuid_hex_string: 1: 8) + '-' +
            %SUBST(uuid_hex_string: 9: 4) + '-' +
            %SUBST(uuid_hex_string: 13: 4) + '-' +
            %SUBST(uuid_hex_string: 17: 4) + '-' +
            %SUBST(uuid_hex_string: 21);

  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_event_info_ds.ll_id = C_SDK4I_LL_ALT; // Alert because people may not be able to log in.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC SEC_CreateUUID;

// -------------------------------------------------------------------------------------------------
///
// Check authentication.
//
// Given a token (UUID), determine if it is valid.
//
// Example:
// IF (NOT SEC_IsAuthenticated(token));
//   // Log message and handle appropriately.
// ENDIF;
//
// @param REQUIRED. The token to be validated.
// @param REQUIRED. Information about the user associated with this event.
//
// @return *ON if the token is valid, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SEC_IsAuthenticated EXPORT;
  DCL-PI SEC_IsAuthenticated IND;
    i_token LIKE(tpl_sdk4i_uuid) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NULLIND);
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S temp_token LIKE(i_token);
  DCL-S user_id LIKE(tpl_sdk4i_log_user_info_ds.user_id) NULLIND;
  DCL-S username LIKE(tpl_sdk4i_log_user_info_ds.username) NULLIND;

  DCL-S user_id_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S username_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  temp_token = i_token; // Compiler complains when a CONST parameter is used in embedded SQL.

  // Get user ID and username for logging purposes.
  EXEC SQL
    SELECT usr_id, username
    INTO :user_id :user_id_null, :username :username_null
    FROM secsest
    WHERE id = :temp_token
    WITH NC;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = 'See source member.';
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'Token ('+ i_token +') not found or other error retrieving user ID and username. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  // We successfully retrieved the user_id and username so update our outgoing parameter and our
  // local data structure used for logging.
  i_log_user_info_ds.user_id = user_id;
  %NULLIND(i_log_user_info_ds.user_id) = NIL_IntToInd(user_id_null);
  i_log_user_info_ds.username = username;
  %NULLIND(i_log_user_info_ds.username) = NIL_IntToInd(username_null);

  log_user_info_ds.user_id = i_log_user_info_ds.user_id;
  %NULLIND(log_user_info_ds.user_id) = NIL_IntToInd(user_id_null);
  log_user_info_ds.username = i_log_user_info_ds.username;
  %NULLIND(log_user_info_ds.username) = NIL_IntToInd(username_null);

  // See if the user is already logged in.
  s_stmt = 'UPDATE secsest ' +
           'SET last_used = TIMESTAMP(NOW()) ' +
           'WHERE id = ? AND last_used >= TIMESTAMP(NOW() - auto_out MINUTES) ' +
           'WITH NC';

  EXEC SQL PREPARE s_IsAuthenticated FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL EXECUTE s_IsAuthenticated USING :temp_token;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    IF (s_diagnostics_ds.returned_sqlstate = '02000');
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
      log_msg = 'Token ('+ temp_token +') is not logged in.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ELSE;
      log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
      log_cause_info_ds.sstmt = s_stmt;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'EXECUTE failed. ' + s_diagnostics_ds.err_msg;
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      RESET log_event_info_ds;
    ENDIF;
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC SEC_IsAuthenticated;

// -------------------------------------------------------------------------------------------------
///
// Check authorization.
//
// Given a token (UUID) and a security action code, determine if the user associated with the token
// is authorized to the request security action.
//
// Example:
// DCL-S action_id LIKE(tpl_sdk4i_secactt_ds.id) INZ('DELETE_USER');
// IF (NOT SEC_IsAuthorized(token : action_id));
//   // Log message and tell user they are not authorized.
// ENDIF;
//
// @param REQUIRED. The token (UUID) for an active user.
// @param REQUIRED. The ID of the action the user wants to perform.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the user is authorized to perform the requested function, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SEC_IsAuthorized EXPORT;
  DCL-PI SEC_IsAuthorized IND;
    i_token LIKE(tpl_sdk4i_uuid) CONST;
    i_action_id LIKE(tpl_sdk4i_secactt_ds.id) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S action_id LIKE(i_action_id);
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S usr_id LIKE(tpl_sdk4i_secsest_ds.usr_id) INZ;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  action_id = i_action_id; // Compiler complains about CONST parameter in embedded SQL.

  // Use the token to get the usr_id from SECSEST.
  s_stmt = 'SELECT usr_id FROM secsest WHERE id = ? WITH NC';

  EXEC SQL PREPARE s_IsAuthorized1 FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL DECLARE c_IsAuthorized1 CURSOR FOR s_IsAuthorized1;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'DECLARE failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL OPEN c_IsAuthorized1 USING :i_token;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'OPEN failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL FETCH c_IsAuthorized1 INTO :usr_id;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'FETCH failed. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  // Use the usr_id and i_action_id to see if the user is authorized.
  s_stmt = 'UPDATE secusat ' +
           'SET last_used = DATE(NOW()) ' +
           'WHERE usr_id = ? AND act_id = ? ' +
           'WITH NC';

  EXEC SQL PREPARE s_IsAuthorized2 FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'Error with PREPARE of SQL statement 2. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL EXECUTE s_IsAuthorized2 USING :usr_id, :action_id;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
    log_msg = 'User (' + %TRIM(%EDITC(usr_id : 'P')) + ') is not authorized to ' + i_action_id + '.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    EXEC SQL CLOSE c_IsAuthorized1;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC SEC_IsAuthorized;

// -------------------------------------------------------------------------------------------------
///
// Check authorization.
//
//   Given a user profile and a security action code, determine if the user is authorized to the
// requested security action.
//
// Example:
// DCL-S action_id LIKE(tpl_sdk4i_secactt_ds.id) INZ('DELETE_USER');
// IF (NOT SEC_IsAuthorizedUserProfile(psds_ds.username : action_id));
//   // Log message and tell user they are not authorized.
// ENDIF;
//
// @param REQUIRED. The user profile associated with the action being performed.
// @param REQUIRED. The ID of the action the user wants to perform.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return *ON if the user is authorized to perform the requested function, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SEC_IsAuthorizedUserProfile EXPORT;
  DCL-PI SEC_IsAuthorizedUserProfile IND;
    i_usrprf LIKE(tpl_sdk4i_secusrt_ds.usrprf) CONST;
    i_action_id LIKE(tpl_sdk4i_secactt_ds.id) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);

  DCL-S action_id LIKE(i_action_id);
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S usrprf LIKE(i_usrprf);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  action_id = i_action_id; // Compiler complains about CONST parameter in embedded SQL.
  usrprf = i_usrprf; // Compiler complains about CONST parameter in embedded SQL.

  // Build an SQL statement to determine if the user is authorized.
  s_stmt = 'UPDATE secusat ' +
           'SET last_used = DATE(NOW()) ' +
           'WHERE usr_id = (SELECT id FROM secusrt WHERE usrprf = ?) AND act_id = ? ' +
           'WITH NC';

  EXEC SQL PREPARE s_IsAuthorizedUserProfile FROM :s_stmt;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_is_successful = *OFF;
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    RETURN log_is_successful;
  ENDIF;

  EXEC SQL EXECUTE s_IsAuthorizedUserProfile USING :usrprf, :action_id;
  IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
    log_cause_info_ds.sstate = s_diagnostics_ds.returned_sqlstate;
    log_cause_info_ds.sstmt = s_stmt;
    log_event_info_ds.fac_id = 4; // Security/Authorization messages.
    IF (s_diagnostics_ds.returned_sqlstate = C_SDK4I_SQLSTATE_NOT_FOUND);
      log_event_info_ds.ll_id = C_SDK4I_LL_WRN; // Security events should have elevated log level. 2 = Critical.
      log_msg = 'User profile (' + %TRIM(usrprf) + ') is not authorized to ' + i_action_id + '.';
    ELSE;
      log_msg = 'Error with EXECUTE of SQL statement. '+ s_diagnostics_ds.err_msg;
    ENDIF;
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDIF;

  RETURN log_is_successful;

  // -----------------------------------------------
  // Clean up.
  // -----------------------------------------------
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 4; // Security/Authorization messages.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC SEC_IsAuthorizedUserProfile;