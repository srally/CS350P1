
_xvsh:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
int process_one_cmd(char *);

#define MAXLINE 256

int main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	81 ec 14 01 00 00    	sub    $0x114,%esp
    char buf[MAXLINE];
    int i;
    int n;
    printf(1, SH_PROMPT);  /* print prompt (printf requires %% to print %) */
  14:	83 ec 08             	sub    $0x8,%esp
  17:	68 7b 0a 00 00       	push   $0xa7b
  1c:	6a 01                	push   $0x1
  1e:	e8 a2 06 00 00       	call   6c5 <printf>
  23:	83 c4 10             	add    $0x10,%esp

    while ( (n = read(0, buf, MAXLINE)) != 0) 
  26:	eb 7d                	jmp    a5 <main+0xa5>
    {
        if (n == 1)                           /* no input at all, we should skip */
  28:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  2c:	75 14                	jne    42 <main+0x42>
        {
            printf(1, SH_PROMPT);
  2e:	83 ec 08             	sub    $0x8,%esp
  31:	68 7b 0a 00 00       	push   $0xa7b
  36:	6a 01                	push   $0x1
  38:	e8 88 06 00 00       	call   6c5 <printf>
  3d:	83 c4 10             	add    $0x10,%esp
            continue;
  40:	eb 63                	jmp    a5 <main+0xa5>
        }
        buf[i = (strlen(buf) - 1)] = 0;       /* replace newline with null */
  42:	83 ec 0c             	sub    $0xc,%esp
  45:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  4b:	50                   	push   %eax
  4c:	e8 2f 03 00 00       	call   380 <strlen>
  51:	83 c4 10             	add    $0x10,%esp
  54:	83 e8 01             	sub    $0x1,%eax
  57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  5a:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  63:	01 d0                	add    %edx,%eax
  65:	c6 00 00             	movb   $0x0,(%eax)

        process_one_cmd(buf);
  68:	83 ec 0c             	sub    $0xc,%esp
  6b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  71:	50                   	push   %eax
  72:	e8 6d 00 00 00       	call   e4 <process_one_cmd>
  77:	83 c4 10             	add    $0x10,%esp
        
        printf(1, SH_PROMPT);
  7a:	83 ec 08             	sub    $0x8,%esp
  7d:	68 7b 0a 00 00       	push   $0xa7b
  82:	6a 01                	push   $0x1
  84:	e8 3c 06 00 00       	call   6c5 <printf>
  89:	83 c4 10             	add    $0x10,%esp
      
        memset(buf, 0, sizeof(buf));
  8c:	83 ec 04             	sub    $0x4,%esp
  8f:	68 00 01 00 00       	push   $0x100
  94:	6a 00                	push   $0x0
  96:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  9c:	50                   	push   %eax
  9d:	e8 05 03 00 00       	call   3a7 <memset>
  a2:	83 c4 10             	add    $0x10,%esp
    while ( (n = read(0, buf, MAXLINE)) != 0) 
  a5:	83 ec 04             	sub    $0x4,%esp
  a8:	68 00 01 00 00       	push   $0x100
  ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  b3:	50                   	push   %eax
  b4:	6a 00                	push   $0x0
  b6:	e8 9f 04 00 00       	call   55a <read>
  bb:	83 c4 10             	add    $0x10,%esp
  be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  c5:	0f 85 5d ff ff ff    	jne    28 <main+0x28>
    }
    
    exit();
  cb:	e8 72 04 00 00       	call   542 <exit>

000000d0 <exit_check>:
}

