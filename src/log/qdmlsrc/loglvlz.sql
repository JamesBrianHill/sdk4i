-- *************************************************************************************************
--   This SQL statement will insert the 8 logging levels into LOGLVLT.
--
-- 0 = Emergency: system is unusable
-- 1 = Alert: action must be taken immediately
-- 2 = Critical: critical conditions
-- 3 = Error: error conditions
-- 4 = Warning: warning conditions
-- 5 = Notice: normal but significant condition
-- 6 = Informational: informational messages
-- 7 = Debug: debug-level messages
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
INSERT INTO loglvlt (id, code, dsc) VALUES
(0, 'LL_EMG', 'Emergency'),
(1, 'LL_ALT', 'Alert'),
(2, 'LL_CRT', 'Critical'),
(3, 'LL_ERR', 'Error'),
(4, 'LL_WRN', 'Warning'),
(5, 'LL_NOT', 'Notice'),
(6, 'LL_INF', 'Informational'),
(7, 'LL_DBG', 'Debug');