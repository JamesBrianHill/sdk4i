# VLD (Validation Utilities) Component

The `VLD` component of SDK4i provides powerful validation utilities.

The [`VLD_GetMsg`](./qrpglesrc/VLD_GetMsg.md) procedure allows a programmer to retrieve an error/warning message, in different languages, from the `vldmsgt` table. This is very helpful if your user population has different primary languages. Even if all your users have the same primary language, having all our error messages in a single place ensures we are consistent in what we present to users.

The [`VLD_IsValid`](./qrpglesrc/VLD_IsValid.md) procedure will eventually be the best way to validate any value for any column in any table (as long as there is a validation rule defined in `vldrult`!). This procedure works perfectly right now however it's performance needs some work. If you want to use this procedure in your software, it is recommended to pass a value for the `i_lib` parameter to increase performance. This is the only procedure in this service program that is not as performant as we might like.

The ['VLD_IsValidDate`](./qrpglesrc/VLD_IsValidDate.md) procedure will validate that a [Date](https://www.ibm.com/docs/en/i/7.6.0?topic=keywords-dateformatseparator) is between optionally provided low and high dates.

The [`VLD_IsValidFK`](./qrpglesrc/VLD_IsValidFK.md) procedure allows us to validate a foreign key type relation - **even if there is no such relation defined in the database**. Many physical files have fields that are used as foreign keys to other physical files but those relationships are enforced at the application level, not the database level. This procedure allows a programmer to ensure a value for a field is found in some other file.

The ['VLD_IsValidNumber`](./qrpglesrc/VLD_IsValidNumber.md) procedure will validate that a numeric value is between optionally provided low and high values.

The [`VLD_IsValidString`](./qrpglesrc/VLD_IsValidString.md) procedure uses regular expressions to validate a string. The procedure handles UTF-* strings and uses the Db2 for i [REGEXP_LIKE](https://www.ibm.com/docs/en/i/7.6.0?topic=predicates-regexp-like-predicate) predicate. NOTE: the International Components for Unicode (ICU) option must be installed.

The [`VLD_IsValidTime`](./qrpglesrc/VLD_IsValidTime.md) procedure will validate that a [Time](https://www.ibm.com/docs/en/i/7.6.0?topic=keywords-timeformatseparator) is between optionally provided low and high times.

The [`VLD_IsValidTimestamp`](./qrpglesrc/VLD_IsValidTimestamp.md) procedure will validate that a [Timestamp](https://www.ibm.com/docs/en/i/7.6.0?topic=keywords-timestampfractional-seconds) is between optionally provided low and high timestamps.