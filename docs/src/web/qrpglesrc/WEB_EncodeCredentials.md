# **Procedure**

**WEB_EncodeCredentials**

---

## **Overview**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`WEB_EncodeCredentials` generates a Base64-encoded string representing an HTTP Basic Authentication credential in the standard `username:password` format. The procedure concatenates the input username and password, encodes the resulting UTF-8 string using the Db2 for i `BASE64_ENCODE` SQL function, and returns the encoded value.

The procedure also integrates with the standard logging and SQL diagnostics framework used within the SDK. If an SQL error occurs during encoding, a diagnostic entry is logged and the procedure returns an indicator value signaling failure.

---

## **Example Usage**

```rpg
//---------------------------------------------------------------------
// Example: Encode username/password for HTTP Basic Authentication
//---------------------------------------------------------------------
ctl-opt dftactgrp(*no) actgrp(*new);

// Prototypes
dcl-pr WEB_EncodeCredentials like(tpl_sdk4i_base64_result);
  i_username   like(tpl_sdk4i_base64_input) const options(*trim);
  i_password   like(tpl_sdk4i_base64_input) const options(*trim);
end-pr;

dcl-s encodedCreds like(tpl_sdk4i_base64_result);

encodedCreds = WEB_EncodeCredentials(
                 i_username : 'myUser'
               : i_password : 'myPass'
               );

// encodedCreds now holds the Base64 string for "myUser:myPass".

return;
```

---

## **Parameters**

| Parameter    | Type                         | Required | Description                                 |
| ------------ | ---------------------------- | -------- | ------------------------------------------- |
| `i_username` | LIKE(tpl_sdk4i_base64_input) | Yes      | Username to be encoded. Trimmed before use. |
| `i_password` | LIKE(tpl_sdk4i_base64_input) | Yes      | Password to be encoded. Trimmed before use. |

---

## **Related Procedures**

| Procedure        | Description                                                                                                      |
| ---------------- | ---------------------------------------------------------------------------------------------------------------- |
| `ERR_IsSQLError` | Evaluates the SQL diagnostics data structure and returns *ON if any SQL error or warning conditions are present. |
| `LOG_LogMsg`     | Writes a detailed log entry containing message text, cause information, event data, and user context.            |
| `LOG_LogUse`     | Records high-level usage information for auditing, including start time, end status, and user context.           |