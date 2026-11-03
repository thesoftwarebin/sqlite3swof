-- args: @_swof_clone_patch_addr
-- sets: @_swof_clone_patch_val_original

.param set @_swof_clone_patch_val_original "(select (( (instr('0123456789ABCDEF', substr(h, (2*@_swof_clone_patch_addr)+1+0, 1))-1) << 4*1 ) + ( (instr('0123456789ABCDEF', substr(h, (2*@_swof_clone_patch_addr)+1+1, 1))-1) << 4*0 ) + ( (instr('0123456789ABCDEF', substr(h, (2*@_swof_clone_patch_addr)+1+2, 1))-1) << 4*3 ) + ( (instr('0123456789ABCDEF', substr(h, (2*@_swof_clone_patch_addr)+1+3, 1))-1) << 4*2 ) + ( (instr('0123456789ABCDEF', substr(h, (2*@_swof_clone_patch_addr)+1+4, 1))-1) << 4*5 ) + ( (instr('0123456789ABCDEF', substr(h, (2*@_swof_clone_patch_addr)+1+5, 1))-1) << 4*4 ) + ( (instr('0123456789ABCDEF', substr(h, (2*@_swof_clone_patch_addr)+1+6, 1))-1) << 4*7 ) + ( (instr('0123456789ABCDEF', substr(h, (2*@_swof_clone_patch_addr)+1+7, 1))-1) << 4*6 ) ) from (select hex(@_swof_tmplexe) as h))"

select
	printf('    inspecting @_swof_tmplexe dword at address 0x%08x: it''s 0x%08x',
		@_swof_clone_patch_addr,
		@_swof_clone_patch_val_original
	);
