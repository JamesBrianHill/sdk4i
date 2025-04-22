-- *************************************************************************************************
--   This source member will insert Mexican states/territories information into GEOSTAT.
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
('MX', 'AGU', 'Aguascalientes'),
('MX', 'BCN', 'Baja California'),
('MX', 'BCS', 'Baja California Sur'),
('MX', 'CAM', 'Campeche'),
('MX', 'CHH', 'Chihuahua'),
('MX', 'CHP', 'Chiapas'),
('MX', 'CMX', 'Ciudad de México'),
('MX', 'COA', 'Coahuila de Zaragoza'),
('MX', 'COL', 'Colima'),
('MX', 'DUR', 'Durango'),
('MX', 'GRO', 'Guerrero'),
('MX', 'GUA', 'Guanajuato'),
('MX', 'HID', 'Hidalgo'),
('MX', 'JAL', 'Jalisco'),
('MX', 'MEX', 'México'),
('MX', 'MIC', 'Michoacán de Ocampo'),
('MX', 'MOR', 'Morelos'),
('MX', 'NAY', 'Nayarit'),
('MX', 'NLE', 'Nuevo León'),
('MX', 'OAX', 'Oaxaca'),
('MX', 'PUE', 'Puebla'),
('MX', 'QUE', 'Querétaro'),
('MX', 'ROO', 'Quintana Roo'),
('MX', 'SIN', 'Sinaloa'),
('MX', 'SLP', 'San Luis Potosí'),
('MX', 'SON', 'Sonora'),
('MX', 'TAB', 'Tabasco'),
('MX', 'TAM', 'Tamaulipas'),
('MX', 'TLA', 'Tlaxcala'),
('MX', 'VER', 'Veracruz de Ignacio de la Llave'),
('MX', 'YUC', 'Yucatán'),
('MX', 'ZAC', 'Zacatecas');
COMMIT;