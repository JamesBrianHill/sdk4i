-- *************************************************************************************************
--   This source member will insert security actions into SECACTT.
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
INSERT INTO secactt (id, dsc, duration) VALUES
('GEOADDT_CREATE', 'User can add addresses', 366),
('GEOADDT_DELETE', 'User can delete addresses', 366),
('GEOADDT_RETRIEVE', 'User can view addresses', 366),
('GEOADDT_UPDATE', 'User can update addresses', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('GEOADTT_CREATE', 'User can create address types', 366),
('GEOADTT_DELETE', 'User can delete address types', 366),
('GEOADTT_RETRIEVE', 'User can view address types', 366),
('GEOADTT_UPDATE', 'User can update address types', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('GEOCITT_CREATE', 'User can add cities', 366),
('GEOCITT_DELETE', 'User can delete cities', 366),
('GEOCITT_RETRIEVE', 'User can view cities', 366),
('GEOCITT_UPDATE', 'User can update cities', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('GEOCNTT_CREATE', 'User can add countries', 366),
('GEOCNTT_DELETE', 'User can delete countries', 366),
('GEOCNTT_RETRIEVE', 'User can view countries', 366),
('GEOCNTT_UPDATE', 'User can update countries', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('GEOCOUT_CREATE', 'User can create counties', 366),
('GEOCOUT_DELETE', 'User can delete counties', 366),
('GEOCOUT_RETRIEVE', 'User can view counties', 366),
('GEOCOUT_UPDATE', 'User can update counties', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('GEOSTAT_CREATE', 'User can create states', 366),
('GEOSTAT_DELETE', 'User can delete states', 366),
('GEOSTAT_RETRIEVE', 'User can view states', 366),
('GEOSTAT_UPDATE', 'User can update states', 366);

-- *************************************************************************************************
-- LNG - Language component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('LNGT_CREATE', 'User can create language codes', 366),
('LNGT_DELETE', 'User can delete language codes', 366),
('LNGT_RETRIEVE', 'User can view language codes', 366),
('LNGT_UPDATE', 'User can update language codes', 366);

-- *************************************************************************************************
-- LOG - Logging component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('LOGCFGT_CREATE', 'User can create log configurations', 366),
('LOGCFGT_DELETE', 'User can delete log configurations', 366),
('LOGCFGT_RETRIEVE', 'User can view log configurations', 366),
('LOGCFGT_UPDATE', 'User can update log configurations', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('LOGFACT_CREATE', 'User can create log facilities', 366),
('LOGFACT_DELETE', 'User can delete log facilities', 366),
('LOGFACT_RETRIEVE', 'User can view log facilities', 366),
('LOGFACT_UPDATE', 'User can update log facilities', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('LOGLVLT_CREATE', 'User can create log levels', 366),
('LOGLVLT_DELETE', 'User can delete log levels', 366),
('LOGLVLT_RETRIEVE', 'User can view log levels', 366),
('LOGLVLT_UPDATE', 'User can update log levels', 366);

-- *************************************************************************************************
-- MSG - Messages component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('MSGT_CREATE', 'User can create system messages', 366),
('MSGT_DELETE', 'User can delete system messages', 366),
('MSGT_RETRIEVE', 'User can view system messages', 366),
('MSGT_UPDATE', 'User can update system messages', 366);

-- *************************************************************************************************
-- NIL - NULL handling component
-- *************************************************************************************************

-- *************************************************************************************************
-- PSN - Person component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('PSNHONT_CREATE', 'User can create honorifics', 366),
('PSNHONT_DELETE', 'User can delete honorifics', 366),
('PSNHONT_RETRIEVE', 'User can view honorifics', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('PSNSFXT_CREATE', 'User can create name suffixes', 366),
('PSNSFXT_DELETE', 'User can delete name suffixes', 366),
('PSNSFXT_RETRIEVE', 'User can view name suffixes', 366);

-- *************************************************************************************************
-- RGX - Regular expression component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('RGXT_CREATE', 'User can create regular expression templates', 366),
('RGXT_DELETE', 'User can delete regular expression templates', 366),
('RGXT_RETRIEVE', 'User can view regular expression templates', 366),
('RGXT_UPDATE', 'User can update regular expression templates', 366);

-- *************************************************************************************************
-- SEC - Security component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('SECACGT_CREATE', 'User can add security actions to security groups', 90),
('SECACGT_DELETE', 'User can remove security actions from security groups', 90),
('SECACGT_RETRIEVE', 'User can view security actions associated with security groups', 90);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECACTT_CREATE', 'User can create security actions', 90),
('SECACTT_DELETE', 'User can delete security actions', 90),
('SECACTT_RETRIEVE', 'User can view security actions', 90),
('SECACTT_UPDATE', 'User can update security actions', 90);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECGRPT_CREATE', 'User can create security groups', 90),
('SECGRPT_DELETE', 'User can delete security groups', 90),
('SECGRPT_RETRIEVE', 'User can view security groups', 90),
('SECGRPT_UPDATE', 'User can update security groups', 90);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECREQT_CREATE', 'User can create security requests', 90),
('SECREQT_DELETE', 'User can delete security requests', 90),
('SECREQT_RETRIEVE', 'User can view security requests', 90),
('SECREQT_UPDATE', 'User can update security requests', 90);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECUSAT_CREATE', 'User can add security actions to users', 90),
('SECUSAT_DELETE', 'User can remove security actions from users', 90),
('SECUSAT_RETRIEVE', 'User can view security actions of users', 90);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECUSGT_CREATE', 'User can add users to security groups', 90),
('SECUSGT_DELETE', 'User can remove users from security groups', 90),
('SECUSGT_RETRIEVE', 'User can view users associated with security groups', 90);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECUSRT_CREATE', 'User can create other users', 90),
('SECUSRT_DELETE', 'User can delete other users', 90),
('SECUSRT_RETRIEVE', 'User can view other users', 90),
('SECUSRT_UPDATE', 'User can update other users', 90);

-- *************************************************************************************************
-- TME - Date, time, and timestamp component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('TMETZNT_CREATE', 'User can create timezone entries', 366),
('TMETZNT_DELETE', 'User can delete timezone entries', 366),
('TMETZNT_RETRIEVE', 'User can view timezone entries', 366),
('TMETZNT_UPDATE', 'User can update timezone entries', 366);

-- *************************************************************************************************
-- TST - Test component
-- *************************************************************************************************

-- *************************************************************************************************
-- TXT - Text handling component
-- *************************************************************************************************

-- *************************************************************************************************
-- VLD - Validation component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('VLDT_CREATE', 'User can create validation rules', 366),
('VLDT_DELETE', 'User can delete validation rules', 366),
('VLDT_RETRIEVE', 'User can view validation rules', 366),
('VLDT_UPDATE', 'User can update validation rules', 366);

-- *************************************************************************************************
-- WEB - Web services component
-- *************************************************************************************************

-- *************************************************************************************************
-- WFL - Workflow component
-- *************************************************************************************************