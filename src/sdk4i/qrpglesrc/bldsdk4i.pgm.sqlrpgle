**FREE
// -------------------------------------------------------------------------------------------------
//   This program will build all of the objects for all of the components of SDK4i.
//
// @copyright Copyright (c) 2015 - 2025 by James Brian Hill
// @license GNU General Public License version 3
// @link https://www.gnu.org/licenses/gpl-3.0.html
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
//   This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses/gpl-3.0.html
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// Control Statements.
// -------------------------------------------------------------------------------------------------
CTL-OPT ACTGRP(*NEW);
CTL-OPT ALWNULL(*USRCTL);
CTL-OPT CCSIDCVT(*LIST); // list all the source statements that have a CCSID conversion.
CTL-OPT COPYRIGHT('Copyright (c) 2015 - 2025 by James Brian Hill');
CTL-OPT DATFMT(*ISO);
// CTL-OPT DATEYY(*NOALLOW); // Became available with 7.5TR5 on 2024-11-22.
CTL-OPT DEBUG(*CONSTANTS: *DUMP: *INPUT: *RETVAL: *XMLSAX);
CTL-OPT DECEDIT('0.'); // JSON requires a leading zero.
CTL-OPT EXPROPTS(*USEDECEDIT); // Use the DECEDIT setting for built-in functions like %DEC.
CTL-OPT EXTBININT(*YES);
CTL-OPT MAIN(BLDSDK4I);
CTL-OPT OPTIMIZE(*FULL); // Change to *FULL for production code.
CTL-OPT OPTION(*NODEBUGIO: *NOSHOWCPY: *NOUNREF: *SRCSTMT);
CTL-OPT TEXT('SDK4i - Build everything');
CTL-OPT TIMFMT(*ISO);

// -------------------------------------------------------------------------------------------------
// Bring in the copybooks we will use.
//
// IBMAPIK - IBM API constants, data structures, variables, and procedure definitions.
// PSDSK - Definition of the Program Status Data Structure (PSDS).
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/ibmapik.rpgleinc'
/COPY '../../qcpysrc/psdsk.rpgleinc'

// -------------------------------------------------------------------------------------------------
// Define global constants, template data structures, and template variables.
// -------------------------------------------------------------------------------------------------
DCL-C C_ADD_RESTRICT_ON_DROP 'Y';
DCL-C C_CLN_LIB 'HILLB1';
DCL-C C_LIBDTA 'HILLB1';
DCL-C C_LIBPGM 'HILLB2';
DCL-C C_LIBWEB 'HILLB2';
DCL-C C_IFS_BASE '/home/hillb/sdk4i/src/';

// -------------------------------------------------------------------------------------------------
// Set SQL options before any executable code.
// -------------------------------------------------------------------------------------------------
/COPY '../../qcpysrc/sqloptk.rpgleinc'

// -------------------------------------------------------------------------------------------------
///
// Add an entry to a binding directory.
//
// Use the ADDBNDDIRE command to add an entry to a binding directory.
//
// @param REQUIRED. The library where the binding directory resides.
// @param REQUIRED. The name of the binding directory.
// @param REQUIRED. The library where the object resides.
// @param REQUIRED. The object to add to the binding directory.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC AddBindingDirectoryEntry;
  DCL-PI AddBindingDirectoryEntry;
    i_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_binding_directory LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_obj_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_obj LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  cmd = 'ADDBNDDIRE BNDDIR('+ i_lib +'/'+ i_binding_directory +') OBJ(('+ i_obj_lib +'/'+
    i_obj +'))';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  LogMsg(is_successful: 'add binding directory entry: '+ i_lib +'/'+ i_binding_directory + ': ' +
    i_obj_lib + '/' + i_obj);

  RETURN;
END-PROC AddBindingDirectoryEntry;

