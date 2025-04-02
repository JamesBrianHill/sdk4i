-- *************************************************************************************************
--   This source member will insert error codes and English messages into msgt.
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

INSERT INTO msgt (id, msg) VALUES
('GENERIC_FAILURE', 'An unexpected error has occurred.');

-- *************************************************************************************************
-- COM - Communications component
-- *************************************************************************************************

-- *************************************************************************************************
-- DM - Data Mapper messages.
-- *************************************************************************************************
INSERT INTO msgt (id, msg) VALUES
('DM_PARSE_FAILED', 'The JSON payload provided could not be parsed. This issue must be corrected by the Technology team.'),
('DM_RETRIEVE_NO_COLUMN_SELECTED', 'No valid columns were selected for retrieval. You must select one or more valid columns to retrieve data.');

-- *************************************************************************************************
-- DOC - Document component
-- *************************************************************************************************

-- *************************************************************************************************
-- ERR - Error component
-- *************************************************************************************************

-- *************************************************************************************************
-- GEO - Geographic component
-- *************************************************************************************************
INSERT INTO msgt(id, msg) VALUES
('GEOCNTT_DUPLICATE_ID', 'The country ID you have entered already exists.'),
('GEOCNTT_DUPLICATE_ISO3', 'The ISO3 code you have entered already exists.'),
('GEOCNTT_DUPLICATE_ISONUM', 'The 3-digit ISO code you have entered already exists.'),
('GEOCNTT_DUPLICATE_NAME', 'The country name you have entered already exists.'),
('GEOCNTT_ID', 'The ID must be the ISO code - two uppercase letters.'),
('GEOCNTT_ISO3', 'The ISO3 value must be the three-character ISO code - three uppercase letters.'),
('GEOCNTT_ISONUM', 'The ISONUM value must be the three-digit ISO code - three numbers.'),
('GEOCNTT_NAME', 'The Name value must be the ISO name of the country composed of upper and lowercase letters, spaces, and a hyphen.'),
('GEOCNTT_TLD', 'The TLD (top level domain) is optional but if provided must be two lowercase letters.');

INSERT INTO msgt(id, msg) VALUES
('GEOSTAT_COUNTRY_ID', 'The country ID does not exist.'),
('GEOSTAT_CODE', 'The state code must be 2 characters long, both of which must be uppercase letters.'),
('GEOSTAT_DUPLICATE_CODE', 'The state code you have entered is already defined in the country you have selected.'),
('GEOSTAT_NAME', 'The state name must be 1-50 characters long, composed of UTF-8 letters, spaces, and hyphens.');

-- *************************************************************************************************
-- LNG - Language component
-- @link https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
-- *************************************************************************************************
INSERT INTO msgt (id, msg) VALUES
('LNGT_ID', 'Language IDs must be from the list of two-character ISO 639-1 codes like en, fr, etc.'),
('LNGT_DSC', 'Language descriptions must be from the list of ISO language names found in ISO 639. This description should be written in American English.'),
('LNGT_DSC_NATIVE', 'This language description is the name of the language using the native characters of that language.');