int exit_check(char **tok, int num_tok)
{
  d0:	55                   	push   %ebp
  d1:	89 e5                	mov    %esp,%ebp
    // your implementation here
    return 0;
  d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  d8:	5d                   	pop    %ebp
  d9:	c3                   	ret    

000000da <process_normal>:

int process_normal(char **tok, int bg)
{
  da:	55                   	push   %ebp
  db:	89 e5                	mov    %esp,%ebp
    // your implementation here
    // note that exec(*tok, tok) is the right way to invoke exec in xv6
    return 0;
  dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  e2:	5d                   	pop    %ebp
  e3:	c3                   	ret    

000000e4 <process_one_cmd>:


int process_one_cmd(char* buf)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	53                   	push   %ebx
  e8:	83 ec 14             	sub    $0x14,%esp
    int i, num_tok;
    char **tok;
    int bg;
    i = (strlen(buf) - 1);
  eb:	83 ec 0c             	sub    $0xc,%esp
  ee:	ff 75 08             	pushl  0x8(%ebp)
  f1:	e8 8a 02 00 00       	call   380 <strlen>
  f6:	83 c4 10             	add    $0x10,%esp
  f9:	83 e8 01             	sub    $0x1,%eax
  fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    num_tok = 1;
  ff:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

    while (i)
 106:	eb 1b                	jmp    123 <process_one_cmd+0x3f>
    {
        if (buf[i--] == ' ')
 108:	8b 45 f4             	mov    -0xc(%ebp),%eax
 10b:	8d 50 ff             	lea    -0x1(%eax),%edx
 10e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 111:	89 c2                	mov    %eax,%edx
 113:	8b 45 08             	mov    0x8(%ebp),%eax
 116:	01 d0                	add    %edx,%eax
 118:	0f b6 00             	movzbl (%eax),%eax
 11b:	3c 20                	cmp    $0x20,%al
 11d:	75 04                	jne    123 <process_one_cmd+0x3f>
            num_tok++;
 11f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    while (i)
 123:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 127:	75 df                	jne    108 <process_one_cmd+0x24>
    }

    if (!(tok = malloc( (num_tok + 1) *   sizeof (char *)))) 
 129:	8b 45 f0             	mov    -0x10(%ebp),%eax
 12c:	83 c0 01             	add    $0x1,%eax
 12f:	c1 e0 02             	shl    $0x2,%eax
 132:	83 ec 0c             	sub    $0xc,%esp
 135:	50                   	push   %eax
 136:	e8 5d 08 00 00       	call   998 <malloc>
 13b:	83 c4 10             	add    $0x10,%esp
 13e:	89 45 e8             	mov    %eax,-0x18(%ebp)
 141:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 145:	75 17                	jne    15e <process_one_cmd+0x7a>
    {
        printf(1, "malloc failed\n");
 147:	83 ec 08             	sub    $0x8,%esp
 14a:	68 82 0a 00 00       	push   $0xa82
 14f:	6a 01                	push   $0x1
 151:	e8 6f 05 00 00       	call   6c5 <printf>
 156:	83 c4 10             	add    $0x10,%esp
        exit();
 159:	e8 e4 03 00 00       	call   542 <exit>
    }        


    i = bg = 0;
 15e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 165:	8b 45 ec             	mov    -0x14(%ebp),%eax
 168:	89 45 f4             	mov    %eax,-0xc(%ebp)
    tok[i++] = strtok(buf, " ");
 16b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16e:	8d 50 01             	lea    0x1(%eax),%edx
 171:	89 55 f4             	mov    %edx,-0xc(%ebp)
 174:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 17b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 17e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 181:	83 ec 08             	sub    $0x8,%esp
 184:	68 91 0a 00 00       	push   $0xa91
 189:	ff 75 08             	pushl  0x8(%ebp)
 18c:	e8 b2 00 00 00       	call   243 <strtok>
 191:	83 c4 10             	add    $0x10,%esp
 194:	89 03                	mov    %eax,(%ebx)

    /* check special symbols */
    while ((tok[i] = strtok(NULL, " "))) 
 196:	eb 3e                	jmp    1d6 <process_one_cmd+0xf2>
    {
        switch (*tok[i]) 
 198:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1a5:	01 d0                	add    %edx,%eax
 1a7:	8b 00                	mov    (%eax),%eax
 1a9:	0f b6 00             	movzbl (%eax),%eax
 1ac:	0f be c0             	movsbl %al,%eax
 1af:	83 f8 26             	cmp    $0x26,%eax
 1b2:	75 1d                	jne    1d1 <process_one_cmd+0xed>
        {
            case '&':
                bg = i;
 1b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
                tok[i] = NULL;
 1ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1c7:	01 d0                	add    %edx,%eax
 1c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                break;
 1cf:	eb 01                	jmp    1d2 <process_one_cmd+0xee>

            default:
                // do nothing
                break;
 1d1:	90                   	nop
        }   
        i++;
 1d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    while ((tok[i] = strtok(NULL, " "))) 
 1d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1e3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 1e6:	83 ec 08             	sub    $0x8,%esp
 1e9:	68 91 0a 00 00       	push   $0xa91
 1ee:	6a 00                	push   $0x0
 1f0:	e8 4e 00 00 00       	call   243 <strtok>
 1f5:	83 c4 10             	add    $0x10,%esp
 1f8:	89 03                	mov    %eax,(%ebx)
 1fa:	8b 03                	mov    (%ebx),%eax
 1fc:	85 c0                	test   %eax,%eax
 1fe:	75 98                	jne    198 <process_one_cmd+0xb4>
    }

    /*Check buid-in exit command */
    if (exit_check(tok, num_tok))
 200:	83 ec 08             	sub    $0x8,%esp
 203:	ff 75 f0             	pushl  -0x10(%ebp)
 206:	ff 75 e8             	pushl  -0x18(%ebp)
 209:	e8 c2 fe ff ff       	call   d0 <exit_check>
 20e:	83 c4 10             	add    $0x10,%esp
 211:	85 c0                	test   %eax,%eax
 213:	74 05                	je     21a <process_one_cmd+0x136>
    {
        /*some code here to wait till all children exit() before exit*/
	// your implementation here
        exit();
 215:	e8 28 03 00 00       	call   542 <exit>
    }

    // your code to check NOT implemented cases
    
    /* to process one command */
    process_normal(tok, bg);
 21a:	83 ec 08             	sub    $0x8,%esp
 21d:	ff 75 ec             	pushl  -0x14(%ebp)
 220:	ff 75 e8             	pushl  -0x18(%ebp)
 223:	e8 b2 fe ff ff       	call   da <process_normal>
 228:	83 c4 10             	add    $0x10,%esp

    free(tok);
 22b:	83 ec 0c             	sub    $0xc,%esp
 22e:	ff 75 e8             	pushl  -0x18(%ebp)
 231:	e8 20 06 00 00       	call   856 <free>
 236:	83 c4 10             	add    $0x10,%esp
    return 0;
 239:	b8 00 00 00 00       	mov    $0x0,%eax
}
 23e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 241:	c9                   	leave  
 242:	c3                   	ret    

00000243 <strtok>:

char *
strtok(s, delim)
    register char *s;
    register const char *delim;
{
 243:	55                   	push   %ebp
 244:	89 e5                	mov    %esp,%ebp
 246:	57                   	push   %edi
 247:	56                   	push   %esi
 248:	53                   	push   %ebx
 249:	83 ec 10             	sub    $0x10,%esp
 24c:	8b 45 08             	mov    0x8(%ebp),%eax
 24f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    register int c, sc;
    char *tok;
    static char *last;


    if (s == NULL && (s = last) == NULL)
 252:	85 c0                	test   %eax,%eax
 254:	75 10                	jne    266 <strtok+0x23>
 256:	a1 84 0d 00 00       	mov    0xd84,%eax
 25b:	85 c0                	test   %eax,%eax
 25d:	75 07                	jne    266 <strtok+0x23>
        return (NULL);
 25f:	b8 00 00 00 00       	mov    $0x0,%eax
 264:	eb 7d                	jmp    2e3 <strtok+0xa0>

    /*
     * Skip (span) leading delimiters (s += strspn(s, delim), sort of).
     */
cont:
 266:	90                   	nop
    c = *s++;
 267:	89 c2                	mov    %eax,%edx
 269:	8d 42 01             	lea    0x1(%edx),%eax
 26c:	0f b6 12             	movzbl (%edx),%edx
 26f:	0f be f2             	movsbl %dl,%esi
    for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
 272:	89 cf                	mov    %ecx,%edi
 274:	eb 06                	jmp    27c <strtok+0x39>
        if (c == sc)
 276:	39 de                	cmp    %ebx,%esi
 278:	75 02                	jne    27c <strtok+0x39>
            goto cont;
 27a:	eb eb                	jmp    267 <strtok+0x24>
    for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
 27c:	89 fa                	mov    %edi,%edx
 27e:	8d 7a 01             	lea    0x1(%edx),%edi
 281:	0f b6 12             	movzbl (%edx),%edx
 284:	0f be da             	movsbl %dl,%ebx
 287:	85 db                	test   %ebx,%ebx
 289:	75 eb                	jne    276 <strtok+0x33>
    }

    if (c == 0) {        /* no non-delimiter characters */
 28b:	85 f6                	test   %esi,%esi
 28d:	75 11                	jne    2a0 <strtok+0x5d>
        last = NULL;
 28f:	c7 05 84 0d 00 00 00 	movl   $0x0,0xd84
 296:	00 00 00 
        return (NULL);
 299:	b8 00 00 00 00       	mov    $0x0,%eax
 29e:	eb 43                	jmp    2e3 <strtok+0xa0>
    }
    tok = s - 1;
 2a0:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a3:	89 55 f0             	mov    %edx,-0x10(%ebp)
    /*
     * Scan token (scan for delimiters: s += strcspn(s, delim), sort of).
     * Note that delim must have one NUL; we stop if we see that, too.
     */
    for (;;) {
        c = *s++;
 2a6:	89 c2                	mov    %eax,%edx
 2a8:	8d 42 01             	lea    0x1(%edx),%eax
 2ab:	0f b6 12             	movzbl (%edx),%edx
 2ae:	0f be f2             	movsbl %dl,%esi
        spanp = (char *)delim;
 2b1:	89 cf                	mov    %ecx,%edi
        do {
            if ((sc = *spanp++) == c) {
 2b3:	89 fa                	mov    %edi,%edx
 2b5:	8d 7a 01             	lea    0x1(%edx),%edi
 2b8:	0f b6 12             	movzbl (%edx),%edx
 2bb:	0f be da             	movsbl %dl,%ebx
 2be:	39 f3                	cmp    %esi,%ebx
 2c0:	75 1b                	jne    2dd <strtok+0x9a>
                if (c == 0)
 2c2:	85 f6                	test   %esi,%esi
 2c4:	75 07                	jne    2cd <strtok+0x8a>
                    s = NULL;
 2c6:	b8 00 00 00 00       	mov    $0x0,%eax
 2cb:	eb 06                	jmp    2d3 <strtok+0x90>
                else
                    s[-1] = 0;
 2cd:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d0:	c6 02 00             	movb   $0x0,(%edx)
                last = s;
 2d3:	a3 84 0d 00 00       	mov    %eax,0xd84
                return (tok);
 2d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2db:	eb 06                	jmp    2e3 <strtok+0xa0>
            }
        } while (sc != 0);
 2dd:	85 db                	test   %ebx,%ebx
 2df:	75 d2                	jne    2b3 <strtok+0x70>
        c = *s++;
 2e1:	eb c3                	jmp    2a6 <strtok+0x63>
    }
    /* NOTREACHED */
}
 2e3:	83 c4 10             	add    $0x10,%esp
 2e6:	5b                   	pop    %ebx
 2e7:	5e                   	pop    %esi
 2e8:	5f                   	pop    %edi
 2e9:	5d                   	pop    %ebp
 2ea:	c3                   	ret    

