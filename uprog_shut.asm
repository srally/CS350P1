
_uprog_shut:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#endif


int 
main(int argc, char * argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
    printf(1, "BYE~\n");
  11:	83 ec 08             	sub    $0x8,%esp
  14:	68 bd 07 00 00       	push   $0x7bd
  19:	6a 01                	push   $0x1
  1b:	e8 e7 03 00 00       	call   407 <printf>
  20:	83 c4 10             	add    $0x10,%esp
    uprog_shut();
  23:	e8 04 03 00 00       	call   32c <uprog_shut>
    exit(); //return 0;
  28:	e8 57 02 00 00       	call   284 <exit>

0000002d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  2d:	55                   	push   %ebp
  2e:	89 e5                	mov    %esp,%ebp
  30:	57                   	push   %edi
  31:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  35:	8b 55 10             	mov    0x10(%ebp),%edx
  38:	8b 45 0c             	mov    0xc(%ebp),%eax
  3b:	89 cb                	mov    %ecx,%ebx
  3d:	89 df                	mov    %ebx,%edi
  3f:	89 d1                	mov    %edx,%ecx
  41:	fc                   	cld    
  42:	f3 aa                	rep stos %al,%es:(%edi)
  44:	89 ca                	mov    %ecx,%edx
  46:	89 fb                	mov    %edi,%ebx
  48:	89 5d 08             	mov    %ebx,0x8(%ebp)
  4b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  4e:	90                   	nop
  4f:	5b                   	pop    %ebx
  50:	5f                   	pop    %edi
  51:	5d                   	pop    %ebp
  52:	c3                   	ret    

00000053 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  53:	55                   	push   %ebp
  54:	89 e5                	mov    %esp,%ebp
  56:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  59:	8b 45 08             	mov    0x8(%ebp),%eax
  5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  5f:	90                   	nop
  60:	8b 55 0c             	mov    0xc(%ebp),%edx
  63:	8d 42 01             	lea    0x1(%edx),%eax
  66:	89 45 0c             	mov    %eax,0xc(%ebp)
  69:	8b 45 08             	mov    0x8(%ebp),%eax
  6c:	8d 48 01             	lea    0x1(%eax),%ecx
  6f:	89 4d 08             	mov    %ecx,0x8(%ebp)
  72:	0f b6 12             	movzbl (%edx),%edx
  75:	88 10                	mov    %dl,(%eax)
  77:	0f b6 00             	movzbl (%eax),%eax
  7a:	84 c0                	test   %al,%al
  7c:	75 e2                	jne    60 <strcpy+0xd>
    ;
  return os;
  7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  81:	c9                   	leave  
  82:	c3                   	ret    

00000083 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  83:	55                   	push   %ebp
  84:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  86:	eb 08                	jmp    90 <strcmp+0xd>
    p++, q++;
  88:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  90:	8b 45 08             	mov    0x8(%ebp),%eax
  93:	0f b6 00             	movzbl (%eax),%eax
  96:	84 c0                	test   %al,%al
  98:	74 10                	je     aa <strcmp+0x27>
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	0f b6 10             	movzbl (%eax),%edx
  a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  a3:	0f b6 00             	movzbl (%eax),%eax
  a6:	38 c2                	cmp    %al,%dl
  a8:	74 de                	je     88 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  aa:	8b 45 08             	mov    0x8(%ebp),%eax
  ad:	0f b6 00             	movzbl (%eax),%eax
  b0:	0f b6 d0             	movzbl %al,%edx
  b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  b6:	0f b6 00             	movzbl (%eax),%eax
  b9:	0f b6 c0             	movzbl %al,%eax
  bc:	29 c2                	sub    %eax,%edx
  be:	89 d0                	mov    %edx,%eax
}
  c0:	5d                   	pop    %ebp
  c1:	c3                   	ret    

000000c2 <strlen>:

