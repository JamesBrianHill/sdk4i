# SDK4i

SDK4i is a Software Development Kit for the IBM i. You will need to be using IBM i version 7.4 or higher to compile and use SDK4i.

- **Security**. Create a security system that does not require individual user profiles and is as fine-grained as you want it to be.
- **Logging**. You can log messages of various levels (Debug, Error, Critical, etc.) from your programs. This logging can be configured by LPAR, library, program, or user - and it's all controlled by settings in a table so there's no need to recompile anything if you want to turn logging on/off. You can log messages, usage, metrics, information about local web services, and information about remote web services.
- **Validation**. Define the rules for what makes a column (or field if you prefer) valid - in one place. Now all your programs can validate data consistently and when you need to change validation rules, you only have to change them in one place with no need to recompile any programs. You can validate numbers, dates, times, and timestamps by min/max value. You can validate character data using regular expressions. You can validate foreign key relationships at the application level.
- **Metrics**. Ever wonder which of your programs (or procedures) are used the most? Or what time(s) of day they are most heavily used? Or if that one program/procedure has even been called in the last few years?
- **Audit artifacts**. Use temporal/history tables to capture a history of data changes that cannot be altered.

## Installation
To install SDK4i you should create some libraries on your IBM i:
- SDK4IDTA - this will hold data gathered by SDK4i as well as configuration settings.
- SDK4IPGM - this will hold programs that are not called directly by web services.
- SDK4IWEB - this will hold programs that are called directly by web services (though your green screen programs can call them too).
- SDK4IJRN - this library is optional and only needed if you want to put journals from SDK4i tables in their own library.

If you do not want to create any of those libraries, you can install SDK4i software into an existing library - **this is not recommended**.

Besides the libraries, you will need to create a directory in the IFS to hold the SDK4i source code. It is recommended you create `/opt/sdk4i/yyyymmdd` where yyyymmdd is the current date. This way you will be able to easily test and upgrade to future versions later.

Next:
- Download the SDK4i repository from GitHub.
- Unzip the repository on your local workstation.
- Modify the SDK4I/src/sdk4i/qrpglesrc/bldsdk4i.pgm.sqlrpgle source file:
  - Search for the string `C_ADD_RESTRICT_ON_DROP` and change this to 'N' if you do not want all SDK4i tables to have the [`RESTRICT ON DROP`](https://www.ibm.com/docs/en/i/7.5?topic=object-restrict-drop) attribute added to them during installation.
  - Update the `C_CLN_LIB`, `C_LIBDTA`, `C_LIBPGM`, and `C_LIBWEB` values to match the libraries you created earlier. It is recommended you set `C_CLN_LIB` to the same library as `C_LIBPGM` - a program called `CLNSDK4I` will be created during the install process. This program can be used as an uninstall script.
  - Update the `C_IFS_BASE` value to match the IFS directory you created earlier.
- Modify the SDK4I/src/sdk4i/qcllesrc/clnsdk4i.pgm.clp source file:
  - Search for `LIBCLN` and change the value to the library you assigned to `C_LIB_CLN` earlier.
  - Also change the libraries for `LIBDTA`, `LIBPGM`, and `LIBWEB` to match the libraries you created earlier.
- After modifying those two source files, upload the entire source tree to the `/opt/sdk4i/yyyymmdd` directory you created earlier.
- Once you have the SDK4i source code uploaded, you need to compile the `BLDSDK4I` program by executing this command on your IBM i: [`CRTSQLRPGI CLOSQLCSR(*ENDACTGRP) COMPILEOPT('PPMINOUTLN(240) TGTCCSID(37)') DATFMT(*ISO) DATSEP(/) DBGVIEW(*SOURCE) OBJ(SDK4IPGM/BLDSDK4I) OPTION(*EVENTF) OUTPUT(*PRINT) RPGPPOPT(*LVL1) SRCSTMF('/opt/sdk4i/yyyymmdd/sdk4i/src/sdk4i/qrpglesrc/bldsdk4i.pgm.sqlrpgle') TGTRLS(*CURRENT) TIMFMT(*ISO) TIMSEP(':')`](https://www.ibm.com/docs/en/i/7.5?topic=ssw_ibm_i_75/cl/crtsqlrpgi.html) - note that you will need to change the `yyyymmdd` part of the SRCSTMF path to match what you created earlier. And if you are not installing to the `SDK4IPGM` library, you will need to change that as well. You do not need the `TGTCCSID(37)` attribute in the `COMPILEOPT` parameter if your LPAR or job has a CCSID other than 65535. The SDK4i coding standard permits lines of source code to be up to 240 characters so you do need the [`PPMINOUTLN(240)`](https://www.ibm.com/support/pages/rpg-cafe-january-2023-control-record-length-qtempqsqlpre-avoid-rnf0733) attribute.
- After compiling the `BLDSDK4I` program, you just need to execute it and it will create all of the SDK4i tables and programs: `CALL SDK4IPGM/BLDSDK4I`.