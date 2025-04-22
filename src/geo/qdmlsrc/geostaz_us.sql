-- *************************************************************************************************
--   This source member will insert United States states/territories information into GEOSTAT.
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
('US', 'AK', 'Alaska'),
('US', 'AL', 'Alabama'),
('US', 'AR', 'Arkansas'),
('US', 'AS', 'American Samoa'),
('US', 'AZ', 'Arizona'),
('US', 'CA', 'California'),
('US', 'CO', 'Colorado'),
('US', 'CT', 'Connecticut'),
('US', 'DC', 'District of Columbia'),
('US', 'DE', 'Delaware'),
('US', 'FL', 'Florida'),
('US', 'GA', 'Georgia'),
('US', 'GU', 'Guam'),
('US', 'HI', 'Hawaii'),
('US', 'IA', 'Iowa'),
('US', 'ID', 'Idaho'),
('US', 'IL', 'Illinois'),
('US', 'IN', 'Indiana'),
('US', 'KS', 'Kansas'),
('US', 'KY', 'Kentucky'),
('US', 'LA', 'Louisiana'),
('US', 'MA', 'Massachusetts'),
('US', 'MD', 'Maryland'),
('US', 'ME', 'Maine'),
('US', 'MI', 'Michigan'),
('US', 'MN', 'Minnesota'),
('US', 'MO', 'Missouri'),
('US', 'MP', 'Northern Mariana Islands'),
('US', 'MS', 'Mississippi'),
('US', 'MT', 'Montana'),
('US', 'NC', 'North Carolina'),
('US', 'ND', 'North Dakota'),
('US', 'NE', 'Nebraska'),
('US', 'NH', 'New Hampshire'),
('US', 'NJ', 'New Jersey'),
('US', 'NM', 'New Mexico'),
('US', 'NV', 'Nevada'),
('US', 'NY', 'New York'),
('US', 'OH', 'Ohio'),
('US', 'OK', 'Oklahoma'),
('US', 'OR', 'Oregon'),
('US', 'PA', 'Pennsylvania'),
('US', 'PR', 'Puerto Rico'),
('US', 'RI', 'Rhode Island'),
('US', 'SC', 'South Carolina'),
('US', 'SD', 'South Dakota'),
('US', 'TN', 'Tennessee'),
('US', 'TX', 'Texas'),
('US', 'UM', 'United States Minor Outlying Islands'),
('US', 'UT', 'Utah'),
('US', 'VA', 'Virginia'),
('US', 'VI', 'Virgin Islands'),
('US', 'VT', 'Vermont'),
('US', 'WA', 'Washington'),
('US', 'WI', 'Wisconsin'),
('US', 'WV', 'West Virginia'),
('US', 'WY', 'Wyoming');
COMMIT;