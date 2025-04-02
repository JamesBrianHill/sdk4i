# Notes about RPG programming in SDK4i.

## Copybook Source Members
- All RPG source code MUST be [fully free-form](https://www.ibm.com/docs/en/i/7.5?topic=statements-fully-free-form).
- A comment block describing what the source code in that copybook accomplishes MUST follow the `**FREE` declaration.
- [Compiler directives](https://www.ibm.com/docs/en/i/7.5?topic=concepts-compiler-directives) MSUT be used to ensure a copybook is only included once.
- [/COPY](https://www.ibm.com/docs/en/i/7.5?topic=directives-copy-include#cdcopy) commands SHOULD be used to bring in other copybooks.
- Any global constants, [template](https://www.ibm.com/docs/en/i/7.5?topic=dsk-template) data structures, or template variables MUST be defined next. Use of the [DCL-C](https://www.ibm.com/docs/en/i/7.5?topic=statement-free-form-named-constant-definition) definition is preferred but using the [CONST](https://www.ibm.com/docs/en/i/7.5?topic=prototypes-standalone-fields#standl__const) keyword with a [DCL-S](https://www.ibm.com/docs/en/i/7.5?topic=statement-free-form-standalone-field-definition) definition is acceptable when it is necessary to specify a data type, a specific CCSID, etc.
- ONLY constants, template data structures, and template variables may be defined at the global level.
- All template data structures must use the [QUALIFIED](https://www.ibm.com/docs/en/i/7.5?topic=dsk-qualified) keyword.

## Source Statement Sequence in Programs
- All programs MUST be `**FREE` so the first line of every copybook, program, and service program must be `**FREE`.
- A comment block describing what the source code in that member accomplishes.

## Control Specifications
The following [Control Specifications](https://www.ibm.com/docs/en/i/7.5?topic=specifications-control) are used by SDK4i:
- [CTL-OPT ALLOC(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-allocstgmdl-teraspace-snglvl)
- [CTL-OPT ALWNUL(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-alwnullno-inputonly-usrctl#halwnul)
- [CTL-OPT BNDDIR(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-bnddirbinding-directory-name-binding-directory-name)
- [CTL-OPT CCSID(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-ccsid-control-keyword#hccsid)
- [CTL-OPT CCSIDCVT(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-ccsidcvtexcp-list)
- [CTL-OPT COPYRIGHT(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-copyrightcopyright-string#hcopyr)
- [CTL-OPT DATFMT](https://www.ibm.com/docs/en/i/7.5?topic=keywords-datfmtfmtseparator)
- [CTL-OPT DATEYY(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-dateyyallow-warn-noallow) - available with 7.5 TR 5 (2024-11-22)
- [CTL-OPT DEBUG(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-debugdump-input-retval-xmlsax-no-yes)
- [CTL-OPT EXTBININT(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-extbinintno-yes#hextbin)
- [CTL-OPT NOMAIN](https://www.ibm.com/docs/en/i/7.5?topic=keywords-nomain)
- [CTL-OPT OPTIMIZE(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-optimizenone-basic-full#hoptim)
- [CTL-OPT OPTION(x)](https://www.ibm.com/docs/en/i/7.5?topic=csk-optionnoxref-nogen-noseclvl-noshowcpy-noexpdds-noext-noshowskp-nosrcstmt-nodebugio-nounref)
- [CTL-OPT TEXT(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-textsrcmbrtxt-blank-description)
- [CTL-OPT TIMFMT(x)](https://www.ibm.com/docs/en/i/7.5?topic=keywords-timfmtfmtseparator)

## Definition Specifications
- [DCL-PR](https://www.ibm.com/docs/en/i/7.5?topic=statement-free-form-prototype-definition)
- [Varying dimensional arrays](https://www.ibm.com/docs/en/i/7.5?topic=constant-varying-dimension-arrays)

## Global Definitions
- Only constants, template data structures and template variables are allowed to be defined at a global level.

## Input/Output
- All I/O is done with SQL, native I/O MUST NOT be used.
- [Capture newly created ID on INSERT](https://www.ibm.com/docs/en/i/7.5?topic=statement-selecting-inserted-values)