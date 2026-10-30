-- args: @_swof_clone_patch_addr
--       @_swof_clone_patch_val

select printf('    patching: at addr 0x%08x change value 0x%s%s%s%s -> 0x%08x',
       @_swof_clone_patch_addr,
       substr(h, (2*@_swof_clone_patch_addr)+7, 2),
       substr(h, (2*@_swof_clone_patch_addr)+5, 2),
       substr(h, (2*@_swof_clone_patch_addr)+3, 2),
       substr(h, (2*@_swof_clone_patch_addr)+1, 2),
       @_swof_clone_patch_val)
       from _swof_newexe;

update _swof_newexe set h=printf(
	 	'%s%02X%02X%02X%02X%s',
	 	substr(h, 1, 2*@_swof_clone_patch_addr),
		@_swof_clone_patch_val & 0xff,
		@_swof_clone_patch_val & 0xff00     >> 8,
		@_swof_clone_patch_val & 0xff0000   >> 16,
		@_swof_clone_patch_val & 0xff000000 >> 24,
		substr(h, 2 * (@_swof_clone_patch_addr + 4)+1)
	)
;
