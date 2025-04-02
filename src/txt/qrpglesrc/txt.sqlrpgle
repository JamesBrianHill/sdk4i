**FREE
// -------------------------------------------------------------------------------------------------
//   This service program provides various text-related functions.
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
CTL-OPT TEXT('SDK4i - TXT - Text utilities');

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// TXTK - TXT constants, data structures, variables, and procedure definitions.
// -------------------------------------------------------------------------------------------------
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
// Create a JSON object.
//
// This procedure creates a JSON "object" used by web services to return JSON data.
//
// NOTE: Scott Klement's YAJL tool is far, far superior to anything this procedure can do. This
// procedure was written solely to not have a dependency on any other tool or framework. If you 
// need to do any real JSON processing, Scott's YAJL tool is highly recommended - you can find it
// here: https://www.scottklement.com/yajl/
//
// @param REQUIRED. The "key" part of the JSON object.
// @param REQUIRED. The "value" part of the JSON object. This could be another JSON object, an array
//   of JSON objects, etc.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return A UTF-8 string containing a JSON object: {"i_name":"i_object"}
///
// -------------------------------------------------------------------------------------------------
DCL-PROC TXT_CreateJSONObject EXPORT;
  DCL-PI TXT_CreateJSONObject LIKE(tpl_sdk4i_varchar_2M_utf8);
    i_name LIKE(tpl_sdk4i_varchar_2M) CONST;
    i_object LIKE(tpl_sdk4i_varchar_2M_utf8) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S o_json LIKE(tpl_sdk4i_varchar_2M_utf8);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  o_json = %CHAR('{"' + i_name + '":' + i_object + '}': *UTF8);

  RETURN o_json;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC TXT_CreateJSONObject;

// -------------------------------------------------------------------------------------------------
///
// Justify a string.
//
// Justify a string to the left, center, or right. This procedure works with single-byte and multi-
// byte characters.
//
// @param REQUIRED. The source string that needs to be justified.
// @param REQUIRED. The justification desired: C = centered, L = left justified, and R = right
//   justified.
// @param REQUIRED. The character count of the final string. NOTE: it is important this is the
//   number of CHARACTERS in the final string, not the number of BYTES. You should use 
//   %CHARCOUNT(return_string) or provide this number as a constant.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return The justified string.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC TXT_Justify EXPORT;
  DCL-PI TXT_Justify LIKE(tpl_sdk4i_varchar_1K_utf8);
    i_str LIKE(tpl_sdk4i_varchar_1K_utf8) OPTIONS(*TRIM) CONST;
    i_position CHAR(1) CONST; // C, L, or R
    i_char_count PACKED(5: 0) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S o_str LIKE(i_str);
  DCL-S start LIKE(i_char_count);
  DCL-S str_char_count LIKE(i_char_count);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  //   If the calling program did not provide a source string to justify, return an empty string
  // and log an error message.
  IF (%LEN(%TRIM(i_str)) = 0);
    log_is_successful = *OFF;
    log_msg = 'Calling program did not provide a source string for parameter '+
      %CHAR(%PARMNUM(i_str)) +' (i_str). Returning an empty string.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN o_str;
  ENDIF;

  //   If the calling program did not tell us how to justify the source string, return an empty
  // string and log an error message.
  IF (i_position <> 'C' AND i_position <> 'L' AND i_position <> 'R');
    log_is_successful = *OFF;
    log_msg = 'Calling program did not specify C, L, or R for parameter '+
      %CHAR(%PARMNUM(i_position)) +' (i_position). Returning an empty string.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN o_str;
  ENDIF;

  //   If the calling program did not tell us how long the final string is supposed to be, return
  // an empty string and log an error message.
  IF (i_char_count = 0);
    log_is_successful = *OFF;
    log_msg = 'Calling program did not specify the length of the final string for ' +
      'parameter '+ %CHAR(%PARMNUM(i_char_count)) +' (i_char_count). Returning an empty string.';
    LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    RETURN o_str;
  ENDIF;

  // Center a string within another string.
  IF (i_position = 'C');
    str_char_count = %CHARCOUNT(i_str);
    IF (str_char_count >= i_char_count); // Source string is >= target string
      o_str = i_str;
      %LEN(o_str) = %LEN(%SUBST(i_str: 1: %MIN(str_char_count: i_char_count): *NATURAL));
      RETURN o_str;
    ENDIF;
    start = %INT((i_char_count - str_char_count) / 2) + 1;
    MONITOR;
      %LEN(o_str) = %LEN(%SUBST(i_str: 1: *STDCHARSIZE)) + (i_char_count - str_char_count);
      %SUBST(o_str: start: *NATURAL) = i_str;
    ON-ERROR;
      log_msg = 'Error executing %SUBST when centering a string. ' +
        'start = ' + %TRIM(%EDITC(start: '1')) +
        'str_char_count = ' + %TRIM(%EDITC(str_char_count: '1'));
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      log_is_successful = *OFF;
    ENDMON;
    RETURN o_str;
  ENDIF;

  // Left-justify a string.
  IF (i_position = 'L');
    str_char_count = %CHARCOUNT(i_str);
    o_str = i_str;
    IF (str_char_count >= i_char_count);
      %LEN(o_str) = %LEN(%SUBST(i_str: 1: %MIN(str_char_count: i_char_count): *NATURAL));
    ELSE;
      %LEN(o_str) = %LEN(%SUBST(i_str: 1: *STDCHARSIZE)) + (i_char_count - str_char_count);
      %SUBST(o_str: str_char_count + 1: *NATURAL) = *BLANKS;
    ENDIF;
    RETURN o_str;
  ENDIF;

  // Right-justify a string.
  IF (i_position = 'R');
    str_char_count = %CHARCOUNT(i_str);
    IF (str_char_count >= i_char_count);
      o_str = i_str;
      %LEN(o_str) = %LEN(%SUBST(i_str: 1: %MIN(str_char_count: i_char_count): *NATURAL));
      RETURN o_str;
    ENDIF;
    start = %INT(i_char_count - str_char_count) + 1;
    MONITOR;
      %LEN(o_str) = %LEN(%SUBST(i_str: 1: *STDCHARSIZE)) + (i_char_count - str_char_count);
      %SUBST(o_str: start: *NATURAL) = i_str;
    ON-ERROR;
      log_msg = 'Error executing %SUBST when right-justifying a string. ' +
        'start = ' + %TRIM(%EDITC(start: '1')) +
        'str_char_count = ' + %TRIM(%EDITC(str_char_count: '1'));
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
      log_is_successful = *OFF;
    ENDMON;
    RETURN o_str;
  ENDIF;

  RETURN o_str;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC TXT_Justify;