// -------------------------------------------------------------------------------------------------
///
// This is the main procedure where execution begins.
//
// This procedure builds all of the objects for SDK4i.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC BLDSDK4I;
  DCL-PI BLDSDK4I;
  END-PI;

  SetupLibraryList();
  
  BuildTables();
  
  BuildBindingDirectories();

  BuildComponent('NIL': 'SDK4i - NIL - NULL handling procedures': 'SDK4I');
  BuildComponent('LOG': 'SDK4i - LOG - Logging procedures': 'SDK4I');
  BuildComponent('ERR': 'SDK4i - ERR - Error handling procedures': 'SDK4I');
  BuildComponent('TXT': 'SDK4i - TXT - Text utilities': 'SDK4I');
  BuildComponent('COM': 'SDK4i - COM - Communication utilities': 'SDK4I');
  BuildComponent('MSG': 'SDK4i - MSG - Message handling procedures': 'SDK4I');
  BuildComponent('VLD': 'SDK4i - VLD - Validation procedures': 'SDK4I');
  BuildComponent('SEC': 'SDK4i - SEC - Security procedures': 'SDK4I');
  BuildComponent('WEB': 'SDK4i - WEB - Web service procedures': 'SDK4I');

  // Create a CL program to delete all SDK4i objects.
  CreateCLProgram(C_CLN_LIB: 'CLNSDK4I': C_IFS_BASE + 'sdk4i/qcllesrc/clnsdk4i.pgm.clp':
    'SDK4i - Delete all SDK4i objects');
  
END-PROC BLDSDK4I;

// -------------------------------------------------------------------------------------------------
///
// Build binding directories.
//
// This procedure will build all binding directories and add core binding directory entries.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC BuildBindingDirectories;
  DCL-PI BuildBindingDirectories;
  END-PI;

  // Create binding directory for SDK4i.
  CreateBindingDirectory(C_LIBPGM: 'SDK4I': 'SDK4i Binding Directory');

  //   The QZHBCGI service program is provided by IBM. Our web services use the QtmhRdStin and
  // QtmhWrStout procedures to read in HTTP Requests and write out HTTP Responses respectively.
  //
  //   The QAXIS10HT service program, also provided by IBM, is commonly used for base 64
  // encoding/decoding.
  AddBindingDirectoryEntry(C_LIBPGM: 'SDK4I': 'QHTTPSVR': 'QZHBCGI');
  AddBindingDirectoryEntry(C_LIBPGM: 'SDK4I': 'QSYSDIR': 'QAXIS10HT');
END-PROC BuildBindingDirectories;

// -------------------------------------------------------------------------------------------------
///
// Build a SDK4i component.
//
// The build process for each of the SDK4i components is very similar so we have a reusable
// procedure.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC BuildComponent;
  DCL-PI BuildComponent;
    i_name VARCHAR(10) CONST;
    i_text VARCHAR(50) CONST;
    i_bnddir VARCHAR(10) CONST;
  END-PI;

  DCL-S temp_module_path VARCHAR(1024);
  DCL-S temp_srvpgm_path VARCHAR(1024);

  temp_module_path = C_IFS_BASE + %LOWER(i_name) + '/qrpglesrc/' + %LOWER(i_name) + '.sqlrpgle';
  temp_srvpgm_path = C_IFS_BASE + %LOWER(i_name) + '/qsrvsrc/' + %LOWER(i_name) + '.bnd';

  IF (CreateModule(C_LIBPGM: %UPPER(i_name): temp_module_path));
    IF (CreateServiceProgram(C_LIBPGM: %UPPER(i_name): temp_srvpgm_path: i_text));
      AddBindingDirectoryEntry(C_LIBPGM: i_bnddir: C_LIBPGM: %UPPER(i_name));
    ENDIF;
    // We do not need the module any more so delete it.
    DeleteObject(C_LIBPGM: i_name: '*MODULE');
  ENDIF;
END-PROC BuildComponent;

