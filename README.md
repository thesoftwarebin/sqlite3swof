sqlite3swof: SQLite3 scripting-without-files
============================================

This is a Windows-only experimental modification of the SQLite shell.
It can embed sqlite databases and scripts inside the shell EXE file, which then behaves as a standalone, single-file EXE application.



What does it do at startup?
---------------------------

- load an embedded database from the EXE resources
- IF script `main.sql` is stored in database table `sqlar` THEN execute it once
- IF script `loop.sql` is stored in database table `sqlar` THEN execute it in an infinite loop



Which new commands are available in scripts or interactive sessions?
--------------------------------------------------------------------

- `.read :ar:mypath/myscript.sql`: executes once a script read from `sqlar`
- `.read :query:select ...(scripttext) [from ... where]`: takes the first column of first result of the query, interprets it as a script and executes it once
- `.loop :ar:mypath/myscript.sql`: executes forever in loop a script read from `sqlar`
- `.loop :query:select ...(scripttext) [from ... where]`: executes the query result as a script forever in loop



How to modify the embedded database?
------------------------------------

Either replace the embedded database with Resource Hacker, or more simply just type `.read :ar:sqlite3swof/clone/scripts/clone.sql`, which will clone the executable and embed the current session's database in it.



What can possibly go wrong?
---------------------------

1) the embedded script `clone.sql` is a quick hack to avoid the need of Resource Hacker, but it's fragile: the patch offsets of the executable are hardcoded. If you recompile the C source code, the executable's offsets for code and resource sections will change, so you need to analyze the executable with `objdump` and modify the offsets and values in `clone.sql` accordingly.

2) the embedded db is loaded from the Windows resources code section, so it won't compile in Linux

3) the SQLite code is statically linked, so if in the future bugs or security vulnerabilities are discovered in SQLite or in the shell
