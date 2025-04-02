-- *************************************************************************************************
--   This source member will insert rows into vldt that will ensure SDK4I tables can only have valid
-- data entered into them.
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

-- *************************************************************************************************
-- COM - Communications component
-- *************************************************************************************************

-- *************************************************************************************************
-- DOC - Document component
-- *************************************************************************************************

-- *************************************************************************************************
-- ERR - Error component
-- *************************************************************************************************

-- *************************************************************************************************
-- GEO - Geographic component
-- *************************************************************************************************
INSERT INTO vldt(tbl, col, rgx, msg_id) VALUES
('GEOCNTT', 'ID', '^[A-Z]{2}$', 'GEOCNTT_ID'),
('GEOCNTT', 'ISO3', '^[A-Z]{3}$', 'GEOCNTT_ISO3'),
('GEOCNTT', 'ISONUM', '^[0-9]{3}$', 'GEOCNTT_ISONUM'),
('GEOCNTT', 'NAME', '^[a-zA-Z'' -]{1,50}$', 'GEOCNTT_NAME'),
('GEOCNTT', 'TLD', '^[a-z]{2}$', 'GEOCNTT_TLD');

INSERT INTO vldt(tbl, col, ftbl, fcol, msg_id) VALUES
('GEOSTAT', 'COUNTRY_ID', 'GEOCNTT', 'ID', 'GEOSTAT_COUNTRY_ID');
INSERT INTO vldt(tbl, col, rgx, msg_id) VALUES
('GEOSTAT', 'CODE', '^[A-Z]{2}$', 'GEOSTAT_CODE');
INSERT INTO vldt (tbl, col, rgx, rgx_id, min_len, max_len, msg_id) VALUES
('GEOSTAT', 'NAME', '\. -', 'UTF8_LETTERS_ONLY', 1, 50, 'GEOSTAT_NAME');

