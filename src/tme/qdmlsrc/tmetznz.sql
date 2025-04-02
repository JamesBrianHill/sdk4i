-- *************************************************************************************************
--   This source member will insert common timezones into TMETZNT.
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
INSERT INTO tmetznt (code, dsc, offset) VALUES
('ADT', 'US Atlantic Daylight Time', -3),
('AST', 'US Atlantic Standard Time', -4),
('AKDT', 'US Alaska Daylight Time', -8),
('AKST', 'US Alaska Standard Time', -9),
('CDT', 'US Central Daylight Time', -5),
('CHST', 'US Chamorro Standard Time', 10),
('CST', 'US Central Standard Time', -6),
('EDT', 'US Eastern Daylight Time', -4),
('EST', 'US Eastern Standard Time', -5),
('HDT', 'US Hawaii-Aleutian Daylight Time', -9),
('HST', 'US Hawaii-Aleutian Standard Time', -10),
('MDT', 'US Mountain Daylight Time', -6),
('MST', 'US Mountain Standard Time', -7),
('PDT', 'US Pacific Daylight Time', -7),
('PST', 'US Pacific Standard Time', -8),
('SST', 'US Samoa Standard Time', -11);