000002eb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2eb:	55                   	push   %ebp
 2ec:	89 e5                	mov    %esp,%ebp
 2ee:	57                   	push   %edi
 2ef:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2f3:	8b 55 10             	mov    0x10(%ebp),%edx
 2f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f9:	89 cb                	mov    %ecx,%ebx
 2fb:	89 df                	mov    %ebx,%edi
 2fd:	89 d1                	mov    %edx,%ecx
 2ff:	fc                   	cld    
 300:	f3 aa                	rep stos %al,%es:(%edi)
 302:	89 ca                	mov    %ecx,%edx
 304:	89 fb                	mov    %edi,%ebx
 306:	89 5d 08             	mov    %ebx,0x8(%ebp)
 309:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 30c:	90                   	nop
 30d:	5b                   	pop    %ebx
 30e:	5f                   	pop    %edi
 30f:	5d                   	pop    %ebp
 310:	c3                   	ret    

00000311 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
 314:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 31d:	90                   	nop
 31e:	8b 55 0c             	mov    0xc(%ebp),%edx
 321:	8d 42 01             	lea    0x1(%edx),%eax
 324:	89 45 0c             	mov    %eax,0xc(%ebp)
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	8d 48 01             	lea    0x1(%eax),%ecx
 32d:	89 4d 08             	mov    %ecx,0x8(%ebp)
 330:	0f b6 12             	movzbl (%edx),%edx
 333:	88 10                	mov    %dl,(%eax)
 335:	0f b6 00             	movzbl (%eax),%eax
 338:	84 c0                	test   %al,%al
 33a:	75 e2                	jne    31e <strcpy+0xd>
    ;
  return os;
 33c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33f:	c9                   	leave  
 340:	c3                   	ret    

00000341 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 344:	eb 08                	jmp    34e <strcmp+0xd>
    p++, q++;
 346:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 34a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 34e:	8b 45 08             	mov    0x8(%ebp),%eax
 351:	0f b6 00             	movzbl (%eax),%eax
 354:	84 c0                	test   %al,%al
 356:	74 10                	je     368 <strcmp+0x27>
 358:	8b 45 08             	mov    0x8(%ebp),%eax
 35b:	0f b6 10             	movzbl (%eax),%edx
 35e:	8b 45 0c             	mov    0xc(%ebp),%eax
 361:	0f b6 00             	movzbl (%eax),%eax
 364:	38 c2                	cmp    %al,%dl
 366:	74 de                	je     346 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 368:	8b 45 08             	mov    0x8(%ebp),%eax
 36b:	0f b6 00             	movzbl (%eax),%eax
 36e:	0f b6 d0             	movzbl %al,%edx
 371:	8b 45 0c             	mov    0xc(%ebp),%eax
 374:	0f b6 00             	movzbl (%eax),%eax
 377:	0f b6 c0             	movzbl %al,%eax
 37a:	29 c2                	sub    %eax,%edx
 37c:	89 d0                	mov    %edx,%eax
}
 37e:	5d                   	pop    %ebp
 37f:	c3                   	ret    