-- *************************************************************************************************
-- LOG - Logging component
-- *************************************************************************************************
INSERT INTO msgt (id, msg) VALUES
('LOGCFGT_SYS', 'The name of this LPAR.'),
('LOGCFGT_LIB', 'A valid library name.'),
('LOGCFGT_PGM', 'A valid program name.'),
('LOGCFGT_MOD', 'A valid module name.'),
('LOGCFGT_PRC', 'A valid procedure name.'),
('LOGCFGT_LOGCSIT', 'A flag indicating if we should collect call stack information. Must be 1 (true) or 0 (false). Defaults to 0.'),
('LOGCFGT_LOGEXTT', 'A flag indicating if we should collect extended debugging information. Must be 1 (true) or 0 (false). Defaults to 0.'),
('LOGCFGT_LOGMETT', 'A flag indicating if we should collect metrics. Must be 1 (true) or 0 (false). Defaults to 0.'),
('LOGCFGT_LOGMSGT_ID', 'A valid log level indicating at what level logging should begin. Leave blank if you do not want to log any messages.'),
('LOGCFGT_LOGUSET', 'A flag indicating if we should collect usage of programs and procedures. Must be 1 (true) or 0 (false). Defaults to 0.'),
('LOGCFGT_LOGWBLT', 'A flag indicating if we should collect information about local web services. Must be 1 (true) or 0 (false). Defaults to 0.'),
('LOGCFGT_LOGWBRT', 'A flag indicating if we should collect information about remote web services. Must be 1 (true) or 0 (false). Defaults to 0.'),
('LOGCFGT_ALTEMG_ID', 'An alert group indicating who should be notified when a message is logged at the EMERGENCY level.'),
('LOGCFGT_ALTALT_ID', 'An alert group indicating who should be notified when a message is logged at the ALERT level.'),
('LOGCFGT_ALTCRT_ID', 'An alert group indicating who should be notified when a message is logged at the CRITICAL level.'),
('LOGCFGT_ALTERR_ID', 'An alert group indicating who should be notified when a message is logged at the ERROR level.'),
('LOGCFGT_ALTWRN_ID', 'An alert group indicating who should be notified when a message is logged at the WARNING level.'),
('LOGCFGT_ALTNOT_ID', 'An alert group indicating who should be notified when a message is logged at the NOTICE level.'),
('LOGCFGT_ALTINF_ID', 'An alert group indicating who should be notified when a message is logged at the INFORMATION level.'),
('LOGCFGT_ALTDBG_ID', 'An alert group indicating who should be notified when a message is logged at the DEBUG level.');

INSERT INTO msgt (id, msg) VALUES
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

-- *************************************************************************************************
-- MSG - Messages component
-- *************************************************************************************************
INSERT INTO msgt (id, msg) VALUES
('MSGT_ID', 'A unique identifier for a message. Must be between 1 and 50 alphanumeric characters.'),
('MSGT_LNG_ID', 'A valid two-character language ID like en, fr, etc.'),
('MSGT_MSG', 'The message we want to show to a user. Must be between 1 and 1,024 characters.');

-- *************************************************************************************************
-- NIL - NULL handling component
-- *************************************************************************************************

-- *************************************************************************************************
-- PSN - Person component
-- *************************************************************************************************
INSERT INTO msgt (id, msg) VALUES
('PSNHONT_ID', 'An honorific is often called a salutation. Examples are Mr., Mrs., etc. Honorifics must be composed of 2-10 UTF-8 letters and an optional period.');

INSERT INTO msgt (id, msg) VALUES
('PSNSFXT_ID', 'Name suffix examples are Sr., Jr., etc. Suffixes must be composed of 2-10 UTF-8 letters and an optional period.');

-- *************************************************************************************************
-- RGX - Regular expression component
-- *************************************************************************************************

-- *************************************************************************************************
-- SEC - Security component
-- *************************************************************************************************
INSERT INTO msgt (id, msg) VALUES
('SECACGT_ACT_ID', 'The Security Action must already exist.'),
('SECACGT_GRP_ID', 'The Security Group must already exist.');

INSERT INTO msgt (id, msg) VALUES
('SECACTT_ID', 'Security action IDs must be between 1 and 50 characters long, composed of: any English letter (upper- or lower-case); any number; and underscores.'),
('SECACTT_DSC', 'The description must be between 1 and 255 characters long, composed of: any English letter (upper- or lower-case); any number; and the following symbols: !@#$%^&*()-_=+[]{}\|/<>.'),
('SECACTT_DURATION', 'The duration period for a security action must be from 1 to 370 days.');

INSERT INTO msgt (id, msg) VALUES
('SECCFLT_ACT1_ID', 'The Security Action must already exist.'),
('SECCFLT_ACT2_ID', 'The Security Action must already exist.');

INSERT INTO msgt (id, msg) VALUES
('SECGRPT_DSC', 'The security group description must be between 1 and 50 characters long, composed of: any English letter (upper- or lower-case), any number, parentheses (), underscores _, dashes -, and spaces.');

INSERT INTO msgt (id, msg) VALUES
('SECREQT_REQ_ID', 'The requester ID must already exist.'),
('SECREQT_ACT_ID', 'The Security Action must already exist.');

INSERT INTO msgt (id, msg) VALUES
('SECUSAT_USR_ID', 'The user must already exist.'),
('SECUSAT_ACT_ID', 'The Security Action must already exist.');

INSERT INTO msgt (id, msg) VALUES
('SECUSGT_USR_ID', 'The user must already exist.'),
('SECUSGT_GRP_ID', 'The Security Group must already exist.');