// -------------------------------------------------------------------------------------------------
///
// Build all tables.
//
// This procedure will build all of the tables for SDK4i and populate some of them. After all tables
// are built, temporal and history tables will be associated with each other and the RESTRIC ON DROP
// clause will be added - if configured to do so and this program is running on an LPAR with IBM i
// 7.5 or higher.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC BuildTables;
  DCL-PI BuildTables;
  END-PI;

  // Create the tables we need to start logging messages.
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logfact.table': C_LIBDTA: *OFF);
  RunSQLStatement(C_IFS_BASE + 'log/qdmlsrc/logfacz.sql': *OMIT: *OFF);
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/loglvlt.table': C_LIBDTA: *OFF);
  RunSQLStatement(C_IFS_BASE + 'log/qdmlsrc/loglvlz.sql': *OMIT: *OFF);
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logmsgt.table': C_LIBDTA: *OFF); // logfact, loglvlt

  // Create tables that have no dependencies other than the tables above.
  RunSQLStatement(C_IFS_BASE + 'alt/qddlsrc/altgrpt.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'geo/qddlsrc/geoadtt.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'geo/qdmlsrc/geoadtz.sql'); // Populate address types.
  RunSQLStatement(C_IFS_BASE + 'geo/qddlsrc/geocntt.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'geo/qdmlsrc/geocntz.sql'); // Populate countries.
  RunSQLStatement(C_IFS_BASE + 'lng/qddlsrc/lngt.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'lng/qdmlsrc/lngz.sql'); // Populate languages.
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logmett.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logpurt.temporal': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logpurth.history': C_LIBDTA); // logpurt
  RunSQLStatement(C_IFS_BASE + 'log/qdmlsrc/logpurz.sql'); // Populate log purge configurations.
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/loguset.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logwblt.table': C_LIBDTA); // logmsgt
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logwbrt.table': C_LIBDTA); // logmsgt
  RunSQLStatement(C_IFS_BASE + 'psn/qddlsrc/psnhont.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'psn/qdmlsrc/psnhonz.sql'); // Populate honorifics.
  RunSQLStatement(C_IFS_BASE + 'psn/qddlsrc/psnsfxt.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'psn/qdmlsrc/psnsfxz.sql'); // Populate suffixes.
  RunSQLStatement(C_IFS_BASE + 'rgx/qddlsrc/rgxt.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'rgx/qdmlsrc/rgxz.sql'); // Populate regular expressions.
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secactt.temporal': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secactth.history': C_LIBDTA); // secactt
  RunSQLStatement(C_IFS_BASE + 'sec/qdmlsrc/secactz.sql'); // Populate security actions.
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secgrpt.temporal': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secgrpth.history': C_LIBDTA); // secgrpt
  RunSQLStatement(C_IFS_BASE + 'tme/qddlsrc/tmetznt.table': C_LIBDTA);
  RunSQLStatement(C_IFS_BASE + 'tme/qdmlsrc/tmetznz.sql'); // Populate timezones.

  // Create tables that have dependencies.
  RunSQLStatement(C_IFS_BASE + 'geo/qddlsrc/geostat.table': C_LIBDTA); // geocntt
  RunSQLStatement(C_IFS_BASE + 'geo/qddlsrc/geocitt.table': C_LIBDTA); // geostat
  RunSQLStatement(C_IFS_BASE + 'geo/qddlsrc/geocout.table': C_LIBDTA); // geostat
  RunSQLStatement(C_IFS_BASE + 'geo/qddlsrc/geoaddt.table': C_LIBDTA); // geocitt, geocout, geostat
  RunSQLStatement(C_IFS_BASE + 'msg/qddlsrc/msgt.table': C_LIBDTA); // lngt
  RunSQLStatement(C_IFS_BASE + 'msg/qdmlsrc/msgz.sql'); // Populate messages.
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secacgt.temporal': C_LIBDTA); // secactt, secgrpt
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secacgth.history': C_LIBDTA); // secacgt
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secusrt.temporal': C_LIBDTA); // lngt, psnhont, psnsfxt, tmetznt
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secusrth.history': C_LIBDTA); // secusrt
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secsest.table': C_LIBDTA); // lngt, secusrt
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secusat.temporal': C_LIBDTA); // secactt, secgrpt
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secusath.history': C_LIBDTA); // secusat
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secusgt.temporal': C_LIBDTA); // secgrpt, secusrt
  RunSQLStatement(C_IFS_BASE + 'sec/qddlsrc/secusgth.history': C_LIBDTA); // secusgt
  RunSQLStatement(C_IFS_BASE + 'alt/qddlsrc/altgrmt.table': C_LIBDTA); // altgrpt, secusrt
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logcfgt.temporal': C_LIBDTA); // altgrpt
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logcfgth.history': C_LIBDTA); // logcfgt
  RunSQLStatement(C_IFS_BASE + 'log/qdmlsrc/logcfgz.sql'); // Populate log configurations.
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logcsit.table': C_LIBDTA); // logmsgt
  RunSQLStatement(C_IFS_BASE + 'log/qddlsrc/logextt.table': C_LIBDTA); // logmsgt
  RunSQLStatement(C_IFS_BASE + 'vld/qddlsrc/vldt.temporal': C_LIBDTA); // msgt, rgxt
  RunSQLStatement(C_IFS_BASE + 'vld/qddlsrc/vldth.history': C_LIBDTA); // vldt
  RunSQLStatement(C_IFS_BASE + 'vld/qdmlsrc/vldz.sql'); // Populate validation rules.

  // After all temporal/history tables have been created, add versioning.
  RunSQLStatement(C_IFS_BASE + 'sdk4i/qddlsrc/temporal.sql');

  // After all tables have been created, add RESTRICT ON DROP if desired.
  // Note this is only available on IBM i 7.5 and higher so we use compiler directives to check.
  IF (C_ADD_RESTRICT_ON_DROP = 'Y');
    /IF DEFINED(*V7R5M0)
    RunSQLStatement(C_IFS_BASE + 'sdk4i/qddlsrc/restrict.sql');
    /ENDIF
  ENDIF;
END-PROC BuildTables;

// -------------------------------------------------------------------------------------------------
///
// Create a binding directory.
//
// Create the requested binding directory in the designated library.
//
// @param REQUIRED. The library where the binding directory should be created.
// @param REQUIRED. The name of the binding directory to be created.
// @param REQUIRED. The text description of the binding directory.
//
// @return *ON if the binding directory was created successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC CreateBindingDirectory;
  DCL-PI CreateBindingDirectory IND;
    i_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_binding_directory LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_text VARCHAR(50) OPTIONS(*TRIM) CONST;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  cmd = 'CRTBNDDIR BNDDIR('+ i_lib +'/'+ i_binding_directory +') AUT(*EXCLUDE) TEXT('''+
    i_text +''')';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-EXCP 'CPF2112'; // The binding directory already exists.
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  LogMsg(is_successful: 'create binding directory: '+ i_lib +'/'+ i_binding_directory);

  RETURN is_successful;
END-PROC CreateBindingDirectory;

// -------------------------------------------------------------------------------------------------
///
// Create a CL program.
//
// Execute the CRTBNDCL command to create a CL program.
//
// @param REQUIRED. The library where the program should be created.
// @param REQUIRED. The name of the program you want to create.
// @param REQUIRED. The full path to the source for the program.
// @param OPTIONAL. The description of the newly created program.
// @param OPTIONAL. An *ON/*OFF flag indicating if we should log the success/failure of this
//    procedure. Defaults to *ON.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC CreateCLProgram;
  DCL-PI CreateCLProgram IND;
    i_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_pgm LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_src LIKE(tpl_sdk4i_ifs_source_path) OPTIONS(*TRIM) CONST;
    i_dsc LIKE(tpl_sdk4i_object_description) OPTIONS(*NOPASS: *TRIM) CONST;
    i_log_msg IND OPTIONS(*NOPASS) CONST;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S do_log_msg LIKE(i_log_msg) INZ(*ON);
  DCL-S dsc LIKE(i_dsc) INZ('');
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  IF (%PARMS >= %PARMNUM(i_dsc) AND %ADDR(i_dsc) <> *NULL);
    dsc = i_dsc;
  ENDIF;

  IF (%PARMS >= %PARMNUM(i_log_msg) AND %ADDR(i_log_msg) <> *NULL);
    do_log_msg = i_log_msg;
  ENDIF;

  cmd = 'CRTBNDCL PGM('+ i_lib +'/'+ i_pgm + ') SRCSTMF('''+ i_src + ''') ' +
        'TEXT('''+ dsc + ''') ALWRTVSRC(*NO)';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  IF (do_log_msg);
    LogMsg(is_successful: 'creating program: '+ i_lib +'/'+ i_pgm);
  ENDIF;

  RETURN is_successful;
END-PROC CreateCLProgram;

// -------------------------------------------------------------------------------------------------
///
// Create a module.
//
// Use the CRTSQLRPGI command to create a module.
//
// @param REQUIRED. The library where the module should be created.
// @param REQUIRED. The name of the module you want to create.
// @param REQUIRED. The full path to the source for the module.
//
// @return *ON if the module was successfully created, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC CreateModule;
  DCL-PI CreateModule IND;
    i_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_module LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_src LIKE(tpl_sdk4i_ifs_source_path) OPTIONS(*TRIM) CONST;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  cmd = 'CRTSQLRPGI CLOSQLCSR(*ENDACTGRP) COMPILEOPT(''PPMINOUTLN(240) TGTCCSID(*JOB)'') ' +
        'DATFMT(*ISO) DATSEP(/) DBGVIEW(*SOURCE) OBJ('+ i_lib +'/'+ i_module + ') ' +
        'OBJTYPE(*MODULE) OPTION(*EVENTF) OUTPUT(*PRINT) RPGPPOPT(*LVL1) ' +
        'SRCSTMF('''+ i_src +''') TGTRLS(*CURRENT) TIMFMT(*ISO) TIMSEP('':'')';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  LogMsg(is_successful: 'create module: '+ i_lib +'/'+ i_module);

  RETURN is_successful;
END-PROC CreateModule;

// -------------------------------------------------------------------------------------------------
///
// Create a service program.
//
// Use the CRTSRVPGM command to create a service program.
//
// @param REQUIRED. The library where the service program should be created.
// @param REQUIRED. The name of the service program you want to create.
// @param REQUIRED. The full path to the source for the service program.
// @param REQUIRED. The text description of the service program.
// @param OPTIONAL. A Y/N flag indicating if unresolved symbols are allowed. Defaults to N.
//
// @return *ON if the service program was successfully create, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC CreateServiceProgram;
  DCL-PI CreateServiceProgram IND;
    i_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_srvpgm LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_src LIKE(tpl_sdk4i_ifs_source_path) OPTIONS(*TRIM) CONST;
    i_text VARCHAR(50) OPTIONS(*TRIM) CONST;
    i_allow_unresolved CHAR(1) OPTIONS(*NOPASS) CONST;
  END-PI;

  DCL-S allow_unresolved LIKE(i_allow_unresolved) INZ('N');
  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  IF (%PARMS >= %PARMNUM(i_allow_unresolved) AND %ADDR(i_allow_unresolved) <> *NULL);
    allow_unresolved = i_allow_unresolved;
  ENDIF;

  /IF DEFINED(*V7R5M0)
  IF (allow_unresolved = 'N');
    cmd = 'CRTSRVPGM SRVPGM('+ i_lib +'/'+ i_srvpgm +') SRCSTMF('''+ i_src +''') ' +
          'OPTION(*EVENTF) DETAIL(*FULL) TEXT('''+ i_text +''')';
  ELSE;
    cmd = 'CRTSRVPGM SRVPGM('+ i_lib +'/'+ i_srvpgm +') SRCSTMF('''+ i_src +''') ' +
          'OPTION(*EVENTF *UNRSLVREF) DETAIL(*FULL) TEXT('''+ i_text +''')';
  ENDIF;

  /ELSE

  IF (allow_unresolved = 'N');
    cmd = 'CRTSRVPGM SRVPGM('+ i_lib +'/'+ i_srvpgm +') SRCSTMF('''+ i_src +''') ' +
          'DETAIL(*FULL) TEXT('''+ i_text +''')';
  ELSE;
    cmd = 'CRTSRVPGM SRVPGM('+ i_lib +'/'+ i_srvpgm +') SRCSTMF('''+ i_src +''') ' +
          'OPTION(*UNRSLVREF) DETAIL(*FULL) TEXT('''+ i_text +''')';
  ENDIF;
  /ENDIF

  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  LogMsg(is_successful: 'create service program: '+ i_lib +'/'+ i_srvpgm);

  RETURN is_successful;
END-PROC CreateServiceProgram;

// -------------------------------------------------------------------------------------------------
///
// Create a SQLRPGLE program.
//
// Use the CRTSQLRPGI command to create a program object.
//
// @param REQUIRED. The library where the program should be created.
// @param REQUIRED. The name of the program you want to create.
// @param REQUIRED. The full path to the source for the program.
//
// @return *ON if the program was created successfully, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC CreateSQLRPGLEProgram;
  DCL-PI CreateSQLRPGLEProgram IND;
    i_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_pgm LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_src LIKE(tpl_sdk4i_ifs_source_path) OPTIONS(*TRIM) CONST;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  cmd = 'CRTSQLRPGI CLOSQLCSR(*ENDACTGRP) COMPILEOPT(''PPMINOUTLN(240) TGTCCSID(*JOB)'') ' +
        'DATFMT(*ISO) DATSEP(/) DBGVIEW(*SOURCE) OBJ('+ i_lib +'/'+ i_pgm + ') ' +
        'OBJTYPE(*PGM) OPTION(*EVENTF) OUTPUT(*PRINT) RPGPPOPT(*LVL1) ' +
        'SRCSTMF('''+ i_src +''') TGTRLS(*CURRENT) TIMFMT(*ISO) TIMSEP('':'')';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  LogMsg(is_successful: 'create program: '+ i_lib +'/'+ i_pgm);

  RETURN is_successful;
END-PROC CreateSQLRPGLEProgram;

// -------------------------------------------------------------------------------------------------
///
// Delete an object.
//
// Use the DLTOBJ command to delete an object.
//
// @param REQUIRED. The library where the object resides.
// @param REQUIRED. The name of the object to be deleted.
// @param REQUIRED. The type of the object to be deleted.
//
// @return *ON if the object was successfully deleted, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC DeleteObject;
  DCL-PI DeleteObject IND;
    i_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_object LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_type LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  cmd = 'DLTOBJ OBJ('+ i_lib +'/'+ i_object +') OBJTYPE('+ i_type +')';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  LogMsg(is_successful: 'delete object: '+ i_lib +'/'+ i_object + ' of type '+ i_type);

  RETURN is_successful;
END-PROC DeleteObject;

// -------------------------------------------------------------------------------------------------
///
// Log a message.
//
// As various parts of this program execute, we want to log our actions and results.
//
// @param REQUIRED. A flag indicating success when *ON and failure when *OFF.
// @param REQUIRED. A message to be logged.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC LogMsg;
  DCL-PI LogMsg;
    i_sts IND CONST;
    i_msg LIKE(tpl_sdk4i_ifs_source_path) OPTIONS(*TRIM) CONST;
  END-PI;

  DCL-S errcode VARCHAR(7);
  DCL-S fac_id PACKED(2:0) INZ(1); // Default to User-Level Messages.
  DCL-S ll_id PACKED(1:0) INZ(6); // Default to INFORMATIONAL.
  DCL-S msg VARCHAR(1024) CCSID(*UTF8);
  DCL-S prc VARCHAR(128);
  DCL-S s_stmt VARCHAR(1024) CCSID(*UTF8);

  prc = %PROC();
  errcode = psds_ds.exc_type + psds_ds.exc_num;

  IF (i_sts);
    msg = 'Success ' + i_msg;
  ELSE;
    msg = 'FAILURE ' + i_msg;
  ENDIF;

  s_stmt = 'INSERT INTO logmsgt(usrprf_cur, logfact_id, loglvlt_id, msg, sys, lib, pgm, prc, ' +
    'job_number, job_user, job_name, errcode, errline, errrout, errdata) ' +
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) WITH NC';
  
  EXEC SQL PREPARE s_logmsg FROM :s_stmt;
  IF (SQLSTATE <> C_SDK4I_SQLSTATE_OK);
    RETURN;
  ENDIF;

  EXEC SQL EXECUTE s_logmsg USING :psds_ds.cur_usr, :fac_id, :ll_id, :msg, :psds_ds.sys,
    :psds_ds.lib, :psds_ds.pgm_prc, :prc, :psds_ds.job_number, :psds_ds.username, :psds_ds.job_name,
    :errcode, :psds_ds.line, :psds_ds.routine, :psds_ds.exc_data;
  IF (SQLSTATE <> C_SDK4I_SQLSTATE_OK);
    RETURN;
  ENDIF;

END-PROC LogMsg;

// -------------------------------------------------------------------------------------------------
///
// Remove an entry from a binding directory.
//
// Because of circular dependencies, we sometimes need to remove entries from binding directories.
//
// @param REQUIRED. The library where the binding directory resides.
// @param REQUIRED. The name of the binding directory.
// @param REQUIRED. The library where the object resides.
// @param REQUIRED. The object to remove from the binding directory.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC RemoveBindingDirectoryEntry;
  DCL-PI RemoveBindingDirectoryEntry;
    i_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_binding_directory LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_obj_lib LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
    i_obj LIKE(tpl_sdk4i_system_object_name) OPTIONS(*TRIM) CONST;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  cmd = 'RMVBNDDIRE BNDDIR('+ i_lib +'/'+ i_binding_directory +') OBJ(('+ i_obj_lib +'/'+
    i_obj +'))';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  LogMsg(is_successful: 'remove binding directory entry: '+ i_lib +'/'+ i_binding_directory +': '+
    i_obj_lib + '/' + i_obj);

  RETURN;
END-PROC RemoveBindingDirectoryEntry;

// -------------------------------------------------------------------------------------------------
///
// Run an SQL statement.
//
// Execute a RUNSQLSTM command against the given SQL source member.
//
// @param REQUIRED. The full path to the source for the SQL statement.
// @param OPTIONAL. The target library when creating a table.
// @param OPTIONAL. An *ON/*OFF flag indicating if we should log the success/failure of this
//    procedure. Defaults to *ON.
//
// @return *ON if successful, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC RunSQLStatement;
  DCL-PI RunSQLStatement IND;
    i_src LIKE(tpl_sdk4i_ifs_source_path) OPTIONS(*TRIM) CONST;
    i_lib CHAR(10) OPTIONS(*NOPASS: *OMIT) CONST;
    i_log_msg IND OPTIONS(*NOPASS) CONST;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S do_log_msg IND INZ(*ON);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  IF (%PARMS >= %PARMNUM(i_log_msg) AND %ADDR(i_log_msg) <> *NULL);
    do_log_msg = i_log_msg;
  ENDIF;

  IF (%ADDR(i_lib) <> *NULL AND i_lib <> *BLANKS);
    cmd = 'RUNSQLSTM DATFMT(*ISO) DATSEP(''-'') DECMPT(*PERIOD) DFTRDBCOL('+ i_lib + ') ' +
      'MARGINS(240) SRCSTMF('''+ i_src + ''') TIMFMT(*ISO) TIMSEP('':'') COMMIT(*NONE)';
  ELSE;
    cmd = 'RUNSQLSTM DATFMT(*ISO) DATSEP(''-'') DECMPT(*PERIOD) ' +
      'MARGINS(240) SRCSTMF('''+ i_src +''') TIMFMT(*ISO) TIMSEP('':'') COMMIT(*NONE)';
  ENDIF;
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  IF (do_log_msg);
    LogMsg(is_successful: 'SQL statement: ' + i_src);
  ENDIF;

  RETURN is_successful;
END-PROC RunSQLStatement;

// -------------------------------------------------------------------------------------------------
///
// Set up the library list.
//
// We want to ensure our SDK4i libraries are in the library list.
//
// We handle the following specific exceptions:
// CPF2103: Library &1 already exists in library list.
//
// @return *ON if the library list was updated, *OFF otherwise.
///
// -------------------------------------------------------------------------------------------------
DCL-PROC SetupLibraryList;
  DCL-PI SetupLibraryList IND;
  END-PI;

  DCL-S cmd LIKE(tpl_sdk4i_ibm_qcmdexc_cmd);
  DCL-S is_successful IND INZ(*ON); // Assume we will be successful.

  cmd = 'ADDLIBLE '+ C_LIBPGM + ' *FIRST';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-EXCP 'CPF2103'; // The library already exists in the library list.
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  cmd = 'ADDLIBLE '+ C_LIBWEB + ' *FIRST';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-EXCP 'CPF2103'; // The library already exists in the library list.
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  cmd = 'ADDLIBLE '+ C_LIBDTA + ' *FIRST';
  MONITOR;
    QCMDEXC(cmd: %LEN(cmd));
  ON-EXCP 'CPF2103'; // The library already exists in the library list.
  ON-ERROR;
    is_successful = *OFF;
  ENDMON;

  psds_ds.exc_type = *BLANKS;
  psds_ds.exc_num = *BLANKS;
  psds_ds.line = *BLANKS;
  psds_ds.routine = *BLANKS;
  psds_ds.exc_data = *BLANKS;

  RETURN is_successful;
END-PROC SetupLibraryList;