00000380 <strlen>:

uint
strlen(char *s)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 386:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 38d:	eb 04                	jmp    393 <strlen+0x13>
 38f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 393:	8b 55 fc             	mov    -0x4(%ebp),%edx
 396:	8b 45 08             	mov    0x8(%ebp),%eax
 399:	01 d0                	add    %edx,%eax
 39b:	0f b6 00             	movzbl (%eax),%eax
 39e:	84 c0                	test   %al,%al
 3a0:	75 ed                	jne    38f <strlen+0xf>
    ;
  return n;
 3a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3aa:	8b 45 10             	mov    0x10(%ebp),%eax
 3ad:	50                   	push   %eax
 3ae:	ff 75 0c             	pushl  0xc(%ebp)
 3b1:	ff 75 08             	pushl  0x8(%ebp)
 3b4:	e8 32 ff ff ff       	call   2eb <stosb>
 3b9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3bf:	c9                   	leave  
 3c0:	c3                   	ret    

000003c1 <strchr>:

char*
strchr(const char *s, char c)
{
 3c1:	55                   	push   %ebp
 3c2:	89 e5                	mov    %esp,%ebp
 3c4:	83 ec 04             	sub    $0x4,%esp
 3c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ca:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3cd:	eb 14                	jmp    3e3 <strchr+0x22>
    if(*s == c)
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	0f b6 00             	movzbl (%eax),%eax
 3d5:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3d8:	75 05                	jne    3df <strchr+0x1e>
      return (char*)s;
 3da:	8b 45 08             	mov    0x8(%ebp),%eax
 3dd:	eb 13                	jmp    3f2 <strchr+0x31>
  for(; *s; s++)
 3df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
 3e6:	0f b6 00             	movzbl (%eax),%eax
 3e9:	84 c0                	test   %al,%al
 3eb:	75 e2                	jne    3cf <strchr+0xe>
  return 0;
 3ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3f2:	c9                   	leave  
 3f3:	c3                   	ret    

000003f4 <gets>:

char*
gets(char *buf, int max)
{
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 401:	eb 42                	jmp    445 <gets+0x51>
    cc = read(0, &c, 1);
 403:	83 ec 04             	sub    $0x4,%esp
 406:	6a 01                	push   $0x1
 408:	8d 45 ef             	lea    -0x11(%ebp),%eax
 40b:	50                   	push   %eax
 40c:	6a 00                	push   $0x0
 40e:	e8 47 01 00 00       	call   55a <read>
 413:	83 c4 10             	add    $0x10,%esp
 416:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 419:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 41d:	7e 33                	jle    452 <gets+0x5e>
      break;
    buf[i++] = c;
 41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 422:	8d 50 01             	lea    0x1(%eax),%edx
 425:	89 55 f4             	mov    %edx,-0xc(%ebp)
 428:	89 c2                	mov    %eax,%edx
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	01 c2                	add    %eax,%edx
 42f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 433:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 435:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 439:	3c 0a                	cmp    $0xa,%al
 43b:	74 16                	je     453 <gets+0x5f>
 43d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 441:	3c 0d                	cmp    $0xd,%al
 443:	74 0e                	je     453 <gets+0x5f>
  for(i=0; i+1 < max; ){
 445:	8b 45 f4             	mov    -0xc(%ebp),%eax
 448:	83 c0 01             	add    $0x1,%eax
 44b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 44e:	7f b3                	jg     403 <gets+0xf>
 450:	eb 01                	jmp    453 <gets+0x5f>
      break;
 452:	90                   	nop
      break;
  }
  buf[i] = '\0';
 453:	8b 55 f4             	mov    -0xc(%ebp),%edx
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	01 d0                	add    %edx,%eax
 45b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 461:	c9                   	leave  
 462:	c3                   	ret    

00000463 <stat>:

int
stat(char *n, struct stat *st)
{
 463:	55                   	push   %ebp
 464:	89 e5                	mov    %esp,%ebp
 466:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 469:	83 ec 08             	sub    $0x8,%esp
 46c:	6a 00                	push   $0x0
 46e:	ff 75 08             	pushl  0x8(%ebp)
 471:	e8 0c 01 00 00       	call   582 <open>
 476:	83 c4 10             	add    $0x10,%esp
 479:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 47c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 480:	79 07                	jns    489 <stat+0x26>
    return -1;
 482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 487:	eb 25                	jmp    4ae <stat+0x4b>
  r = fstat(fd, st);
 489:	83 ec 08             	sub    $0x8,%esp
 48c:	ff 75 0c             	pushl  0xc(%ebp)
 48f:	ff 75 f4             	pushl  -0xc(%ebp)
 492:	e8 03 01 00 00       	call   59a <fstat>
 497:	83 c4 10             	add    $0x10,%esp
 49a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 49d:	83 ec 0c             	sub    $0xc,%esp
 4a0:	ff 75 f4             	pushl  -0xc(%ebp)
 4a3:	e8 c2 00 00 00       	call   56a <close>
 4a8:	83 c4 10             	add    $0x10,%esp
  return r;
 4ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4ae:	c9                   	leave  
 4af:	c3                   	ret    

000004b0 <atoi>:

int
atoi(const char *s)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4bd:	eb 25                	jmp    4e4 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4c2:	89 d0                	mov    %edx,%eax
 4c4:	c1 e0 02             	shl    $0x2,%eax
 4c7:	01 d0                	add    %edx,%eax
 4c9:	01 c0                	add    %eax,%eax
 4cb:	89 c1                	mov    %eax,%ecx
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	8d 50 01             	lea    0x1(%eax),%edx
 4d3:	89 55 08             	mov    %edx,0x8(%ebp)
 4d6:	0f b6 00             	movzbl (%eax),%eax
 4d9:	0f be c0             	movsbl %al,%eax
 4dc:	01 c8                	add    %ecx,%eax
 4de:	83 e8 30             	sub    $0x30,%eax
 4e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4e4:	8b 45 08             	mov    0x8(%ebp),%eax
 4e7:	0f b6 00             	movzbl (%eax),%eax
 4ea:	3c 2f                	cmp    $0x2f,%al
 4ec:	7e 0a                	jle    4f8 <atoi+0x48>
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	0f b6 00             	movzbl (%eax),%eax
 4f4:	3c 39                	cmp    $0x39,%al
 4f6:	7e c7                	jle    4bf <atoi+0xf>
  return n;
 4f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4fb:	c9                   	leave  
 4fc:	c3                   	ret    

000004fd <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4fd:	55                   	push   %ebp
 4fe:	89 e5                	mov    %esp,%ebp
 500:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 503:	8b 45 08             	mov    0x8(%ebp),%eax
 506:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 509:	8b 45 0c             	mov    0xc(%ebp),%eax
 50c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 50f:	eb 17                	jmp    528 <memmove+0x2b>
    *dst++ = *src++;
 511:	8b 55 f8             	mov    -0x8(%ebp),%edx
 514:	8d 42 01             	lea    0x1(%edx),%eax
 517:	89 45 f8             	mov    %eax,-0x8(%ebp)
 51a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 51d:	8d 48 01             	lea    0x1(%eax),%ecx
 520:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 523:	0f b6 12             	movzbl (%edx),%edx
 526:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 528:	8b 45 10             	mov    0x10(%ebp),%eax
 52b:	8d 50 ff             	lea    -0x1(%eax),%edx
 52e:	89 55 10             	mov    %edx,0x10(%ebp)
 531:	85 c0                	test   %eax,%eax
 533:	7f dc                	jg     511 <memmove+0x14>
  return vdst;
 535:	8b 45 08             	mov    0x8(%ebp),%eax
}
 538:	c9                   	leave  
 539:	c3                   	ret    

0000053a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 53a:	b8 01 00 00 00       	mov    $0x1,%eax
 53f:	cd 40                	int    $0x40
 541:	c3                   	ret    

00000542 <exit>:
SYSCALL(exit)
 542:	b8 02 00 00 00       	mov    $0x2,%eax
 547:	cd 40                	int    $0x40
 549:	c3                   	ret    

0000054a <wait>:
SYSCALL(wait)
 54a:	b8 03 00 00 00       	mov    $0x3,%eax
 54f:	cd 40                	int    $0x40
 551:	c3                   	ret    

00000552 <pipe>:
SYSCALL(pipe)
 552:	b8 04 00 00 00       	mov    $0x4,%eax
 557:	cd 40                	int    $0x40
 559:	c3                   	ret    

0000055a <read>:
SYSCALL(read)
 55a:	b8 05 00 00 00       	mov    $0x5,%eax
 55f:	cd 40                	int    $0x40
 561:	c3                   	ret    

00000562 <write>:
SYSCALL(write)
 562:	b8 10 00 00 00       	mov    $0x10,%eax
 567:	cd 40                	int    $0x40
 569:	c3                   	ret    

0000056a <close>:
SYSCALL(close)
 56a:	b8 15 00 00 00       	mov    $0x15,%eax
 56f:	cd 40                	int    $0x40
 571:	c3                   	ret    

00000572 <kill>:
SYSCALL(kill)
 572:	b8 06 00 00 00       	mov    $0x6,%eax
 577:	cd 40                	int    $0x40
 579:	c3                   	ret    

0000057a <exec>:
SYSCALL(exec)
 57a:	b8 07 00 00 00       	mov    $0x7,%eax
 57f:	cd 40                	int    $0x40
 581:	c3                   	ret    

00000582 <open>:
SYSCALL(open)
 582:	b8 0f 00 00 00       	mov    $0xf,%eax
 587:	cd 40                	int    $0x40
 589:	c3                   	ret    

0000058a <mknod>:
SYSCALL(mknod)
 58a:	b8 11 00 00 00       	mov    $0x11,%eax
 58f:	cd 40                	int    $0x40
 591:	c3                   	ret    

00000592 <unlink>:
SYSCALL(unlink)
 592:	b8 12 00 00 00       	mov    $0x12,%eax
 597:	cd 40                	int    $0x40
 599:	c3                   	ret    

0000059a <fstat>:
SYSCALL(fstat)
 59a:	b8 08 00 00 00       	mov    $0x8,%eax
 59f:	cd 40                	int    $0x40
 5a1:	c3                   	ret    

000005a2 <link>:
SYSCALL(link)
 5a2:	b8 13 00 00 00       	mov    $0x13,%eax
 5a7:	cd 40                	int    $0x40
 5a9:	c3                   	ret    

000005aa <mkdir>:
SYSCALL(mkdir)
 5aa:	b8 14 00 00 00       	mov    $0x14,%eax
 5af:	cd 40                	int    $0x40
 5b1:	c3                   	ret    

000005b2 <chdir>:
SYSCALL(chdir)
 5b2:	b8 09 00 00 00       	mov    $0x9,%eax
 5b7:	cd 40                	int    $0x40
 5b9:	c3                   	ret    

000005ba <dup>:
SYSCALL(dup)
 5ba:	b8 0a 00 00 00       	mov    $0xa,%eax
 5bf:	cd 40                	int    $0x40
 5c1:	c3                   	ret    

000005c2 <getpid>:
SYSCALL(getpid)
 5c2:	b8 0b 00 00 00       	mov    $0xb,%eax
 5c7:	cd 40                	int    $0x40
 5c9:	c3                   	ret    

000005ca <sbrk>:
SYSCALL(sbrk)
 5ca:	b8 0c 00 00 00       	mov    $0xc,%eax
 5cf:	cd 40                	int    $0x40
 5d1:	c3                   	ret    

000005d2 <sleep>:
SYSCALL(sleep)
 5d2:	b8 0d 00 00 00       	mov    $0xd,%eax
 5d7:	cd 40                	int    $0x40
 5d9:	c3                   	ret    

000005da <uptime>:
SYSCALL(uptime)
 5da:	b8 0e 00 00 00       	mov    $0xe,%eax
 5df:	cd 40                	int    $0x40
 5e1:	c3                   	ret    

000005e2 <enable_sched_trace>:
SYSCALL(enable_sched_trace)
 5e2:	b8 16 00 00 00       	mov    $0x16,%eax
 5e7:	cd 40                	int    $0x40
 5e9:	c3                   	ret    

000005ea <uprog_shut>:
SYSCALL(uprog_shut)
 5ea:	b8 17 00 00 00       	mov    $0x17,%eax
 5ef:	cd 40                	int    $0x40
 5f1:	c3                   	ret    

000005f2 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5f2:	55                   	push   %ebp
 5f3:	89 e5                	mov    %esp,%ebp
 5f5:	83 ec 18             	sub    $0x18,%esp
 5f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5fb:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5fe:	83 ec 04             	sub    $0x4,%esp
 601:	6a 01                	push   $0x1
 603:	8d 45 f4             	lea    -0xc(%ebp),%eax
 606:	50                   	push   %eax
 607:	ff 75 08             	pushl  0x8(%ebp)
 60a:	e8 53 ff ff ff       	call   562 <write>
 60f:	83 c4 10             	add    $0x10,%esp
}
 612:	90                   	nop
 613:	c9                   	leave  
 614:	c3                   	ret    

00000615 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 615:	55                   	push   %ebp
 616:	89 e5                	mov    %esp,%ebp
 618:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 61b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 622:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 626:	74 17                	je     63f <printint+0x2a>
 628:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 62c:	79 11                	jns    63f <printint+0x2a>
    neg = 1;
 62e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 635:	8b 45 0c             	mov    0xc(%ebp),%eax
 638:	f7 d8                	neg    %eax
 63a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 63d:	eb 06                	jmp    645 <printint+0x30>
  } else {
    x = xx;
 63f:	8b 45 0c             	mov    0xc(%ebp),%eax
 642:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 645:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 64c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 64f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 652:	ba 00 00 00 00       	mov    $0x0,%edx
 657:	f7 f1                	div    %ecx
 659:	89 d1                	mov    %edx,%ecx
 65b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65e:	8d 50 01             	lea    0x1(%eax),%edx
 661:	89 55 f4             	mov    %edx,-0xc(%ebp)
 664:	0f b6 91 70 0d 00 00 	movzbl 0xd70(%ecx),%edx
 66b:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 66f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 672:	8b 45 ec             	mov    -0x14(%ebp),%eax
 675:	ba 00 00 00 00       	mov    $0x0,%edx
 67a:	f7 f1                	div    %ecx
 67c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 67f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 683:	75 c7                	jne    64c <printint+0x37>
  if(neg)
 685:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 689:	74 2d                	je     6b8 <printint+0xa3>
    buf[i++] = '-';
 68b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68e:	8d 50 01             	lea    0x1(%eax),%edx
 691:	89 55 f4             	mov    %edx,-0xc(%ebp)
 694:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 699:	eb 1d                	jmp    6b8 <printint+0xa3>
    putc(fd, buf[i]);
 69b:	8d 55 dc             	lea    -0x24(%ebp),%edx
 69e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a1:	01 d0                	add    %edx,%eax
 6a3:	0f b6 00             	movzbl (%eax),%eax
 6a6:	0f be c0             	movsbl %al,%eax
 6a9:	83 ec 08             	sub    $0x8,%esp
 6ac:	50                   	push   %eax
 6ad:	ff 75 08             	pushl  0x8(%ebp)
 6b0:	e8 3d ff ff ff       	call   5f2 <putc>
 6b5:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6b8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6c0:	79 d9                	jns    69b <printint+0x86>
}
 6c2:	90                   	nop
 6c3:	c9                   	leave  
 6c4:	c3                   	ret    

