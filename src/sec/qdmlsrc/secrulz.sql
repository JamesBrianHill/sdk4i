-- *************************************************************************************************
--   This source member will insert rules into VLDRULT related to the SEC component.
--
-- NOTE: while IBM i object names can have $, #, and @ in them, we intentionally disallow them in
--       our validation rules. All three of these characters are "variant", meaning they can change
--       based on CCSID. For instance, the octothorpe (#) is x7B in CCSID 37 but x7B in CCSID 297
--       (France), it is the symbol for British Pounds.
--
-- @author James Brian Hill
-- @copyright Copyright (c) 2015 - 2025 by James Brian Hill
-- @license GNU General Public License version 3
-- @link https://www.gnu.org/licenses/gpl-3.0.html
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

-- ***********************************************
-- Rules for SECACGT.
-- ***********************************************
INSERT INTO vldrult (tbl, col, ftbl, fcol, vldmsgt_id) VALUES
('SECACGT', 'ACT_ID', 'SECACTT', 'ID', 'SECACGT_ACT_ID'),
('SECACGT', 'GRP_ID', 'SECGRPT', 'ID', 'SECACGT_GRP_ID');


-- ***********************************************
-- Rules for SECACTT.
-- ***********************************************
INSERT INTO vldrult (tbl, col, rgx, vldmsgt_id) VALUES
('SECACTT', 'ID', '^[a-zA-Z0-9_]{1,50}$', 'SECACTT_ID'),
('SECACTT', 'RENEWABLE', '^[YN]{1}$', 'SECACTT_RENEWABLE');

INSERT INTO vldrult (tbl, col, rgx_id, min_len, max_len, vldmsgt_id) VALUES
('SECACTT', 'DSC', 'ASCII_ALPHANUMERIC_AND_SPECIAL_CHARACTERS', 1, 255, 'SECACTT_DSC');

INSERT INTO vldrult (tbl, col, min_num, max_num, vldmsgt_id) VALUES
('SECACTT', 'DURATION', 0, 999, 'SECACTT_DURATION');


-- ***********************************************
-- Rules for SECGRPT.
-- ***********************************************
INSERT INTO vldrult (tbl, col, rgx_id, min_len, max_len, vldmsgt_id) VALUES
('SECGRPT', 'DSC', 'ASCII_ALPHANUMERIC_AND_SPECIAL_CHARACTERS', 1, 50, 'SECGRPT_DSC');


-- ***********************************************
-- Rules for SECUSAT.
-- ***********************************************
INSERT INTO vldrult (tbl, col, ftbl, fcol, vldmsgt_id) VALUES
('SECUSAT', 'USR_ID', 'SECUSRT', 'ID', 'SECUSAT_USR_ID'),
('SECUSAT', 'ACT_ID', 'SECACTT', 'ID', 'SECUSAT_ACT_ID');

INSERT INTO vldrult (tbl, col, min_date, max_date, vldmsgt_id) VALUES
('SECUSAT', 'LAST_USED', '2025-01-01', '2099-12-31', 'SECUSAT_LAST_USED');


-- ***********************************************
-- Rules for SECUSGT.
-- ***********************************************
INSERT INTO vldrult (tbl, col, ftbl, fcol, vldmsgt_id) VALUES
('SECUSGT', 'USR_ID', 'SECUSRT', 'ID', 'SECUSGT_USR_ID'),
('SECUSGT', 'GRP_ID', 'SECGRPT', 'ID', 'SECUSGT_GRP_ID');


-- ***********************************************
-- Rules for SECUSRT.
-- ***********************************************
INSERT INTO vldrult (tbl, col, ftbl, fcol, vldmsgt_id) VALUES
('SECUSRT', 'APPRVR_ID', 'SECUSRT', 'ID', 'SECUSRT_APPRVR_ID'),
('SECUSRT', 'HON_ID', 'PSNHONT', 'ID', 'SECUSRT_HON_ID'),
('SECUSRT', 'SUFFIX_ID', 'PSNSFXT', 'ID', 'SECUSRT_SUFFIX_ID'),
('SECUSRT', 'TZ_ID', 'TMETZNT', 'ID', 'SECUSRT_TZ_ID'),
('SECUSRT', 'LNG_ID', 'LNGT', 'ID', 'SECUSRT_LNG_ID');

INSERT INTO vldrult (tbl, col, rgx, vldmsgt_id) VALUES
('SECUSRT', 'USR', '^[a-zA-Z0-9_-]{3,128}$', 'SECUSRT_USR'), -- all non-control, ASCII characters
('SECUSRT', 'PWD', '^[\x20-\x7E]{12,128}$', 'SECUSRT_PWD'), -- all non-control, ASCII characters
('SECUSRT', 'EMAIL', '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', 'SECUSRT_EMAIL'),
('SECUSRT', 'CELL', '^((\+\d{1,3}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4})?$', 'SECUSRT_CELL'),
('SECUSRT', 'USRPRF', '^([A-Z][A-Z0-9_]{0,9})?$', 'SECUSRT_USRPRF'),
('SECUSRT', 'IS_ENABLED', '^[YN]{1}$', 'SECUSRT_IS_ENABLED');

INSERT INTO vldrult (tbl, col, min_num, max_num, vldmsgt_id) VALUES
('SECUSRT', 'PWD_DUR', 1, 999, 'SECUSRT_PWD_DUR'),
('SECUSRT', 'AUTO_OUT', 1, 999, 'SECUSRT_AUTO_OUT');

INSERT INTO vldrult (tbl, col, rgx, rgx_id, min_len, max_len, vldmsgt_id) VALUES
('SECUSRT', 'FNAME', ''' ', 'UTF8_LETTERS_ONLY', 1, 50, 'SECUSRT_FNAME'),
('SECUSRT', 'LNAME', ''' ', 'UTF8_LETTERS_ONLY', 1, 50, 'SECUSRT_LNAME'),
('SECUSRT', 'MNAME', ''' ', 'UTF8_LETTERS_ONLY', 0, 50, 'SECUSRT_MNAME'),
('SECUSRT', 'PNAME', '()'' ', 'UTF8_LETTERS_ONLY', 0, 50, 'SECUSRT_PNAME');

INSERT INTO vldrult (tbl, col, min_date, max_date, vldmsgt_id) VALUES
('SECUSRT', 'EXP_DATE', '2025-01-01', '2099-12-31', 'SECUSRT_EXP_DATE');

INSERT INTO vldrult (tbl, col, min_date, max_date, vldmsgt_id) VALUES
('SECUSRT', 'PWD_EXP', '2025-01-01-00.00.00.000000', '2099-12-31-23.59.59.999999', 'SECUSRT_PWD_EXP');