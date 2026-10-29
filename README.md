sqlite3swof: SQLite3 scripting-without-files
============================================

This is a Windows-only experimental modification of the SQLite shell.



Who may need or like this program?
----------------------------------

Those who prepare SQLite shell scripts for non-technical people.



What can it do, which shell doesn't do?
--------------------------------------

1) at startup:
- load an embedded database from the EXE resources
- execute script `main.sql` stored in database table `sqlar`

2) new commands available during the session:
- `.read :ar:mypath/myscript.sql`: executes a script read from `sqlar`, not from a file 
- `.read :query:select ...(scripttext) [from ... where]`: executes the SQL query, takes the first column of first result, interprets it as text and executes it like it't the text of a script



How to modify the embedded database?
------------------------------------

Either replace the embedded database with Resource Hacker, or more simply just type `.read :ar:sqlite3swof/clone/scripts/clone.sql`, which will clone the executable and embed the current session's database in it.



What can possibly go wrong?
---------------------------

1) the embedded script `clone.sql` is a quick hack to avoid the need of Resource Hacker, but it's fragile: the patch offsets of the executable are hardcoded. If you recompile the C source code, the executable's offsets for code and resource sections will change, so you need to analyze the executable with `objdump` and modify the offsets and values in `clone.sql` accordingly.

2) the embedded db is loaded from the Windows resources code section, so it won't compile in Linux

3) the SQLite code is statically linked, so if in the future bugs or security vulnerabilities are discovered in SQLite or in the shell
