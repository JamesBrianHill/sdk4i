# **Procedure**

**COM_SendBreakMessage**

---

## **Overview**

NOTE: Documentation created by AI but not yet vetted by a human. Be skeptical.

The `COM_SendBreakMessage` procedure sends a break message to a specified user profile by invoking the `QEZSNDMG` system API (wrapped by the `API_SendMessage` procedure). The message is delivered using the `*BREAK` delivery mode, causing it to appear immediately on the receiving user's display.

This procedure includes robust exception handling through the [`MONITOR`](https://www.ibm.com/docs/en/i/7.6?topic=statements-monitor-on-error-on-excp) block and logs errors, diagnostic messages, and abnormal ends using the SDK's centralized logging infrastructure (`LOG_LogMsg`, `LOG_LogUse`).

It returns *ON when the message is sent without error and *OFF when an error or exception occurs.

---

## **Example Usage**

```rpgle
// -------------------------------------------------------------
// Example: Send a break message to a user profile.
// -------------------------------------------------------------
DCL-S isSent        IND;
DCL-S msg           VARCHAR(200);
DCL-S user          VARCHAR(10);

// Initialize values
user = 'JSMITH';
msg  = 'Your job requires attention.';

// Attempt to send break message
IF (COM_SendBreakMessage(user: msg));
  // Message successfully sent
ELSE;
  // Handle error condition
ENDIF;
```

---

## **Parameters**

| Parameter            | Type                                              | Required | Description                                                                                                  |
| -------------------- | ------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------ |
| `i_usrprf`           | `LIKE(tpl_sdk4i_com_sndmsg_usrprf)`               | Yes      | The target user profile to receive the break message.                                                        |
| `i_msg`              | `LIKE(tpl_sdk4i_com_sndmsg_msg)` (*TRIM applied*) | Yes      | The message text to be sent. Trimmed prior to use and copied to a `CHAR(494)` buffer as required by the API. |
| `i_log_user_info_ds` | `LIKEDS(tpl_sdk4i_log_user_info_ds)`              | Optional | User-related logging metadata. May be omitted or null.                                                       |

---

## **Related Procedures**

| Procedure         | Description                                                                                                                 |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------- |
| [**`API_SendMessage`**](../../../../src/qcpysrc/apik.rpgleinc) | Calls the IBM API [`QEZSNDMG`](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/apis/QEZSNDMG.html) to send messages to users or message queues. Handles message type, delivery mode, and routing. |
| [**`LOG_LogMsg`**](../../log/qrpglesrc/LOG_LogMsg.md)      | Writes a log message including cause data, event data, and context derived from the caller and runtime environment.         |
| [**`LOG_LogUse`**](../../log/qrpglesrc/LOG_LogUse.md)      | Logs usage metrics for the procedure, including start time, end time, success indicators, and abend status.                 |