000006c5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6c5:	55                   	push   %ebp
 6c6:	89 e5                	mov    %esp,%ebp
 6c8:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6cb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6d2:	8d 45 0c             	lea    0xc(%ebp),%eax
 6d5:	83 c0 04             	add    $0x4,%eax
 6d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6e2:	e9 59 01 00 00       	jmp    840 <printf+0x17b>
    c = fmt[i] & 0xff;
 6e7:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ed:	01 d0                	add    %edx,%eax
 6ef:	0f b6 00             	movzbl (%eax),%eax
 6f2:	0f be c0             	movsbl %al,%eax
 6f5:	25 ff 00 00 00       	and    $0xff,%eax
 6fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 701:	75 2c                	jne    72f <printf+0x6a>
      if(c == '%'){
 703:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 707:	75 0c                	jne    715 <printf+0x50>
        state = '%';
 709:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 710:	e9 27 01 00 00       	jmp    83c <printf+0x177>
      } else {
        putc(fd, c);
 715:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 718:	0f be c0             	movsbl %al,%eax
 71b:	83 ec 08             	sub    $0x8,%esp
 71e:	50                   	push   %eax
 71f:	ff 75 08             	pushl  0x8(%ebp)
 722:	e8 cb fe ff ff       	call   5f2 <putc>
 727:	83 c4 10             	add    $0x10,%esp
 72a:	e9 0d 01 00 00       	jmp    83c <printf+0x177>
      }
    } else if(state == '%'){
 72f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 733:	0f 85 03 01 00 00    	jne    83c <printf+0x177>
      if(c == 'd'){
 739:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 73d:	75 1e                	jne    75d <printf+0x98>
        printint(fd, *ap, 10, 1);
 73f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 742:	8b 00                	mov    (%eax),%eax
 744:	6a 01                	push   $0x1
 746:	6a 0a                	push   $0xa
 748:	50                   	push   %eax
 749:	ff 75 08             	pushl  0x8(%ebp)
 74c:	e8 c4 fe ff ff       	call   615 <printint>
 751:	83 c4 10             	add    $0x10,%esp
        ap++;
 754:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 758:	e9 d8 00 00 00       	jmp    835 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 75d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 761:	74 06                	je     769 <printf+0xa4>
 763:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 767:	75 1e                	jne    787 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 769:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76c:	8b 00                	mov    (%eax),%eax
 76e:	6a 00                	push   $0x0
 770:	6a 10                	push   $0x10
 772:	50                   	push   %eax
 773:	ff 75 08             	pushl  0x8(%ebp)
 776:	e8 9a fe ff ff       	call   615 <printint>
 77b:	83 c4 10             	add    $0x10,%esp
        ap++;
 77e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 782:	e9 ae 00 00 00       	jmp    835 <printf+0x170>
      } else if(c == 's'){
 787:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 78b:	75 43                	jne    7d0 <printf+0x10b>
        s = (char*)*ap;
 78d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 795:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 799:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79d:	75 25                	jne    7c4 <printf+0xff>
          s = "(null)";
 79f:	c7 45 f4 93 0a 00 00 	movl   $0xa93,-0xc(%ebp)
        while(*s != 0){
 7a6:	eb 1c                	jmp    7c4 <printf+0xff>
          putc(fd, *s);
 7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ab:	0f b6 00             	movzbl (%eax),%eax
 7ae:	0f be c0             	movsbl %al,%eax
 7b1:	83 ec 08             	sub    $0x8,%esp
 7b4:	50                   	push   %eax
 7b5:	ff 75 08             	pushl  0x8(%ebp)
 7b8:	e8 35 fe ff ff       	call   5f2 <putc>
 7bd:	83 c4 10             	add    $0x10,%esp
          s++;
 7c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	0f b6 00             	movzbl (%eax),%eax
 7ca:	84 c0                	test   %al,%al
 7cc:	75 da                	jne    7a8 <printf+0xe3>
 7ce:	eb 65                	jmp    835 <printf+0x170>
        }
      } else if(c == 'c'){
 7d0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7d4:	75 1d                	jne    7f3 <printf+0x12e>
        putc(fd, *ap);
 7d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d9:	8b 00                	mov    (%eax),%eax
 7db:	0f be c0             	movsbl %al,%eax
 7de:	83 ec 08             	sub    $0x8,%esp
 7e1:	50                   	push   %eax
 7e2:	ff 75 08             	pushl  0x8(%ebp)
 7e5:	e8 08 fe ff ff       	call   5f2 <putc>
 7ea:	83 c4 10             	add    $0x10,%esp
        ap++;
 7ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f1:	eb 42                	jmp    835 <printf+0x170>
      } else if(c == '%'){
 7f3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7f7:	75 17                	jne    810 <printf+0x14b>
        putc(fd, c);
 7f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7fc:	0f be c0             	movsbl %al,%eax
 7ff:	83 ec 08             	sub    $0x8,%esp
 802:	50                   	push   %eax
 803:	ff 75 08             	pushl  0x8(%ebp)
 806:	e8 e7 fd ff ff       	call   5f2 <putc>
 80b:	83 c4 10             	add    $0x10,%esp
 80e:	eb 25                	jmp    835 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 810:	83 ec 08             	sub    $0x8,%esp
 813:	6a 25                	push   $0x25
 815:	ff 75 08             	pushl  0x8(%ebp)
 818:	e8 d5 fd ff ff       	call   5f2 <putc>
 81d:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 820:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 823:	0f be c0             	movsbl %al,%eax
 826:	83 ec 08             	sub    $0x8,%esp
 829:	50                   	push   %eax
 82a:	ff 75 08             	pushl  0x8(%ebp)
 82d:	e8 c0 fd ff ff       	call   5f2 <putc>
 832:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 835:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 83c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 840:	8b 55 0c             	mov    0xc(%ebp),%edx
 843:	8b 45 f0             	mov    -0x10(%ebp),%eax
 846:	01 d0                	add    %edx,%eax
 848:	0f b6 00             	movzbl (%eax),%eax
 84b:	84 c0                	test   %al,%al
 84d:	0f 85 94 fe ff ff    	jne    6e7 <printf+0x22>
    }
  }
}
 853:	90                   	nop
 854:	c9                   	leave  
 855:	c3                   	ret    