INSERT INTO msgt (id, msg) VALUES
('SECUSRT_APPRVR_ID', 'The approver user is invalid - it must already exist in the security user master table.'),
('SECUSRT_AUTH_FAILED', 'I am unable to verify the username and password you provided. If you believe you might have typed either your username or password incorrectly, please try again. If you are sure they are correct, please contact the help Desk.'),
('SECUSRT_CELL', 'The optional mobile phone number provided is invalid. It must be exactly 10 digits long with no punctuation of any kind.'),
('SECUSRT_CUS_ID', 'The customer ID is invalid - it must already exist in the customer master.'),
('SECUSRT_EMAIL', 'The user email is invalid - a valid email address is required.'),
('SECUSRT_EMP_ID', 'The employee ID is invalid - it must already exist in the employee master.'),
('SECUSRT_ENABLED', 'The enabled flag must be Y or N.'),
('SECUSRT_EXP_DATE', 'The expiration date must be empty or a date between today and one year from now.'),
('SECUSRT_FNAME', 'The first name must be composed of 1-50 UTF-8 letters, spaces, and apostrophes.'),
('SECUSRT_HON_ID', 'The honorific is invalid - it must already exist in the honorific master table.'),
('SECUSRT_LNAME', 'The last name must be composed of 1-50 UTF-8 letters, spaces, and apostrophes.'),
('SECUSRT_LNG_ID', 'The language ID is invalid - it must already exist in the language master table.'),
('SECUSRT_MNAME', 'The middle name is optional and if provided must be composed of 1-50 UTF-8 letters, spaces, and apostrophes.'),
('SECUSRT_PNAME', 'The preferred name is optional and if provided must be composed of 1-50 UTF-8 letters, spaces, and apostrophes.'),
('SECUSRT_PWD', 'The password must be between 14 and 128 characters long, composed of: any English letter (upper- or lower-case), any numbers, spaces, and any punctuation characters common to English keyboards in the United States. You must have at least one lowercase letter, one uppercase letter, one number, and one special character.'),
('SECUSRT_SUFFIX_ID', 'The suffix is invalid - it must already exist in the suffix master table.'),
('SECUSRT_TZ_ID', 'The timezone ID is invalid - it must already exist in the time zone master table.'),
('SECUSRT_USR', 'The username must be between 4 and 128 characters long, composed of: any English letter (upper- or lower-case), any numbers, spaces, and any punctuation characters common to English keyboards in the United States.'),
('SECUSRT_USRPRF', 'The optional user profile is invalid. Please correct or remove it.'),
('SECUSRT_VND_ID', 'The vendor ID is invalid - it must already exist in the vendor master.');

-- *************************************************************************************************
-- TME - Date, time, and timestamp component
-- *************************************************************************************************
INSERT INTO msgt (id, msg) VALUES
('TMETZNT_CODE', 'The timezone code must be 3-5 uppercase letters.'),
('TMETZNT_DSC', 'The description must be 1-50 letters and spaces.'),
('TMETZNT_OFFSET', 'The offset must be between -12 and 14.');

-- *************************************************************************************************
-- TST - Test component
-- *************************************************************************************************
INSERT INTO msgt (id, msg) VALUES
('TSTMSTT_BIGINT_VAL', 'The BIGINT value must be between 0 and 10.'),
('TSTMSTT_DATE_VAL', 'The DATE value must be between 2025-01-01 and 2025-12-31.'),
('TSTMSTT_DSC', 'The description must be 1-50 letters and spaces.'),
('TSTMSTT_INT_VAL', 'The INT value must be between 0 and 10.'),
('TSTMSTT_SMALLINT_VAL', 'The SMALLINT value must be between 0 and 10.'),
('TSTMSTT_TIME_VAL', 'The TIME value must be between 08:00:00 and 17:00:00.'),
('TSTMSTT_TIMESTAMP_VAL', 'The TIMESTAMP value must be between 2025-01-01 08:00:00.000002 and 2025-12-31 17:00:00.999997.');

-- *************************************************************************************************
-- TXT - Text handling component
-- *************************************************************************************************

-- *************************************************************************************************
-- VLD - Validation component
-- *************************************************************************************************

-- *************************************************************************************************
-- WEB - Web services component
-- *************************************************************************************************

-- *************************************************************************************************
-- WFL - Workflow component
-- *************************************************************************************************