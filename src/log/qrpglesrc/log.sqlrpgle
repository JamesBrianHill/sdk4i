**FREE
// -------------------------------------------------------------------------------------------------
//   This service program provides functionality to log messages from applications and to gather
// helpful information when programs experience exceptions (assuming the programs use this service
// program and this service program has been configured to capture such information).
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
/COPY '../../qcpysrc/ctloptspk.rpgleinc'
CTL-OPT TEXT('SDK4i - LOG - Logging utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// CCSID1208K - UTF-8 constants.
// LOGK - LOG constants, data structures, variables, and procedure definitions.
// NILK - NIL constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/logk.rpgleinc'
/COPY '../../qcpysrc/nilk.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'

// -------------------------------------------------------------------------------------------------
// Pull in column definitions.
// -------------------------------------------------------------------------------------------------
DCL-DS tpl_sdk4i_logcfgt_ds EXTNAME('LOGCFGT') INZ(*EXTDFT) QUALIFIED TEMPLATE CCSID(*EXACT) END-DS;

// -------------------------------------------------------------------------------------------------
// Define global constants, template data structures, and template variables.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Set SQL options before any executable code but after all global Definition Specifications.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/sqloptk.rpgleinc'

// -------------------------------------------------------------------------------------------------
///
//   Build a data structure holding information for the LOGWBLT table. This data structure will be
// passed into the LOG_LogMsg procedure from our web services.
//
// @param REQUIRED. The number of elements in i_env_var_array.
// @param REQUIRED. An array of data structures with information about environment variables.
// @param REQUIRED. The data structure built by this procedure.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC LOG_BuildLOGWBLT EXPORT;
  DCL-PI LOG_BuildLOGWBLT;
    i_env_var_count LIKE(tpl_sdk4i_unsigned_binary4) CONST;
    i_env_var_array LIKEDS(tpl_sdk4i_web_env_var_ds) DIM(C_SDK4I_WEB_ENV_VAR_ARRAY_COUNT)
      OPTIONS(*NULLIND) CONST;
    o_logwblt_ds LIKEDS(tpl_sdk4i_logwblt_ds) OPTIONS(*NULLIND);
  END-PI;

  DCL-S x LIKE(tpl_sdk4i_binary4);

  FOR x = 1 TO i_env_var_count;
    SELECT;
      WHEN (i_env_var_array(x).name = 'DOCUMENT_URI');
        o_logwblt_ds.uri = i_env_var_array(x).string_value;
      WHEN (i_env_var_array(x).name = 'QIBM_CGI_LIBRARY_LIST');
        o_logwblt_ds.libl = i_env_var_array(x).string_value;
      WHEN (i_env_var_array(x).name = 'QUERY_STRING');
        o_logwblt_ds.query = i_env_var_array(x).string_value;
      WHEN (i_env_var_array(x).name = 'REMOTE_ADDR');
        o_logwblt_ds.rmt_ipv4 = i_env_var_array(x).string_value;
      WHEN (i_env_var_array(x).name = 'REMOTE_PORT');
        o_logwblt_ds.rmt_port = i_env_var_array(x).int_value;
      WHEN (i_env_var_array(x).name = 'REQUEST_METHOD');
        o_logwblt_ds.req_method = i_env_var_array(x).string_value;
      WHEN (i_env_var_array(x).name = 'SCRIPT_NAME');
        o_logwblt_ds.script = i_env_var_array(x).string_value;
      WHEN (i_env_var_array(x).name = 'SERVER_ADDR');
        o_logwblt_ds.srv_ipv4 = i_env_var_array(x).string_value;
      WHEN (i_env_var_array(x).name = 'SERVER_PORT');
        o_logwblt_ds.srv_port = i_env_var_array(x).int_value;
      WHEN (i_env_var_array(x).name = 'SERVER_PROTOCOL');
        o_logwblt_ds.protocol = i_env_var_array(x).string_value;
      OTHER;
    ENDSL;
  ENDFOR;
END-PROC LOG_BuildLOGWBLT;

// -------------------------------------------------------------------------------------------------
///
//   Log a message from an application.
//
//   Log an event from an application. We want to know information about the event, the system, and
// the procedure. We also want to allow some (optional) additional information about the cause of
// the event, non IBM i user information, and information related to a web request.
//
// @param REQUIRED. A populated tpl_sdk4i_psds_ds data structure.
// @param REQUIRED. The name of the calling procedure.
// @param REQUIRED. The message to be logged.
// @param OPTIONAL. A tpl_sdk4i_log_cause_info_ds data structure.
// @param OPTIONAL. A tpl_sdk4i_log_event_info_ds data structure.
// @param OPTIONAL. A tpl_sdk4i_log_user_info_ds data structure.
// @param OPTIONAL. A tpl_logwblt_ds data structure containing info about a local web service.
// @param OPTIONAL. A tpl_logwbrt_ds data structure containing info about a remote web service.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC LOG_LogMsg EXPORT;
  DCL-PI LOG_LogMsg;
    i_psds_ds LIKEDS(tpl_sdk4i_psds_ds) CONST;
    i_proc LIKE(tpl_sdk4i_logmsgt_ds.prc) CONST;
    i_msg LIKE(tpl_sdk4i_logmsgt_ds.msg) CONST;
    i_cause_info_ds LIKEDS(tpl_sdk4i_log_cause_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_event_info_ds LIKEDS(tpl_sdk4i_log_event_info_ds) OPTIONS(*NOPASS: *OMIT) CONST;
    i_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_logwblt_ds LIKEDS(tpl_sdk4i_logwblt_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_logwbrt_ds LIKEDS(tpl_sdk4i_logwbrt_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S altemg_id LIKE(tpl_sdk4i_logcfgt_ds.altemg_id);
  DCL-S altalt_id LIKE(tpl_sdk4i_logcfgt_ds.altalt_id);
  DCL-S altcrt_id LIKE(tpl_sdk4i_logcfgt_ds.altcrt_id);
  DCL-S alterr_id LIKE(tpl_sdk4i_logcfgt_ds.alterr_id);
  DCL-S altwrn_id LIKE(tpl_sdk4i_logcfgt_ds.altwrn_id);
  DCL-S altnot_id LIKE(tpl_sdk4i_logcfgt_ds.altnot_id);
  DCL-S altinf_id LIKE(tpl_sdk4i_logcfgt_ds.altinf_id);
  DCL-S altdbg_id LIKE(tpl_sdk4i_logcfgt_ds.altdbg_id);
  DCL-S cfg_lvl LIKE(tpl_sdk4i_logcfgt_ds.logmsgt_id);
  DCL-S do_logcsit LIKE(tpl_sdk4i_logcfgt_ds.logcsit) INZ('N');
  DCL-S do_logextt LIKE(tpl_sdk4i_logcfgt_ds.logextt) INZ('N');
  DCL-S do_logwblt LIKE(tpl_sdk4i_logcfgt_ds.logwblt) INZ('N');
  DCL-S do_logwbrt LIKE(tpl_sdk4i_logcfgt_ds.logwbrt) INZ('N');
  DCL-S new_id LIKE(tpl_sdk4i_logmsgt_ds.id);

  // Variables associated with LOGMSGT.
  DCL-S usrprf_cur LIKE(i_psds_ds.username);
  DCL-S usrprf_ses LIKE(i_psds_ds.cur_usr);
  DCL-S user_id LIKE(tpl_sdk4i_logmsgt_ds.user_id);
  DCL-S username LIKE(tpl_sdk4i_logmsgt_ds.username);
  DCL-S fac_id LIKE(tpl_sdk4i_logmsgt_ds.logfact_id) INZ(1);
  DCL-S msg_lvl LIKE(tpl_sdk4i_logmsgt_ds.loglvlt_id) INZ(C_SDK4I_LL_ERR);
  DCL-S sys LIKE(i_psds_ds.sys);
  DCL-S lib LIKE(i_psds_ds.lib);
  DCL-S pgm LIKE(i_psds_ds.pgm_prc);
  DCL-S mod LIKE(i_psds_ds.mod_prc);
  DCL-S job_number LIKE(i_psds_ds.job_number);
  DCL-S job_user LIKE(i_psds_ds.username);
  DCL-S job_name LIKE(i_psds_ds.job_name);
  DCL-S sstate LIKE(tpl_sdk4i_logmsgt_ds.sstate);
  DCL-S sstmt LIKE(tpl_sdk4i_logmsgt_ds.sstmt);
  DCL-S errcode LIKE(tpl_sdk4i_logmsgt_ds.errcode);
  DCL-S errline LIKE(i_psds_ds.line);
  DCL-S errrout LIKE(i_psds_ds.routine);
  DCL-S errdata LIKE(i_psds_ds.exc_data);

  DCL-S errcode_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S errline_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S errrout_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S errdata_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S sstate_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S sstmt_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S user_id_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S username_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL

  // Extract data from i_psds_ds
  job_name = i_psds_ds.job_name;
  job_number = i_psds_ds.job_number;
  job_user = i_psds_ds.username;
  lib = i_psds_ds.lib;
  mod = i_psds_ds.mod_prc;
  pgm = i_psds_ds.pgm_prc;
  sys = i_psds_ds.sys;
  usrprf_cur = i_psds_ds.cur_usr;
  usrprf_ses = i_psds_ds.username;

  // Extract data from i_event_info_ds if provided.
  IF (%PARMS >= %PARMNUM(i_event_info_ds) AND %ADDR(i_event_info_ds) <> *NULL);
    fac_id = i_event_info_ds.fac_id;
    msg_lvl = i_event_info_ds.ll_id;
  ENDIF;

  // Check the LOGCFGT table to see if we should log anything. The order of precedence, from lowest
  // priority to highest priority is:
  // sys - the query below calls this priority 6
  // lib - the query below calls this priority 5
  // pgm - the query below calls this priority 4
  // mod - the query below calls this priority 3
  // prc - the query below calls this priority 2
  // usr - the query below calls this priority 1
  // 
  // Configuration for a usr will override all other configuration settings. Configuration for a
  // particular procedure will override all other settings - exept those for a particular user, etc.
  // We want the settings associated with the most important priority.
  EXEC SQL
    WITH pty1 (priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id) AS (
      SELECT 1, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id
      FROM logcfgt
      WHERE usr IN (:usrprf_cur, :usrprf_ses)
    ),
    pty2 (priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id) AS (
      SELECT 2, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id
      FROM logcfgt
      WHERE prc = :i_proc
    ),
    pty3 (priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id) AS (
      SELECT 3, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id
      FROM logcfgt
      WHERE mod = :mod
    ),
    pty4 (priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id) AS (
      SELECT 4, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id
      FROM logcfgt
      WHERE pgm = :pgm
    ),
    pty5 (priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id) AS (
      SELECT 5, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id
      FROM logcfgt
      WHERE lib = :lib
    ),
    pty6 (priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id) AS (
      SELECT 6, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id
      FROM logcfgt
      WHERE sys = :sys
    ),
    composite AS (
      SELECT priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id FROM pty1
      UNION
      SELECT priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id FROM pty2
      UNION
      SELECT priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id FROM pty3
      UNION
      SELECT priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id FROM pty4
      UNION
      SELECT priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id FROM pty5
      UNION
      SELECT priority, logcsit, logextt, logmsgt_id, logwblt, logwbrt, altemg_id, altalt_id, altcrt_id, alterr_id, altwrn_id, altnot_id, altinf_id, altdbg_id FROM pty6
    )
    SELECT
      COALESCE(logcsit, 'N'),
      COALESCE(logextt, 'N'),
      COALESCE(logmsgt_id, -1),
      COALESCE(logwblt, 'N'),
      COALESCE(logwbrt, 'N'),
      COALESCE(altemg_id, -1),
      COALESCE(altalt_id, -1),
      COALESCE(altcrt_id, -1),
      COALESCE(alterr_id, -1),
      COALESCE(altwrn_id, -1),
      COALESCE(altnot_id, -1),
      COALESCE(altinf_id, -1),
      COALESCE(altdbg_id, -1)
    INTO :do_logcsit, :do_logextt, :cfg_lvl, :do_logwblt, :do_logwbrt, :altemg_id, :altalt_id, :altcrt_id, :alterr_id, :altwrn_id, :altnot_id, :altinf_id, :altdbg_id
    FROM composite
    ORDER BY priority
    FETCH FIRST 1 ROWS ONLY
    WITH NC;

  // If the log level of the message is higher than the log level of the calling program,
  // return without logging anything. An example of this would be when the log level of the message
  // is C_SDK4I_LL_DBG (debug = 7) but the configuration has a log level of C_SDK4I_LL_ERR
  // (error = 3).
  IF (msg_lvl > cfg_lvl);
    RETURN;
  ENDIF;

  IF (i_psds_ds.exc_type <> *BLANKS AND i_psds_ds.exc_num <> *BLANKS);
    errcode = i_psds_ds.exc_type + i_psds_ds.exc_num;
    errcode_null = C_SDK4I_NOT_NULL;
    errline = i_psds_ds.line;
    errline_null = C_SDK4I_NOT_NULL;
    errrout = i_psds_ds.routine;
    errrout_null = C_SDK4I_NOT_NULL;
    errdata = i_psds_ds.exc_data;
    errdata_null = C_SDK4I_NOT_NULL;
  ENDIF;

  // Extract data from i_cause_info_ds if provided.
  IF (%PARMS >= %PARMNUM(i_cause_info_ds) AND %ADDR(i_cause_info_ds) <> *NULL);
    IF (i_cause_info_ds.sstate <> *BLANKS);
      sstate = i_cause_info_ds.sstate;
      sstate_null = C_SDK4I_NOT_NULL;
    ENDIF;
    IF (i_cause_info_ds.sstmt <> *BLANKS);
      sstmt = i_cause_info_ds.sstmt;
      sstmt_null = C_SDK4I_NOT_NULL;
    ENDIF;
  ENDIF;

  // Extract data from i_user_info_ds if provided.
  IF (%PARMS >= %PARMNUM(i_user_info_ds) AND %ADDR(i_user_info_ds) <> *NULL);
    IF (i_user_info_ds.user_id > 0);
      user_id = i_user_info_ds.user_id;
      user_id_null = C_SDK4I_NOT_NULL;
    ENDIF;
    IF (i_user_info_ds.username <> *BLANKS);
      username = i_user_info_ds.username;
      username_null = C_SDK4I_NOT_NULL;
    ENDIF;
  ENDIF;

  // Log the provided message and related information. Capture the newly created LOGMSGT.ID in case
  // we need it for one of the other log tables as a foreign key.
  EXEC SQL
    SELECT id
    INTO :new_id
    FROM FINAL TABLE (
      INSERT INTO logmsgt (usrprf_cur, user_id, username, logfact_id, loglvlt_id, msg, sys, lib,
        pgm, mod, prc, job_number, job_user, job_name, sstate, sstmt, errcode, errline, errrout,
        errdata)
      VALUES(
        :usrprf_cur,
        :user_id :user_id_null,
        :username :username_null,
        :fac_id,
        :msg_lvl,
        :i_msg,
        :sys,
        :lib,
        :pgm,
        :mod,
        :i_proc,
        :job_number,
        :job_user,
        :job_name,
        :sstate :sstate_null,
        :sstmt :sstmt_null,
        :errcode :errcode_null,
        :errline :errline_null,
        :errrout :errrout_null,
        :errdata :errdata_null)
    ) WITH NC;

  // Log call stack information if configured to do so.
  IF (do_logcsit = 'Y');
    SaveCallStackInfo(new_id);
  ENDIF;

  // Log extended information if configured to do so.
  IF (do_logextt = 'Y');
    SaveExtendedInfo(new_id);
  ENDIF;

  // Log local web service information if configured to do so and it was provided.
  IF (do_logwblt = 'Y' AND %PARMS >= %PARMNUM(i_logwblt_ds) AND %ADDR(i_logwblt_ds) <> *NULL);
    SaveLocalWebServiceInfo(new_id: i_logwblt_ds);
  ENDIF;

  // Log remote web service information if configured to do so and it was provided.
  IF (do_logwbrt = 'Y' AND %PARMS >= %PARMNUM(i_logwbrt_ds) AND %ADDR(i_logwbrt_ds) <> *NULL);
    SaveRemoteWebServiceInfo(new_id: i_logwbrt_ds);
  ENDIF;

END-PROC LOG_LogMsg;

// -------------------------------------------------------------------------------------------------
///
//   Log the use of a program or procedure.
//
//   We need to know which programs and procedures are being used. It is also helpful to know how
// often they are being used, if they are failing, how long they take to execute, etc.
//
//   This procedure will look at LOGCFGT to determine if anything should be written out to the
// following tables:
// LOGMETT - metrics such as beg/end timestamps, success, abnormal end, etc.
// LOGUSET - a simple count of how many times a program/procedure/etc. is called every time period.
//
// @param i_psds_ds REQUIRED. A populated PSDS data structure.
// @param i_proc REQUIRED. The name of the procedure that was used.
// @param i_beg_ts REQUIRED. A timestamp for when this process began.
// @param i_successful OPTIONAL. The return value (*ON/*OFF) of the process. Defaults to NULL.
// @param i_abend OPTIONAL. The abnormal end indicator of a procedure. Defaults to NULL.
// @param i_user_info_ds OPTIONAL. Information about the user associated with this event.
// @param i_end_ts OPTIONAL. A timestamp for when this process ended.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC LOG_LogUse EXPORT;
  DCL-PI LOG_LogUse;
    i_psds_ds LIKEDS(tpl_sdk4i_psds_ds) CONST;
    i_proc LIKE(tpl_sdk4i_logmett_ds.prc) CONST;
    i_beg_ts LIKE(tpl_sdk4i_logmett_ds.beg_ts) CONST;
    i_successful LIKE(tpl_sdk4i_is_successful) CONST OPTIONS(*NOPASS: *OMIT);
    i_abend LIKE(tpl_sdk4i_is_abend) CONST OPTIONS(*NOPASS: *OMIT);
    i_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
    i_end_ts LIKE(tpl_sdk4i_logmett_ds.end_ts) CONST OPTIONS(*NOPASS: *OMIT);
  END-PI;

  DCL-DS temp_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) INZ(*LIKEDS);

  DCL-S do_logmett LIKE(tpl_sdk4i_logcfgt_ds.logmett);
  DCL-S do_loguset LIKE(tpl_sdk4i_logcfgt_ds.loguset);
  DCL-S job_name LIKE(tpl_sdk4i_logmett_ds.job_name);
  DCL-S job_number LIKE(tpl_sdk4i_logmett_ds.job_number);
  DCL-S job_user LIKE(tpl_sdk4i_logmett_ds.job_user);
  DCL-S lib LIKE(i_psds_ds.lib);
  DCL-S mod LIKE(i_psds_ds.mod_prc);
  DCL-S pgm LIKE(i_psds_ds.pgm_prc);
  DCL-S sys LIKE(i_psds_ds.sys);
  DCL-S temp_abend LIKE(i_abend) NULLIND INZ(*OFF);
  DCL-S temp_end_ts LIKE(i_end_ts) NULLIND INZ(*SYS);
  DCL-S temp_successful LIKE(i_successful) NULLIND INZ(*OFF);
  DCL-S usrprf_cur LIKE(i_psds_ds.cur_usr);
  DCL-S usrprf_ses LIKE(i_psds_ds.username);

  // Extract data from i_psds_ds
  job_name = i_psds_ds.job_name;
  job_number = i_psds_ds.job_number;
  job_user = i_psds_ds.username;
  lib = i_psds_ds.lib;
  mod = i_psds_ds.mod_prc;
  pgm = i_psds_ds.pgm_prc;
  sys = i_psds_ds.sys;
  usrprf_cur = i_psds_ds.cur_usr;
  usrprf_ses = i_psds_ds.username;

  // Check the LOGCFGT table to see if we should log anything.
  EXEC SQL
    WITH pty1 (priority, logmett, loguset) AS (
      SELECT 1, logmett, loguset
      FROM logcfgt
      WHERE usr IN (:usrprf_cur, :usrprf_ses)
    ),
    pty2 (priority, logmett, loguset) AS (
      SELECT 2, logmett, loguset
      FROM logcfgt
      WHERE prc = :i_proc
    ),
    pty3 (priority, logmett, loguset) AS (
      SELECT 3, logmett, loguset
      FROM logcfgt
      WHERE mod = :mod
    ),
    pty4 (priority, logmett, loguset) AS (
      SELECT 4, logmett, loguset
      FROM logcfgt
      WHERE pgm = :pgm
    ),
    pty5 (priority, logmett, loguset) AS (
      SELECT 5, logmett, loguset
      FROM logcfgt
      WHERE lib = :lib
    ),
    pty6 (priority, logmett, loguset) AS (
      SELECT 6, logmett, loguset
      FROM logcfgt
      WHERE sys = :sys
    ),
    composite AS (
      SELECT priority, logmett, loguset FROM pty1
      UNION
      SELECT priority, logmett, loguset FROM pty2
      UNION
      SELECT priority, logmett, loguset FROM pty1
      UNION
      SELECT priority, logmett, loguset FROM pty1
      UNION
      SELECT priority, logmett, loguset FROM pty5
      UNION
      SELECT priority, logmett, loguset FROM pty6
    )
    SELECT
      COALESCE(logmett, 'N'),
      COALESCE(loguset, 'N')
    INTO :do_logmett, :do_loguset
    FROM composite
    ORDER BY priority
    FETCH FIRST 1 ROWS ONLY
    WITH NC;

  // If we are not configured to log anything, return to caller.
  IF (do_logmett = 'N' AND do_loguset = 'N');
    RETURN;
  ENDIF;

  // Log metrics if configured to do so.
  IF (do_logmett = 'Y');
    IF (%PARMS > %PARMNUM(i_successful) AND %ADDR(i_successful) <> *NULL);
      temp_successful = i_successful;
      %NULLIND(temp_successful) = *OFF;
    ELSE;
      %NULLIND(temp_successful) = *ON;
    ENDIF;

    IF (%PARMS >= %PARMNUM(i_abend) AND %ADDR(i_abend) <> *NULL);
      temp_abend = i_abend;
      %NULLIND(temp_abend) = *OFF;
    ELSE;
      %NULLIND(temp_abend) = *ON;
    ENDIF;

    IF (%PARMS >= %PARMNUM(i_user_info_ds) AND %ADDR(i_user_info_ds) <> *NULL);
      IF (i_user_info_ds.user_id > 0);
        temp_user_info_ds.user_id = i_user_info_ds.user_id;
        %NULLIND(temp_user_info_ds.user_id) = *OFF;
      ELSE;
        %NULLIND(temp_user_info_ds.user_id) = *ON;
      ENDIF;
      IF (i_user_info_ds.username <> *BLANKS);
        temp_user_info_ds.username = i_user_info_ds.username;
        %NULLIND(temp_user_info_ds.username) = *OFF;
      ELSE;
        %NULLIND(temp_user_info_ds.username) = *ON;
      ENDIF;
    ENDIF;

    IF (%PARMS > %PARMNUM(i_end_ts) AND %ADDR(i_end_ts) <> *NULL);
      temp_end_ts = i_end_ts;
    ENDIF;

    SaveMetrics(i_psds_ds: i_proc: i_beg_ts: temp_successful: temp_abend: temp_user_info_ds: temp_end_ts);
  ENDIF;

  // Log usage if configured to do so.
  IF (do_loguset <> 'N');
    SaveUseInfo(i_psds_ds: i_proc: do_loguset);
  ENDIF;

END-PROC LOG_LogUse;

// -------------------------------------------------------------------------------------------------
///
// Get callstack information for the application that just called LOG_LogMsg.
//
// Note that this procedure is expensive with regards to time and resources used. It will use the
// Db2 QSYS.STACK_INFO table function to retrieve one row for each entry in the callstack for every
// thread associated with the current job. A single call to this procedure could insert thousands
// of rows into the log table and take many seconds/minutes to execute.
//
// @param REQUIRED. This is the LOGMSGT.ID of the row just created in LOG_LogMsg.
//
// @link https://www.ibm.com/docs/en/i/7.5?topic=services-stack-info-table-function
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SaveCallStackInfo;
  DCL-PI SaveCallStackInfo;
    i_id LIKE(tpl_sdk4i_logmsgt_ds.id) CONST;
  END-PI;

  EXEC SQL
    INSERT INTO logcsit (logmsgt_id, thr_id, thr_type, ord_pos, entry_type, pgmlib, pgmnam, stmt_id,
      rqst_lvl, ctl_bnd, pgmaspnam, pgmaspnum, modlib, modnam, proc_name, actgrpnum, actgrpnam,
      mi_num, j_line, j_bytoff, j_mtype, j_class, j_mname, j_msig, j_fname, j_srcnam,
      p_line, p_iaddr, p_ioff, p_kcode, p_bcode, p_altres, p_proc, p_lmodnam, p_lmodpth, p_src,
      l_ioff, l_proc, l_lmodnam)
    SELECT :i_id, thread_id, thread_type, ordinal_position, entry_type, program_name,
      program_library_name, statement_identifiers, request_level, control_boundary,
      program_asp_name, program_asp_number, module_name, module_library_name, procedure_name,
      activation_group_number, activation_group_name, mi_instruction_number, java_line_number,
      java_byte_code_offset, java_method_type, java_class_name, java_method_name,
      java_method_signature, java_file_name, java_source_file_name, pase_line_number,
      pase_instruction_address, pase_instruction_offset, pase_kernel_code, pase_bit_code,
      pase_alternate_resume_point, pase_procedure_name, pase_load_module_name,
      pase_load_module_path, pase_source_path_and_file, lic_instruction_offset, lic_procedure_name,
      lic_load_module_name
    FROM TABLE (
      qsys2.stack_info('*', 'ALL')
    ) WITH NC;
END-PROC SaveCallStackInfo;

// -------------------------------------------------------------------------------------------------
///
// Get extended information.
//
// We are able to gather considerable information about the environment when needed. The option to
// collect extended information will likely be rare, when debugging a complicated error.
//
// @param REQUIRED. This is the LOGMSGT.ID of the row just created in LOG_LogMsg.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SaveExtendedInfo;
  DCL-PI SaveExtendedInfo;
    i_id LIKE(tpl_sdk4i_logmsgt_ds.id) CONST;
  END-PI;

  EXEC SQL
    INSERT INTO logextt (logmsgt_id, job_status, job_type, job_type_enhanced, job_subsystem, job_date,
      job_description_library, job_description, job_accounting_code, submitter_job_name,
      submitter_message_queue_library, submitter_message_queue, server_type,
      job_entered_system_time, job_scheduled_time, job_active_time, job_end_time, job_end_severity,
      completion_status, job_end_reason, job_queue_library, job_queue_name, job_queue_status,
      job_queue_priority, job_queue_time, job_message_queue_maximum_size,
      job_message_queue_full_action, allow_multiple_threads, peak_temporary_storage, default_wait,
      maximum_processing_time_allowed, maximum_temporary_storage_allowed, time_slice, job_switches,
      routing_data, job_ccsid, character_identifier_control, sort_sequence_library,
      sort_sequence_name, language_id, country_id, date_format, date_separator, time_separator,
      decimal_format, time_zone_description_name, message_logging_level, message_logging_severity,
      message_logging_text, log_cl_program_commands, status_message, inquiry_message_reply,
      break_message, job_log_output, job_log_pending, output_queue_priority, output_queue_library,
      output_queue_name, spooled_file_action, printer_device_name, print_key_format, print_text,
      device_name, device_recovery_action, ddm_conversation, mode_name, unit_of_work_id,
      internal_job_id, debug_mode, decfloat_rounding_mode, degree, implicit_xmlparse_option,
      current_path, current_schm, current_timezone, cur_user, sys_user, process_id, thread_id)
    SELECT :i_id, job_status, job_type, job_type_enhanced, job_subsystem, job_date,
      job_description_library, job_description, job_accounting_code, submitter_job_name,
      submitter_message_queue_library, submitter_message_queue, server_type,
      job_entered_system_time, job_scheduled_time, job_active_time, job_end_time, job_end_severity,
      completion_status, job_end_reason, job_queue_library, job_queue_name, job_queue_status,
      job_queue_priority, job_queue_time, job_message_queue_maximum_size,
      job_message_queue_full_action, allow_multiple_threads, peak_temporary_storage, default_wait,
      maximum_processing_time_allowed, maximum_temporary_storage_allowed, time_slice, job_switches,
      routing_data, ccsid, character_identifier_control, sort_sequence_library,
      sort_sequence_name, language_id, country_id, date_format, date_separator, time_separator,
      decimal_format, time_zone_description_name, message_logging_level, message_logging_severity,
      message_logging_text, log_cl_program_commands, status_message, inquiry_message_reply,
      break_message, job_log_output, job_log_pending, output_queue_priority, output_queue_library,
      output_queue_name, spooled_file_action, printer_device_name, print_key_format, print_text,
      device_name, device_recovery_action, ddm_conversation, mode_name, unit_of_work_id,
      internal_job_id,
      (SELECT current debug mode FROM sysibm.sysdummy1),
      (SELECT current decfloat rounding mode FROM sysibm.sysdummy1),
      (SELECT current degree FROM sysibm.sysdummy1),
      (SELECT current implicit xmlparse option FROM sysibm.sysdummy1),
      (SELECT current path FROM sysibm.sysdummy1),
      (SELECT current schema FROM sysibm.sysdummy1),
      (SELECT current timezone FROM sysibm.sysdummy1),
      (SELECT current user FROM sysibm.sysdummy1),
      (SELECT system_user FROM sysibm.sysdummy1),
      (VALUES(qsys2.process_id)),
      (VALUES(qsys2.thread_id))
    FROM TABLE (
      qsys2.job_info(JOB_STATUS_FILTER => '*ACTIVE', JOB_USER_FILTER => '*USER')
    )
    WHERE job_name = qsys2.job_name
    WITH NC;
END-PROC SaveExtendedInfo;

// -------------------------------------------------------------------------------------------------
///
// Save remote web service information.
//
// We may want to log information about calls to local web services such as remote IP, request
// information, etc.
//
// @param REQUIRED. This is the LOGMSGT.ID of the row just created in LOG_LogMsg.
// @param REQUIRED. A tpl_sdk4i_logwblt_ds data structure.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SaveLocalWebServiceInfo;
  DCL-PI SaveLocalWebServiceInfo;
    i_id LIKE(tpl_sdk4i_logmsgt_ds.id) CONST;
    i_logwblt_ds LIKEDS(tpl_sdk4i_logwblt_ds) OPTIONS(*NULLIND) CONST;
  END-PI;

  DCL-S srv_ipv4 LIKE(tpl_sdk4i_logwblt_ds.srv_ipv4);
  DCL-S srv_port LIKE(tpl_sdk4i_logwblt_ds.srv_port);
  DCL-S rmt_ipv4 LIKE(tpl_sdk4i_logwblt_ds.rmt_ipv4);
  DCL-S rmt_port LIKE(tpl_sdk4i_logwblt_ds.rmt_port);
  DCL-S protocol LIKE(tpl_sdk4i_logwblt_ds.protocol);
  DCL-S req_method LIKE(tpl_sdk4i_logwblt_ds.req_method);
  DCL-S uri LIKE(tpl_sdk4i_logwblt_ds.uri);
  DCL-S query LIKE(tpl_sdk4i_logwblt_ds.query);
  DCL-S rsp_code LIKE(tpl_sdk4i_logwblt_ds.rsp_code);
  DCL-S script LIKE(tpl_sdk4i_logwblt_ds.script);
  DCL-S libl LIKE(tpl_sdk4i_logwblt_ds.libl);

  DCL-S srv_ipv4_null INT(5) INZ(-1); // Assume NULL
  DCL-S srv_port_null INT(5) INZ(-1); // Assume NULL
  DCL-S rmt_ipv4_null INT(5) INZ(-1); // Assume NULL
  DCL-S rmt_port_null INT(5) INZ(-1); // Assume NULL
  DCL-S protocol_null INT(5) INZ(-1); // Assume NULL
  DCL-S req_method_null INT(5) INZ(-1); // Assume NULL
  DCL-S uri_null INT(5) INZ(-1); // Assume NULL
  DCL-S query_null INT(5) INZ(-1); // Assume NULL
  DCL-S rsp_code_null INT(5) INZ(-1); // Assume NULL
  DCL-S script_null INT(5) INZ(-1); // Assume NULL
  DCL-S libl_null INT(5) INZ(-1); // Assume NULL

  srv_ipv4 = i_logwblt_ds.srv_ipv4;
  srv_ipv4_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.srv_ipv4));
  srv_port = i_logwblt_ds.srv_port;
  srv_port_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.srv_port));
  rmt_ipv4 = i_logwblt_ds.rmt_ipv4;
  rmt_ipv4_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.rmt_ipv4));
  rmt_port = i_logwblt_ds.rmt_port;
  rmt_port_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.rmt_port));
  protocol = i_logwblt_ds.protocol;
  protocol_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.protocol));
  req_method = i_logwblt_ds.req_method;
  req_method_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.req_method));
  uri = i_logwblt_ds.uri;
  uri_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.uri));
  query = i_logwblt_ds.query;
  query_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.query));
  rsp_code = i_logwblt_ds.rsp_code;
  rsp_code_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.rsp_code));
  script = i_logwblt_ds.script;
  script_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.script));
  libl = i_logwblt_ds.libl;
  libl_null = NIL_IndToInt(%NULLIND(i_logwblt_ds.libl));

  EXEC SQL
    INSERT INTO logwblt (logmsgt_id, srv_ipv4, srv_port, rmt_ipv4, rmt_port, protocol, req_method,
      uri, query, rsp_code, script, libl)
    VALUES(
      :i_id,
      :srv_ipv4 :srv_ipv4_null,
      :srv_port :srv_port_null,
      :rmt_ipv4 :rmt_ipv4_null,
      :rmt_port :rmt_port_null,
      :protocol :protocol_null,
      :req_method :req_method_null,
      :uri :uri_null,
      :query :query_null,
      :rsp_code :rsp_code_null,
      :script :script_null,
      :libl :libl_null
      )
    WITH NC;