00000856 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 856:	55                   	push   %ebp
 857:	89 e5                	mov    %esp,%ebp
 859:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85c:	8b 45 08             	mov    0x8(%ebp),%eax
 85f:	83 e8 08             	sub    $0x8,%eax
 862:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 865:	a1 90 0d 00 00       	mov    0xd90,%eax
 86a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 86d:	eb 24                	jmp    893 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 872:	8b 00                	mov    (%eax),%eax
 874:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 877:	72 12                	jb     88b <free+0x35>
 879:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 87f:	77 24                	ja     8a5 <free+0x4f>
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 00                	mov    (%eax),%eax
 886:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 889:	72 1a                	jb     8a5 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 00                	mov    (%eax),%eax
 890:	89 45 fc             	mov    %eax,-0x4(%ebp)
 893:	8b 45 f8             	mov    -0x8(%ebp),%eax
 896:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 899:	76 d4                	jbe    86f <free+0x19>
 89b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89e:	8b 00                	mov    (%eax),%eax
 8a0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8a3:	73 ca                	jae    86f <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a8:	8b 40 04             	mov    0x4(%eax),%eax
 8ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b5:	01 c2                	add    %eax,%edx
 8b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ba:	8b 00                	mov    (%eax),%eax
 8bc:	39 c2                	cmp    %eax,%edx
 8be:	75 24                	jne    8e4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c3:	8b 50 04             	mov    0x4(%eax),%edx
 8c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c9:	8b 00                	mov    (%eax),%eax
 8cb:	8b 40 04             	mov    0x4(%eax),%eax
 8ce:	01 c2                	add    %eax,%edx
 8d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d9:	8b 00                	mov    (%eax),%eax
 8db:	8b 10                	mov    (%eax),%edx
 8dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e0:	89 10                	mov    %edx,(%eax)
 8e2:	eb 0a                	jmp    8ee <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e7:	8b 10                	mov    (%eax),%edx
 8e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ec:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f1:	8b 40 04             	mov    0x4(%eax),%eax
 8f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fe:	01 d0                	add    %edx,%eax
 900:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 903:	75 20                	jne    925 <free+0xcf>
    p->s.size += bp->s.size;
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	8b 50 04             	mov    0x4(%eax),%edx
 90b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90e:	8b 40 04             	mov    0x4(%eax),%eax
 911:	01 c2                	add    %eax,%edx
 913:	8b 45 fc             	mov    -0x4(%ebp),%eax
 916:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 919:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91c:	8b 10                	mov    (%eax),%edx
 91e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 921:	89 10                	mov    %edx,(%eax)
 923:	eb 08                	jmp    92d <free+0xd7>
  } else
    p->s.ptr = bp;
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	8b 55 f8             	mov    -0x8(%ebp),%edx
 92b:	89 10                	mov    %edx,(%eax)
  freep = p;
 92d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 930:	a3 90 0d 00 00       	mov    %eax,0xd90
}
 935:	90                   	nop
 936:	c9                   	leave  
 937:	c3                   	ret    

