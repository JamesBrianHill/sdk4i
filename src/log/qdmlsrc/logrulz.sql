-- *************************************************************************************************
--   This source member will insert rules into VLDRULT related to the LOG component.
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
-- Rules for LOGCFGT.
-- ***********************************************
INSERT INTO vldrult (tbl, col, rgx, vldmsgt_id) VALUES
('LOGCFGT', 'ALTCMD', '^[A-Za-z0-9&*()_ ]{0,1024}$', 'LOGCFGT_ALTCMD'),
('LOGCFGT', 'CRTCMD', '^[A-Za-z0-9&*()_ ]{0,1024}$', 'LOGCFGT_CRTCMD'),
('LOGCFGT', 'DBGCMD', '^[A-Za-z0-9&*()_ ]{0,1024}$', 'LOGCFGT_DBGCMD'),
('LOGCFGT', 'EMGCMD', '^[A-Za-z0-9&*()_ ]{0,1024}$', 'LOGCFGT_EMGCMD'),
('LOGCFGT', 'ERRCMD', '^[A-Za-z0-9&*()_ ]{0,1024}$', 'LOGCFGT_ERRCMD'),
('LOGCFGT', 'INFCMD', '^[A-Za-z0-9&*()_ ]{0,1024}$', 'LOGCFGT_INFCMD'),
('LOGCFGT', 'LIB', '^([A-Z@#$][A-Z@#$0-9_\.]{0,9})?$', 'LOGCFGT_LIB'),
('LOGCFGT', 'LOGCSIT', '^[NY]{1}$', 'LOGCFGT_LOGCSIT'),
('LOGCFGT', 'LOGEXTT', '^[NY]{1}$', 'LOGCFGT_LOGEXTT'),
('LOGCFGT', 'LOGMETT', '^[NY]{1}$', 'LOGCFGT_LOGMETT'),
('LOGCFGT', 'LOGUSET', '^[DHIMNWY]{1}$', 'LOGCFGT_LOGUSET'),
('LOGCFGT', 'LOGWBLT', '^[NY]{1}$', 'LOGCFGT_LOGWBLT'),
('LOGCFGT', 'LOGWBRT', '^[NY]{1}$', 'LOGCFGT_LOGWBRT'),
('LOGCFGT', 'MOD', '^([A-Z@#$][A-Z@#$0-9_\.]{0,9})?$', 'LOGCFGT_MOD'),
('LOGCFGT', 'NTFCMD', '^[A-Za-z0-9&*()_ ]{0,1024}$', 'LOGCFGT_NTFCMD'),
('LOGCFGT', 'PGM', '^([A-Z@#$][A-Z@#$0-9_\.]{0,9})?$', 'LOGCFGT_PGM'),
('LOGCFGT', 'PRC', '^[A-Za-z0-9_]{0,128}$', 'LOGCFGT_PRC'),
('LOGCFGT', 'SYS', '^([A-Z][A-Z0-9]{0,7})?$', 'LOGCFGT_SYS'),
('LOGCFGT', 'USR', '^([A-Z@#$][A-Z@#$0-9_\.]{0,9})?$', 'LOGCFGT_USR'),
('LOGCFGT', 'WRNCMD', '^[A-Za-z0-9&*()_ ]{0,1024}$', 'LOGCFGT_WRNCMD');

INSERT INTO vldrult (tbl, col, ftbl, fcol, vldmsgt_id) VALUES
('LOGCFGT', 'LOGMSGT_ID', 'LOGLVLT', 'ID', 'LOGCFGT_LOGMSGT_ID');


-- ***********************************************
-- Rules for LOGPURT.
-- ***********************************************
INSERT INTO vldrult (tbl, col, rgx, vldmsgt_id) VALUES
('LOGPURT', 'ID', '^[A-Z0-9]{1,8}$', 'LOGPURT_ID');

INSERT INTO vldrult (tbl, col, min_num, max_num, vldmsgt_id) VALUES
('LOGPURT', 'DB_PURGE_0', 1, 999, 'LOGPURT_DB_PURGE_0'),
('LOGPURT', 'DB_PURGE_1', 1, 999, 'LOGPURT_DB_PURGE_1'),
('LOGPURT', 'DB_PURGE_2', 1, 999, 'LOGPURT_DB_PURGE_2'),
('LOGPURT', 'DB_PURGE_3', 1, 999, 'LOGPURT_DB_PURGE_3'),
('LOGPURT', 'DB_PURGE_4', 1, 999, 'LOGPURT_DB_PURGE_4'),
('LOGPURT', 'DB_PURGE_5', 1, 999, 'LOGPURT_DB_PURGE_5'),
('LOGPURT', 'DB_PURGE_6', 1, 999, 'LOGPURT_DB_PURGE_6'),
('LOGPURT', 'DB_PURGE_7', 1, 999, 'LOGPURT_DB_PURGE_7'),
('LOGPURT', 'DB_PURGE_U', 1, 999, 'LOGPURT_DB_PURGE_U');