-- *************************************************************************************************
-- LNG - Language component
-- *************************************************************************************************
-- @link https://stackoverflow.com/a/22075070
INSERT INTO vldt (tbl, col, rgx, msg_id) VALUES
('LNGT', 'ID', '^[a-z]{2}$', 'LNGT_ID'),
('LNGT', 'DSC', '^[a-zA-Z() -]{1,20}$', 'LNGT_DSC');
INSERT INTO vldt (tbl, col, rgx, rgx_id, min_len, max_len, msg_id) VALUES
('LNGT', 'DSC_NATIVE', ''' ', 'UTF8_LETTERS_ONLY', 0, 80, 'LNGT_DSC_NATIVE');

-- *************************************************************************************************
-- LOG - Logging component
-- *************************************************************************************************
INSERT INTO vldt (tbl, col, rgx, msg_id) VALUES
('LOGPURT', 'ID', '^[A-Z0-9]{1,8}$', 'LOGPURT_ID');
INSERT INTO vldt (tbl, col, min_num, max_num, msg_id) VALUES
('LOGPURT', 'DB_PURGE_0', 1, 731, 'LOGPURT_DB_PURGE_0'),
('LOGPURT', 'DB_PURGE_1', 1, 366, 'LOGPURT_DB_PURGE_1'),
('LOGPURT', 'DB_PURGE_2', 1, 180, 'LOGPURT_DB_PURGE_2'),
('LOGPURT', 'DB_PURGE_3', 1, 180, 'LOGPURT_DB_PURGE_3'),
('LOGPURT', 'DB_PURGE_4', 1, 90, 'LOGPURT_DB_PURGE_4'),
('LOGPURT', 'DB_PURGE_5', 1, 60, 'LOGPURT_DB_PURGE_5'),
('LOGPURT', 'DB_PURGE_6', 1, 30, 'LOGPURT_DB_PURGE_6'),
('LOGPURT', 'DB_PURGE_7', 1, 10, 'LOGPURT_DB_PURGE_7'),
('LOGPURT', 'DB_PURGE_U', 1, 10, 'LOGPURT_DB_PURGE_U');

INSERT INTO vldt (tbl, col, rgx, msg_id) VALUES
('LOGCFGT', 'LOGCSIT', '^[10]{1}$', 'LOGCFGT_LOGCSIT'),
('LOGCFGT', 'LOGEXTT', '^[10]{1}$', 'LOGCFGT_LOGEXTT'),
('LOGCFGT', 'LOGMETT', '^[10]{1}$', 'LOGCFGT_LOGMETT'),
('LOGCFGT', 'LOGUSET', '^[10]{1}$', 'LOGCFGT_LOGUSET'),
('LOGCFGT', 'LOGWBLT', '^[10]{1}$', 'LOGCFGT_LOGWBLT'),
('LOGCFGT', 'LOGWBRT', '^[10]{1}$', 'LOGCFGT_LOGWBRT');
INSERT INTO vldt (tbl, col, min_num, max_num, msg_id) VALUES
('LOGCFGT', 'LOGMSGT_ID', 0, 7, 'LOGCFGT_LOGMSGT_ID');

-- *************************************************************************************************
-- MSG - Messages component
-- *************************************************************************************************
INSERT INTO vldt (tbl, col, rgx, msg_id) VALUES
('MSGT', 'ID', '[A-Z0-9_-]{1,50}', 'MSGT_ID');
INSERT INTO vldt (tbl, col, ftbl, fcol, msg_id) VALUES
('MSGT', 'LNG_ID', 'LNGT', 'ID', 'MSGT_LNG_ID');
INSERT INTO vldt (tbl, col, rgx, rgx_id, min_len, max_len, msg_id) VALUES
('MSGT', 'MSG', '0-9()'' ', 'UTF8_LETTERS_ONLY', 1, 1024, 'MSGT_MSG');

-- *************************************************************************************************
-- NIL - NULL handling component
-- *************************************************************************************************

-- *************************************************************************************************
-- PSN - Person component
-- *************************************************************************************************
INSERT INTO vldt (tbl, col, rgx, rgx_id, min_len, max_len, msg_id) VALUES
('PSNHONT', 'ID', '\.', 'UTF8_LETTERS_ONLY', 2, 10, 'PSNHONT_ID');

INSERT INTO vldt (tbl, col, rgx, rgx_id, min_len, max_len, msg_id) VALUES
('PSNSFXT', 'ID', '\.', 'UTF8_LETTERS_ONLY', 2, 10, 'PSNSFXT_ID');

-- *************************************************************************************************
-- RGX - Regular expression component
-- *************************************************************************************************

-- *************************************************************************************************
-- SEC - Security component
-- *************************************************************************************************
INSERT INTO vldt (tbl, col, ftbl, fcol, msg_id) VALUES
('SECACGT', 'ACT_ID', 'SECACTT', 'ID', 'SECACGT_ACT_ID'),
('SECACGT', 'GRP_ID', 'SECGRPT', 'ID', 'SECACGT_GRP_ID');

INSERT INTO vldt (tbl, col, rgx, msg_id) VALUES
('SECACTT', 'ID', '^[a-zA-Z0-9_]{1,50}$', 'SECACTT_ID'),
('SECACTT', 'DSC', '^[a-zA-Z0-9!@#\$%\^&\*\(\)_=\+\[\]{}<>/\|\\ \.-]{1,50}$', 'SECACTT_DSC');
INSERT INTO vldt (tbl, col, min_num, max_num, msg_id) VALUES
('SECACTT', 'DURATION', 1, 370, 'SECACTT_DURATION');

INSERT INTO vldt (tbl, col, ftbl, fcol, msg_id) VALUES
('SECCFLT', 'ACT1_ID', 'SECACTT', 'ID', 'SECCFLT_ACT1_ID'),
('SECCFLT', 'ACT2_ID', 'SECACTT', 'ID', 'SECCFLT_ACT1_ID');

INSERT INTO vldt (tbl, col, rgx, msg_id) VALUES
('SECGRPT', 'DSC', '^[a-zA-Z0-9() _-]{1,50}$', 'SECGRPT_DSC');

INSERT INTO vldt (tbl, col, ftbl, fcol, msg_id) VALUES
('SECREQT', 'REQ_ID', 'SECUSRT', 'ID', 'SECREQT_REQ_ID'),
('SECREQT', 'ACT_ID', 'SECACTT', 'ID', 'SECREQT_ACT_ID');

INSERT INTO vldt (tbl, col, ftbl, fcol, msg_id) VALUES
('SECUSAT', 'USR_ID', 'SECUSRT', 'ID', 'SECUSAT_USR_ID'),
('SECUSAT', 'ACT_ID', 'SECACTT', 'ID', 'SECUSAT_ACT_ID');

INSERT INTO vldt (tbl, col, ftbl, fcol, msg_id) VALUES
('SECUSGT', 'USR_ID', 'SECUSRT', 'ID', 'SECUSGT_USR_ID'),
('SECUSGT', 'GRP_ID', 'SECGRPT', 'ID', 'SECUSGT_GRP_ID');

INSERT INTO vldt (tbl, col, rgx, msg_id) VALUES
('SECUSRT', 'ENABLED', '^[YN]{1}$', 'SECUSRT_ENABLED'),
('SECUSRT', 'PWD', '^[\x20-\x7E]{14,128}$', 'SECUSRT_PWD'), -- all non-control, ASCII characters
('SECUSRT', 'USR', '^[\x20-\x7E]{4,128}$', 'SECUSRT_USR'); -- all non-control, ASCII characters
INSERT INTO vldt (tbl, col, rgx_id, min_len, max_len, msg_id) VALUES
('SECUSRT', 'USRPRF', 'UTF8_ALPHANUMERIC', 1, 10, 'SECUSRT_USRPRF');
INSERT INTO vldt (tbl, col, rgx, rgx_id, min_len, max_len, msg_id) VALUES
('SECUSRT', 'FNAME', ''' ', 'UTF8_LETTERS_ONLY', 1, 50, 'SECUSRT_FNAME'),
('SECUSRT', 'LNAME', ''' ', 'UTF8_LETTERS_ONLY', 1, 50, 'SECUSRT_LNAME'),
('SECUSRT', 'MNAME', ''' ', 'UTF8_LETTERS_ONLY', 0, 50, 'SECUSRT_MNAME'),
('SECUSRT', 'PNAME', '()'' ', 'UTF8_LETTERS_ONLY', 0, 50, 'SECUSRT_PNAME');
INSERT INTO vldt (tbl, col, ftbl, fcol, msg_id) VALUES
('SECUSRT', 'APPRVR_ID', 'SECUSRT', 'ID', 'SECUSRT_APPRVR_ID'),
('SECUSRT', 'HON_ID', 'PSNHONT', 'ID', 'SECUSRT_HON_ID'),
('SECUSRT', 'LNG_ID', 'LNGT', 'ID', 'SECUSRT_LNG_ID'),
('SECUSRT', 'SUFFIX_ID', 'PSNSFXT', 'ID', 'SECUSRT_SUFFIX_ID'),
('SECUSRT', 'TZ_ID', 'TMETZNT', 'ID', 'SECUSRT_TZ_ID');
INSERT INTO vldt (tbl, col, min_date, max_date, msg_id) VALUES
('SECUSRT', 'EXP_DATE', '2025-01-01', '2099-12-31', 'SECUSRT_EXP_DATE');

-- *************************************************************************************************
-- TME - Date, time, and timestamp component
-- *************************************************************************************************
INSERT INTO vldt (tbl, col, rgx, msg_id) VALUES
('TMETZNT', 'CODE', '^[A-Z]{3,5}$', 'TMETZNT_CODE'),
('TMETZNT', 'DSC', '^[a-zA-Z ]{1,50}$', 'TMETZNT_DSC');
INSERT INTO vldt (tbl, col, min_num, max_num, msg_id) VALUES
('TMETZNT', 'OFFSET', -12, 14, 'TMETZNT_OFFSET');