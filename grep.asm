
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
   d:	e9 ae 00 00 00       	jmp    c0 <grep+0xc0>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    buf[m] = '\0';
  18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1b:	05 00 0e 00 00       	add    $0xe00,%eax
  20:	c6 00 00             	movb   $0x0,(%eax)
    p = buf;
  23:	c7 45 f0 00 0e 00 00 	movl   $0xe00,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  2a:	eb 44                	jmp    70 <grep+0x70>
      *q = 0;
  2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  2f:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  32:	83 ec 08             	sub    $0x8,%esp
  35:	ff 75 f0             	pushl  -0x10(%ebp)
  38:	ff 75 08             	pushl  0x8(%ebp)
  3b:	e8 92 01 00 00       	call   1d2 <match>
  40:	83 c4 10             	add    $0x10,%esp
  43:	85 c0                	test   %eax,%eax
  45:	74 20                	je     67 <grep+0x67>
        *q = '\n';
  47:	8b 45 e8             	mov    -0x18(%ebp),%eax
  4a:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  50:	83 c0 01             	add    $0x1,%eax
  53:	2b 45 f0             	sub    -0x10(%ebp),%eax
  56:	83 ec 04             	sub    $0x4,%esp
  59:	50                   	push   %eax
  5a:	ff 75 f0             	pushl  -0x10(%ebp)
  5d:	6a 01                	push   $0x1
  5f:	e8 41 05 00 00       	call   5a5 <write>
  64:	83 c4 10             	add    $0x10,%esp
      }
      p = q+1;
  67:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6a:	83 c0 01             	add    $0x1,%eax
  6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  70:	83 ec 08             	sub    $0x8,%esp
  73:	6a 0a                	push   $0xa
  75:	ff 75 f0             	pushl  -0x10(%ebp)
  78:	e8 87 03 00 00       	call   404 <strchr>
  7d:	83 c4 10             	add    $0x10,%esp
  80:	89 45 e8             	mov    %eax,-0x18(%ebp)
  83:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  87:	75 a3                	jne    2c <grep+0x2c>
    }
    if(p == buf)
  89:	81 7d f0 00 0e 00 00 	cmpl   $0xe00,-0x10(%ebp)
  90:	75 07                	jne    99 <grep+0x99>
      m = 0;
  92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  9d:	7e 21                	jle    c0 <grep+0xc0>
      m -= p - buf;
  9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  a2:	2d 00 0e 00 00       	sub    $0xe00,%eax
  a7:	29 45 f4             	sub    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  aa:	83 ec 04             	sub    $0x4,%esp
  ad:	ff 75 f4             	pushl  -0xc(%ebp)
  b0:	ff 75 f0             	pushl  -0x10(%ebp)
  b3:	68 00 0e 00 00       	push   $0xe00
  b8:	e8 83 04 00 00       	call   540 <memmove>
  bd:	83 c4 10             	add    $0x10,%esp
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
  c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c3:	ba ff 03 00 00       	mov    $0x3ff,%edx
  c8:	29 c2                	sub    %eax,%edx
  ca:	89 d0                	mov    %edx,%eax
  cc:	89 c2                	mov    %eax,%edx
  ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d1:	05 00 0e 00 00       	add    $0xe00,%eax
  d6:	83 ec 04             	sub    $0x4,%esp
  d9:	52                   	push   %edx
  da:	50                   	push   %eax
  db:	ff 75 0c             	pushl  0xc(%ebp)
  de:	e8 ba 04 00 00       	call   59d <read>
  e3:	83 c4 10             	add    $0x10,%esp
  e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  ed:	0f 8f 1f ff ff ff    	jg     12 <grep+0x12>
    }
  }
}
  f3:	90                   	nop
  f4:	c9                   	leave  
  f5:	c3                   	ret    

000000f6 <main>:

int
main(int argc, char *argv[])
{
  f6:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  fa:	83 e4 f0             	and    $0xfffffff0,%esp
  fd:	ff 71 fc             	pushl  -0x4(%ecx)
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	53                   	push   %ebx
 104:	51                   	push   %ecx
 105:	83 ec 10             	sub    $0x10,%esp
 108:	89 cb                	mov    %ecx,%ebx
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 10a:	83 3b 01             	cmpl   $0x1,(%ebx)
 10d:	7f 17                	jg     126 <main+0x30>
    printf(2, "usage: grep pattern [file ...]\n");
 10f:	83 ec 08             	sub    $0x8,%esp
 112:	68 c0 0a 00 00       	push   $0xac0
 117:	6a 02                	push   $0x2
 119:	e8 ea 05 00 00       	call   708 <printf>
 11e:	83 c4 10             	add    $0x10,%esp
    exit();
 121:	e8 5f 04 00 00       	call   585 <exit>
  }
  pattern = argv[1];
 126:	8b 43 04             	mov    0x4(%ebx),%eax
 129:	8b 40 04             	mov    0x4(%eax),%eax
 12c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  if(argc <= 2){
 12f:	83 3b 02             	cmpl   $0x2,(%ebx)
 132:	7f 15                	jg     149 <main+0x53>
    grep(pattern, 0);
 134:	83 ec 08             	sub    $0x8,%esp
 137:	6a 00                	push   $0x0
 139:	ff 75 f0             	pushl  -0x10(%ebp)
 13c:	e8 bf fe ff ff       	call   0 <grep>
 141:	83 c4 10             	add    $0x10,%esp
    exit();
 144:	e8 3c 04 00 00       	call   585 <exit>
  }

  for(i = 2; i < argc; i++){
 149:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
 150:	eb 74                	jmp    1c6 <main+0xd0>
    if((fd = open(argv[i], 0)) < 0){
 152:	8b 45 f4             	mov    -0xc(%ebp),%eax
 155:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 15c:	8b 43 04             	mov    0x4(%ebx),%eax
 15f:	01 d0                	add    %edx,%eax
 161:	8b 00                	mov    (%eax),%eax
 163:	83 ec 08             	sub    $0x8,%esp
 166:	6a 00                	push   $0x0
 168:	50                   	push   %eax
 169:	e8 57 04 00 00       	call   5c5 <open>
 16e:	83 c4 10             	add    $0x10,%esp
 171:	89 45 ec             	mov    %eax,-0x14(%ebp)
 174:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 178:	79 29                	jns    1a3 <main+0xad>
      printf(1, "grep: cannot open %s\n", argv[i]);
 17a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 184:	8b 43 04             	mov    0x4(%ebx),%eax
 187:	01 d0                	add    %edx,%eax
 189:	8b 00                	mov    (%eax),%eax
 18b:	83 ec 04             	sub    $0x4,%esp
 18e:	50                   	push   %eax
 18f:	68 e0 0a 00 00       	push   $0xae0
 194:	6a 01                	push   $0x1
 196:	e8 6d 05 00 00       	call   708 <printf>
 19b:	83 c4 10             	add    $0x10,%esp
      exit();
 19e:	e8 e2 03 00 00       	call   585 <exit>
    }
    grep(pattern, fd);
 1a3:	83 ec 08             	sub    $0x8,%esp
 1a6:	ff 75 ec             	pushl  -0x14(%ebp)
 1a9:	ff 75 f0             	pushl  -0x10(%ebp)
 1ac:	e8 4f fe ff ff       	call   0 <grep>
 1b1:	83 c4 10             	add    $0x10,%esp
    close(fd);
 1b4:	83 ec 0c             	sub    $0xc,%esp
 1b7:	ff 75 ec             	pushl  -0x14(%ebp)
 1ba:	e8 ee 03 00 00       	call   5ad <close>
 1bf:	83 c4 10             	add    $0x10,%esp
  for(i = 2; i < argc; i++){
 1c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c9:	3b 03                	cmp    (%ebx),%eax
 1cb:	7c 85                	jl     152 <main+0x5c>
  }
  exit();
 1cd:	e8 b3 03 00 00       	call   585 <exit>

000001d2 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	83 ec 08             	sub    $0x8,%esp
  if(re[0] == '^')
 1d8:	8b 45 08             	mov    0x8(%ebp),%eax
 1db:	0f b6 00             	movzbl (%eax),%eax
 1de:	3c 5e                	cmp    $0x5e,%al
 1e0:	75 17                	jne    1f9 <match+0x27>
    return matchhere(re+1, text);
 1e2:	8b 45 08             	mov    0x8(%ebp),%eax
 1e5:	83 c0 01             	add    $0x1,%eax
 1e8:	83 ec 08             	sub    $0x8,%esp
 1eb:	ff 75 0c             	pushl  0xc(%ebp)
 1ee:	50                   	push   %eax
 1ef:	e8 38 00 00 00       	call   22c <matchhere>
 1f4:	83 c4 10             	add    $0x10,%esp
 1f7:	eb 31                	jmp    22a <match+0x58>
  do{  // must look at empty string
    if(matchhere(re, text))
 1f9:	83 ec 08             	sub    $0x8,%esp
 1fc:	ff 75 0c             	pushl  0xc(%ebp)
 1ff:	ff 75 08             	pushl  0x8(%ebp)
 202:	e8 25 00 00 00       	call   22c <matchhere>
 207:	83 c4 10             	add    $0x10,%esp
 20a:	85 c0                	test   %eax,%eax
 20c:	74 07                	je     215 <match+0x43>
      return 1;
 20e:	b8 01 00 00 00       	mov    $0x1,%eax
 213:	eb 15                	jmp    22a <match+0x58>
  }while(*text++ != '\0');
 215:	8b 45 0c             	mov    0xc(%ebp),%eax
 218:	8d 50 01             	lea    0x1(%eax),%edx
 21b:	89 55 0c             	mov    %edx,0xc(%ebp)
 21e:	0f b6 00             	movzbl (%eax),%eax
 221:	84 c0                	test   %al,%al
 223:	75 d4                	jne    1f9 <match+0x27>
  return 0;
 225:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22a:	c9                   	leave  
 22b:	c3                   	ret    

0000022c <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
 22f:	83 ec 08             	sub    $0x8,%esp
  if(re[0] == '\0')
 232:	8b 45 08             	mov    0x8(%ebp),%eax
 235:	0f b6 00             	movzbl (%eax),%eax
 238:	84 c0                	test   %al,%al
 23a:	75 0a                	jne    246 <matchhere+0x1a>
    return 1;
 23c:	b8 01 00 00 00       	mov    $0x1,%eax
 241:	e9 99 00 00 00       	jmp    2df <matchhere+0xb3>
  if(re[1] == '*')
 246:	8b 45 08             	mov    0x8(%ebp),%eax
 249:	83 c0 01             	add    $0x1,%eax
 24c:	0f b6 00             	movzbl (%eax),%eax
 24f:	3c 2a                	cmp    $0x2a,%al
 251:	75 21                	jne    274 <matchhere+0x48>
    return matchstar(re[0], re+2, text);
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	8d 50 02             	lea    0x2(%eax),%edx
 259:	8b 45 08             	mov    0x8(%ebp),%eax
 25c:	0f b6 00             	movzbl (%eax),%eax
 25f:	0f be c0             	movsbl %al,%eax
 262:	83 ec 04             	sub    $0x4,%esp
 265:	ff 75 0c             	pushl  0xc(%ebp)
 268:	52                   	push   %edx
 269:	50                   	push   %eax
 26a:	e8 72 00 00 00       	call   2e1 <matchstar>
 26f:	83 c4 10             	add    $0x10,%esp
 272:	eb 6b                	jmp    2df <matchhere+0xb3>
  if(re[0] == '$' && re[1] == '\0')
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	0f b6 00             	movzbl (%eax),%eax
 27a:	3c 24                	cmp    $0x24,%al
 27c:	75 1d                	jne    29b <matchhere+0x6f>
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
 281:	83 c0 01             	add    $0x1,%eax
 284:	0f b6 00             	movzbl (%eax),%eax
 287:	84 c0                	test   %al,%al
 289:	75 10                	jne    29b <matchhere+0x6f>
    return *text == '\0';
 28b:	8b 45 0c             	mov    0xc(%ebp),%eax
 28e:	0f b6 00             	movzbl (%eax),%eax
 291:	84 c0                	test   %al,%al
 293:	0f 94 c0             	sete   %al
 296:	0f b6 c0             	movzbl %al,%eax
 299:	eb 44                	jmp    2df <matchhere+0xb3>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 29b:	8b 45 0c             	mov    0xc(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	84 c0                	test   %al,%al
 2a3:	74 35                	je     2da <matchhere+0xae>
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	0f b6 00             	movzbl (%eax),%eax
 2ab:	3c 2e                	cmp    $0x2e,%al
 2ad:	74 10                	je     2bf <matchhere+0x93>
 2af:	8b 45 08             	mov    0x8(%ebp),%eax
 2b2:	0f b6 10             	movzbl (%eax),%edx
 2b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	38 c2                	cmp    %al,%dl
 2bd:	75 1b                	jne    2da <matchhere+0xae>
    return matchhere(re+1, text+1);
 2bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c2:	8d 50 01             	lea    0x1(%eax),%edx
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	83 c0 01             	add    $0x1,%eax
 2cb:	83 ec 08             	sub    $0x8,%esp
 2ce:	52                   	push   %edx
 2cf:	50                   	push   %eax
 2d0:	e8 57 ff ff ff       	call   22c <matchhere>
 2d5:	83 c4 10             	add    $0x10,%esp
 2d8:	eb 05                	jmp    2df <matchhere+0xb3>
  return 0;
 2da:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2df:	c9                   	leave  
 2e0:	c3                   	ret    

000002e1 <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 2e1:	55                   	push   %ebp
 2e2:	89 e5                	mov    %esp,%ebp
 2e4:	83 ec 08             	sub    $0x8,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 2e7:	83 ec 08             	sub    $0x8,%esp
 2ea:	ff 75 10             	pushl  0x10(%ebp)
 2ed:	ff 75 0c             	pushl  0xc(%ebp)
 2f0:	e8 37 ff ff ff       	call   22c <matchhere>
 2f5:	83 c4 10             	add    $0x10,%esp
 2f8:	85 c0                	test   %eax,%eax
 2fa:	74 07                	je     303 <matchstar+0x22>
      return 1;
 2fc:	b8 01 00 00 00       	mov    $0x1,%eax
 301:	eb 29                	jmp    32c <matchstar+0x4b>
  }while(*text!='\0' && (*text++==c || c=='.'));
 303:	8b 45 10             	mov    0x10(%ebp),%eax
 306:	0f b6 00             	movzbl (%eax),%eax
 309:	84 c0                	test   %al,%al
 30b:	74 1a                	je     327 <matchstar+0x46>
 30d:	8b 45 10             	mov    0x10(%ebp),%eax
 310:	8d 50 01             	lea    0x1(%eax),%edx
 313:	89 55 10             	mov    %edx,0x10(%ebp)
 316:	0f b6 00             	movzbl (%eax),%eax
 319:	0f be c0             	movsbl %al,%eax
 31c:	39 45 08             	cmp    %eax,0x8(%ebp)
 31f:	74 c6                	je     2e7 <matchstar+0x6>
 321:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 325:	74 c0                	je     2e7 <matchstar+0x6>
  return 0;
 327:	b8 00 00 00 00       	mov    $0x0,%eax
}
 32c:	c9                   	leave  
 32d:	c3                   	ret    

