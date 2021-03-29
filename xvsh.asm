
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
  17:	68 1c 0b 00 00       	push   $0xb1c
  1c:	6a 01                	push   $0x1
  1e:	e8 40 07 00 00       	call   763 <printf>
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
  31:	68 1c 0b 00 00       	push   $0xb1c
  36:	6a 01                	push   $0x1
  38:	e8 26 07 00 00       	call   763 <printf>
  3d:	83 c4 10             	add    $0x10,%esp
            continue;
  40:	eb 63                	jmp    a5 <main+0xa5>
        }
        buf[i = (strlen(buf) - 1)] = 0;       /* replace newline with null */
  42:	83 ec 0c             	sub    $0xc,%esp
  45:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  4b:	50                   	push   %eax
  4c:	e8 cd 03 00 00       	call   41e <strlen>
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
  72:	e8 06 01 00 00       	call   17d <process_one_cmd>
  77:	83 c4 10             	add    $0x10,%esp
        
        printf(1, SH_PROMPT);
  7a:	83 ec 08             	sub    $0x8,%esp
  7d:	68 1c 0b 00 00       	push   $0xb1c
  82:	6a 01                	push   $0x1
  84:	e8 da 06 00 00       	call   763 <printf>
  89:	83 c4 10             	add    $0x10,%esp
      
        memset(buf, 0, sizeof(buf));
  8c:	83 ec 04             	sub    $0x4,%esp
  8f:	68 00 01 00 00       	push   $0x100
  94:	6a 00                	push   $0x0
  96:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  9c:	50                   	push   %eax
  9d:	e8 a3 03 00 00       	call   445 <memset>
  a2:	83 c4 10             	add    $0x10,%esp
    while ( (n = read(0, buf, MAXLINE)) != 0) 
  a5:	83 ec 04             	sub    $0x4,%esp
  a8:	68 00 01 00 00       	push   $0x100
  ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  b3:	50                   	push   %eax
  b4:	6a 00                	push   $0x0
  b6:	e8 3d 05 00 00       	call   5f8 <read>
  bb:	83 c4 10             	add    $0x10,%esp
  be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  c5:	0f 85 5d ff ff ff    	jne    28 <main+0x28>
    }
    
    exit();
  cb:	e8 10 05 00 00       	call   5e0 <exit>

000000d0 <exit_check>:
}