00000938 <morecore>:

static Header*
morecore(uint nu)
{
 938:	55                   	push   %ebp
 939:	89 e5                	mov    %esp,%ebp
 93b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 93e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 945:	77 07                	ja     94e <morecore+0x16>
    nu = 4096;
 947:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 94e:	8b 45 08             	mov    0x8(%ebp),%eax
 951:	c1 e0 03             	shl    $0x3,%eax
 954:	83 ec 0c             	sub    $0xc,%esp
 957:	50                   	push   %eax
 958:	e8 6d fc ff ff       	call   5ca <sbrk>
 95d:	83 c4 10             	add    $0x10,%esp
 960:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 963:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 967:	75 07                	jne    970 <morecore+0x38>
    return 0;
 969:	b8 00 00 00 00       	mov    $0x0,%eax
 96e:	eb 26                	jmp    996 <morecore+0x5e>
  hp = (Header*)p;
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 976:	8b 45 f0             	mov    -0x10(%ebp),%eax
 979:	8b 55 08             	mov    0x8(%ebp),%edx
 97c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 97f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 982:	83 c0 08             	add    $0x8,%eax
 985:	83 ec 0c             	sub    $0xc,%esp
 988:	50                   	push   %eax
 989:	e8 c8 fe ff ff       	call   856 <free>
 98e:	83 c4 10             	add    $0x10,%esp
  return freep;
 991:	a1 90 0d 00 00       	mov    0xd90,%eax
}
 996:	c9                   	leave  
 997:	c3                   	ret    