END-PROC SaveLocalWebServiceInfo;

// -------------------------------------------------------------------------------------------------
///
// Save metrics.
//
// We may want to log information about whether or not a procedure ended abnormally, how long it
// took to execute, etc.
//
// @param REQUIRED. A tpl_sdk4i_psds_ds.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SaveMetrics;
  DCL-PI SaveMetrics;
    i_psds_ds LIKEDS(tpl_sdk4i_psds_ds) CONST;
    i_proc LIKE(tpl_sdk4i_logmett_ds.prc) CONST;
    i_beg_ts LIKE(tpl_sdk4i_logmett_ds.beg_ts) CONST;
    i_successful LIKE(tpl_sdk4i_is_successful) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
    i_abend LIKE(tpl_sdk4i_is_abend) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
    i_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
    i_end_ts LIKE(tpl_sdk4i_logmett_ds.end_ts) CONST OPTIONS(*NOPASS: *NULLIND: *OMIT);
  END-PI;

  DCL-S abend LIKE(tpl_sdk4i_logmett_ds.abend) INZ(*OFF); // Must use LIKE(tpl_sdk4i_loguset_ds)
  DCL-S end_ts LIKE(i_end_ts) INZ(*SYS);
  DCL-S job_name LIKE(tpl_sdk4i_logmett_ds.job_name);
  DCL-S job_number LIKE(tpl_sdk4i_logmett_ds.job_number);
  DCL-S job_user LIKE(tpl_sdk4i_logmett_ds.job_user);
  DCL-S lib LIKE(i_psds_ds.lib);
  DCL-S mod LIKE(i_psds_ds.mod_prc);
  DCL-S pgm LIKE(i_psds_ds.pgm_prc);
  DCL-S success LIKE(tpl_sdk4i_logmett_ds.success) INZ(*ON);// Must use LIKE(tpl_sdk4i_loguset_ds)
  DCL-S sys LIKE(i_psds_ds.sys);
  DCL-S user_id LIKE(tpl_sdk4i_logmett_ds.user_id);
  DCL-S username LIKE(tpl_sdk4i_logmett_ds.username);
  DCL-S usrprf_cur LIKE(i_psds_ds.cur_usr);
  DCL-S usrprf_ses LIKE(i_psds_ds.username);

  DCL-S abend_null INT(5) INZ(-1); // Assume NULL
  DCL-S success_null INT(5) INZ(-1); // Assume NULL
  DCL-S user_id_null INT(5) INZ(-1); // Assume NULL
  DCL-S username_null INT(5) INZ(-1); // Assume NULL

  // Extract data from i_psds_ds
  job_name = i_psds_ds.job_name;
  job_number = i_psds_ds.job_number;
  job_user = i_psds_ds.username;
  lib = i_psds_ds.lib;
  mod = i_psds_ds.mod_prc;
  pgm = i_psds_ds.pgm_prc;
  sys = i_psds_ds.sys;
  usrprf_cur = i_psds_ds.cur_usr;
  usrprf_ses = i_psds_ds.username;

  IF (%PARMS >= %PARMNUM(i_successful) AND %ADDR(i_successful) <> *NULL AND NOT %NULLIND(i_successful));
    IF (i_successful);
      success = '1';
    ELSE;
      success = '0';
    ENDIF;
    success_null = C_SDK4I_NOT_NULL;
  ENDIF;

  IF (%PARMS >= %PARMNUM(i_abend) AND %ADDR(i_abend) <> *NULL AND NOT %NULLIND(i_abend));
    IF (i_abend);
      abend = '1';
    ELSE;
      abend = '0';
    ENDIF;
    abend_null = C_SDK4I_NOT_NULL;
  ENDIF;

  // Extract data from i_user_info_ds if provided.
  IF (%PARMS >= %PARMNUM(i_user_info_ds) AND %ADDR(i_user_info_ds) <> *NULL);
    IF (i_user_info_ds.user_id > 0);
      user_id = i_user_info_ds.user_id;
      user_id_null = C_SDK4I_NOT_NULL;
    ENDIF;
    IF (i_user_info_ds.username <> *BLANKS);
      username = i_user_info_ds.username;
      username_null = C_SDK4I_NOT_NULL;
    ENDIF;
  ENDIF;

  IF (%PARMS >= %PARMNUM(i_end_ts) AND %ADDR(i_end_ts) <> *NULL AND NOT %NULLIND(i_end_ts));
    end_ts = i_end_ts;
  ENDIF;

  EXEC SQL
    INSERT INTO logmett (sys, lib, pgm, mod, prc, job_number, job_user, job_name, beg_ts, end_ts,
      success, abend, user_id, username, usrprf_cur)
    VALUES(:sys,
          :lib,
          :pgm,
          :mod,
          :i_proc,
          :job_number,
          :job_user,
          :job_name,
          :i_beg_ts,
          :end_ts,
          :success :success_null,
          :abend :abend_null,
          :user_id :user_id_null,
          :username :username_null,
          :usrprf_cur)
    WITH NC;
