.print "[ INFO ] start of clone script."

.print "[ INFO ] create directory sqlite3swof/clone/db if not existent..."
select writefile('sqlite3swof/clone/db/', '', 16384) as createdirectory;

.print "[ INFO ] vacuuming db before saving..."
vacuum;

.print "[ INFO ] saving db..."
.backup main sqlite3swof/clone/db/clone.sqlite3

.param init

.param set @_swof_tmplexe "(select sqlar_uncompress(data,sz) from sqlar where name='sqlite3swof/clone/template/sqlite3swof.0.exe')"
.param set @_swof_db      "(select readfile('sqlite3swof/clone/db/clone.sqlite3'))"
.param set @_swof_dbsize  "(select length(@_swof_db))"

.mode tabs --quote off
select printf('[ INFO ] new db size is %d = 0x%x bytes', @_swof_dbsize, @_swof_dbsize);

-- file offset of the embedded sqlite db inside @_swof_tmplexe
.param set @_swof_dbaddr 0x1e5400+0xa0

-- file offset of the embedded manifest inside @_swof_tmplexe
.param set @_swof_mnaddr 0x1e5400+0xa0
.param set @_swof_mnsize "0x1e5a00-@_swof_mnaddr"

select printf('[ INFO ] creating temporary table _swof_newexe...');

create temporary table _swof_newexe as select
       hex(substr(@_swof_tmplexe, 1, @_swof_dbaddr))
       || hex(@_swof_db)
       || hex(substr(@_swof_tmplexe, @_swof_mnaddr+1, @_swof_mnsize))
       || hex(substr(@_swof_tmplexe, @_swof_mnaddr+@_swof_mnsize+1)) as h
;

-- do not upate SizeOfCode

.print "[ INFO ] SizeOfInitializedData += newdbsize"
.param set @_swof_clone_patch_addr 0xa0
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_patch_val @_swof_clone_patch_val_original+@_swof_dbsize
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql

.print "[ INFO ] size of .rsrc += newdbsize"
.param set @_swof_clone_patch_addr 0x11c
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_patch_val @_swof_clone_patch_val_original+@_swof_dbsize
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql

.param set @_swof_clone_patch_addr 0x2d0
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_patch_val @_swof_clone_patch_val_original+@_swof_dbsize
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql

.param set @_swof_clone_patch_addr 0x2d8
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_patch_val @_swof_clone_patch_val_original+@_swof_dbsize
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql

.param set @_swof_clone_newsize_rsrc @_swof_clone_patch_val
select printf('[ INFO ] storing @_swof_clone_newsize_rsrc = 0x%x', @_swof_clone_newsize_rsrc);

.print "[ INFO ] reading file offset of .rsrc"
.param set @_swof_clone_patch_addr 0x2dc
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_file_offset_of_rsrc @_swof_clone_patch_val_original
select printf('[ INFO ] stored @_swof_clone_file_offset_of_rsrc = 0x%x', @_swof_clone_file_offset_of_rsrc);

.print "[ INFO ] reading memaddr of .rsrc"
.param set @_swof_clone_patch_addr 0x2d4
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_memaddr_of_rsrc @_swof_clone_patch_val_original
select printf('[ INFO ] stored @_swof_clone_memaddr_of_rsrc = 0x%x', @_swof_clone_memaddr_of_rsrc);

.print "[ INFO ] calculating round-up to 0x1000 based on mem address and size of .rsrc"
.param set @_swof_clone_reloc_roundup "(select case when t.x % 0x1000 != 0 then (0x1000 - t.x % 0x1000) else 0 end from (select @_swof_clone_memaddr_of_rsrc+@_swof_clone_newsize_rsrc as x) as t)"
select printf('[ INFO ] stored @_swof_clone_reloc_roundup = 0x%x', @_swof_clone_reloc_roundup);

.print "[ INFO ] memaddr of .reloc = round_up_0x1000(memaddr of .rsrc + new size of .rsrc)"
.param set @_swof_clone_patch_addr 0x130
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_memaddr_reloc_old @_swof_clone_patch_val_original
.param set @_swof_clone_patch_val "@_swof_clone_memaddr_of_rsrc+@_swof_clone_newsize_rsrc+@_swof_clone_reloc_roundup"
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql
.param set @_swof_clone_memaddr_reloc_new @_swof_clone_patch_val

.param set @_swof_clone_patch_addr 0x2fc
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql

.print "[ INFO ] update SizeOfImage += (new memaddr of .reloc - old memaddr of .reloc)"
.param set @_swof_clone_patch_addr 0xd0
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_patch_val @_swof_clone_patch_val_original+(@_swof_clone_memaddr_reloc_new-@_swof_clone_memaddr_reloc_old)
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql


.print "[ INFO ] file addr of .reloc += newdbsize"
.param set @_swof_clone_patch_addr 0x304
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_patch_val @_swof_clone_patch_val_original+@_swof_dbsize
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql

.print "[ INFO ] length of embeddeddb += newdbsize"
.param set @_swof_clone_patch_addr @_swof_clone_file_offset_of_rsrc+0x80+0x04
.param set @_swof_clone_patch_val @_swof_dbsize
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql

.print "[ INFO ] start location of manifest += newdbsize"
.param set @_swof_clone_patch_addr @_swof_clone_file_offset_of_rsrc+0x90
.read :ar:sqlite3swof/clone/scripts/clone_patch_get_dword.sql
.param set @_swof_clone_patch_val @_swof_clone_patch_val_original+@_swof_dbsize
.read :ar:sqlite3swof/clone/scripts/clone_patch_hex_dword.sql

-- write patched exe to file
select printf(
       '[ INFO ] writing %s, %d bytes',
       outfile.name,
       writefile(outfile.name, unhex(h))
)
from
	_swof_newexe,
	(select strftime('sqlite3swof.clone.%Y%m%d_%H%M%S.exe', datetime('now')) as name) as outfile;

.print "[ INFO ] deleting temporary db structures..."

drop table _swof_newexe;

.param unset @_swof_tmplexe
.param unset @_swof_db
.param unset @_swof_dbsize

.print "[ INFO ] end of clone script."