uint
strlen(char *s)
{
  c2:	55                   	push   %ebp
  c3:	89 e5                	mov    %esp,%ebp
  c5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  cf:	eb 04                	jmp    d5 <strlen+0x13>
  d1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  d8:	8b 45 08             	mov    0x8(%ebp),%eax
  db:	01 d0                	add    %edx,%eax
  dd:	0f b6 00             	movzbl (%eax),%eax
  e0:	84 c0                	test   %al,%al
  e2:	75 ed                	jne    d1 <strlen+0xf>
    ;
  return n;
  e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e7:	c9                   	leave  
  e8:	c3                   	ret    

000000e9 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e9:	55                   	push   %ebp
  ea:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  ec:	8b 45 10             	mov    0x10(%ebp),%eax
  ef:	50                   	push   %eax
  f0:	ff 75 0c             	pushl  0xc(%ebp)
  f3:	ff 75 08             	pushl  0x8(%ebp)
  f6:	e8 32 ff ff ff       	call   2d <stosb>
  fb:	83 c4 0c             	add    $0xc,%esp
  return dst;
  fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
 101:	c9                   	leave  
 102:	c3                   	ret    

00000103 <strchr>:

char*
strchr(const char *s, char c)
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 ec 04             	sub    $0x4,%esp
 109:	8b 45 0c             	mov    0xc(%ebp),%eax
 10c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 10f:	eb 14                	jmp    125 <strchr+0x22>
    if(*s == c)
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	0f b6 00             	movzbl (%eax),%eax
 117:	38 45 fc             	cmp    %al,-0x4(%ebp)
 11a:	75 05                	jne    121 <strchr+0x1e>
      return (char*)s;
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	eb 13                	jmp    134 <strchr+0x31>
  for(; *s; s++)
 121:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 125:	8b 45 08             	mov    0x8(%ebp),%eax
 128:	0f b6 00             	movzbl (%eax),%eax
 12b:	84 c0                	test   %al,%al
 12d:	75 e2                	jne    111 <strchr+0xe>
  return 0;
 12f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 134:	c9                   	leave  
 135:	c3                   	ret    

00000136 <gets>:

char*
gets(char *buf, int max)
{
 136:	55                   	push   %ebp
 137:	89 e5                	mov    %esp,%ebp
 139:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 143:	eb 42                	jmp    187 <gets+0x51>
    cc = read(0, &c, 1);
 145:	83 ec 04             	sub    $0x4,%esp
 148:	6a 01                	push   $0x1
 14a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 14d:	50                   	push   %eax
 14e:	6a 00                	push   $0x0
 150:	e8 47 01 00 00       	call   29c <read>
 155:	83 c4 10             	add    $0x10,%esp
 158:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 15b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 15f:	7e 33                	jle    194 <gets+0x5e>
      break;
    buf[i++] = c;
 161:	8b 45 f4             	mov    -0xc(%ebp),%eax
 164:	8d 50 01             	lea    0x1(%eax),%edx
 167:	89 55 f4             	mov    %edx,-0xc(%ebp)
 16a:	89 c2                	mov    %eax,%edx
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	01 c2                	add    %eax,%edx
 171:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 175:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 177:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 17b:	3c 0a                	cmp    $0xa,%al
 17d:	74 16                	je     195 <gets+0x5f>
 17f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 183:	3c 0d                	cmp    $0xd,%al
 185:	74 0e                	je     195 <gets+0x5f>
  for(i=0; i+1 < max; ){
 187:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18a:	83 c0 01             	add    $0x1,%eax
 18d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 190:	7f b3                	jg     145 <gets+0xf>
 192:	eb 01                	jmp    195 <gets+0x5f>
      break;
 194:	90                   	nop
      break;
  }
  buf[i] = '\0';
 195:	8b 55 f4             	mov    -0xc(%ebp),%edx
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	01 d0                	add    %edx,%eax
 19d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a3:	c9                   	leave  
 1a4:	c3                   	ret    

000001a5 <stat>:

int
stat(char *n, struct stat *st)
{
 1a5:	55                   	push   %ebp
 1a6:	89 e5                	mov    %esp,%ebp
 1a8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ab:	83 ec 08             	sub    $0x8,%esp
 1ae:	6a 00                	push   $0x0
 1b0:	ff 75 08             	pushl  0x8(%ebp)
 1b3:	e8 0c 01 00 00       	call   2c4 <open>
 1b8:	83 c4 10             	add    $0x10,%esp
 1bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c2:	79 07                	jns    1cb <stat+0x26>
    return -1;
 1c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c9:	eb 25                	jmp    1f0 <stat+0x4b>
  r = fstat(fd, st);
 1cb:	83 ec 08             	sub    $0x8,%esp
 1ce:	ff 75 0c             	pushl  0xc(%ebp)
 1d1:	ff 75 f4             	pushl  -0xc(%ebp)
 1d4:	e8 03 01 00 00       	call   2dc <fstat>
 1d9:	83 c4 10             	add    $0x10,%esp
 1dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1df:	83 ec 0c             	sub    $0xc,%esp
 1e2:	ff 75 f4             	pushl  -0xc(%ebp)
 1e5:	e8 c2 00 00 00       	call   2ac <close>
 1ea:	83 c4 10             	add    $0x10,%esp
  return r;
 1ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1f0:	c9                   	leave  
 1f1:	c3                   	ret    

000001f2 <atoi>:

int
atoi(const char *s)
{
 1f2:	55                   	push   %ebp
 1f3:	89 e5                	mov    %esp,%ebp
 1f5:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1ff:	eb 25                	jmp    226 <atoi+0x34>
    n = n*10 + *s++ - '0';
 201:	8b 55 fc             	mov    -0x4(%ebp),%edx
 204:	89 d0                	mov    %edx,%eax
 206:	c1 e0 02             	shl    $0x2,%eax
 209:	01 d0                	add    %edx,%eax
 20b:	01 c0                	add    %eax,%eax
 20d:	89 c1                	mov    %eax,%ecx
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	8d 50 01             	lea    0x1(%eax),%edx
 215:	89 55 08             	mov    %edx,0x8(%ebp)
 218:	0f b6 00             	movzbl (%eax),%eax
 21b:	0f be c0             	movsbl %al,%eax
 21e:	01 c8                	add    %ecx,%eax
 220:	83 e8 30             	sub    $0x30,%eax
 223:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 226:	8b 45 08             	mov    0x8(%ebp),%eax
 229:	0f b6 00             	movzbl (%eax),%eax
 22c:	3c 2f                	cmp    $0x2f,%al
 22e:	7e 0a                	jle    23a <atoi+0x48>
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	0f b6 00             	movzbl (%eax),%eax
 236:	3c 39                	cmp    $0x39,%al
 238:	7e c7                	jle    201 <atoi+0xf>
  return n;
 23a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 23d:	c9                   	leave  
 23e:	c3                   	ret    

0000023f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 23f:	55                   	push   %ebp
 240:	89 e5                	mov    %esp,%ebp
 242:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 245:	8b 45 08             	mov    0x8(%ebp),%eax
 248:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 24b:	8b 45 0c             	mov    0xc(%ebp),%eax
 24e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 251:	eb 17                	jmp    26a <memmove+0x2b>
    *dst++ = *src++;
 253:	8b 55 f8             	mov    -0x8(%ebp),%edx
 256:	8d 42 01             	lea    0x1(%edx),%eax
 259:	89 45 f8             	mov    %eax,-0x8(%ebp)
 25c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 25f:	8d 48 01             	lea    0x1(%eax),%ecx
 262:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 265:	0f b6 12             	movzbl (%edx),%edx
 268:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 26a:	8b 45 10             	mov    0x10(%ebp),%eax
 26d:	8d 50 ff             	lea    -0x1(%eax),%edx
 270:	89 55 10             	mov    %edx,0x10(%ebp)
 273:	85 c0                	test   %eax,%eax
 275:	7f dc                	jg     253 <memmove+0x14>
  return vdst;
 277:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27a:	c9                   	leave  
 27b:	c3                   	ret    

0000027c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 27c:	b8 01 00 00 00       	mov    $0x1,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <exit>:
SYSCALL(exit)
 284:	b8 02 00 00 00       	mov    $0x2,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <wait>:
SYSCALL(wait)
 28c:	b8 03 00 00 00       	mov    $0x3,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <pipe>:
SYSCALL(pipe)
 294:	b8 04 00 00 00       	mov    $0x4,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <read>:
SYSCALL(read)
 29c:	b8 05 00 00 00       	mov    $0x5,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <write>:
SYSCALL(write)
 2a4:	b8 10 00 00 00       	mov    $0x10,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <close>:
SYSCALL(close)
 2ac:	b8 15 00 00 00       	mov    $0x15,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <kill>:
SYSCALL(kill)
 2b4:	b8 06 00 00 00       	mov    $0x6,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <exec>:
SYSCALL(exec)
 2bc:	b8 07 00 00 00       	mov    $0x7,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <open>:
SYSCALL(open)
 2c4:	b8 0f 00 00 00       	mov    $0xf,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <mknod>:
SYSCALL(mknod)
 2cc:	b8 11 00 00 00       	mov    $0x11,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <unlink>:
SYSCALL(unlink)
 2d4:	b8 12 00 00 00       	mov    $0x12,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <fstat>:
SYSCALL(fstat)
 2dc:	b8 08 00 00 00       	mov    $0x8,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <link>:
SYSCALL(link)
 2e4:	b8 13 00 00 00       	mov    $0x13,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <mkdir>:
SYSCALL(mkdir)
 2ec:	b8 14 00 00 00       	mov    $0x14,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <chdir>:
SYSCALL(chdir)
 2f4:	b8 09 00 00 00       	mov    $0x9,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <dup>:
SYSCALL(dup)
 2fc:	b8 0a 00 00 00       	mov    $0xa,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <getpid>:
SYSCALL(getpid)
 304:	b8 0b 00 00 00       	mov    $0xb,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <sbrk>:
SYSCALL(sbrk)
 30c:	b8 0c 00 00 00       	mov    $0xc,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <sleep>:
SYSCALL(sleep)
 314:	b8 0d 00 00 00       	mov    $0xd,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <uptime>:
SYSCALL(uptime)
 31c:	b8 0e 00 00 00       	mov    $0xe,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <enable_sched_trace>:
SYSCALL(enable_sched_trace)
 324:	b8 16 00 00 00       	mov    $0x16,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <uprog_shut>:
SYSCALL(uprog_shut)
 32c:	b8 17 00 00 00       	mov    $0x17,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 334:	55                   	push   %ebp
 335:	89 e5                	mov    %esp,%ebp
 337:	83 ec 18             	sub    $0x18,%esp
 33a:	8b 45 0c             	mov    0xc(%ebp),%eax
 33d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 340:	83 ec 04             	sub    $0x4,%esp
 343:	6a 01                	push   $0x1
 345:	8d 45 f4             	lea    -0xc(%ebp),%eax
 348:	50                   	push   %eax
 349:	ff 75 08             	pushl  0x8(%ebp)
 34c:	e8 53 ff ff ff       	call   2a4 <write>
 351:	83 c4 10             	add    $0x10,%esp
}
 354:	90                   	nop
 355:	c9                   	leave  
 356:	c3                   	ret    

00000357 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 357:	55                   	push   %ebp
 358:	89 e5                	mov    %esp,%ebp
 35a:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 35d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 364:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 368:	74 17                	je     381 <printint+0x2a>
 36a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 36e:	79 11                	jns    381 <printint+0x2a>
    neg = 1;
 370:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 377:	8b 45 0c             	mov    0xc(%ebp),%eax
 37a:	f7 d8                	neg    %eax
 37c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 37f:	eb 06                	jmp    387 <printint+0x30>
  } else {
    x = xx;
 381:	8b 45 0c             	mov    0xc(%ebp),%eax
 384:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 387:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 38e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 391:	8b 45 ec             	mov    -0x14(%ebp),%eax
 394:	ba 00 00 00 00       	mov    $0x0,%edx
 399:	f7 f1                	div    %ecx
 39b:	89 d1                	mov    %edx,%ecx
 39d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a0:	8d 50 01             	lea    0x1(%eax),%edx
 3a3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3a6:	0f b6 91 10 0a 00 00 	movzbl 0xa10(%ecx),%edx
 3ad:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3b7:	ba 00 00 00 00       	mov    $0x0,%edx
 3bc:	f7 f1                	div    %ecx
 3be:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3c5:	75 c7                	jne    38e <printint+0x37>
  if(neg)
 3c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3cb:	74 2d                	je     3fa <printint+0xa3>
    buf[i++] = '-';
 3cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d0:	8d 50 01             	lea    0x1(%eax),%edx
 3d3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3d6:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3db:	eb 1d                	jmp    3fa <printint+0xa3>
    putc(fd, buf[i]);
 3dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e3:	01 d0                	add    %edx,%eax
 3e5:	0f b6 00             	movzbl (%eax),%eax
 3e8:	0f be c0             	movsbl %al,%eax
 3eb:	83 ec 08             	sub    $0x8,%esp
 3ee:	50                   	push   %eax
 3ef:	ff 75 08             	pushl  0x8(%ebp)
 3f2:	e8 3d ff ff ff       	call   334 <putc>
 3f7:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 3fa:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 402:	79 d9                	jns    3dd <printint+0x86>
}
 404:	90                   	nop
 405:	c9                   	leave  
 406:	c3                   	ret    

00000407 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 407:	55                   	push   %ebp
 408:	89 e5                	mov    %esp,%ebp
 40a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 40d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 414:	8d 45 0c             	lea    0xc(%ebp),%eax
 417:	83 c0 04             	add    $0x4,%eax
 41a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 41d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 424:	e9 59 01 00 00       	jmp    582 <printf+0x17b>
    c = fmt[i] & 0xff;
 429:	8b 55 0c             	mov    0xc(%ebp),%edx
 42c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 42f:	01 d0                	add    %edx,%eax
 431:	0f b6 00             	movzbl (%eax),%eax
 434:	0f be c0             	movsbl %al,%eax
 437:	25 ff 00 00 00       	and    $0xff,%eax
 43c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 43f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 443:	75 2c                	jne    471 <printf+0x6a>
      if(c == '%'){
 445:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 449:	75 0c                	jne    457 <printf+0x50>
        state = '%';
 44b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 452:	e9 27 01 00 00       	jmp    57e <printf+0x177>
      } else {
        putc(fd, c);
 457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 45a:	0f be c0             	movsbl %al,%eax
 45d:	83 ec 08             	sub    $0x8,%esp
 460:	50                   	push   %eax
 461:	ff 75 08             	pushl  0x8(%ebp)
 464:	e8 cb fe ff ff       	call   334 <putc>
 469:	83 c4 10             	add    $0x10,%esp
 46c:	e9 0d 01 00 00       	jmp    57e <printf+0x177>
      }
    } else if(state == '%'){
 471:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 475:	0f 85 03 01 00 00    	jne    57e <printf+0x177>
      if(c == 'd'){
 47b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 47f:	75 1e                	jne    49f <printf+0x98>
        printint(fd, *ap, 10, 1);
 481:	8b 45 e8             	mov    -0x18(%ebp),%eax
 484:	8b 00                	mov    (%eax),%eax
 486:	6a 01                	push   $0x1
 488:	6a 0a                	push   $0xa
 48a:	50                   	push   %eax
 48b:	ff 75 08             	pushl  0x8(%ebp)
 48e:	e8 c4 fe ff ff       	call   357 <printint>
 493:	83 c4 10             	add    $0x10,%esp
        ap++;
 496:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 49a:	e9 d8 00 00 00       	jmp    577 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 49f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4a3:	74 06                	je     4ab <printf+0xa4>
 4a5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4a9:	75 1e                	jne    4c9 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ae:	8b 00                	mov    (%eax),%eax
 4b0:	6a 00                	push   $0x0
 4b2:	6a 10                	push   $0x10
 4b4:	50                   	push   %eax
 4b5:	ff 75 08             	pushl  0x8(%ebp)
 4b8:	e8 9a fe ff ff       	call   357 <printint>
 4bd:	83 c4 10             	add    $0x10,%esp
        ap++;
 4c0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4c4:	e9 ae 00 00 00       	jmp    577 <printf+0x170>
      } else if(c == 's'){
 4c9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4cd:	75 43                	jne    512 <printf+0x10b>
        s = (char*)*ap;
 4cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d2:	8b 00                	mov    (%eax),%eax
 4d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4d7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4df:	75 25                	jne    506 <printf+0xff>
          s = "(null)";
 4e1:	c7 45 f4 c3 07 00 00 	movl   $0x7c3,-0xc(%ebp)
        while(*s != 0){
 4e8:	eb 1c                	jmp    506 <printf+0xff>
          putc(fd, *s);
 4ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ed:	0f b6 00             	movzbl (%eax),%eax
 4f0:	0f be c0             	movsbl %al,%eax
 4f3:	83 ec 08             	sub    $0x8,%esp
 4f6:	50                   	push   %eax
 4f7:	ff 75 08             	pushl  0x8(%ebp)
 4fa:	e8 35 fe ff ff       	call   334 <putc>
 4ff:	83 c4 10             	add    $0x10,%esp
          s++;
 502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 506:	8b 45 f4             	mov    -0xc(%ebp),%eax
 509:	0f b6 00             	movzbl (%eax),%eax
 50c:	84 c0                	test   %al,%al
 50e:	75 da                	jne    4ea <printf+0xe3>
 510:	eb 65                	jmp    577 <printf+0x170>
        }
      } else if(c == 'c'){
 512:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 516:	75 1d                	jne    535 <printf+0x12e>
        putc(fd, *ap);
 518:	8b 45 e8             	mov    -0x18(%ebp),%eax
 51b:	8b 00                	mov    (%eax),%eax
 51d:	0f be c0             	movsbl %al,%eax
 520:	83 ec 08             	sub    $0x8,%esp
 523:	50                   	push   %eax
 524:	ff 75 08             	pushl  0x8(%ebp)
 527:	e8 08 fe ff ff       	call   334 <putc>
 52c:	83 c4 10             	add    $0x10,%esp
        ap++;
 52f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 533:	eb 42                	jmp    577 <printf+0x170>
      } else if(c == '%'){
 535:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 539:	75 17                	jne    552 <printf+0x14b>
        putc(fd, c);
 53b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 53e:	0f be c0             	movsbl %al,%eax
 541:	83 ec 08             	sub    $0x8,%esp
 544:	50                   	push   %eax
 545:	ff 75 08             	pushl  0x8(%ebp)
 548:	e8 e7 fd ff ff       	call   334 <putc>
 54d:	83 c4 10             	add    $0x10,%esp
 550:	eb 25                	jmp    577 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 552:	83 ec 08             	sub    $0x8,%esp
 555:	6a 25                	push   $0x25
 557:	ff 75 08             	pushl  0x8(%ebp)
 55a:	e8 d5 fd ff ff       	call   334 <putc>
 55f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 565:	0f be c0             	movsbl %al,%eax
 568:	83 ec 08             	sub    $0x8,%esp
 56b:	50                   	push   %eax
 56c:	ff 75 08             	pushl  0x8(%ebp)
 56f:	e8 c0 fd ff ff       	call   334 <putc>
 574:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 577:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 57e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 582:	8b 55 0c             	mov    0xc(%ebp),%edx
 585:	8b 45 f0             	mov    -0x10(%ebp),%eax
 588:	01 d0                	add    %edx,%eax
 58a:	0f b6 00             	movzbl (%eax),%eax
 58d:	84 c0                	test   %al,%al
 58f:	0f 85 94 fe ff ff    	jne    429 <printf+0x22>
    }
  }
}
 595:	90                   	nop
 596:	c9                   	leave  
 597:	c3                   	ret    

