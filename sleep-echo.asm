
_sleep-echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
    int i = 0;
  14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	sleep(500);
  1b:	83 ec 0c             	sub    $0xc,%esp
  1e:	68 f4 01 00 00       	push   $0x1f4
  23:	e8 46 03 00 00       	call   36e <sleep>
  28:	83 c4 10             	add    $0x10,%esp
    
    for (i = 1; i < argc; i++)
  2b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  32:	eb 35                	jmp    69 <main+0x69>
    {
        printf(1, argv[i]);
  34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3e:	8b 43 04             	mov    0x4(%ebx),%eax
  41:	01 d0                	add    %edx,%eax
  43:	8b 00                	mov    (%eax),%eax
  45:	83 ec 08             	sub    $0x8,%esp
  48:	50                   	push   %eax
  49:	6a 01                	push   $0x1
  4b:	e8 11 04 00 00       	call   461 <printf>
  50:	83 c4 10             	add    $0x10,%esp
        printf(1, " ");
  53:	83 ec 08             	sub    $0x8,%esp
  56:	68 17 08 00 00       	push   $0x817
  5b:	6a 01                	push   $0x1
  5d:	e8 ff 03 00 00       	call   461 <printf>
  62:	83 c4 10             	add    $0x10,%esp
    for (i = 1; i < argc; i++)
  65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6c:	3b 03                	cmp    (%ebx),%eax
  6e:	7c c4                	jl     34 <main+0x34>
    }

    printf(1, "\n");
  70:	83 ec 08             	sub    $0x8,%esp
  73:	68 19 08 00 00       	push   $0x819
  78:	6a 01                	push   $0x1
  7a:	e8 e2 03 00 00       	call   461 <printf>
  7f:	83 c4 10             	add    $0x10,%esp
    
    exit();
  82:	e8 57 02 00 00       	call   2de <exit>

00000087 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  87:	55                   	push   %ebp
  88:	89 e5                	mov    %esp,%ebp
  8a:	57                   	push   %edi
  8b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8f:	8b 55 10             	mov    0x10(%ebp),%edx
  92:	8b 45 0c             	mov    0xc(%ebp),%eax
  95:	89 cb                	mov    %ecx,%ebx
  97:	89 df                	mov    %ebx,%edi
  99:	89 d1                	mov    %edx,%ecx
  9b:	fc                   	cld    
  9c:	f3 aa                	rep stos %al,%es:(%edi)
  9e:	89 ca                	mov    %ecx,%edx
  a0:	89 fb                	mov    %edi,%ebx
  a2:	89 5d 08             	mov    %ebx,0x8(%ebp)
  a5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  a8:	90                   	nop
  a9:	5b                   	pop    %ebx
  aa:	5f                   	pop    %edi
  ab:	5d                   	pop    %ebp
  ac:	c3                   	ret    

000000ad <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  ad:	55                   	push   %ebp
  ae:	89 e5                	mov    %esp,%ebp
  b0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  b3:	8b 45 08             	mov    0x8(%ebp),%eax
  b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  b9:	90                   	nop
  ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  bd:	8d 42 01             	lea    0x1(%edx),%eax
  c0:	89 45 0c             	mov    %eax,0xc(%ebp)
  c3:	8b 45 08             	mov    0x8(%ebp),%eax
  c6:	8d 48 01             	lea    0x1(%eax),%ecx
  c9:	89 4d 08             	mov    %ecx,0x8(%ebp)
  cc:	0f b6 12             	movzbl (%edx),%edx
  cf:	88 10                	mov    %dl,(%eax)
  d1:	0f b6 00             	movzbl (%eax),%eax
  d4:	84 c0                	test   %al,%al
  d6:	75 e2                	jne    ba <strcpy+0xd>
    ;
  return os;
  d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  db:	c9                   	leave  
  dc:	c3                   	ret    