0000032e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 32e:	55                   	push   %ebp
 32f:	89 e5                	mov    %esp,%ebp
 331:	57                   	push   %edi
 332:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 333:	8b 4d 08             	mov    0x8(%ebp),%ecx
 336:	8b 55 10             	mov    0x10(%ebp),%edx
 339:	8b 45 0c             	mov    0xc(%ebp),%eax
 33c:	89 cb                	mov    %ecx,%ebx
 33e:	89 df                	mov    %ebx,%edi
 340:	89 d1                	mov    %edx,%ecx
 342:	fc                   	cld    
 343:	f3 aa                	rep stos %al,%es:(%edi)
 345:	89 ca                	mov    %ecx,%edx
 347:	89 fb                	mov    %edi,%ebx
 349:	89 5d 08             	mov    %ebx,0x8(%ebp)
 34c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 34f:	90                   	nop
 350:	5b                   	pop    %ebx
 351:	5f                   	pop    %edi
 352:	5d                   	pop    %ebp
 353:	c3                   	ret    

00000354 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 35a:	8b 45 08             	mov    0x8(%ebp),%eax
 35d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 360:	90                   	nop
 361:	8b 55 0c             	mov    0xc(%ebp),%edx
 364:	8d 42 01             	lea    0x1(%edx),%eax
 367:	89 45 0c             	mov    %eax,0xc(%ebp)
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
 36d:	8d 48 01             	lea    0x1(%eax),%ecx
 370:	89 4d 08             	mov    %ecx,0x8(%ebp)
 373:	0f b6 12             	movzbl (%edx),%edx
 376:	88 10                	mov    %dl,(%eax)
 378:	0f b6 00             	movzbl (%eax),%eax
 37b:	84 c0                	test   %al,%al
 37d:	75 e2                	jne    361 <strcpy+0xd>
    ;
  return os;
 37f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 382:	c9                   	leave  
 383:	c3                   	ret    

00000384 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 384:	55                   	push   %ebp
 385:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 387:	eb 08                	jmp    391 <strcmp+0xd>
    p++, q++;
 389:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 38d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 391:	8b 45 08             	mov    0x8(%ebp),%eax
 394:	0f b6 00             	movzbl (%eax),%eax
 397:	84 c0                	test   %al,%al
 399:	74 10                	je     3ab <strcmp+0x27>
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	0f b6 10             	movzbl (%eax),%edx
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	0f b6 00             	movzbl (%eax),%eax
 3a7:	38 c2                	cmp    %al,%dl
 3a9:	74 de                	je     389 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	0f b6 00             	movzbl (%eax),%eax
 3b1:	0f b6 d0             	movzbl %al,%edx
 3b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b7:	0f b6 00             	movzbl (%eax),%eax
 3ba:	0f b6 c0             	movzbl %al,%eax
 3bd:	29 c2                	sub    %eax,%edx
 3bf:	89 d0                	mov    %edx,%eax
}
 3c1:	5d                   	pop    %ebp
 3c2:	c3                   	ret    

