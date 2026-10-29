/* System calls for the TDM simulator.

   The authors hereby grant permission to use, copy, modify, distribute,
   and license this software and its documentation for any purpose, provided
   that existing copyright notices are retained in all copies and that this
   notice is included verbatim in any distributions. No written agreement,
   license, or royalty fee is required for any of the authorized uses.
   Modifications to this software may be copyrighted by their authors
   and need not follow the licensing terms described here, provided that
   the new terms are clearly indicated on the first page of each file where
   they apply.  */

/* The simulator only has a console: file descriptors 0-2 are it, and
   nothing can be opened.  */

#include <errno.h>
#include <stddef.h>
#include <sys/stat.h>
#include <sys/types.h>

extern void __tdm_outbyte (int);
extern int __tdm_inbyte (void);
extern void _exit (int) __attribute__ ((noreturn));

static int
console_p (int fd)
{
  return fd >= 0 && fd <= 2;
}

int
_write (int fd, const void *buf, size_t len)
{
  const unsigned char *p = buf;

  if (!console_p (fd))
    {
      errno = EBADF;
      return -1;
    }
  for (size_t i = 0; i < len; i++)
    __tdm_outbyte (p[i]);
  return len;
}

/* Read up to LEN characters, stopping after a newline.  */

int
_read (int fd, void *buf, size_t len)
{
  unsigned char *p = buf;
  size_t n = 0;

  if (!console_p (fd))
    {
      errno = EBADF;
      return -1;
    }
  while (n < len)
    {
      int c = __tdm_inbyte ();
      if (c < 0)
	break;
      p[n++] = c;
      if (c == '\n')
	break;
    }
  return n;
}

int
_open (const char *name, int flags, ...)
{
  (void) name;
  (void) flags;
  errno = ENOENT;
  return -1;
}

int
_close (int fd)
{
  if (!console_p (fd))
    {
      errno = EBADF;
      return -1;
    }
  return 0;
}

int
_fstat (int fd, struct stat *st)
{
  if (!console_p (fd))
    {
      errno = EBADF;
      return -1;
    }
  st->st_mode = S_IFCHR;
  st->st_blksize = 0;
  return 0;
}

int
_stat (const char *name, struct stat *st)
{
  (void) name;
  (void) st;
  errno = ENOENT;
  return -1;
}

int
_isatty (int fd)
{
  if (!console_p (fd))
    {
      errno = EBADF;
      return 0;
    }
  return 1;
}

off_t
_lseek (int fd, off_t offset, int whence)
{
  (void) offset;
  (void) whence;
  errno = console_p (fd) ? ESPIPE : EBADF;
  return -1;
}

int
_unlink (const char *name)
{
  (void) name;
  errno = ENOENT;
  return -1;
}

int
_link (const char *old, const char *new)
{
  (void) old;
  (void) new;
  errno = EMLINK;
  return -1;
}

int
_getpid (void)
{
  return 1;
}

int
_kill (int pid, int sig)
{
  if (pid == 1)
    _exit (128 + sig);
  errno = EINVAL;
  return -1;
}

/* The heap grows from the end of .bss towards the stack.  */

void *
_sbrk (ptrdiff_t incr)
{
  extern char _end[];
  static char *brk;
  char *prev;

  if (brk == NULL)
    brk = _end;
  /* Leave some room for the stack to grow.  The room can be more than
     PTRDIFF_MAX octets, so compare as unsigned.  */
  if (incr > 0
      && (size_t) incr > (size_t) ((char *) __builtin_stack_address ()
				   - 256 - brk))
    {
      errno = ENOMEM;
      return (void *) -1;
    }
  prev = brk;
  brk += incr;
  return prev;
}
