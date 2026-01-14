-- *************************************************************************************************
--   This source member will insert security actions into SECACTT.
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
-- LOG - Logging component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('LOGCFGT_CREATE', 'Create log configurations', 366),
('LOGCFGT_DELETE', 'Delete log configurations', 366),
('LOGCFGT_RETRIEVE', 'Retrieve log configurations', 366),
('LOGCFGT_UPDATE', 'Update log configurations', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('LOGPURT_CREATE', 'Create log purge configurations', 366),
('LOGPURT_DELETE', 'Delete log purge configurations', 366),
('LOGPURT_RETRIEVE', 'Retrieve log purge configurations', 366),
('LOGPURT_UPDATE', 'Update log purge configurations', 366);

-- *************************************************************************************************
-- SEC - Security component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('SECACGT_CREATE', 'Add security actions to security groups', 366),
('SECACGT_DELETE', 'Remove security actions from security groups', 366),
('SECACGT_RETRIEVE', 'Retrieve security action/group associations', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECACTT_CREATE', 'Create security actions', 366),
('SECACTT_DELETE', 'Delete security actions', 366),
('SECACTT_RETRIEVE', 'Retrieve security actions', 366),
('SECACTT_UPDATE', 'Update security actions', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECGRPT_CREATE', 'Create security groups', 366),
('SECGRPT_DELETE', 'Delete security groups', 366),
('SECGRPT_RETRIEVE', 'Retrieve security groups', 366),
('SECGRPT_UPDATE', 'Update security groups', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECUSAT_CREATE', 'Add security actions to users', 366),
('SECUSAT_DELETE', 'Remove security actions from users', 366),
('SECUSAT_RETRIEVE', 'Retrieve security user/action associations', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECUSGT_CREATE', 'Add users to security groups', 366),
('SECUSGT_DELETE', 'Remove users from security groups', 366),
('SECUSGT_RETRIEVE', 'Retrieve security user/group associations', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('SECUSRT_CREATE', 'Create users', 366),
('SECUSRT_DELETE', 'Delete users', 366),
('SECUSRT_RETRIEVE', 'Retrieve users', 366),
('SECUSRT_UPDATE', 'Update users', 366);

-- *************************************************************************************************
-- VLD - Validation component
-- *************************************************************************************************
INSERT INTO secactt (id, dsc, duration) VALUES
('VLDMSGT_CREATE', 'Create validation messages', 366),
('VLDMSGT_DELETE', 'Delete validation messages', 366),
('VLDMSGT_RETRIEVE', 'Retrieve validation messages', 366),
('VLDMSGT_UPDATE', 'Update validation messages', 366);

INSERT INTO secactt (id, dsc, duration) VALUES
('VLDRULT_CREATE', 'Create validation rules', 366),
('VLDRULT_DELETE', 'Delete validation rules', 366),
('VLDRULT_RETRIEVE', 'Retrieve validation rules', 366),
('VLDRULT_UPDATE', 'Update validation rules', 366);