000003c3 <strlen>:

uint
strlen(char *s)
{
 3c3:	55                   	push   %ebp
 3c4:	89 e5                	mov    %esp,%ebp
 3c6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3d0:	eb 04                	jmp    3d6 <strlen+0x13>
 3d2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3d9:	8b 45 08             	mov    0x8(%ebp),%eax
 3dc:	01 d0                	add    %edx,%eax
 3de:	0f b6 00             	movzbl (%eax),%eax
 3e1:	84 c0                	test   %al,%al
 3e3:	75 ed                	jne    3d2 <strlen+0xf>
    ;
  return n;
 3e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3e8:	c9                   	leave  
 3e9:	c3                   	ret    

000003ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 3ea:	55                   	push   %ebp
 3eb:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3ed:	8b 45 10             	mov    0x10(%ebp),%eax
 3f0:	50                   	push   %eax
 3f1:	ff 75 0c             	pushl  0xc(%ebp)
 3f4:	ff 75 08             	pushl  0x8(%ebp)
 3f7:	e8 32 ff ff ff       	call   32e <stosb>
 3fc:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
}
 402:	c9                   	leave  
 403:	c3                   	ret    

00000404 <strchr>:

char*
strchr(const char *s, char c)
{
 404:	55                   	push   %ebp
 405:	89 e5                	mov    %esp,%ebp
 407:	83 ec 04             	sub    $0x4,%esp
 40a:	8b 45 0c             	mov    0xc(%ebp),%eax
 40d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 410:	eb 14                	jmp    426 <strchr+0x22>
    if(*s == c)
 412:	8b 45 08             	mov    0x8(%ebp),%eax
 415:	0f b6 00             	movzbl (%eax),%eax
 418:	38 45 fc             	cmp    %al,-0x4(%ebp)
 41b:	75 05                	jne    422 <strchr+0x1e>
      return (char*)s;
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
 420:	eb 13                	jmp    435 <strchr+0x31>
  for(; *s; s++)
 422:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 426:	8b 45 08             	mov    0x8(%ebp),%eax
 429:	0f b6 00             	movzbl (%eax),%eax
 42c:	84 c0                	test   %al,%al
 42e:	75 e2                	jne    412 <strchr+0xe>
  return 0;
 430:	b8 00 00 00 00       	mov    $0x0,%eax
}
 435:	c9                   	leave  
 436:	c3                   	ret    

00000437 <gets>:

