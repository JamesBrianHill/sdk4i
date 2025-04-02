-- *************************************************************************************************
--   This script will add versioning to all of our temporal tables.
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

ALTER TABLE logpurt ADD VERSIONING USE HISTORY TABLE logpurth ON DELETE ADD EXTRA ROW;
ALTER TABLE logcfgt ADD VERSIONING USE HISTORY TABLE logcfgth ON DELETE ADD EXTRA ROW;

ALTER TABLE secacgt ADD VERSIONING USE HISTORY TABLE secacgth ON DELETE ADD EXTRA ROW;
ALTER TABLE secactt ADD VERSIONING USE HISTORY TABLE secactth ON DELETE ADD EXTRA ROW;
ALTER TABLE secgrpt ADD VERSIONING USE HISTORY TABLE secgrpth ON DELETE ADD EXTRA ROW;
ALTER TABLE secusat ADD VERSIONING USE HISTORY TABLE secusath ON DELETE ADD EXTRA ROW;
ALTER TABLE secusgt ADD VERSIONING USE HISTORY TABLE secusgth ON DELETE ADD EXTRA ROW;
ALTER TABLE secusrt ADD VERSIONING USE HISTORY TABLE secusrth ON DELETE ADD EXTRA ROW;

ALTER TABLE vldt ADD VERSIONING USE HISTORY TABLE vldth ON DELETE ADD EXTRA ROW;
