# TXT (Text Utilities) Component

The `TXT` component of SDK4i provides utilities related to text manipulation.

The [`TXT_Q`](./qrpglesrc/TXT_Q.md) procedure can be very helpful when building dynamic SQL statements and the programmer needs to %TRIM() and wrap single quotes around a value. The prefix allows the programmer to prepend and/or suffix the trimmed source string before it is wrapped in single quotes.

The [`TXT_Justify`](./qrpglesrc/TXT_Justify.md) procedure will allow you to justify (left, right, or center) a string within another string. Many shops already have utilities to center a string but they only handle characters in their local CCSID and often cannot do left or right justification. `TXT_Justify` works with UTF-8 (CCSID = 1208) so it might be helpful when dealing with non-native characters.

The [`TXT_Tokenize`](./qrpglesrc/TXT_Tokenize.md) procedure will "tokenize" a string by breaking up a string into an array of substrings. Conceptually, this is very similar to the `C` function `strtok`. The main difference is this procedure can accept an array of delimiters.