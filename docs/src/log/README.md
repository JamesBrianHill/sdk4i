# LOG (Logging) Component

## tl;dr
- Eight different and independent logging levels for LPAR, libraries, programs, modules, procedures, and users.
- Program/module/procedure usage by minute, day, hour, week, month, or year.
- Metrics for programs/procedures/etc. including success/failure, execution time, normal or abnormal end.
- Capture complete callstack and extended system information for those hard-to-understand support issues.
- Capture information related to remote web services being called AND local web services running on IBM i.

## Ok, sounds intriguing, tell me more
The LOG component of SDK4i is where the project started. There was a clear need for a centralized log that would automatically capture information that could be helpful for support, forensics, and governance/compliance reasons. Additionally, there were certain questions that seemed to pop up in most companies using IBM i:

- Is this program still being used?
- How can we tell the last time this piece of code (subroutine, procedure, etc.) was executed?
- How often does this program/procedure/etc. get called?
- Who is executing this code?
- When is this code being executed?
- Why is this program failing for just one user and nobody else?
- Why is this process taking so long to complete?

Over the years functionality has been added to address all of these things and more.

## Log levels can be set independently for multiple things
The LOG component allows us to log messages from applications at 8 different levels - based on the 8 levels defined in RFC 5424 (the syslog protocol). Many other logging programs for other languages use the same or similar log levels (Emergency, Alert, Critical, Error, Warning, Notification, Informational, and Debug).

Besides these eight different levels of messages, we are able to set the logging level independently for:
- The whole LPAR.
- Specific libraries.
- Specific programs.
- Specific modules.
- Specific procedures.
- Specific users.

If you use the SDK4i defaults, the error level is set to ERROR for the LPAR. Because we're able to specify particular libraries, programs, etc., this means when a particular program is having a problem, we can increase the logging just for it without affecting the overall logging level of everything else. For example, if program `SNDBAL` was behaving oddly, we might insert a row into `LOGCFGT` like this:
```sql
INSERT INTO logcfgt(pgm, logmett, logmsgt_id, loguset) VALUES('SNDBAL', 'Y', 5, 'Y');
```
This would instantly start capturing NOTICE level and above messages for the `SNDBAL` program - NO RECOMPILE NECESSARY. If capturing NOTICE level messages and higher isn't enough, we could change that 5 to a 7 to capture DEBUG messages and up. Once we've figured out the problem, we just delete this row from the `LOGCFGT` table and we will instantly go back to treating the `SNDBAL` program like everything else - again, with no recompile needed.

If Bob in accounting is the only user having an issue, we can change the logging just for him - even more specifically, just for Bob and the particular program - without affecting logging for anyone or anything else. Here's an example of how we could do that:
```sql
INSERT INTO logcfgt(pgm, usr, logmett, logmsgt_id, loguset) VALUES('SNDBAL', 'BOB', 'Y', 7, 'Y');
```
After we execute this SQL statement to add a row to the `LOGCFGT` table, we will instantly be capturing DEBUG level information and higher for user profile `BOB` and no one else without needing to recompile `SNDBAL`.

This keeps us from having an impact on system performance and makes it easier to hone in on the problem affecting Bob.

## Usage of programs, modules, etc.
Since many companies using IBM i have programs that are 30 or 40 (or more) years old, it's not uncommon for them to not know for sure if a program is still being used. By adding a call to the [LOG_LogUse](./qrpglesrc/LOG_LogUse.md) procedure, we can painlessly start tracking when a program (or module, or procedure, etc.) is used.

So how hard is to start capturing usage? Here's how you would start logging the usage of a procedure:
```rpg
// This line goes with your CTL-OPT or H specs:
CTL-OPT BNDDIR('SDK4I');

// This line goes immediately after all of your other local variable declarations.
/COPY '/opt/sdk4i/src/qcpysrc/logvar2k.rpgleinc'

// This line would ideally be in an ON-EXIT section so it would be guaranteed to be executed but
// if you don't have an ON-EXIT section and you're unwilling to add one, make this the last line of
// the procedure:
LOG_LogUse(psds_ds: log_proc: log_beg_ts: log_is_successful: log_is_abend: log_user_info_ds);
```
That's it, three lines of code. And make sure you've got usage enabled in your `LOGCFGT` table (`loguset` = 'D', 'H', 'I', 'M', 'N', 'W', or 'Y'). If you are using the defaults installed by SDK4i, usage information is enabled and counts are by Day (`loguset` = 'D').

## Metrics are related to usage
Besides capturing the fact a program, module, etc. is being used, it can be helpful to know just how often it's being used. Or if it ended normally or abnormally. Or if it was successful - however you the programmer want to define that. Or maybe you'd like to know exactly how long it took to execute?

Capturing metrics like these can help us focus on exactly the things that need attention to make us more efficient.

If you are using the defaults installed by SDK4i, metrics are enabled for the whole LPAR (`logmett` = 'Y').

## Really hard to crack support issues
Every once and a while we get a very difficult support issue. We rule out all the usual suspects, then we rule out all the unlikely suspects, finally we're asking all the other developers and no one has any ideas.

Sounds like it's time to start capturing detailed, low-level information for the entire callstack.

Because there can be a noticeable performance hit, you will probably only turn these on when all else fails.

In your `LOGCFGT` table, you can enable two options - one to capture callstack information and the other to capture extended system information. This SQL statement will enable both options for program `SNDBAL`:
```sql
INSERT INTO logcfgt (pgm, logcsit, logextt) VALUES('SNDBAL', 'Y', 'Y');
```

## Capture web service information
Everything is a web service nowadays and you've probably been calling remote web services for a while. Maybe you're exploring the idea of serving web services directly from IBM i. If you want to capture information related to the remote web services you're calling, enable the capture of that data in your `LOGCFGT` table by setting `logwbrt` = 'Y' and adding `LOG_LogMsg` calls to your programs call those remote web services and passing the `i_logwbrt` parameter.

Similarly, if you want to capture information about local web services, enable that in your `LOGCFGT` table by setting `logwblt` = 'Y' and adding calls to `LOG_LogMsg` to your web service programs and passing the `i_logwblt` parameter.