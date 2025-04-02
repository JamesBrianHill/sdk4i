# Notes about DDL statements used by SDK4i.

DISCLAIMER: all of the "MUST", "SHOULD", etc. statements are from James Brian Hill in regards to the SDK4i software. These statements are not from previous, current, or future employers, nor are they from anyone else on the planet. Do not blame anyone else for what I have stated here.

All SDK4i DDL source members should be compiled with SRTSEQ(*HEX). There are some tables with a VARCHAR(x) CCSID 1208 (UTF-8) primary key.

## Source member extensions
- .history is a history table associated with a System Period Temporal table.
- .table is a non-temporal table.
- .temporal is a System Period Temporal table.

## Long table/column names
- Long table and column names SHOULD be used if doing so will increase code readability.
- Long table names MUST be 30 characters or less in length. [2024-01-12: Kent Milligan - The Long & Short of SQL Names](https://db2ibmi.blogspot.com/2024/01/the-long-short-of-sql-names.html)

## CREATE statement
- The `CREATE OR REPLACE` syntax MUST be used for SQL objects (tables, views, etc.).

## Primary keys
- Tables MUST have a primary key and it must be over a single column
  - Except if the table is an [associative table](https://en.wikipedia.org/wiki/Associative_entity) in which case the primary key will be composed of the foreign keys it holds.
- The primary key SHOULD be a [surrogate key](https://en.wikipedia.org/wiki/Surrogate_key) except for very well defined and stable data such as ISO standards (countries, states, languages, etc.).
- Surrogate primary keys MUST use one of the integer (`SMALLINT`, `INTEGER`/`INT`, or `BIGINT`) types or the DECIMAL data type with an odd number for the precision.
- Surrogate primary keys MUST use `GENERATED ALWAYS AS IDENTITY (START WITH 1 CYCLE)`.

## Data types
- `NUMERIC` should never be used, use `DECIMAL` instead.
- `VARCHAR` is almost always preferred over `CHAR`.

## CCSID
- Character columns that might hold data that uses different CCSIDs, particularly any columns that hold data sent to/received from non-Db2 sources, SHOULD use `CCSID 1208` (UTF-8) or `CCSID 1200` (UTF-16).

## NULL
- If you cannot guarantee a column will contain data, it must use DEFAULT NULL.

## Audit columns for creation/update information
- If you want to track anything related to the creation or last update of a row (such as the user, date/time, program, etc.), make the table a System Period Temporal table. This will provide you an automatic way of tracking all changes to a row.

## LABEL statements
- Label the table and all columns.
- Column Headings (`x IS 'description'`) are limited to 60 characters (3 sets of 20 characters).
- Column Text (`x TEXT IS 'description'`) are limited to 50 characters.
- @see https://www.ibm.com/docs/en/i/7.5?topic=language-creating-descriptive-labels-using-label-statement
- @see https://www.ibm.com/docs/en/i/7.5?topic=statements-label

## Temporal and History tables
- [Working with System Period Temporal tables](https://www.ibm.com/docs/en/i/7.5?topic=administration-working-system-period-temporal-tables).
- Define history tables with the `LIKE` clause. Example: `CREATE OR REPLACE TABLE sdk4i_sec_user FOR SYSTEM NAME secusrth LIKE secusrt;`.

## Reuse deleted records
- By default, SQL tables are set to reuse deleted records (`REUSEDLT(*YES)`). This is what we want.

## Level check
- Programs that solely use SQL for input/output completely ignore the file level identifier - they do not care if a table has `LVLCHK(*YES)` or `LVLCHK(*NO)`.

## IBM Documentation
- [Special Registers](https://www.ibm.com/docs/en/i/7.5?topic=elements-special-registers)
- [Built-in Global Variables](https://www.ibm.com/docs/en/i/7.5?topic=reference-built-in-global-variables)
- [CREATE TABLE](https://www.ibm.com/docs/en/i/7.5?topic=statements-create-table)
- [HASH_SHA512](https://www.ibm.com/docs/en/i/7.5?topic=sf-hash-md5-hash-sha1-hash-sha256-hash-sha512) for password hashing
- [JOB_INFO](https://www.ibm.com/docs/en/i/7.5?topic=services-job-info-table-function) table function
- [STACK_INFO](https://www.ibm.com/docs/en/i/7.5?topic=services-stack-info-table-function) table function.