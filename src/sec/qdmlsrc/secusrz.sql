-- *************************************************************************************************
--   This source member will create a user based on the user profile executing the script.
--
--   Note that the password created for this user is a randomly generated 16-character password.
-- This default user can be deleted or updated as you see fit.
--
-- @author James Brian Hill
-- @copyright Copyright (c) 2015 - 2025 by James Brian Hill
-- @license GNU General Public License version 3
-- @link https://www.gnu.org/licenses/gpl-3.0.html
-- @link https://www.ibm.com/docs/en/i/7.6.0?topic=registers-current-user
-- @link https://www.ibm.com/docs/en/i/7.6.0?topic=functions-chr
-- @link https://www.ibm.com/docs/en/i/7.6.0?topic=sf-hash-md5-hash-sha1-hash-sha256-hash-sha512
-- @link https://www.ibm.com/docs/en/i/7.6.0?topic=functions-random-rand
-- *************************************************************************************************

-- *************************************************************************************************
--   This program is free software: you can redistribute it and/or modify it under the terms of the
-- GNU General Public License as published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
--   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
--   You should have received a copy of the GNU General Public License along with this program. If
-- not, see https://www.gnu.org/licenses/gpl-3.0.html
-- *************************************************************************************************
INSERT INTO secusrt(usr, pwd, pwd_exp, hon_id, fname, lname, email, usrprf, apprvr_id, tz_id) VALUES
(CURRENT_USER,
HASH_SHA512(CAST(
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33) ||
  CHR(INT(RAND() * 93) + 33)
AS VARCHAR(128))),
NOW() + 90 DAYS,
'Mr.',
'Default',
'User',
'me@example.com',
CURRENT_USER,
1,
5);