END-PROC SaveMetrics;

// -------------------------------------------------------------------------------------------------
///
// Save remote web service information.
//
// We may want to log information about calls to remote web services such as FQDN (Fully Qualified
// Domain Name), IP address, the information sent in the request, etc.
//
// @param REQUIRED. This is the LOGMSGT.ID of the row just created in LOG_LogMsg.
// @param REQUIRED. A tpl_sdk4i_logwbrt_ds data structure.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SaveRemoteWebServiceInfo;
  DCL-PI SaveRemoteWebServiceInfo;
    i_id LIKE(tpl_sdk4i_logmsgt_ds.id) CONST;
    i_logwbrt_ds LIKEDS(tpl_sdk4i_logwbrt_ds) OPTIONS(*NULLIND) CONST;
  END-PI;

  DCL-S protocol LIKE(tpl_sdk4i_logwbrt_ds.protocol);
  DCL-S rmt_fqdn LIKE(tpl_sdk4i_logwbrt_ds.rmt_fqdn);
  DCL-S rmt_ipv4 LIKE(tpl_sdk4i_logwbrt_ds.rmt_ipv4);
  DCL-S rmt_port LIKE(tpl_sdk4i_logwbrt_ds.rmt_port);
  DCL-S rmt_api LIKE(tpl_sdk4i_logwbrt_ds.rmt_api);
  DCL-S query LIKE(tpl_sdk4i_logwbrt_ds.query);
  DCL-S req_method LIKE(tpl_sdk4i_logwbrt_ds.req_method);
  DCL-S req_body LIKE(tpl_sdk4i_logwbrt_ds.req_body);
  DCL-S rsp_code LIKE(tpl_sdk4i_logwbrt_ds.rsp_code);
  DCL-S rsp_body LIKE(tpl_sdk4i_logwbrt_ds.rsp_body);

  DCL-S protocol_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S rmt_fqdn_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S rmt_ipv4_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S rmt_port_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S rmt_api_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S query_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S req_method_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S req_body_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S rsp_code_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL
  DCL-S rsp_body_null INT(5) INZ(C_SDK4I_NULL); // Assume NULL

  protocol = i_logwbrt_ds.protocol;
  protocol_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.protocol));
  rmt_fqdn = i_logwbrt_ds.rmt_fqdn;
  rmt_fqdn_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.rmt_fqdn));
  rmt_ipv4 = i_logwbrt_ds.rmt_ipv4;
  rmt_ipv4_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.rmt_ipv4));
  rmt_port = i_logwbrt_ds.rmt_port;
  rmt_port_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.rmt_port));
  rmt_api = i_logwbrt_ds.rmt_api;
  rmt_api_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.rmt_api));
  query = i_logwbrt_ds.query;
  query_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.query));
  req_method = i_logwbrt_ds.req_method;
  req_method_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.req_method));
  req_body = i_logwbrt_ds.req_body;
  req_body_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.req_body));
  rsp_code = i_logwbrt_ds.rsp_code;
  rsp_code_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.rsp_code));
  rsp_body = i_logwbrt_ds.rsp_body;
  rsp_body_null = NIL_IndToInt(%NULLIND(i_logwbrt_ds.rsp_body));

  EXEC SQL
    INSERT INTO logwbrt (logmsgt_id, protocol, rmt_fqdn, rmt_ipv4, rmt_port, rmt_api, query,
      req_method, req_body, rsp_code, rsp_body)
    VALUES(
      :i_id,
      :protocol :protocol_null,
      :rmt_fqdn :rmt_fqdn_null,
      :rmt_ipv4 :rmt_ipv4_null,
      :rmt_port :rmt_port_null,
      :rmt_api :rmt_api_null,
      :query :query_null,
      :req_method :req_method_null,
      :req_body :req_body_null,
      :rsp_code :rsp_code_null,
      :rsp_body :rsp_body_null
      )
    WITH NC;
