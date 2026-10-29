/* Startup code for TDM.

   The authors hereby grant permission to use, copy, modify, distribute,
   and license this software and its documentation for any purpose, provided
   that existing copyright notices are retained in all copies and that this
   notice is included verbatim in any distributions. No written agreement,
   license, or royalty fee is required for any of the authorized uses.
   Modifications to this software may be copyrighted by their authors
   and need not follow the licensing terms described here, provided that
   the new terms are clearly indicated on the first page of each file where
   they apply.  */

/* Set up the stack and the constant registers $mr3-$mr5, clear .bss,
   run the constructors, then call main (0, NULL) and exit with its
   result.  The program is loaded into memory as linked, .data
   included.

   The stack starts at _stack, a word address, if the link defines it
   (say with --defsym=_stack=ADDR); otherwise at 0x7ffe, the top of the
   32K words that C data can be in.  [_stack+1] holds main's second
   argument.  */

	.weak	_stack

	.text
	.global	_start
	.type	_start, @function
_start:
	mov	$r0, [$pc+(.Lstack-.)]
	if_eq	$r0, 0
	mov	$r0, [$pc+(.Ldefault_stack-.)]
	mov	$sp, $r0
	mov	$r0, [$pc+(.Lc3-.)]
	mov	$mr3, $r0
	mov	$r0, [$pc+(.Lc4-.)]
	mov	$mr4, $r0
	mov	$r0, [$pc+(.Lc5-.)]
	mov	$mr5, $r0

	/* Clear .bss, a word at a time.  */
	mov	$r0, [$pc+(.Lbss_start-.)]
	mov	$r1, 0
.Lclear:
	if_geu	$r0, [$pc+(.Lbss_end-.)]
	mov	$pc, $pc+(.Lcleared-.)
	mov	[$r0], $r1
	add	$r0, 1
	mov	$pc, $pc+(.Lclear-.)
.Lcleared:

	mov	$r1, [$pc+(.Linit-.)]
	mov	[$sp], $r1
	swap	$pc, [$sp]

	/* main (0, NULL).  */
	mov	$r0, 0
	mov	$r1, 0
	mov	[$sp+1], $r1
	mov	$r1, [$pc+(.Lmain-.)]
	mov	[$sp], $r1
	swap	$pc, [$sp]

	mov	$r1, [$pc+(.Lexit-.)]
	mov	[$sp], $r1
	swap	$pc, [$sp]
	brk

.Lstack:	.word	_stack
.Ldefault_stack: .word	0x7ffe
.Lc3:		.word	0x00ff
.Lc4:		.word	0xff00
.Lc5:		.word	0x7fff
.Lbss_start:	.word	__bss_start
.Lbss_end:	.word	_end
.Linit:		.word	__libc_init_array
.Lmain:		.word	main
.Lexit:		.word	exit
	.size	_start, .-_start

/* __libc_init_array calls these; there's nothing for them to do.  */
	.weak	_init
	.type	_init, @function
_init:
	.weak	_fini
	.type	_fini, @function
_fini:
	mov	$pc, [$sp]
	.size	_init, .-_init
	.size	_fini, .-_fini
