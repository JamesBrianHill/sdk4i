# ERR (Error Utilities) Component

The `ERR` component of SDK4i provides utilities for handling errors consistently and gracefully.

The [`ERR_IsSQLError`](./qrpglesrc/ERR_IsSQLError.md) procedure uses [GET DIAGNOSTICS](https://www.ibm.com/docs/en/i/7.6.0?topic=statements-get-diagnostics) to determine if the previously executed SQL statement was successful or not. If it was not successful, helpful information is captured in a `tpl_sdk4i_err_sql_diagnostics_ds` data structure and returned to the programmer to be handled however they see fit.

By default, any SQLSTATE other than '00000' is considered invalid and results in the `ERR_IsSQLError` procedure returning `*OFF` and a populated `tpl_sdk4i_err_sql_diagnostics_ds` based data structure. The programmer can optionally pass an array of SQLSTATE values that should not be considered an error. A common example of this would be to allow the SQLSTATE '02000' which is the result of a query that found no data. IBM helpfully provides a list of [SQLSTATE values in their documentation](https://www.ibm.com/docs/en/i/7.6.0?topic=codes-listing-sqlstate-values).