END-PROC SaveRemoteWebServiceInfo;

// -------------------------------------------------------------------------------------------------
///
// Save usage information.
//
// We may want to log the fact a program, procedure, etc. has been used. The LOGCFGT table allows us
// to indicate if we should track usage and how fine-grained that tracking should be (yearly,
// monthly, weekly, daily, hourly, or by the minute).
//
// Note that we use the WEEK scalar function which returns a value between 1 and 54 and this week
// value is always for the same/current year.
//
// If you want to use the WEEK_ISO scalar function instead, be aware that it returns a value between
// 1 and 53 so it's possible for the function to return a week that is in the previous or next year
// - which means you need to decide whether or not to change the year and month values to match the
// previous/next year when you encounter an edge case.
//
// @param REQUIRED. This is the LOGMSGT.ID of the row just created in LOG_LogMsg.
// @param REQUIRED. A tpl_sdk4i_logwbrt_ds data structure.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SaveUseInfo;
  DCL-PI SaveUseInfo;
    i_psds_ds LIKEDS(tpl_sdk4i_psds_ds) CONST;
    i_proc LIKE(tpl_sdk4i_loguset_ds.prc) CONST;
    i_loguset LIKE(tpl_sdk4i_logcfgt_ds.loguset) CONST;
  END-PI;

  DCL-S cur_day LIKE(tpl_sdk4i_loguset_ds.d) INZ(-1);
  DCL-S cur_hour LIKE(tpl_sdk4i_loguset_ds.hr) INZ(-1);
  DCL-S cur_minute LIKE(tpl_sdk4i_loguset_ds.mn) INZ(-1);
  DCL-S cur_month LIKE(tpl_sdk4i_loguset_ds.mnth) INZ(-1);
  DCL-S cur_timestamp TIMESTAMP INZ(*SYS);
  DCL-S cur_week LIKE(tpl_sdk4i_loguset_ds.wk) INZ(-1);
  DCL-S cur_year LIKE(tpl_sdk4i_loguset_ds.yr);
  DCL-S lib LIKE(i_psds_ds.lib);
  DCL-S mod LIKE(i_psds_ds.mod_prc);
  DCL-S pgm LIKE(i_psds_ds.pgm_prc);
  DCL-S sys LIKE(i_psds_ds.sys);
  
  // Extract data from i_psds_ds
  lib = i_psds_ds.lib;
  mod = i_psds_ds.mod_prc;
  pgm = i_psds_ds.pgm_prc;
  sys = i_psds_ds.sys;

  cur_year = %SUBDT(cur_timestamp: *YEARS: 4);

  // Populate values based on the granularity needed.
  // Nothing needs to be done for i_loguset = 'Y' since we have already populated cur_year.
  SELECT;
    WHEN (i_loguset = 'M'); // Log usage by month.
      cur_month = %SUBDT(cur_timestamp: *MONTHS: 2);
    
    WHEN (i_loguset = 'W'); // Log usage by week.
      cur_month = %SUBDT(cur_timestamp: *MONTHS: 2);
      EXEC SQL
        VALUES(WEEK(:cur_timestamp)) INTO :cur_week;
    
    WHEN (i_loguset = 'D'); // Log usage by day.
      cur_month = %SUBDT(cur_timestamp: *MONTHS: 2);
      EXEC SQL
        VALUES(WEEK(:cur_timestamp)) INTO :cur_week;
      cur_day = %SUBDT(cur_timestamp: *DAYS: 2);

    WHEN (i_loguset = 'H'); // Log usage by hour.
      cur_month = %SUBDT(cur_timestamp: *MONTHS: 2);
      EXEC SQL
        VALUES(WEEK(:cur_timestamp)) INTO :cur_week;
      cur_day = %SUBDT(cur_timestamp: *DAYS: 2);
      cur_hour = %SUBDT(cur_timestamp: *HOURS: 2);
    
    WHEN (i_loguset = 'I'); // Log usage by minute.
      cur_month = %SUBDT(cur_timestamp: *MONTHS: 2);
      EXEC SQL
        VALUES(WEEK(:cur_timestamp)) INTO :cur_week;
      cur_day = %SUBDT(cur_timestamp: *DAYS: 2);
      cur_hour = %SUBDT(cur_timestamp: *HOURS: 2);
      cur_minute = %SUBDT(cur_timestamp: *MINUTES: 2);

    OTHER; // Nothing to be done here.
  ENDSL;

  EXEC SQL
    -- MERGE or "UPSERT" (UPDATE/INSERT) for loguset.
    -- @link https://www.ibm.com/docs/en/i/7.5?topic=statements-merge
    MERGE INTO loguset AS tgt USING (
      VALUES(:sys, :lib, :pgm, :mod, :i_proc, :cur_year, :cur_month, :cur_week, :cur_day, :cur_hour, :cur_minute)
    ) AS src (sys, lib, pgm, mod, prc, yr, mnth, wk, d, hr, mn)
    ON (tgt.sys = src.sys
        AND tgt.lib = src.lib
        AND tgt.pgm = src.pgm
        AND tgt.mod = src.mod
        AND tgt.prc = src.prc
        AND tgt.yr = src.yr
        AND tgt.mnth = src.mnth
        AND tgt.wk = src.wk
        AND tgt.d = src.d
        AND tgt.hr = src.hr
        AND tgt.mn = src.mn)
    WHEN MATCHED THEN
      UPDATE SET (cnt) = (tgt.cnt + 1)
    WHEN NOT MATCHED THEN
      INSERT (sys, lib, pgm, mod, prc, yr, mnth, wk, d, hr, mn, cnt) 
      VALUES (src.sys, src.lib, src.pgm, src.mod, src.prc, src.yr, src.mnth, src.wk, src.d, src.hr, src.mn, 1)
    ELSE IGNORE
    WITH NC;
END-PROC SaveUseInfo;