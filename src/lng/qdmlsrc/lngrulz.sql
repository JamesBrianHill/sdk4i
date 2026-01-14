-- *************************************************************************************************
--   This source member will insert rules into VLDRULT related to the LNG component.
--
-- NOTE: while IBM i object names can have $, #, and @ in them, we intentionally disallow them in
--       our validation rules. All three of these characters are "variant", meaning they can change
--       based on CCSID. For instance, the octothorpe (#) is x7B in CCSID 37 but x7B in CCSID 297
--       (France), it is the symbol for British Pounds.
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

INSERT INTO vldrult (tbl, col, rgx, vldmsgt_id) VALUES
('LNGT', 'ID', '^[a-z]{2}$', 'LNGT_ID'),
('LNGT', 'DSC', '^[a-zA-Z() -]{1,20}$', 'LNGT_DSC');

INSERT INTO vldrult (tbl, col, rgx, rgx_id, min_len, max_len, vldmsgt_id) VALUES
('LNGT', 'DSC_NATIVE', ''' ', 'UTF8_LETTERS_ONLY', 0, 80, 'LNGT_DSC_NATIVE');