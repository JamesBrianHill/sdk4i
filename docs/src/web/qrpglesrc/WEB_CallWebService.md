# **Procedure**

**WEB_CallWebService**

---

## **Overview**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

`WEB_CallWebService` is a high-level wrapper around the IBM i `QSYS2.HTTP_*` family of SQL functions, providing a unified interface for invoking remote HTTP/REST web services. It supports all major HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, CONNECT, TRACE) and allows callers to specify whether the payloads should be processed as text (CLOB) or binary (BLOB), as well as whether verbose variants of the IBM HTTP functions should be used.

The procedure abstracts memory management, SQL error handling, request and response payload transfer, and response parsing. When verbose mode is enabled, it returns both HTTP headers and payload. All calls are logged through the SDK4i logging framework, including detailed diagnostic information upon error and optional recording of request/response metadata.

The procedure returns *ON* or *OFF* to indicate whether the web service call was executed successfully at the transport level. It does **not** interpret the HTTP status code for success or failure; callers must inspect `o_rsp_code` for web-service-level success.

---

## **Example Usage**

```rpg
//---------------------------------------------------------------------
// Example: Call a REST API using POST with JSON payload.
//---------------------------------------------------------------------
ctl-opt decedit('0,') option(*srcstmt:*noshow);

dcl-s httpOptions varchar(1024) inz(
  '{ "timeout": 30, "httpHeaders": [ ' +
  '  { "name": "Content-Type", "value": "application/json" } ' +
  '] }'
);

dcl-s httpOptionsLen int(10) inz(%len(%trim(httpOptions)));
dcl-s httpOptionsPtr pointer inz(%addr(httpOptions));

dcl-s reqPayload varchar(2048) inz(
  '{ "customerId": 12345, "includeHistory": true }'
);
dcl-s reqPayloadLen int(10) inz(%len(%trim(reqPayload)));
dcl-s reqPayloadPtr pointer inz(%addr(reqPayload));

dcl-s rspCode packed(3:0);
dcl-s rspHeaders varchar(8192);
dcl-s rspHeadersLen int(10) inz(%size(rspHeaders));
dcl-s rspHeadersPtr pointer inz(%addr(rspHeaders));

dcl-s rspPayload varchar(1048576);
dcl-s rspPayloadLen int(10) inz(%size(rspPayload));
dcl-s rspPayloadPtr pointer inz(%addr(rspPayload));

dcl-s success ind;

success = WEB_CallWebService(
            i_method              : 'https://example.com/api/customer' :
            httpOptionsLen        : httpOptionsPtr :
            rspCode               :
            rspHeadersLen         : rspHeadersPtr :
            rspPayloadLen         : rspPayloadPtr :
            reqPayloadLen         : reqPayloadPtr  :
            *omit                 : 'N'            // BLOB? No.
            : 'Y'                                 // Verbose? Yes.
          );

if success;
   dsply ('HTTP Code: ' + %char(rspCode));
   dsply ('Payload: ' + %trim(rspPayload));
else;
   dsply ('Call failed.');
endif;
```

---

## **Parameters**

| Parameter               | Type                                   | Required | Description                                                                           |
| ----------------------- | -------------------------------------- | -------- | ------------------------------------------------------------------------------------- |
| `i_method`              | `LIKE(tpl_sdk4i_web_method)`           | Yes      | HTTP method (GET, POST, PUT, DELETE, PATCH, etc.).                                    |
| `i_url`                 | `LIKE(tpl_sdk4i_web_uri)`              | Yes      | Fully qualified URL of the target web service.                                        |
| `i_http_options_length` | `LIKE(tpl_sdk4i_len)`                  | Yes      | Length, in bytes, of the HTTP options structure.                                      |
| `i_http_options`        | `POINTER VALUE`                        | Yes      | Pointer to UTF-8 encoded HTTP options JSON structure.                                 |
| `o_rsp_code`            | `LIKE(tpl_sdk4i_web_http_status_code)` | Yes      | Output HTTP response status code returned by the remote service.                      |
| `io_rsp_headers_length` | `LIKE(tpl_sdk4i_len)`                  | Yes      | Input: size of buffer. Output: number of bytes returned in response headers.          |
| `o_rsp_headers`         | `POINTER VALUE`                        | Yes      | Pointer to UTF-8 buffer for response headers (verbose mode only).                     |
| `io_rsp_payload_length` | `LIKE(tpl_sdk4i_len)`                  | Yes      | Input: size of buffer. Output: number of bytes returned in response body.             |
| `o_rsp_payload`         | `POINTER VALUE`                        | Yes      | Pointer to UTF-8 buffer for response body.                                            |
| `i_req_payload_length`  | `LIKE(tpl_sdk4i_len)`                  | Optional | Length of request payload. Required for POST, PUT, PATCH.                             |
| `i_req_payload`         | `POINTER VALUE`                        | Optional | Pointer to UTF-8 request payload (CLOB or BLOB depending on `i_blob`).                |
| `i_blob`                | `CHAR(1)`                              | Optional | Indicates whether payloads should use BLOB functions (`'Y'`) or CLOB (`'N'` default). |
| `i_verbose`             | `CHAR(1)`                              | Optional | Whether to use verbose HTTP functions (default `'Y'`).                                |

---

## **Related Procedures**

| Procedure        | Description                                                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------ |
| [**`API_CopyMemory`**](../../../../src/qcpysrc/apik.rpgleinc) | Calls the IBM API [`memcpy`](https://www.ibm.com/docs/en/i/7.6.0?topic=instructions-memory-copy-memcpy) to copy arbitrary byte sequences between memory buffers.|
| [**`ERR_IsSQLError`**](../../err/qrpglesrc/ERR_IsSQLError.md) | Inspects SQL diagnostics to determine whether an SQL exception or warning occurred.                                      |
| [**`LOG_LogMsg`**](../../log/qrpglesrc/LOG_LogMsg.md)      | Writes a log message including cause data, event data, and context derived from the caller and runtime environment.         |
| [**`LOG_LogUse`**](../../log/qrpglesrc/LOG_LogUse.md)      | Logs usage metrics for the procedure, including start time, end time, success indicators, and abend status.                 |