char*
gets(char *buf, int max)
{
 437:	55                   	push   %ebp
 438:	89 e5                	mov    %esp,%ebp
 43a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 43d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 444:	eb 42                	jmp    488 <gets+0x51>
    cc = read(0, &c, 1);
 446:	83 ec 04             	sub    $0x4,%esp
 449:	6a 01                	push   $0x1
 44b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 44e:	50                   	push   %eax
 44f:	6a 00                	push   $0x0
 451:	e8 47 01 00 00       	call   59d <read>
 456:	83 c4 10             	add    $0x10,%esp
 459:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 45c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 460:	7e 33                	jle    495 <gets+0x5e>
      break;
    buf[i++] = c;
 462:	8b 45 f4             	mov    -0xc(%ebp),%eax
 465:	8d 50 01             	lea    0x1(%eax),%edx
 468:	89 55 f4             	mov    %edx,-0xc(%ebp)
 46b:	89 c2                	mov    %eax,%edx
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	01 c2                	add    %eax,%edx
 472:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 476:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 478:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 47c:	3c 0a                	cmp    $0xa,%al
 47e:	74 16                	je     496 <gets+0x5f>
 480:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 484:	3c 0d                	cmp    $0xd,%al
 486:	74 0e                	je     496 <gets+0x5f>
  for(i=0; i+1 < max; ){
 488:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48b:	83 c0 01             	add    $0x1,%eax
 48e:	39 45 0c             	cmp    %eax,0xc(%ebp)
 491:	7f b3                	jg     446 <gets+0xf>
 493:	eb 01                	jmp    496 <gets+0x5f>
      break;
 495:	90                   	nop
      break;
  }
  buf[i] = '\0';
 496:	8b 55 f4             	mov    -0xc(%ebp),%edx
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	01 d0                	add    %edx,%eax
 49e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4a4:	c9                   	leave  
 4a5:	c3                   	ret    

000004a6 <stat>:

int
stat(char *n, struct stat *st)
{
 4a6:	55                   	push   %ebp
 4a7:	89 e5                	mov    %esp,%ebp
 4a9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4ac:	83 ec 08             	sub    $0x8,%esp
 4af:	6a 00                	push   $0x0
 4b1:	ff 75 08             	pushl  0x8(%ebp)
 4b4:	e8 0c 01 00 00       	call   5c5 <open>
 4b9:	83 c4 10             	add    $0x10,%esp
 4bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c3:	79 07                	jns    4cc <stat+0x26>
    return -1;
 4c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4ca:	eb 25                	jmp    4f1 <stat+0x4b>
  r = fstat(fd, st);
 4cc:	83 ec 08             	sub    $0x8,%esp
 4cf:	ff 75 0c             	pushl  0xc(%ebp)
 4d2:	ff 75 f4             	pushl  -0xc(%ebp)
 4d5:	e8 03 01 00 00       	call   5dd <fstat>
 4da:	83 c4 10             	add    $0x10,%esp
 4dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4e0:	83 ec 0c             	sub    $0xc,%esp
 4e3:	ff 75 f4             	pushl  -0xc(%ebp)
 4e6:	e8 c2 00 00 00       	call   5ad <close>
 4eb:	83 c4 10             	add    $0x10,%esp
  return r;
 4ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4f1:	c9                   	leave  
 4f2:	c3                   	ret    

000004f3 <atoi>:

int
atoi(const char *s)
{
 4f3:	55                   	push   %ebp
 4f4:	89 e5                	mov    %esp,%ebp
 4f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 500:	eb 25                	jmp    527 <atoi+0x34>
    n = n*10 + *s++ - '0';
 502:	8b 55 fc             	mov    -0x4(%ebp),%edx
 505:	89 d0                	mov    %edx,%eax
 507:	c1 e0 02             	shl    $0x2,%eax
 50a:	01 d0                	add    %edx,%eax
 50c:	01 c0                	add    %eax,%eax
 50e:	89 c1                	mov    %eax,%ecx
 510:	8b 45 08             	mov    0x8(%ebp),%eax
 513:	8d 50 01             	lea    0x1(%eax),%edx
 516:	89 55 08             	mov    %edx,0x8(%ebp)
 519:	0f b6 00             	movzbl (%eax),%eax
 51c:	0f be c0             	movsbl %al,%eax
 51f:	01 c8                	add    %ecx,%eax
 521:	83 e8 30             	sub    $0x30,%eax
 524:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 527:	8b 45 08             	mov    0x8(%ebp),%eax
 52a:	0f b6 00             	movzbl (%eax),%eax
 52d:	3c 2f                	cmp    $0x2f,%al
 52f:	7e 0a                	jle    53b <atoi+0x48>
 531:	8b 45 08             	mov    0x8(%ebp),%eax
 534:	0f b6 00             	movzbl (%eax),%eax
 537:	3c 39                	cmp    $0x39,%al
 539:	7e c7                	jle    502 <atoi+0xf>
  return n;
 53b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 53e:	c9                   	leave  
 53f:	c3                   	ret    

00000540 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 540:	55                   	push   %ebp
 541:	89 e5                	mov    %esp,%ebp
 543:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 546:	8b 45 08             	mov    0x8(%ebp),%eax
 549:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 54c:	8b 45 0c             	mov    0xc(%ebp),%eax
 54f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 552:	eb 17                	jmp    56b <memmove+0x2b>
    *dst++ = *src++;
 554:	8b 55 f8             	mov    -0x8(%ebp),%edx
 557:	8d 42 01             	lea    0x1(%edx),%eax
 55a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 55d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 560:	8d 48 01             	lea    0x1(%eax),%ecx
 563:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 566:	0f b6 12             	movzbl (%edx),%edx
 569:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 56b:	8b 45 10             	mov    0x10(%ebp),%eax
 56e:	8d 50 ff             	lea    -0x1(%eax),%edx
 571:	89 55 10             	mov    %edx,0x10(%ebp)
 574:	85 c0                	test   %eax,%eax
 576:	7f dc                	jg     554 <memmove+0x14>
  return vdst;
 578:	8b 45 08             	mov    0x8(%ebp),%eax
}
 57b:	c9                   	leave  
 57c:	c3                   	ret    

0000057d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 57d:	b8 01 00 00 00       	mov    $0x1,%eax
 582:	cd 40                	int    $0x40
 584:	c3                   	ret    

00000585 <exit>:
SYSCALL(exit)
 585:	b8 02 00 00 00       	mov    $0x2,%eax
 58a:	cd 40                	int    $0x40
 58c:	c3                   	ret    

0000058d <wait>:
SYSCALL(wait)
 58d:	b8 03 00 00 00       	mov    $0x3,%eax
 592:	cd 40                	int    $0x40
 594:	c3                   	ret    

00000595 <pipe>:
SYSCALL(pipe)
 595:	b8 04 00 00 00       	mov    $0x4,%eax
 59a:	cd 40                	int    $0x40
 59c:	c3                   	ret    

0000059d <read>:
SYSCALL(read)
 59d:	b8 05 00 00 00       	mov    $0x5,%eax
 5a2:	cd 40                	int    $0x40
 5a4:	c3                   	ret    

000005a5 <write>:
SYSCALL(write)
 5a5:	b8 10 00 00 00       	mov    $0x10,%eax
 5aa:	cd 40                	int    $0x40
 5ac:	c3                   	ret    

000005ad <close>:
SYSCALL(close)
 5ad:	b8 15 00 00 00       	mov    $0x15,%eax
 5b2:	cd 40                	int    $0x40
 5b4:	c3                   	ret    

000005b5 <kill>:
SYSCALL(kill)
 5b5:	b8 06 00 00 00       	mov    $0x6,%eax
 5ba:	cd 40                	int    $0x40
 5bc:	c3                   	ret    

000005bd <exec>:
SYSCALL(exec)
 5bd:	b8 07 00 00 00       	mov    $0x7,%eax
 5c2:	cd 40                	int    $0x40
 5c4:	c3                   	ret    

000005c5 <open>:
SYSCALL(open)
 5c5:	b8 0f 00 00 00       	mov    $0xf,%eax
 5ca:	cd 40                	int    $0x40
 5cc:	c3                   	ret    

000005cd <mknod>:
SYSCALL(mknod)
 5cd:	b8 11 00 00 00       	mov    $0x11,%eax
 5d2:	cd 40                	int    $0x40
 5d4:	c3                   	ret    

000005d5 <unlink>:
SYSCALL(unlink)
 5d5:	b8 12 00 00 00       	mov    $0x12,%eax
 5da:	cd 40                	int    $0x40
 5dc:	c3                   	ret    

000005dd <fstat>:
SYSCALL(fstat)
 5dd:	b8 08 00 00 00       	mov    $0x8,%eax
 5e2:	cd 40                	int    $0x40
 5e4:	c3                   	ret    

000005e5 <link>:
SYSCALL(link)
 5e5:	b8 13 00 00 00       	mov    $0x13,%eax
 5ea:	cd 40                	int    $0x40
 5ec:	c3                   	ret    

000005ed <mkdir>:
SYSCALL(mkdir)
 5ed:	b8 14 00 00 00       	mov    $0x14,%eax
 5f2:	cd 40                	int    $0x40
 5f4:	c3                   	ret    

000005f5 <chdir>:
SYSCALL(chdir)
 5f5:	b8 09 00 00 00       	mov    $0x9,%eax
 5fa:	cd 40                	int    $0x40
 5fc:	c3                   	ret    

000005fd <dup>:
SYSCALL(dup)
 5fd:	b8 0a 00 00 00       	mov    $0xa,%eax
 602:	cd 40                	int    $0x40
 604:	c3                   	ret    

00000605 <getpid>:
SYSCALL(getpid)
 605:	b8 0b 00 00 00       	mov    $0xb,%eax
 60a:	cd 40                	int    $0x40
 60c:	c3                   	ret    

0000060d <sbrk>:
SYSCALL(sbrk)
 60d:	b8 0c 00 00 00       	mov    $0xc,%eax
 612:	cd 40                	int    $0x40
 614:	c3                   	ret    

00000615 <sleep>:
SYSCALL(sleep)
 615:	b8 0d 00 00 00       	mov    $0xd,%eax
 61a:	cd 40                	int    $0x40
 61c:	c3                   	ret    

0000061d <uptime>:
SYSCALL(uptime)
 61d:	b8 0e 00 00 00       	mov    $0xe,%eax
 622:	cd 40                	int    $0x40
 624:	c3                   	ret    

00000625 <enable_sched_trace>:
SYSCALL(enable_sched_trace)
 625:	b8 16 00 00 00       	mov    $0x16,%eax
 62a:	cd 40                	int    $0x40
 62c:	c3                   	ret    

0000062d <uprog_shut>:
SYSCALL(uprog_shut)
 62d:	b8 17 00 00 00       	mov    $0x17,%eax
 632:	cd 40                	int    $0x40
 634:	c3                   	ret    

00000635 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 635:	55                   	push   %ebp
 636:	89 e5                	mov    %esp,%ebp
 638:	83 ec 18             	sub    $0x18,%esp
 63b:	8b 45 0c             	mov    0xc(%ebp),%eax
 63e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 641:	83 ec 04             	sub    $0x4,%esp
 644:	6a 01                	push   $0x1
 646:	8d 45 f4             	lea    -0xc(%ebp),%eax
 649:	50                   	push   %eax
 64a:	ff 75 08             	pushl  0x8(%ebp)
 64d:	e8 53 ff ff ff       	call   5a5 <write>
 652:	83 c4 10             	add    $0x10,%esp
}
 655:	90                   	nop
 656:	c9                   	leave  
 657:	c3                   	ret    

00000658 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 658:	55                   	push   %ebp
 659:	89 e5                	mov    %esp,%ebp
 65b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 65e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 665:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 669:	74 17                	je     682 <printint+0x2a>
 66b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 66f:	79 11                	jns    682 <printint+0x2a>
    neg = 1;
 671:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 678:	8b 45 0c             	mov    0xc(%ebp),%eax
 67b:	f7 d8                	neg    %eax
 67d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 680:	eb 06                	jmp    688 <printint+0x30>
  } else {
    x = xx;
 682:	8b 45 0c             	mov    0xc(%ebp),%eax
 685:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 68f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 692:	8b 45 ec             	mov    -0x14(%ebp),%eax
 695:	ba 00 00 00 00       	mov    $0x0,%edx
 69a:	f7 f1                	div    %ecx
 69c:	89 d1                	mov    %edx,%ecx
 69e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a1:	8d 50 01             	lea    0x1(%eax),%edx
 6a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6a7:	0f b6 91 c8 0d 00 00 	movzbl 0xdc8(%ecx),%edx
 6ae:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b8:	ba 00 00 00 00       	mov    $0x0,%edx
 6bd:	f7 f1                	div    %ecx
 6bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c6:	75 c7                	jne    68f <printint+0x37>
  if(neg)
 6c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6cc:	74 2d                	je     6fb <printint+0xa3>
    buf[i++] = '-';
 6ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d1:	8d 50 01             	lea    0x1(%eax),%edx
 6d4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6d7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6dc:	eb 1d                	jmp    6fb <printint+0xa3>
    putc(fd, buf[i]);
 6de:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e4:	01 d0                	add    %edx,%eax
 6e6:	0f b6 00             	movzbl (%eax),%eax
 6e9:	0f be c0             	movsbl %al,%eax
 6ec:	83 ec 08             	sub    $0x8,%esp
 6ef:	50                   	push   %eax
 6f0:	ff 75 08             	pushl  0x8(%ebp)
 6f3:	e8 3d ff ff ff       	call   635 <putc>
 6f8:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 703:	79 d9                	jns    6de <printint+0x86>
}
 705:	90                   	nop
 706:	c9                   	leave  
 707:	c3                   	ret    

