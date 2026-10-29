/* setjmp and longjmp for TDM.

   The authors hereby grant permission to use, copy, modify, distribute,
   and license this software and its documentation for any purpose, provided
   that existing copyright notices are retained in all copies and that this
   notice is included verbatim in any distributions. No written agreement,
   license, or royalty fee is required for any of the authorized uses.
   Modifications to this software may be copyrighted by their authors
   and need not follow the licensing terms described here, provided that
   the new terms are clearly indicated on the first page of each file where
   they apply.  */

/* The jmp_buf holds the callee saved registers and how to return:

     word 0	$mr6 (the frame pointer of functions that need one)
     words 1-13	$mr19-$mr31
     word 14	$sp
     word 15	the return address, which the call left in [$sp]

   The jmp_buf pointer comes in $r0 as a byte pointer (twice the word
   address); longjmp's second argument is on the stack, at [$sp+1].
   $mr3-$mr5 are constants and need no saving.  */

	.text
	.global	setjmp
	.type	setjmp, @function
setjmp:
	ror	$r0
	mov	$r1, $mr6
	mov	[$r0], $r1
	mov	$r1, $mr19
	mov	[$r0+1], $r1
	mov	$r1, $mr20
	mov	[$r0+2], $r1
	mov	$r1, $mr21
	mov	[$r0+3], $r1
	mov	$r1, $mr22
	mov	[$r0+4], $r1
	mov	$r1, $mr23
	mov	[$r0+5], $r1
	mov	$r1, $mr24
	mov	[$r0+6], $r1
	mov	$r1, $mr25
	mov	[$r0+7], $r1
	mov	$r1, $mr26
	mov	[$r0+8], $r1
	mov	$r1, $mr27
	mov	[$r0+9], $r1
	mov	$r1, $mr28
	mov	[$r0+10], $r1
	mov	$r1, $mr29
	mov	[$r0+11], $r1
	mov	$r1, $mr30
	mov	[$r0+12], $r1
	mov	$r1, $mr31
	mov	[$r0+13], $r1
	mov	[$r0+14], $sp
	mov	$r1, [$sp]
	mov	[$r0+15], $r1
	mov	$r0, 0
	mov	$pc, [$sp]
	.size	setjmp, .-setjmp

	.global	longjmp
	.type	longjmp, @function
longjmp:
	/* Return VAL, or 1 for 0.  Keep it in $mr7, which is caller
	   saved, while $r1 moves the registers.  */
	mov	$r1, [$sp+1]
	if_eq	$r1, 0
	mov	$r1, 1
	mov	$mr7, $r1
	ror	$r0
	mov	$r1, [$r0]
	mov	$mr6, $r1
	mov	$r1, [$r0+1]
	mov	$mr19, $r1
	mov	$r1, [$r0+2]
	mov	$mr20, $r1
	mov	$r1, [$r0+3]
	mov	$mr21, $r1
	mov	$r1, [$r0+4]
	mov	$mr22, $r1
	mov	$r1, [$r0+5]
	mov	$mr23, $r1
	mov	$r1, [$r0+6]
	mov	$mr24, $r1
	mov	$r1, [$r0+7]
	mov	$mr25, $r1
	mov	$r1, [$r0+8]
	mov	$mr26, $r1
	mov	$r1, [$r0+9]
	mov	$mr27, $r1
	mov	$r1, [$r0+10]
	mov	$mr28, $r1
	mov	$r1, [$r0+11]
	mov	$mr29, $r1
	mov	$r1, [$r0+12]
	mov	$mr30, $r1
	mov	$r1, [$r0+13]
	mov	$mr31, $r1
	mov	$sp, [$r0+14]
	/* The call slot of setjmp's caller may have been reused since:
	   put the return address back.  */
	mov	$r1, [$r0+15]
	mov	[$sp], $r1
	mov	$r0, $mr7
	mov	$pc, [$sp]
	.size	longjmp, .-longjmp