// -------------------------------------------------------------------------------------------------
///
// Add single quotes and an optional prefix/suffix around a string.
//
// We often need to build an SQL statement and have single quotes around strings that make up those
// statements. This procedure exists primarily to make our code more readable. Note that the source
// string will be stripped of all leading and trailing blanks before the optional prefix and suffix
// and the opening/closing single quotes.
// Returns: '<optional prefix><the TRIMmed string given to this procedure><optional suffix>'
//
// @param REQUIRED. This is the source string that needs quotes around it.
// @param OPTIONAL. This is a prefix that will appear between a single quote and the beginning of
//   the source string.
// @param OPTIONAL. This is a suffix that will appear between the end of the source string and the
//   closing single quote.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return The quoted source string.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC TXT_Q EXPORT;
  DCL-PI TXT_Q LIKE(tpl_sdk4i_sql_statement);
    i_str LIKE(tpl_sdk4i_sql_statement) OPTIONS(*TRIM) CONST;
    i_prefix LIKE(tpl_sdk4i_sql_statement) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_suffix LIKE(tpl_sdk4i_sql_statement) OPTIONS(*NOPASS: *OMIT: *TRIM) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S o_str LIKE(i_str) INZ(*BLANKS);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // Start with an opening single quote.
  o_str = C_SDK4I_QUOTE;

  // Add the optional prefix if one was specified.
  IF (%PARMS >= %PARMNUM(i_prefix) AND %ADDR(i_prefix) <> *NULL);
    o_str += i_prefix;
  ENDIF;

  // Append our trimmed source string.
  // @link https://www.ibm.com/docs/en/i/7.5?topic=functions-scanrpl-scan-replace-characters#bbscanrp
  o_str += %SCANRPL(
    %CHAR(C_SDK4I_QUOTE: *UTF8):
    %CHAR(C_SDK4I_QUOTE + C_SDK4I_QUOTE: *UTF8):
    i_str:
    *NATURAL
  );

  // Add the optional suffix if one was specified.
  IF (%PARMS >= %PARMNUM(i_suffix) AND %ADDR(i_suffix) <> *NULL);
    o_str += i_suffix;
  ENDIF;

  // Finally, append our closing single quote.
  o_str += C_SDK4I_QUOTE;

  RETURN %TRIMR(o_str);

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC TXT_Q;

