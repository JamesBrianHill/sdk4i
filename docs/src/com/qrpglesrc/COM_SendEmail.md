**COM_SendEmail**

---

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`COM_SendEmail` constructs and sends an email with optional attachments using IBM i APIs and Db2 for i table functions. The procedure accepts an array of recipients, subject and message pointers/lengths, optional content-type and attachment lists, and optional security parameters (password, sign/encrypt flags). It builds in-memory payloads for recipients, the email note (subject + message + optional password), and attachments, then calls a platform-specific helper (`API_CreateAndSendEmail`) to deliver the message.

The implementation:

* Is NOT limited to 5000 characters like some commands/APIs - you can send messages as large as mail systems will allow.
* Allocates contiguous memory buffers for recipients, note, and attachments using RPG pointer/allocator built-ins.
* Copies structures and variable-length data into those buffers (using internal helper APIs such as `API_CopyMemory` and `API_CopyWithPointer`).
* Uses the Db2 for i table function [`qsys2.ifs_object_statistics`](https://www.ibm.com/docs/en/i/7.6.0?topic=services-ifs-object-statistics-table-function) to inspect attachment files (CCSID, size, and filename).
* Maps file extensions to MIME content types and prepares attachment descriptors.
* Invokes `API_CreateAndSendEmail` with formatted payloads to create/send the email.
* Uses [`MONITOR` / `ON-ERROR` / `ON-EXCP`](https://www.ibm.com/docs/en/i/7.6.0?topic=codes-monitor-begin-monitor-group) blocks for runtime exception handling and logs errors through the centralized logging procedure `LOG_LogMsg`.

---

## Example Usage

```rpgle
DCL-PROC SendEmail;
  DCL-PI SendEmail;
    i_dsc LIKE(tpl_sdk4i_loglvlt_ds.dsc) CONST;
    i_sys LIKE(tpl_sdk4i_logmsgt_ds.sys) CONST;
    i_lib LIKE(tpl_sdk4i_logmsgt_ds.lib) CONST;
    i_pgm LIKE(tpl_sdk4i_logmsgt_ds.pgm) CONST;
    i_mod LIKE(tpl_sdk4i_logmsgt_ds.mod) CONST;
    i_prc LIKE(tpl_sdk4i_logmsgt_ds.prc) CONST;
    i_usrprf_cur LIKE(tpl_sdk4i_logmsgt_ds.usrprf_cur) CONST;
    i_msg LIKE(tpl_sdk4i_logmsgt_ds.msg) CONST;
    i_job VARCHAR(28)  CONST;
    i_sstate LIKE(tpl_sdk4i_logmsgt_ds.sstate) CONST;
    i_errcode LIKE(tpl_sdk4i_logmsgt_ds.errcode) CONST;
    i_errdata LIKE(tpl_sdk4i_logmsgt_ds.errdata) CONST;
  END-PI;

  // -----------------------------------------------
  // Define local variables.
  // -----------------------------------------------
  DCL-DS email_recipients LIKEDS(tpl_sdk4i_com_email_recipient_ds) DIM(C_SDK4I_COM_EMAIL_MAX_RECIPIENTS);

  //   The size of the subject and message are both arbitrary - you should use values that make
  // sense for your application and will work best with current email systems.
  DCL-S email_subject VARCHAR(50) CCSID(*UTF8) INZ('Template Event Handler');
  DCL-S email_message VARCHAR(C_SDK4I_SIZE_8KI) CCSID(*UTF8);

  /COPY '/opt/sdk4i/src/qcpysrc/logvar2k.rpgleinc'

  // -----------------------------------------------
  // Main logic.
  // -----------------------------------------------
  email_recipients(1).address = 'someone@example.com';
  email_recipients(1).type = 'TO';

  email_message = '<!doctype html><html lang="en">'+
    '<head>'+
      '<meta name="viewport" content="width=device-width, initial-scale=1.0">'+
      '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'+
      '<title>Template Event Handler</title>'+
      '<style media="all" type="text/css">'+
        '@media all {'+
          '.btn-primary table td:hover {'+
            'background-color: #ec0867 !important;'+
          '}'+
          '.btn-primary a:hover {'+
            'background-color: #ec0867 !important;'+
            'border-color: #ec0867 !important;'+
          '}'+
        '}'+
        '@media only screen and (max-width: 640px) {'+
          '.main p,'+
          '.main td,'+
          '.main span {'+
            'font-size: 16px !important;'+
          '}'+
          '.wrapper {'+
            'padding: 8px !important;'+
          '}'+
          '.content {'+
            'padding: 0 !important;'+
          '}'+
          '.container {'+
            'padding: 0 !important;'+
            'padding-top: 8px !important;'+
            'width: 100% !important;'+
          '}'+
          '.main {'+
            'border-left-width: 0 !important;'+
            'border-radius: 0 !important;'+
            'border-right-width: 0 !important;'+
          '}'+
          '.btn table {'+
            'max-width: 100% !important;'+
            'width: 100% !important;'+
          '}'+
          '.btn a {'+
            'font-size: 16px !important;'+
            'max-width: 100% !important;'+
            'width: 100% !important;'+
          '}'+
        '}'+
        '@media all {'+
          '.ExternalClass {'+
            'width: 100%;'+
          '}'+
          '.ExternalClass,'+
          '.ExternalClass p,'+
          '.ExternalClass span,'+
          '.ExternalClass font,'+
          '.ExternalClass td,'+
          '.ExternalClass div {'+
            'line-height: 100%;'+
          '}'+
          '.apple-link a {'+
            'color: inherit !important;'+
            'font-family: inherit !important;'+
            'font-size: inherit !important;'+
            'font-weight: inherit !important;'+
            'line-height: inherit !important;'+
            'text-decoration: none !important;'+
          '}'+
          '#MessageViewBody a {'+
            'color: inherit;'+
            'text-decoration: none;'+
            'font-size: inherit;'+
            'font-family: inherit;'+
            'font-weight: inherit;'+
            'line-height: inherit;'+
          '}'+
        '}'+
      '</style>'+
    '</head>'+
    '<body style="font-family: Helvetica, sans-serif; -webkit-font-smoothing: antialiased; font-size: 16px; line-height: 1.3; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f4f5f6; margin: 0; padding: 0;">'+
      '<table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #f4f5f6; width: 100%;" width="100%" bgcolor="#f4f5f6">'+
        '<tr>'+
          '<td style="font-family: Helvetica, sans-serif; font-size: 16px; vertical-align: top;" valign="top">&nbsp;</td>'+
          '<td class="container" style="font-family: Helvetica, sans-serif; font-size: 16px; vertical-align: top; max-width: 600px; padding: 0; padding-top: 24px; width: 600px; margin: 0 auto;" width="600" valign="top">'+
            '<div class="content" style="box-sizing: border-box; display: block; margin: 0 auto; max-width: 600px; padding: 0;">'+

              '<!-- START CENTERED WHITE CONTAINER -->'+
              '<span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;">'+ i_dsc +' Message</span>'+
              '<table role="presentation" border="0" cellpadding="0" cellspacing="0" class="main" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background: #ffffff; border: 1px solid #eaebed; border-radius: 16px; width: 100%;" width="100%">'+

                '<!-- START MAIN CONTENT AREA -->'+
                '<tr>'+
                  '<td class="wrapper" style="font-family: Helvetica, sans-serif; font-size: 16px; vertical-align: top; box-sizing: border-box; padding: 24px;" valign="top">'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">Event level: '+ i_dsc +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">An event has occurred that requires your attention. Information about this event is below:</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">System: '+ i_sys +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">Library: '+ i_lib +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">Program: '+ i_pgm +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">Module: '+ i_mod +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">Procedure: '+ i_prc +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">User: '+ i_usrprf_cur +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">Job: '+ i_job +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">SQLSTATE: '+ i_sstate +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">Error code and data: '+ i_errcode +': '+ i_errdata +'</p>'+
                    '<p style="font-family: Helvetica, sans-serif; font-size: 16px; font-weight: normal; margin: 0; margin-bottom: 16px;">Error message: '+ i_msg +'</p>'+
                  '</td>'+
                '</tr>'+

                '<!-- END MAIN CONTENT AREA -->'+
              '</table>'+

              '<!-- START FOOTER -->'+
              '<div class="footer" style="clear: both; padding-top: 24px; text-align: center; width: 100%;">'+
                '<table role="presentation" border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%">'+
                  '<tr>'+
                    '<td class="content-block" style="font-family: Helvetica, sans-serif; vertical-align: top; color: #9a9ea6; font-size: 16px; text-align: center;" valign="top" align="center">'+
                      '<span class="apple-link" style="color: #9a9ea6; font-size: 16px; text-align: center;">Your Company, Inc.</span>'+
                    '</td>'+
                  '</tr>'+
                  '<tr>'+
                    '<td class="content-block powered-by" style="font-family: Helvetica, sans-serif; vertical-align: top; color: #9a9ea6; font-size: 16px; text-align: center;" valign="top" align="center">'+
                      'Powered by <a href="https://github.com/JamesBrianHill/sdk4i" style="color: #9a9ea6; font-size: 16px; text-align: center; text-decoration: none;">SDK4i</a>'+
                    '</td>'+
                  '</tr>'+
                '</table>'+
              '</div>'+

              '<!-- END FOOTER -->'+

              '<!-- END CENTERED WHITE CONTAINER --></div>'+
          '</td>'+
          '<td style="font-family: Helvetica, sans-serif; font-size: 16px; vertical-align: top;" valign="top">&nbsp;</td>'+
        '</tr>'+
      '</table>'+
    '</body>'+
  '</html>';

  COM_SendEmail(1: email_recipients:
                %LEN(email_subject): %ADDR(email_subject: *DATA):
                %LEN(email_message): %ADDR(email_message: *DATA): 1);

  // --------------------------------------------------
  // Clean up.
  // --------------------------------------------------
  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC SendEmail;
```

---

## Parameters

| Parameter            |                                                                               Type |                 Required                | Description                                                                                               |
| -------------------- | ---------------------------------------------------------------------------------: | :-------------------------------------: | --------------------------------------------------------------------------------------------------------- |
| `i_recipient_count`  |                                                 `LIKE(tpl_sdk4i_unsigned_binary4)` |                 **Yes**                 | Count of recipients contained in `i_recipient_array`.                                                     |
| `i_recipient_array`  |   `LIKEDS(tpl_sdk4i_com_email_recipient_ds) DIM(C_SDK4I_COM_EMAIL_MAX_RECIPIENTS)` |                 **Yes**                 | Array of recipient descriptors. Each element includes `type` (TO/CC/BCC) and `address`.                   |
| `i_subject_length`   |                                                 `LIKE(tpl_sdk4i_unsigned_binary4)` |                 **Yes**                 | Length in bytes of the subject buffer pointed to by `i_subject`.                                          |
| `i_subject`          |                                                                    `POINTER VALUE` |                 **Yes**                 | Pointer to the subject data (not a CHAR/VARCHAR). Caller must supply pointer and length.                  |
| `i_msg_length`       |                                                 `LIKE(tpl_sdk4i_unsigned_binary4)` |                 **Yes**                 | Length in bytes of the message buffer pointed to by `i_msg`.                                              |
| `i_msg`              |                                                                    `POINTER VALUE` |                 **Yes**                 | Pointer to the message body data.                                                                         |
| `i_msg_content_type` |                                                 `LIKE(tpl_sdk4i_unsigned_binary4)` |                 Optional                | Numeric code identifying the message content type (if the mail API supports it).                          |
| `i_attachment_count` |                                                 `LIKE(tpl_sdk4i_unsigned_binary4)` |                 Optional                | Number of attachments provided in `i_attachment_array`. If omitted or zero, no attachments are processed. |
| `i_attachment_array` | `LIKE(tpl_sdk4i_com_email_attachment_name) DIM(C_SDK4I_COM_EMAIL_MAX_ATTACHMENTS)` |                 Optional                | Array of attachment pathnames (full IFS paths). Used only when `i_attachment_count > 0`.                  |
| `i_log_user_info_ds` |                                               `LIKEDS(tpl_sdk4i_log_user_info_ds)` |                 Optional                | Logging/user metadata passed to the logging framework (`LOG_LogMsg`, `LOG_LogUse`).                       |
| `i_password_length`  |                                                 `LIKE(tpl_sdk4i_unsigned_binary4)` |                 Optional                | Length of password data (for encrypted/signed notes). Must be used with `i_password`.                     |
| `i_password`         |                                                                    `POINTER VALUE` | Optional (requires `i_password_length`) | Pointer to password bytes used when signing/encrypting the note.                                          |
| `i_is_signed`        |                                                                              `IND` |                 Optional                | Indicator flag: if supplied and *ON, the email/note should be signed (feature partially TODO in source).  |
| `i_is_encrypted`     |                                                                              `IND` |                 Optional                | Indicator flag: if supplied and *ON, the email/note should be encrypted.                                  |

---

## Related Procedures

| Procedure                | Description                                                                                                                                |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [**`API_CopyMemory`**](../../../../src/qcpysrc/apik.rpgleinc)         | Calls the IBM API [`memcpy`](https://www.ibm.com/docs/en/i/7.6.0?topic=instructions-memory-copy-memcpy) to copy arbitrary bytes into a target buffer — used to place subject, message and password into the note buffer.                            |
| [**`API_CopyWithPointer`**](../../../../src/qcpysrc/apik.rpgleinc)    | Calls the IBM API [`cpybwp`](https://www.ibm.com/docs/en/i/7.6.0?topic=instructions-copy-bytes-pointers-cpybwp) to copy structured data using pointer-aware/aligned copy semantics (used for fixed-size descriptor structures).                             |
| [**`API_CreateAndSendEmail`**](../../../../src/qcpysrc/apik.rpgleinc) | Calls the IBM API [QtmsCreateSendEmail](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/apis/qtmscreatesendemail.html) to send the email. |
| [**`ERR_IsSQLError`**](../../err/qrpglesrc/ERR_IsSQLError.md)         | Tests for SQL errors after `EXEC SQL` operations and populates diagnostic structure(s) when errors occur.                                  |
| [**`LOG_LogMsg`**](../../log/qrpglesrc/LOG_LogMsg.md)             | Centralized logging routine used to record errors, events, and diagnostic context (message, cause, event info).                            |
| [**`LOG_LogUse`**](../../log/qrpglesrc/LOG_LogUse.md)             | Centralized usage/metrics logging used in the `ON-EXIT` cleanup to record success/abend usage data.                                        |
| [**`TXT_Q`**](../../txt/qrpglesrc/TXT_Q.md)                  | Helper used to produce the SQL-escaped single quote / string quoting used in dynamic SQL.     |