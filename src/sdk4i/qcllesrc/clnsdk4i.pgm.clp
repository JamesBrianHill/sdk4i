/* -------------------------------------------------------------------------- */
/* This program will delete all objects in the SDK4i-related libraries        */
/* defined below.                                                             */
/*                                                                            */
/* @author James Brian Hill                                                   */
/* @copyright Copyright (c) 2015 - 2025 by James Brian Hill                   */
/* @license GNU General Public License version 3                              */
/* @link https://www.gnu.org/licenses/gpl-3.0.html                            */
/* -------------------------------------------------------------------------- */

/*----------------------------------------------------------------------------*/
/*   This program is free software: you can redistribute it and/or modify it  */
/* under the terms of the GNU General Public License as published by the Free */
/* Software Foundation, either version 3 of the License, or (at your option)  */
/* any later version.                                                         */
/*                                                                            */
/*   This program is distributed in the hope that it will be useful, but      */
/* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY */
/* or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License    */
/* for more details.                                                          */
/*                                                                            */
/*   You should have received a copy of the GNU General Public License along  */
/* with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.html   */
/*----------------------------------------------------------------------------*/
PGM

DCL VAR(&LIBCLN) TYPE(*CHAR) LEN(10) VALUE('SDK4IPGM')
DCL VAR(&LIBDTA) TYPE(*CHAR) LEN(10) VALUE('SDK4IDTA')
DCL VAR(&LIBPGM) TYPE(*CHAR) LEN(10) VALUE('SDK4IPGM')
DCL VAR(&LIBWEB) TYPE(*CHAR) LEN(10) VALUE('SDK4IWEB')

MONMSG MSGID(CPF0000)

/* Delete all of my spool files. */
DLTSPLF FILE(*SELECT)

/*----------------------------------------------------------------------------*/
/* Delete all service programs, programs, modules, and binding directories.   */
/*----------------------------------------------------------------------------*/
DLTOBJ &LIBDTA/EVFEVENT *FILE
DLTOBJ &LIBPGM/EVFEVENT *FILE
DLTOBJ &LIBWEB/EVFEVENT *FILE

/* Web service programs */
/* DLTOBJ &LIBWEB/*ALL *PGM */

/* Service programs and programs. Modules were cleaned up by the build pgm.   */
DLTOBJ &LIBPGM/COM *SRVPGM
DLTOBJ &LIBPGM/ERR *SRVPGM
DLTOBJ &LIBPGM/LOG *SRVPGM
DLTOBJ &LIBPGM/MSG *SRVPGM
DLTOBJ &LIBPGM/NIL *SRVPGM
DLTOBJ &LIBPGM/SEC *SRVPGM
DLTOBJ &LIBPGM/TXT *SRVPGM
DLTOBJ &LIBPGM/VLD *SRVPGM
DLTOBJ &LIBPGM/WEB *SRVPGM

DLTOBJ &LIBCLN/CLNSDK4I *PGM

DLTOBJ &LIBPGM/LOGPURP *PGM
DLTOBJ &LIBPGM/TSTLOG *PGM
DLTOBJ &LIBPGM/TSTLOG2 *PGM

/* Binding Directories */
DLTOBJ &LIBPGM/SDK4I *BNDDIR

/*----------------------------------------------------------------------------*/
/* Delete all tables.                                                         */
/*----------------------------------------------------------------------------*/

/* First, drop the RESTRICT ON DROP protection on all tables. */
/* This can be done in any order so I list tables alphabetically. */
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/ALTGRMT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/ALTGRPT DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/GEOADDT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/GEOADTT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/GEOCITT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/GEOCNTT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/GEOCOUT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/GEOSTAT DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LNGT DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGCFGT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGCFGTH DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGCSIT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGEXTT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGFACT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGLVLT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGMETT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGMSGT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGPURT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGPURTH DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGUSET DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGWBLT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/LOGWBRT DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/MSGT DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/PSNHONT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/PSNSFXT DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/RGXT DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECACGT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECACGTH DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECACTT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECACTTH DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECGRPT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECGRPTH DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECSEST DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECUSAT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECUSATH DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECUSGT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECUSGTH DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECUSRT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/SECUSRTH DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/TMETZNT DROP RESTRICT ON DROP')

RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/VLDT DROP RESTRICT ON DROP')
RUNSQL SQL('ALTER TABLE ' *CAT &LIBDTA *CAT '/VLDTH DROP RESTRICT ON DROP')

RUNSQL SQL('COMMIT')

/* Now drop tables in the reverse order they were created. */
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/VLDT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGEXTT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGCSIT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGCFGT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/ALTGRMT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/SECUSGT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/SECUSAT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/SECSEST')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/SECUSRT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/SECACGT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/MSGT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/GEOADDT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/GEOCOUT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/GEOCITT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/GEOSTAT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/TMETZNT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/SECGRPT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/SECACTT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/RGXT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/PSNSFXT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/PSNHONT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGWBRT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGWBLT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGUSET')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGPURT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGMETT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LNGT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/GEOCNTT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/GEOADTT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/ALTGRPT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGMSGT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGLVLT')
RUNSQL SQL('DROP TABLE ' *CAT &LIBDTA *CAT '/LOGFACT')
RUNSQL SQL('COMMIT')

/*----------------------------------------------------------------------------*/
ENDPGM