# Installation

The source code for SDK4i is designed to be stored in software like Git, GitHub, GitLab, Azure DevOps, etc. and then copied to the IFS by some mechanism so it can be compiled.

## IFS Directory

It is recommended for the SDK4i software to reside in the `/opt/sdk4i` directory of the IFS. By default, the `/opt` directory is [not provided](https://www.ibm.com/docs/en/i/7.6.0?topic=directory-provided-directories) so it would need to be created first. Here are two example commands to create the necessary directories:

```clp
CRTDIR DIR('/opt') DTAAUT(*EXCLUDE) OBJAUT(*NONE) RSTDRNMUNL(*YES)
CRTDIR DIR('/opt/sdk4i') DTAAUT(*EXCLUDE) OBJAUT(*NONE) RSTDRNMUNL(*YES)
```

You can read more about the [CRTDIR](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/crtdir.html) command on IBM's website. You may also want to change the owner of these directories using the [CHGOWN](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/chgown.html) command.

Note that the two example commands provided will block `*PUBLIC` from accessing these directories at all. You should work with your system administrators to determine how best to set up a directory for the IFS source code.

If you just want to give SDK4i a test drive, you can upload the source to your local `/home/my_user_profile` directory.

## Libraries

It is recommended for the SDK4i objects to reside in their own libraries:
- `SDK4IDTA` to hold database objects such as tables and views.
- `SDK4IPGM` to hold program-related objects like binding directories, modules, programs, and service programs.
- `SDK4IWEB` to hold web service related programs and service programs.

The tables in `SDK4IDTA` need to be journaled. You can use an existing journal and receiver or you can create a new journal and receiver for SDK4i. Here are example commands to create these new libraries, journal, journal receiver, and a command to start journaling:

```clp
CRTLIB LIB(SDK4IDTA) TEXT('SDK4i - Data related objects') AUT(*EXCLUDE) CRTAUT(*EXCLUDE)
CRTLIB LIB(SDK4IPGM) TEXT('SDK4i - Program related objects') AUT(*EXCLUDE) CRTAUT(*EXCLUDE)
CRTLIB LIB(SDK4IWEB) TEXT('SDK4i - Web related objects') AUT(*EXCLUDE) CRTAUT(*EXCLUDE)
CRTLIB LIB(SDK4IJRN) TEXT('SDK4i - Journals') AUT(*EXCLUDE) CRTAUT(*EXCLUDE)

CRTJRNRCV JRNRCV(SDK4IJRN/SDK4I00001) TEXT('SDK4i - Journal Receiver')
CRTJRN JRN(SDK4IJRN/SDK4IJRN) JRNRCV(SDK4IJRN/SDK4I00001) TEXT('SDK4i - Journal')
STRJRNLIB LIB(SDK4IDTA) JRN(SDK4IJRN/SDK4IJRN)

GRTOBJAUT OBJ(QSYS/SDK4IDTA) OBJTYPE(*LIB) USER(QTMHHTP1) AUT(*CHANGE)
GRTOBJAUT OBJ(QSYS/SDK4IPGM) OBJTYPE(*LIB) USER(QTMHHTP1) AUT(*USE)
GRTOBJAUT OBJ(QSYS/SDK4IWEB) OBJTYPE(*LIB) USER(QTMHHTTP) AUT(*USE)
GRTOBJAUT OBJ(QSYS/SDK4IWEB) OBJTYPE(*LIB) USER(QTMHHTP1) AUT(*USE)
```

You can read more about the [CRTLIB](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/crtlib.html), [CRTJRNRCV](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/crtjrnrcv.html), [CRTJRN](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/crtjrn.html), [STRJRNLIB](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/strjrnlib.html), and [GRTOBJAUT](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/grtobjaut.html) commands on IBM's website. You may also want to change the ownership of these libraries with the [CHGOBJOWN](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/chgobjown.html) command.

In these examples, we grant authority to the QTMHHTP1 and QTMHHTTP users because they are the default IBM user profiles associated with HTTP Server for i (Apache). Whenever we host web services on IBM i, the QTMHHTP1 user profile is calling programs on behalf of web users. QTMHHTTP is the user profile executing the web server jobs.

Again, you will want to work with your system administrators to determine how best to implement all of this.

## Upload the Source

Download the latest stable release of SDK4i from GitHub and unpack it on your local workstation. Before you upload the source to the IFS directory you created earlier, you need to make some choices that may require you to change some settings in the source file (`src/sdk4i/qrpglesrc/bldsdk4i.pgm.sqlrpgle`) for the build program.

By default, the build program expects the SDK4i source to be installed in `/opt/sdk4i/src` and it will compile objects into `SDK4IDTA`, `SDK4IPGM`, and `SDK4IWEB`.

If you want to install the source to a different directory, or you want to have the compiled objects go to different libraries than the defaults, open the `src/sdk4i/qrpglesrc/bldsdk4i.pgm.sqlrpgle` source file and modify the `C_LIBDTA`, `C_LIBPGM`, `C_LIBWEB`, and `C_SRC_ROOT` constants accordingly.

If you change the libraries where SDK4i objects are stored, you will need update the `src/sdk4i/qcllesrc/clnsdk4i.pgm.clp` source member for the CLNSDK4I (Clean) program by modifying the `LIBDTA`, `LIBPGM`, and `LIBWEB` variables declared at the beginning of the source file.

Also by default, the build program will compile all SDK4i tables with the [`RESTRICT ON DROP`](https://www.ibm.com/docs/en/i/7.6.0?topic=object-restrict-drop) attribute. If you do NOT want the SDK4i tables to have that attribute, change the `C_ADD_RESTRICT_ON_DROP` constant to `N`.

After you have made any necessary changes to the source files for the BLDSDK4I and CLNSDK4I programs, you can now transfer the full SDK4i directory tree to the IFS directory you created earlier.

## Compile and Run the BLDSDK4I (Build) Program

Now that your source is in place, you just need to build it all. Compile the build program with the [CRTSQLRPGI](https://www.ibm.com/docs/en/i/7.6.0?topic=ssw_ibm_i_76/cl/crtsqlrpgi.html) command - note that you will need to modify this command if you want the object to go to a different library or you put the source code in a different directory:

```clp
CRTSQLRPGI OBJ(SDK4IPGM/BLDSDK4I) SRCSTMF('/opt/sdk4i/src/qrpglesrc/bldsdk4i.pgm.sqlrpgle') CLOSQLCSR(*ENDMOD) COMPILEOPT('PPMINOUTLN(240)') DATFMT(*ISO) DBGVIEW(*SOURCE) OPTION(*EVENTF) OUTPUT(*PRINT) RPGPPOPT(*LVL2) TIMFMT(*ISO)
```

If you are on a system where the QCCSID is 65535, this might be a better example for you - note that if you are not in North America or don't normally use CCSID 37, you should change the `TGTCCSID(37)` bit to use the CCSID appropriate for you:
```clp
CRTSQLRPGI OBJ(SDK4IPGM/BLDSDK4I) SRCSTMF('/opt/sdk4i/src/qrpglesrc/bldsdk4i.pgm.sqlrpgle') CLOSQLCSR(*ENDMOD) COMPILEOPT('PPMINOUTLN(240) TGTCCSID(37)') DATFMT(*ISO) DBGVIEW(*SOURCE) OPTION(*EVENTF) OUTPUT(*PRINT) RPGPPOPT(*LVL2) TIMFMT(*ISO)
```

You should now have a program (BLDSDK4I) that will build all of the components in SDK4i.

You can call that program in the usual way:

```clp
CALL SDK4IPGM/BLDSDK4I
```

After you call the BLDSDK4I program, you can query LOGMSGT to see the results:

```sql
SELECT
  ts,
  event_facility AS "Fac",
  event_level AS "Lvl",
  event_message AS "Msg",
  process_library AS "Lib",
  process_program AS "pgm",
  process_procedure AS "Proc",
  cause_sqlstate AS "SQLSTATE",
  cause_sql_statement AS "Statement",
  cause_error_code AS "Err Code",
  cause_error_line AS "Err Line",
  cause_error_routine AS "Err Routine",
  cause_error_data AS "Err Data"
FROM
  logmsgt
ORDER BY
  ts;
```

You should see a bunch of Success messages. If not, look at the information in LOGMSGT and in your joblog to determine what went wrong.