000000dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dd:	55                   	push   %ebp
  de:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e0:	eb 08                	jmp    ea <strcmp+0xd>
    p++, q++;
  e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  e6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  ea:	8b 45 08             	mov    0x8(%ebp),%eax
  ed:	0f b6 00             	movzbl (%eax),%eax
  f0:	84 c0                	test   %al,%al
  f2:	74 10                	je     104 <strcmp+0x27>
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	0f b6 10             	movzbl (%eax),%edx
  fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  fd:	0f b6 00             	movzbl (%eax),%eax
 100:	38 c2                	cmp    %al,%dl
 102:	74 de                	je     e2 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 104:	8b 45 08             	mov    0x8(%ebp),%eax
 107:	0f b6 00             	movzbl (%eax),%eax
 10a:	0f b6 d0             	movzbl %al,%edx
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	0f b6 00             	movzbl (%eax),%eax
 113:	0f b6 c0             	movzbl %al,%eax
 116:	29 c2                	sub    %eax,%edx
 118:	89 d0                	mov    %edx,%eax
}
 11a:	5d                   	pop    %ebp
 11b:	c3                   	ret    

0000011c <strlen>:

uint
strlen(char *s)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 122:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 129:	eb 04                	jmp    12f <strlen+0x13>
 12b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 12f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 132:	8b 45 08             	mov    0x8(%ebp),%eax
 135:	01 d0                	add    %edx,%eax
 137:	0f b6 00             	movzbl (%eax),%eax
 13a:	84 c0                	test   %al,%al
 13c:	75 ed                	jne    12b <strlen+0xf>
    ;
  return n;
 13e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 141:	c9                   	leave  
 142:	c3                   	ret    

00000143 <memset>:

void*
memset(void *dst, int c, uint n)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 146:	8b 45 10             	mov    0x10(%ebp),%eax
 149:	50                   	push   %eax
 14a:	ff 75 0c             	pushl  0xc(%ebp)
 14d:	ff 75 08             	pushl  0x8(%ebp)
 150:	e8 32 ff ff ff       	call   87 <stosb>
 155:	83 c4 0c             	add    $0xc,%esp
  return dst;
 158:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15b:	c9                   	leave  
 15c:	c3                   	ret    

0000015d <strchr>:

