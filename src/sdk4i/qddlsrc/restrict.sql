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

ALTER TABLE altgrmt ADD RESTRICT ON DROP;
ALTER TABLE altgrpt ADD RESTRICT ON DROP;

ALTER TABLE geoaddt ADD RESTRICT ON DROP;
ALTER TABLE geoadtt ADD RESTRICT ON DROP;
ALTER TABLE geocitt ADD RESTRICT ON DROP;
ALTER TABLE geocntt ADD RESTRICT ON DROP;
ALTER TABLE geocout ADD RESTRICT ON DROP;
ALTER TABLE geostat ADD RESTRICT ON DROP;

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

ALTER TABLE msgt ADD RESTRICT ON DROP;

ALTER TABLE psnhont ADD RESTRICT ON DROP;
ALTER TABLE psnsfxt ADD RESTRICT ON DROP;

ALTER TABLE rgxt ADD RESTRICT ON DROP;

ALTER TABLE secacgt ADD RESTRICT ON DROP;
ALTER TABLE secacgth ADD RESTRICT ON DROP;
ALTER TABLE secactt ADD RESTRICT ON DROP;
ALTER TABLE secactth ADD RESTRICT ON DROP;
ALTER TABLE secgrpt ADD RESTRICT ON DROP;
ALTER TABLE secgrpth ADD RESTRICT ON DROP;
ALTER TABLE secusat ADD RESTRICT ON DROP;
ALTER TABLE secusath ADD RESTRICT ON DROP;
ALTER TABLE secusgt ADD RESTRICT ON DROP;
ALTER TABLE secusgth ADD RESTRICT ON DROP;
ALTER TABLE secusrt ADD RESTRICT ON DROP;
ALTER TABLE secusrth ADD RESTRICT ON DROP;

ALTER TABLE tmetznt ADD RESTRICT ON DROP;

ALTER TABLE vldt ADD RESTRICT ON DROP;
ALTER TABLE vldth ADD RESTRICT ON DROP;