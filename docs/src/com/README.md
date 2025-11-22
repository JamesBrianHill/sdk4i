# COM (Communications) Component

The `COM` component of SDK4i provides communications-related procedures.

You can send break messages to IBM i users with the [`COM_SendBreakMessage`](./qrpglesrc/COM_SendBreakMessage.md) procedure. This calls the IBM [`QEZSNDMG`](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/apis/QEZSNDMG.html) API allowing you to send messages up to 494 characters long.

You can also send emails, with or without attachments, optionally signed and/or encrypted. **Notably, you can send emails with messages that are longer than 5000 characters.** Other commonly used commands/APIs limit the message size to 5000 characters which can be quite limiting when sending HTML-based emails. Using the [`COM_SendEmail`](./qrpglesrc/COM_SendEmail.md) procedure, the size of your emails are limited by the email servers involved - often 10MB or larger. This procedure uses IBMs [`QtmsCreateSendEmail`](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/apis/qtmscreatesendemail.html) API.

Lastly, you can use a third-party service like Twilio to send SMS messages with the `COM_SendSMS` procedure. (Forthcoming)