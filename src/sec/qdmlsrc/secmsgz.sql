-- *************************************************************************************************
--   This source member will insert error codes and English messages into vldmsgt for the LOG
-- component.
--
-- @author James Brian Hill
-- @copyright Copyright (c) 2015 - 2025 by James Brian Hill
-- @license GNU General Public License version 3
-- @link https://www.gnu.org/licenses/gpl-3.0.html
-- @link https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
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
INSERT INTO vldmsgt (id, msg) VALUES
('SECACGT_ACT_ID', 'A valid action ID from the SECACTT table.'),
('SECACGT_GRP_ID', 'A valid group ID from the SECGRPT table.');

INSERT INTO vldmsgt (id, msg) VALUES
('SECACTT_ID', 'The unique identifier for a Security Action. From 1 to 50 characters long, composed of upper and/or lowercase letters, numbers, and underscores.'),
('SECACTT_DSC', 'The description of the Security Action. From 1 to 255 characters long.'),
('SECACTT_DURATION', 'The number of days a user can go without exercising this authority before it is automatically removed. Defaults to 30 and valid values are 0 - 999.'),
('SECACTT_RENEWABLE', 'A flag indicating if the duration an authority was granted for resets every time that authority is exercised. Must be Y or N, defaults to Y.');

INSERT INTO vldmsgt (id, msg) VALUES
('SECGRPT_DSC', 'The description of the Security Group. From 1 to 50 characters long.');

INSERT INTO vldmsgt (id, msg) VALUES
('SECUSAT_USR_ID', 'A valid user ID from the SECUSRT table.'),
('SECUSAT_ACT_ID', 'A valid action ID from the SECACTT table.'),
('SECUSAT_LAST_USED', 'A valid date between 2025-01-01 and 2099-12-31.');

INSERT INTO vldmsgt (id, msg) VALUES
('SECUSGT_USR_ID', 'A valid user ID from the SECUSRT table.'),
('SECUSGT_GRP_ID', 'A valid group ID from the SECGRPT table.');

INSERT INTO vldmsgt (id, msg) VALUES
('SECUSRT_USR', 'A username is required and is 3 to 128 characters composed of upper and/or lowercase letters, numbers, underscores, and dashes.'),
('SECUSRT_PWD', 'A password is required and is 12 to 128 characters composed of any non-control ASCII characters.'),
('SECUSRT_PWD_DUR', 'The password duration lasts from 1 to 999 days and defaults to 90.'),
('SECUSRT_PWD_EXP', 'The password expiration date is updated every time the password is changed.'),
('SECUSRT_HON_ID', 'An honorific is required and must be a valid value from the PSNHONT table.'),
('SECUSRT_FNAME', 'A first name is required and must be 1 to 50 characters long, beginning with an uppercase letter followed by upper and/or lowercase letters, spaces, and dashes.'),
('SECUSRT_MNAME', 'A middle name is optional and if one is entered, must be 1 to 50 characters long, beginning with an uppercase letter followed by upper and/or lowercase letters, spaces, and dashes.'),
('SECUSRT_LNAME', 'A last name (the family name) is required and must be 1 to 50 characters long, beginning with an uppercase letter followed by upper and/or lowercase letters, spaces, and dashes.'),
('SECUSRT_PNAME', 'A preferred name is optional and if one is entered, must be 1 to 50 characters long, beginning with an uppercase letter followed by upper and/or lowercase letters, spaces, and dashes.'),
('SECUSRT_SUFFIX_ID', 'A suffix is optional and if one is chosen, must be a valid one from the PSNSFXT table.'),
('SECUSRT_EMAIL', 'An email address is required and can be up to 254 characters long.'),
('SECUSRT_CELL', 'A mobile number is optional and if one is entered, must be exactly 10 digits long.'),
('SECUSRT_USRPRF', 'A user profile is optional and if one is entered, must be 1 to 10 alphanumeric characters.'),
('SECUSRT_APPRVR_ID', 'A manager ID is required and must be a valid ID from the SECUSRT table.'),
('SECUSRT_EXP_DATE', 'An expiration date is optional and indicates the date this user account should be disabled/deleted.'),
('SECUSRT_AUTO_OUT', 'The automatic logout value is required and indicates how many minutes will pass before a user is automatically logged out due to inactivity. Valid values are 1 - 999, the default is 120.'),
('SECUSRT_IS_ENABLED', 'The is_enabled flag indicates if this account is currently enabled or not. Valid values are Y and N. When creating a new user the default is Y.'),
('SECUSRT_TZ_ID', 'The timezone ID is required and must be a valid value from the TMETZNT table.'),
('SECUSRT_LNG_ID', 'The language ID is required and must be a valid value from the LNGT table. It defaults to en for English.');