00000998 <malloc>:

void*
malloc(uint nbytes)
{
 998:	55                   	push   %ebp
 999:	89 e5                	mov    %esp,%ebp
 99b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99e:	8b 45 08             	mov    0x8(%ebp),%eax
 9a1:	83 c0 07             	add    $0x7,%eax
 9a4:	c1 e8 03             	shr    $0x3,%eax
 9a7:	83 c0 01             	add    $0x1,%eax
 9aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9ad:	a1 90 0d 00 00       	mov    0xd90,%eax
 9b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9b9:	75 23                	jne    9de <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9bb:	c7 45 f0 88 0d 00 00 	movl   $0xd88,-0x10(%ebp)
 9c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c5:	a3 90 0d 00 00       	mov    %eax,0xd90
 9ca:	a1 90 0d 00 00       	mov    0xd90,%eax
 9cf:	a3 88 0d 00 00       	mov    %eax,0xd88
    base.s.size = 0;
 9d4:	c7 05 8c 0d 00 00 00 	movl   $0x0,0xd8c
 9db:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e1:	8b 00                	mov    (%eax),%eax
 9e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e9:	8b 40 04             	mov    0x4(%eax),%eax
 9ec:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9ef:	77 4d                	ja     a3e <malloc+0xa6>
      if(p->s.size == nunits)
 9f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f4:	8b 40 04             	mov    0x4(%eax),%eax
 9f7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9fa:	75 0c                	jne    a08 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	8b 10                	mov    (%eax),%edx
 a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a04:	89 10                	mov    %edx,(%eax)
 a06:	eb 26                	jmp    a2e <malloc+0x96>
      else {
        p->s.size -= nunits;
 a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0b:	8b 40 04             	mov    0x4(%eax),%eax
 a0e:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a11:	89 c2                	mov    %eax,%edx
 a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a16:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1c:	8b 40 04             	mov    0x4(%eax),%eax
 a1f:	c1 e0 03             	shl    $0x3,%eax
 a22:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a28:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a2b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a31:	a3 90 0d 00 00       	mov    %eax,0xd90
      return (void*)(p + 1);
 a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a39:	83 c0 08             	add    $0x8,%eax
 a3c:	eb 3b                	jmp    a79 <malloc+0xe1>
    }
    if(p == freep)
 a3e:	a1 90 0d 00 00       	mov    0xd90,%eax
 a43:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a46:	75 1e                	jne    a66 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a48:	83 ec 0c             	sub    $0xc,%esp
 a4b:	ff 75 ec             	pushl  -0x14(%ebp)
 a4e:	e8 e5 fe ff ff       	call   938 <morecore>
 a53:	83 c4 10             	add    $0x10,%esp
 a56:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a5d:	75 07                	jne    a66 <malloc+0xce>
        return 0;
 a5f:	b8 00 00 00 00       	mov    $0x0,%eax
 a64:	eb 13                	jmp    a79 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6f:	8b 00                	mov    (%eax),%eax
 a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a74:	e9 6d ff ff ff       	jmp    9e6 <malloc+0x4e>
  }
}
 a79:	c9                   	leave  
 a7a:	c3                   	ret    
