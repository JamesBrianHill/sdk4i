# General Notes related to SDK4i.

This page provides links to documentation relevant to SDK4i. Documentation for APIs used, ISO standards, and various programming details. You do NOT need to read any of this to use SDK4i.

## IBM Reference Documentation
- [API Finder](https://www.ibm.com/docs/en/i/7.5?topic=interfaces-alphabetic-list-apis)
  - [QCMDEXC](https://www.ibm.com/docs/en/i/7.5?topic=ssw_ibm_i_75/apis/qcmdexc.html) - Execute command
  - [QEZSNDMG](https://www.ibm.com/docs/en/i/7.5?topic=ssw_ibm_i_75/apis/QEZSNDMG.html) - Send Message
  - [QtmhRdStin](https://www.ibm.com/docs/en/i/7.5?topic=ssw_ibm_i_75/rzaie/rzaieapi_qtmhrdstin.html) - Read from Stdin
  - [QtmhWrStout](https://www.ibm.com/docs/en/i/7.5?topic=ssw_ibm_i_75/rzaie/rzaieapi_qtmhwrstout.html) - Write to Stdout
  - [QtmsCreateSendEmail](https://www.ibm.com/docs/en/i/7.5?topic=ssw_ibm_i_75/apis/qtmscreatesendemail.html) - Send Email
    - Also see QSYSINC/QRPGLESRC/QTMSCRTSNM.
  - [stat](https://www.ibm.com/docs/en/i/7.5?topic=ssw_ibm_i_75/apis/stat.html) - Get file information
  - [strtok](https://www.ibm.com/docs/en/i/7.5?topic=functions-strtok-tokenize-string) - Tokenize string
- [CCSIDs](https://www.ibm.com/docs/en/i/7.5?topic=reference-ccsid-values)
- [CGI APIs](https://www.ibm.com/docs/en/i/7.5?topic=api-cgi-apis)
- [Control Language](https://www.ibm.com/docs/en/i/7.5?topic=programming-control-language)
- [Db2 for i Reference](https://www.ibm.com/docs/en/i/7.5?topic=reference-sql)
  - [PREPARE](https://www.ibm.com/docs/en/i/7.5?topic=statements-prepare)
  - [DECLARE CURSOR](https://www.ibm.com/docs/en/i/7.5?topic=statements-declare-cursor)
  - [OPEN](https://www.ibm.com/docs/en/i/7.5?topic=statements-open)
  - [FETCH](https://www.ibm.com/docs/en/i/7.5?topic=statements-fetch)
  - [Isolation clause](https://www.ibm.com/docs/en/i/7.5?topic=statement-isolation-clause)
  - [REGEXP_LIKE](https://www.ibm.com/docs/en/i/7.5?topic=predicates-regexp-like-predicate)
  - [QSYS2.IFS_OBJECT_STATISTICS](https://www.ibm.com/docs/en/i/7.5?topic=services-ifs-object-statistics-table-function)
  - [QSYS2.LIBRARY_LIST_INFO](https://www.ibm.com/docs/en/i/7.5?topic=services-library-list-info-view)
  - [QSYS2.SYSCOLUMNS](https://www.ibm.com/docs/en/i/7.5?topic=views-syscolumns)
  - [SQLSTATE values](https://www.ibm.com/docs/en/i/7.5?topic=codes-listing-sqlstate-values)
  - [Db2 for i Limits](https://www.ibm.com/docs/en/i/7.5?topic=reference-sql-limits)
  - [Three-Part Names](https://www.ibm.com/docs/en/i/7.5?topic=request-three-part-names)
- [DDS - Data Description Specifications](https://www.ibm.com/docs/en/i/7.5?topic=programming-dds)
  - [DDS - Physical and Logical Files](https://www.ibm.com/docs/en/i/7.5?topic=dds-physical-logical-files)
  - [DDS - Display Files](https://www.ibm.com/docs/en/i/7.5?topic=dds-display-files)
  - [DDS - Printer Files](https://www.ibm.com/docs/en/i/7.5?topic=dds-printer-files)
- [HTTP Server for i](https://www.ibm.com/support/pages/http-server-i)
  - [Environment variables set by HTTP Server](https://www.ibm.com/docs/en/i/7.5?topic=information-environment-variables)
- [Machine Interface Programming](https://www.ibm.com/docs/en/i/7.5?topic=interface-machine-programming)
  - [CPYBWP](https://www.ibm.com/docs/en/i/7.5?topic=instructions-copy-bytes-pointers-cpybwp) - Copy Bytes with Pointers
    - [Why you should use ALIGN(*FULL)](https://www.ibm.com/support/pages/node/1118397) - RPG Cafe article
      - [ALIGN{(*FULL)}](https://www.ibm.com/docs/en/i/7.5?topic=keywords-alignfull#dalign) - RPG definition specification documentation
  - [MEMCPY](https://www.ibm.com/docs/en/i/7.5?topic=instructions-memory-copy-memcpy) - Memory Copy
- [IBM PASE for i](https://www.ibm.com/docs/en/i/7.5?topic=programming-pase-i)
- [ILE RPG Reference](https://www.ibm.com/docs/en/i/7.5?topic=rpg-ile-reference)
  - [Convert C Prototypes to RPG](https://www.ibm.com/support/pages/converting-c-prototypes-rpg)
  - [Program Status Data Structure](https://www.ibm.com/docs/en/i/7.5?topic=exceptionerrors-program-status-data-structure)
  - [Embedding SQL Statements in ILE RPG](https://www.ibm.com/docs/en/i/7.5?topic=cssiira-embedding-sql-statements-in-ile-rpg-applications-that-use-sql)
    - [Using host variables in embedded SQL](https://www.ibm.com/docs/en/i/7.5?topic=cssiira-using-host-variables-in-ile-rpg-applications-that-use-sql)
      - [Declaring xLOB host variables](https://www.ibm.com/docs/en/i/7.5?topic=dhviiratus-declaring-lob-host-variables-in-ile-rpg-applications-that-use-sql) - how to use DCL-S SQLTYPE(xLOB: x);
      - [Data structures as host variables](https://www.ibm.com/docs/en/i/7.5?topic=cssiira-using-host-structures-in-ile-rpg-applications-that-use-sql)
      - [Arrays of data structures as host variables](https://www.ibm.com/docs/en/i/7.5?topic=cssiira-using-host-structure-arrays-in-ile-rpg-applications-that-use-sql)
      - [Determining equivalent SQL and ILE RPG data types](https://www.ibm.com/docs/en/i/7.5?topic=applications-determining-equivalent-sql-ile-rpg-data-types)
      - [Using indicator variables](https://www.ibm.com/docs/en/i/7.5?topic=cssiira-using-indicator-variables-in-ile-rpg-applications-that-use-sql) - how to handle NULL values. SDK4i has a component (NIL) that provides utilities to make working with NULLs easier.
  - [RPG IV restrictions/limits](https://www.ibm.com/docs/en/i/7.5?topic=appendixes-appendix-rpg-iv-restrictions)
  - [Service Programs](https://www.ibm.com/docs/en/i/7.5?topic=programs-service)
    - [Binder Language](https://www.ibm.com/docs/en/i/7.5?topic=concepts-binder-language)
- [Variant characters](https://www.ibm.com/docs/en/i/7.5?topic=considerations-runtime-character-set)
- [Path names in the root file system](https://www.ibm.com/docs/en/i/7.5?topic=system-path-names-in-root-file)

## Geographic Data
- [ISO 3166](https://en.wikipedia.org/wiki/ISO_3166-1) standarizes country and subdivision information.
- [INCITS county codes](https://en.wikipedia.org/wiki/List_of_United_States_INCITS_codes_by_county) (formerly FIPS county codes) provides a list of all counties and county equivalents in the United States.

## Languages
- [ISO 639](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) standardizes language information.

## Logging
- We use the logging facilities and levels defined in [RFC 5424](http://tools.ietf.org/html/rfc5424).

## Time
- [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) standardizes time-related information including timezone offsets.
- [Timezone abbreviations](https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations).
- We use ISO date and time formats and separaters because SDK4i was built with worldwide use in mind.
  - We use [SET OPTION](https://www.ibm.com/docs/en/i/7.5?topic=statements-set-option) to ensure all programs use ISO formats for both RPG and SQL.
- All dates in documentation or source code comments are in ISO format: YYYY-MM-DD.

## Machine Interface Error to MCHxxxx
The MI error codes provided in IBM documentation are hexadecimal. To get the corresponding MCHxxxx error code (which can then be used in a `MONITOR` group using the `ON-EXCP` code), we must convert the hexadecimal numbers to decimal numbers.

An example is the "Pointer Does Not Exist" error associated with the _GENUUID API which is 2401. To get the MCHxxxx code, we need to convert hexadecimal "24" and "01" to decimal values:

Hexadecimal 24 = decimal 36
Hexadecimal 01 = decimal 01

So the MCH code is MCH3601.

I cannot point you to any public documentation that explains this, it is something I picked up at a COMMON conference.

## Web Services
- [HTTP Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Messages#http_requests)
- [Media Types - application](https://www.iana.org/assignments/media-types/media-types.xhtml#application)
- [Media Types - text](https://www.iana.org/assignments/media-types/media-types.xhtml#text)
- [Media Types - images](https://www.iana.org/assignments/media-types/media-types.xhtml#image)
- [RFC 9110 - HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110.html)