-- *************************************************************************************************
--   This SQL statement will insert the 24 facility codes into LOGFACT.
--
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
INSERT INTO logfact (id, dsc) VALUES
(0, 'Kernel Messages (kern)'),
(1, 'User-Level Messages (user)'),
(2, 'Mail System (mail)'),
(3, 'System Daemons (daemon)'),
(4, 'Security/Authorization Messages (auth)'),
(5, 'Message Generated Internally by Syslog (syslog)'),
(6, 'Line Printer Subsystem (lpr)'),
(7, 'Network News Subsystem (news)'),
(8, 'UUCP Subsystem (uucp)'),
(9, 'Clock Daemon (cron)'),
(10, 'Security/Authorization Messages (authpriv)'),
(11, 'FTP Daemon (ftp)'),
(12, 'NTP Subsystem (ntp)'),
(13, 'Log Audit (security)'),
(14, 'Log Alert (console)'),
(15, 'Clock Daemon (solaris-cron)'),
(16, 'Local Use 0 (local0)'),
(17, 'Local Use 1 (local1)'),
(18, 'Local Use 2 (local2)'),
(19, 'Local Use 3 (local3)'),
(20, 'Local Use 4 (local4)'),
(21, 'Local Use 5 (local5)'),
(22, 'Local Use 6 (local6)'),
(23, 'Local Use 7 (local7)');
