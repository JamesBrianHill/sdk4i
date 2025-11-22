# **TXT_Tokenize**

---

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`TXT_Tokenize` parses a UTF-8 input string into an array of tokens based on one or more delimiters supplied by the caller. The caller provides an array of delimiter strings, and the procedure searches for the next occurrence of any delimiter, extracts the text between delimiters, and stores each token in an output array. Optionally, the caller may request that the delimiters themselves be included in the output token list.

The procedure returns the number of tokens stored in the output array. If the input string is blank, no tokens are returned. If errors occur, diagnostic information is logged using `LOG_LogMsg`. Procedure usage and completion status are recorded using `LOG_LogUse`.

---

## Example Usage

```rpgle
**free
ctl-opt dftactgrp(*no) actgrp(*new);

// Local variables
dcl-s tokenCount int(10);
dcl-s x int(10);

dcl-s input varchar(2000) ccsid(1208) inz('apple,banana;cherry|date');
dcl-s returnDelims ind inz(*off);

dcl-s delCount int(10) inz(3);
dcl-s delimiterArray likeds(tpl_sdk4i_txt_delimiter)
        dim(C_SDK4I_TXT_DELIMITER_ARRAY_SIZE);

dcl-s tokenArray likeds(tpl_sdk4i_txt_token)
        dim(C_SDK4I_TXT_TOKEN_ARRAY_SIZE);

dcl-ds logInfo likeds(tpl_sdk4i_log_user_info_ds) inz(*likeds);

// Define delimiters
delimiterArray(1) = ',';
delimiterArray(2) = ';';
delimiterArray(3) = '|';

// Tokenize the string
tokenCount = TXT_Tokenize(
                input:
                delCount:
                delimiterArray:
                tokenArray:
                returnDelims:
                logInfo );

// Display the tokens
for x = 1 to tokenCount;
    dsply ('Token ' + %char(x) + ': ' + tokenArray(x));
endfor;

*inlr = *on;
return;
```

---

## Parameters

| Parameter                 | Type                                                         | Required | Description                                                          |
| ------------------------- | ------------------------------------------------------------ | :------: | -------------------------------------------------------------------- |
| `i_str`                   | `LIKE(tpl_sdk4i_varchar_2M_utf8)`                            |  **Yes** | Source UTF-8 string to tokenize.                                     |
| `i_delimiter_array_count` | `LIKE(tpl_sdk4i_binary4)`                                    |  **Yes** | Number of delimiters in the delimiter array.                         |
| `i_delimiter_array`       | `LIKE(tpl_sdk4i_txt_delimiter)` DIM(...) `OPTIONS(*VARSIZE)` |  **Yes** | Array of delimiter strings used to split `i_str`.                    |
| `o_token_array`           | `LIKE(tpl_sdk4i_txt_token)` DIM(...) `OPTIONS(*VARSIZE)`     |  **Yes** | Output array populated with extracted tokens.                        |
| `i_return_delimiters`     | `IND`                                                        | Optional | If provided and *ON*, delimiter strings are also returned as tokens. |
| `i_log_user_info_ds`      | `LIKEDS(tpl_sdk4i_log_user_info_ds)`                         | Optional | Logging metadata structure passed to the logging subsystem.          |

---

## Related Procedures

| Procedure      | Description                                                                                                                                                   |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [**`LOG_LogMsg`**](../../log/qrpglesrc/LOG_LogMsg.md) | Writes error, warning, or informational messages to the logging subsystem, including details about the procedure, caller context, and diagnostic information. |
| [**`LOG_LogUse`**](../../log/qrpglesrc/LOG_LogUse.md) | Records usage statistics for the procedure on normal or abnormal termination (success flag, abend flag, timestamps).                                          |