char*
strchr(const char *s, char c)
{
 15d:	55                   	push   %ebp
 15e:	89 e5                	mov    %esp,%ebp
 160:	83 ec 04             	sub    $0x4,%esp
 163:	8b 45 0c             	mov    0xc(%ebp),%eax
 166:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 169:	eb 14                	jmp    17f <strchr+0x22>
    if(*s == c)
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	0f b6 00             	movzbl (%eax),%eax
 171:	38 45 fc             	cmp    %al,-0x4(%ebp)
 174:	75 05                	jne    17b <strchr+0x1e>
      return (char*)s;
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	eb 13                	jmp    18e <strchr+0x31>
  for(; *s; s++)
 17b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	84 c0                	test   %al,%al
 187:	75 e2                	jne    16b <strchr+0xe>
  return 0;
 189:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18e:	c9                   	leave  
 18f:	c3                   	ret    

00000190 <gets>:

char*
gets(char *buf, int max)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 196:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19d:	eb 42                	jmp    1e1 <gets+0x51>
    cc = read(0, &c, 1);
 19f:	83 ec 04             	sub    $0x4,%esp
 1a2:	6a 01                	push   $0x1
 1a4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a7:	50                   	push   %eax
 1a8:	6a 00                	push   $0x0
 1aa:	e8 47 01 00 00       	call   2f6 <read>
 1af:	83 c4 10             	add    $0x10,%esp
 1b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b9:	7e 33                	jle    1ee <gets+0x5e>
      break;
    buf[i++] = c;
 1bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1be:	8d 50 01             	lea    0x1(%eax),%edx
 1c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1c4:	89 c2                	mov    %eax,%edx
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	01 c2                	add    %eax,%edx
 1cb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cf:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d5:	3c 0a                	cmp    $0xa,%al
 1d7:	74 16                	je     1ef <gets+0x5f>
 1d9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1dd:	3c 0d                	cmp    $0xd,%al
 1df:	74 0e                	je     1ef <gets+0x5f>
  for(i=0; i+1 < max; ){
 1e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e4:	83 c0 01             	add    $0x1,%eax
 1e7:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1ea:	7f b3                	jg     19f <gets+0xf>
 1ec:	eb 01                	jmp    1ef <gets+0x5f>
      break;
 1ee:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	01 d0                	add    %edx,%eax
 1f7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fd:	c9                   	leave  
 1fe:	c3                   	ret    

000001ff <stat>:

int
stat(char *n, struct stat *st)
{
 1ff:	55                   	push   %ebp
 200:	89 e5                	mov    %esp,%ebp
 202:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 205:	83 ec 08             	sub    $0x8,%esp
 208:	6a 00                	push   $0x0
 20a:	ff 75 08             	pushl  0x8(%ebp)
 20d:	e8 0c 01 00 00       	call   31e <open>
 212:	83 c4 10             	add    $0x10,%esp
 215:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 218:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 21c:	79 07                	jns    225 <stat+0x26>
    return -1;
 21e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 223:	eb 25                	jmp    24a <stat+0x4b>
  r = fstat(fd, st);
 225:	83 ec 08             	sub    $0x8,%esp
 228:	ff 75 0c             	pushl  0xc(%ebp)
 22b:	ff 75 f4             	pushl  -0xc(%ebp)
 22e:	e8 03 01 00 00       	call   336 <fstat>
 233:	83 c4 10             	add    $0x10,%esp
 236:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 239:	83 ec 0c             	sub    $0xc,%esp
 23c:	ff 75 f4             	pushl  -0xc(%ebp)
 23f:	e8 c2 00 00 00       	call   306 <close>
 244:	83 c4 10             	add    $0x10,%esp
  return r;
 247:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 24a:	c9                   	leave  
 24b:	c3                   	ret    

0000024c <atoi>:

int
atoi(const char *s)
{
 24c:	55                   	push   %ebp
 24d:	89 e5                	mov    %esp,%ebp
 24f:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 252:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 259:	eb 25                	jmp    280 <atoi+0x34>
    n = n*10 + *s++ - '0';
 25b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 25e:	89 d0                	mov    %edx,%eax
 260:	c1 e0 02             	shl    $0x2,%eax
 263:	01 d0                	add    %edx,%eax
 265:	01 c0                	add    %eax,%eax
 267:	89 c1                	mov    %eax,%ecx
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	8d 50 01             	lea    0x1(%eax),%edx
 26f:	89 55 08             	mov    %edx,0x8(%ebp)
 272:	0f b6 00             	movzbl (%eax),%eax
 275:	0f be c0             	movsbl %al,%eax
 278:	01 c8                	add    %ecx,%eax
 27a:	83 e8 30             	sub    $0x30,%eax
 27d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	0f b6 00             	movzbl (%eax),%eax
 286:	3c 2f                	cmp    $0x2f,%al
 288:	7e 0a                	jle    294 <atoi+0x48>
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	0f b6 00             	movzbl (%eax),%eax
 290:	3c 39                	cmp    $0x39,%al
 292:	7e c7                	jle    25b <atoi+0xf>
  return n;
 294:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 297:	c9                   	leave  
 298:	c3                   	ret    

00000299 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 29f:	8b 45 08             	mov    0x8(%ebp),%eax
 2a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ab:	eb 17                	jmp    2c4 <memmove+0x2b>
    *dst++ = *src++;
 2ad:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2b0:	8d 42 01             	lea    0x1(%edx),%eax
 2b3:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b9:	8d 48 01             	lea    0x1(%eax),%ecx
 2bc:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2bf:	0f b6 12             	movzbl (%edx),%edx
 2c2:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2c4:	8b 45 10             	mov    0x10(%ebp),%eax
 2c7:	8d 50 ff             	lea    -0x1(%eax),%edx
 2ca:	89 55 10             	mov    %edx,0x10(%ebp)
 2cd:	85 c0                	test   %eax,%eax
 2cf:	7f dc                	jg     2ad <memmove+0x14>
  return vdst;
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d4:	c9                   	leave  
 2d5:	c3                   	ret    

000002d6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2d6:	b8 01 00 00 00       	mov    $0x1,%eax
 2db:	cd 40                	int    $0x40
 2dd:	c3                   	ret    

000002de <exit>:
SYSCALL(exit)
 2de:	b8 02 00 00 00       	mov    $0x2,%eax
 2e3:	cd 40                	int    $0x40
 2e5:	c3                   	ret    

000002e6 <wait>:
SYSCALL(wait)
 2e6:	b8 03 00 00 00       	mov    $0x3,%eax
 2eb:	cd 40                	int    $0x40
 2ed:	c3                   	ret    

000002ee <pipe>:
SYSCALL(pipe)
 2ee:	b8 04 00 00 00       	mov    $0x4,%eax
 2f3:	cd 40                	int    $0x40
 2f5:	c3                   	ret    

000002f6 <read>:
SYSCALL(read)
 2f6:	b8 05 00 00 00       	mov    $0x5,%eax
 2fb:	cd 40                	int    $0x40
 2fd:	c3                   	ret    

000002fe <write>:
SYSCALL(write)
 2fe:	b8 10 00 00 00       	mov    $0x10,%eax
 303:	cd 40                	int    $0x40
 305:	c3                   	ret    

00000306 <close>:
SYSCALL(close)
 306:	b8 15 00 00 00       	mov    $0x15,%eax
 30b:	cd 40                	int    $0x40
 30d:	c3                   	ret    

0000030e <kill>:
SYSCALL(kill)
 30e:	b8 06 00 00 00       	mov    $0x6,%eax
 313:	cd 40                	int    $0x40
 315:	c3                   	ret    

00000316 <exec>:
SYSCALL(exec)
 316:	b8 07 00 00 00       	mov    $0x7,%eax
 31b:	cd 40                	int    $0x40
 31d:	c3                   	ret    

0000031e <open>:
SYSCALL(open)
 31e:	b8 0f 00 00 00       	mov    $0xf,%eax
 323:	cd 40                	int    $0x40
 325:	c3                   	ret    

00000326 <mknod>:
SYSCALL(mknod)
 326:	b8 11 00 00 00       	mov    $0x11,%eax
 32b:	cd 40                	int    $0x40
 32d:	c3                   	ret    

0000032e <unlink>:
SYSCALL(unlink)
 32e:	b8 12 00 00 00       	mov    $0x12,%eax
 333:	cd 40                	int    $0x40
 335:	c3                   	ret    

00000336 <fstat>:
SYSCALL(fstat)
 336:	b8 08 00 00 00       	mov    $0x8,%eax
 33b:	cd 40                	int    $0x40
 33d:	c3                   	ret    

0000033e <link>:
SYSCALL(link)
 33e:	b8 13 00 00 00       	mov    $0x13,%eax
 343:	cd 40                	int    $0x40
 345:	c3                   	ret    

00000346 <mkdir>:
SYSCALL(mkdir)
 346:	b8 14 00 00 00       	mov    $0x14,%eax
 34b:	cd 40                	int    $0x40
 34d:	c3                   	ret    

0000034e <chdir>:
SYSCALL(chdir)
 34e:	b8 09 00 00 00       	mov    $0x9,%eax
 353:	cd 40                	int    $0x40
 355:	c3                   	ret    

00000356 <dup>:
SYSCALL(dup)
 356:	b8 0a 00 00 00       	mov    $0xa,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret    

0000035e <getpid>:
SYSCALL(getpid)
 35e:	b8 0b 00 00 00       	mov    $0xb,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret    

00000366 <sbrk>:
SYSCALL(sbrk)
 366:	b8 0c 00 00 00       	mov    $0xc,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret    

0000036e <sleep>:
SYSCALL(sleep)
 36e:	b8 0d 00 00 00       	mov    $0xd,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <uptime>:
SYSCALL(uptime)
 376:	b8 0e 00 00 00       	mov    $0xe,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <enable_sched_trace>:
SYSCALL(enable_sched_trace)
 37e:	b8 16 00 00 00       	mov    $0x16,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <uprog_shut>:
SYSCALL(uprog_shut)
 386:	b8 17 00 00 00       	mov    $0x17,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 38e:	55                   	push   %ebp
 38f:	89 e5                	mov    %esp,%ebp
 391:	83 ec 18             	sub    $0x18,%esp
 394:	8b 45 0c             	mov    0xc(%ebp),%eax
 397:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 39a:	83 ec 04             	sub    $0x4,%esp
 39d:	6a 01                	push   $0x1
 39f:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3a2:	50                   	push   %eax
 3a3:	ff 75 08             	pushl  0x8(%ebp)
 3a6:	e8 53 ff ff ff       	call   2fe <write>
 3ab:	83 c4 10             	add    $0x10,%esp
}
 3ae:	90                   	nop
 3af:	c9                   	leave  
 3b0:	c3                   	ret    

000003b1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
 3b4:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3be:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c2:	74 17                	je     3db <printint+0x2a>
 3c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3c8:	79 11                	jns    3db <printint+0x2a>
    neg = 1;
 3ca:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d4:	f7 d8                	neg    %eax
 3d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d9:	eb 06                	jmp    3e1 <printint+0x30>
  } else {
    x = xx;
 3db:	8b 45 0c             	mov    0xc(%ebp),%eax
 3de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ee:	ba 00 00 00 00       	mov    $0x0,%edx
 3f3:	f7 f1                	div    %ecx
 3f5:	89 d1                	mov    %edx,%ecx
 3f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fa:	8d 50 01             	lea    0x1(%eax),%edx
 3fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 400:	0f b6 91 6c 0a 00 00 	movzbl 0xa6c(%ecx),%edx
 407:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 40b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 40e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 411:	ba 00 00 00 00       	mov    $0x0,%edx
 416:	f7 f1                	div    %ecx
 418:	89 45 ec             	mov    %eax,-0x14(%ebp)
 41b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 41f:	75 c7                	jne    3e8 <printint+0x37>
  if(neg)
 421:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 425:	74 2d                	je     454 <printint+0xa3>
    buf[i++] = '-';
 427:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42a:	8d 50 01             	lea    0x1(%eax),%edx
 42d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 430:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 435:	eb 1d                	jmp    454 <printint+0xa3>
    putc(fd, buf[i]);
 437:	8d 55 dc             	lea    -0x24(%ebp),%edx
 43a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43d:	01 d0                	add    %edx,%eax
 43f:	0f b6 00             	movzbl (%eax),%eax
 442:	0f be c0             	movsbl %al,%eax
 445:	83 ec 08             	sub    $0x8,%esp
 448:	50                   	push   %eax
 449:	ff 75 08             	pushl  0x8(%ebp)
 44c:	e8 3d ff ff ff       	call   38e <putc>
 451:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 454:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 458:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45c:	79 d9                	jns    437 <printint+0x86>
}
 45e:	90                   	nop
 45f:	c9                   	leave  
 460:	c3                   	ret    

00000461 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 461:	55                   	push   %ebp
 462:	89 e5                	mov    %esp,%ebp
 464:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 467:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 46e:	8d 45 0c             	lea    0xc(%ebp),%eax
 471:	83 c0 04             	add    $0x4,%eax
 474:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 477:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 47e:	e9 59 01 00 00       	jmp    5dc <printf+0x17b>
    c = fmt[i] & 0xff;
 483:	8b 55 0c             	mov    0xc(%ebp),%edx
 486:	8b 45 f0             	mov    -0x10(%ebp),%eax
 489:	01 d0                	add    %edx,%eax
 48b:	0f b6 00             	movzbl (%eax),%eax
 48e:	0f be c0             	movsbl %al,%eax
 491:	25 ff 00 00 00       	and    $0xff,%eax
 496:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 499:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 49d:	75 2c                	jne    4cb <printf+0x6a>
      if(c == '%'){
 49f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4a3:	75 0c                	jne    4b1 <printf+0x50>
        state = '%';
 4a5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ac:	e9 27 01 00 00       	jmp    5d8 <printf+0x177>
      } else {
        putc(fd, c);
 4b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b4:	0f be c0             	movsbl %al,%eax
 4b7:	83 ec 08             	sub    $0x8,%esp
 4ba:	50                   	push   %eax
 4bb:	ff 75 08             	pushl  0x8(%ebp)
 4be:	e8 cb fe ff ff       	call   38e <putc>
 4c3:	83 c4 10             	add    $0x10,%esp
 4c6:	e9 0d 01 00 00       	jmp    5d8 <printf+0x177>
      }
    } else if(state == '%'){
 4cb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4cf:	0f 85 03 01 00 00    	jne    5d8 <printf+0x177>
      if(c == 'd'){
 4d5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4d9:	75 1e                	jne    4f9 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4de:	8b 00                	mov    (%eax),%eax
 4e0:	6a 01                	push   $0x1
 4e2:	6a 0a                	push   $0xa
 4e4:	50                   	push   %eax
 4e5:	ff 75 08             	pushl  0x8(%ebp)
 4e8:	e8 c4 fe ff ff       	call   3b1 <printint>
 4ed:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f4:	e9 d8 00 00 00       	jmp    5d1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4f9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4fd:	74 06                	je     505 <printf+0xa4>
 4ff:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 503:	75 1e                	jne    523 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 505:	8b 45 e8             	mov    -0x18(%ebp),%eax
 508:	8b 00                	mov    (%eax),%eax
 50a:	6a 00                	push   $0x0
 50c:	6a 10                	push   $0x10
 50e:	50                   	push   %eax
 50f:	ff 75 08             	pushl  0x8(%ebp)
 512:	e8 9a fe ff ff       	call   3b1 <printint>
 517:	83 c4 10             	add    $0x10,%esp
        ap++;
 51a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51e:	e9 ae 00 00 00       	jmp    5d1 <printf+0x170>
      } else if(c == 's'){
 523:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 527:	75 43                	jne    56c <printf+0x10b>
        s = (char*)*ap;
 529:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52c:	8b 00                	mov    (%eax),%eax
 52e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 531:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 535:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 539:	75 25                	jne    560 <printf+0xff>
          s = "(null)";
 53b:	c7 45 f4 1b 08 00 00 	movl   $0x81b,-0xc(%ebp)
        while(*s != 0){
 542:	eb 1c                	jmp    560 <printf+0xff>
          putc(fd, *s);
 544:	8b 45 f4             	mov    -0xc(%ebp),%eax
 547:	0f b6 00             	movzbl (%eax),%eax
 54a:	0f be c0             	movsbl %al,%eax
 54d:	83 ec 08             	sub    $0x8,%esp
 550:	50                   	push   %eax
 551:	ff 75 08             	pushl  0x8(%ebp)
 554:	e8 35 fe ff ff       	call   38e <putc>
 559:	83 c4 10             	add    $0x10,%esp
          s++;
 55c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 560:	8b 45 f4             	mov    -0xc(%ebp),%eax
 563:	0f b6 00             	movzbl (%eax),%eax
 566:	84 c0                	test   %al,%al
 568:	75 da                	jne    544 <printf+0xe3>
 56a:	eb 65                	jmp    5d1 <printf+0x170>
        }
      } else if(c == 'c'){
 56c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 570:	75 1d                	jne    58f <printf+0x12e>
        putc(fd, *ap);
 572:	8b 45 e8             	mov    -0x18(%ebp),%eax
 575:	8b 00                	mov    (%eax),%eax
 577:	0f be c0             	movsbl %al,%eax
 57a:	83 ec 08             	sub    $0x8,%esp
 57d:	50                   	push   %eax
 57e:	ff 75 08             	pushl  0x8(%ebp)
 581:	e8 08 fe ff ff       	call   38e <putc>
 586:	83 c4 10             	add    $0x10,%esp
        ap++;
 589:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58d:	eb 42                	jmp    5d1 <printf+0x170>
      } else if(c == '%'){
 58f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 593:	75 17                	jne    5ac <printf+0x14b>
        putc(fd, c);
 595:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 598:	0f be c0             	movsbl %al,%eax
 59b:	83 ec 08             	sub    $0x8,%esp
 59e:	50                   	push   %eax
 59f:	ff 75 08             	pushl  0x8(%ebp)
 5a2:	e8 e7 fd ff ff       	call   38e <putc>
 5a7:	83 c4 10             	add    $0x10,%esp
 5aa:	eb 25                	jmp    5d1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ac:	83 ec 08             	sub    $0x8,%esp
 5af:	6a 25                	push   $0x25
 5b1:	ff 75 08             	pushl  0x8(%ebp)
 5b4:	e8 d5 fd ff ff       	call   38e <putc>
 5b9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5bf:	0f be c0             	movsbl %al,%eax
 5c2:	83 ec 08             	sub    $0x8,%esp
 5c5:	50                   	push   %eax
 5c6:	ff 75 08             	pushl  0x8(%ebp)
 5c9:	e8 c0 fd ff ff       	call   38e <putc>
 5ce:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5d1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5d8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5dc:	8b 55 0c             	mov    0xc(%ebp),%edx
 5df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e2:	01 d0                	add    %edx,%eax
 5e4:	0f b6 00             	movzbl (%eax),%eax
 5e7:	84 c0                	test   %al,%al
 5e9:	0f 85 94 fe ff ff    	jne    483 <printf+0x22>
    }
  }
}
 5ef:	90                   	nop
 5f0:	c9                   	leave  
 5f1:	c3                   	ret    

