-- *************************************************************************************************
--   This source member will insert Canadian provinces/territories information into GEOSTAT.
--
-- @author James Brian Hill
-- @copyright Copyright (c) 2015 - 2025 by James Brian Hill
-- @license GNU General Public License version 3
-- @link https://www.gnu.org/licenses/gpl-3.0.html
--
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
INSERT INTO geostat (country_id, code, name) VALUES
('CA', 'AB', 'Alberta'),
('CA', 'BC', 'British Columbia'),
('CA', 'MB', 'Manitoba'),
('CA', 'NB', 'New Brunswick'),
('CA', 'NL', 'Newfoundland and Labrador'),
('CA', 'NS', 'Nova Scotia'),
('CA', 'NT', 'Northwest Territories'),
('CA', 'NU', 'Nunavut'),
('CA', 'ON', 'Ontario'),
('CA', 'PE', 'Prince Edward Island'),
('CA', 'QC', 'Quebec'),
('CA', 'SK', 'Saskatchewan'),
('CA', 'YT', 'Yukon');