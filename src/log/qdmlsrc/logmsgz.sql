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
('LOGCFGT_SYS', 'A valid LPAR name. Up to 8 characters long, the first character must be an uppercase letter. The remaining characters can be uppercase letters or numbers.'),
('LOGCFGT_LIB', 'A valid library name. Up to 10 characters long, the first character must be an uppercase letter. The remaining characters can be uppercase letters, numbers and underscores.'),
('LOGCFGT_PGM', 'A valid program name. Up to 10 characters long, the first character must be an uppercase letter. The remaining characters can be uppercase letters, numbers and underscores.'),
('LOGCFGT_MOD', 'A valid module name. Up to 10 characters long, the first character must be an uppercase letter. The remaining characters can be uppercase letters, numbers, and underscores.'),
('LOGCFGT_PRC', 'A valid procedure name. Up to 128 characters long. the first character must be a letter. The remaining characters can be letters, numbers, and underscores.'),
('LOGCFGT_LOGCSIT', 'A flag indicating if we should collect call stack information. Must be Y or N. Defaults to N.'),
('LOGCFGT_LOGEXTT', 'A flag indicating if we should collect extended debugging information. Must be Y or N. Defaults to N.'),
('LOGCFGT_LOGMETT', 'A flag indicating if we should collect metrics. Must be Y or N. Defaults to N'),
('LOGCFGT_LOGMSGT_ID', 'A valid log level indicating at what level logging should begin.'),
('LOGCFGT_LOGUSET', 'A flag indicating if we should collect usage of programs and procedures. Must be D(Daily), H(Hourly), I(Minute), M(Month), N(None), W(Weekly), Y(Yearly). Defaults to D.'),
('LOGCFGT_LOGWBLT', 'A flag indicating if we should collect information about local web services. Must be Y or N. Defaults to N.'),
('LOGCFGT_LOGWBRT', 'A flag indicating if we should collect information about remote web services. Must be Y or N. Defaults to N.'),
('LOGCFGT_EMGCMD', 'A command that should be executed when an EMERGENCY level (0) event is logged. This can be up to 1024 characters long.'),
('LOGCFGT_ALTCMD', 'A command that should be executed when an ALERT level (1) event is logged. This can be up to 1024 characters long.'),
('LOGCFGT_CRTCMD', 'A command that should be executed when an CRITICAL level (2) event is logged. This can be up to 1024 characters long.'),
('LOGCFGT_ERRCMD', 'A command that should be executed when an ERROR level (3) event is logged. This can be up to 1024 characters long.'),
('LOGCFGT_WRNCMD', 'A command that should be executed when an WARNING level (4) event is logged. This can be up to 1024 characters long.'),
('LOGCFGT_NOTCMD', 'A command that should be executed when an NOTIFICATION level (5) event is logged. This can be up to 1024 characters long.'),
('LOGCFGT_INFCMD', 'A command that should be executed when an INFORMATIONAL level (6) event is logged. This can be up to 1024 characters long.'),
('LOGCFGT_DBGCMD', 'A command that should be executed when an DEBUG level (7) event is logged. This can be up to 1024 characters long.');

INSERT INTO vldmsgt (id, msg) VALUES
('LOGPURT_ID', 'The ID is the name of the LPAR.'),
('LOGPURT_DB_PURGE_0', 'The number of days we should keep Emergency level logs. Valid values are 1 to 999. Defaults to 731 (two years).'),
('LOGPURT_DB_PURGE_1', 'The number of days we should keep Alert level logs. Valid values are 1 to 999. Defaults to 366 (one year).'),
('LOGPURT_DB_PURGE_2', 'The number of days we should keep Critical level logs. Valid values are 1 to 999. Defaults to 180 (six months).'),
('LOGPURT_DB_PURGE_3', 'The number of days we should keep Error level logs. Valid values are 1 to 999. Defaults to 180 (six months).'),
('LOGPURT_DB_PURGE_4', 'The number of days we should keep Warning level logs. Valid values are 1 to 999. Defaults to 90 (three months).'),
('LOGPURT_DB_PURGE_5', 'The number of days we should keep Notification level logs. Valid values are 1 to 999. Defaults to 60 (two months).'),
('LOGPURT_DB_PURGE_6', 'The number of days we should keep Information level logs. Valid values are 1 to 999. Defaults to 30 (one month).'),
('LOGPURT_DB_PURGE_7', 'The number of days we should keep Debug level logs. Valid values are 1 to 999. Defaults to 10 days.'),
('LOGPURT_DB_PURGE_U', 'The number of days we will keep usage logs. Valid values are 1 to 999. Defaults to 10 days.');