00000598 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 598:	55                   	push   %ebp
 599:	89 e5                	mov    %esp,%ebp
 59b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	83 e8 08             	sub    $0x8,%eax
 5a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5a7:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 5ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5af:	eb 24                	jmp    5d5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b4:	8b 00                	mov    (%eax),%eax
 5b6:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5b9:	72 12                	jb     5cd <free+0x35>
 5bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5c1:	77 24                	ja     5e7 <free+0x4f>
 5c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c6:	8b 00                	mov    (%eax),%eax
 5c8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5cb:	72 1a                	jb     5e7 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d0:	8b 00                	mov    (%eax),%eax
 5d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5db:	76 d4                	jbe    5b1 <free+0x19>
 5dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e0:	8b 00                	mov    (%eax),%eax
 5e2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5e5:	73 ca                	jae    5b1 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ea:	8b 40 04             	mov    0x4(%eax),%eax
 5ed:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 5f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f7:	01 c2                	add    %eax,%edx
 5f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fc:	8b 00                	mov    (%eax),%eax
 5fe:	39 c2                	cmp    %eax,%edx
 600:	75 24                	jne    626 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 602:	8b 45 f8             	mov    -0x8(%ebp),%eax
 605:	8b 50 04             	mov    0x4(%eax),%edx
 608:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60b:	8b 00                	mov    (%eax),%eax
 60d:	8b 40 04             	mov    0x4(%eax),%eax
 610:	01 c2                	add    %eax,%edx
 612:	8b 45 f8             	mov    -0x8(%ebp),%eax
 615:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 618:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61b:	8b 00                	mov    (%eax),%eax
 61d:	8b 10                	mov    (%eax),%edx
 61f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 622:	89 10                	mov    %edx,(%eax)
 624:	eb 0a                	jmp    630 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 626:	8b 45 fc             	mov    -0x4(%ebp),%eax
 629:	8b 10                	mov    (%eax),%edx
 62b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 630:	8b 45 fc             	mov    -0x4(%ebp),%eax
 633:	8b 40 04             	mov    0x4(%eax),%eax
 636:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 63d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 640:	01 d0                	add    %edx,%eax
 642:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 645:	75 20                	jne    667 <free+0xcf>
    p->s.size += bp->s.size;
 647:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64a:	8b 50 04             	mov    0x4(%eax),%edx
 64d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 650:	8b 40 04             	mov    0x4(%eax),%eax
 653:	01 c2                	add    %eax,%edx
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 65b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65e:	8b 10                	mov    (%eax),%edx
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	89 10                	mov    %edx,(%eax)
 665:	eb 08                	jmp    66f <free+0xd7>
  } else
    p->s.ptr = bp;
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 66d:	89 10                	mov    %edx,(%eax)
  freep = p;
 66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 672:	a3 2c 0a 00 00       	mov    %eax,0xa2c
}
 677:	90                   	nop
 678:	c9                   	leave  
 679:	c3                   	ret    

