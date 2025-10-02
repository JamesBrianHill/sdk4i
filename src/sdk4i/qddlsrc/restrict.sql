-- *************************************************************************************************
--   This script will add a RESTRICT ON DROP clause to all SDK4i tables.
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

ALTER TABLE lngt ADD RESTRICT ON DROP;

ALTER TABLE logcfgt ADD RESTRICT ON DROP;
ALTER TABLE logcfgth ADD RESTRICT ON DROP;
ALTER TABLE logcsit ADD RESTRICT ON DROP;
ALTER TABLE logextt ADD RESTRICT ON DROP;
ALTER TABLE logfact ADD RESTRICT ON DROP;
ALTER TABLE loglvlt ADD RESTRICT ON DROP;
ALTER TABLE logmett ADD RESTRICT ON DROP;
ALTER TABLE logmsgt ADD RESTRICT ON DROP;
ALTER TABLE logpurt ADD RESTRICT ON DROP;
ALTER TABLE logpurth ADD RESTRICT ON DROP;
ALTER TABLE loguset ADD RESTRICT ON DROP;
ALTER TABLE logwblt ADD RESTRICT ON DROP;
ALTER TABLE logwbrt ADD RESTRICT ON DROP;

ALTER TABLE rgxt ADD RESTRICT ON DROP;

ALTER TABLE vldmsgt ADD RESTRICT ON DROP;
ALTER TABLE vldrult ADD RESTRICT ON DROP;
ALTER TABLE vldrulth ADD RESTRICT ON DROP;