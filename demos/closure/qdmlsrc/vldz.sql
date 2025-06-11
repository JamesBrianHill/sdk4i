-- *************************************************************************************************
--   This source member will insert rows into VLDT that will ensure data entered into tables
-- related to this demo are valid.
--
-- @author James Brian Hill
-- @copyright Copyright (c) 2025 by James Brian Hill
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
-- DEMO 1 - Closure Table
-- *************************************************************************************************
INSERT INTO vldt(tbl, col, rgx, msg_id) VALUES
('ITMT', 'NAME', '^[0-9a-zA-Z''_ -]{1,50}$', 'ITMT_NAME');

COMMIT;