00000708 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 708:	55                   	push   %ebp
 709:	89 e5                	mov    %esp,%ebp
 70b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 70e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 715:	8d 45 0c             	lea    0xc(%ebp),%eax
 718:	83 c0 04             	add    $0x4,%eax
 71b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 71e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 725:	e9 59 01 00 00       	jmp    883 <printf+0x17b>
    c = fmt[i] & 0xff;
 72a:	8b 55 0c             	mov    0xc(%ebp),%edx
 72d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 730:	01 d0                	add    %edx,%eax
 732:	0f b6 00             	movzbl (%eax),%eax
 735:	0f be c0             	movsbl %al,%eax
 738:	25 ff 00 00 00       	and    $0xff,%eax
 73d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 740:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 744:	75 2c                	jne    772 <printf+0x6a>
      if(c == '%'){
 746:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74a:	75 0c                	jne    758 <printf+0x50>
        state = '%';
 74c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 753:	e9 27 01 00 00       	jmp    87f <printf+0x177>
      } else {
        putc(fd, c);
 758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75b:	0f be c0             	movsbl %al,%eax
 75e:	83 ec 08             	sub    $0x8,%esp
 761:	50                   	push   %eax
 762:	ff 75 08             	pushl  0x8(%ebp)
 765:	e8 cb fe ff ff       	call   635 <putc>
 76a:	83 c4 10             	add    $0x10,%esp
 76d:	e9 0d 01 00 00       	jmp    87f <printf+0x177>
      }
    } else if(state == '%'){
 772:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 776:	0f 85 03 01 00 00    	jne    87f <printf+0x177>
      if(c == 'd'){
 77c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 780:	75 1e                	jne    7a0 <printf+0x98>
        printint(fd, *ap, 10, 1);
 782:	8b 45 e8             	mov    -0x18(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	6a 01                	push   $0x1
 789:	6a 0a                	push   $0xa
 78b:	50                   	push   %eax
 78c:	ff 75 08             	pushl  0x8(%ebp)
 78f:	e8 c4 fe ff ff       	call   658 <printint>
 794:	83 c4 10             	add    $0x10,%esp
        ap++;
 797:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 79b:	e9 d8 00 00 00       	jmp    878 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7a0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7a4:	74 06                	je     7ac <printf+0xa4>
 7a6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7aa:	75 1e                	jne    7ca <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7af:	8b 00                	mov    (%eax),%eax
 7b1:	6a 00                	push   $0x0
 7b3:	6a 10                	push   $0x10
 7b5:	50                   	push   %eax
 7b6:	ff 75 08             	pushl  0x8(%ebp)
 7b9:	e8 9a fe ff ff       	call   658 <printint>
 7be:	83 c4 10             	add    $0x10,%esp
        ap++;
 7c1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c5:	e9 ae 00 00 00       	jmp    878 <printf+0x170>
      } else if(c == 's'){
 7ca:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ce:	75 43                	jne    813 <printf+0x10b>
        s = (char*)*ap;
 7d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d3:	8b 00                	mov    (%eax),%eax
 7d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e0:	75 25                	jne    807 <printf+0xff>
          s = "(null)";
 7e2:	c7 45 f4 f6 0a 00 00 	movl   $0xaf6,-0xc(%ebp)
        while(*s != 0){
 7e9:	eb 1c                	jmp    807 <printf+0xff>
          putc(fd, *s);
 7eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ee:	0f b6 00             	movzbl (%eax),%eax
 7f1:	0f be c0             	movsbl %al,%eax
 7f4:	83 ec 08             	sub    $0x8,%esp
 7f7:	50                   	push   %eax
 7f8:	ff 75 08             	pushl  0x8(%ebp)
 7fb:	e8 35 fe ff ff       	call   635 <putc>
 800:	83 c4 10             	add    $0x10,%esp
          s++;
 803:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	0f b6 00             	movzbl (%eax),%eax
 80d:	84 c0                	test   %al,%al
 80f:	75 da                	jne    7eb <printf+0xe3>
 811:	eb 65                	jmp    878 <printf+0x170>
        }
      } else if(c == 'c'){
 813:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 817:	75 1d                	jne    836 <printf+0x12e>
        putc(fd, *ap);
 819:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	0f be c0             	movsbl %al,%eax
 821:	83 ec 08             	sub    $0x8,%esp
 824:	50                   	push   %eax
 825:	ff 75 08             	pushl  0x8(%ebp)
 828:	e8 08 fe ff ff       	call   635 <putc>
 82d:	83 c4 10             	add    $0x10,%esp
        ap++;
 830:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 834:	eb 42                	jmp    878 <printf+0x170>
      } else if(c == '%'){
 836:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 83a:	75 17                	jne    853 <printf+0x14b>
        putc(fd, c);
 83c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83f:	0f be c0             	movsbl %al,%eax
 842:	83 ec 08             	sub    $0x8,%esp
 845:	50                   	push   %eax
 846:	ff 75 08             	pushl  0x8(%ebp)
 849:	e8 e7 fd ff ff       	call   635 <putc>
 84e:	83 c4 10             	add    $0x10,%esp
 851:	eb 25                	jmp    878 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 853:	83 ec 08             	sub    $0x8,%esp
 856:	6a 25                	push   $0x25
 858:	ff 75 08             	pushl  0x8(%ebp)
 85b:	e8 d5 fd ff ff       	call   635 <putc>
 860:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 863:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 866:	0f be c0             	movsbl %al,%eax
 869:	83 ec 08             	sub    $0x8,%esp
 86c:	50                   	push   %eax
 86d:	ff 75 08             	pushl  0x8(%ebp)
 870:	e8 c0 fd ff ff       	call   635 <putc>
 875:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 878:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 87f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 883:	8b 55 0c             	mov    0xc(%ebp),%edx
 886:	8b 45 f0             	mov    -0x10(%ebp),%eax
 889:	01 d0                	add    %edx,%eax
 88b:	0f b6 00             	movzbl (%eax),%eax
 88e:	84 c0                	test   %al,%al
 890:	0f 85 94 fe ff ff    	jne    72a <printf+0x22>
    }
  }
}
 896:	90                   	nop
 897:	c9                   	leave  
 898:	c3                   	ret    