int exit_check(char **tok, int num_tok)
{
  d0:	55                   	push   %ebp
  d1:	89 e5                	mov    %esp,%ebp
  d3:	83 ec 08             	sub    $0x8,%esp
    // your implementation here
    if(!(strcmp(tok[0],"exit"))){
  d6:	8b 45 08             	mov    0x8(%ebp),%eax
  d9:	8b 00                	mov    (%eax),%eax
  db:	83 ec 08             	sub    $0x8,%esp
  de:	68 23 0b 00 00       	push   $0xb23
  e3:	50                   	push   %eax
  e4:	e8 f6 02 00 00       	call   3df <strcmp>
  e9:	83 c4 10             	add    $0x10,%esp
  ec:	85 c0                	test   %eax,%eax
  ee:	75 07                	jne    f7 <exit_check+0x27>
      return 1;
  f0:	b8 01 00 00 00       	mov    $0x1,%eax
  f5:	eb 05                	jmp    fc <exit_check+0x2c>
    }
    else{
      return 0;
  f7:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
  fc:	c9                   	leave  
  fd:	c3                   	ret    

000000fe <process_normal>:

int process_normal(char **tok, int bg)
{
  fe:	55                   	push   %ebp
  ff:	89 e5                	mov    %esp,%ebp
 101:	83 ec 18             	sub    $0x18,%esp
    // your implementation here
    int x=fork();
 104:	e8 cf 04 00 00       	call   5d8 <fork>
 109:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(x>0 && bg<1){
 10c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 110:	7e 10                	jle    122 <process_normal+0x24>
 112:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 116:	7f 0a                	jg     122 <process_normal+0x24>
      x=wait();
 118:	e8 cb 04 00 00       	call   5e8 <wait>
 11d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 120:	eb 54                	jmp    176 <process_normal+0x78>
    }
    else if(x==0){
 122:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 126:	75 33                	jne    15b <process_normal+0x5d>
      if(exec(*tok,tok)==-1){
 128:	8b 45 08             	mov    0x8(%ebp),%eax
 12b:	8b 00                	mov    (%eax),%eax
 12d:	83 ec 08             	sub    $0x8,%esp
 130:	ff 75 08             	pushl  0x8(%ebp)
 133:	50                   	push   %eax
 134:	e8 df 04 00 00       	call   618 <exec>
 139:	83 c4 10             	add    $0x10,%esp
 13c:	83 f8 ff             	cmp    $0xffffffff,%eax
 13f:	75 35                	jne    176 <process_normal+0x78>
        printf(1, "Cannot run this command %s \n", *tok);
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	8b 00                	mov    (%eax),%eax
 146:	83 ec 04             	sub    $0x4,%esp
 149:	50                   	push   %eax
 14a:	68 28 0b 00 00       	push   $0xb28
 14f:	6a 01                	push   $0x1
 151:	e8 0d 06 00 00       	call   763 <printf>
 156:	83 c4 10             	add    $0x10,%esp
 159:	eb 1b                	jmp    176 <process_normal+0x78>
      }
    }
    else if(bg>1){
 15b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
 15f:	7e 15                	jle    176 <process_normal+0x78>
      printf(1, "[pid %d] runs as a background process \n", x);
 161:	83 ec 04             	sub    $0x4,%esp
 164:	ff 75 f4             	pushl  -0xc(%ebp)
 167:	68 48 0b 00 00       	push   $0xb48
 16c:	6a 01                	push   $0x1
 16e:	e8 f0 05 00 00       	call   763 <printf>
 173:	83 c4 10             	add    $0x10,%esp
    }
    // note that exec(*tok, tok) is the right way to invoke exec in xv6
    return 0;
 176:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17b:	c9                   	leave  
 17c:	c3                   	ret    

0000017d <process_one_cmd>:


int process_one_cmd(char* buf)
{
 17d:	55                   	push   %ebp
 17e:	89 e5                	mov    %esp,%ebp
 180:	53                   	push   %ebx
 181:	83 ec 14             	sub    $0x14,%esp
    int i, num_tok;
    char **tok;
    int bg;
    i = (strlen(buf) - 1);
 184:	83 ec 0c             	sub    $0xc,%esp
 187:	ff 75 08             	pushl  0x8(%ebp)
 18a:	e8 8f 02 00 00       	call   41e <strlen>
 18f:	83 c4 10             	add    $0x10,%esp
 192:	83 e8 01             	sub    $0x1,%eax
 195:	89 45 f4             	mov    %eax,-0xc(%ebp)
    num_tok = 1;
 198:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

    while (i)
 19f:	eb 1b                	jmp    1bc <process_one_cmd+0x3f>
    {
        if (buf[i--] == ' ')
 1a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a4:	8d 50 ff             	lea    -0x1(%eax),%edx
 1a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1aa:	89 c2                	mov    %eax,%edx
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	01 d0                	add    %edx,%eax
 1b1:	0f b6 00             	movzbl (%eax),%eax
 1b4:	3c 20                	cmp    $0x20,%al
 1b6:	75 04                	jne    1bc <process_one_cmd+0x3f>
            num_tok++;
 1b8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    while (i)
 1bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c0:	75 df                	jne    1a1 <process_one_cmd+0x24>
    }

    if (!(tok = malloc( (num_tok + 1) *   sizeof (char *)))) 
 1c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1c5:	83 c0 01             	add    $0x1,%eax
 1c8:	c1 e0 02             	shl    $0x2,%eax
 1cb:	83 ec 0c             	sub    $0xc,%esp
 1ce:	50                   	push   %eax
 1cf:	e8 62 08 00 00       	call   a36 <malloc>
 1d4:	83 c4 10             	add    $0x10,%esp
 1d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
 1da:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 1de:	75 17                	jne    1f7 <process_one_cmd+0x7a>
    {
        printf(1, "malloc failed\n");
 1e0:	83 ec 08             	sub    $0x8,%esp
 1e3:	68 70 0b 00 00       	push   $0xb70
 1e8:	6a 01                	push   $0x1
 1ea:	e8 74 05 00 00       	call   763 <printf>
 1ef:	83 c4 10             	add    $0x10,%esp
        exit();
 1f2:	e8 e9 03 00 00       	call   5e0 <exit>
    }        


    i = bg = 0;
 1f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 1fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
 201:	89 45 f4             	mov    %eax,-0xc(%ebp)
    tok[i++] = strtok(buf, " ");
 204:	8b 45 f4             	mov    -0xc(%ebp),%eax
 207:	8d 50 01             	lea    0x1(%eax),%edx
 20a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 20d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 214:	8b 45 e8             	mov    -0x18(%ebp),%eax
 217:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 21a:	83 ec 08             	sub    $0x8,%esp
 21d:	68 7f 0b 00 00       	push   $0xb7f
 222:	ff 75 08             	pushl  0x8(%ebp)
 225:	e8 b7 00 00 00       	call   2e1 <strtok>
 22a:	83 c4 10             	add    $0x10,%esp
 22d:	89 03                	mov    %eax,(%ebx)

    /* check special symbols */
    while ((tok[i] = strtok(NULL, " "))) 
 22f:	eb 3e                	jmp    26f <process_one_cmd+0xf2>
    {
        switch (*tok[i]) 
 231:	8b 45 f4             	mov    -0xc(%ebp),%eax
 234:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 23b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 23e:	01 d0                	add    %edx,%eax
 240:	8b 00                	mov    (%eax),%eax
 242:	0f b6 00             	movzbl (%eax),%eax
 245:	0f be c0             	movsbl %al,%eax
 248:	83 f8 26             	cmp    $0x26,%eax
 24b:	75 1d                	jne    26a <process_one_cmd+0xed>
        {
            case '&':
                bg = i;
 24d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 250:	89 45 ec             	mov    %eax,-0x14(%ebp)
                tok[i] = NULL;
 253:	8b 45 f4             	mov    -0xc(%ebp),%eax
 256:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 25d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 260:	01 d0                	add    %edx,%eax
 262:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                break;
 268:	eb 01                	jmp    26b <process_one_cmd+0xee>

            default:
                // do nothing
                break;
 26a:	90                   	nop
        }   
        i++;
 26b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    while ((tok[i] = strtok(NULL, " "))) 
 26f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 272:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 279:	8b 45 e8             	mov    -0x18(%ebp),%eax
 27c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 27f:	83 ec 08             	sub    $0x8,%esp
 282:	68 7f 0b 00 00       	push   $0xb7f
 287:	6a 00                	push   $0x0
 289:	e8 53 00 00 00       	call   2e1 <strtok>
 28e:	83 c4 10             	add    $0x10,%esp
 291:	89 03                	mov    %eax,(%ebx)
 293:	8b 03                	mov    (%ebx),%eax
 295:	85 c0                	test   %eax,%eax
 297:	75 98                	jne    231 <process_one_cmd+0xb4>
    }

    /*Check buid-in exit command */
    if (exit_check(tok, num_tok))
 299:	83 ec 08             	sub    $0x8,%esp
 29c:	ff 75 f0             	pushl  -0x10(%ebp)
 29f:	ff 75 e8             	pushl  -0x18(%ebp)
 2a2:	e8 29 fe ff ff       	call   d0 <exit_check>
 2a7:	83 c4 10             	add    $0x10,%esp
 2aa:	85 c0                	test   %eax,%eax
 2ac:	74 0a                	je     2b8 <process_one_cmd+0x13b>
    {
        wait();
 2ae:	e8 35 03 00 00       	call   5e8 <wait>
        /*some code here to wait till all children exit() before exit*/
	// your implementation here
        exit();
 2b3:	e8 28 03 00 00       	call   5e0 <exit>
    }

    // your code to check NOT implemented cases
    
    /* to process one command */
    process_normal(tok, bg);
 2b8:	83 ec 08             	sub    $0x8,%esp
 2bb:	ff 75 ec             	pushl  -0x14(%ebp)
 2be:	ff 75 e8             	pushl  -0x18(%ebp)
 2c1:	e8 38 fe ff ff       	call   fe <process_normal>
 2c6:	83 c4 10             	add    $0x10,%esp

    free(tok);
 2c9:	83 ec 0c             	sub    $0xc,%esp
 2cc:	ff 75 e8             	pushl  -0x18(%ebp)
 2cf:	e8 20 06 00 00       	call   8f4 <free>
 2d4:	83 c4 10             	add    $0x10,%esp
    return 0;
 2d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2df:	c9                   	leave  
 2e0:	c3                   	ret    

000002e1 <strtok>:

char *
strtok(s, delim)
    register char *s;
    register const char *delim;
{
 2e1:	55                   	push   %ebp
 2e2:	89 e5                	mov    %esp,%ebp
 2e4:	57                   	push   %edi
 2e5:	56                   	push   %esi
 2e6:	53                   	push   %ebx
 2e7:	83 ec 10             	sub    $0x10,%esp
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
 2ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    register int c, sc;
    char *tok;
    static char *last;


    if (s == NULL && (s = last) == NULL)
 2f0:	85 c0                	test   %eax,%eax
 2f2:	75 10                	jne    304 <strtok+0x23>
 2f4:	a1 70 0e 00 00       	mov    0xe70,%eax
 2f9:	85 c0                	test   %eax,%eax
 2fb:	75 07                	jne    304 <strtok+0x23>
        return (NULL);
 2fd:	b8 00 00 00 00       	mov    $0x0,%eax
 302:	eb 7d                	jmp    381 <strtok+0xa0>

    /*
     * Skip (span) leading delimiters (s += strspn(s, delim), sort of).
     */
cont:
 304:	90                   	nop
    c = *s++;
 305:	89 c2                	mov    %eax,%edx
 307:	8d 42 01             	lea    0x1(%edx),%eax
 30a:	0f b6 12             	movzbl (%edx),%edx
 30d:	0f be f2             	movsbl %dl,%esi
    for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
 310:	89 cf                	mov    %ecx,%edi
 312:	eb 06                	jmp    31a <strtok+0x39>
        if (c == sc)
 314:	39 de                	cmp    %ebx,%esi
 316:	75 02                	jne    31a <strtok+0x39>
            goto cont;
 318:	eb eb                	jmp    305 <strtok+0x24>
    for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
 31a:	89 fa                	mov    %edi,%edx
 31c:	8d 7a 01             	lea    0x1(%edx),%edi
 31f:	0f b6 12             	movzbl (%edx),%edx
 322:	0f be da             	movsbl %dl,%ebx
 325:	85 db                	test   %ebx,%ebx
 327:	75 eb                	jne    314 <strtok+0x33>
    }

    if (c == 0) {        /* no non-delimiter characters */
 329:	85 f6                	test   %esi,%esi
 32b:	75 11                	jne    33e <strtok+0x5d>
        last = NULL;
 32d:	c7 05 70 0e 00 00 00 	movl   $0x0,0xe70
 334:	00 00 00 
        return (NULL);
 337:	b8 00 00 00 00       	mov    $0x0,%eax
 33c:	eb 43                	jmp    381 <strtok+0xa0>
    }
    tok = s - 1;
 33e:	8d 50 ff             	lea    -0x1(%eax),%edx
 341:	89 55 f0             	mov    %edx,-0x10(%ebp)
    /*
     * Scan token (scan for delimiters: s += strcspn(s, delim), sort of).
     * Note that delim must have one NUL; we stop if we see that, too.
     */
    for (;;) {
        c = *s++;
 344:	89 c2                	mov    %eax,%edx
 346:	8d 42 01             	lea    0x1(%edx),%eax
 349:	0f b6 12             	movzbl (%edx),%edx
 34c:	0f be f2             	movsbl %dl,%esi
        spanp = (char *)delim;
 34f:	89 cf                	mov    %ecx,%edi
        do {
            if ((sc = *spanp++) == c) {
 351:	89 fa                	mov    %edi,%edx
 353:	8d 7a 01             	lea    0x1(%edx),%edi
 356:	0f b6 12             	movzbl (%edx),%edx
 359:	0f be da             	movsbl %dl,%ebx
 35c:	39 f3                	cmp    %esi,%ebx
 35e:	75 1b                	jne    37b <strtok+0x9a>
                if (c == 0)
 360:	85 f6                	test   %esi,%esi
 362:	75 07                	jne    36b <strtok+0x8a>
                    s = NULL;
 364:	b8 00 00 00 00       	mov    $0x0,%eax
 369:	eb 06                	jmp    371 <strtok+0x90>
                else
                    s[-1] = 0;
 36b:	8d 50 ff             	lea    -0x1(%eax),%edx
 36e:	c6 02 00             	movb   $0x0,(%edx)
                last = s;
 371:	a3 70 0e 00 00       	mov    %eax,0xe70
                return (tok);
 376:	8b 45 f0             	mov    -0x10(%ebp),%eax
 379:	eb 06                	jmp    381 <strtok+0xa0>
            }
        } while (sc != 0);
 37b:	85 db                	test   %ebx,%ebx
 37d:	75 d2                	jne    351 <strtok+0x70>
        c = *s++;
 37f:	eb c3                	jmp    344 <strtok+0x63>
    }
    /* NOTREACHED */
}
 381:	83 c4 10             	add    $0x10,%esp
 384:	5b                   	pop    %ebx
 385:	5e                   	pop    %esi
 386:	5f                   	pop    %edi
 387:	5d                   	pop    %ebp
 388:	c3                   	ret    

00000389 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 389:	55                   	push   %ebp
 38a:	89 e5                	mov    %esp,%ebp
 38c:	57                   	push   %edi
 38d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 38e:	8b 4d 08             	mov    0x8(%ebp),%ecx
 391:	8b 55 10             	mov    0x10(%ebp),%edx
 394:	8b 45 0c             	mov    0xc(%ebp),%eax
 397:	89 cb                	mov    %ecx,%ebx
 399:	89 df                	mov    %ebx,%edi
 39b:	89 d1                	mov    %edx,%ecx
 39d:	fc                   	cld    
 39e:	f3 aa                	rep stos %al,%es:(%edi)
 3a0:	89 ca                	mov    %ecx,%edx
 3a2:	89 fb                	mov    %edi,%ebx
 3a4:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3a7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3aa:	90                   	nop
 3ab:	5b                   	pop    %ebx
 3ac:	5f                   	pop    %edi
 3ad:	5d                   	pop    %ebp
 3ae:	c3                   	ret    

000003af <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3af:	55                   	push   %ebp
 3b0:	89 e5                	mov    %esp,%ebp
 3b2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3bb:	90                   	nop
 3bc:	8b 55 0c             	mov    0xc(%ebp),%edx
 3bf:	8d 42 01             	lea    0x1(%edx),%eax
 3c2:	89 45 0c             	mov    %eax,0xc(%ebp)
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	8d 48 01             	lea    0x1(%eax),%ecx
 3cb:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3ce:	0f b6 12             	movzbl (%edx),%edx
 3d1:	88 10                	mov    %dl,(%eax)
 3d3:	0f b6 00             	movzbl (%eax),%eax
 3d6:	84 c0                	test   %al,%al
 3d8:	75 e2                	jne    3bc <strcpy+0xd>
    ;
  return os;
 3da:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3dd:	c9                   	leave  
 3de:	c3                   	ret    

000003df <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3df:	55                   	push   %ebp
 3e0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3e2:	eb 08                	jmp    3ec <strcmp+0xd>
    p++, q++;
 3e4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3ec:	8b 45 08             	mov    0x8(%ebp),%eax
 3ef:	0f b6 00             	movzbl (%eax),%eax
 3f2:	84 c0                	test   %al,%al
 3f4:	74 10                	je     406 <strcmp+0x27>
 3f6:	8b 45 08             	mov    0x8(%ebp),%eax
 3f9:	0f b6 10             	movzbl (%eax),%edx
 3fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ff:	0f b6 00             	movzbl (%eax),%eax
 402:	38 c2                	cmp    %al,%dl
 404:	74 de                	je     3e4 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 406:	8b 45 08             	mov    0x8(%ebp),%eax
 409:	0f b6 00             	movzbl (%eax),%eax
 40c:	0f b6 d0             	movzbl %al,%edx
 40f:	8b 45 0c             	mov    0xc(%ebp),%eax
 412:	0f b6 00             	movzbl (%eax),%eax
 415:	0f b6 c0             	movzbl %al,%eax
 418:	29 c2                	sub    %eax,%edx
 41a:	89 d0                	mov    %edx,%eax
}
 41c:	5d                   	pop    %ebp
 41d:	c3                   	ret    

0000041e <strlen>:

uint
strlen(char *s)
{
 41e:	55                   	push   %ebp
 41f:	89 e5                	mov    %esp,%ebp
 421:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 424:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 42b:	eb 04                	jmp    431 <strlen+0x13>
 42d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 431:	8b 55 fc             	mov    -0x4(%ebp),%edx
 434:	8b 45 08             	mov    0x8(%ebp),%eax
 437:	01 d0                	add    %edx,%eax
 439:	0f b6 00             	movzbl (%eax),%eax
 43c:	84 c0                	test   %al,%al
 43e:	75 ed                	jne    42d <strlen+0xf>
    ;
  return n;
 440:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 443:	c9                   	leave  
 444:	c3                   	ret    

00000445 <memset>:

void*
memset(void *dst, int c, uint n)
{
 445:	55                   	push   %ebp
 446:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 448:	8b 45 10             	mov    0x10(%ebp),%eax
 44b:	50                   	push   %eax
 44c:	ff 75 0c             	pushl  0xc(%ebp)
 44f:	ff 75 08             	pushl  0x8(%ebp)
 452:	e8 32 ff ff ff       	call   389 <stosb>
 457:	83 c4 0c             	add    $0xc,%esp
  return dst;
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 45d:	c9                   	leave  
 45e:	c3                   	ret    

0000045f <strchr>:

char*
strchr(const char *s, char c)
{
 45f:	55                   	push   %ebp
 460:	89 e5                	mov    %esp,%ebp
 462:	83 ec 04             	sub    $0x4,%esp
 465:	8b 45 0c             	mov    0xc(%ebp),%eax
 468:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 46b:	eb 14                	jmp    481 <strchr+0x22>
    if(*s == c)
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	0f b6 00             	movzbl (%eax),%eax
 473:	38 45 fc             	cmp    %al,-0x4(%ebp)
 476:	75 05                	jne    47d <strchr+0x1e>
      return (char*)s;
 478:	8b 45 08             	mov    0x8(%ebp),%eax
 47b:	eb 13                	jmp    490 <strchr+0x31>
  for(; *s; s++)
 47d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	0f b6 00             	movzbl (%eax),%eax
 487:	84 c0                	test   %al,%al
 489:	75 e2                	jne    46d <strchr+0xe>
  return 0;
 48b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 490:	c9                   	leave  
 491:	c3                   	ret    

00000492 <gets>:

char*
gets(char *buf, int max)
{
 492:	55                   	push   %ebp
 493:	89 e5                	mov    %esp,%ebp
 495:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 498:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 49f:	eb 42                	jmp    4e3 <gets+0x51>
    cc = read(0, &c, 1);
 4a1:	83 ec 04             	sub    $0x4,%esp
 4a4:	6a 01                	push   $0x1
 4a6:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4a9:	50                   	push   %eax
 4aa:	6a 00                	push   $0x0
 4ac:	e8 47 01 00 00       	call   5f8 <read>
 4b1:	83 c4 10             	add    $0x10,%esp
 4b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4bb:	7e 33                	jle    4f0 <gets+0x5e>
      break;
    buf[i++] = c;
 4bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c0:	8d 50 01             	lea    0x1(%eax),%edx
 4c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c6:	89 c2                	mov    %eax,%edx
 4c8:	8b 45 08             	mov    0x8(%ebp),%eax
 4cb:	01 c2                	add    %eax,%edx
 4cd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d1:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4d3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d7:	3c 0a                	cmp    $0xa,%al
 4d9:	74 16                	je     4f1 <gets+0x5f>
 4db:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4df:	3c 0d                	cmp    $0xd,%al
 4e1:	74 0e                	je     4f1 <gets+0x5f>
  for(i=0; i+1 < max; ){
 4e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e6:	83 c0 01             	add    $0x1,%eax
 4e9:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4ec:	7f b3                	jg     4a1 <gets+0xf>
 4ee:	eb 01                	jmp    4f1 <gets+0x5f>
      break;
 4f0:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4f4:	8b 45 08             	mov    0x8(%ebp),%eax
 4f7:	01 d0                	add    %edx,%eax
 4f9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4ff:	c9                   	leave  
 500:	c3                   	ret    

00000501 <stat>:

int
stat(char *n, struct stat *st)
{
 501:	55                   	push   %ebp
 502:	89 e5                	mov    %esp,%ebp
 504:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 507:	83 ec 08             	sub    $0x8,%esp
 50a:	6a 00                	push   $0x0
 50c:	ff 75 08             	pushl  0x8(%ebp)
 50f:	e8 0c 01 00 00       	call   620 <open>
 514:	83 c4 10             	add    $0x10,%esp
 517:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 51a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51e:	79 07                	jns    527 <stat+0x26>
    return -1;
 520:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 525:	eb 25                	jmp    54c <stat+0x4b>
  r = fstat(fd, st);
 527:	83 ec 08             	sub    $0x8,%esp
 52a:	ff 75 0c             	pushl  0xc(%ebp)
 52d:	ff 75 f4             	pushl  -0xc(%ebp)
 530:	e8 03 01 00 00       	call   638 <fstat>
 535:	83 c4 10             	add    $0x10,%esp
 538:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 53b:	83 ec 0c             	sub    $0xc,%esp
 53e:	ff 75 f4             	pushl  -0xc(%ebp)
 541:	e8 c2 00 00 00       	call   608 <close>
 546:	83 c4 10             	add    $0x10,%esp
  return r;
 549:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 54c:	c9                   	leave  
 54d:	c3                   	ret    

0000054e <atoi>:

int
atoi(const char *s)
{
 54e:	55                   	push   %ebp
 54f:	89 e5                	mov    %esp,%ebp
 551:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 554:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 55b:	eb 25                	jmp    582 <atoi+0x34>
    n = n*10 + *s++ - '0';
 55d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 560:	89 d0                	mov    %edx,%eax
 562:	c1 e0 02             	shl    $0x2,%eax
 565:	01 d0                	add    %edx,%eax
 567:	01 c0                	add    %eax,%eax
 569:	89 c1                	mov    %eax,%ecx
 56b:	8b 45 08             	mov    0x8(%ebp),%eax
 56e:	8d 50 01             	lea    0x1(%eax),%edx
 571:	89 55 08             	mov    %edx,0x8(%ebp)
 574:	0f b6 00             	movzbl (%eax),%eax
 577:	0f be c0             	movsbl %al,%eax
 57a:	01 c8                	add    %ecx,%eax
 57c:	83 e8 30             	sub    $0x30,%eax
 57f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 582:	8b 45 08             	mov    0x8(%ebp),%eax
 585:	0f b6 00             	movzbl (%eax),%eax
 588:	3c 2f                	cmp    $0x2f,%al
 58a:	7e 0a                	jle    596 <atoi+0x48>
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
 58f:	0f b6 00             	movzbl (%eax),%eax
 592:	3c 39                	cmp    $0x39,%al
 594:	7e c7                	jle    55d <atoi+0xf>
  return n;
 596:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 599:	c9                   	leave  
 59a:	c3                   	ret    

0000059b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 59b:	55                   	push   %ebp
 59c:	89 e5                	mov    %esp,%ebp
 59e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 5a1:	8b 45 08             	mov    0x8(%ebp),%eax
 5a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5ad:	eb 17                	jmp    5c6 <memmove+0x2b>
    *dst++ = *src++;
 5af:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5b2:	8d 42 01             	lea    0x1(%edx),%eax
 5b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5bb:	8d 48 01             	lea    0x1(%eax),%ecx
 5be:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5c1:	0f b6 12             	movzbl (%edx),%edx
 5c4:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5c6:	8b 45 10             	mov    0x10(%ebp),%eax
 5c9:	8d 50 ff             	lea    -0x1(%eax),%edx
 5cc:	89 55 10             	mov    %edx,0x10(%ebp)
 5cf:	85 c0                	test   %eax,%eax
 5d1:	7f dc                	jg     5af <memmove+0x14>
  return vdst;
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5d6:	c9                   	leave  
 5d7:	c3                   	ret    

000005d8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5d8:	b8 01 00 00 00       	mov    $0x1,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <exit>:
SYSCALL(exit)
 5e0:	b8 02 00 00 00       	mov    $0x2,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <wait>:
SYSCALL(wait)
 5e8:	b8 03 00 00 00       	mov    $0x3,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <pipe>:
SYSCALL(pipe)
 5f0:	b8 04 00 00 00       	mov    $0x4,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <read>:
SYSCALL(read)
 5f8:	b8 05 00 00 00       	mov    $0x5,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <write>:
SYSCALL(write)
 600:	b8 10 00 00 00       	mov    $0x10,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <close>:
SYSCALL(close)
 608:	b8 15 00 00 00       	mov    $0x15,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <kill>:
SYSCALL(kill)
 610:	b8 06 00 00 00       	mov    $0x6,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <exec>:
SYSCALL(exec)
 618:	b8 07 00 00 00       	mov    $0x7,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <open>:
SYSCALL(open)
 620:	b8 0f 00 00 00       	mov    $0xf,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <mknod>:
SYSCALL(mknod)
 628:	b8 11 00 00 00       	mov    $0x11,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <unlink>:
SYSCALL(unlink)
 630:	b8 12 00 00 00       	mov    $0x12,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <fstat>:
SYSCALL(fstat)
 638:	b8 08 00 00 00       	mov    $0x8,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <link>:
SYSCALL(link)
 640:	b8 13 00 00 00       	mov    $0x13,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <mkdir>:
SYSCALL(mkdir)
 648:	b8 14 00 00 00       	mov    $0x14,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <chdir>:
SYSCALL(chdir)
 650:	b8 09 00 00 00       	mov    $0x9,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <dup>:
SYSCALL(dup)
 658:	b8 0a 00 00 00       	mov    $0xa,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <getpid>:
SYSCALL(getpid)
 660:	b8 0b 00 00 00       	mov    $0xb,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <sbrk>:
SYSCALL(sbrk)
 668:	b8 0c 00 00 00       	mov    $0xc,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <sleep>:
SYSCALL(sleep)
 670:	b8 0d 00 00 00       	mov    $0xd,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <uptime>:
SYSCALL(uptime)
 678:	b8 0e 00 00 00       	mov    $0xe,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <enable_sched_trace>:
SYSCALL(enable_sched_trace)
 680:	b8 16 00 00 00       	mov    $0x16,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <uprog_shut>:
SYSCALL(uprog_shut)
 688:	b8 17 00 00 00       	mov    $0x17,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 690:	55                   	push   %ebp
 691:	89 e5                	mov    %esp,%ebp
 693:	83 ec 18             	sub    $0x18,%esp
 696:	8b 45 0c             	mov    0xc(%ebp),%eax
 699:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 69c:	83 ec 04             	sub    $0x4,%esp
 69f:	6a 01                	push   $0x1
 6a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6a4:	50                   	push   %eax
 6a5:	ff 75 08             	pushl  0x8(%ebp)
 6a8:	e8 53 ff ff ff       	call   600 <write>
 6ad:	83 c4 10             	add    $0x10,%esp
}
 6b0:	90                   	nop
 6b1:	c9                   	leave  
 6b2:	c3                   	ret    

000006b3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6b3:	55                   	push   %ebp
 6b4:	89 e5                	mov    %esp,%ebp
 6b6:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6b9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6c0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6c4:	74 17                	je     6dd <printint+0x2a>
 6c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6ca:	79 11                	jns    6dd <printint+0x2a>
    neg = 1;
 6cc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d6:	f7 d8                	neg    %eax
 6d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6db:	eb 06                	jmp    6e3 <printint+0x30>
  } else {
    x = xx;
 6dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f0:	ba 00 00 00 00       	mov    $0x0,%edx
 6f5:	f7 f1                	div    %ecx
 6f7:	89 d1                	mov    %edx,%ecx
 6f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fc:	8d 50 01             	lea    0x1(%eax),%edx
 6ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
 702:	0f b6 91 5c 0e 00 00 	movzbl 0xe5c(%ecx),%edx
 709:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 70d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 710:	8b 45 ec             	mov    -0x14(%ebp),%eax
 713:	ba 00 00 00 00       	mov    $0x0,%edx
 718:	f7 f1                	div    %ecx
 71a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 71d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 721:	75 c7                	jne    6ea <printint+0x37>
  if(neg)
 723:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 727:	74 2d                	je     756 <printint+0xa3>
    buf[i++] = '-';
 729:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72c:	8d 50 01             	lea    0x1(%eax),%edx
 72f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 732:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 737:	eb 1d                	jmp    756 <printint+0xa3>
    putc(fd, buf[i]);
 739:	8d 55 dc             	lea    -0x24(%ebp),%edx
 73c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73f:	01 d0                	add    %edx,%eax
 741:	0f b6 00             	movzbl (%eax),%eax
 744:	0f be c0             	movsbl %al,%eax
 747:	83 ec 08             	sub    $0x8,%esp
 74a:	50                   	push   %eax
 74b:	ff 75 08             	pushl  0x8(%ebp)
 74e:	e8 3d ff ff ff       	call   690 <putc>
 753:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 756:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 75a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 75e:	79 d9                	jns    739 <printint+0x86>
}
 760:	90                   	nop
 761:	c9                   	leave  
 762:	c3                   	ret    

00000763 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 763:	55                   	push   %ebp
 764:	89 e5                	mov    %esp,%ebp
 766:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 769:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 770:	8d 45 0c             	lea    0xc(%ebp),%eax
 773:	83 c0 04             	add    $0x4,%eax
 776:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 779:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 780:	e9 59 01 00 00       	jmp    8de <printf+0x17b>
    c = fmt[i] & 0xff;
 785:	8b 55 0c             	mov    0xc(%ebp),%edx
 788:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78b:	01 d0                	add    %edx,%eax
 78d:	0f b6 00             	movzbl (%eax),%eax
 790:	0f be c0             	movsbl %al,%eax
 793:	25 ff 00 00 00       	and    $0xff,%eax
 798:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 79b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 79f:	75 2c                	jne    7cd <printf+0x6a>
      if(c == '%'){
 7a1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7a5:	75 0c                	jne    7b3 <printf+0x50>
        state = '%';
 7a7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7ae:	e9 27 01 00 00       	jmp    8da <printf+0x177>
      } else {
        putc(fd, c);
 7b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b6:	0f be c0             	movsbl %al,%eax
 7b9:	83 ec 08             	sub    $0x8,%esp
 7bc:	50                   	push   %eax
 7bd:	ff 75 08             	pushl  0x8(%ebp)
 7c0:	e8 cb fe ff ff       	call   690 <putc>
 7c5:	83 c4 10             	add    $0x10,%esp
 7c8:	e9 0d 01 00 00       	jmp    8da <printf+0x177>
      }
    } else if(state == '%'){
 7cd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7d1:	0f 85 03 01 00 00    	jne    8da <printf+0x177>
      if(c == 'd'){
 7d7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7db:	75 1e                	jne    7fb <printf+0x98>
        printint(fd, *ap, 10, 1);
 7dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e0:	8b 00                	mov    (%eax),%eax
 7e2:	6a 01                	push   $0x1
 7e4:	6a 0a                	push   $0xa
 7e6:	50                   	push   %eax
 7e7:	ff 75 08             	pushl  0x8(%ebp)
 7ea:	e8 c4 fe ff ff       	call   6b3 <printint>
 7ef:	83 c4 10             	add    $0x10,%esp
        ap++;
 7f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f6:	e9 d8 00 00 00       	jmp    8d3 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7fb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ff:	74 06                	je     807 <printf+0xa4>
 801:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 805:	75 1e                	jne    825 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 807:	8b 45 e8             	mov    -0x18(%ebp),%eax
 80a:	8b 00                	mov    (%eax),%eax
 80c:	6a 00                	push   $0x0
 80e:	6a 10                	push   $0x10
 810:	50                   	push   %eax
 811:	ff 75 08             	pushl  0x8(%ebp)
 814:	e8 9a fe ff ff       	call   6b3 <printint>
 819:	83 c4 10             	add    $0x10,%esp
        ap++;
 81c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 820:	e9 ae 00 00 00       	jmp    8d3 <printf+0x170>
      } else if(c == 's'){
 825:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 829:	75 43                	jne    86e <printf+0x10b>
        s = (char*)*ap;
 82b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 82e:	8b 00                	mov    (%eax),%eax
 830:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 833:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 837:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 83b:	75 25                	jne    862 <printf+0xff>
          s = "(null)";
 83d:	c7 45 f4 81 0b 00 00 	movl   $0xb81,-0xc(%ebp)
        while(*s != 0){
 844:	eb 1c                	jmp    862 <printf+0xff>
          putc(fd, *s);
 846:	8b 45 f4             	mov    -0xc(%ebp),%eax
 849:	0f b6 00             	movzbl (%eax),%eax
 84c:	0f be c0             	movsbl %al,%eax
 84f:	83 ec 08             	sub    $0x8,%esp
 852:	50                   	push   %eax
 853:	ff 75 08             	pushl  0x8(%ebp)
 856:	e8 35 fe ff ff       	call   690 <putc>
 85b:	83 c4 10             	add    $0x10,%esp
          s++;
 85e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 862:	8b 45 f4             	mov    -0xc(%ebp),%eax
 865:	0f b6 00             	movzbl (%eax),%eax
 868:	84 c0                	test   %al,%al
 86a:	75 da                	jne    846 <printf+0xe3>
 86c:	eb 65                	jmp    8d3 <printf+0x170>
        }
      } else if(c == 'c'){
 86e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 872:	75 1d                	jne    891 <printf+0x12e>
        putc(fd, *ap);
 874:	8b 45 e8             	mov    -0x18(%ebp),%eax
 877:	8b 00                	mov    (%eax),%eax
 879:	0f be c0             	movsbl %al,%eax
 87c:	83 ec 08             	sub    $0x8,%esp
 87f:	50                   	push   %eax
 880:	ff 75 08             	pushl  0x8(%ebp)
 883:	e8 08 fe ff ff       	call   690 <putc>
 888:	83 c4 10             	add    $0x10,%esp
        ap++;
 88b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 88f:	eb 42                	jmp    8d3 <printf+0x170>
      } else if(c == '%'){
 891:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 895:	75 17                	jne    8ae <printf+0x14b>
        putc(fd, c);
 897:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 89a:	0f be c0             	movsbl %al,%eax
 89d:	83 ec 08             	sub    $0x8,%esp
 8a0:	50                   	push   %eax
 8a1:	ff 75 08             	pushl  0x8(%ebp)
 8a4:	e8 e7 fd ff ff       	call   690 <putc>
 8a9:	83 c4 10             	add    $0x10,%esp
 8ac:	eb 25                	jmp    8d3 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8ae:	83 ec 08             	sub    $0x8,%esp
 8b1:	6a 25                	push   $0x25
 8b3:	ff 75 08             	pushl  0x8(%ebp)
 8b6:	e8 d5 fd ff ff       	call   690 <putc>
 8bb:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c1:	0f be c0             	movsbl %al,%eax
 8c4:	83 ec 08             	sub    $0x8,%esp
 8c7:	50                   	push   %eax
 8c8:	ff 75 08             	pushl  0x8(%ebp)
 8cb:	e8 c0 fd ff ff       	call   690 <putc>
 8d0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8de:	8b 55 0c             	mov    0xc(%ebp),%edx
 8e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e4:	01 d0                	add    %edx,%eax
 8e6:	0f b6 00             	movzbl (%eax),%eax
 8e9:	84 c0                	test   %al,%al
 8eb:	0f 85 94 fe ff ff    	jne    785 <printf+0x22>
    }
  }
}
 8f1:	90                   	nop
 8f2:	c9                   	leave  
 8f3:	c3                   	ret    

000008f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f4:	55                   	push   %ebp
 8f5:	89 e5                	mov    %esp,%ebp
 8f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8fa:	8b 45 08             	mov    0x8(%ebp),%eax
 8fd:	83 e8 08             	sub    $0x8,%eax
 900:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 903:	a1 7c 0e 00 00       	mov    0xe7c,%eax
 908:	89 45 fc             	mov    %eax,-0x4(%ebp)
 90b:	eb 24                	jmp    931 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 00                	mov    (%eax),%eax
 912:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 915:	72 12                	jb     929 <free+0x35>
 917:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 91d:	77 24                	ja     943 <free+0x4f>
 91f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 922:	8b 00                	mov    (%eax),%eax
 924:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 927:	72 1a                	jb     943 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 931:	8b 45 f8             	mov    -0x8(%ebp),%eax
 934:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 937:	76 d4                	jbe    90d <free+0x19>
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 941:	73 ca                	jae    90d <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	8b 40 04             	mov    0x4(%eax),%eax
 949:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 950:	8b 45 f8             	mov    -0x8(%ebp),%eax
 953:	01 c2                	add    %eax,%edx
 955:	8b 45 fc             	mov    -0x4(%ebp),%eax
 958:	8b 00                	mov    (%eax),%eax
 95a:	39 c2                	cmp    %eax,%edx
 95c:	75 24                	jne    982 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 95e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 961:	8b 50 04             	mov    0x4(%eax),%edx
 964:	8b 45 fc             	mov    -0x4(%ebp),%eax
 967:	8b 00                	mov    (%eax),%eax
 969:	8b 40 04             	mov    0x4(%eax),%eax
 96c:	01 c2                	add    %eax,%edx
 96e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 971:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 974:	8b 45 fc             	mov    -0x4(%ebp),%eax
 977:	8b 00                	mov    (%eax),%eax
 979:	8b 10                	mov    (%eax),%edx
 97b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97e:	89 10                	mov    %edx,(%eax)
 980:	eb 0a                	jmp    98c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 982:	8b 45 fc             	mov    -0x4(%ebp),%eax
 985:	8b 10                	mov    (%eax),%edx
 987:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 98c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98f:	8b 40 04             	mov    0x4(%eax),%eax
 992:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 999:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99c:	01 d0                	add    %edx,%eax
 99e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9a1:	75 20                	jne    9c3 <free+0xcf>
    p->s.size += bp->s.size;
 9a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a6:	8b 50 04             	mov    0x4(%eax),%edx
 9a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ac:	8b 40 04             	mov    0x4(%eax),%eax
 9af:	01 c2                	add    %eax,%edx
 9b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ba:	8b 10                	mov    (%eax),%edx
 9bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bf:	89 10                	mov    %edx,(%eax)
 9c1:	eb 08                	jmp    9cb <free+0xd7>
  } else
    p->s.ptr = bp;
 9c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9c9:	89 10                	mov    %edx,(%eax)
  freep = p;
 9cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ce:	a3 7c 0e 00 00       	mov    %eax,0xe7c
}
 9d3:	90                   	nop
 9d4:	c9                   	leave  
 9d5:	c3                   	ret    

000009d6 <morecore>:

static Header*
morecore(uint nu)
{
 9d6:	55                   	push   %ebp
 9d7:	89 e5                	mov    %esp,%ebp
 9d9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9dc:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9e3:	77 07                	ja     9ec <morecore+0x16>
    nu = 4096;
 9e5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9ec:	8b 45 08             	mov    0x8(%ebp),%eax
 9ef:	c1 e0 03             	shl    $0x3,%eax
 9f2:	83 ec 0c             	sub    $0xc,%esp
 9f5:	50                   	push   %eax
 9f6:	e8 6d fc ff ff       	call   668 <sbrk>
 9fb:	83 c4 10             	add    $0x10,%esp
 9fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a01:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a05:	75 07                	jne    a0e <morecore+0x38>
    return 0;
 a07:	b8 00 00 00 00       	mov    $0x0,%eax
 a0c:	eb 26                	jmp    a34 <morecore+0x5e>
  hp = (Header*)p;
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a17:	8b 55 08             	mov    0x8(%ebp),%edx
 a1a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a20:	83 c0 08             	add    $0x8,%eax
 a23:	83 ec 0c             	sub    $0xc,%esp
 a26:	50                   	push   %eax
 a27:	e8 c8 fe ff ff       	call   8f4 <free>
 a2c:	83 c4 10             	add    $0x10,%esp
  return freep;
 a2f:	a1 7c 0e 00 00       	mov    0xe7c,%eax
}
 a34:	c9                   	leave  
 a35:	c3                   	ret    

00000a36 <malloc>:

void*
malloc(uint nbytes)
{
 a36:	55                   	push   %ebp
 a37:	89 e5                	mov    %esp,%ebp
 a39:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3c:	8b 45 08             	mov    0x8(%ebp),%eax
 a3f:	83 c0 07             	add    $0x7,%eax
 a42:	c1 e8 03             	shr    $0x3,%eax
 a45:	83 c0 01             	add    $0x1,%eax
 a48:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a4b:	a1 7c 0e 00 00       	mov    0xe7c,%eax
 a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a53:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a57:	75 23                	jne    a7c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a59:	c7 45 f0 74 0e 00 00 	movl   $0xe74,-0x10(%ebp)
 a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a63:	a3 7c 0e 00 00       	mov    %eax,0xe7c
 a68:	a1 7c 0e 00 00       	mov    0xe7c,%eax
 a6d:	a3 74 0e 00 00       	mov    %eax,0xe74
    base.s.size = 0;
 a72:	c7 05 78 0e 00 00 00 	movl   $0x0,0xe78
 a79:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7f:	8b 00                	mov    (%eax),%eax
 a81:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a87:	8b 40 04             	mov    0x4(%eax),%eax
 a8a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a8d:	77 4d                	ja     adc <malloc+0xa6>
      if(p->s.size == nunits)
 a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a92:	8b 40 04             	mov    0x4(%eax),%eax
 a95:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a98:	75 0c                	jne    aa6 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9d:	8b 10                	mov    (%eax),%edx
 a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa2:	89 10                	mov    %edx,(%eax)
 aa4:	eb 26                	jmp    acc <malloc+0x96>
      else {
        p->s.size -= nunits;
 aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa9:	8b 40 04             	mov    0x4(%eax),%eax
 aac:	2b 45 ec             	sub    -0x14(%ebp),%eax
 aaf:	89 c2                	mov    %eax,%edx
 ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aba:	8b 40 04             	mov    0x4(%eax),%eax
 abd:	c1 e0 03             	shl    $0x3,%eax
 ac0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ac9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acf:	a3 7c 0e 00 00       	mov    %eax,0xe7c
      return (void*)(p + 1);
 ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad7:	83 c0 08             	add    $0x8,%eax
 ada:	eb 3b                	jmp    b17 <malloc+0xe1>
    }
    if(p == freep)
 adc:	a1 7c 0e 00 00       	mov    0xe7c,%eax
 ae1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ae4:	75 1e                	jne    b04 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ae6:	83 ec 0c             	sub    $0xc,%esp
 ae9:	ff 75 ec             	pushl  -0x14(%ebp)
 aec:	e8 e5 fe ff ff       	call   9d6 <morecore>
 af1:	83 c4 10             	add    $0x10,%esp
 af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 af7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 afb:	75 07                	jne    b04 <malloc+0xce>
        return 0;
 afd:	b8 00 00 00 00       	mov    $0x0,%eax
 b02:	eb 13                	jmp    b17 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b07:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0d:	8b 00                	mov    (%eax),%eax
 b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b12:	e9 6d ff ff ff       	jmp    a84 <malloc+0x4e>
  }
}
 b17:	c9                   	leave  
 b18:	c3                   	ret    