000005f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f2:	55                   	push   %ebp
 5f3:	89 e5                	mov    %esp,%ebp
 5f5:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5f8:	8b 45 08             	mov    0x8(%ebp),%eax
 5fb:	83 e8 08             	sub    $0x8,%eax
 5fe:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 601:	a1 88 0a 00 00       	mov    0xa88,%eax
 606:	89 45 fc             	mov    %eax,-0x4(%ebp)
 609:	eb 24                	jmp    62f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 60b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60e:	8b 00                	mov    (%eax),%eax
 610:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 613:	72 12                	jb     627 <free+0x35>
 615:	8b 45 f8             	mov    -0x8(%ebp),%eax
 618:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61b:	77 24                	ja     641 <free+0x4f>
 61d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 620:	8b 00                	mov    (%eax),%eax
 622:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 625:	72 1a                	jb     641 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 627:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62a:	8b 00                	mov    (%eax),%eax
 62c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 62f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 632:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 635:	76 d4                	jbe    60b <free+0x19>
 637:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63a:	8b 00                	mov    (%eax),%eax
 63c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 63f:	73 ca                	jae    60b <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 641:	8b 45 f8             	mov    -0x8(%ebp),%eax
 644:	8b 40 04             	mov    0x4(%eax),%eax
 647:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 64e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 651:	01 c2                	add    %eax,%edx
 653:	8b 45 fc             	mov    -0x4(%ebp),%eax
 656:	8b 00                	mov    (%eax),%eax
 658:	39 c2                	cmp    %eax,%edx
 65a:	75 24                	jne    680 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 65c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65f:	8b 50 04             	mov    0x4(%eax),%edx
 662:	8b 45 fc             	mov    -0x4(%ebp),%eax
 665:	8b 00                	mov    (%eax),%eax
 667:	8b 40 04             	mov    0x4(%eax),%eax
 66a:	01 c2                	add    %eax,%edx
 66c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 672:	8b 45 fc             	mov    -0x4(%ebp),%eax
 675:	8b 00                	mov    (%eax),%eax
 677:	8b 10                	mov    (%eax),%edx
 679:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67c:	89 10                	mov    %edx,(%eax)
 67e:	eb 0a                	jmp    68a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	8b 10                	mov    (%eax),%edx
 685:	8b 45 f8             	mov    -0x8(%ebp),%eax
 688:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 40 04             	mov    0x4(%eax),%eax
 690:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	01 d0                	add    %edx,%eax
 69c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 69f:	75 20                	jne    6c1 <free+0xcf>
    p->s.size += bp->s.size;
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 50 04             	mov    0x4(%eax),%edx
 6a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6aa:	8b 40 04             	mov    0x4(%eax),%eax
 6ad:	01 c2                	add    %eax,%edx
 6af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b8:	8b 10                	mov    (%eax),%edx
 6ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bd:	89 10                	mov    %edx,(%eax)
 6bf:	eb 08                	jmp    6c9 <free+0xd7>
  } else
    p->s.ptr = bp;
 6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c7:	89 10                	mov    %edx,(%eax)
  freep = p;
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	a3 88 0a 00 00       	mov    %eax,0xa88
}
 6d1:	90                   	nop
 6d2:	c9                   	leave  
 6d3:	c3                   	ret    

