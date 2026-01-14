# Procedure: **SEC_CreateUUID**

## Overview

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`SEC_CreateUUID` generates a new universally unique identifier (UUID) using the IBM i `_GENUUID` system API and returns it in standard hexadecimal string format (`8-4-4-4-12`).

The procedure handles all low-level API interaction, error trapping, and logging. On success, it returns a formatted UUID token. On failure, it logs detailed diagnostic information and returns *OFF.

This procedure is primarily used by security and session-management components to generate unique session tokens and identifiers.

---

### Example Usage

```rpg
dcl-s token like(tpl_sdk4i_uuid);
dcl-ds log_user_info_ds likeds(tpl_sdk4i_log_user_info_ds) inz;

if SEC_CreateUUID(token : log_user_info_ds);
   dsply ('Generated UUID: ' + token);
else;
   dsply ('Failed to generate UUID.');
endif;
```

---

### Parameters

| Parameter            | Type                               | Required | Description                                                                                            |
| -------------------- | ---------------------------------- | -------- | ------------------------------------------------------------------------------------------------------ |
| `o_token`            | LIKE(tpl_sdk4i_uuid)               | Yes      | Output UUID token formatted as a standard hexadecimal string (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`). |
| `i_log_user_info_ds` | LIKEDS(tpl_sdk4i_log_user_info_ds) | Optional | Logging context information for auditing and diagnostics. Supports `*NOPASS`, `*NULLIND`, and `*OMIT`. |

---

### Related Procedures

| Procedure          | Description                                                           |
| ------------------ | --------------------------------------------------------------------- |
| `API_GenerateUUID` | IBM i system API `_GENUUID` used to generate a binary UUID value.     |
| `API_CharToHex`    | Converts binary UUID data into a hexadecimal character string.        |
| `LOG_LogMsg`       | Writes diagnostic and error messages to the system logging framework. |
| `LOG_LogUse`       | Records procedure execution statistics and success/failure state.     |