00000899 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 899:	55                   	push   %ebp
 89a:	89 e5                	mov    %esp,%ebp
 89c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 89f:	8b 45 08             	mov    0x8(%ebp),%eax
 8a2:	83 e8 08             	sub    $0x8,%eax
 8a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a8:	a1 e8 0d 00 00       	mov    0xde8,%eax
 8ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b0:	eb 24                	jmp    8d6 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b5:	8b 00                	mov    (%eax),%eax
 8b7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8ba:	72 12                	jb     8ce <free+0x35>
 8bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c2:	77 24                	ja     8e8 <free+0x4f>
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	8b 00                	mov    (%eax),%eax
 8c9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8cc:	72 1a                	jb     8e8 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d1:	8b 00                	mov    (%eax),%eax
 8d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8dc:	76 d4                	jbe    8b2 <free+0x19>
 8de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e1:	8b 00                	mov    (%eax),%eax
 8e3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8e6:	73 ca                	jae    8b2 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8eb:	8b 40 04             	mov    0x4(%eax),%eax
 8ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f8:	01 c2                	add    %eax,%edx
 8fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fd:	8b 00                	mov    (%eax),%eax
 8ff:	39 c2                	cmp    %eax,%edx
 901:	75 24                	jne    927 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 903:	8b 45 f8             	mov    -0x8(%ebp),%eax
 906:	8b 50 04             	mov    0x4(%eax),%edx
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	8b 40 04             	mov    0x4(%eax),%eax
 911:	01 c2                	add    %eax,%edx
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	8b 10                	mov    (%eax),%edx
 920:	8b 45 f8             	mov    -0x8(%ebp),%eax
 923:	89 10                	mov    %edx,(%eax)
 925:	eb 0a                	jmp    931 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 927:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92a:	8b 10                	mov    (%eax),%edx
 92c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 931:	8b 45 fc             	mov    -0x4(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 941:	01 d0                	add    %edx,%eax
 943:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 946:	75 20                	jne    968 <free+0xcf>
    p->s.size += bp->s.size;
 948:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94b:	8b 50 04             	mov    0x4(%eax),%edx
 94e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 951:	8b 40 04             	mov    0x4(%eax),%eax
 954:	01 c2                	add    %eax,%edx
 956:	8b 45 fc             	mov    -0x4(%ebp),%eax
 959:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 95c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95f:	8b 10                	mov    (%eax),%edx
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	89 10                	mov    %edx,(%eax)
 966:	eb 08                	jmp    970 <free+0xd7>
  } else
    p->s.ptr = bp;
 968:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 96e:	89 10                	mov    %edx,(%eax)
  freep = p;
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	a3 e8 0d 00 00       	mov    %eax,0xde8
}
 978:	90                   	nop
 979:	c9                   	leave  
 97a:	c3                   	ret    

