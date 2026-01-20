-- *************************************************************************************************
--   This source member will insert error codes and English messages into vldmsgt for the LNG
-- component.
--
-- @author James Brian Hill
-- @copyright Copyright (c) 2015 - 2026 by James Brian Hill
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
('LNGT_ID', 'Language IDs must be from the list of two-character ISO 639-1 codes like en, fr, etc.'),
('LNGT_DSC', 'Language descriptions must be from the list of ISO language names found in ISO 639. This description should be written in American English.'),
('LNGT_DSC_NATIVE', 'This language description is the name of the language using the native characters of that language.');