000006d4 <morecore>:

static Header*
morecore(uint nu)
{
 6d4:	55                   	push   %ebp
 6d5:	89 e5                	mov    %esp,%ebp
 6d7:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6da:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e1:	77 07                	ja     6ea <morecore+0x16>
    nu = 4096;
 6e3:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6ea:	8b 45 08             	mov    0x8(%ebp),%eax
 6ed:	c1 e0 03             	shl    $0x3,%eax
 6f0:	83 ec 0c             	sub    $0xc,%esp
 6f3:	50                   	push   %eax
 6f4:	e8 6d fc ff ff       	call   366 <sbrk>
 6f9:	83 c4 10             	add    $0x10,%esp
 6fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6ff:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 703:	75 07                	jne    70c <morecore+0x38>
    return 0;
 705:	b8 00 00 00 00       	mov    $0x0,%eax
 70a:	eb 26                	jmp    732 <morecore+0x5e>
  hp = (Header*)p;
 70c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 712:	8b 45 f0             	mov    -0x10(%ebp),%eax
 715:	8b 55 08             	mov    0x8(%ebp),%edx
 718:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 71b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71e:	83 c0 08             	add    $0x8,%eax
 721:	83 ec 0c             	sub    $0xc,%esp
 724:	50                   	push   %eax
 725:	e8 c8 fe ff ff       	call   5f2 <free>
 72a:	83 c4 10             	add    $0x10,%esp
  return freep;
 72d:	a1 88 0a 00 00       	mov    0xa88,%eax
}
 732:	c9                   	leave  
 733:	c3                   	ret    

