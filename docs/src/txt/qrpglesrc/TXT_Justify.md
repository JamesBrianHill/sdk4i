# **TXT_Justify**

---

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`TXT_Justify` returns a new character string whose contents are left-justified, right-justified, or centered within a target length specified by the caller. It accepts a UTF-8 source string, a justification option (`C`, `L`, or `R`), and a target character length. The procedure validates all inputs, and when any input is missing or invalid, it logs an error using `LOG_LogMsg` and returns an empty string.

The algorithm uses the RPG built-in functions
[`%LEN`](https://www.ibm.com/docs/en/i/7.6.0?topic=functions-len-get-set-length#bblen),
[`%SUBST`](https://www.ibm.com/docs/en/i/7.6.0?topic=functions-subst-get-substring),
[`%CHARCOUNT`](https://www.ibm.com/docs/en/i/7.6.0?topic=functions-charcount-return-number-characters), and
[`%INT`](https://www.ibm.com/docs/en/i/7.6.0?topic=functions-int-convert-integer-format)
to compute the target length and manipulate the UTF-8 character content safely.

On abnormal completion, the procedure logs the error (with facility and cause information) and records usage via `LOG_LogUse`.

---

## Example Usage

```rpgle
// Assume d_title is a 30-character field defined in a Display File.
DCL-S my_title LIKE(d_title) INZ('Hello World!');

// This will center the string 'Hello World!' in the d_title field like this:
// |         Hello World!         |
d_title = TXT_Justify(my_title: 'C': %CHARCOUNT(d_title));
```

---

## Parameters

| Parameter            | Type                                 | Required | Description                                                                            |
| -------------------- | ------------------------------------ | :------: | -------------------------------------------------------------------------------------- |
| `i_str`              | `LIKE(tpl_sdk4i_varchar_1K_utf8)`    |  **Yes** | Source UTF-8 string to justify.                                                        |
| `i_position`         | `CHAR(1)`                            |  **Yes** | Justification directive: `'C'` = center, `'L'` = left, `'R'` = right.                  |
| `i_char_count`       | `PACKED(5:0)`                        |  **Yes** | Target character length of the resulting string.                                       |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)` | Optional | Structure containing logging metadata passed through to `LOG_LogMsg` and `LOG_LogUse`. |

---

## Related Procedures

| Procedure      | Description                                                                                                                                                   |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [**`LOG_LogMsg`**](../../log/qrpglesrc/LOG_LogMsg.md) | Writes error, warning, or informational messages to the logging subsystem, including details about the procedure, caller context, and diagnostic information. |
| [**`LOG_LogUse`**](../../log/qrpglesrc/LOG_LogUse.md) | Records usage statistics for the procedure on normal or abnormal termination (success flag, abend flag, timestamps).                                          |