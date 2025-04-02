**FREE
// TODO: implement COM_SendSMS (use Twilio?)
// -------------------------------------------------------------------------------------------------
//   This service program provides functionality related to communications such as sending a break
// message, email, or SMS (Text) message.
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
CTL-OPT TEXT('SDK4i - COM - Communication utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// COMK - COM constants, data structures, variables, and procedure definitions.
// ERRK - ERR constants, data structures, variables, and procedure definitions.
// IBMAPIK - IBM API constants, data structures, variables, and procedure definitions.
// LOGK - LOG constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// TXTK - TXT constants, data structures, variables, and procedure definitions.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/comk.rpgleinc'
/COPY '../../qcpysrc/errk.rpgleinc'
/COPY '../../qcpysrc/ibmapik.rpgleinc'
/COPY '../../qcpysrc/logk.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'
/COPY '../../qcpysrc/txtk.rpgleinc'

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
//   Send a break message.
//
//   Send a break message to another IBM i user profile using the QEZSNDMG API.
//
// @param REQUIRED. A user profile name.
// @param REQUIRED. The message to send - 494 characters maximum.
// @param OPTIONAL. A tpl_sdk4i_log_user_info_ds data structure.
//
// @return *ON if the break message was sent successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC COM_SendBreakMessage EXPORT;
  DCL-PI COM_SendBreakMessage IND;
    i_usrprf LIKE(tpl_sdk4i_com_sndmsg_usrprf) CONST;
    i_msg LIKE(tpl_sdk4i_com_sndmsg_msg) OPTIONS(*TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-DS error_ds LIKEDS(tpl_sdk4i_errc0100_ds) INZ(*LIKEDS);
  DCL-S function_requested LIKE(tpl_sdk4i_binary4);
  DCL-S sent LIKE(tpl_sdk4i_binary4);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  MONITOR;
    QEZSNDMG('*INFO': '*BREAK': i_msg: %LEN(i_msg): i_usrprf: 1: sent: function_requested:
      error_ds: 'N': *BLANKS: '*USR');
  ON-EXCP 'CPF1EA0';
    log_msg = 'Not authorized to send message to *ALL or *ALLACT.';
  ON-EXCP 'CPF1EBA';
    log_msg = 'Parameters passed on CALL do not match those required.';
  ON-EXCP 'CPF1EBB';
    log_msg = 'Value &1 not valid for list of display station names.';
  ON-EXCP 'CPF1EBC';
    log_msg = 'At least one user or display station must be specified.';
  ON-EXCP 'CPF1EBD';
    log_msg = 'Message text cannot be blank.';
  ON-EXCP 'CPF1EBE';
    log_msg = 'Display station names cannot be used with the Send a Message display.';
  ON-EXCP 'CPF1EBF';
    log_msg = 'Value for Use Send a Message display not valid.';
  ON-EXCP 'CPF1EB2';
    log_msg = 'Delivery mode must be *BREAK or *NORMAL.';
  ON-EXCP 'CPF1EB3';
    log_msg = 'Value forlength of message text must be 0 - 494.';
  ON-EXCP 'CPF1EB4';
    log_msg = 'Number of user profiles names not valid.';
  ON-EXCP 'CPF1EB5';
    log_msg = 'Value for number of user profile name must be 0 - 299.';
  ON-EXCP 'CPF1EB6';
    log_msg = 'Program &1 cannot be run as a batch job.';
  ON-EXCP 'CPF1EB7';
    log_msg = '*ALL not allowed with other user profile names.';
  ON-EXCP 'CPF1EB8';
    log_msg = 'Value &1 for name type indicator not valid.';
  ON-EXCP 'CPF1EB9';
    log_msg = 'Value &1 not valid for list of user profile names.';
  ON-EXCP 'CPF1E99';
    log_msg = 'Unexpected error occurred.';
  ON-EXCP 'CPF24B3';
    log_msg = 'Message type &1 not valid.';
  ON-EXCP 'CPF24B4';
    log_msg = 'Severe error while addressing parameter list.';
  ON-EXCP 'CPF2403';
    log_msg = 'Message queue &1 in &2 not found.';
  ON-EXCP 'CPF2408';
    log_msg = 'Not authorized to message queue &1.';
  ON-EXCP 'CPF3C90';
    log_msg = 'Literal value cannot be changed.';
  ON-EXCP 'CPF3CF1';
    log_msg = 'Error code parameter not valid.';
  ON-EXCP 'CPF9871';
    log_msg = 'Error occurred while processing.';
  ON-EXCP 'CPF9872';
    log_msg = 'Program or service program &1 in library &2 ended. Reason code &3.';
  ON-ERROR;
    log_msg = 'Unknown error occurred when executing QEZSNDMG.';
    log_is_successful = *OFF;
  ENDMON;

  IF (log_msg <> *BLANKS);
    log_event_info_ds.fac_id = 3; // System Daemons.
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RESET log_event_info_ds;
  ENDIF;

  RETURN log_is_successful;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 3; // System Daemons.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC COM_SendBreakMessage;

// -------------------------------------------------------------------------------------------------
///
//   Send an email.
//
//   This procedure can send an email with a message of any size, with any number of attachements,
// digitally signed, and encrypted.
//
// @param REQUIRED. The number of recipients. Must be greater than 0 and less than or equal to
//   C_SDK4I_COM_EMAIL_MAX_RECIPIENTS.
// @param REQUIRED. An array of data structures containing the email address and email type (To,
//   CC, BCC) for each address.
// @param REQUIRED. The length of the subject string in bytes.
// @param REQUIRED. A pointer to the variable holding the subject string.
// @param REQUIRED. The length of the message in bytes.
// @param REQUIRED. A pointer to the variable holding the message to be sent.
// @param OPTIONAL. The number of attachments. Must be 0 to C_SDK4I_COM_EMAIL_MAX_ATTACHMENTS.
//   Defaults to 0.
// @param OPTIONAL. An array of strings containing the full IFS path to a file to be attached to
//   the email.
// @param OPTIONAL. A data structure holding logging information about the user.
// @param OPTIONAL. The length of the password in bytes.
// @param OPTIONAL. The password needed for signing/encrypting.
// @param OPTIONAL. A flag indicating if the message should be signed. Defaults to *OFF.
// @param OPTIONAL. A flag indicating if the message should be encrypted. Defaults to *OFF.
//
// @return *ON if the email was sent successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC COM_SendEmail EXPORT;
  DCL-PI COM_SendEmail IND;
    i_recipient_count LIKE(tpl_sdk4i_unsigned_binary4) CONST;
    i_recipient_array LIKEDS(tpl_sdk4i_com_email_recipient_ds) DIM(C_SDK4I_COM_EMAIL_MAX_RECIPIENTS);
    i_subject_length LIKE(tpl_sdk4i_unsigned_binary4) CONST;
    i_subject POINTER VALUE;
    i_msg_length LIKE(tpl_sdk4i_unsigned_binary4) CONST;
    i_msg POINTER VALUE;
    i_attachment_count LIKE(tpl_sdk4i_unsigned_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_attachment_array LIKE(tpl_sdk4i_com_email_attachment_name) DIM(C_SDK4I_COM_EMAIL_MAX_ATTACHMENTS) OPTIONS(*NOPASS: *OMIT);
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
    i_password_length LIKE(tpl_sdk4i_unsigned_binary4) OPTIONS(*NOPASS: *OMIT) CONST;
    i_password POINTER VALUE OPTIONS(*NOPASS);
    i_is_signed IND OPTIONS(*NOPASS: *OMIT) CONST;
    i_is_encrypted IND OPTIONS(*NOPASS: *OMIT) CONST;
  END-PI;

  DCL-DS attachment_ds LIKEDS(tpl_sdk4i_atch0100_ds) INZ(*LIKEDS);
  DCL-DS note_ds LIKEDS(tpl_sdk4i_note0100_ds) INZ(*LIKEDS);
  DCL-DS recipient_ds LIKEDS(tpl_sdk4i_rcpt0100_ds) INZ(*LIKEDS);
  DCL-DS s_diagnostics_ds LIKEDS(tpl_sdk4i_err_sql_diagnostics_ds) INZ(*LIKEDS);
  DCL-S attachment_count LIKE(i_attachment_count);
  DCL-S attachment_count_actual LIKE(i_attachment_count) INZ(0);
  DCL-S attachment_data_size LIKE(tpl_sdk4i_unsigned_binary4);
  DCL-S attachment_format CHAR(8) INZ('ATCH0000');
  DCL-S is_encrypted LIKE(i_is_encrypted) INZ(*OFF);
  DCL-S is_signed LIKE(i_is_signed) INZ(*OFF);
  DCL-S note_data_size LIKE(tpl_sdk4i_unsigned_binary4);
  DCL-S note_format CHAR(8) INZ('NOTE0100');
  DCL-S offset LIKE(tpl_sdk4i_unsigned_binary4);
  DCL-S password_length LIKE(i_password_length) INZ(0);
  DCL-S p_attachment POINTER;
  DCL-S p_note POINTER;
  DCL-S p_password POINTER;
  DCL-S p_recipient POINTER;
  DCL-S p_temp POINTER;
  DCL-S recipient_data_size LIKE(tpl_sdk4i_unsigned_binary4);
  DCL-S recipient_format CHAR(8) INZ('RCPT0100');
  DCL-S s_stmt LIKE(tpl_sdk4i_sql_statement);
  DCL-S temp_attachment_path_name LIKE(tpl_sdk4i_com_email_attachment_name) INZ('');
  DCL-S temp_ccsid LIKE(tpl_sdk4i_binary4) INZ(1208);
  DCL-S temp_data_size LIKE(tpl_sdk4i_binary8) INZ(0);
  DCL-S temp_extension LIKE(tpl_sdk4i_com_email_attachment_name) INZ('');
  DCL-S x LIKE(i_recipient_count);

  // ===========================================================================
  // Bring in variables associated with logging.
  // ===========================================================================
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // ===========================================================================
  // See if the caller is overriding any defaults.
  // ===========================================================================
  IF (%PARMS >= %PARMNUM(i_is_signed) AND %ADDR(i_is_signed) <> *NULL);
    is_signed = i_is_signed;
  ENDIF;

  IF (%PARMS >= %PARMNUM(i_is_encrypted) AND %ADDR(i_is_encrypted) <> *NULL);
    is_encrypted = i_is_encrypted;
  ENDIF;

  // In order to send any attachments, we must have an i_attachment_count > 0 and an array of
  // attachment paths provided to us.
  IF (%PARMS >= %PARMNUM(i_attachment_count) AND %ADDR(i_attachment_count) <> *NULL AND i_attachment_count > 0 AND
      %PARMS >= %PARMNUM(i_attachment_array) AND %ADDR(i_attachment_array) <> *NULL);
    attachment_count = i_attachment_count;
  ENDIF;

  // In order to use a password, we must have a valid password length and a password both.
  IF (%PARMS >= %PARMNUM(i_password_length) AND %ADDR(i_password_length) <> *NULL AND i_password_length > 0);
    IF (%PARMS >= %PARMNUM(i_password) AND %ADDR(i_password) <> *NULL AND i_password <> *NULL);
      password_length = i_password_length;
      p_password = i_password;
    ENDIF;
  ENDIF;

  // ===========================================================================
  // Part 1 - Recipients.
  // ===========================================================================
  // Allocate memory for the recipient data. We deallocate this memory in the
  // ON-EXIT section at the end of this procedure.
  FOR x = 1 TO i_recipient_count;
    recipient_data_size += %LEN(recipient_ds); // 16 bytes each
    recipient_data_size += %LEN(i_recipient_array(x).address);
  ENDFOR;
  MONITOR;
    p_recipient = %ALLOC(recipient_data_size);
  ON-ERROR 00425;
    RESET log_event_info_ds;
    log_event_info_ds.fac_id = 2; // Mail server
    log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(recipient_data_size: '1')) +') for email recipients: 00425 - requested allocation size is out of range.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ON-ERROR 00426;
    RESET log_event_info_ds;
    log_event_info_ds.fac_id = 2; // Mail server
    log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(recipient_data_size: '1')) +') for email recipients: 00426 - error occurred during memory allocation.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ON-ERROR;
    RESET log_event_info_ds;
    log_event_info_ds.fac_id = 2; // Mail server
    log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(recipient_data_size: '1')) +') for email recipients: Unknown error.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDMON;

  // Build the recipient data in memory.
  // There will be i_recipient_count copies of the recipient_ds data structure.
  // Then there will be all the email addresses we are sending this message to.
  offset = i_recipient_count * %LEN(recipient_ds);
  p_temp = p_recipient; // Start at the beginning of our allocated memory.
  FOR x = 1 TO i_recipient_count; // Loop through all recipients.
    RESET recipient_ds;
    recipient_ds.input_ccsid = 1208;
    SELECT;
      WHEN (%UPPER(%TRIM(i_recipient_array(x).type)) = 'TO');
        recipient_ds.recipient_type = 0;
      WHEN (%UPPER(%TRIM(i_recipient_array(x).type)) = 'CC');
        recipient_ds.recipient_type = 1;
      WHEN (%UPPER(%TRIM(i_recipient_array(x).type)) = 'BCC');
        recipient_ds.recipient_type = 2;
      OTHER;
        recipient_ds.recipient_type = 0; // Default to TO.
    ENDSL;
    recipient_ds.offset_to_recipient_address = offset;
    recipient_ds.length_of_recipient_address = %LEN(i_recipient_array(x).address);

    //   We use the CPYBWP (Copy Bytes with Pointers) function because the data is aligned on a
    // 16-byte boundary.
    cpybwp(p_temp: %ADDR(recipient_ds): %LEN(recipient_ds));

    //   We use the MEMCPY function because the data is almost certainly NOT aligned on a 16-byte
    // boundary.
    memcpy(p_recipient + offset: %ADDR(i_recipient_array(x).address: *DATA): %LEN(i_recipient_array(x).address));

    // Increment the offset so we can write out the email address of the next recipient.
    offset += recipient_ds.length_of_recipient_address;

    p_temp += %LEN(recipient_ds); // Point to the next recipient data structure.
  ENDFOR;

  // ===========================================================================
  // Part 2 - Note.
  // ===========================================================================
  // Allocate memory for the note data. We deallocate this memory in the
  // ON-EXIT section at the end of this procedure.
  note_data_size = %LEN(note_ds) + i_subject_length + i_msg_length + password_length;

  MONITOR;
    p_note = %ALLOC(note_data_size);
  ON-ERROR 00425;
    RESET log_event_info_ds;
    log_event_info_ds.fac_id = 2; // Mail server
    log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(note_data_size: '1')) +') for email note: 00425 - requested allocation size is out of range.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ON-ERROR 00426;
    RESET log_event_info_ds;
    log_event_info_ds.fac_id = 2; // Mail server
    log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(note_data_size: '1')) +') for email note: 00426 - error occurred during memory allocation.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ON-ERROR;
    RESET log_event_info_ds;
    log_event_info_ds.fac_id = 2; // Mail server
    log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(note_data_size: '1')) +') for email note: Unknown error.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    log_is_successful = *OFF;
    RETURN log_is_successful;
  ENDMON;

  // Populate the note_ds data structure.
  note_ds.note_security_level = 0;
  note_ds.note_content_type = 0;
  note_ds.input_ccsid = 1208;
  note_ds.length_of_password = 0;
  note_ds.length_of_note = i_msg_length;
  note_ds.length_of_subject = i_subject_length;
  note_ds.offset_to_password = 0;
  note_ds.offset_to_subject = %LEN(note_ds);
  note_ds.offset_to_note = %LEN(note_ds) + i_subject_length;
  IF (password_length > 0);
    note_ds.length_of_password = password_length;
    note_ds.offset_to_password = %LEN(note_ds) + i_subject_length + i_msg_length;
    SELECT;
      WHEN (is_signed AND is_encrypted);
        note_ds.note_security_level = 3;
      WHEN (is_signed);
        note_ds.note_security_level = 1;
      WHEN (is_encrypted);
        note_ds.note_security_level = 2;
      OTHER;
        note_ds.note_security_level = 0;
        note_ds.offset_to_password = 0;
        note_ds.length_of_password = 0;
        RESET log_event_info_ds;
        log_event_info_ds.fac_id = 2; // Mail server
        log_msg = 'A password was provided but the caller did not indicate the email should be signed or encrypted. ' +
          'Proceeding as if no password was provided, sending the email unsigned and unencrypted.';
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDSL;
    IF (is_signed);

    ENDIF;
  ENDIF;

  // First, copy the note_ds data to the memory allocated to p_note.
  memcpy(p_note: %ADDR(note_ds): %LEN(note_ds));
  p_temp = p_note + %LEN(note_ds);

  // Next, copy the subject to the memory allocated to p_note.
  memcpy(p_temp: i_subject: i_subject_length);
  p_temp += i_subject_length;

  // Next, copy the message to the memory allocated to p_note.
  memcpy(p_temp: i_msg: i_msg_length);
  p_temp += i_msg_length;

  // Next, copy the password (if there is one) to the memory allocated to p_note.
  IF (note_ds.note_security_level > 0);
    memcpy(p_temp: i_password: i_password_length);
  ENDIF;

  // ===========================================================================
  // Part 3 - Attachments.
  // ===========================================================================
  IF (attachment_count > 0);
    // We need to allocate memory to hold information about the attachments.
    FOR x = 1 TO attachment_count;
      attachment_data_size += %LEN(attachment_ds);
      attachment_data_size += %LEN(i_attachment_array(x));
    ENDFOR;
    MONITOR;
      p_attachment = %ALLOC(attachment_data_size);
    ON-ERROR 00425;
      RESET log_event_info_ds;
      log_event_info_ds.fac_id = 2; // Mail server
      log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(attachment_data_size: '1')) +') for email recipients: 00425 - requested allocation size is out of range.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      log_is_successful = *OFF;
      RETURN log_is_successful;
    ON-ERROR 00426;
      RESET log_event_info_ds;
      log_event_info_ds.fac_id = 2; // Mail server
      log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(attachment_data_size: '1')) +') for email recipients: 00426 - error occurred during memory allocation.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      log_is_successful = *OFF;
      RETURN log_is_successful;
    ON-ERROR;
      RESET log_event_info_ds;
      log_event_info_ds.fac_id = 2; // Mail server
      log_msg = 'Failed to allocate memory ('+ %TRIM(%EDITC(attachment_data_size: '1')) +') for email recipients: Unknown error.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      log_is_successful = *OFF;
      RETURN log_is_successful;
    ENDMON;

    // We need to get information about each of the attachments. We could use the Qp0lGetAttr() or
    // stat() functions (and probably some other methods) but it's easier to call the
    // IFS_OBJECT_STATISTICS table function in Db2 for i.
    offset = attachment_count * %LEN(attachment_ds);
    p_temp = p_attachment;
    FOR x = 1 TO attachment_count;
      s_stmt = 'SELECT ccsid, data_size, SUBSTRING(path_name, LOCATE_IN_STRING(path_name, '+
                  TXT_Q('.') +', -1) + 1) ' +
               'FROM TABLE (' +
                 'qsys2.ifs_object_statistics(START_PATH_NAME => ?)' +
               ') AS x';

      EXEC SQL PREPARE s_attachment FROM :s_stmt;
      IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
        RESET log_cause_info_ds;
        RESET log_event_info_ds;
        log_cause_info_ds.sstate =s_diagnostics_ds.returned_sqlstate;
        log_cause_info_ds.sstmt = s_stmt;
        log_event_info_ds.fac_id = 2; // Mail server.
        log_msg = 'Error with PREPARE of SQL statement. ' + s_diagnostics_ds.err_msg;
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
        log_is_successful = *OFF;
        RETURN log_is_successful;
      ENDIF;

      EXEC SQL DECLARE c_attachment CURSOR FOR s_attachment;
      IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
        RESET log_cause_info_ds;
        RESET log_event_info_ds;
        log_cause_info_ds.sstate =s_diagnostics_ds.returned_sqlstate;
        log_cause_info_ds.sstmt = s_stmt;
        log_event_info_ds.fac_id = 2; // Mail server.
        log_msg = 'DECLARE failed. ' + s_diagnostics_ds.err_msg;
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
        log_is_successful = *OFF;
        RETURN log_is_successful;
      ENDIF;

      temp_attachment_path_name = i_attachment_array(x);
      EXEC SQL OPEN c_attachment USING :temp_attachment_path_name;
      IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
        RESET log_cause_info_ds;
        RESET log_event_info_ds;
        log_cause_info_ds.sstate =s_diagnostics_ds.returned_sqlstate;
        log_cause_info_ds.sstmt = s_stmt;
        log_event_info_ds.fac_id = 2; // Mail server.
        log_msg = 'OPEN failed. ' + s_diagnostics_ds.err_msg;
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
        log_is_successful = *OFF;
        RETURN log_is_successful;
      ENDIF;

      EXEC SQL FETCH c_attachment INTO :temp_ccsid, :temp_data_size, :temp_extension;
      // The caller told us to attach a file but that file does not exist or we do not have the
      // authority to see it. Close the cursor and process the next attachment.
      IF (SQLSTATE = C_SDK4I_SQLSTATE_NOT_FOUND);
        EXEC SQL CLOSE c_attachment;
        ITER;
      ENDIF;
      IF (ERR_IsSQLError(s_diagnostics_ds: *OMIT: *OMIT: log_user_info_ds));
        RESET log_cause_info_ds;
        RESET log_event_info_ds;
        log_cause_info_ds.sstate =s_diagnostics_ds.returned_sqlstate;
        log_cause_info_ds.sstmt = s_stmt;
        log_event_info_ds.fac_id = 2; // Mail server.
        log_msg = 'FETCH failed. ' + s_diagnostics_ds.err_msg;
        LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
        log_is_successful = *OFF;
        RETURN log_is_successful;
      ENDIF;

      // If we made it here, we are going to have at least one attachment so update the format.
      attachment_count_actual += 1;
      attachment_format = 'ATCH0100';

      attachment_ds.input_ccsid = temp_ccsid;
      SELECT;
        WHEN (%LOWER(temp_extension) = 'txt' OR %LOWER(temp_extension) = 'text' OR %LOWER(temp_extension) = 'csv');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_TEXT;
        WHEN (%LOWER(temp_extension) = 'htm' OR %LOWER(temp_extension) = 'html' OR temp_extension = 'xhtml');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_HTML;
        WHEN (%LOWER(temp_extension) = 'xml' OR %LOWER(temp_extension) = 'xsl');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_XML;
        WHEN (%LOWER(temp_extension) = 'ogg');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_APP_OGG;
        WHEN (%LOWER(temp_extension) = 'pdf');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_APP_PDF;
        WHEN (%LOWER(temp_extension) = 'vsd');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_APP_VISIO;
        WHEN (%LOWER(temp_extension) = 'zip');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_APP_ZIP;
        WHEN (%LOWER(temp_extension) = 'doc' OR %LOWER(temp_extension) = 'docx');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_MSWORD;
        WHEN (%LOWER(temp_extension) = 'ppt' OR %LOWER(temp_extension) = 'pptx');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_VND_MS_PPT;
        WHEN (%LOWER(temp_extension) = 'xls' OR %LOWER(temp_extension) = 'xlsx');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_VND_MS_XLS;
        WHEN (%LOWER(temp_extension) = 'wav');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_AUDIO_WAV;
        WHEN (%LOWER(temp_extension) = 'bmp');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_IMG_BMP;
        WHEN (%LOWER(temp_extension) = 'gif');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_IMG_GIF;
        WHEN (%LOWER(temp_extension) = 'jpg' OR %LOWER(temp_extension) = 'jpeg');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_IMG_JPEG;
        WHEN (%LOWER(temp_extension) = 'png');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_IMG_PNG;
        WHEN (%LOWER(temp_extension) = 'mpeg');
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_VIDEO_MPEG;
        OTHER;
          attachment_ds.content_type = C_SDK4I_COM_EMAIL_ATTACHMENT_TYPE_APP_OCTET_STREAM;
      ENDSL;
      attachment_ds.offset_to_filename = offset;
      attachment_ds.length_of_filename = %LEN(i_attachment_array(x));

      // Copy bytes from the attachment_ds data structure to our allocated memory.
      cpybwp(p_temp: %ADDR(attachment_ds): %LEN(attachment_ds));

      // Copy the full pathname of the attachment to our allocated memory.
      memcpy(p_attachment + offset: %ADDR(i_attachment_array(x): *DATA): %LEN(i_attachment_array(x)));

      // Increment the offset so we can write out the pathname of the next attachment.
      offset += %LEN(i_attachment_array(x));

      // Change our temporary pointer so we can copy bytes from attachment_ds for the next attachment.
      p_temp += %LEN(attachment_ds);

      // Close our cursor.
      EXEC SQL CLOSE c_attachment;
    ENDFOR;
  ENDIF;

  //   It is possible the caller gave us at least one file they wanted to attach - but those files
  // do not exist or we do not have permission to them. If that is the case, we need to send the
  // email as if there were no attachments. Free up the memory we allocated for p_attachment and
  // set the pointer to NULL.
  IF (attachment_count_actual = 0);
    DEALLOC(N) p_attachment;
  ENDIF;

  // ===========================================================================
  // Part 4 - wrap it all up and send the email.
  // ===========================================================================
  QtmsCreateSendEmail(p_recipient: // Recipient data
                      i_recipient_count: // Recipient count
                      %ADDR(recipient_format): // Format of recipient data
                      p_note: // Email (subject, message)
                      %ADDR(note_format): // Format of email data
                      p_attachment: // Attachment data
                      attachment_count_actual: // Attachment count
                      %ADDR(attachment_format) // Format of attachment data
  );

  RETURN log_is_successful;

  RESET log_event_info_ds; // This cannot be done in the ON-EXIT section.
  ON-EXIT log_is_abend;
    DEALLOC(N) p_attachment;
    DEALLOC(N) p_note;
    DEALLOC(N) p_recipient;
    EXEC SQL CLOSE c_attachment;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_event_info_ds.fac_id = 2; // Mail system.
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC COM_SendEmail;

// -------------------------------------------------------------------------------------------------
///
//   Send an SMS
//
//   Send a Short Message Service (ie "text") message.
//
// @param OPTIONAL. A data structure holding logging information about the user.
//
// @return *ON if the SMS message was sent successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC COM_SendSMS EXPORT;
  DCL-PI COM_SendSMS IND;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  RETURN log_is_successful;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC COM_SendSMS;