0000067a <morecore>:

static Header*
morecore(uint nu)
{
 67a:	55                   	push   %ebp
 67b:	89 e5                	mov    %esp,%ebp
 67d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 680:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 687:	77 07                	ja     690 <morecore+0x16>
    nu = 4096;
 689:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 690:	8b 45 08             	mov    0x8(%ebp),%eax
 693:	c1 e0 03             	shl    $0x3,%eax
 696:	83 ec 0c             	sub    $0xc,%esp
 699:	50                   	push   %eax
 69a:	e8 6d fc ff ff       	call   30c <sbrk>
 69f:	83 c4 10             	add    $0x10,%esp
 6a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6a5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6a9:	75 07                	jne    6b2 <morecore+0x38>
    return 0;
 6ab:	b8 00 00 00 00       	mov    $0x0,%eax
 6b0:	eb 26                	jmp    6d8 <morecore+0x5e>
  hp = (Header*)p;
 6b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6bb:	8b 55 08             	mov    0x8(%ebp),%edx
 6be:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c4:	83 c0 08             	add    $0x8,%eax
 6c7:	83 ec 0c             	sub    $0xc,%esp
 6ca:	50                   	push   %eax
 6cb:	e8 c8 fe ff ff       	call   598 <free>
 6d0:	83 c4 10             	add    $0x10,%esp
  return freep;
 6d3:	a1 2c 0a 00 00       	mov    0xa2c,%eax
}
 6d8:	c9                   	leave  
 6d9:	c3                   	ret    

