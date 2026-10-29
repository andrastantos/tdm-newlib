/* Console and exit for the TDM simulator.

   The authors hereby grant permission to use, copy, modify, distribute,
   and license this software and its documentation for any purpose, provided
   that existing copyright notices are retained in all copies and that this
   notice is included verbatim in any distributions. No written agreement,
   license, or royalty fee is required for any of the authorized uses.
   Modifications to this software may be copyrighted by their authors
   and need not follow the licensing terms described here, provided that
   the new terms are clearly indicated on the first page of each file where
   they apply.  */

/* The simulator's tdm_stdio device has three ports:

     0xffe0  EXIT    write: stop, the value is the exit status
     0xffe1  STDOUT  write: print the low 8 bits
     0xffe2  STDIN   read: the next character, 0xffff at end of file

   They are above the reach of C data pointers, so these go through
   $r0 as a word address.  */

	.text

/* void _exit (int status) */
	.global	_exit
	.type	_exit, @function
_exit:
	mov	$r1, $r0
	mov	$r0, [$pc+(.Lexit_port-.)]
	mov	[$r0], $r1
	brk
.Lexit_port:	.word	0xffe0
	.size	_exit, .-_exit

/* void __tdm_outbyte (int c) */
	.global	__tdm_outbyte
	.type	__tdm_outbyte, @function
__tdm_outbyte:
	mov	$r1, $r0
	and	$r1, $mr3
	mov	$r0, [$pc+(.Lstdout_port-.)]
	mov	[$r0], $r1
	mov	$pc, [$sp]
.Lstdout_port:	.word	0xffe1
	.size	__tdm_outbyte, .-__tdm_outbyte

/* int __tdm_inbyte (void): a character, or -1 at end of file.  */
	.global	__tdm_inbyte
	.type	__tdm_inbyte, @function
__tdm_inbyte:
	mov	$r0, [$pc+(.Lstdin_port-.)]
	mov	$r0, [$r0]
	mov	$pc, [$sp]
.Lstdin_port:	.word	0xffe2
	.size	__tdm_inbyte, .-__tdm_inbyte
