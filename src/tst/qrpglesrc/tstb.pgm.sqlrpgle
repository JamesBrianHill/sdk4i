**FREE
// -------------------------------------------------------------------------------------------------
//   This test program invokes various procedures in the SDK4i modules.
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
/COPY '/home/hillb/sdk4i/src/qcpysrc/ctloptpgmk.rpgleinc'
CTL-OPT MAIN(tstb);
CTL-OPT TEXT('SDK4i - TST - PGM');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// LOGK - LOG constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// -------------------------------------------------------------------------------------------------
/COPY '/home/hillb/sdk4i/src/qcpysrc/logk.rpgleinc'
/COPY '/home/hillb/sdk4i/src/qcpysrc/psdsk.rpgleinc'

// -------------------------------------------------------------------------------------------------
// Pull in column definitions.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Define global constants, template data structures, and template variables.
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Set SQL options before any executable code but after all global Definition Specifications.
// -------------------------------------------------------------------------------------------------
/COPY '/home/hillb/sdk4i/src/qcpysrc/sqloptk.rpgleinc'

// -------------------------------------------------------------------------------------------------
///
//   Title.
//
//   Description.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC tstb;
  DCL-PI tstb EXTPGM;
    i_prc PACKED(1:0) CONST;
  END-PI;

  /COPY '/home/hillb/sdk4i/src/qcpysrc/logvar2k.rpgleinc'

  SELECT;
    WHEN (i_prc = 1);
      tstb1();
    WHEN (i_prc = 2);
      tstb2();
    OTHER;
      tstb3();
  ENDSL;

  // Log that we were here.
  log_msg = 'x';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
    EXEC SQL COMMIT;
END-PROC tstb;

// -------------------------------------------------------------------------------------------------
///
//   Title.
//
//   Description.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC tstb1;
  DCL-PI tstb1;
  END-PI;

  /COPY '/home/hillb/sdk4i/src/qcpysrc/logvar2k.rpgleinc'

  // Log that we were here.
  log_msg = '1';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC tstb1;

// -------------------------------------------------------------------------------------------------
///
//   Title.
//
//   Description.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC tstb2;
  DCL-PI tstb2;
  END-PI;

  /COPY '/home/hillb/sdk4i/src/qcpysrc/logvar2k.rpgleinc'

  // Log that we were here.
  log_msg = '2';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC tstb2;

// -------------------------------------------------------------------------------------------------
///
//   Title.
//
//   Description.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC tstb3;
  DCL-PI tstb3;
  END-PI;

  /COPY '/home/hillb/sdk4i/src/qcpysrc/logvar2k.rpgleinc'

  // Log that we were here.
  log_msg = 'Other';
  LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);

  ON-EXIT log_is_abend;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC tstb3;