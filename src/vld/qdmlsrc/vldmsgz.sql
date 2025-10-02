-- *************************************************************************************************
--   This source member will insert error codes and English messages into vldmsgt.
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
-- Generic messages.
-- *************************************************************************************************
INSERT INTO vldmsgt (id, msg) VALUES
('GENERIC_FAILURE', 'An unexpected error has occurred.'),
('GENERIC_UNAUTHORIZED', 'You are not authorized to perform the requested function.');

-- *************************************************************************************************
-- VLD - Validation component
-- *************************************************************************************************
INSERT INTO vldmsgt (id, msg) VALUES
('VLDMSGT_ID', 'A unique identifier for a message. Must be between 1 and 50 alphanumeric characters.'),
('VLDMSGT_LNG_ID', 'A valid two-character language ID like en, fr, etc.'),
('VLDMSGT_MSG', 'The message we want to show to a user. Must be between 1 and 1,024 characters.'),
('VLDMSGT_LVL_ID', 'A valid error level between 0 (most severe) and 7 (least severe).');