0000097b <morecore>:

static Header*
morecore(uint nu)
{
 97b:	55                   	push   %ebp
 97c:	89 e5                	mov    %esp,%ebp
 97e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 981:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 988:	77 07                	ja     991 <morecore+0x16>
    nu = 4096;
 98a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 991:	8b 45 08             	mov    0x8(%ebp),%eax
 994:	c1 e0 03             	shl    $0x3,%eax
 997:	83 ec 0c             	sub    $0xc,%esp
 99a:	50                   	push   %eax
 99b:	e8 6d fc ff ff       	call   60d <sbrk>
 9a0:	83 c4 10             	add    $0x10,%esp
 9a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9a6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9aa:	75 07                	jne    9b3 <morecore+0x38>
    return 0;
 9ac:	b8 00 00 00 00       	mov    $0x0,%eax
 9b1:	eb 26                	jmp    9d9 <morecore+0x5e>
  hp = (Header*)p;
 9b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bc:	8b 55 08             	mov    0x8(%ebp),%edx
 9bf:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c5:	83 c0 08             	add    $0x8,%eax
 9c8:	83 ec 0c             	sub    $0xc,%esp
 9cb:	50                   	push   %eax
 9cc:	e8 c8 fe ff ff       	call   899 <free>
 9d1:	83 c4 10             	add    $0x10,%esp
  return freep;
 9d4:	a1 e8 0d 00 00       	mov    0xde8,%eax
}
 9d9:	c9                   	leave  
 9da:	c3                   	ret    

000009db <malloc>:

void*
malloc(uint nbytes)
{
 9db:	55                   	push   %ebp
 9dc:	89 e5                	mov    %esp,%ebp
 9de:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e1:	8b 45 08             	mov    0x8(%ebp),%eax
 9e4:	83 c0 07             	add    $0x7,%eax
 9e7:	c1 e8 03             	shr    $0x3,%eax
 9ea:	83 c0 01             	add    $0x1,%eax
 9ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9f0:	a1 e8 0d 00 00       	mov    0xde8,%eax
 9f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9fc:	75 23                	jne    a21 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9fe:	c7 45 f0 e0 0d 00 00 	movl   $0xde0,-0x10(%ebp)
 a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a08:	a3 e8 0d 00 00       	mov    %eax,0xde8
 a0d:	a1 e8 0d 00 00       	mov    0xde8,%eax
 a12:	a3 e0 0d 00 00       	mov    %eax,0xde0
    base.s.size = 0;
 a17:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
 a1e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a24:	8b 00                	mov    (%eax),%eax
 a26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2c:	8b 40 04             	mov    0x4(%eax),%eax
 a2f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a32:	77 4d                	ja     a81 <malloc+0xa6>
      if(p->s.size == nunits)
 a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a37:	8b 40 04             	mov    0x4(%eax),%eax
 a3a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a3d:	75 0c                	jne    a4b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a42:	8b 10                	mov    (%eax),%edx
 a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a47:	89 10                	mov    %edx,(%eax)
 a49:	eb 26                	jmp    a71 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	8b 40 04             	mov    0x4(%eax),%eax
 a51:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a54:	89 c2                	mov    %eax,%edx
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	8b 40 04             	mov    0x4(%eax),%eax
 a62:	c1 e0 03             	shl    $0x3,%eax
 a65:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a6e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a74:	a3 e8 0d 00 00       	mov    %eax,0xde8
      return (void*)(p + 1);
 a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7c:	83 c0 08             	add    $0x8,%eax
 a7f:	eb 3b                	jmp    abc <malloc+0xe1>
    }
    if(p == freep)
 a81:	a1 e8 0d 00 00       	mov    0xde8,%eax
 a86:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a89:	75 1e                	jne    aa9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a8b:	83 ec 0c             	sub    $0xc,%esp
 a8e:	ff 75 ec             	pushl  -0x14(%ebp)
 a91:	e8 e5 fe ff ff       	call   97b <morecore>
 a96:	83 c4 10             	add    $0x10,%esp
 a99:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aa0:	75 07                	jne    aa9 <malloc+0xce>
        return 0;
 aa2:	b8 00 00 00 00       	mov    $0x0,%eax
 aa7:	eb 13                	jmp    abc <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aac:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab2:	8b 00                	mov    (%eax),%eax
 ab4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ab7:	e9 6d ff ff ff       	jmp    a29 <malloc+0x4e>
  }
}
 abc:	c9                   	leave  
 abd:	c3                   	ret    