00000734 <malloc>:

void*
malloc(uint nbytes)
{
 734:	55                   	push   %ebp
 735:	89 e5                	mov    %esp,%ebp
 737:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73a:	8b 45 08             	mov    0x8(%ebp),%eax
 73d:	83 c0 07             	add    $0x7,%eax
 740:	c1 e8 03             	shr    $0x3,%eax
 743:	83 c0 01             	add    $0x1,%eax
 746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 749:	a1 88 0a 00 00       	mov    0xa88,%eax
 74e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 751:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 755:	75 23                	jne    77a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 757:	c7 45 f0 80 0a 00 00 	movl   $0xa80,-0x10(%ebp)
 75e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 761:	a3 88 0a 00 00       	mov    %eax,0xa88
 766:	a1 88 0a 00 00       	mov    0xa88,%eax
 76b:	a3 80 0a 00 00       	mov    %eax,0xa80
    base.s.size = 0;
 770:	c7 05 84 0a 00 00 00 	movl   $0x0,0xa84
 777:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77d:	8b 00                	mov    (%eax),%eax
 77f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 782:	8b 45 f4             	mov    -0xc(%ebp),%eax
 785:	8b 40 04             	mov    0x4(%eax),%eax
 788:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 78b:	77 4d                	ja     7da <malloc+0xa6>
      if(p->s.size == nunits)
 78d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 790:	8b 40 04             	mov    0x4(%eax),%eax
 793:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 796:	75 0c                	jne    7a4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	8b 10                	mov    (%eax),%edx
 79d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a0:	89 10                	mov    %edx,(%eax)
 7a2:	eb 26                	jmp    7ca <malloc+0x96>
      else {
        p->s.size -= nunits;
 7a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a7:	8b 40 04             	mov    0x4(%eax),%eax
 7aa:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7ad:	89 c2                	mov    %eax,%edx
 7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b8:	8b 40 04             	mov    0x4(%eax),%eax
 7bb:	c1 e0 03             	shl    $0x3,%eax
 7be:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7c7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cd:	a3 88 0a 00 00       	mov    %eax,0xa88
      return (void*)(p + 1);
 7d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d5:	83 c0 08             	add    $0x8,%eax
 7d8:	eb 3b                	jmp    815 <malloc+0xe1>
    }
    if(p == freep)
 7da:	a1 88 0a 00 00       	mov    0xa88,%eax
 7df:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e2:	75 1e                	jne    802 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7e4:	83 ec 0c             	sub    $0xc,%esp
 7e7:	ff 75 ec             	pushl  -0x14(%ebp)
 7ea:	e8 e5 fe ff ff       	call   6d4 <morecore>
 7ef:	83 c4 10             	add    $0x10,%esp
 7f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f9:	75 07                	jne    802 <malloc+0xce>
        return 0;
 7fb:	b8 00 00 00 00       	mov    $0x0,%eax
 800:	eb 13                	jmp    815 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	8b 45 f4             	mov    -0xc(%ebp),%eax
 805:	89 45 f0             	mov    %eax,-0x10(%ebp)
 808:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80b:	8b 00                	mov    (%eax),%eax
 80d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 810:	e9 6d ff ff ff       	jmp    782 <malloc+0x4e>
  }
}
 815:	c9                   	leave  
 816:	c3                   	ret    
