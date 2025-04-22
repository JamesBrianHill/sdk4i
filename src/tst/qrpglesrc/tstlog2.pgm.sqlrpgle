**FREE
// -------------------------------------------------------------------------------------------------
//   This test program invokes various LOG procedures for demonstration purposes.
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
CTL-OPT MAIN(tstlog2);
CTL-OPT TEXT('SDK4i - TST - Test logging utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// LOGK - LOG constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/logk.rpgleinc'
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
//   Title.
//
//   Description.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC tstlog2;
  DCL-PI tstlog2;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log that we were here.
  log_msg = 'Entering the TSTLOG2 program...';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  do_level0_emergency();
  do_level1_alert();
  do_level2_critical();
  do_level3_error();
  do_level4_warning();
  do_level5_notice();
  do_level6_informational();
  do_level7_debug();

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
    EXEC SQL COMMIT;
END-PROC tstlog2;

// -------------------------------------------------------------------------------------------------
///
//   Test level 0 (Emergency).
//
//   Log a message at the C_SDK4I_LL_EMG (Emergency) level.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC do_level0_emergency;
  DCL-PI do_level0_emergency;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log a message at the emergency level.
  log_event_info_ds.ll_id = C_SDK4I_LL_EMG;
  log_msg = 'This is an emergency level (0) message from TSTLOG2.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC do_level0_emergency;

// -------------------------------------------------------------------------------------------------
///
//   Test level 1 (Alert).
//
//   Log a message at the C_SDK4I_LL_ALT (Alert) level.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC do_level1_alert;
  DCL-PI do_level1_alert;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log a message at the alert level.
  log_event_info_ds.ll_id = C_SDK4I_LL_ALT;
  log_msg = 'This is an alert level (1) message from TSTLOG2.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC do_level1_alert;

// -------------------------------------------------------------------------------------------------
///
//   Test level 2 (Critical).
//
//   Log a message at the C_SDK4I_LL_CRT (Critical) level.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC do_level2_critical;
  DCL-PI do_level2_critical;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log a message at the critical level.
  log_event_info_ds.ll_id = C_SDK4I_LL_CRT;
  log_msg = 'This is a critical level (2) message from TSTLOG2.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC do_level2_critical;

// -------------------------------------------------------------------------------------------------
///
//   Test level 3 (Error).
//
//   Log a message at the C_SDK4I_LL_ERR (Error) level. Note that since this is the default level,
// we do not need to explicitly set a log level like we do in other procedures.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC do_level3_error;
  DCL-PI do_level3_error;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log a message at the error level.
  log_msg = 'This is an error level (3) message from TSTLOG2.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC do_level3_error;

// -------------------------------------------------------------------------------------------------
///
//   Test level 4 (Warning).
//
//   Log a message at the C_SDK4I_LL_WRN (Warning) level.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC do_level4_warning;
  DCL-PI do_level4_warning;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log a message at the warning level.
  log_event_info_ds.ll_id = C_SDK4I_LL_WRN;
  log_msg = 'This is a warning level (4) message from TSTLOG2.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC do_level4_warning;

// -------------------------------------------------------------------------------------------------
///
//   Test level 5 (Notice).
//
//   Log a message at the C_SDK4I_LL_NOT (Notice) level.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC do_level5_notice;
  DCL-PI do_level5_notice;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log a message at the notice level.
  log_event_info_ds.ll_id = C_SDK4I_LL_NOT;
  log_msg = 'This is a notice level (5) message from TSTLOG2.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC do_level5_notice;

// -------------------------------------------------------------------------------------------------
///
//   Test level 6 (Informational).
//
//   Log a message at the C_SDK4I_LL_INF (Informational) level.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC do_level6_informational;
  DCL-PI do_level6_informational;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log a message at the informational level.
  log_event_info_ds.ll_id = C_SDK4I_LL_INF;
  log_msg = 'This is an informational level (6) message from TSTLOG2.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC do_level6_informational;

// -------------------------------------------------------------------------------------------------
///
//   Test level 7 (Debug).
//
//   Log a message at the C_SDK4I_LL_DBG (Debug) level.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC do_level7_debug;
  DCL-PI do_level7_debug;
  END-PI;

  /COPY '../../qcpysrc/logvar2k.rpgleinc'

  // Log a message at the debug level.
  log_event_info_ds.ll_id = C_SDK4I_LL_DBG;
  log_msg = 'This is a debug level (7) message from TSTLOG2.';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC do_level7_debug;