// -------------------------------------------------------------------------------------------------
///
// Tokenize a string using 0 or more delimiters.
//
// Note that the delimiter_array and token_array are both variable size arrays in the calling
// program defined something like this:
// DCL-S delimiter_array LIKE(tpl_sdk4i_txt_delimiter)
//   DIM(*AUTO: C_SDK4I_TXT_DELIMITER_ARRAY_SIZE);
// DCL-S token_array LIKE(tpl_sdk4i_txt_token) DIM(*VAR: C_SDK4I_TXT_TOKEN_ARRAY_SIZE);
//
// It doesn't matter if the caller uses *AUTO or *VAR but it is important they do this before
// calling this procedure:
// %ELEM(token_array: *ALLOC) = C_SDK4I_TXT_TOKEN_ARRAY_SIZE;
//
// IBM documentation seems to indicate memory must be allocated before the array is passed to a
// procedure - though all testing indicates this is not necessary. It is very possible the tests
// work by sheer luck - perhaps that area in memory isn't being overwritten by some other process.
//
// The caller does not need to worry about allocating memory for the delimiter_array - this
// procedure does not add elements to that array.
//
// Note: a possible alternative for certain cases (all delimiters are 1 character and the caller
// does not want delimiters returned) might be the strtok function from C.
// @link https://www.ibm.com/docs/en/i/7.5?topic=functions-strtok-tokenize-string
//
// @param REQUIRED. The string to be tokenized.
// @param REQUIRED. The number of delimiters in the delimiter_array.
// @param REQUIRED. An array of delimiters (like a space, &, etc.).
// @param REQUIRED. An array that will hold tokens from the source string.
// @param OPTIONAL. An indicator that tells us if the caller wants the delimiters returned as well
//   as the tokens. Defaults to *OFF so delimiters are not returned.
// @param OPTIONAL. Information about the user associated with this event.
//
// @return The number of tokens (including delimiters if the caller wants them) in o_token_array.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC TXT_Tokenize EXPORT;
  DCL-PI TXT_Tokenize LIKE(tpl_sdk4i_binary4);
    i_str LIKE(tpl_sdk4i_varchar_2M_utf8) OPTIONS(*TRIM) CONST;
    i_delimiter_array_count LIKE(tpl_sdk4i_binary4) CONST;
    i_delimiter_array LIKE(tpl_sdk4i_txt_delimiter) DIM(C_SDK4I_TXT_DELIMITER_ARRAY_SIZE) OPTIONS(*VARSIZE) CONST;
    o_token_array LIKE(tpl_sdk4i_txt_token) DIM(C_SDK4I_TXT_TOKEN_ARRAY_SIZE) OPTIONS(*VARSIZE);
    i_return_delimiters IND OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_user_info_ds LIKEDS(tpl_sdk4i_log_user_info_ds) OPTIONS(*NOPASS: *NULLIND: *OMIT) CONST;
  END-PI;

  DCL-S cur_pos LIKE(tpl_sdk4i_binary4) INZ(1);
  DCL-S delimiter_length PACKED(3: 0);
  DCL-S nxt_pos LIKE(tpl_sdk4i_binary4);
  DCL-S prv_pos LIKE(tpl_sdk4i_binary4) INZ(1);
  DCL-S tmp_pos LIKE(tpl_sdk4i_binary4);

  DCL-S return_delimiters IND;
  DCL-S token LIKE(tpl_sdk4i_txt_token);
  DCL-S token_count LIKE(tpl_sdk4i_binary4);
  DCL-S x LIKE(tpl_sdk4i_binary4);

  // Bring in variables associated with logging.
  /COPY '../../qcpysrc/logvark.rpgleinc'

  // It is safe to CLEAR this array because the elements are VARCHAR.
  CLEAR o_token_array;

  // We were given a blank string so return.
  IF (i_str = *BLANKS);
    RETURN token_count;
  ENDIF;

  // See if the caller wants us to return the delimiters as tokens or not.
  IF (%PARMS >= %PARMNUM(i_return_delimiters) AND %ADDR(i_return_delimiters) <> *NULL);
    return_delimiters = i_return_delimiters;
  ENDIF;

  DOW (prv_pos <= %LEN(i_str));
    // First, we need to find the next delimiter.
    nxt_pos = %LEN(i_str) + 1;
    delimiter_length = 0;
    FOR x = 1 TO i_delimiter_array_count;
      tmp_pos = %SCAN(i_delimiter_array(x): i_str: prv_pos: *NATURAL);
      IF (tmp_pos > 0 AND tmp_pos < nxt_pos);
        nxt_pos = tmp_pos;
        delimiter_length = %LEN(i_delimiter_array(x));
      ENDIF;
    ENDFOR;
    cur_pos = nxt_pos;

    // Capture the token between prv_pos and cur_pos.
    token = %SUBST(i_str: prv_pos: %MAX(cur_pos - prv_pos: delimiter_length: 1): *NATURAL);
    IF (%LOOKUP(token: i_delimiter_array: 1: i_delimiter_array_count) = 0);
      token_count += 1;
      o_token_array(token_count) = token;
    ENDIF;

    // If the caller also wants the delimiters returned, do that here.
    IF (cur_pos <= %LEN(i_str) AND return_delimiters AND delimiter_length > 0);
      token_count += 1;
      token = %SUBST(i_str: cur_pos: delimiter_length: *NATURAL);
      o_token_array(token_count) = token;
    ENDIF;

    // Move our previous pos forward so we start right after the delimiter we just processed.
    prv_pos = cur_pos + delimiter_length;
  ENDDO;

  RETURN token_count;

  ON-EXIT log_is_abend;
    IF (log_is_abend);
      log_is_successful = *OFF;
      log_msg = 'Procedure ended abnormally.';
      LOG_LogMsg(psds_ds: log_proc: log_msg: log_cause_info_ds: log_event_info_ds: log_user_info_ds);
    ENDIF;
    LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
END-PROC TXT_Tokenize;