# SDK4i
SDK4i is a Software Development Kit written in modern RPG for use on IBM i. There are multiple components providing a variety of essential functions such as logging, validation, and security.

## Logging (LOG)
One of the most powerful features provided by SDK4i is the robust LOG component. Programmers can quickly and easily:
- log messages at eight different levels (modeled after the syslog protocol defined in [RFC 5424](https://www.rfc-editor.org/rfc/rfc5424))
- capture usage counts by year, month, week, day, hour, or minute for procedures, subroutines, programs, etc. Never again do you have to ask, "Is this program/procedure still being used?"
- capture execution time for a section of code such as a procedure, subroutine, program, etc.
- capture request/response headers and bodies for both local and remote web services.

More details about the LOG component are available in it's [README](./docs/src/log/README.md).

## Validation (VLD)
The VLD component allows a programmer to define validation rules for every column in every table (or every field in every file if you prefer). These rules can be anything from basic min/max values or foreign key relationships (without any constraints being defined in the database) to powerful regular expressions.

More details about the VLD component are available in it's [README](./docs/src/vld/README.md).

## Security (SEC)
Security is critical and the SEC component gives a programmer the ability to define users (based on local IBM i user profiles AND/OR externally defined users) and the actions they are authorized to perform. Groups can be defined to make management of users and actions simpler.

The SEC component does not use the outdated role-based security model. Instead, it utilizes a model called "Sliding Window Authorization" based on the Principle of Least Privilege and time-bounded authorizations where user activity can (sometimes) automatically renew the time-bound authorizations.

You can read more about Sliding Window Authorization and other functionality provided by the SEC component on it's [README](./docs/src/sec/README.md).

## Summary
There are other components available in SDK4i, all available for you to use as much or as little as you need. The three highlighted above, LOG, VLD, and SEC, are the foundation we all need for our projects. Here are some of the other components available:
- ERR component: error handling utilities ([README](./docs/src/err/README.md))
- NIL component: NULL handling utilities
- TXT component: text-related utilities (check out TXT_Q to help build dynamic embedded SQL statements) ([README](./docs/src/txt/README.md))
- WEB component: utilities for calling remote web services AND for hosting local web services on IBM i ([README](./docs/src/web/README.md))

SDK4i uses modern RPG with embedded SQL and functionality provided by the current versions of IBM i - 7.5 and 7.6. Inside, you will find the use of:
- [System-Period Temporal Tables](https://www.ibm.com/docs/en/i/7.6.0?topic=administration-working-system-period-temporal-tables)
- The [RESTRICT ON DROP](https://www.ibm.com/docs/en/i/7.6.0?topic=object-restrict-drop) attribute (optional)
- SQL for all input and output - no record-level-access :hot_pepper:
- [ON-EXIT](https://www.ibm.com/docs/en/i/7.6.0?topic=codes-exit-exit) is used in every procedure
- [*UTF8](https://www.ibm.com/docs/en/i/7.6.0?topic=keywords-ccsid-definition-keyword) variables in RPG and [CCSID(1208)](https://www.ibm.com/docs/en/i/7.6.0?topic=keywords-ccsid-definition-keyword) columns in Db2 for i
- [NULL](https://www.ibm.com/docs/en/i/7.6.0?topic=types-nulls)-capable columns and variables
- [LOB](https://www.ibm.com/docs/en/i/7.6.0?topic=dhviiratus-declaring-lob-host-variables-in-ile-rpg-applications-that-use-sql) (Large OBject) variables in RPG and Db2
- IFS-based source files
- Completely free-format RPG with lines up to 240 characters long (this is a self-imposed limit)

## Requirements and Installation
- Requires IBM i 7.5 or higher.
- The ability to upload source code to the IFS.
- All SDK4i tables must be journaled.
- Creation of some new libraries to keep SDK4i self-contained is recommended but not required.
- Creation of a proper IFS directory (such as `/opt/sdk4i`) is recommended for permanent installation but you can upload the source to your personal directory if you just want to give it a test drive.

Step-by-step installation instructions are available in a [separate document](INSTALL.md).

## Disclaimers
This software is provided "as-is" without warranty of any kind. The authors are not affiliated with IBM Corporation. IBM, IBM i, Db2, and RPG are trademarks or registered trademarks of International Business Machines Corportation.

Additionally, the use of brand names, commercial products, or services is solely for educational or reference purposes and does not imply endorsement by the owners of those brands, products, or services.

### A Note About AI
All of the **_code_** in SDK4i was generated solely by a human. Conversely, almost all of the documentation was generated by AI and then edited by a human.