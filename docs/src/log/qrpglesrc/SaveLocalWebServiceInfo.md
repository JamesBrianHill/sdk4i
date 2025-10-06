# **Procedure: SaveLocalWebServiceInfo**

### **Purpose:**
Captures detailed information about a local web service request and response associated with a specific log message.
This data is stored in the `LOGWBLT` table, allowing each log message to be correlated with the originating web service call, its request details, and its response metadata.

---

### Parameters

| Parameter      | Type                            | Description                                                                                                                                                                                                      |
| -------------- | ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `i_id`         | LIKE(`tpl_sdk4i_logmsgt_ds.id`) | The unique identifier of the log message record in the `LOGMSGT` table that this web service information will be associated with.                                                                                |
| `i_logwblt_ds` | LIKEDS(`tpl_sdk4i_logwblt_ds`)  | A data structure containing web service attributes such as local and remote IPs, ports, HTTP protocol, method, URI, query string, and response code. May be passed with null indicators for any optional fields. |

---

### Description

`SaveLocalWebServiceInfo` records contextual details about the current web service transaction that triggered a logged event.
It is designed for use within SDK4i logging and diagnostic routines that execute in the context of an HTTP or REST-based service running locally on IBM i.

When called, the procedure extracts values from the input structure `i_logwblt_ds` and converts null indicators to integer flags using the internal helper function `NIL_IndToInt`.
It then inserts a single row into the `LOGWBLT` table, linking the data to a specific log message record via the supplied `LOGMSGT_ID`.

This stored information helps correlate system-level logging events with their corresponding web service calls, providing traceability between business logic execution and external request activity.

---

### Captured Information

The following attributes are persisted to the `LOGWBLT` table:

| Field        | Description                                                                 |
| ------------ | --------------------------------------------------------------------------- |
| `SRV_IPV4`   | The IPv4 address of the local IBM i server handling the request.            |
| `SRV_PORT`   | The local TCP/IP port number the service is listening on.                   |
| `RMT_IPV4`   | The IPv4 address of the remote client that initiated the request.           |
| `RMT_PORT`   | The client-side TCP/IP port number used for the connection.                 |
| `PROTOCOL`   | The communication protocol (e.g., `HTTP`, `HTTPS`).                         |
| `REQ_METHOD` | The HTTP request method (e.g., `GET`, `POST`, `PUT`, `DELETE`).             |
| `URI`        | The requested URI path.                                                     |
| `QUERY`      | The query string portion of the request, if any.                            |
| `RSP_CODE`   | The HTTP response code returned by the service (e.g., `200`, `404`, `500`). |
| `SCRIPT`     | The ILE or script name invoked as part of the web service handler.          |
| `LIBL`       | The library list active when the request was processed.                     |

Each field supports nullability to accommodate partial or optional web service data.

---

### Processing Logic

1. Initialize all local variables and null indicators.
2. Extract field values from the input data structure `i_logwblt_ds`.
3. Convert each null indicator to an integer-compatible flag for use in SQL parameters.
4. Perform an SQL `INSERT INTO LOGWBLT` statement to persist the web service information, binding all parameters dynamically.
5. Associate the inserted record with the supplied log message ID (`LOGMSGT_ID`).

The operation is performed with `WITH NC` (no commit), allowing the caller to control transaction scope.

---

### Example Usage

This procedure is not exported from the LOG service program therefore is not accessible to external callers. The only way to trigger the SaveLocalWebServiceInfo procedure is by configuring it in the LOGCFGT table: `logwblt` = 'Y'.

---

### Database Dependencies

| Table     | Description                                                                    |
| --------- | ------------------------------------------------------------------------------ |
| `LOGWBLT` | Stores web service session and HTTP transaction details tied to a log message. |
| `LOGMSGT` | Primary log message table that references `LOGWBLT` through `LOGMSGT_ID`.      |

---

### Notes

* This procedure is designed for internal SDK4i use within web service or API contexts.
* Supports null indicators for optional fields to ensure compatibility with incomplete data structures.
* Performs no error handling; SQL errors propagate to the caller.
* Must be called within a job context associated with a log message (`LOGMSGT_ID`).

---

### **Related Procedures**

| Procedure                      | Description                                                                         |
| ------------------------------ | ----------------------------------------------------------------------------------- |
| [**`LOG_LogMsg`**](./LOG_LogMsg.md)               | Logs messages, warnings, and error events to the LOGMSGT table.                     |
| [**`LOG_LogUse`**](./LOG_LogUse.md)               | Logs usage and metrics.                                                             |
| [**`SaveCallStackInfo`**](./SaveCallStackInfo.md)        | Inserts callstack information into the LOGCSIT table.                               |
| [**`SaveExtendedInfo`**](./SaveExtendedInfo.md)         | Inserts extended application information into the LOGEXTT table.                    |
| [**`SaveLocalWebServiceInfo`**](./SaveLocalWebServiceInfo.md)  | Inserts local web service information into the LOGWBLT table.                       |
| [**`SaveMetrics`**](./SaveMetrics.md)              | Inserts execution metrics (duration, success/failure, etc.) into the LOGMETT table. |
| [**`SaveRemoteWebServiceInfo`**](./SaveRemoteWebServiceInfo.md) | Inserts remote web service information into the LOGWBRT table.                      |
| [**`SaveUseInfo`**](./SaveUseInfo.md)              | Inserts usage records into the LOGUSET table.                                       |