000006da <malloc>:

void*
malloc(uint nbytes)
{
 6da:	55                   	push   %ebp
 6db:	89 e5                	mov    %esp,%ebp
 6dd:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6e0:	8b 45 08             	mov    0x8(%ebp),%eax
 6e3:	83 c0 07             	add    $0x7,%eax
 6e6:	c1 e8 03             	shr    $0x3,%eax
 6e9:	83 c0 01             	add    $0x1,%eax
 6ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6ef:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 6f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6fb:	75 23                	jne    720 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6fd:	c7 45 f0 24 0a 00 00 	movl   $0xa24,-0x10(%ebp)
 704:	8b 45 f0             	mov    -0x10(%ebp),%eax
 707:	a3 2c 0a 00 00       	mov    %eax,0xa2c
 70c:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 711:	a3 24 0a 00 00       	mov    %eax,0xa24
    base.s.size = 0;
 716:	c7 05 28 0a 00 00 00 	movl   $0x0,0xa28
 71d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 720:	8b 45 f0             	mov    -0x10(%ebp),%eax
 723:	8b 00                	mov    (%eax),%eax
 725:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 728:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72b:	8b 40 04             	mov    0x4(%eax),%eax
 72e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 731:	77 4d                	ja     780 <malloc+0xa6>
      if(p->s.size == nunits)
 733:	8b 45 f4             	mov    -0xc(%ebp),%eax
 736:	8b 40 04             	mov    0x4(%eax),%eax
 739:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 73c:	75 0c                	jne    74a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 73e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 741:	8b 10                	mov    (%eax),%edx
 743:	8b 45 f0             	mov    -0x10(%ebp),%eax
 746:	89 10                	mov    %edx,(%eax)
 748:	eb 26                	jmp    770 <malloc+0x96>
      else {
        p->s.size -= nunits;
 74a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74d:	8b 40 04             	mov    0x4(%eax),%eax
 750:	2b 45 ec             	sub    -0x14(%ebp),%eax
 753:	89 c2                	mov    %eax,%edx
 755:	8b 45 f4             	mov    -0xc(%ebp),%eax
 758:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 75b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75e:	8b 40 04             	mov    0x4(%eax),%eax
 761:	c1 e0 03             	shl    $0x3,%eax
 764:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 767:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 76d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 770:	8b 45 f0             	mov    -0x10(%ebp),%eax
 773:	a3 2c 0a 00 00       	mov    %eax,0xa2c
      return (void*)(p + 1);
 778:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77b:	83 c0 08             	add    $0x8,%eax
 77e:	eb 3b                	jmp    7bb <malloc+0xe1>
    }
    if(p == freep)
 780:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 785:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 788:	75 1e                	jne    7a8 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 78a:	83 ec 0c             	sub    $0xc,%esp
 78d:	ff 75 ec             	pushl  -0x14(%ebp)
 790:	e8 e5 fe ff ff       	call   67a <morecore>
 795:	83 c4 10             	add    $0x10,%esp
 798:	89 45 f4             	mov    %eax,-0xc(%ebp)
 79b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79f:	75 07                	jne    7a8 <malloc+0xce>
        return 0;
 7a1:	b8 00 00 00 00       	mov    $0x0,%eax
 7a6:	eb 13                	jmp    7bb <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b6:	e9 6d ff ff ff       	jmp    728 <malloc+0x4e>
  }
}
 7bb:	c9                   	leave  
 7bc:	c3                   	ret    
