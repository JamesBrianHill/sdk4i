# **Procedure: SaveRemoteWebServiceInfo**

### **Purpose:**
Records metadata and payload details for outbound (remote) web service requests and responses executed by the current job or process.
This procedure captures HTTP/S request and response information and writes it to the `LOGWBRT` table for diagnostics, auditing, and performance analysis.

---

### Parameters

| Parameter      | Type                            | Description                                                                                                                                                                               |
| -------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `i_id`         | LIKE(`tpl_sdk4i_logmsgt_ds.id`) | Unique message or transaction identifier linking this record to the primary log message entry.                                                                                            |
| `i_logwbrt_ds` | LIKEDS(`tpl_sdk4i_logwbrt_ds`)  | Data structure containing web service request and response details, including connection info, protocol, headers, and payload content. Optional; individual fields may be null-indicated. |

---

### Description

`SaveRemoteWebServiceInfo` logs contextual and technical information about outbound web service interactions initiated by SDK4i-enabled applications.
It captures both network and application-layer attributes — such as destination server, API endpoint, HTTP method, request/response payloads, and status codes — to assist with transaction tracing, debugging, and operational analytics.

This procedure complements `SaveLocalWebServiceInfo`, which records inbound (local) HTTP request data, thereby providing full visibility into both directions of service traffic within IBM i service-oriented applications.

When invoked, the procedure reads values from the `i_logwbrt_ds` data structure, evaluates null indicators for each field, and performs an SQL `INSERT` into the `LOGWBRT` table.
All data is inserted using proper null handling to maintain integrity even when optional fields are missing or undefined.

---

### Captured Information

The following fields are inserted into the `LOGWBRT` table:

| Field        | Description                                                          |
| ------------ | -------------------------------------------------------------------- |
| `LOGMSGT_ID` | Identifier linking this record to the main log message.              |
| `PROTOCOL`   | Communication protocol used for the request (e.g., `HTTP`, `HTTPS`). |
| `RMT_FQDN`   | Fully Qualified Domain Name of the remote host.                      |
| `RMT_IPV4`   | IPv4 address of the remote server.                                   |
| `RMT_PORT`   | Port number used to connect to the remote service.                   |
| `RMT_API`    | API endpoint or resource path accessed.                              |
| `QUERY`      | Query string or URL parameters appended to the request.              |
| `REQ_METHOD` | HTTP method (e.g., `GET`, `POST`, `PUT`, `DELETE`).                  |
| `REQ_HEAD`   | HTTP request headers sent to the server.                             |
| `REQ_BODY`   | HTTP request payload (typically JSON, XML, or form data).            |
| `RSP_CODE`   | HTTP response code returned by the remote server.                    |
| `RSP_HEAD`   | HTTP response headers received.                                      |
| `RSP_BODY`   | HTTP response payload body.                                          |

Each field supports null indication for flexibility when data is not available or applicable to a given transaction.

---

### Processing Logic

1. **Extract Field Data**
   Reads each attribute from the input structure `i_logwbrt_ds` and stores it in local variables for SQL compatibility.

2. **Handle Null Indicators**
   Converts `%NULLIND()` values to SDK4i-compatible integer null flags via the `NIL_IndToInt()` helper function, ensuring SQL inserts are accurate and compliant with database constraints.

3. **Insert Record**
   Executes an SQL `INSERT INTO LOGWBRT` statement, associating all collected values with the parent log message identifier (`i_id`).

4. **Transaction Control**
   Uses `WITH NC` (No Commit) to defer transaction control to the caller’s environment or commit scope, maintaining flexibility across different job configurations.

---

### Example Usage

This procedure is not exported from the LOG service program therefore is not accessible to external callers. The only way to trigger the SaveRemoteWebServiceInfo procedure is by configuring it in the LOGCFGT table: `logwbrt` = 'Y'.

---

### Database Dependencies

| Table     | Description                                                                    |
| --------- | ------------------------------------------------------------------------------ |
| `LOGWBRT` | Stores metadata and payload information for outbound web service transactions. |
| `LOGMSGT` | Provides parent linkage for message-level tracking and trace correlation.      |

---

### Notes

* Intended for use by SDK4i service wrappers, middleware, and integration layers performing HTTP or RESTful requests from IBM i.
* All parameters are optional except the parent log message identifier (`i_id`).
* Large payloads may be truncated depending on database column sizes and configuration.
* The procedure assumes UTF-8 encoding for character fields to ensure cross-system compatibility.
* Error handling and SQL exception management should be implemented by the caller.

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