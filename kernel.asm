
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 60 c6 10 80       	mov    $0x8010c660,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 98 38 10 80       	mov    $0x80103898,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 14 86 10 80       	push   $0x80108614
80100042:	68 60 c6 10 80       	push   $0x8010c660
80100047:	e8 f6 4f 00 00       	call   80105042 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 05 11 80       	mov    0x80110574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 05 11 80       	mov    %eax,0x80110574
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 05 11 80       	mov    $0x80110564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 c6 10 80       	push   $0x8010c660
801000c1:	e8 9e 4f 00 00       	call   80105064 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 05 11 80       	mov    0x80110574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	39 45 08             	cmp    %eax,0x8(%ebp)
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 c6 10 80       	push   $0x8010c660
8010010c:	e8 ba 4f 00 00       	call   801050cb <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 c6 10 80       	push   $0x8010c660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 3f 4c 00 00       	call   80104d6b <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 05 11 80       	mov    0x80110570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 c6 10 80       	push   $0x8010c660
80100188:	e8 3e 4f 00 00       	call   801050cb <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 1b 86 10 80       	push   $0x8010861b
801001af:	e8 b3 03 00 00       	call   80100567 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 2a 27 00 00       	call   80102911 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 2c 86 10 80       	push   $0x8010862c
80100209:	e8 59 03 00 00       	call   80100567 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 e9 26 00 00       	call   80102911 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 33 86 10 80       	push   $0x80108633
80100248:	e8 1a 03 00 00       	call   80100567 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 c6 10 80       	push   $0x8010c660
80100255:	e8 0a 4e 00 00       	call   80105064 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 05 11 80       	mov    0x80110574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 98 4b 00 00       	call   80104e56 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 c6 10 80       	push   $0x8010c660
801002c9:	e8 fd 4d 00 00       	call   801050cb <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 45 08             	mov    0x8(%ebp),%eax
801002fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801002fd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100301:	89 d0                	mov    %edx,%eax
80100303:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010030a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030e:	ee                   	out    %al,(%dx)
}
8010030f:	90                   	nop
80100310:	c9                   	leave  
80100311:	c3                   	ret    

80100312 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100312:	55                   	push   %ebp
80100313:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100315:	fa                   	cli    
}
80100316:	90                   	nop
80100317:	5d                   	pop    %ebp
80100318:	c3                   	ret    

80100319 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100319:	55                   	push   %ebp
8010031a:	89 e5                	mov    %esp,%ebp
8010031c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100323:	74 1c                	je     80100341 <printint+0x28>
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c1 e8 1f             	shr    $0x1f,%eax
8010032b:	0f b6 c0             	movzbl %al,%eax
8010032e:	89 45 10             	mov    %eax,0x10(%ebp)
80100331:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100335:	74 0a                	je     80100341 <printint+0x28>
    x = -xx;
80100337:	8b 45 08             	mov    0x8(%ebp),%eax
8010033a:	f7 d8                	neg    %eax
8010033c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033f:	eb 06                	jmp    80100347 <printint+0x2e>
  else
    x = xx;
80100341:	8b 45 08             	mov    0x8(%ebp),%eax
80100344:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100347:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100351:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100354:	ba 00 00 00 00       	mov    $0x0,%edx
80100359:	f7 f1                	div    %ecx
8010035b:	89 d1                	mov    %edx,%ecx
8010035d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100360:	8d 50 01             	lea    0x1(%eax),%edx
80100363:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100366:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
8010036d:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
80100371:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100377:	ba 00 00 00 00       	mov    $0x0,%edx
8010037c:	f7 f1                	div    %ecx
8010037e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100381:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100385:	75 c7                	jne    8010034e <printint+0x35>

  if(sign)
80100387:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038b:	74 2a                	je     801003b7 <printint+0x9e>
    buf[i++] = '-';
8010038d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100390:	8d 50 01             	lea    0x1(%eax),%edx
80100393:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100396:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039b:	eb 1a                	jmp    801003b7 <printint+0x9e>
    consputc(buf[i]);
8010039d:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a3:	01 d0                	add    %edx,%eax
801003a5:	0f b6 00             	movzbl (%eax),%eax
801003a8:	0f be c0             	movsbl %al,%eax
801003ab:	83 ec 0c             	sub    $0xc,%esp
801003ae:	50                   	push   %eax
801003af:	e8 e7 03 00 00       	call   8010079b <consputc>
801003b4:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003b7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003bf:	79 dc                	jns    8010039d <printint+0x84>
}
801003c1:	90                   	nop
801003c2:	c9                   	leave  
801003c3:	c3                   	ret    

801003c4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c4:	55                   	push   %ebp
801003c5:	89 e5                	mov    %esp,%ebp
801003c7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003ca:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d6:	74 10                	je     801003e8 <cprintf+0x24>
    acquire(&cons.lock);
801003d8:	83 ec 0c             	sub    $0xc,%esp
801003db:	68 c0 b5 10 80       	push   $0x8010b5c0
801003e0:	e8 7f 4c 00 00       	call   80105064 <acquire>
801003e5:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003e8:	8b 45 08             	mov    0x8(%ebp),%eax
801003eb:	85 c0                	test   %eax,%eax
801003ed:	75 0d                	jne    801003fc <cprintf+0x38>
    panic("null fmt");
801003ef:	83 ec 0c             	sub    $0xc,%esp
801003f2:	68 3a 86 10 80       	push   $0x8010863a
801003f7:	e8 6b 01 00 00       	call   80100567 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fc:	8d 45 0c             	lea    0xc(%ebp),%eax
801003ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100402:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100409:	e9 1d 01 00 00       	jmp    8010052b <cprintf+0x167>
    if(c != '%'){
8010040e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100412:	74 13                	je     80100427 <cprintf+0x63>
      consputc(c);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041a:	e8 7c 03 00 00       	call   8010079b <consputc>
8010041f:	83 c4 10             	add    $0x10,%esp
      continue;
80100422:	e9 00 01 00 00       	jmp    80100527 <cprintf+0x163>
    }
    c = fmt[++i] & 0xff;
80100427:	8b 55 08             	mov    0x8(%ebp),%edx
8010042a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010042e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100431:	01 d0                	add    %edx,%eax
80100433:	0f b6 00             	movzbl (%eax),%eax
80100436:	0f be c0             	movsbl %al,%eax
80100439:	25 ff 00 00 00       	and    $0xff,%eax
8010043e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100441:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100445:	0f 84 02 01 00 00    	je     8010054d <cprintf+0x189>
      break;
    switch(c){
8010044b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010044f:	74 4c                	je     8010049d <cprintf+0xd9>
80100451:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100455:	7f 15                	jg     8010046c <cprintf+0xa8>
80100457:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010045b:	0f 84 9b 00 00 00    	je     801004fc <cprintf+0x138>
80100461:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
80100465:	74 16                	je     8010047d <cprintf+0xb9>
80100467:	e9 9f 00 00 00       	jmp    8010050b <cprintf+0x147>
8010046c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100470:	74 48                	je     801004ba <cprintf+0xf6>
80100472:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100476:	74 25                	je     8010049d <cprintf+0xd9>
80100478:	e9 8e 00 00 00       	jmp    8010050b <cprintf+0x147>
    case 'd':
      printint(*argp++, 10, 1);
8010047d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100480:	8d 50 04             	lea    0x4(%eax),%edx
80100483:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100486:	8b 00                	mov    (%eax),%eax
80100488:	83 ec 04             	sub    $0x4,%esp
8010048b:	6a 01                	push   $0x1
8010048d:	6a 0a                	push   $0xa
8010048f:	50                   	push   %eax
80100490:	e8 84 fe ff ff       	call   80100319 <printint>
80100495:	83 c4 10             	add    $0x10,%esp
      break;
80100498:	e9 8a 00 00 00       	jmp    80100527 <cprintf+0x163>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004a0:	8d 50 04             	lea    0x4(%eax),%edx
801004a3:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a6:	8b 00                	mov    (%eax),%eax
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	6a 00                	push   $0x0
801004ad:	6a 10                	push   $0x10
801004af:	50                   	push   %eax
801004b0:	e8 64 fe ff ff       	call   80100319 <printint>
801004b5:	83 c4 10             	add    $0x10,%esp
      break;
801004b8:	eb 6d                	jmp    80100527 <cprintf+0x163>
    case 's':
      if((s = (char*)*argp++) == 0)
801004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bd:	8d 50 04             	lea    0x4(%eax),%edx
801004c0:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c3:	8b 00                	mov    (%eax),%eax
801004c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cc:	75 22                	jne    801004f0 <cprintf+0x12c>
        s = "(null)";
801004ce:	c7 45 ec 43 86 10 80 	movl   $0x80108643,-0x14(%ebp)
      for(; *s; s++)
801004d5:	eb 19                	jmp    801004f0 <cprintf+0x12c>
        consputc(*s);
801004d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004da:	0f b6 00             	movzbl (%eax),%eax
801004dd:	0f be c0             	movsbl %al,%eax
801004e0:	83 ec 0c             	sub    $0xc,%esp
801004e3:	50                   	push   %eax
801004e4:	e8 b2 02 00 00       	call   8010079b <consputc>
801004e9:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
801004ec:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f3:	0f b6 00             	movzbl (%eax),%eax
801004f6:	84 c0                	test   %al,%al
801004f8:	75 dd                	jne    801004d7 <cprintf+0x113>
      break;
801004fa:	eb 2b                	jmp    80100527 <cprintf+0x163>
    case '%':
      consputc('%');
801004fc:	83 ec 0c             	sub    $0xc,%esp
801004ff:	6a 25                	push   $0x25
80100501:	e8 95 02 00 00       	call   8010079b <consputc>
80100506:	83 c4 10             	add    $0x10,%esp
      break;
80100509:	eb 1c                	jmp    80100527 <cprintf+0x163>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050b:	83 ec 0c             	sub    $0xc,%esp
8010050e:	6a 25                	push   $0x25
80100510:	e8 86 02 00 00       	call   8010079b <consputc>
80100515:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100518:	83 ec 0c             	sub    $0xc,%esp
8010051b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051e:	e8 78 02 00 00       	call   8010079b <consputc>
80100523:	83 c4 10             	add    $0x10,%esp
      break;
80100526:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100527:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052b:	8b 55 08             	mov    0x8(%ebp),%edx
8010052e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100531:	01 d0                	add    %edx,%eax
80100533:	0f b6 00             	movzbl (%eax),%eax
80100536:	0f be c0             	movsbl %al,%eax
80100539:	25 ff 00 00 00       	and    $0xff,%eax
8010053e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100541:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100545:	0f 85 c3 fe ff ff    	jne    8010040e <cprintf+0x4a>
8010054b:	eb 01                	jmp    8010054e <cprintf+0x18a>
      break;
8010054d:	90                   	nop
    }
  }

  if(locking)
8010054e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100552:	74 10                	je     80100564 <cprintf+0x1a0>
    release(&cons.lock);
80100554:	83 ec 0c             	sub    $0xc,%esp
80100557:	68 c0 b5 10 80       	push   $0x8010b5c0
8010055c:	e8 6a 4b 00 00       	call   801050cb <release>
80100561:	83 c4 10             	add    $0x10,%esp
}
80100564:	90                   	nop
80100565:	c9                   	leave  
80100566:	c3                   	ret    

80100567 <panic>:

void
panic(char *s)
{
80100567:	55                   	push   %ebp
80100568:	89 e5                	mov    %esp,%ebp
8010056a:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056d:	e8 a0 fd ff ff       	call   80100312 <cli>
  cons.locking = 0;
80100572:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100579:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100582:	0f b6 00             	movzbl (%eax),%eax
80100585:	0f b6 c0             	movzbl %al,%eax
80100588:	83 ec 08             	sub    $0x8,%esp
8010058b:	50                   	push   %eax
8010058c:	68 4a 86 10 80       	push   $0x8010864a
80100591:	e8 2e fe ff ff       	call   801003c4 <cprintf>
80100596:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100599:	8b 45 08             	mov    0x8(%ebp),%eax
8010059c:	83 ec 0c             	sub    $0xc,%esp
8010059f:	50                   	push   %eax
801005a0:	e8 1f fe ff ff       	call   801003c4 <cprintf>
801005a5:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a8:	83 ec 0c             	sub    $0xc,%esp
801005ab:	68 59 86 10 80       	push   $0x80108659
801005b0:	e8 0f fe ff ff       	call   801003c4 <cprintf>
801005b5:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b8:	83 ec 08             	sub    $0x8,%esp
801005bb:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005be:	50                   	push   %eax
801005bf:	8d 45 08             	lea    0x8(%ebp),%eax
801005c2:	50                   	push   %eax
801005c3:	e8 55 4b 00 00       	call   8010511d <getcallerpcs>
801005c8:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d2:	eb 1c                	jmp    801005f0 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d7:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005db:	83 ec 08             	sub    $0x8,%esp
801005de:	50                   	push   %eax
801005df:	68 5b 86 10 80       	push   $0x8010865b
801005e4:	e8 db fd ff ff       	call   801003c4 <cprintf>
801005e9:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005f0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f4:	7e de                	jle    801005d4 <panic+0x6d>
  panicked = 1; // freeze other CPU
801005f6:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005fd:	00 00 00 
  for(;;)
80100600:	eb fe                	jmp    80100600 <panic+0x99>

80100602 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100602:	55                   	push   %ebp
80100603:	89 e5                	mov    %esp,%ebp
80100605:	53                   	push   %ebx
80100606:	83 ec 14             	sub    $0x14,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100609:	6a 0e                	push   $0xe
8010060b:	68 d4 03 00 00       	push   $0x3d4
80100610:	e8 dc fc ff ff       	call   801002f1 <outb>
80100615:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100618:	68 d5 03 00 00       	push   $0x3d5
8010061d:	e8 b2 fc ff ff       	call   801002d4 <inb>
80100622:	83 c4 04             	add    $0x4,%esp
80100625:	0f b6 c0             	movzbl %al,%eax
80100628:	c1 e0 08             	shl    $0x8,%eax
8010062b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062e:	6a 0f                	push   $0xf
80100630:	68 d4 03 00 00       	push   $0x3d4
80100635:	e8 b7 fc ff ff       	call   801002f1 <outb>
8010063a:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063d:	68 d5 03 00 00       	push   $0x3d5
80100642:	e8 8d fc ff ff       	call   801002d4 <inb>
80100647:	83 c4 04             	add    $0x4,%esp
8010064a:	0f b6 c0             	movzbl %al,%eax
8010064d:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100650:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100654:	75 30                	jne    80100686 <cgaputc+0x84>
    pos += 80 - pos%80;
80100656:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100659:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065e:	89 c8                	mov    %ecx,%eax
80100660:	f7 ea                	imul   %edx
80100662:	c1 fa 05             	sar    $0x5,%edx
80100665:	89 c8                	mov    %ecx,%eax
80100667:	c1 f8 1f             	sar    $0x1f,%eax
8010066a:	29 c2                	sub    %eax,%edx
8010066c:	89 d0                	mov    %edx,%eax
8010066e:	c1 e0 02             	shl    $0x2,%eax
80100671:	01 d0                	add    %edx,%eax
80100673:	c1 e0 04             	shl    $0x4,%eax
80100676:	29 c1                	sub    %eax,%ecx
80100678:	89 ca                	mov    %ecx,%edx
8010067a:	b8 50 00 00 00       	mov    $0x50,%eax
8010067f:	29 d0                	sub    %edx,%eax
80100681:	01 45 f4             	add    %eax,-0xc(%ebp)
80100684:	eb 38                	jmp    801006be <cgaputc+0xbc>
  else if(c == BACKSPACE){
80100686:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068d:	75 0c                	jne    8010069b <cgaputc+0x99>
    if(pos > 0) --pos;
8010068f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100693:	7e 29                	jle    801006be <cgaputc+0xbc>
80100695:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100699:	eb 23                	jmp    801006be <cgaputc+0xbc>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010069b:	8b 45 08             	mov    0x8(%ebp),%eax
8010069e:	0f b6 c0             	movzbl %al,%eax
801006a1:	80 cc 07             	or     $0x7,%ah
801006a4:	89 c3                	mov    %eax,%ebx
801006a6:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006af:	8d 50 01             	lea    0x1(%eax),%edx
801006b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006b5:	01 c0                	add    %eax,%eax
801006b7:	01 c8                	add    %ecx,%eax
801006b9:	89 da                	mov    %ebx,%edx
801006bb:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006c2:	78 09                	js     801006cd <cgaputc+0xcb>
801006c4:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006cb:	7e 0d                	jle    801006da <cgaputc+0xd8>
    panic("pos under/overflow");
801006cd:	83 ec 0c             	sub    $0xc,%esp
801006d0:	68 5f 86 10 80       	push   $0x8010865f
801006d5:	e8 8d fe ff ff       	call   80100567 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006da:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006e1:	7e 4c                	jle    8010072f <cgaputc+0x12d>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006e3:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006ee:	a1 00 90 10 80       	mov    0x80109000,%eax
801006f3:	83 ec 04             	sub    $0x4,%esp
801006f6:	68 60 0e 00 00       	push   $0xe60
801006fb:	52                   	push   %edx
801006fc:	50                   	push   %eax
801006fd:	e8 84 4c 00 00       	call   80105386 <memmove>
80100702:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100705:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100709:	b8 80 07 00 00       	mov    $0x780,%eax
8010070e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100711:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100714:	a1 00 90 10 80       	mov    0x80109000,%eax
80100719:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010071c:	01 c9                	add    %ecx,%ecx
8010071e:	01 c8                	add    %ecx,%eax
80100720:	83 ec 04             	sub    $0x4,%esp
80100723:	52                   	push   %edx
80100724:	6a 00                	push   $0x0
80100726:	50                   	push   %eax
80100727:	e8 9b 4b 00 00       	call   801052c7 <memset>
8010072c:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010072f:	83 ec 08             	sub    $0x8,%esp
80100732:	6a 0e                	push   $0xe
80100734:	68 d4 03 00 00       	push   $0x3d4
80100739:	e8 b3 fb ff ff       	call   801002f1 <outb>
8010073e:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
80100741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100744:	c1 f8 08             	sar    $0x8,%eax
80100747:	0f b6 c0             	movzbl %al,%eax
8010074a:	83 ec 08             	sub    $0x8,%esp
8010074d:	50                   	push   %eax
8010074e:	68 d5 03 00 00       	push   $0x3d5
80100753:	e8 99 fb ff ff       	call   801002f1 <outb>
80100758:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
8010075b:	83 ec 08             	sub    $0x8,%esp
8010075e:	6a 0f                	push   $0xf
80100760:	68 d4 03 00 00       	push   $0x3d4
80100765:	e8 87 fb ff ff       	call   801002f1 <outb>
8010076a:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010076d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100770:	0f b6 c0             	movzbl %al,%eax
80100773:	83 ec 08             	sub    $0x8,%esp
80100776:	50                   	push   %eax
80100777:	68 d5 03 00 00       	push   $0x3d5
8010077c:	e8 70 fb ff ff       	call   801002f1 <outb>
80100781:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100784:	a1 00 90 10 80       	mov    0x80109000,%eax
80100789:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010078c:	01 d2                	add    %edx,%edx
8010078e:	01 d0                	add    %edx,%eax
80100790:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100795:	90                   	nop
80100796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100799:	c9                   	leave  
8010079a:	c3                   	ret    

8010079b <consputc>:

void
consputc(int c)
{
8010079b:	55                   	push   %ebp
8010079c:	89 e5                	mov    %esp,%ebp
8010079e:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007a1:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
801007a6:	85 c0                	test   %eax,%eax
801007a8:	74 07                	je     801007b1 <consputc+0x16>
    cli();
801007aa:	e8 63 fb ff ff       	call   80100312 <cli>
    for(;;)
801007af:	eb fe                	jmp    801007af <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007b1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007b8:	75 29                	jne    801007e3 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007ba:	83 ec 0c             	sub    $0xc,%esp
801007bd:	6a 08                	push   $0x8
801007bf:	e8 d4 64 00 00       	call   80106c98 <uartputc>
801007c4:	83 c4 10             	add    $0x10,%esp
801007c7:	83 ec 0c             	sub    $0xc,%esp
801007ca:	6a 20                	push   $0x20
801007cc:	e8 c7 64 00 00       	call   80106c98 <uartputc>
801007d1:	83 c4 10             	add    $0x10,%esp
801007d4:	83 ec 0c             	sub    $0xc,%esp
801007d7:	6a 08                	push   $0x8
801007d9:	e8 ba 64 00 00       	call   80106c98 <uartputc>
801007de:	83 c4 10             	add    $0x10,%esp
801007e1:	eb 0e                	jmp    801007f1 <consputc+0x56>
  } else
    uartputc(c);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	ff 75 08             	pushl  0x8(%ebp)
801007e9:	e8 aa 64 00 00       	call   80106c98 <uartputc>
801007ee:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007f1:	83 ec 0c             	sub    $0xc,%esp
801007f4:	ff 75 08             	pushl  0x8(%ebp)
801007f7:	e8 06 fe ff ff       	call   80100602 <cgaputc>
801007fc:	83 c4 10             	add    $0x10,%esp
}
801007ff:	90                   	nop
80100800:	c9                   	leave  
80100801:	c3                   	ret    

80100802 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100802:	55                   	push   %ebp
80100803:	89 e5                	mov    %esp,%ebp
80100805:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100808:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
8010080f:	83 ec 0c             	sub    $0xc,%esp
80100812:	68 c0 b5 10 80       	push   $0x8010b5c0
80100817:	e8 48 48 00 00       	call   80105064 <acquire>
8010081c:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010081f:	e9 46 01 00 00       	jmp    8010096a <consoleintr+0x168>
    switch(c){
80100824:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100828:	74 22                	je     8010084c <consoleintr+0x4a>
8010082a:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010082e:	7f 0b                	jg     8010083b <consoleintr+0x39>
80100830:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100834:	74 6d                	je     801008a3 <consoleintr+0xa1>
80100836:	e9 9d 00 00 00       	jmp    801008d8 <consoleintr+0xd6>
8010083b:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010083f:	74 34                	je     80100875 <consoleintr+0x73>
80100841:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100845:	74 5c                	je     801008a3 <consoleintr+0xa1>
80100847:	e9 8c 00 00 00       	jmp    801008d8 <consoleintr+0xd6>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010084c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100853:	e9 12 01 00 00       	jmp    8010096a <consoleintr+0x168>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100858:	a1 08 08 11 80       	mov    0x80110808,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	a3 08 08 11 80       	mov    %eax,0x80110808
        consputc(BACKSPACE);
80100865:	83 ec 0c             	sub    $0xc,%esp
80100868:	68 00 01 00 00       	push   $0x100
8010086d:	e8 29 ff ff ff       	call   8010079b <consputc>
80100872:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100875:	8b 15 08 08 11 80    	mov    0x80110808,%edx
8010087b:	a1 04 08 11 80       	mov    0x80110804,%eax
80100880:	39 c2                	cmp    %eax,%edx
80100882:	0f 84 e2 00 00 00    	je     8010096a <consoleintr+0x168>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100888:	a1 08 08 11 80       	mov    0x80110808,%eax
8010088d:	83 e8 01             	sub    $0x1,%eax
80100890:	83 e0 7f             	and    $0x7f,%eax
80100893:	0f b6 80 80 07 11 80 	movzbl -0x7feef880(%eax),%eax
      while(input.e != input.w &&
8010089a:	3c 0a                	cmp    $0xa,%al
8010089c:	75 ba                	jne    80100858 <consoleintr+0x56>
      }
      break;
8010089e:	e9 c7 00 00 00       	jmp    8010096a <consoleintr+0x168>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008a3:	8b 15 08 08 11 80    	mov    0x80110808,%edx
801008a9:	a1 04 08 11 80       	mov    0x80110804,%eax
801008ae:	39 c2                	cmp    %eax,%edx
801008b0:	0f 84 b4 00 00 00    	je     8010096a <consoleintr+0x168>
        input.e--;
801008b6:	a1 08 08 11 80       	mov    0x80110808,%eax
801008bb:	83 e8 01             	sub    $0x1,%eax
801008be:	a3 08 08 11 80       	mov    %eax,0x80110808
        consputc(BACKSPACE);
801008c3:	83 ec 0c             	sub    $0xc,%esp
801008c6:	68 00 01 00 00       	push   $0x100
801008cb:	e8 cb fe ff ff       	call   8010079b <consputc>
801008d0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008d3:	e9 92 00 00 00       	jmp    8010096a <consoleintr+0x168>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008dc:	0f 84 87 00 00 00    	je     80100969 <consoleintr+0x167>
801008e2:	8b 15 08 08 11 80    	mov    0x80110808,%edx
801008e8:	a1 00 08 11 80       	mov    0x80110800,%eax
801008ed:	29 c2                	sub    %eax,%edx
801008ef:	89 d0                	mov    %edx,%eax
801008f1:	83 f8 7f             	cmp    $0x7f,%eax
801008f4:	77 73                	ja     80100969 <consoleintr+0x167>
        c = (c == '\r') ? '\n' : c;
801008f6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008fa:	74 05                	je     80100901 <consoleintr+0xff>
801008fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008ff:	eb 05                	jmp    80100906 <consoleintr+0x104>
80100901:	b8 0a 00 00 00       	mov    $0xa,%eax
80100906:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100909:	a1 08 08 11 80       	mov    0x80110808,%eax
8010090e:	8d 50 01             	lea    0x1(%eax),%edx
80100911:	89 15 08 08 11 80    	mov    %edx,0x80110808
80100917:	83 e0 7f             	and    $0x7f,%eax
8010091a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010091d:	88 90 80 07 11 80    	mov    %dl,-0x7feef880(%eax)
        consputc(c);
80100923:	83 ec 0c             	sub    $0xc,%esp
80100926:	ff 75 f0             	pushl  -0x10(%ebp)
80100929:	e8 6d fe ff ff       	call   8010079b <consputc>
8010092e:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100931:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100935:	74 18                	je     8010094f <consoleintr+0x14d>
80100937:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
8010093b:	74 12                	je     8010094f <consoleintr+0x14d>
8010093d:	a1 08 08 11 80       	mov    0x80110808,%eax
80100942:	8b 15 00 08 11 80    	mov    0x80110800,%edx
80100948:	83 ea 80             	sub    $0xffffff80,%edx
8010094b:	39 d0                	cmp    %edx,%eax
8010094d:	75 1a                	jne    80100969 <consoleintr+0x167>
          input.w = input.e;
8010094f:	a1 08 08 11 80       	mov    0x80110808,%eax
80100954:	a3 04 08 11 80       	mov    %eax,0x80110804
          wakeup(&input.r);
80100959:	83 ec 0c             	sub    $0xc,%esp
8010095c:	68 00 08 11 80       	push   $0x80110800
80100961:	e8 f0 44 00 00       	call   80104e56 <wakeup>
80100966:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100969:	90                   	nop
  while((c = getc()) >= 0){
8010096a:	8b 45 08             	mov    0x8(%ebp),%eax
8010096d:	ff d0                	call   *%eax
8010096f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100972:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100976:	0f 89 a8 fe ff ff    	jns    80100824 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010097c:	83 ec 0c             	sub    $0xc,%esp
8010097f:	68 c0 b5 10 80       	push   $0x8010b5c0
80100984:	e8 42 47 00 00       	call   801050cb <release>
80100989:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010098c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100990:	74 05                	je     80100997 <consoleintr+0x195>
    procdump();  // now call procdump() wo. cons.lock held
80100992:	e8 7a 45 00 00       	call   80104f11 <procdump>
  }
}
80100997:	90                   	nop
80100998:	c9                   	leave  
80100999:	c3                   	ret    

8010099a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010099a:	55                   	push   %ebp
8010099b:	89 e5                	mov    %esp,%ebp
8010099d:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009a0:	83 ec 0c             	sub    $0xc,%esp
801009a3:	ff 75 08             	pushl  0x8(%ebp)
801009a6:	e8 28 11 00 00       	call   80101ad3 <iunlock>
801009ab:	83 c4 10             	add    $0x10,%esp
  target = n;
801009ae:	8b 45 10             	mov    0x10(%ebp),%eax
801009b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009b4:	83 ec 0c             	sub    $0xc,%esp
801009b7:	68 c0 b5 10 80       	push   $0x8010b5c0
801009bc:	e8 a3 46 00 00       	call   80105064 <acquire>
801009c1:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009c4:	e9 ac 00 00 00       	jmp    80100a75 <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009cf:	8b 40 24             	mov    0x24(%eax),%eax
801009d2:	85 c0                	test   %eax,%eax
801009d4:	74 28                	je     801009fe <consoleread+0x64>
        release(&cons.lock);
801009d6:	83 ec 0c             	sub    $0xc,%esp
801009d9:	68 c0 b5 10 80       	push   $0x8010b5c0
801009de:	e8 e8 46 00 00       	call   801050cb <release>
801009e3:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009e6:	83 ec 0c             	sub    $0xc,%esp
801009e9:	ff 75 08             	pushl  0x8(%ebp)
801009ec:	e8 84 0f 00 00       	call   80101975 <ilock>
801009f1:	83 c4 10             	add    $0x10,%esp
        return -1;
801009f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009f9:	e9 ab 00 00 00       	jmp    80100aa9 <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009fe:	83 ec 08             	sub    $0x8,%esp
80100a01:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a06:	68 00 08 11 80       	push   $0x80110800
80100a0b:	e8 5b 43 00 00       	call   80104d6b <sleep>
80100a10:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a13:	8b 15 00 08 11 80    	mov    0x80110800,%edx
80100a19:	a1 04 08 11 80       	mov    0x80110804,%eax
80100a1e:	39 c2                	cmp    %eax,%edx
80100a20:	74 a7                	je     801009c9 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a22:	a1 00 08 11 80       	mov    0x80110800,%eax
80100a27:	8d 50 01             	lea    0x1(%eax),%edx
80100a2a:	89 15 00 08 11 80    	mov    %edx,0x80110800
80100a30:	83 e0 7f             	and    $0x7f,%eax
80100a33:	0f b6 80 80 07 11 80 	movzbl -0x7feef880(%eax),%eax
80100a3a:	0f be c0             	movsbl %al,%eax
80100a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a40:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a44:	75 17                	jne    80100a5d <consoleread+0xc3>
      if(n < target){
80100a46:	8b 45 10             	mov    0x10(%ebp),%eax
80100a49:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a4c:	76 2f                	jbe    80100a7d <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a4e:	a1 00 08 11 80       	mov    0x80110800,%eax
80100a53:	83 e8 01             	sub    $0x1,%eax
80100a56:	a3 00 08 11 80       	mov    %eax,0x80110800
      }
      break;
80100a5b:	eb 20                	jmp    80100a7d <consoleread+0xe3>
    }
    *dst++ = c;
80100a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a60:	8d 50 01             	lea    0x1(%eax),%edx
80100a63:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a66:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a69:	88 10                	mov    %dl,(%eax)
    --n;
80100a6b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a6f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a73:	74 0b                	je     80100a80 <consoleread+0xe6>
  while(n > 0){
80100a75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a79:	7f 98                	jg     80100a13 <consoleread+0x79>
80100a7b:	eb 04                	jmp    80100a81 <consoleread+0xe7>
      break;
80100a7d:	90                   	nop
80100a7e:	eb 01                	jmp    80100a81 <consoleread+0xe7>
      break;
80100a80:	90                   	nop
  }
  release(&cons.lock);
80100a81:	83 ec 0c             	sub    $0xc,%esp
80100a84:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a89:	e8 3d 46 00 00       	call   801050cb <release>
80100a8e:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a91:	83 ec 0c             	sub    $0xc,%esp
80100a94:	ff 75 08             	pushl  0x8(%ebp)
80100a97:	e8 d9 0e 00 00       	call   80101975 <ilock>
80100a9c:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a9f:	8b 45 10             	mov    0x10(%ebp),%eax
80100aa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa5:	29 c2                	sub    %eax,%edx
80100aa7:	89 d0                	mov    %edx,%eax
}
80100aa9:	c9                   	leave  
80100aaa:	c3                   	ret    

80100aab <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aab:	55                   	push   %ebp
80100aac:	89 e5                	mov    %esp,%ebp
80100aae:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ab1:	83 ec 0c             	sub    $0xc,%esp
80100ab4:	ff 75 08             	pushl  0x8(%ebp)
80100ab7:	e8 17 10 00 00       	call   80101ad3 <iunlock>
80100abc:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100abf:	83 ec 0c             	sub    $0xc,%esp
80100ac2:	68 c0 b5 10 80       	push   $0x8010b5c0
80100ac7:	e8 98 45 00 00       	call   80105064 <acquire>
80100acc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ad6:	eb 21                	jmp    80100af9 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ad8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100adb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ade:	01 d0                	add    %edx,%eax
80100ae0:	0f b6 00             	movzbl (%eax),%eax
80100ae3:	0f be c0             	movsbl %al,%eax
80100ae6:	0f b6 c0             	movzbl %al,%eax
80100ae9:	83 ec 0c             	sub    $0xc,%esp
80100aec:	50                   	push   %eax
80100aed:	e8 a9 fc ff ff       	call   8010079b <consputc>
80100af2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100afc:	3b 45 10             	cmp    0x10(%ebp),%eax
80100aff:	7c d7                	jl     80100ad8 <consolewrite+0x2d>
  release(&cons.lock);
80100b01:	83 ec 0c             	sub    $0xc,%esp
80100b04:	68 c0 b5 10 80       	push   $0x8010b5c0
80100b09:	e8 bd 45 00 00       	call   801050cb <release>
80100b0e:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b11:	83 ec 0c             	sub    $0xc,%esp
80100b14:	ff 75 08             	pushl  0x8(%ebp)
80100b17:	e8 59 0e 00 00       	call   80101975 <ilock>
80100b1c:	83 c4 10             	add    $0x10,%esp

  return n;
80100b1f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b22:	c9                   	leave  
80100b23:	c3                   	ret    

80100b24 <consoleinit>:

void
consoleinit(void)
{
80100b24:	55                   	push   %ebp
80100b25:	89 e5                	mov    %esp,%ebp
80100b27:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b2a:	83 ec 08             	sub    $0x8,%esp
80100b2d:	68 72 86 10 80       	push   $0x80108672
80100b32:	68 c0 b5 10 80       	push   $0x8010b5c0
80100b37:	e8 06 45 00 00       	call   80105042 <initlock>
80100b3c:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b3f:	c7 05 cc 11 11 80 ab 	movl   $0x80100aab,0x801111cc
80100b46:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b49:	c7 05 c8 11 11 80 9a 	movl   $0x8010099a,0x801111c8
80100b50:	09 10 80 
  cons.locking = 1;
80100b53:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100b5a:	00 00 00 

  picenable(IRQ_KBD);
80100b5d:	83 ec 0c             	sub    $0xc,%esp
80100b60:	6a 01                	push   $0x1
80100b62:	e8 c9 33 00 00       	call   80103f30 <picenable>
80100b67:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b6a:	83 ec 08             	sub    $0x8,%esp
80100b6d:	6a 00                	push   $0x0
80100b6f:	6a 01                	push   $0x1
80100b71:	e8 68 1f 00 00       	call   80102ade <ioapicenable>
80100b76:	83 c4 10             	add    $0x10,%esp
}
80100b79:	90                   	nop
80100b7a:	c9                   	leave  
80100b7b:	c3                   	ret    

80100b7c <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b7c:	55                   	push   %ebp
80100b7d:	89 e5                	mov    %esp,%ebp
80100b7f:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b85:	e8 cc 29 00 00       	call   80103556 <begin_op>
  if((ip = namei(path)) == 0){
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 08             	pushl  0x8(%ebp)
80100b90:	e8 95 19 00 00       	call   8010252a <namei>
80100b95:	83 c4 10             	add    $0x10,%esp
80100b98:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b9b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b9f:	75 0f                	jne    80100bb0 <exec+0x34>
    end_op();
80100ba1:	e8 3c 2a 00 00       	call   801035e2 <end_op>
    return -1;
80100ba6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bab:	e9 ce 03 00 00       	jmp    80100f7e <exec+0x402>
  }
  ilock(ip);
80100bb0:	83 ec 0c             	sub    $0xc,%esp
80100bb3:	ff 75 d8             	pushl  -0x28(%ebp)
80100bb6:	e8 ba 0d 00 00       	call   80101975 <ilock>
80100bbb:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bbe:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bc5:	6a 34                	push   $0x34
80100bc7:	6a 00                	push   $0x0
80100bc9:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bcf:	50                   	push   %eax
80100bd0:	ff 75 d8             	pushl  -0x28(%ebp)
80100bd3:	e8 06 13 00 00       	call   80101ede <readi>
80100bd8:	83 c4 10             	add    $0x10,%esp
80100bdb:	83 f8 33             	cmp    $0x33,%eax
80100bde:	0f 86 49 03 00 00    	jbe    80100f2d <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100be4:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bea:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bef:	0f 85 3b 03 00 00    	jne    80100f30 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bf5:	e8 f3 71 00 00       	call   80107ded <setupkvm>
80100bfa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bfd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c01:	0f 84 2c 03 00 00    	je     80100f33 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c07:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c0e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c15:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c1e:	e9 ab 00 00 00       	jmp    80100cce <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c26:	6a 20                	push   $0x20
80100c28:	50                   	push   %eax
80100c29:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c2f:	50                   	push   %eax
80100c30:	ff 75 d8             	pushl  -0x28(%ebp)
80100c33:	e8 a6 12 00 00       	call   80101ede <readi>
80100c38:	83 c4 10             	add    $0x10,%esp
80100c3b:	83 f8 20             	cmp    $0x20,%eax
80100c3e:	0f 85 f2 02 00 00    	jne    80100f36 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c44:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c4a:	83 f8 01             	cmp    $0x1,%eax
80100c4d:	75 71                	jne    80100cc0 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c4f:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c55:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c5b:	39 c2                	cmp    %eax,%edx
80100c5d:	0f 82 d6 02 00 00    	jb     80100f39 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c63:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c69:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c6f:	01 d0                	add    %edx,%eax
80100c71:	83 ec 04             	sub    $0x4,%esp
80100c74:	50                   	push   %eax
80100c75:	ff 75 e0             	pushl  -0x20(%ebp)
80100c78:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c7b:	e8 15 75 00 00       	call   80108195 <allocuvm>
80100c80:	83 c4 10             	add    $0x10,%esp
80100c83:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c86:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c8a:	0f 84 ac 02 00 00    	je     80100f3c <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c90:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c96:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c9c:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100ca2:	83 ec 0c             	sub    $0xc,%esp
80100ca5:	52                   	push   %edx
80100ca6:	50                   	push   %eax
80100ca7:	ff 75 d8             	pushl  -0x28(%ebp)
80100caa:	51                   	push   %ecx
80100cab:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cae:	e8 0b 74 00 00       	call   801080be <loaduvm>
80100cb3:	83 c4 20             	add    $0x20,%esp
80100cb6:	85 c0                	test   %eax,%eax
80100cb8:	0f 88 81 02 00 00    	js     80100f3f <exec+0x3c3>
80100cbe:	eb 01                	jmp    80100cc1 <exec+0x145>
      continue;
80100cc0:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cc1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cc8:	83 c0 20             	add    $0x20,%eax
80100ccb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cce:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cd5:	0f b7 c0             	movzwl %ax,%eax
80100cd8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100cdb:	0f 8c 42 ff ff ff    	jl     80100c23 <exec+0xa7>
      goto bad;
  }
  iunlockput(ip);
80100ce1:	83 ec 0c             	sub    $0xc,%esp
80100ce4:	ff 75 d8             	pushl  -0x28(%ebp)
80100ce7:	e8 49 0f 00 00       	call   80101c35 <iunlockput>
80100cec:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cef:	e8 ee 28 00 00       	call   801035e2 <end_op>
  ip = 0;
80100cf4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cfe:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d08:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0e:	05 00 20 00 00       	add    $0x2000,%eax
80100d13:	83 ec 04             	sub    $0x4,%esp
80100d16:	50                   	push   %eax
80100d17:	ff 75 e0             	pushl  -0x20(%ebp)
80100d1a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d1d:	e8 73 74 00 00       	call   80108195 <allocuvm>
80100d22:	83 c4 10             	add    $0x10,%esp
80100d25:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d28:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d2c:	0f 84 10 02 00 00    	je     80100f42 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d35:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d3a:	83 ec 08             	sub    $0x8,%esp
80100d3d:	50                   	push   %eax
80100d3e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d41:	e8 75 76 00 00       	call   801083bb <clearpteu>
80100d46:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d49:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d4f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d56:	e9 96 00 00 00       	jmp    80100df1 <exec+0x275>
    if(argc >= MAXARG)
80100d5b:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d5f:	0f 87 e0 01 00 00    	ja     80100f45 <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d72:	01 d0                	add    %edx,%eax
80100d74:	8b 00                	mov    (%eax),%eax
80100d76:	83 ec 0c             	sub    $0xc,%esp
80100d79:	50                   	push   %eax
80100d7a:	e8 95 47 00 00       	call   80105514 <strlen>
80100d7f:	83 c4 10             	add    $0x10,%esp
80100d82:	89 c2                	mov    %eax,%edx
80100d84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d87:	29 d0                	sub    %edx,%eax
80100d89:	83 e8 01             	sub    $0x1,%eax
80100d8c:	83 e0 fc             	and    $0xfffffffc,%eax
80100d8f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d95:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d9f:	01 d0                	add    %edx,%eax
80100da1:	8b 00                	mov    (%eax),%eax
80100da3:	83 ec 0c             	sub    $0xc,%esp
80100da6:	50                   	push   %eax
80100da7:	e8 68 47 00 00       	call   80105514 <strlen>
80100dac:	83 c4 10             	add    $0x10,%esp
80100daf:	83 c0 01             	add    $0x1,%eax
80100db2:	89 c1                	mov    %eax,%ecx
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	51                   	push   %ecx
80100dc6:	50                   	push   %eax
80100dc7:	ff 75 dc             	pushl  -0x24(%ebp)
80100dca:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dcd:	e8 a1 77 00 00       	call   80108573 <copyout>
80100dd2:	83 c4 10             	add    $0x10,%esp
80100dd5:	85 c0                	test   %eax,%eax
80100dd7:	0f 88 6b 01 00 00    	js     80100f48 <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de0:	8d 50 03             	lea    0x3(%eax),%edx
80100de3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de6:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100ded:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dfe:	01 d0                	add    %edx,%eax
80100e00:	8b 00                	mov    (%eax),%eax
80100e02:	85 c0                	test   %eax,%eax
80100e04:	0f 85 51 ff ff ff    	jne    80100d5b <exec+0x1df>
  }
  ustack[3+argc] = 0;
80100e0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0d:	83 c0 03             	add    $0x3,%eax
80100e10:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e17:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e1b:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e22:	ff ff ff 
  ustack[1] = argc;
80100e25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e28:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e31:	83 c0 01             	add    $0x1,%eax
80100e34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e3b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e3e:	29 d0                	sub    %edx,%eax
80100e40:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e49:	83 c0 04             	add    $0x4,%eax
80100e4c:	c1 e0 02             	shl    $0x2,%eax
80100e4f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e55:	83 c0 04             	add    $0x4,%eax
80100e58:	c1 e0 02             	shl    $0x2,%eax
80100e5b:	50                   	push   %eax
80100e5c:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e62:	50                   	push   %eax
80100e63:	ff 75 dc             	pushl  -0x24(%ebp)
80100e66:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e69:	e8 05 77 00 00       	call   80108573 <copyout>
80100e6e:	83 c4 10             	add    $0x10,%esp
80100e71:	85 c0                	test   %eax,%eax
80100e73:	0f 88 d2 00 00 00    	js     80100f4b <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e79:	8b 45 08             	mov    0x8(%ebp),%eax
80100e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e82:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e85:	eb 17                	jmp    80100e9e <exec+0x322>
    if(*s == '/')
80100e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e8a:	0f b6 00             	movzbl (%eax),%eax
80100e8d:	3c 2f                	cmp    $0x2f,%al
80100e8f:	75 09                	jne    80100e9a <exec+0x31e>
      last = s+1;
80100e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e94:	83 c0 01             	add    $0x1,%eax
80100e97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100e9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea1:	0f b6 00             	movzbl (%eax),%eax
80100ea4:	84 c0                	test   %al,%al
80100ea6:	75 df                	jne    80100e87 <exec+0x30b>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eae:	83 c0 6c             	add    $0x6c,%eax
80100eb1:	83 ec 04             	sub    $0x4,%esp
80100eb4:	6a 10                	push   $0x10
80100eb6:	ff 75 f0             	pushl  -0x10(%ebp)
80100eb9:	50                   	push   %eax
80100eba:	e8 0b 46 00 00       	call   801054ca <safestrcpy>
80100ebf:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ec2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec8:	8b 40 04             	mov    0x4(%eax),%eax
80100ecb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ece:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ed7:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ee3:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ee5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eeb:	8b 40 18             	mov    0x18(%eax),%eax
80100eee:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ef4:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ef7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100efd:	8b 40 18             	mov    0x18(%eax),%eax
80100f00:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f03:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f0c:	83 ec 0c             	sub    $0xc,%esp
80100f0f:	50                   	push   %eax
80100f10:	e8 bf 6f 00 00       	call   80107ed4 <switchuvm>
80100f15:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f18:	83 ec 0c             	sub    $0xc,%esp
80100f1b:	ff 75 d0             	pushl  -0x30(%ebp)
80100f1e:	e8 f8 73 00 00       	call   8010831b <freevm>
80100f23:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f26:	b8 00 00 00 00       	mov    $0x0,%eax
80100f2b:	eb 51                	jmp    80100f7e <exec+0x402>
    goto bad;
80100f2d:	90                   	nop
80100f2e:	eb 1c                	jmp    80100f4c <exec+0x3d0>
    goto bad;
80100f30:	90                   	nop
80100f31:	eb 19                	jmp    80100f4c <exec+0x3d0>
    goto bad;
80100f33:	90                   	nop
80100f34:	eb 16                	jmp    80100f4c <exec+0x3d0>
      goto bad;
80100f36:	90                   	nop
80100f37:	eb 13                	jmp    80100f4c <exec+0x3d0>
      goto bad;
80100f39:	90                   	nop
80100f3a:	eb 10                	jmp    80100f4c <exec+0x3d0>
      goto bad;
80100f3c:	90                   	nop
80100f3d:	eb 0d                	jmp    80100f4c <exec+0x3d0>
      goto bad;
80100f3f:	90                   	nop
80100f40:	eb 0a                	jmp    80100f4c <exec+0x3d0>
    goto bad;
80100f42:	90                   	nop
80100f43:	eb 07                	jmp    80100f4c <exec+0x3d0>
      goto bad;
80100f45:	90                   	nop
80100f46:	eb 04                	jmp    80100f4c <exec+0x3d0>
      goto bad;
80100f48:	90                   	nop
80100f49:	eb 01                	jmp    80100f4c <exec+0x3d0>
    goto bad;
80100f4b:	90                   	nop

 bad:
  if(pgdir)
80100f4c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f50:	74 0e                	je     80100f60 <exec+0x3e4>
    freevm(pgdir);
80100f52:	83 ec 0c             	sub    $0xc,%esp
80100f55:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f58:	e8 be 73 00 00       	call   8010831b <freevm>
80100f5d:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f60:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f64:	74 13                	je     80100f79 <exec+0x3fd>
    iunlockput(ip);
80100f66:	83 ec 0c             	sub    $0xc,%esp
80100f69:	ff 75 d8             	pushl  -0x28(%ebp)
80100f6c:	e8 c4 0c 00 00       	call   80101c35 <iunlockput>
80100f71:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f74:	e8 69 26 00 00       	call   801035e2 <end_op>
  }
  return -1;
80100f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f7e:	c9                   	leave  
80100f7f:	c3                   	ret    

80100f80 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f80:	55                   	push   %ebp
80100f81:	89 e5                	mov    %esp,%ebp
80100f83:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f86:	83 ec 08             	sub    $0x8,%esp
80100f89:	68 7a 86 10 80       	push   $0x8010867a
80100f8e:	68 20 08 11 80       	push   $0x80110820
80100f93:	e8 aa 40 00 00       	call   80105042 <initlock>
80100f98:	83 c4 10             	add    $0x10,%esp
}
80100f9b:	90                   	nop
80100f9c:	c9                   	leave  
80100f9d:	c3                   	ret    

80100f9e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f9e:	55                   	push   %ebp
80100f9f:	89 e5                	mov    %esp,%ebp
80100fa1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fa4:	83 ec 0c             	sub    $0xc,%esp
80100fa7:	68 20 08 11 80       	push   $0x80110820
80100fac:	e8 b3 40 00 00       	call   80105064 <acquire>
80100fb1:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fb4:	c7 45 f4 54 08 11 80 	movl   $0x80110854,-0xc(%ebp)
80100fbb:	eb 2d                	jmp    80100fea <filealloc+0x4c>
    if(f->ref == 0){
80100fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc0:	8b 40 04             	mov    0x4(%eax),%eax
80100fc3:	85 c0                	test   %eax,%eax
80100fc5:	75 1f                	jne    80100fe6 <filealloc+0x48>
      f->ref = 1;
80100fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fca:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fd1:	83 ec 0c             	sub    $0xc,%esp
80100fd4:	68 20 08 11 80       	push   $0x80110820
80100fd9:	e8 ed 40 00 00       	call   801050cb <release>
80100fde:	83 c4 10             	add    $0x10,%esp
      return f;
80100fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe4:	eb 23                	jmp    80101009 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fe6:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fea:	b8 b4 11 11 80       	mov    $0x801111b4,%eax
80100fef:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100ff2:	72 c9                	jb     80100fbd <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80100ff4:	83 ec 0c             	sub    $0xc,%esp
80100ff7:	68 20 08 11 80       	push   $0x80110820
80100ffc:	e8 ca 40 00 00       	call   801050cb <release>
80101001:	83 c4 10             	add    $0x10,%esp
  return 0;
80101004:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101009:	c9                   	leave  
8010100a:	c3                   	ret    

8010100b <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010100b:	55                   	push   %ebp
8010100c:	89 e5                	mov    %esp,%ebp
8010100e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101011:	83 ec 0c             	sub    $0xc,%esp
80101014:	68 20 08 11 80       	push   $0x80110820
80101019:	e8 46 40 00 00       	call   80105064 <acquire>
8010101e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101021:	8b 45 08             	mov    0x8(%ebp),%eax
80101024:	8b 40 04             	mov    0x4(%eax),%eax
80101027:	85 c0                	test   %eax,%eax
80101029:	7f 0d                	jg     80101038 <filedup+0x2d>
    panic("filedup");
8010102b:	83 ec 0c             	sub    $0xc,%esp
8010102e:	68 81 86 10 80       	push   $0x80108681
80101033:	e8 2f f5 ff ff       	call   80100567 <panic>
  f->ref++;
80101038:	8b 45 08             	mov    0x8(%ebp),%eax
8010103b:	8b 40 04             	mov    0x4(%eax),%eax
8010103e:	8d 50 01             	lea    0x1(%eax),%edx
80101041:	8b 45 08             	mov    0x8(%ebp),%eax
80101044:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101047:	83 ec 0c             	sub    $0xc,%esp
8010104a:	68 20 08 11 80       	push   $0x80110820
8010104f:	e8 77 40 00 00       	call   801050cb <release>
80101054:	83 c4 10             	add    $0x10,%esp
  return f;
80101057:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010105a:	c9                   	leave  
8010105b:	c3                   	ret    

8010105c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010105c:	55                   	push   %ebp
8010105d:	89 e5                	mov    %esp,%ebp
8010105f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101062:	83 ec 0c             	sub    $0xc,%esp
80101065:	68 20 08 11 80       	push   $0x80110820
8010106a:	e8 f5 3f 00 00       	call   80105064 <acquire>
8010106f:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101072:	8b 45 08             	mov    0x8(%ebp),%eax
80101075:	8b 40 04             	mov    0x4(%eax),%eax
80101078:	85 c0                	test   %eax,%eax
8010107a:	7f 0d                	jg     80101089 <fileclose+0x2d>
    panic("fileclose");
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	68 89 86 10 80       	push   $0x80108689
80101084:	e8 de f4 ff ff       	call   80100567 <panic>
  if(--f->ref > 0){
80101089:	8b 45 08             	mov    0x8(%ebp),%eax
8010108c:	8b 40 04             	mov    0x4(%eax),%eax
8010108f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101092:	8b 45 08             	mov    0x8(%ebp),%eax
80101095:	89 50 04             	mov    %edx,0x4(%eax)
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	8b 40 04             	mov    0x4(%eax),%eax
8010109e:	85 c0                	test   %eax,%eax
801010a0:	7e 15                	jle    801010b7 <fileclose+0x5b>
    release(&ftable.lock);
801010a2:	83 ec 0c             	sub    $0xc,%esp
801010a5:	68 20 08 11 80       	push   $0x80110820
801010aa:	e8 1c 40 00 00       	call   801050cb <release>
801010af:	83 c4 10             	add    $0x10,%esp
801010b2:	e9 8b 00 00 00       	jmp    80101142 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	8b 10                	mov    (%eax),%edx
801010bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010bf:	8b 50 04             	mov    0x4(%eax),%edx
801010c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010c5:	8b 50 08             	mov    0x8(%eax),%edx
801010c8:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010cb:	8b 50 0c             	mov    0xc(%eax),%edx
801010ce:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010d1:	8b 50 10             	mov    0x10(%eax),%edx
801010d4:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010d7:	8b 40 14             	mov    0x14(%eax),%eax
801010da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010e7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010f0:	83 ec 0c             	sub    $0xc,%esp
801010f3:	68 20 08 11 80       	push   $0x80110820
801010f8:	e8 ce 3f 00 00       	call   801050cb <release>
801010fd:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101100:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101103:	83 f8 01             	cmp    $0x1,%eax
80101106:	75 19                	jne    80101121 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101108:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010110c:	0f be d0             	movsbl %al,%edx
8010110f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101112:	83 ec 08             	sub    $0x8,%esp
80101115:	52                   	push   %edx
80101116:	50                   	push   %eax
80101117:	e8 80 30 00 00       	call   8010419c <pipeclose>
8010111c:	83 c4 10             	add    $0x10,%esp
8010111f:	eb 21                	jmp    80101142 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101121:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101124:	83 f8 02             	cmp    $0x2,%eax
80101127:	75 19                	jne    80101142 <fileclose+0xe6>
    begin_op();
80101129:	e8 28 24 00 00       	call   80103556 <begin_op>
    iput(ff.ip);
8010112e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101131:	83 ec 0c             	sub    $0xc,%esp
80101134:	50                   	push   %eax
80101135:	e8 0b 0a 00 00       	call   80101b45 <iput>
8010113a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010113d:	e8 a0 24 00 00       	call   801035e2 <end_op>
  }
}
80101142:	c9                   	leave  
80101143:	c3                   	ret    

80101144 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101144:	55                   	push   %ebp
80101145:	89 e5                	mov    %esp,%ebp
80101147:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010114a:	8b 45 08             	mov    0x8(%ebp),%eax
8010114d:	8b 00                	mov    (%eax),%eax
8010114f:	83 f8 02             	cmp    $0x2,%eax
80101152:	75 40                	jne    80101194 <filestat+0x50>
    ilock(f->ip);
80101154:	8b 45 08             	mov    0x8(%ebp),%eax
80101157:	8b 40 10             	mov    0x10(%eax),%eax
8010115a:	83 ec 0c             	sub    $0xc,%esp
8010115d:	50                   	push   %eax
8010115e:	e8 12 08 00 00       	call   80101975 <ilock>
80101163:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101166:	8b 45 08             	mov    0x8(%ebp),%eax
80101169:	8b 40 10             	mov    0x10(%eax),%eax
8010116c:	83 ec 08             	sub    $0x8,%esp
8010116f:	ff 75 0c             	pushl  0xc(%ebp)
80101172:	50                   	push   %eax
80101173:	e8 20 0d 00 00       	call   80101e98 <stati>
80101178:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010117b:	8b 45 08             	mov    0x8(%ebp),%eax
8010117e:	8b 40 10             	mov    0x10(%eax),%eax
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	50                   	push   %eax
80101185:	e8 49 09 00 00       	call   80101ad3 <iunlock>
8010118a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010118d:	b8 00 00 00 00       	mov    $0x0,%eax
80101192:	eb 05                	jmp    80101199 <filestat+0x55>
  }
  return -1;
80101194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101199:	c9                   	leave  
8010119a:	c3                   	ret    

8010119b <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010119b:	55                   	push   %ebp
8010119c:	89 e5                	mov    %esp,%ebp
8010119e:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011a1:	8b 45 08             	mov    0x8(%ebp),%eax
801011a4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011a8:	84 c0                	test   %al,%al
801011aa:	75 0a                	jne    801011b6 <fileread+0x1b>
    return -1;
801011ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011b1:	e9 9b 00 00 00       	jmp    80101251 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	8b 00                	mov    (%eax),%eax
801011bb:	83 f8 01             	cmp    $0x1,%eax
801011be:	75 1a                	jne    801011da <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011c0:	8b 45 08             	mov    0x8(%ebp),%eax
801011c3:	8b 40 0c             	mov    0xc(%eax),%eax
801011c6:	83 ec 04             	sub    $0x4,%esp
801011c9:	ff 75 10             	pushl  0x10(%ebp)
801011cc:	ff 75 0c             	pushl  0xc(%ebp)
801011cf:	50                   	push   %eax
801011d0:	e8 74 31 00 00       	call   80104349 <piperead>
801011d5:	83 c4 10             	add    $0x10,%esp
801011d8:	eb 77                	jmp    80101251 <fileread+0xb6>
  if(f->type == FD_INODE){
801011da:	8b 45 08             	mov    0x8(%ebp),%eax
801011dd:	8b 00                	mov    (%eax),%eax
801011df:	83 f8 02             	cmp    $0x2,%eax
801011e2:	75 60                	jne    80101244 <fileread+0xa9>
    ilock(f->ip);
801011e4:	8b 45 08             	mov    0x8(%ebp),%eax
801011e7:	8b 40 10             	mov    0x10(%eax),%eax
801011ea:	83 ec 0c             	sub    $0xc,%esp
801011ed:	50                   	push   %eax
801011ee:	e8 82 07 00 00       	call   80101975 <ilock>
801011f3:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011f9:	8b 45 08             	mov    0x8(%ebp),%eax
801011fc:	8b 50 14             	mov    0x14(%eax),%edx
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 10             	mov    0x10(%eax),%eax
80101205:	51                   	push   %ecx
80101206:	52                   	push   %edx
80101207:	ff 75 0c             	pushl  0xc(%ebp)
8010120a:	50                   	push   %eax
8010120b:	e8 ce 0c 00 00       	call   80101ede <readi>
80101210:	83 c4 10             	add    $0x10,%esp
80101213:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101216:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010121a:	7e 11                	jle    8010122d <fileread+0x92>
      f->off += r;
8010121c:	8b 45 08             	mov    0x8(%ebp),%eax
8010121f:	8b 50 14             	mov    0x14(%eax),%edx
80101222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101225:	01 c2                	add    %eax,%edx
80101227:	8b 45 08             	mov    0x8(%ebp),%eax
8010122a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 0c             	sub    $0xc,%esp
80101236:	50                   	push   %eax
80101237:	e8 97 08 00 00       	call   80101ad3 <iunlock>
8010123c:	83 c4 10             	add    $0x10,%esp
    return r;
8010123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101242:	eb 0d                	jmp    80101251 <fileread+0xb6>
  }
  panic("fileread");
80101244:	83 ec 0c             	sub    $0xc,%esp
80101247:	68 93 86 10 80       	push   $0x80108693
8010124c:	e8 16 f3 ff ff       	call   80100567 <panic>
}
80101251:	c9                   	leave  
80101252:	c3                   	ret    

80101253 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101253:	55                   	push   %ebp
80101254:	89 e5                	mov    %esp,%ebp
80101256:	53                   	push   %ebx
80101257:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010125a:	8b 45 08             	mov    0x8(%ebp),%eax
8010125d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101261:	84 c0                	test   %al,%al
80101263:	75 0a                	jne    8010126f <filewrite+0x1c>
    return -1;
80101265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010126a:	e9 1b 01 00 00       	jmp    8010138a <filewrite+0x137>
  if(f->type == FD_PIPE)
8010126f:	8b 45 08             	mov    0x8(%ebp),%eax
80101272:	8b 00                	mov    (%eax),%eax
80101274:	83 f8 01             	cmp    $0x1,%eax
80101277:	75 1d                	jne    80101296 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 40 0c             	mov    0xc(%eax),%eax
8010127f:	83 ec 04             	sub    $0x4,%esp
80101282:	ff 75 10             	pushl  0x10(%ebp)
80101285:	ff 75 0c             	pushl  0xc(%ebp)
80101288:	50                   	push   %eax
80101289:	e8 b8 2f 00 00       	call   80104246 <pipewrite>
8010128e:	83 c4 10             	add    $0x10,%esp
80101291:	e9 f4 00 00 00       	jmp    8010138a <filewrite+0x137>
  if(f->type == FD_INODE){
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 00                	mov    (%eax),%eax
8010129b:	83 f8 02             	cmp    $0x2,%eax
8010129e:	0f 85 d9 00 00 00    	jne    8010137d <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012a4:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012b2:	e9 a3 00 00 00       	jmp    8010135a <filewrite+0x107>
      int n1 = n - i;
801012b7:	8b 45 10             	mov    0x10(%ebp),%eax
801012ba:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012c3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012c6:	7e 06                	jle    801012ce <filewrite+0x7b>
        n1 = max;
801012c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012ce:	e8 83 22 00 00       	call   80103556 <begin_op>
      ilock(f->ip);
801012d3:	8b 45 08             	mov    0x8(%ebp),%eax
801012d6:	8b 40 10             	mov    0x10(%eax),%eax
801012d9:	83 ec 0c             	sub    $0xc,%esp
801012dc:	50                   	push   %eax
801012dd:	e8 93 06 00 00       	call   80101975 <ilock>
801012e2:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012e5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012e8:	8b 45 08             	mov    0x8(%ebp),%eax
801012eb:	8b 50 14             	mov    0x14(%eax),%edx
801012ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801012f4:	01 c3                	add    %eax,%ebx
801012f6:	8b 45 08             	mov    0x8(%ebp),%eax
801012f9:	8b 40 10             	mov    0x10(%eax),%eax
801012fc:	51                   	push   %ecx
801012fd:	52                   	push   %edx
801012fe:	53                   	push   %ebx
801012ff:	50                   	push   %eax
80101300:	e8 30 0d 00 00       	call   80102035 <writei>
80101305:	83 c4 10             	add    $0x10,%esp
80101308:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010130b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010130f:	7e 11                	jle    80101322 <filewrite+0xcf>
        f->off += r;
80101311:	8b 45 08             	mov    0x8(%ebp),%eax
80101314:	8b 50 14             	mov    0x14(%eax),%edx
80101317:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010131a:	01 c2                	add    %eax,%edx
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	8b 40 10             	mov    0x10(%eax),%eax
80101328:	83 ec 0c             	sub    $0xc,%esp
8010132b:	50                   	push   %eax
8010132c:	e8 a2 07 00 00       	call   80101ad3 <iunlock>
80101331:	83 c4 10             	add    $0x10,%esp
      end_op();
80101334:	e8 a9 22 00 00       	call   801035e2 <end_op>

      if(r < 0)
80101339:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010133d:	78 29                	js     80101368 <filewrite+0x115>
        break;
      if(r != n1)
8010133f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101342:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101345:	74 0d                	je     80101354 <filewrite+0x101>
        panic("short filewrite");
80101347:	83 ec 0c             	sub    $0xc,%esp
8010134a:	68 9c 86 10 80       	push   $0x8010869c
8010134f:	e8 13 f2 ff ff       	call   80100567 <panic>
      i += r;
80101354:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101357:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010135a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101360:	0f 8c 51 ff ff ff    	jl     801012b7 <filewrite+0x64>
80101366:	eb 01                	jmp    80101369 <filewrite+0x116>
        break;
80101368:	90                   	nop
    }
    return i == n ? n : -1;
80101369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010136f:	75 05                	jne    80101376 <filewrite+0x123>
80101371:	8b 45 10             	mov    0x10(%ebp),%eax
80101374:	eb 14                	jmp    8010138a <filewrite+0x137>
80101376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010137b:	eb 0d                	jmp    8010138a <filewrite+0x137>
  }
  panic("filewrite");
8010137d:	83 ec 0c             	sub    $0xc,%esp
80101380:	68 ac 86 10 80       	push   $0x801086ac
80101385:	e8 dd f1 ff ff       	call   80100567 <panic>
}
8010138a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010138d:	c9                   	leave  
8010138e:	c3                   	ret    

8010138f <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010138f:	55                   	push   %ebp
80101390:	89 e5                	mov    %esp,%ebp
80101392:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101395:	8b 45 08             	mov    0x8(%ebp),%eax
80101398:	83 ec 08             	sub    $0x8,%esp
8010139b:	6a 01                	push   $0x1
8010139d:	50                   	push   %eax
8010139e:	e8 13 ee ff ff       	call   801001b6 <bread>
801013a3:	83 c4 10             	add    $0x10,%esp
801013a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ac:	83 c0 18             	add    $0x18,%eax
801013af:	83 ec 04             	sub    $0x4,%esp
801013b2:	6a 1c                	push   $0x1c
801013b4:	50                   	push   %eax
801013b5:	ff 75 0c             	pushl  0xc(%ebp)
801013b8:	e8 c9 3f 00 00       	call   80105386 <memmove>
801013bd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013c0:	83 ec 0c             	sub    $0xc,%esp
801013c3:	ff 75 f4             	pushl  -0xc(%ebp)
801013c6:	e8 63 ee ff ff       	call   8010022e <brelse>
801013cb:	83 c4 10             	add    $0x10,%esp
}
801013ce:	90                   	nop
801013cf:	c9                   	leave  
801013d0:	c3                   	ret    

801013d1 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013d1:	55                   	push   %ebp
801013d2:	89 e5                	mov    %esp,%ebp
801013d4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013d7:	8b 55 0c             	mov    0xc(%ebp),%edx
801013da:	8b 45 08             	mov    0x8(%ebp),%eax
801013dd:	83 ec 08             	sub    $0x8,%esp
801013e0:	52                   	push   %edx
801013e1:	50                   	push   %eax
801013e2:	e8 cf ed ff ff       	call   801001b6 <bread>
801013e7:	83 c4 10             	add    $0x10,%esp
801013ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f0:	83 c0 18             	add    $0x18,%eax
801013f3:	83 ec 04             	sub    $0x4,%esp
801013f6:	68 00 02 00 00       	push   $0x200
801013fb:	6a 00                	push   $0x0
801013fd:	50                   	push   %eax
801013fe:	e8 c4 3e 00 00       	call   801052c7 <memset>
80101403:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101406:	83 ec 0c             	sub    $0xc,%esp
80101409:	ff 75 f4             	pushl  -0xc(%ebp)
8010140c:	e8 7d 23 00 00       	call   8010378e <log_write>
80101411:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101414:	83 ec 0c             	sub    $0xc,%esp
80101417:	ff 75 f4             	pushl  -0xc(%ebp)
8010141a:	e8 0f ee ff ff       	call   8010022e <brelse>
8010141f:	83 c4 10             	add    $0x10,%esp
}
80101422:	90                   	nop
80101423:	c9                   	leave  
80101424:	c3                   	ret    

80101425 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101425:	55                   	push   %ebp
80101426:	89 e5                	mov    %esp,%ebp
80101428:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010142b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101439:	e9 13 01 00 00       	jmp    80101551 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
8010143e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101441:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101447:	85 c0                	test   %eax,%eax
80101449:	0f 48 c2             	cmovs  %edx,%eax
8010144c:	c1 f8 0c             	sar    $0xc,%eax
8010144f:	89 c2                	mov    %eax,%edx
80101451:	a1 38 12 11 80       	mov    0x80111238,%eax
80101456:	01 d0                	add    %edx,%eax
80101458:	83 ec 08             	sub    $0x8,%esp
8010145b:	50                   	push   %eax
8010145c:	ff 75 08             	pushl  0x8(%ebp)
8010145f:	e8 52 ed ff ff       	call   801001b6 <bread>
80101464:	83 c4 10             	add    $0x10,%esp
80101467:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010146a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101471:	e9 a6 00 00 00       	jmp    8010151c <balloc+0xf7>
      m = 1 << (bi % 8);
80101476:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101479:	99                   	cltd   
8010147a:	c1 ea 1d             	shr    $0x1d,%edx
8010147d:	01 d0                	add    %edx,%eax
8010147f:	83 e0 07             	and    $0x7,%eax
80101482:	29 d0                	sub    %edx,%eax
80101484:	ba 01 00 00 00       	mov    $0x1,%edx
80101489:	89 c1                	mov    %eax,%ecx
8010148b:	d3 e2                	shl    %cl,%edx
8010148d:	89 d0                	mov    %edx,%eax
8010148f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101492:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101495:	8d 50 07             	lea    0x7(%eax),%edx
80101498:	85 c0                	test   %eax,%eax
8010149a:	0f 48 c2             	cmovs  %edx,%eax
8010149d:	c1 f8 03             	sar    $0x3,%eax
801014a0:	89 c2                	mov    %eax,%edx
801014a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014a5:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014aa:	0f b6 c0             	movzbl %al,%eax
801014ad:	23 45 e8             	and    -0x18(%ebp),%eax
801014b0:	85 c0                	test   %eax,%eax
801014b2:	75 64                	jne    80101518 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b7:	8d 50 07             	lea    0x7(%eax),%edx
801014ba:	85 c0                	test   %eax,%eax
801014bc:	0f 48 c2             	cmovs  %edx,%eax
801014bf:	c1 f8 03             	sar    $0x3,%eax
801014c2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014c5:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014ca:	89 d1                	mov    %edx,%ecx
801014cc:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014cf:	09 ca                	or     %ecx,%edx
801014d1:	89 d1                	mov    %edx,%ecx
801014d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014d6:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014da:	83 ec 0c             	sub    $0xc,%esp
801014dd:	ff 75 ec             	pushl  -0x14(%ebp)
801014e0:	e8 a9 22 00 00       	call   8010378e <log_write>
801014e5:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014e8:	83 ec 0c             	sub    $0xc,%esp
801014eb:	ff 75 ec             	pushl  -0x14(%ebp)
801014ee:	e8 3b ed ff ff       	call   8010022e <brelse>
801014f3:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fc:	01 c2                	add    %eax,%edx
801014fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101501:	83 ec 08             	sub    $0x8,%esp
80101504:	52                   	push   %edx
80101505:	50                   	push   %eax
80101506:	e8 c6 fe ff ff       	call   801013d1 <bzero>
8010150b:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010150e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101511:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101514:	01 d0                	add    %edx,%eax
80101516:	eb 57                	jmp    8010156f <balloc+0x14a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101518:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010151c:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101523:	7f 17                	jg     8010153c <balloc+0x117>
80101525:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152b:	01 d0                	add    %edx,%eax
8010152d:	89 c2                	mov    %eax,%edx
8010152f:	a1 20 12 11 80       	mov    0x80111220,%eax
80101534:	39 c2                	cmp    %eax,%edx
80101536:	0f 82 3a ff ff ff    	jb     80101476 <balloc+0x51>
      }
    }
    brelse(bp);
8010153c:	83 ec 0c             	sub    $0xc,%esp
8010153f:	ff 75 ec             	pushl  -0x14(%ebp)
80101542:	e8 e7 ec ff ff       	call   8010022e <brelse>
80101547:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010154a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101551:	8b 15 20 12 11 80    	mov    0x80111220,%edx
80101557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010155a:	39 c2                	cmp    %eax,%edx
8010155c:	0f 87 dc fe ff ff    	ja     8010143e <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101562:	83 ec 0c             	sub    $0xc,%esp
80101565:	68 b8 86 10 80       	push   $0x801086b8
8010156a:	e8 f8 ef ff ff       	call   80100567 <panic>
}
8010156f:	c9                   	leave  
80101570:	c3                   	ret    

80101571 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101571:	55                   	push   %ebp
80101572:	89 e5                	mov    %esp,%ebp
80101574:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101577:	83 ec 08             	sub    $0x8,%esp
8010157a:	68 20 12 11 80       	push   $0x80111220
8010157f:	ff 75 08             	pushl  0x8(%ebp)
80101582:	e8 08 fe ff ff       	call   8010138f <readsb>
80101587:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010158a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010158d:	c1 e8 0c             	shr    $0xc,%eax
80101590:	89 c2                	mov    %eax,%edx
80101592:	a1 38 12 11 80       	mov    0x80111238,%eax
80101597:	01 c2                	add    %eax,%edx
80101599:	8b 45 08             	mov    0x8(%ebp),%eax
8010159c:	83 ec 08             	sub    $0x8,%esp
8010159f:	52                   	push   %edx
801015a0:	50                   	push   %eax
801015a1:	e8 10 ec ff ff       	call   801001b6 <bread>
801015a6:	83 c4 10             	add    $0x10,%esp
801015a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801015af:	25 ff 0f 00 00       	and    $0xfff,%eax
801015b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ba:	99                   	cltd   
801015bb:	c1 ea 1d             	shr    $0x1d,%edx
801015be:	01 d0                	add    %edx,%eax
801015c0:	83 e0 07             	and    $0x7,%eax
801015c3:	29 d0                	sub    %edx,%eax
801015c5:	ba 01 00 00 00       	mov    $0x1,%edx
801015ca:	89 c1                	mov    %eax,%ecx
801015cc:	d3 e2                	shl    %cl,%edx
801015ce:	89 d0                	mov    %edx,%eax
801015d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d6:	8d 50 07             	lea    0x7(%eax),%edx
801015d9:	85 c0                	test   %eax,%eax
801015db:	0f 48 c2             	cmovs  %edx,%eax
801015de:	c1 f8 03             	sar    $0x3,%eax
801015e1:	89 c2                	mov    %eax,%edx
801015e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e6:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015eb:	0f b6 c0             	movzbl %al,%eax
801015ee:	23 45 ec             	and    -0x14(%ebp),%eax
801015f1:	85 c0                	test   %eax,%eax
801015f3:	75 0d                	jne    80101602 <bfree+0x91>
    panic("freeing free block");
801015f5:	83 ec 0c             	sub    $0xc,%esp
801015f8:	68 ce 86 10 80       	push   $0x801086ce
801015fd:	e8 65 ef ff ff       	call   80100567 <panic>
  bp->data[bi/8] &= ~m;
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101613:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101618:	89 d1                	mov    %edx,%ecx
8010161a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010161d:	f7 d2                	not    %edx
8010161f:	21 ca                	and    %ecx,%edx
80101621:	89 d1                	mov    %edx,%ecx
80101623:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101626:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010162a:	83 ec 0c             	sub    $0xc,%esp
8010162d:	ff 75 f4             	pushl  -0xc(%ebp)
80101630:	e8 59 21 00 00       	call   8010378e <log_write>
80101635:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101638:	83 ec 0c             	sub    $0xc,%esp
8010163b:	ff 75 f4             	pushl  -0xc(%ebp)
8010163e:	e8 eb eb ff ff       	call   8010022e <brelse>
80101643:	83 c4 10             	add    $0x10,%esp
}
80101646:	90                   	nop
80101647:	c9                   	leave  
80101648:	c3                   	ret    

80101649 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101649:	55                   	push   %ebp
8010164a:	89 e5                	mov    %esp,%ebp
8010164c:	57                   	push   %edi
8010164d:	56                   	push   %esi
8010164e:	53                   	push   %ebx
8010164f:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101652:	83 ec 08             	sub    $0x8,%esp
80101655:	68 e1 86 10 80       	push   $0x801086e1
8010165a:	68 40 12 11 80       	push   $0x80111240
8010165f:	e8 de 39 00 00       	call   80105042 <initlock>
80101664:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101667:	83 ec 08             	sub    $0x8,%esp
8010166a:	68 20 12 11 80       	push   $0x80111220
8010166f:	ff 75 08             	pushl  0x8(%ebp)
80101672:	e8 18 fd ff ff       	call   8010138f <readsb>
80101677:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010167a:	a1 38 12 11 80       	mov    0x80111238,%eax
8010167f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101682:	8b 3d 34 12 11 80    	mov    0x80111234,%edi
80101688:	8b 35 30 12 11 80    	mov    0x80111230,%esi
8010168e:	8b 1d 2c 12 11 80    	mov    0x8011122c,%ebx
80101694:	8b 0d 28 12 11 80    	mov    0x80111228,%ecx
8010169a:	8b 15 24 12 11 80    	mov    0x80111224,%edx
801016a0:	a1 20 12 11 80       	mov    0x80111220,%eax
801016a5:	ff 75 e4             	pushl  -0x1c(%ebp)
801016a8:	57                   	push   %edi
801016a9:	56                   	push   %esi
801016aa:	53                   	push   %ebx
801016ab:	51                   	push   %ecx
801016ac:	52                   	push   %edx
801016ad:	50                   	push   %eax
801016ae:	68 e8 86 10 80       	push   $0x801086e8
801016b3:	e8 0c ed ff ff       	call   801003c4 <cprintf>
801016b8:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016bb:	90                   	nop
801016bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016bf:	5b                   	pop    %ebx
801016c0:	5e                   	pop    %esi
801016c1:	5f                   	pop    %edi
801016c2:	5d                   	pop    %ebp
801016c3:	c3                   	ret    

801016c4 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016c4:	55                   	push   %ebp
801016c5:	89 e5                	mov    %esp,%ebp
801016c7:	83 ec 28             	sub    $0x28,%esp
801016ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801016cd:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016d1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016d8:	e9 9e 00 00 00       	jmp    8010177b <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e0:	c1 e8 03             	shr    $0x3,%eax
801016e3:	89 c2                	mov    %eax,%edx
801016e5:	a1 34 12 11 80       	mov    0x80111234,%eax
801016ea:	01 d0                	add    %edx,%eax
801016ec:	83 ec 08             	sub    $0x8,%esp
801016ef:	50                   	push   %eax
801016f0:	ff 75 08             	pushl  0x8(%ebp)
801016f3:	e8 be ea ff ff       	call   801001b6 <bread>
801016f8:	83 c4 10             	add    $0x10,%esp
801016fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101701:	8d 50 18             	lea    0x18(%eax),%edx
80101704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101707:	83 e0 07             	and    $0x7,%eax
8010170a:	c1 e0 06             	shl    $0x6,%eax
8010170d:	01 d0                	add    %edx,%eax
8010170f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101712:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101715:	0f b7 00             	movzwl (%eax),%eax
80101718:	66 85 c0             	test   %ax,%ax
8010171b:	75 4c                	jne    80101769 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010171d:	83 ec 04             	sub    $0x4,%esp
80101720:	6a 40                	push   $0x40
80101722:	6a 00                	push   $0x0
80101724:	ff 75 ec             	pushl  -0x14(%ebp)
80101727:	e8 9b 3b 00 00       	call   801052c7 <memset>
8010172c:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010172f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101732:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101736:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101739:	83 ec 0c             	sub    $0xc,%esp
8010173c:	ff 75 f0             	pushl  -0x10(%ebp)
8010173f:	e8 4a 20 00 00       	call   8010378e <log_write>
80101744:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101747:	83 ec 0c             	sub    $0xc,%esp
8010174a:	ff 75 f0             	pushl  -0x10(%ebp)
8010174d:	e8 dc ea ff ff       	call   8010022e <brelse>
80101752:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101758:	83 ec 08             	sub    $0x8,%esp
8010175b:	50                   	push   %eax
8010175c:	ff 75 08             	pushl  0x8(%ebp)
8010175f:	e8 f8 00 00 00       	call   8010185c <iget>
80101764:	83 c4 10             	add    $0x10,%esp
80101767:	eb 30                	jmp    80101799 <ialloc+0xd5>
    }
    brelse(bp);
80101769:	83 ec 0c             	sub    $0xc,%esp
8010176c:	ff 75 f0             	pushl  -0x10(%ebp)
8010176f:	e8 ba ea ff ff       	call   8010022e <brelse>
80101774:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101777:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010177b:	8b 15 28 12 11 80    	mov    0x80111228,%edx
80101781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101784:	39 c2                	cmp    %eax,%edx
80101786:	0f 87 51 ff ff ff    	ja     801016dd <ialloc+0x19>
  }
  panic("ialloc: no inodes");
8010178c:	83 ec 0c             	sub    $0xc,%esp
8010178f:	68 3b 87 10 80       	push   $0x8010873b
80101794:	e8 ce ed ff ff       	call   80100567 <panic>
}
80101799:	c9                   	leave  
8010179a:	c3                   	ret    

8010179b <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010179b:	55                   	push   %ebp
8010179c:	89 e5                	mov    %esp,%ebp
8010179e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017a1:	8b 45 08             	mov    0x8(%ebp),%eax
801017a4:	8b 40 04             	mov    0x4(%eax),%eax
801017a7:	c1 e8 03             	shr    $0x3,%eax
801017aa:	89 c2                	mov    %eax,%edx
801017ac:	a1 34 12 11 80       	mov    0x80111234,%eax
801017b1:	01 c2                	add    %eax,%edx
801017b3:	8b 45 08             	mov    0x8(%ebp),%eax
801017b6:	8b 00                	mov    (%eax),%eax
801017b8:	83 ec 08             	sub    $0x8,%esp
801017bb:	52                   	push   %edx
801017bc:	50                   	push   %eax
801017bd:	e8 f4 e9 ff ff       	call   801001b6 <bread>
801017c2:	83 c4 10             	add    $0x10,%esp
801017c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	8d 50 18             	lea    0x18(%eax),%edx
801017ce:	8b 45 08             	mov    0x8(%ebp),%eax
801017d1:	8b 40 04             	mov    0x4(%eax),%eax
801017d4:	83 e0 07             	and    $0x7,%eax
801017d7:	c1 e0 06             	shl    $0x6,%eax
801017da:	01 d0                	add    %edx,%eax
801017dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017df:	8b 45 08             	mov    0x8(%ebp),%eax
801017e2:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e9:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017ec:	8b 45 08             	mov    0x8(%ebp),%eax
801017ef:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f6:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017fa:	8b 45 08             	mov    0x8(%ebp),%eax
801017fd:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101804:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101808:	8b 45 08             	mov    0x8(%ebp),%eax
8010180b:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101812:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101816:	8b 45 08             	mov    0x8(%ebp),%eax
80101819:	8b 50 18             	mov    0x18(%eax),%edx
8010181c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010181f:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101822:	8b 45 08             	mov    0x8(%ebp),%eax
80101825:	8d 50 1c             	lea    0x1c(%eax),%edx
80101828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010182b:	83 c0 0c             	add    $0xc,%eax
8010182e:	83 ec 04             	sub    $0x4,%esp
80101831:	6a 34                	push   $0x34
80101833:	52                   	push   %edx
80101834:	50                   	push   %eax
80101835:	e8 4c 3b 00 00       	call   80105386 <memmove>
8010183a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010183d:	83 ec 0c             	sub    $0xc,%esp
80101840:	ff 75 f4             	pushl  -0xc(%ebp)
80101843:	e8 46 1f 00 00       	call   8010378e <log_write>
80101848:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010184b:	83 ec 0c             	sub    $0xc,%esp
8010184e:	ff 75 f4             	pushl  -0xc(%ebp)
80101851:	e8 d8 e9 ff ff       	call   8010022e <brelse>
80101856:	83 c4 10             	add    $0x10,%esp
}
80101859:	90                   	nop
8010185a:	c9                   	leave  
8010185b:	c3                   	ret    

8010185c <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010185c:	55                   	push   %ebp
8010185d:	89 e5                	mov    %esp,%ebp
8010185f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101862:	83 ec 0c             	sub    $0xc,%esp
80101865:	68 40 12 11 80       	push   $0x80111240
8010186a:	e8 f5 37 00 00       	call   80105064 <acquire>
8010186f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101872:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101879:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101880:	eb 5d                	jmp    801018df <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101885:	8b 40 08             	mov    0x8(%eax),%eax
80101888:	85 c0                	test   %eax,%eax
8010188a:	7e 39                	jle    801018c5 <iget+0x69>
8010188c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188f:	8b 00                	mov    (%eax),%eax
80101891:	39 45 08             	cmp    %eax,0x8(%ebp)
80101894:	75 2f                	jne    801018c5 <iget+0x69>
80101896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101899:	8b 40 04             	mov    0x4(%eax),%eax
8010189c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010189f:	75 24                	jne    801018c5 <iget+0x69>
      ip->ref++;
801018a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a4:	8b 40 08             	mov    0x8(%eax),%eax
801018a7:	8d 50 01             	lea    0x1(%eax),%edx
801018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ad:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018b0:	83 ec 0c             	sub    $0xc,%esp
801018b3:	68 40 12 11 80       	push   $0x80111240
801018b8:	e8 0e 38 00 00       	call   801050cb <release>
801018bd:	83 c4 10             	add    $0x10,%esp
      return ip;
801018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c3:	eb 74                	jmp    80101939 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018c9:	75 10                	jne    801018db <iget+0x7f>
801018cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ce:	8b 40 08             	mov    0x8(%eax),%eax
801018d1:	85 c0                	test   %eax,%eax
801018d3:	75 06                	jne    801018db <iget+0x7f>
      empty = ip;
801018d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018db:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018df:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801018e6:	72 9a                	jb     80101882 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018ec:	75 0d                	jne    801018fb <iget+0x9f>
    panic("iget: no inodes");
801018ee:	83 ec 0c             	sub    $0xc,%esp
801018f1:	68 4d 87 10 80       	push   $0x8010874d
801018f6:	e8 6c ec ff ff       	call   80100567 <panic>

  ip = empty;
801018fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101904:	8b 55 08             	mov    0x8(%ebp),%edx
80101907:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010190f:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101915:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101926:	83 ec 0c             	sub    $0xc,%esp
80101929:	68 40 12 11 80       	push   $0x80111240
8010192e:	e8 98 37 00 00       	call   801050cb <release>
80101933:	83 c4 10             	add    $0x10,%esp

  return ip;
80101936:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101939:	c9                   	leave  
8010193a:	c3                   	ret    

8010193b <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010193b:	55                   	push   %ebp
8010193c:	89 e5                	mov    %esp,%ebp
8010193e:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101941:	83 ec 0c             	sub    $0xc,%esp
80101944:	68 40 12 11 80       	push   $0x80111240
80101949:	e8 16 37 00 00       	call   80105064 <acquire>
8010194e:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101951:	8b 45 08             	mov    0x8(%ebp),%eax
80101954:	8b 40 08             	mov    0x8(%eax),%eax
80101957:	8d 50 01             	lea    0x1(%eax),%edx
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101960:	83 ec 0c             	sub    $0xc,%esp
80101963:	68 40 12 11 80       	push   $0x80111240
80101968:	e8 5e 37 00 00       	call   801050cb <release>
8010196d:	83 c4 10             	add    $0x10,%esp
  return ip;
80101970:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101973:	c9                   	leave  
80101974:	c3                   	ret    

80101975 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101975:	55                   	push   %ebp
80101976:	89 e5                	mov    %esp,%ebp
80101978:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010197b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010197f:	74 0a                	je     8010198b <ilock+0x16>
80101981:	8b 45 08             	mov    0x8(%ebp),%eax
80101984:	8b 40 08             	mov    0x8(%eax),%eax
80101987:	85 c0                	test   %eax,%eax
80101989:	7f 0d                	jg     80101998 <ilock+0x23>
    panic("ilock");
8010198b:	83 ec 0c             	sub    $0xc,%esp
8010198e:	68 5d 87 10 80       	push   $0x8010875d
80101993:	e8 cf eb ff ff       	call   80100567 <panic>

  acquire(&icache.lock);
80101998:	83 ec 0c             	sub    $0xc,%esp
8010199b:	68 40 12 11 80       	push   $0x80111240
801019a0:	e8 bf 36 00 00       	call   80105064 <acquire>
801019a5:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019a8:	eb 13                	jmp    801019bd <ilock+0x48>
    sleep(ip, &icache.lock);
801019aa:	83 ec 08             	sub    $0x8,%esp
801019ad:	68 40 12 11 80       	push   $0x80111240
801019b2:	ff 75 08             	pushl  0x8(%ebp)
801019b5:	e8 b1 33 00 00       	call   80104d6b <sleep>
801019ba:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019bd:	8b 45 08             	mov    0x8(%ebp),%eax
801019c0:	8b 40 0c             	mov    0xc(%eax),%eax
801019c3:	83 e0 01             	and    $0x1,%eax
801019c6:	85 c0                	test   %eax,%eax
801019c8:	75 e0                	jne    801019aa <ilock+0x35>
  ip->flags |= I_BUSY;
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	8b 40 0c             	mov    0xc(%eax),%eax
801019d0:	83 c8 01             	or     $0x1,%eax
801019d3:	89 c2                	mov    %eax,%edx
801019d5:	8b 45 08             	mov    0x8(%ebp),%eax
801019d8:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019db:	83 ec 0c             	sub    $0xc,%esp
801019de:	68 40 12 11 80       	push   $0x80111240
801019e3:	e8 e3 36 00 00       	call   801050cb <release>
801019e8:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019eb:	8b 45 08             	mov    0x8(%ebp),%eax
801019ee:	8b 40 0c             	mov    0xc(%eax),%eax
801019f1:	83 e0 02             	and    $0x2,%eax
801019f4:	85 c0                	test   %eax,%eax
801019f6:	0f 85 d4 00 00 00    	jne    80101ad0 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019fc:	8b 45 08             	mov    0x8(%ebp),%eax
801019ff:	8b 40 04             	mov    0x4(%eax),%eax
80101a02:	c1 e8 03             	shr    $0x3,%eax
80101a05:	89 c2                	mov    %eax,%edx
80101a07:	a1 34 12 11 80       	mov    0x80111234,%eax
80101a0c:	01 c2                	add    %eax,%edx
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	8b 00                	mov    (%eax),%eax
80101a13:	83 ec 08             	sub    $0x8,%esp
80101a16:	52                   	push   %edx
80101a17:	50                   	push   %eax
80101a18:	e8 99 e7 ff ff       	call   801001b6 <bread>
80101a1d:	83 c4 10             	add    $0x10,%esp
80101a20:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a26:	8d 50 18             	lea    0x18(%eax),%edx
80101a29:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2c:	8b 40 04             	mov    0x4(%eax),%eax
80101a2f:	83 e0 07             	and    $0x7,%eax
80101a32:	c1 e0 06             	shl    $0x6,%eax
80101a35:	01 d0                	add    %edx,%eax
80101a37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3d:	0f b7 10             	movzwl (%eax),%edx
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4a:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a51:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a58:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a66:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6d:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a74:	8b 50 08             	mov    0x8(%eax),%edx
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7a:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a80:	8d 50 0c             	lea    0xc(%eax),%edx
80101a83:	8b 45 08             	mov    0x8(%ebp),%eax
80101a86:	83 c0 1c             	add    $0x1c,%eax
80101a89:	83 ec 04             	sub    $0x4,%esp
80101a8c:	6a 34                	push   $0x34
80101a8e:	52                   	push   %edx
80101a8f:	50                   	push   %eax
80101a90:	e8 f1 38 00 00       	call   80105386 <memmove>
80101a95:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a98:	83 ec 0c             	sub    $0xc,%esp
80101a9b:	ff 75 f4             	pushl  -0xc(%ebp)
80101a9e:	e8 8b e7 ff ff       	call   8010022e <brelse>
80101aa3:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa9:	8b 40 0c             	mov    0xc(%eax),%eax
80101aac:	83 c8 02             	or     $0x2,%eax
80101aaf:	89 c2                	mov    %eax,%edx
80101ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab4:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101abe:	66 85 c0             	test   %ax,%ax
80101ac1:	75 0d                	jne    80101ad0 <ilock+0x15b>
      panic("ilock: no type");
80101ac3:	83 ec 0c             	sub    $0xc,%esp
80101ac6:	68 63 87 10 80       	push   $0x80108763
80101acb:	e8 97 ea ff ff       	call   80100567 <panic>
  }
}
80101ad0:	90                   	nop
80101ad1:	c9                   	leave  
80101ad2:	c3                   	ret    

80101ad3 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ad3:	55                   	push   %ebp
80101ad4:	89 e5                	mov    %esp,%ebp
80101ad6:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ad9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101add:	74 17                	je     80101af6 <iunlock+0x23>
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	8b 40 0c             	mov    0xc(%eax),%eax
80101ae5:	83 e0 01             	and    $0x1,%eax
80101ae8:	85 c0                	test   %eax,%eax
80101aea:	74 0a                	je     80101af6 <iunlock+0x23>
80101aec:	8b 45 08             	mov    0x8(%ebp),%eax
80101aef:	8b 40 08             	mov    0x8(%eax),%eax
80101af2:	85 c0                	test   %eax,%eax
80101af4:	7f 0d                	jg     80101b03 <iunlock+0x30>
    panic("iunlock");
80101af6:	83 ec 0c             	sub    $0xc,%esp
80101af9:	68 72 87 10 80       	push   $0x80108772
80101afe:	e8 64 ea ff ff       	call   80100567 <panic>

  acquire(&icache.lock);
80101b03:	83 ec 0c             	sub    $0xc,%esp
80101b06:	68 40 12 11 80       	push   $0x80111240
80101b0b:	e8 54 35 00 00       	call   80105064 <acquire>
80101b10:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	8b 40 0c             	mov    0xc(%eax),%eax
80101b19:	83 e0 fe             	and    $0xfffffffe,%eax
80101b1c:	89 c2                	mov    %eax,%edx
80101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b21:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b24:	83 ec 0c             	sub    $0xc,%esp
80101b27:	ff 75 08             	pushl  0x8(%ebp)
80101b2a:	e8 27 33 00 00       	call   80104e56 <wakeup>
80101b2f:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b32:	83 ec 0c             	sub    $0xc,%esp
80101b35:	68 40 12 11 80       	push   $0x80111240
80101b3a:	e8 8c 35 00 00       	call   801050cb <release>
80101b3f:	83 c4 10             	add    $0x10,%esp
}
80101b42:	90                   	nop
80101b43:	c9                   	leave  
80101b44:	c3                   	ret    

80101b45 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b45:	55                   	push   %ebp
80101b46:	89 e5                	mov    %esp,%ebp
80101b48:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b4b:	83 ec 0c             	sub    $0xc,%esp
80101b4e:	68 40 12 11 80       	push   $0x80111240
80101b53:	e8 0c 35 00 00       	call   80105064 <acquire>
80101b58:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5e:	8b 40 08             	mov    0x8(%eax),%eax
80101b61:	83 f8 01             	cmp    $0x1,%eax
80101b64:	0f 85 a9 00 00 00    	jne    80101c13 <iput+0xce>
80101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6d:	8b 40 0c             	mov    0xc(%eax),%eax
80101b70:	83 e0 02             	and    $0x2,%eax
80101b73:	85 c0                	test   %eax,%eax
80101b75:	0f 84 98 00 00 00    	je     80101c13 <iput+0xce>
80101b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b82:	66 85 c0             	test   %ax,%ax
80101b85:	0f 85 88 00 00 00    	jne    80101c13 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8e:	8b 40 0c             	mov    0xc(%eax),%eax
80101b91:	83 e0 01             	and    $0x1,%eax
80101b94:	85 c0                	test   %eax,%eax
80101b96:	74 0d                	je     80101ba5 <iput+0x60>
      panic("iput busy");
80101b98:	83 ec 0c             	sub    $0xc,%esp
80101b9b:	68 7a 87 10 80       	push   $0x8010877a
80101ba0:	e8 c2 e9 ff ff       	call   80100567 <panic>
    ip->flags |= I_BUSY;
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	8b 40 0c             	mov    0xc(%eax),%eax
80101bab:	83 c8 01             	or     $0x1,%eax
80101bae:	89 c2                	mov    %eax,%edx
80101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb3:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bb6:	83 ec 0c             	sub    $0xc,%esp
80101bb9:	68 40 12 11 80       	push   $0x80111240
80101bbe:	e8 08 35 00 00       	call   801050cb <release>
80101bc3:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bc6:	83 ec 0c             	sub    $0xc,%esp
80101bc9:	ff 75 08             	pushl  0x8(%ebp)
80101bcc:	e8 a3 01 00 00       	call   80101d74 <itrunc>
80101bd1:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd7:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	ff 75 08             	pushl  0x8(%ebp)
80101be3:	e8 b3 fb ff ff       	call   8010179b <iupdate>
80101be8:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101beb:	83 ec 0c             	sub    $0xc,%esp
80101bee:	68 40 12 11 80       	push   $0x80111240
80101bf3:	e8 6c 34 00 00       	call   80105064 <acquire>
80101bf8:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfe:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c05:	83 ec 0c             	sub    $0xc,%esp
80101c08:	ff 75 08             	pushl  0x8(%ebp)
80101c0b:	e8 46 32 00 00       	call   80104e56 <wakeup>
80101c10:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	8b 40 08             	mov    0x8(%eax),%eax
80101c19:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1f:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	68 40 12 11 80       	push   $0x80111240
80101c2a:	e8 9c 34 00 00       	call   801050cb <release>
80101c2f:	83 c4 10             	add    $0x10,%esp
}
80101c32:	90                   	nop
80101c33:	c9                   	leave  
80101c34:	c3                   	ret    

80101c35 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c35:	55                   	push   %ebp
80101c36:	89 e5                	mov    %esp,%ebp
80101c38:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c3b:	83 ec 0c             	sub    $0xc,%esp
80101c3e:	ff 75 08             	pushl  0x8(%ebp)
80101c41:	e8 8d fe ff ff       	call   80101ad3 <iunlock>
80101c46:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c49:	83 ec 0c             	sub    $0xc,%esp
80101c4c:	ff 75 08             	pushl  0x8(%ebp)
80101c4f:	e8 f1 fe ff ff       	call   80101b45 <iput>
80101c54:	83 c4 10             	add    $0x10,%esp
}
80101c57:	90                   	nop
80101c58:	c9                   	leave  
80101c59:	c3                   	ret    

80101c5a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c5a:	55                   	push   %ebp
80101c5b:	89 e5                	mov    %esp,%ebp
80101c5d:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c60:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c64:	77 42                	ja     80101ca8 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c66:	8b 45 08             	mov    0x8(%ebp),%eax
80101c69:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c6c:	83 c2 04             	add    $0x4,%edx
80101c6f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c7a:	75 24                	jne    80101ca0 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7f:	8b 00                	mov    (%eax),%eax
80101c81:	83 ec 0c             	sub    $0xc,%esp
80101c84:	50                   	push   %eax
80101c85:	e8 9b f7 ff ff       	call   80101425 <balloc>
80101c8a:	83 c4 10             	add    $0x10,%esp
80101c8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c90:	8b 45 08             	mov    0x8(%ebp),%eax
80101c93:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c96:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c9c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ca3:	e9 ca 00 00 00       	jmp    80101d72 <bmap+0x118>
  }
  bn -= NDIRECT;
80101ca8:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cac:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cb0:	0f 87 af 00 00 00    	ja     80101d65 <bmap+0x10b>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cc3:	75 1d                	jne    80101ce2 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc8:	8b 00                	mov    (%eax),%eax
80101cca:	83 ec 0c             	sub    $0xc,%esp
80101ccd:	50                   	push   %eax
80101cce:	e8 52 f7 ff ff       	call   80101425 <balloc>
80101cd3:	83 c4 10             	add    $0x10,%esp
80101cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cdf:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce5:	8b 00                	mov    (%eax),%eax
80101ce7:	83 ec 08             	sub    $0x8,%esp
80101cea:	ff 75 f4             	pushl  -0xc(%ebp)
80101ced:	50                   	push   %eax
80101cee:	e8 c3 e4 ff ff       	call   801001b6 <bread>
80101cf3:	83 c4 10             	add    $0x10,%esp
80101cf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cfc:	83 c0 18             	add    $0x18,%eax
80101cff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d02:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d05:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d0f:	01 d0                	add    %edx,%eax
80101d11:	8b 00                	mov    (%eax),%eax
80101d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d1a:	75 36                	jne    80101d52 <bmap+0xf8>
      a[bn] = addr = balloc(ip->dev);
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 00                	mov    (%eax),%eax
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	50                   	push   %eax
80101d25:	e8 fb f6 ff ff       	call   80101425 <balloc>
80101d2a:	83 c4 10             	add    $0x10,%esp
80101d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d30:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d3d:	01 c2                	add    %eax,%edx
80101d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d42:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d44:	83 ec 0c             	sub    $0xc,%esp
80101d47:	ff 75 f0             	pushl  -0x10(%ebp)
80101d4a:	e8 3f 1a 00 00       	call   8010378e <log_write>
80101d4f:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d52:	83 ec 0c             	sub    $0xc,%esp
80101d55:	ff 75 f0             	pushl  -0x10(%ebp)
80101d58:	e8 d1 e4 ff ff       	call   8010022e <brelse>
80101d5d:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d63:	eb 0d                	jmp    80101d72 <bmap+0x118>
  }

  panic("bmap: out of range");
80101d65:	83 ec 0c             	sub    $0xc,%esp
80101d68:	68 84 87 10 80       	push   $0x80108784
80101d6d:	e8 f5 e7 ff ff       	call   80100567 <panic>
}
80101d72:	c9                   	leave  
80101d73:	c3                   	ret    

80101d74 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d74:	55                   	push   %ebp
80101d75:	89 e5                	mov    %esp,%ebp
80101d77:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d81:	eb 45                	jmp    80101dc8 <itrunc+0x54>
    if(ip->addrs[i]){
80101d83:	8b 45 08             	mov    0x8(%ebp),%eax
80101d86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d89:	83 c2 04             	add    $0x4,%edx
80101d8c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d90:	85 c0                	test   %eax,%eax
80101d92:	74 30                	je     80101dc4 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9a:	83 c2 04             	add    $0x4,%edx
80101d9d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101da1:	8b 55 08             	mov    0x8(%ebp),%edx
80101da4:	8b 12                	mov    (%edx),%edx
80101da6:	83 ec 08             	sub    $0x8,%esp
80101da9:	50                   	push   %eax
80101daa:	52                   	push   %edx
80101dab:	e8 c1 f7 ff ff       	call   80101571 <bfree>
80101db0:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101db3:	8b 45 08             	mov    0x8(%ebp),%eax
80101db6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db9:	83 c2 04             	add    $0x4,%edx
80101dbc:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dc3:	00 
  for(i = 0; i < NDIRECT; i++){
80101dc4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc8:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dcc:	7e b5                	jle    80101d83 <itrunc+0xf>
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dce:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd1:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dd4:	85 c0                	test   %eax,%eax
80101dd6:	0f 84 a1 00 00 00    	je     80101e7d <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 50 4c             	mov    0x4c(%eax),%edx
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 00                	mov    (%eax),%eax
80101de7:	83 ec 08             	sub    $0x8,%esp
80101dea:	52                   	push   %edx
80101deb:	50                   	push   %eax
80101dec:	e8 c5 e3 ff ff       	call   801001b6 <bread>
80101df1:	83 c4 10             	add    $0x10,%esp
80101df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dfa:	83 c0 18             	add    $0x18,%eax
80101dfd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e00:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e07:	eb 3c                	jmp    80101e45 <itrunc+0xd1>
      if(a[j])
80101e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e0c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e16:	01 d0                	add    %edx,%eax
80101e18:	8b 00                	mov    (%eax),%eax
80101e1a:	85 c0                	test   %eax,%eax
80101e1c:	74 23                	je     80101e41 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e28:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e2b:	01 d0                	add    %edx,%eax
80101e2d:	8b 00                	mov    (%eax),%eax
80101e2f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e32:	8b 12                	mov    (%edx),%edx
80101e34:	83 ec 08             	sub    $0x8,%esp
80101e37:	50                   	push   %eax
80101e38:	52                   	push   %edx
80101e39:	e8 33 f7 ff ff       	call   80101571 <bfree>
80101e3e:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e41:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e48:	83 f8 7f             	cmp    $0x7f,%eax
80101e4b:	76 bc                	jbe    80101e09 <itrunc+0x95>
    }
    brelse(bp);
80101e4d:	83 ec 0c             	sub    $0xc,%esp
80101e50:	ff 75 ec             	pushl  -0x14(%ebp)
80101e53:	e8 d6 e3 ff ff       	call   8010022e <brelse>
80101e58:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e61:	8b 55 08             	mov    0x8(%ebp),%edx
80101e64:	8b 12                	mov    (%edx),%edx
80101e66:	83 ec 08             	sub    $0x8,%esp
80101e69:	50                   	push   %eax
80101e6a:	52                   	push   %edx
80101e6b:	e8 01 f7 ff ff       	call   80101571 <bfree>
80101e70:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e73:	8b 45 08             	mov    0x8(%ebp),%eax
80101e76:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e87:	83 ec 0c             	sub    $0xc,%esp
80101e8a:	ff 75 08             	pushl  0x8(%ebp)
80101e8d:	e8 09 f9 ff ff       	call   8010179b <iupdate>
80101e92:	83 c4 10             	add    $0x10,%esp
}
80101e95:	90                   	nop
80101e96:	c9                   	leave  
80101e97:	c3                   	ret    

80101e98 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e98:	55                   	push   %ebp
80101e99:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 00                	mov    (%eax),%eax
80101ea0:	89 c2                	mov    %eax,%edx
80101ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	8b 50 04             	mov    0x4(%eax),%edx
80101eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 50 18             	mov    0x18(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edb:	90                   	nop
80101edc:	5d                   	pop    %ebp
80101edd:	c3                   	ret    

80101ede <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ede:	55                   	push   %ebp
80101edf:	89 e5                	mov    %esp,%ebp
80101ee1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101eeb:	66 83 f8 03          	cmp    $0x3,%ax
80101eef:	75 5c                	jne    80101f4d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef8:	66 85 c0             	test   %ax,%ax
80101efb:	78 20                	js     80101f1d <readi+0x3f>
80101efd:	8b 45 08             	mov    0x8(%ebp),%eax
80101f00:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f04:	66 83 f8 09          	cmp    $0x9,%ax
80101f08:	7f 13                	jg     80101f1d <readi+0x3f>
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f11:	98                   	cwtl   
80101f12:	8b 04 c5 c0 11 11 80 	mov    -0x7feeee40(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0c 01 00 00       	jmp    80102033 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f2e:	98                   	cwtl   
80101f2f:	8b 04 c5 c0 11 11 80 	mov    -0x7feeee40(,%eax,8),%eax
80101f36:	8b 55 14             	mov    0x14(%ebp),%edx
80101f39:	83 ec 04             	sub    $0x4,%esp
80101f3c:	52                   	push   %edx
80101f3d:	ff 75 0c             	pushl  0xc(%ebp)
80101f40:	ff 75 08             	pushl  0x8(%ebp)
80101f43:	ff d0                	call   *%eax
80101f45:	83 c4 10             	add    $0x10,%esp
80101f48:	e9 e6 00 00 00       	jmp    80102033 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 40 18             	mov    0x18(%eax),%eax
80101f53:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f56:	77 0d                	ja     80101f65 <readi+0x87>
80101f58:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5e:	01 d0                	add    %edx,%eax
80101f60:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f63:	76 0a                	jbe    80101f6f <readi+0x91>
    return -1;
80101f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6a:	e9 c4 00 00 00       	jmp    80102033 <readi+0x155>
  if(off + n > ip->size)
80101f6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f72:	8b 45 14             	mov    0x14(%ebp),%eax
80101f75:	01 c2                	add    %eax,%edx
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	8b 40 18             	mov    0x18(%eax),%eax
80101f7d:	39 c2                	cmp    %eax,%edx
80101f7f:	76 0c                	jbe    80101f8d <readi+0xaf>
    n = ip->size - off;
80101f81:	8b 45 08             	mov    0x8(%ebp),%eax
80101f84:	8b 40 18             	mov    0x18(%eax),%eax
80101f87:	2b 45 10             	sub    0x10(%ebp),%eax
80101f8a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f94:	e9 8b 00 00 00       	jmp    80102024 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f99:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9c:	c1 e8 09             	shr    $0x9,%eax
80101f9f:	83 ec 08             	sub    $0x8,%esp
80101fa2:	50                   	push   %eax
80101fa3:	ff 75 08             	pushl  0x8(%ebp)
80101fa6:	e8 af fc ff ff       	call   80101c5a <bmap>
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	89 c2                	mov    %eax,%edx
80101fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb3:	8b 00                	mov    (%eax),%eax
80101fb5:	83 ec 08             	sub    $0x8,%esp
80101fb8:	52                   	push   %edx
80101fb9:	50                   	push   %eax
80101fba:	e8 f7 e1 ff ff       	call   801001b6 <bread>
80101fbf:	83 c4 10             	add    $0x10,%esp
80101fc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc8:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcd:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd2:	29 c2                	sub    %eax,%edx
80101fd4:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd7:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fda:	39 c2                	cmp    %eax,%edx
80101fdc:	0f 46 c2             	cmovbe %edx,%eax
80101fdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe5:	8d 50 18             	lea    0x18(%eax),%edx
80101fe8:	8b 45 10             	mov    0x10(%ebp),%eax
80101feb:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff0:	01 d0                	add    %edx,%eax
80101ff2:	83 ec 04             	sub    $0x4,%esp
80101ff5:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff8:	50                   	push   %eax
80101ff9:	ff 75 0c             	pushl  0xc(%ebp)
80101ffc:	e8 85 33 00 00       	call   80105386 <memmove>
80102001:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102004:	83 ec 0c             	sub    $0xc,%esp
80102007:	ff 75 f0             	pushl  -0x10(%ebp)
8010200a:	e8 1f e2 ff ff       	call   8010022e <brelse>
8010200f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102012:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102015:	01 45 f4             	add    %eax,-0xc(%ebp)
80102018:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201b:	01 45 10             	add    %eax,0x10(%ebp)
8010201e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102021:	01 45 0c             	add    %eax,0xc(%ebp)
80102024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102027:	3b 45 14             	cmp    0x14(%ebp),%eax
8010202a:	0f 82 69 ff ff ff    	jb     80101f99 <readi+0xbb>
  }
  return n;
80102030:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102033:	c9                   	leave  
80102034:	c3                   	ret    

80102035 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102035:	55                   	push   %ebp
80102036:	89 e5                	mov    %esp,%ebp
80102038:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102042:	66 83 f8 03          	cmp    $0x3,%ax
80102046:	75 5c                	jne    801020a4 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102048:	8b 45 08             	mov    0x8(%ebp),%eax
8010204b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010204f:	66 85 c0             	test   %ax,%ax
80102052:	78 20                	js     80102074 <writei+0x3f>
80102054:	8b 45 08             	mov    0x8(%ebp),%eax
80102057:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010205b:	66 83 f8 09          	cmp    $0x9,%ax
8010205f:	7f 13                	jg     80102074 <writei+0x3f>
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102068:	98                   	cwtl   
80102069:	8b 04 c5 c4 11 11 80 	mov    -0x7feeee3c(,%eax,8),%eax
80102070:	85 c0                	test   %eax,%eax
80102072:	75 0a                	jne    8010207e <writei+0x49>
      return -1;
80102074:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102079:	e9 3d 01 00 00       	jmp    801021bb <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010207e:	8b 45 08             	mov    0x8(%ebp),%eax
80102081:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102085:	98                   	cwtl   
80102086:	8b 04 c5 c4 11 11 80 	mov    -0x7feeee3c(,%eax,8),%eax
8010208d:	8b 55 14             	mov    0x14(%ebp),%edx
80102090:	83 ec 04             	sub    $0x4,%esp
80102093:	52                   	push   %edx
80102094:	ff 75 0c             	pushl  0xc(%ebp)
80102097:	ff 75 08             	pushl  0x8(%ebp)
8010209a:	ff d0                	call   *%eax
8010209c:	83 c4 10             	add    $0x10,%esp
8010209f:	e9 17 01 00 00       	jmp    801021bb <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801020a4:	8b 45 08             	mov    0x8(%ebp),%eax
801020a7:	8b 40 18             	mov    0x18(%eax),%eax
801020aa:	39 45 10             	cmp    %eax,0x10(%ebp)
801020ad:	77 0d                	ja     801020bc <writei+0x87>
801020af:	8b 55 10             	mov    0x10(%ebp),%edx
801020b2:	8b 45 14             	mov    0x14(%ebp),%eax
801020b5:	01 d0                	add    %edx,%eax
801020b7:	39 45 10             	cmp    %eax,0x10(%ebp)
801020ba:	76 0a                	jbe    801020c6 <writei+0x91>
    return -1;
801020bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c1:	e9 f5 00 00 00       	jmp    801021bb <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020c6:	8b 55 10             	mov    0x10(%ebp),%edx
801020c9:	8b 45 14             	mov    0x14(%ebp),%eax
801020cc:	01 d0                	add    %edx,%eax
801020ce:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d3:	76 0a                	jbe    801020df <writei+0xaa>
    return -1;
801020d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020da:	e9 dc 00 00 00       	jmp    801021bb <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e6:	e9 99 00 00 00       	jmp    80102184 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020eb:	8b 45 10             	mov    0x10(%ebp),%eax
801020ee:	c1 e8 09             	shr    $0x9,%eax
801020f1:	83 ec 08             	sub    $0x8,%esp
801020f4:	50                   	push   %eax
801020f5:	ff 75 08             	pushl  0x8(%ebp)
801020f8:	e8 5d fb ff ff       	call   80101c5a <bmap>
801020fd:	83 c4 10             	add    $0x10,%esp
80102100:	89 c2                	mov    %eax,%edx
80102102:	8b 45 08             	mov    0x8(%ebp),%eax
80102105:	8b 00                	mov    (%eax),%eax
80102107:	83 ec 08             	sub    $0x8,%esp
8010210a:	52                   	push   %edx
8010210b:	50                   	push   %eax
8010210c:	e8 a5 e0 ff ff       	call   801001b6 <bread>
80102111:	83 c4 10             	add    $0x10,%esp
80102114:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102117:	8b 45 10             	mov    0x10(%ebp),%eax
8010211a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211f:	ba 00 02 00 00       	mov    $0x200,%edx
80102124:	29 c2                	sub    %eax,%edx
80102126:	8b 45 14             	mov    0x14(%ebp),%eax
80102129:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010212c:	39 c2                	cmp    %eax,%edx
8010212e:	0f 46 c2             	cmovbe %edx,%eax
80102131:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102137:	8d 50 18             	lea    0x18(%eax),%edx
8010213a:	8b 45 10             	mov    0x10(%ebp),%eax
8010213d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102142:	01 d0                	add    %edx,%eax
80102144:	83 ec 04             	sub    $0x4,%esp
80102147:	ff 75 ec             	pushl  -0x14(%ebp)
8010214a:	ff 75 0c             	pushl  0xc(%ebp)
8010214d:	50                   	push   %eax
8010214e:	e8 33 32 00 00       	call   80105386 <memmove>
80102153:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102156:	83 ec 0c             	sub    $0xc,%esp
80102159:	ff 75 f0             	pushl  -0x10(%ebp)
8010215c:	e8 2d 16 00 00       	call   8010378e <log_write>
80102161:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102164:	83 ec 0c             	sub    $0xc,%esp
80102167:	ff 75 f0             	pushl  -0x10(%ebp)
8010216a:	e8 bf e0 ff ff       	call   8010022e <brelse>
8010216f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 f4             	add    %eax,-0xc(%ebp)
80102178:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217b:	01 45 10             	add    %eax,0x10(%ebp)
8010217e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102181:	01 45 0c             	add    %eax,0xc(%ebp)
80102184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102187:	3b 45 14             	cmp    0x14(%ebp),%eax
8010218a:	0f 82 5b ff ff ff    	jb     801020eb <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102190:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102194:	74 22                	je     801021b8 <writei+0x183>
80102196:	8b 45 08             	mov    0x8(%ebp),%eax
80102199:	8b 40 18             	mov    0x18(%eax),%eax
8010219c:	39 45 10             	cmp    %eax,0x10(%ebp)
8010219f:	76 17                	jbe    801021b8 <writei+0x183>
    ip->size = off;
801021a1:	8b 45 08             	mov    0x8(%ebp),%eax
801021a4:	8b 55 10             	mov    0x10(%ebp),%edx
801021a7:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021aa:	83 ec 0c             	sub    $0xc,%esp
801021ad:	ff 75 08             	pushl  0x8(%ebp)
801021b0:	e8 e6 f5 ff ff       	call   8010179b <iupdate>
801021b5:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021bb:	c9                   	leave  
801021bc:	c3                   	ret    

801021bd <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021bd:	55                   	push   %ebp
801021be:	89 e5                	mov    %esp,%ebp
801021c0:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021c3:	83 ec 04             	sub    $0x4,%esp
801021c6:	6a 0e                	push   $0xe
801021c8:	ff 75 0c             	pushl  0xc(%ebp)
801021cb:	ff 75 08             	pushl  0x8(%ebp)
801021ce:	e8 49 32 00 00       	call   8010541c <strncmp>
801021d3:	83 c4 10             	add    $0x10,%esp
}
801021d6:	c9                   	leave  
801021d7:	c3                   	ret    

801021d8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d8:	55                   	push   %ebp
801021d9:	89 e5                	mov    %esp,%ebp
801021db:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021de:	8b 45 08             	mov    0x8(%ebp),%eax
801021e1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021e5:	66 83 f8 01          	cmp    $0x1,%ax
801021e9:	74 0d                	je     801021f8 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021eb:	83 ec 0c             	sub    $0xc,%esp
801021ee:	68 97 87 10 80       	push   $0x80108797
801021f3:	e8 6f e3 ff ff       	call   80100567 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021ff:	eb 7b                	jmp    8010227c <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102201:	6a 10                	push   $0x10
80102203:	ff 75 f4             	pushl  -0xc(%ebp)
80102206:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102209:	50                   	push   %eax
8010220a:	ff 75 08             	pushl  0x8(%ebp)
8010220d:	e8 cc fc ff ff       	call   80101ede <readi>
80102212:	83 c4 10             	add    $0x10,%esp
80102215:	83 f8 10             	cmp    $0x10,%eax
80102218:	74 0d                	je     80102227 <dirlookup+0x4f>
      panic("dirlink read");
8010221a:	83 ec 0c             	sub    $0xc,%esp
8010221d:	68 a9 87 10 80       	push   $0x801087a9
80102222:	e8 40 e3 ff ff       	call   80100567 <panic>
    if(de.inum == 0)
80102227:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010222b:	66 85 c0             	test   %ax,%ax
8010222e:	74 47                	je     80102277 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102230:	83 ec 08             	sub    $0x8,%esp
80102233:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102236:	83 c0 02             	add    $0x2,%eax
80102239:	50                   	push   %eax
8010223a:	ff 75 0c             	pushl  0xc(%ebp)
8010223d:	e8 7b ff ff ff       	call   801021bd <namecmp>
80102242:	83 c4 10             	add    $0x10,%esp
80102245:	85 c0                	test   %eax,%eax
80102247:	75 2f                	jne    80102278 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102249:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010224d:	74 08                	je     80102257 <dirlookup+0x7f>
        *poff = off;
8010224f:	8b 45 10             	mov    0x10(%ebp),%eax
80102252:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102255:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102257:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010225b:	0f b7 c0             	movzwl %ax,%eax
8010225e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102261:	8b 45 08             	mov    0x8(%ebp),%eax
80102264:	8b 00                	mov    (%eax),%eax
80102266:	83 ec 08             	sub    $0x8,%esp
80102269:	ff 75 f0             	pushl  -0x10(%ebp)
8010226c:	50                   	push   %eax
8010226d:	e8 ea f5 ff ff       	call   8010185c <iget>
80102272:	83 c4 10             	add    $0x10,%esp
80102275:	eb 19                	jmp    80102290 <dirlookup+0xb8>
      continue;
80102277:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102278:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010227c:	8b 45 08             	mov    0x8(%ebp),%eax
8010227f:	8b 40 18             	mov    0x18(%eax),%eax
80102282:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102285:	0f 82 76 ff ff ff    	jb     80102201 <dirlookup+0x29>
    }
  }

  return 0;
8010228b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102290:	c9                   	leave  
80102291:	c3                   	ret    

80102292 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102292:	55                   	push   %ebp
80102293:	89 e5                	mov    %esp,%ebp
80102295:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102298:	83 ec 04             	sub    $0x4,%esp
8010229b:	6a 00                	push   $0x0
8010229d:	ff 75 0c             	pushl  0xc(%ebp)
801022a0:	ff 75 08             	pushl  0x8(%ebp)
801022a3:	e8 30 ff ff ff       	call   801021d8 <dirlookup>
801022a8:	83 c4 10             	add    $0x10,%esp
801022ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022b2:	74 18                	je     801022cc <dirlink+0x3a>
    iput(ip);
801022b4:	83 ec 0c             	sub    $0xc,%esp
801022b7:	ff 75 f0             	pushl  -0x10(%ebp)
801022ba:	e8 86 f8 ff ff       	call   80101b45 <iput>
801022bf:	83 c4 10             	add    $0x10,%esp
    return -1;
801022c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c7:	e9 9c 00 00 00       	jmp    80102368 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d3:	eb 39                	jmp    8010230e <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d8:	6a 10                	push   $0x10
801022da:	50                   	push   %eax
801022db:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022de:	50                   	push   %eax
801022df:	ff 75 08             	pushl  0x8(%ebp)
801022e2:	e8 f7 fb ff ff       	call   80101ede <readi>
801022e7:	83 c4 10             	add    $0x10,%esp
801022ea:	83 f8 10             	cmp    $0x10,%eax
801022ed:	74 0d                	je     801022fc <dirlink+0x6a>
      panic("dirlink read");
801022ef:	83 ec 0c             	sub    $0xc,%esp
801022f2:	68 a9 87 10 80       	push   $0x801087a9
801022f7:	e8 6b e2 ff ff       	call   80100567 <panic>
    if(de.inum == 0)
801022fc:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102300:	66 85 c0             	test   %ax,%ax
80102303:	74 18                	je     8010231d <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102308:	83 c0 10             	add    $0x10,%eax
8010230b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010230e:	8b 45 08             	mov    0x8(%ebp),%eax
80102311:	8b 50 18             	mov    0x18(%eax),%edx
80102314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102317:	39 c2                	cmp    %eax,%edx
80102319:	77 ba                	ja     801022d5 <dirlink+0x43>
8010231b:	eb 01                	jmp    8010231e <dirlink+0x8c>
      break;
8010231d:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010231e:	83 ec 04             	sub    $0x4,%esp
80102321:	6a 0e                	push   $0xe
80102323:	ff 75 0c             	pushl  0xc(%ebp)
80102326:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102329:	83 c0 02             	add    $0x2,%eax
8010232c:	50                   	push   %eax
8010232d:	e8 40 31 00 00       	call   80105472 <strncpy>
80102332:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102335:	8b 45 10             	mov    0x10(%ebp),%eax
80102338:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010233c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233f:	6a 10                	push   $0x10
80102341:	50                   	push   %eax
80102342:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102345:	50                   	push   %eax
80102346:	ff 75 08             	pushl  0x8(%ebp)
80102349:	e8 e7 fc ff ff       	call   80102035 <writei>
8010234e:	83 c4 10             	add    $0x10,%esp
80102351:	83 f8 10             	cmp    $0x10,%eax
80102354:	74 0d                	je     80102363 <dirlink+0xd1>
    panic("dirlink");
80102356:	83 ec 0c             	sub    $0xc,%esp
80102359:	68 b6 87 10 80       	push   $0x801087b6
8010235e:	e8 04 e2 ff ff       	call   80100567 <panic>
  
  return 0;
80102363:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102368:	c9                   	leave  
80102369:	c3                   	ret    

8010236a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010236a:	55                   	push   %ebp
8010236b:	89 e5                	mov    %esp,%ebp
8010236d:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102370:	eb 04                	jmp    80102376 <skipelem+0xc>
    path++;
80102372:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102376:	8b 45 08             	mov    0x8(%ebp),%eax
80102379:	0f b6 00             	movzbl (%eax),%eax
8010237c:	3c 2f                	cmp    $0x2f,%al
8010237e:	74 f2                	je     80102372 <skipelem+0x8>
  if(*path == 0)
80102380:	8b 45 08             	mov    0x8(%ebp),%eax
80102383:	0f b6 00             	movzbl (%eax),%eax
80102386:	84 c0                	test   %al,%al
80102388:	75 07                	jne    80102391 <skipelem+0x27>
    return 0;
8010238a:	b8 00 00 00 00       	mov    $0x0,%eax
8010238f:	eb 77                	jmp    80102408 <skipelem+0x9e>
  s = path;
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102397:	eb 04                	jmp    8010239d <skipelem+0x33>
    path++;
80102399:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010239d:	8b 45 08             	mov    0x8(%ebp),%eax
801023a0:	0f b6 00             	movzbl (%eax),%eax
801023a3:	3c 2f                	cmp    $0x2f,%al
801023a5:	74 0a                	je     801023b1 <skipelem+0x47>
801023a7:	8b 45 08             	mov    0x8(%ebp),%eax
801023aa:	0f b6 00             	movzbl (%eax),%eax
801023ad:	84 c0                	test   %al,%al
801023af:	75 e8                	jne    80102399 <skipelem+0x2f>
  len = path - s;
801023b1:	8b 45 08             	mov    0x8(%ebp),%eax
801023b4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ba:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023be:	7e 15                	jle    801023d5 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023c0:	83 ec 04             	sub    $0x4,%esp
801023c3:	6a 0e                	push   $0xe
801023c5:	ff 75 f4             	pushl  -0xc(%ebp)
801023c8:	ff 75 0c             	pushl  0xc(%ebp)
801023cb:	e8 b6 2f 00 00       	call   80105386 <memmove>
801023d0:	83 c4 10             	add    $0x10,%esp
801023d3:	eb 26                	jmp    801023fb <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d8:	83 ec 04             	sub    $0x4,%esp
801023db:	50                   	push   %eax
801023dc:	ff 75 f4             	pushl  -0xc(%ebp)
801023df:	ff 75 0c             	pushl  0xc(%ebp)
801023e2:	e8 9f 2f 00 00       	call   80105386 <memmove>
801023e7:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801023f0:	01 d0                	add    %edx,%eax
801023f2:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f5:	eb 04                	jmp    801023fb <skipelem+0x91>
    path++;
801023f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023fb:	8b 45 08             	mov    0x8(%ebp),%eax
801023fe:	0f b6 00             	movzbl (%eax),%eax
80102401:	3c 2f                	cmp    $0x2f,%al
80102403:	74 f2                	je     801023f7 <skipelem+0x8d>
  return path;
80102405:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102408:	c9                   	leave  
80102409:	c3                   	ret    

8010240a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010240a:	55                   	push   %ebp
8010240b:	89 e5                	mov    %esp,%ebp
8010240d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102410:	8b 45 08             	mov    0x8(%ebp),%eax
80102413:	0f b6 00             	movzbl (%eax),%eax
80102416:	3c 2f                	cmp    $0x2f,%al
80102418:	75 17                	jne    80102431 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010241a:	83 ec 08             	sub    $0x8,%esp
8010241d:	6a 01                	push   $0x1
8010241f:	6a 01                	push   $0x1
80102421:	e8 36 f4 ff ff       	call   8010185c <iget>
80102426:	83 c4 10             	add    $0x10,%esp
80102429:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010242c:	e9 bb 00 00 00       	jmp    801024ec <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102431:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102437:	8b 40 68             	mov    0x68(%eax),%eax
8010243a:	83 ec 0c             	sub    $0xc,%esp
8010243d:	50                   	push   %eax
8010243e:	e8 f8 f4 ff ff       	call   8010193b <idup>
80102443:	83 c4 10             	add    $0x10,%esp
80102446:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102449:	e9 9e 00 00 00       	jmp    801024ec <namex+0xe2>
    ilock(ip);
8010244e:	83 ec 0c             	sub    $0xc,%esp
80102451:	ff 75 f4             	pushl  -0xc(%ebp)
80102454:	e8 1c f5 ff ff       	call   80101975 <ilock>
80102459:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010245c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102463:	66 83 f8 01          	cmp    $0x1,%ax
80102467:	74 18                	je     80102481 <namex+0x77>
      iunlockput(ip);
80102469:	83 ec 0c             	sub    $0xc,%esp
8010246c:	ff 75 f4             	pushl  -0xc(%ebp)
8010246f:	e8 c1 f7 ff ff       	call   80101c35 <iunlockput>
80102474:	83 c4 10             	add    $0x10,%esp
      return 0;
80102477:	b8 00 00 00 00       	mov    $0x0,%eax
8010247c:	e9 a7 00 00 00       	jmp    80102528 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102481:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102485:	74 20                	je     801024a7 <namex+0x9d>
80102487:	8b 45 08             	mov    0x8(%ebp),%eax
8010248a:	0f b6 00             	movzbl (%eax),%eax
8010248d:	84 c0                	test   %al,%al
8010248f:	75 16                	jne    801024a7 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102491:	83 ec 0c             	sub    $0xc,%esp
80102494:	ff 75 f4             	pushl  -0xc(%ebp)
80102497:	e8 37 f6 ff ff       	call   80101ad3 <iunlock>
8010249c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a2:	e9 81 00 00 00       	jmp    80102528 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a7:	83 ec 04             	sub    $0x4,%esp
801024aa:	6a 00                	push   $0x0
801024ac:	ff 75 10             	pushl  0x10(%ebp)
801024af:	ff 75 f4             	pushl  -0xc(%ebp)
801024b2:	e8 21 fd ff ff       	call   801021d8 <dirlookup>
801024b7:	83 c4 10             	add    $0x10,%esp
801024ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c1:	75 15                	jne    801024d8 <namex+0xce>
      iunlockput(ip);
801024c3:	83 ec 0c             	sub    $0xc,%esp
801024c6:	ff 75 f4             	pushl  -0xc(%ebp)
801024c9:	e8 67 f7 ff ff       	call   80101c35 <iunlockput>
801024ce:	83 c4 10             	add    $0x10,%esp
      return 0;
801024d1:	b8 00 00 00 00       	mov    $0x0,%eax
801024d6:	eb 50                	jmp    80102528 <namex+0x11e>
    }
    iunlockput(ip);
801024d8:	83 ec 0c             	sub    $0xc,%esp
801024db:	ff 75 f4             	pushl  -0xc(%ebp)
801024de:	e8 52 f7 ff ff       	call   80101c35 <iunlockput>
801024e3:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024ec:	83 ec 08             	sub    $0x8,%esp
801024ef:	ff 75 10             	pushl  0x10(%ebp)
801024f2:	ff 75 08             	pushl  0x8(%ebp)
801024f5:	e8 70 fe ff ff       	call   8010236a <skipelem>
801024fa:	83 c4 10             	add    $0x10,%esp
801024fd:	89 45 08             	mov    %eax,0x8(%ebp)
80102500:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102504:	0f 85 44 ff ff ff    	jne    8010244e <namex+0x44>
  }
  if(nameiparent){
8010250a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250e:	74 15                	je     80102525 <namex+0x11b>
    iput(ip);
80102510:	83 ec 0c             	sub    $0xc,%esp
80102513:	ff 75 f4             	pushl  -0xc(%ebp)
80102516:	e8 2a f6 ff ff       	call   80101b45 <iput>
8010251b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010251e:	b8 00 00 00 00       	mov    $0x0,%eax
80102523:	eb 03                	jmp    80102528 <namex+0x11e>
  }
  return ip;
80102525:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102528:	c9                   	leave  
80102529:	c3                   	ret    

8010252a <namei>:

struct inode*
namei(char *path)
{
8010252a:	55                   	push   %ebp
8010252b:	89 e5                	mov    %esp,%ebp
8010252d:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102530:	83 ec 04             	sub    $0x4,%esp
80102533:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102536:	50                   	push   %eax
80102537:	6a 00                	push   $0x0
80102539:	ff 75 08             	pushl  0x8(%ebp)
8010253c:	e8 c9 fe ff ff       	call   8010240a <namex>
80102541:	83 c4 10             	add    $0x10,%esp
}
80102544:	c9                   	leave  
80102545:	c3                   	ret    

80102546 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102546:	55                   	push   %ebp
80102547:	89 e5                	mov    %esp,%ebp
80102549:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010254c:	83 ec 04             	sub    $0x4,%esp
8010254f:	ff 75 0c             	pushl  0xc(%ebp)
80102552:	6a 01                	push   $0x1
80102554:	ff 75 08             	pushl  0x8(%ebp)
80102557:	e8 ae fe ff ff       	call   8010240a <namex>
8010255c:	83 c4 10             	add    $0x10,%esp
}
8010255f:	c9                   	leave  
80102560:	c3                   	ret    

80102561 <inb>:
{
80102561:	55                   	push   %ebp
80102562:	89 e5                	mov    %esp,%ebp
80102564:	83 ec 14             	sub    $0x14,%esp
80102567:	8b 45 08             	mov    0x8(%ebp),%eax
8010256a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010256e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102572:	89 c2                	mov    %eax,%edx
80102574:	ec                   	in     (%dx),%al
80102575:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102578:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010257c:	c9                   	leave  
8010257d:	c3                   	ret    

8010257e <insl>:
{
8010257e:	55                   	push   %ebp
8010257f:	89 e5                	mov    %esp,%ebp
80102581:	57                   	push   %edi
80102582:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102583:	8b 55 08             	mov    0x8(%ebp),%edx
80102586:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102589:	8b 45 10             	mov    0x10(%ebp),%eax
8010258c:	89 cb                	mov    %ecx,%ebx
8010258e:	89 df                	mov    %ebx,%edi
80102590:	89 c1                	mov    %eax,%ecx
80102592:	fc                   	cld    
80102593:	f3 6d                	rep insl (%dx),%es:(%edi)
80102595:	89 c8                	mov    %ecx,%eax
80102597:	89 fb                	mov    %edi,%ebx
80102599:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010259c:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010259f:	90                   	nop
801025a0:	5b                   	pop    %ebx
801025a1:	5f                   	pop    %edi
801025a2:	5d                   	pop    %ebp
801025a3:	c3                   	ret    

801025a4 <outb>:
{
801025a4:	55                   	push   %ebp
801025a5:	89 e5                	mov    %esp,%ebp
801025a7:	83 ec 08             	sub    $0x8,%esp
801025aa:	8b 45 08             	mov    0x8(%ebp),%eax
801025ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801025b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025b4:	89 d0                	mov    %edx,%eax
801025b6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025bd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025c1:	ee                   	out    %al,(%dx)
}
801025c2:	90                   	nop
801025c3:	c9                   	leave  
801025c4:	c3                   	ret    

801025c5 <outsl>:
{
801025c5:	55                   	push   %ebp
801025c6:	89 e5                	mov    %esp,%ebp
801025c8:	56                   	push   %esi
801025c9:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025ca:	8b 55 08             	mov    0x8(%ebp),%edx
801025cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025d0:	8b 45 10             	mov    0x10(%ebp),%eax
801025d3:	89 cb                	mov    %ecx,%ebx
801025d5:	89 de                	mov    %ebx,%esi
801025d7:	89 c1                	mov    %eax,%ecx
801025d9:	fc                   	cld    
801025da:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025dc:	89 c8                	mov    %ecx,%eax
801025de:	89 f3                	mov    %esi,%ebx
801025e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025e3:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025e6:	90                   	nop
801025e7:	5b                   	pop    %ebx
801025e8:	5e                   	pop    %esi
801025e9:	5d                   	pop    %ebp
801025ea:	c3                   	ret    

801025eb <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025f1:	90                   	nop
801025f2:	68 f7 01 00 00       	push   $0x1f7
801025f7:	e8 65 ff ff ff       	call   80102561 <inb>
801025fc:	83 c4 04             	add    $0x4,%esp
801025ff:	0f b6 c0             	movzbl %al,%eax
80102602:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102605:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102608:	25 c0 00 00 00       	and    $0xc0,%eax
8010260d:	83 f8 40             	cmp    $0x40,%eax
80102610:	75 e0                	jne    801025f2 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102612:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102616:	74 11                	je     80102629 <idewait+0x3e>
80102618:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010261b:	83 e0 21             	and    $0x21,%eax
8010261e:	85 c0                	test   %eax,%eax
80102620:	74 07                	je     80102629 <idewait+0x3e>
    return -1;
80102622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102627:	eb 05                	jmp    8010262e <idewait+0x43>
  return 0;
80102629:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262e:	c9                   	leave  
8010262f:	c3                   	ret    

80102630 <ideinit>:

void
ideinit(void)
{
80102630:	55                   	push   %ebp
80102631:	89 e5                	mov    %esp,%ebp
80102633:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102636:	83 ec 08             	sub    $0x8,%esp
80102639:	68 be 87 10 80       	push   $0x801087be
8010263e:	68 00 b6 10 80       	push   $0x8010b600
80102643:	e8 fa 29 00 00       	call   80105042 <initlock>
80102648:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
8010264b:	83 ec 0c             	sub    $0xc,%esp
8010264e:	6a 0e                	push   $0xe
80102650:	e8 db 18 00 00       	call   80103f30 <picenable>
80102655:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102658:	a1 40 29 11 80       	mov    0x80112940,%eax
8010265d:	83 e8 01             	sub    $0x1,%eax
80102660:	83 ec 08             	sub    $0x8,%esp
80102663:	50                   	push   %eax
80102664:	6a 0e                	push   $0xe
80102666:	e8 73 04 00 00       	call   80102ade <ioapicenable>
8010266b:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010266e:	83 ec 0c             	sub    $0xc,%esp
80102671:	6a 00                	push   $0x0
80102673:	e8 73 ff ff ff       	call   801025eb <idewait>
80102678:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010267b:	83 ec 08             	sub    $0x8,%esp
8010267e:	68 f0 00 00 00       	push   $0xf0
80102683:	68 f6 01 00 00       	push   $0x1f6
80102688:	e8 17 ff ff ff       	call   801025a4 <outb>
8010268d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102690:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102697:	eb 24                	jmp    801026bd <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102699:	83 ec 0c             	sub    $0xc,%esp
8010269c:	68 f7 01 00 00       	push   $0x1f7
801026a1:	e8 bb fe ff ff       	call   80102561 <inb>
801026a6:	83 c4 10             	add    $0x10,%esp
801026a9:	84 c0                	test   %al,%al
801026ab:	74 0c                	je     801026b9 <ideinit+0x89>
      havedisk1 = 1;
801026ad:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801026b4:	00 00 00 
      break;
801026b7:	eb 0d                	jmp    801026c6 <ideinit+0x96>
  for(i=0; i<1000; i++){
801026b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026bd:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026c4:	7e d3                	jle    80102699 <ideinit+0x69>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026c6:	83 ec 08             	sub    $0x8,%esp
801026c9:	68 e0 00 00 00       	push   $0xe0
801026ce:	68 f6 01 00 00       	push   $0x1f6
801026d3:	e8 cc fe ff ff       	call   801025a4 <outb>
801026d8:	83 c4 10             	add    $0x10,%esp
}
801026db:	90                   	nop
801026dc:	c9                   	leave  
801026dd:	c3                   	ret    

801026de <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026de:	55                   	push   %ebp
801026df:	89 e5                	mov    %esp,%ebp
801026e1:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026e8:	75 0d                	jne    801026f7 <idestart+0x19>
    panic("idestart");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 c2 87 10 80       	push   $0x801087c2
801026f2:	e8 70 de ff ff       	call   80100567 <panic>
  if(b->blockno >= FSSIZE)
801026f7:	8b 45 08             	mov    0x8(%ebp),%eax
801026fa:	8b 40 08             	mov    0x8(%eax),%eax
801026fd:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102702:	76 0d                	jbe    80102711 <idestart+0x33>
    panic("incorrect blockno");
80102704:	83 ec 0c             	sub    $0xc,%esp
80102707:	68 cb 87 10 80       	push   $0x801087cb
8010270c:	e8 56 de ff ff       	call   80100567 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102711:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102718:	8b 45 08             	mov    0x8(%ebp),%eax
8010271b:	8b 50 08             	mov    0x8(%eax),%edx
8010271e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102721:	0f af c2             	imul   %edx,%eax
80102724:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102727:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010272b:	7e 0d                	jle    8010273a <idestart+0x5c>
8010272d:	83 ec 0c             	sub    $0xc,%esp
80102730:	68 c2 87 10 80       	push   $0x801087c2
80102735:	e8 2d de ff ff       	call   80100567 <panic>
  
  idewait(0);
8010273a:	83 ec 0c             	sub    $0xc,%esp
8010273d:	6a 00                	push   $0x0
8010273f:	e8 a7 fe ff ff       	call   801025eb <idewait>
80102744:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102747:	83 ec 08             	sub    $0x8,%esp
8010274a:	6a 00                	push   $0x0
8010274c:	68 f6 03 00 00       	push   $0x3f6
80102751:	e8 4e fe ff ff       	call   801025a4 <outb>
80102756:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010275c:	0f b6 c0             	movzbl %al,%eax
8010275f:	83 ec 08             	sub    $0x8,%esp
80102762:	50                   	push   %eax
80102763:	68 f2 01 00 00       	push   $0x1f2
80102768:	e8 37 fe ff ff       	call   801025a4 <outb>
8010276d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102773:	0f b6 c0             	movzbl %al,%eax
80102776:	83 ec 08             	sub    $0x8,%esp
80102779:	50                   	push   %eax
8010277a:	68 f3 01 00 00       	push   $0x1f3
8010277f:	e8 20 fe ff ff       	call   801025a4 <outb>
80102784:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102787:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010278a:	c1 f8 08             	sar    $0x8,%eax
8010278d:	0f b6 c0             	movzbl %al,%eax
80102790:	83 ec 08             	sub    $0x8,%esp
80102793:	50                   	push   %eax
80102794:	68 f4 01 00 00       	push   $0x1f4
80102799:	e8 06 fe ff ff       	call   801025a4 <outb>
8010279e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a4:	c1 f8 10             	sar    $0x10,%eax
801027a7:	0f b6 c0             	movzbl %al,%eax
801027aa:	83 ec 08             	sub    $0x8,%esp
801027ad:	50                   	push   %eax
801027ae:	68 f5 01 00 00       	push   $0x1f5
801027b3:	e8 ec fd ff ff       	call   801025a4 <outb>
801027b8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027bb:	8b 45 08             	mov    0x8(%ebp),%eax
801027be:	8b 40 04             	mov    0x4(%eax),%eax
801027c1:	c1 e0 04             	shl    $0x4,%eax
801027c4:	83 e0 10             	and    $0x10,%eax
801027c7:	89 c2                	mov    %eax,%edx
801027c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027cc:	c1 f8 18             	sar    $0x18,%eax
801027cf:	83 e0 0f             	and    $0xf,%eax
801027d2:	09 d0                	or     %edx,%eax
801027d4:	83 c8 e0             	or     $0xffffffe0,%eax
801027d7:	0f b6 c0             	movzbl %al,%eax
801027da:	83 ec 08             	sub    $0x8,%esp
801027dd:	50                   	push   %eax
801027de:	68 f6 01 00 00       	push   $0x1f6
801027e3:	e8 bc fd ff ff       	call   801025a4 <outb>
801027e8:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027eb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ee:	8b 00                	mov    (%eax),%eax
801027f0:	83 e0 04             	and    $0x4,%eax
801027f3:	85 c0                	test   %eax,%eax
801027f5:	74 30                	je     80102827 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
801027f7:	83 ec 08             	sub    $0x8,%esp
801027fa:	6a 30                	push   $0x30
801027fc:	68 f7 01 00 00       	push   $0x1f7
80102801:	e8 9e fd ff ff       	call   801025a4 <outb>
80102806:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102809:	8b 45 08             	mov    0x8(%ebp),%eax
8010280c:	83 c0 18             	add    $0x18,%eax
8010280f:	83 ec 04             	sub    $0x4,%esp
80102812:	68 80 00 00 00       	push   $0x80
80102817:	50                   	push   %eax
80102818:	68 f0 01 00 00       	push   $0x1f0
8010281d:	e8 a3 fd ff ff       	call   801025c5 <outsl>
80102822:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102825:	eb 12                	jmp    80102839 <idestart+0x15b>
    outb(0x1f7, IDE_CMD_READ);
80102827:	83 ec 08             	sub    $0x8,%esp
8010282a:	6a 20                	push   $0x20
8010282c:	68 f7 01 00 00       	push   $0x1f7
80102831:	e8 6e fd ff ff       	call   801025a4 <outb>
80102836:	83 c4 10             	add    $0x10,%esp
}
80102839:	90                   	nop
8010283a:	c9                   	leave  
8010283b:	c3                   	ret    

8010283c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010283c:	55                   	push   %ebp
8010283d:	89 e5                	mov    %esp,%ebp
8010283f:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102842:	83 ec 0c             	sub    $0xc,%esp
80102845:	68 00 b6 10 80       	push   $0x8010b600
8010284a:	e8 15 28 00 00       	call   80105064 <acquire>
8010284f:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102852:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102857:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010285a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010285e:	75 15                	jne    80102875 <ideintr+0x39>
    release(&idelock);
80102860:	83 ec 0c             	sub    $0xc,%esp
80102863:	68 00 b6 10 80       	push   $0x8010b600
80102868:	e8 5e 28 00 00       	call   801050cb <release>
8010286d:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102870:	e9 9a 00 00 00       	jmp    8010290f <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102878:	8b 40 14             	mov    0x14(%eax),%eax
8010287b:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102883:	8b 00                	mov    (%eax),%eax
80102885:	83 e0 04             	and    $0x4,%eax
80102888:	85 c0                	test   %eax,%eax
8010288a:	75 2d                	jne    801028b9 <ideintr+0x7d>
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	6a 01                	push   $0x1
80102891:	e8 55 fd ff ff       	call   801025eb <idewait>
80102896:	83 c4 10             	add    $0x10,%esp
80102899:	85 c0                	test   %eax,%eax
8010289b:	78 1c                	js     801028b9 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010289d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a0:	83 c0 18             	add    $0x18,%eax
801028a3:	83 ec 04             	sub    $0x4,%esp
801028a6:	68 80 00 00 00       	push   $0x80
801028ab:	50                   	push   %eax
801028ac:	68 f0 01 00 00       	push   $0x1f0
801028b1:	e8 c8 fc ff ff       	call   8010257e <insl>
801028b6:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bc:	8b 00                	mov    (%eax),%eax
801028be:	83 c8 02             	or     $0x2,%eax
801028c1:	89 c2                	mov    %eax,%edx
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cb:	8b 00                	mov    (%eax),%eax
801028cd:	83 e0 fb             	and    $0xfffffffb,%eax
801028d0:	89 c2                	mov    %eax,%edx
801028d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d5:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028d7:	83 ec 0c             	sub    $0xc,%esp
801028da:	ff 75 f4             	pushl  -0xc(%ebp)
801028dd:	e8 74 25 00 00       	call   80104e56 <wakeup>
801028e2:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028e5:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028ea:	85 c0                	test   %eax,%eax
801028ec:	74 11                	je     801028ff <ideintr+0xc3>
    idestart(idequeue);
801028ee:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028f3:	83 ec 0c             	sub    $0xc,%esp
801028f6:	50                   	push   %eax
801028f7:	e8 e2 fd ff ff       	call   801026de <idestart>
801028fc:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801028ff:	83 ec 0c             	sub    $0xc,%esp
80102902:	68 00 b6 10 80       	push   $0x8010b600
80102907:	e8 bf 27 00 00       	call   801050cb <release>
8010290c:	83 c4 10             	add    $0x10,%esp
}
8010290f:	c9                   	leave  
80102910:	c3                   	ret    

80102911 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102911:	55                   	push   %ebp
80102912:	89 e5                	mov    %esp,%ebp
80102914:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102917:	8b 45 08             	mov    0x8(%ebp),%eax
8010291a:	8b 00                	mov    (%eax),%eax
8010291c:	83 e0 01             	and    $0x1,%eax
8010291f:	85 c0                	test   %eax,%eax
80102921:	75 0d                	jne    80102930 <iderw+0x1f>
    panic("iderw: buf not busy");
80102923:	83 ec 0c             	sub    $0xc,%esp
80102926:	68 dd 87 10 80       	push   $0x801087dd
8010292b:	e8 37 dc ff ff       	call   80100567 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102930:	8b 45 08             	mov    0x8(%ebp),%eax
80102933:	8b 00                	mov    (%eax),%eax
80102935:	83 e0 06             	and    $0x6,%eax
80102938:	83 f8 02             	cmp    $0x2,%eax
8010293b:	75 0d                	jne    8010294a <iderw+0x39>
    panic("iderw: nothing to do");
8010293d:	83 ec 0c             	sub    $0xc,%esp
80102940:	68 f1 87 10 80       	push   $0x801087f1
80102945:	e8 1d dc ff ff       	call   80100567 <panic>
  if(b->dev != 0 && !havedisk1)
8010294a:	8b 45 08             	mov    0x8(%ebp),%eax
8010294d:	8b 40 04             	mov    0x4(%eax),%eax
80102950:	85 c0                	test   %eax,%eax
80102952:	74 16                	je     8010296a <iderw+0x59>
80102954:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102959:	85 c0                	test   %eax,%eax
8010295b:	75 0d                	jne    8010296a <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010295d:	83 ec 0c             	sub    $0xc,%esp
80102960:	68 06 88 10 80       	push   $0x80108806
80102965:	e8 fd db ff ff       	call   80100567 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010296a:	83 ec 0c             	sub    $0xc,%esp
8010296d:	68 00 b6 10 80       	push   $0x8010b600
80102972:	e8 ed 26 00 00       	call   80105064 <acquire>
80102977:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010297a:	8b 45 08             	mov    0x8(%ebp),%eax
8010297d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102984:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
8010298b:	eb 0b                	jmp    80102998 <iderw+0x87>
8010298d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102990:	8b 00                	mov    (%eax),%eax
80102992:	83 c0 14             	add    $0x14,%eax
80102995:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299b:	8b 00                	mov    (%eax),%eax
8010299d:	85 c0                	test   %eax,%eax
8010299f:	75 ec                	jne    8010298d <iderw+0x7c>
    ;
  *pp = b;
801029a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a4:	8b 55 08             	mov    0x8(%ebp),%edx
801029a7:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029a9:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801029ae:	39 45 08             	cmp    %eax,0x8(%ebp)
801029b1:	75 23                	jne    801029d6 <iderw+0xc5>
    idestart(b);
801029b3:	83 ec 0c             	sub    $0xc,%esp
801029b6:	ff 75 08             	pushl  0x8(%ebp)
801029b9:	e8 20 fd ff ff       	call   801026de <idestart>
801029be:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029c1:	eb 13                	jmp    801029d6 <iderw+0xc5>
    sleep(b, &idelock);
801029c3:	83 ec 08             	sub    $0x8,%esp
801029c6:	68 00 b6 10 80       	push   $0x8010b600
801029cb:	ff 75 08             	pushl  0x8(%ebp)
801029ce:	e8 98 23 00 00       	call   80104d6b <sleep>
801029d3:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029d6:	8b 45 08             	mov    0x8(%ebp),%eax
801029d9:	8b 00                	mov    (%eax),%eax
801029db:	83 e0 06             	and    $0x6,%eax
801029de:	83 f8 02             	cmp    $0x2,%eax
801029e1:	75 e0                	jne    801029c3 <iderw+0xb2>
  }

  release(&idelock);
801029e3:	83 ec 0c             	sub    $0xc,%esp
801029e6:	68 00 b6 10 80       	push   $0x8010b600
801029eb:	e8 db 26 00 00       	call   801050cb <release>
801029f0:	83 c4 10             	add    $0x10,%esp
}
801029f3:	90                   	nop
801029f4:	c9                   	leave  
801029f5:	c3                   	ret    

801029f6 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029f6:	55                   	push   %ebp
801029f7:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029f9:	a1 14 22 11 80       	mov    0x80112214,%eax
801029fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102a01:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a03:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a08:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a0b:	5d                   	pop    %ebp
80102a0c:	c3                   	ret    

80102a0d <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a0d:	55                   	push   %ebp
80102a0e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a10:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a15:	8b 55 08             	mov    0x8(%ebp),%edx
80102a18:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a1a:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a22:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a25:	90                   	nop
80102a26:	5d                   	pop    %ebp
80102a27:	c3                   	ret    

80102a28 <ioapicinit>:

void
ioapicinit(void)
{
80102a28:	55                   	push   %ebp
80102a29:	89 e5                	mov    %esp,%ebp
80102a2b:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a2e:	a1 44 23 11 80       	mov    0x80112344,%eax
80102a33:	85 c0                	test   %eax,%eax
80102a35:	0f 84 a0 00 00 00    	je     80102adb <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a3b:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
80102a42:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a45:	6a 01                	push   $0x1
80102a47:	e8 aa ff ff ff       	call   801029f6 <ioapicread>
80102a4c:	83 c4 04             	add    $0x4,%esp
80102a4f:	c1 e8 10             	shr    $0x10,%eax
80102a52:	25 ff 00 00 00       	and    $0xff,%eax
80102a57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a5a:	6a 00                	push   $0x0
80102a5c:	e8 95 ff ff ff       	call   801029f6 <ioapicread>
80102a61:	83 c4 04             	add    $0x4,%esp
80102a64:	c1 e8 18             	shr    $0x18,%eax
80102a67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a6a:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
80102a71:	0f b6 c0             	movzbl %al,%eax
80102a74:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102a77:	74 10                	je     80102a89 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a79:	83 ec 0c             	sub    $0xc,%esp
80102a7c:	68 24 88 10 80       	push   $0x80108824
80102a81:	e8 3e d9 ff ff       	call   801003c4 <cprintf>
80102a86:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a90:	eb 3f                	jmp    80102ad1 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a95:	83 c0 20             	add    $0x20,%eax
80102a98:	0d 00 00 01 00       	or     $0x10000,%eax
80102a9d:	89 c2                	mov    %eax,%edx
80102a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa2:	83 c0 08             	add    $0x8,%eax
80102aa5:	01 c0                	add    %eax,%eax
80102aa7:	83 ec 08             	sub    $0x8,%esp
80102aaa:	52                   	push   %edx
80102aab:	50                   	push   %eax
80102aac:	e8 5c ff ff ff       	call   80102a0d <ioapicwrite>
80102ab1:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab7:	83 c0 08             	add    $0x8,%eax
80102aba:	01 c0                	add    %eax,%eax
80102abc:	83 c0 01             	add    $0x1,%eax
80102abf:	83 ec 08             	sub    $0x8,%esp
80102ac2:	6a 00                	push   $0x0
80102ac4:	50                   	push   %eax
80102ac5:	e8 43 ff ff ff       	call   80102a0d <ioapicwrite>
80102aca:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102acd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ad7:	7e b9                	jle    80102a92 <ioapicinit+0x6a>
80102ad9:	eb 01                	jmp    80102adc <ioapicinit+0xb4>
    return;
80102adb:	90                   	nop
  }
}
80102adc:	c9                   	leave  
80102add:	c3                   	ret    

80102ade <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ade:	55                   	push   %ebp
80102adf:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102ae1:	a1 44 23 11 80       	mov    0x80112344,%eax
80102ae6:	85 c0                	test   %eax,%eax
80102ae8:	74 39                	je     80102b23 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102aea:	8b 45 08             	mov    0x8(%ebp),%eax
80102aed:	83 c0 20             	add    $0x20,%eax
80102af0:	89 c2                	mov    %eax,%edx
80102af2:	8b 45 08             	mov    0x8(%ebp),%eax
80102af5:	83 c0 08             	add    $0x8,%eax
80102af8:	01 c0                	add    %eax,%eax
80102afa:	52                   	push   %edx
80102afb:	50                   	push   %eax
80102afc:	e8 0c ff ff ff       	call   80102a0d <ioapicwrite>
80102b01:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b07:	c1 e0 18             	shl    $0x18,%eax
80102b0a:	89 c2                	mov    %eax,%edx
80102b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0f:	83 c0 08             	add    $0x8,%eax
80102b12:	01 c0                	add    %eax,%eax
80102b14:	83 c0 01             	add    $0x1,%eax
80102b17:	52                   	push   %edx
80102b18:	50                   	push   %eax
80102b19:	e8 ef fe ff ff       	call   80102a0d <ioapicwrite>
80102b1e:	83 c4 08             	add    $0x8,%esp
80102b21:	eb 01                	jmp    80102b24 <ioapicenable+0x46>
    return;
80102b23:	90                   	nop
}
80102b24:	c9                   	leave  
80102b25:	c3                   	ret    

80102b26 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b26:	55                   	push   %ebp
80102b27:	89 e5                	mov    %esp,%ebp
80102b29:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2c:	05 00 00 00 80       	add    $0x80000000,%eax
80102b31:	5d                   	pop    %ebp
80102b32:	c3                   	ret    

80102b33 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b33:	55                   	push   %ebp
80102b34:	89 e5                	mov    %esp,%ebp
80102b36:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b39:	83 ec 08             	sub    $0x8,%esp
80102b3c:	68 56 88 10 80       	push   $0x80108856
80102b41:	68 20 22 11 80       	push   $0x80112220
80102b46:	e8 f7 24 00 00       	call   80105042 <initlock>
80102b4b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b4e:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
80102b55:	00 00 00 
  freerange(vstart, vend);
80102b58:	83 ec 08             	sub    $0x8,%esp
80102b5b:	ff 75 0c             	pushl  0xc(%ebp)
80102b5e:	ff 75 08             	pushl  0x8(%ebp)
80102b61:	e8 2a 00 00 00       	call   80102b90 <freerange>
80102b66:	83 c4 10             	add    $0x10,%esp
}
80102b69:	90                   	nop
80102b6a:	c9                   	leave  
80102b6b:	c3                   	ret    

80102b6c <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b6c:	55                   	push   %ebp
80102b6d:	89 e5                	mov    %esp,%ebp
80102b6f:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b72:	83 ec 08             	sub    $0x8,%esp
80102b75:	ff 75 0c             	pushl  0xc(%ebp)
80102b78:	ff 75 08             	pushl  0x8(%ebp)
80102b7b:	e8 10 00 00 00       	call   80102b90 <freerange>
80102b80:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b83:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102b8a:	00 00 00 
}
80102b8d:	90                   	nop
80102b8e:	c9                   	leave  
80102b8f:	c3                   	ret    

80102b90 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b90:	55                   	push   %ebp
80102b91:	89 e5                	mov    %esp,%ebp
80102b93:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b96:	8b 45 08             	mov    0x8(%ebp),%eax
80102b99:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ba6:	eb 15                	jmp    80102bbd <freerange+0x2d>
    kfree(p);
80102ba8:	83 ec 0c             	sub    $0xc,%esp
80102bab:	ff 75 f4             	pushl  -0xc(%ebp)
80102bae:	e8 1a 00 00 00       	call   80102bcd <kfree>
80102bb3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc0:	05 00 10 00 00       	add    $0x1000,%eax
80102bc5:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bc8:	73 de                	jae    80102ba8 <freerange+0x18>
}
80102bca:	90                   	nop
80102bcb:	c9                   	leave  
80102bcc:	c3                   	ret    

80102bcd <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bcd:	55                   	push   %ebp
80102bce:	89 e5                	mov    %esp,%ebp
80102bd0:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd6:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bdb:	85 c0                	test   %eax,%eax
80102bdd:	75 1b                	jne    80102bfa <kfree+0x2d>
80102bdf:	81 7d 08 3c 51 11 80 	cmpl   $0x8011513c,0x8(%ebp)
80102be6:	72 12                	jb     80102bfa <kfree+0x2d>
80102be8:	ff 75 08             	pushl  0x8(%ebp)
80102beb:	e8 36 ff ff ff       	call   80102b26 <v2p>
80102bf0:	83 c4 04             	add    $0x4,%esp
80102bf3:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bf8:	76 0d                	jbe    80102c07 <kfree+0x3a>
    panic("kfree");
80102bfa:	83 ec 0c             	sub    $0xc,%esp
80102bfd:	68 5b 88 10 80       	push   $0x8010885b
80102c02:	e8 60 d9 ff ff       	call   80100567 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c07:	83 ec 04             	sub    $0x4,%esp
80102c0a:	68 00 10 00 00       	push   $0x1000
80102c0f:	6a 01                	push   $0x1
80102c11:	ff 75 08             	pushl  0x8(%ebp)
80102c14:	e8 ae 26 00 00       	call   801052c7 <memset>
80102c19:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c1c:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c21:	85 c0                	test   %eax,%eax
80102c23:	74 10                	je     80102c35 <kfree+0x68>
    acquire(&kmem.lock);
80102c25:	83 ec 0c             	sub    $0xc,%esp
80102c28:	68 20 22 11 80       	push   $0x80112220
80102c2d:	e8 32 24 00 00       	call   80105064 <acquire>
80102c32:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c35:	8b 45 08             	mov    0x8(%ebp),%eax
80102c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c3b:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c44:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c49:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102c4e:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c53:	85 c0                	test   %eax,%eax
80102c55:	74 10                	je     80102c67 <kfree+0x9a>
    release(&kmem.lock);
80102c57:	83 ec 0c             	sub    $0xc,%esp
80102c5a:	68 20 22 11 80       	push   $0x80112220
80102c5f:	e8 67 24 00 00       	call   801050cb <release>
80102c64:	83 c4 10             	add    $0x10,%esp
}
80102c67:	90                   	nop
80102c68:	c9                   	leave  
80102c69:	c3                   	ret    

80102c6a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c6a:	55                   	push   %ebp
80102c6b:	89 e5                	mov    %esp,%ebp
80102c6d:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c70:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c75:	85 c0                	test   %eax,%eax
80102c77:	74 10                	je     80102c89 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c79:	83 ec 0c             	sub    $0xc,%esp
80102c7c:	68 20 22 11 80       	push   $0x80112220
80102c81:	e8 de 23 00 00       	call   80105064 <acquire>
80102c86:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c89:	a1 58 22 11 80       	mov    0x80112258,%eax
80102c8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c95:	74 0a                	je     80102ca1 <kalloc+0x37>
    kmem.freelist = r->next;
80102c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9a:	8b 00                	mov    (%eax),%eax
80102c9c:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102ca1:	a1 54 22 11 80       	mov    0x80112254,%eax
80102ca6:	85 c0                	test   %eax,%eax
80102ca8:	74 10                	je     80102cba <kalloc+0x50>
    release(&kmem.lock);
80102caa:	83 ec 0c             	sub    $0xc,%esp
80102cad:	68 20 22 11 80       	push   $0x80112220
80102cb2:	e8 14 24 00 00       	call   801050cb <release>
80102cb7:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cbd:	c9                   	leave  
80102cbe:	c3                   	ret    

80102cbf <inb>:
{
80102cbf:	55                   	push   %ebp
80102cc0:	89 e5                	mov    %esp,%ebp
80102cc2:	83 ec 14             	sub    $0x14,%esp
80102cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ccc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cd0:	89 c2                	mov    %eax,%edx
80102cd2:	ec                   	in     (%dx),%al
80102cd3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cd6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cda:	c9                   	leave  
80102cdb:	c3                   	ret    

80102cdc <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cdc:	55                   	push   %ebp
80102cdd:	89 e5                	mov    %esp,%ebp
80102cdf:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ce2:	6a 64                	push   $0x64
80102ce4:	e8 d6 ff ff ff       	call   80102cbf <inb>
80102ce9:	83 c4 04             	add    $0x4,%esp
80102cec:	0f b6 c0             	movzbl %al,%eax
80102cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf5:	83 e0 01             	and    $0x1,%eax
80102cf8:	85 c0                	test   %eax,%eax
80102cfa:	75 0a                	jne    80102d06 <kbdgetc+0x2a>
    return -1;
80102cfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d01:	e9 23 01 00 00       	jmp    80102e29 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d06:	6a 60                	push   $0x60
80102d08:	e8 b2 ff ff ff       	call   80102cbf <inb>
80102d0d:	83 c4 04             	add    $0x4,%esp
80102d10:	0f b6 c0             	movzbl %al,%eax
80102d13:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d16:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d1d:	75 17                	jne    80102d36 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d1f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d24:	83 c8 40             	or     $0x40,%eax
80102d27:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d2c:	b8 00 00 00 00       	mov    $0x0,%eax
80102d31:	e9 f3 00 00 00       	jmp    80102e29 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d39:	25 80 00 00 00       	and    $0x80,%eax
80102d3e:	85 c0                	test   %eax,%eax
80102d40:	74 45                	je     80102d87 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d42:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d47:	83 e0 40             	and    $0x40,%eax
80102d4a:	85 c0                	test   %eax,%eax
80102d4c:	75 08                	jne    80102d56 <kbdgetc+0x7a>
80102d4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d51:	83 e0 7f             	and    $0x7f,%eax
80102d54:	eb 03                	jmp    80102d59 <kbdgetc+0x7d>
80102d56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d59:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d5f:	05 20 90 10 80       	add    $0x80109020,%eax
80102d64:	0f b6 00             	movzbl (%eax),%eax
80102d67:	83 c8 40             	or     $0x40,%eax
80102d6a:	0f b6 c0             	movzbl %al,%eax
80102d6d:	f7 d0                	not    %eax
80102d6f:	89 c2                	mov    %eax,%edx
80102d71:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d76:	21 d0                	and    %edx,%eax
80102d78:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d7d:	b8 00 00 00 00       	mov    $0x0,%eax
80102d82:	e9 a2 00 00 00       	jmp    80102e29 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d87:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d8c:	83 e0 40             	and    $0x40,%eax
80102d8f:	85 c0                	test   %eax,%eax
80102d91:	74 14                	je     80102da7 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d93:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d9a:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d9f:	83 e0 bf             	and    $0xffffffbf,%eax
80102da2:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102daa:	05 20 90 10 80       	add    $0x80109020,%eax
80102daf:	0f b6 00             	movzbl (%eax),%eax
80102db2:	0f b6 d0             	movzbl %al,%edx
80102db5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dba:	09 d0                	or     %edx,%eax
80102dbc:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc4:	05 20 91 10 80       	add    $0x80109120,%eax
80102dc9:	0f b6 00             	movzbl (%eax),%eax
80102dcc:	0f b6 d0             	movzbl %al,%edx
80102dcf:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dd4:	31 d0                	xor    %edx,%eax
80102dd6:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102ddb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102de0:	83 e0 03             	and    $0x3,%eax
80102de3:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102dea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ded:	01 d0                	add    %edx,%eax
80102def:	0f b6 00             	movzbl (%eax),%eax
80102df2:	0f b6 c0             	movzbl %al,%eax
80102df5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102df8:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dfd:	83 e0 08             	and    $0x8,%eax
80102e00:	85 c0                	test   %eax,%eax
80102e02:	74 22                	je     80102e26 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e04:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e08:	76 0c                	jbe    80102e16 <kbdgetc+0x13a>
80102e0a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e0e:	77 06                	ja     80102e16 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e10:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e14:	eb 10                	jmp    80102e26 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e16:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e1a:	76 0a                	jbe    80102e26 <kbdgetc+0x14a>
80102e1c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e20:	77 04                	ja     80102e26 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e22:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e26:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e29:	c9                   	leave  
80102e2a:	c3                   	ret    

80102e2b <kbdintr>:

void
kbdintr(void)
{
80102e2b:	55                   	push   %ebp
80102e2c:	89 e5                	mov    %esp,%ebp
80102e2e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e31:	83 ec 0c             	sub    $0xc,%esp
80102e34:	68 dc 2c 10 80       	push   $0x80102cdc
80102e39:	e8 c4 d9 ff ff       	call   80100802 <consoleintr>
80102e3e:	83 c4 10             	add    $0x10,%esp
}
80102e41:	90                   	nop
80102e42:	c9                   	leave  
80102e43:	c3                   	ret    

80102e44 <inb>:
{
80102e44:	55                   	push   %ebp
80102e45:	89 e5                	mov    %esp,%ebp
80102e47:	83 ec 14             	sub    $0x14,%esp
80102e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e51:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e55:	89 c2                	mov    %eax,%edx
80102e57:	ec                   	in     (%dx),%al
80102e58:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e5b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e5f:	c9                   	leave  
80102e60:	c3                   	ret    

80102e61 <outb>:
{
80102e61:	55                   	push   %ebp
80102e62:	89 e5                	mov    %esp,%ebp
80102e64:	83 ec 08             	sub    $0x8,%esp
80102e67:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e6d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e71:	89 d0                	mov    %edx,%eax
80102e73:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e76:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e7a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e7e:	ee                   	out    %al,(%dx)
}
80102e7f:	90                   	nop
80102e80:	c9                   	leave  
80102e81:	c3                   	ret    

80102e82 <readeflags>:
{
80102e82:	55                   	push   %ebp
80102e83:	89 e5                	mov    %esp,%ebp
80102e85:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e88:	9c                   	pushf  
80102e89:	58                   	pop    %eax
80102e8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e90:	c9                   	leave  
80102e91:	c3                   	ret    

80102e92 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e92:	55                   	push   %ebp
80102e93:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e95:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102e9d:	c1 e2 02             	shl    $0x2,%edx
80102ea0:	01 c2                	add    %eax,%edx
80102ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ea5:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ea7:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102eac:	83 c0 20             	add    $0x20,%eax
80102eaf:	8b 00                	mov    (%eax),%eax
}
80102eb1:	90                   	nop
80102eb2:	5d                   	pop    %ebp
80102eb3:	c3                   	ret    

80102eb4 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102eb4:	55                   	push   %ebp
80102eb5:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102eb7:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ebc:	85 c0                	test   %eax,%eax
80102ebe:	0f 84 0c 01 00 00    	je     80102fd0 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ec4:	68 3f 01 00 00       	push   $0x13f
80102ec9:	6a 3c                	push   $0x3c
80102ecb:	e8 c2 ff ff ff       	call   80102e92 <lapicw>
80102ed0:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ed3:	6a 0b                	push   $0xb
80102ed5:	68 f8 00 00 00       	push   $0xf8
80102eda:	e8 b3 ff ff ff       	call   80102e92 <lapicw>
80102edf:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ee2:	68 20 00 02 00       	push   $0x20020
80102ee7:	68 c8 00 00 00       	push   $0xc8
80102eec:	e8 a1 ff ff ff       	call   80102e92 <lapicw>
80102ef1:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102ef4:	68 80 96 98 00       	push   $0x989680
80102ef9:	68 e0 00 00 00       	push   $0xe0
80102efe:	e8 8f ff ff ff       	call   80102e92 <lapicw>
80102f03:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f06:	68 00 00 01 00       	push   $0x10000
80102f0b:	68 d4 00 00 00       	push   $0xd4
80102f10:	e8 7d ff ff ff       	call   80102e92 <lapicw>
80102f15:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f18:	68 00 00 01 00       	push   $0x10000
80102f1d:	68 d8 00 00 00       	push   $0xd8
80102f22:	e8 6b ff ff ff       	call   80102e92 <lapicw>
80102f27:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f2a:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f2f:	83 c0 30             	add    $0x30,%eax
80102f32:	8b 00                	mov    (%eax),%eax
80102f34:	c1 e8 10             	shr    $0x10,%eax
80102f37:	25 fc 00 00 00       	and    $0xfc,%eax
80102f3c:	85 c0                	test   %eax,%eax
80102f3e:	74 12                	je     80102f52 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f40:	68 00 00 01 00       	push   $0x10000
80102f45:	68 d0 00 00 00       	push   $0xd0
80102f4a:	e8 43 ff ff ff       	call   80102e92 <lapicw>
80102f4f:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f52:	6a 33                	push   $0x33
80102f54:	68 dc 00 00 00       	push   $0xdc
80102f59:	e8 34 ff ff ff       	call   80102e92 <lapicw>
80102f5e:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f61:	6a 00                	push   $0x0
80102f63:	68 a0 00 00 00       	push   $0xa0
80102f68:	e8 25 ff ff ff       	call   80102e92 <lapicw>
80102f6d:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f70:	6a 00                	push   $0x0
80102f72:	68 a0 00 00 00       	push   $0xa0
80102f77:	e8 16 ff ff ff       	call   80102e92 <lapicw>
80102f7c:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f7f:	6a 00                	push   $0x0
80102f81:	6a 2c                	push   $0x2c
80102f83:	e8 0a ff ff ff       	call   80102e92 <lapicw>
80102f88:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f8b:	6a 00                	push   $0x0
80102f8d:	68 c4 00 00 00       	push   $0xc4
80102f92:	e8 fb fe ff ff       	call   80102e92 <lapicw>
80102f97:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f9a:	68 00 85 08 00       	push   $0x88500
80102f9f:	68 c0 00 00 00       	push   $0xc0
80102fa4:	e8 e9 fe ff ff       	call   80102e92 <lapicw>
80102fa9:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fac:	90                   	nop
80102fad:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102fb2:	05 00 03 00 00       	add    $0x300,%eax
80102fb7:	8b 00                	mov    (%eax),%eax
80102fb9:	25 00 10 00 00       	and    $0x1000,%eax
80102fbe:	85 c0                	test   %eax,%eax
80102fc0:	75 eb                	jne    80102fad <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fc2:	6a 00                	push   $0x0
80102fc4:	6a 20                	push   $0x20
80102fc6:	e8 c7 fe ff ff       	call   80102e92 <lapicw>
80102fcb:	83 c4 08             	add    $0x8,%esp
80102fce:	eb 01                	jmp    80102fd1 <lapicinit+0x11d>
    return;
80102fd0:	90                   	nop
}
80102fd1:	c9                   	leave  
80102fd2:	c3                   	ret    

80102fd3 <cpunum>:

int
cpunum(void)
{
80102fd3:	55                   	push   %ebp
80102fd4:	89 e5                	mov    %esp,%ebp
80102fd6:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fd9:	e8 a4 fe ff ff       	call   80102e82 <readeflags>
80102fde:	25 00 02 00 00       	and    $0x200,%eax
80102fe3:	85 c0                	test   %eax,%eax
80102fe5:	74 26                	je     8010300d <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102fe7:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102fec:	8d 50 01             	lea    0x1(%eax),%edx
80102fef:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102ff5:	85 c0                	test   %eax,%eax
80102ff7:	75 14                	jne    8010300d <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102ff9:	8b 45 04             	mov    0x4(%ebp),%eax
80102ffc:	83 ec 08             	sub    $0x8,%esp
80102fff:	50                   	push   %eax
80103000:	68 64 88 10 80       	push   $0x80108864
80103005:	e8 ba d3 ff ff       	call   801003c4 <cprintf>
8010300a:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010300d:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80103012:	85 c0                	test   %eax,%eax
80103014:	74 0f                	je     80103025 <cpunum+0x52>
    return lapic[ID]>>24;
80103016:	a1 5c 22 11 80       	mov    0x8011225c,%eax
8010301b:	83 c0 20             	add    $0x20,%eax
8010301e:	8b 00                	mov    (%eax),%eax
80103020:	c1 e8 18             	shr    $0x18,%eax
80103023:	eb 05                	jmp    8010302a <cpunum+0x57>
  return 0;
80103025:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010302a:	c9                   	leave  
8010302b:	c3                   	ret    

8010302c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010302c:	55                   	push   %ebp
8010302d:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010302f:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80103034:	85 c0                	test   %eax,%eax
80103036:	74 0c                	je     80103044 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103038:	6a 00                	push   $0x0
8010303a:	6a 2c                	push   $0x2c
8010303c:	e8 51 fe ff ff       	call   80102e92 <lapicw>
80103041:	83 c4 08             	add    $0x8,%esp
}
80103044:	90                   	nop
80103045:	c9                   	leave  
80103046:	c3                   	ret    

80103047 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103047:	55                   	push   %ebp
80103048:	89 e5                	mov    %esp,%ebp
}
8010304a:	90                   	nop
8010304b:	5d                   	pop    %ebp
8010304c:	c3                   	ret    

8010304d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010304d:	55                   	push   %ebp
8010304e:	89 e5                	mov    %esp,%ebp
80103050:	83 ec 14             	sub    $0x14,%esp
80103053:	8b 45 08             	mov    0x8(%ebp),%eax
80103056:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103059:	6a 0f                	push   $0xf
8010305b:	6a 70                	push   $0x70
8010305d:	e8 ff fd ff ff       	call   80102e61 <outb>
80103062:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103065:	6a 0a                	push   $0xa
80103067:	6a 71                	push   $0x71
80103069:	e8 f3 fd ff ff       	call   80102e61 <outb>
8010306e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103071:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103078:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010307b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103080:	8b 45 0c             	mov    0xc(%ebp),%eax
80103083:	c1 e8 04             	shr    $0x4,%eax
80103086:	89 c2                	mov    %eax,%edx
80103088:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010308b:	83 c0 02             	add    $0x2,%eax
8010308e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103091:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103095:	c1 e0 18             	shl    $0x18,%eax
80103098:	50                   	push   %eax
80103099:	68 c4 00 00 00       	push   $0xc4
8010309e:	e8 ef fd ff ff       	call   80102e92 <lapicw>
801030a3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030a6:	68 00 c5 00 00       	push   $0xc500
801030ab:	68 c0 00 00 00       	push   $0xc0
801030b0:	e8 dd fd ff ff       	call   80102e92 <lapicw>
801030b5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030b8:	68 c8 00 00 00       	push   $0xc8
801030bd:	e8 85 ff ff ff       	call   80103047 <microdelay>
801030c2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030c5:	68 00 85 00 00       	push   $0x8500
801030ca:	68 c0 00 00 00       	push   $0xc0
801030cf:	e8 be fd ff ff       	call   80102e92 <lapicw>
801030d4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030d7:	6a 64                	push   $0x64
801030d9:	e8 69 ff ff ff       	call   80103047 <microdelay>
801030de:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030e8:	eb 3d                	jmp    80103127 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030ea:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030ee:	c1 e0 18             	shl    $0x18,%eax
801030f1:	50                   	push   %eax
801030f2:	68 c4 00 00 00       	push   $0xc4
801030f7:	e8 96 fd ff ff       	call   80102e92 <lapicw>
801030fc:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103102:	c1 e8 0c             	shr    $0xc,%eax
80103105:	80 cc 06             	or     $0x6,%ah
80103108:	50                   	push   %eax
80103109:	68 c0 00 00 00       	push   $0xc0
8010310e:	e8 7f fd ff ff       	call   80102e92 <lapicw>
80103113:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103116:	68 c8 00 00 00       	push   $0xc8
8010311b:	e8 27 ff ff ff       	call   80103047 <microdelay>
80103120:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103123:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103127:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010312b:	7e bd                	jle    801030ea <lapicstartap+0x9d>
  }
}
8010312d:	90                   	nop
8010312e:	c9                   	leave  
8010312f:	c3                   	ret    

80103130 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103130:	55                   	push   %ebp
80103131:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103133:	8b 45 08             	mov    0x8(%ebp),%eax
80103136:	0f b6 c0             	movzbl %al,%eax
80103139:	50                   	push   %eax
8010313a:	6a 70                	push   $0x70
8010313c:	e8 20 fd ff ff       	call   80102e61 <outb>
80103141:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103144:	68 c8 00 00 00       	push   $0xc8
80103149:	e8 f9 fe ff ff       	call   80103047 <microdelay>
8010314e:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103151:	6a 71                	push   $0x71
80103153:	e8 ec fc ff ff       	call   80102e44 <inb>
80103158:	83 c4 04             	add    $0x4,%esp
8010315b:	0f b6 c0             	movzbl %al,%eax
}
8010315e:	c9                   	leave  
8010315f:	c3                   	ret    

80103160 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103160:	55                   	push   %ebp
80103161:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103163:	6a 00                	push   $0x0
80103165:	e8 c6 ff ff ff       	call   80103130 <cmos_read>
8010316a:	83 c4 04             	add    $0x4,%esp
8010316d:	89 c2                	mov    %eax,%edx
8010316f:	8b 45 08             	mov    0x8(%ebp),%eax
80103172:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103174:	6a 02                	push   $0x2
80103176:	e8 b5 ff ff ff       	call   80103130 <cmos_read>
8010317b:	83 c4 04             	add    $0x4,%esp
8010317e:	89 c2                	mov    %eax,%edx
80103180:	8b 45 08             	mov    0x8(%ebp),%eax
80103183:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103186:	6a 04                	push   $0x4
80103188:	e8 a3 ff ff ff       	call   80103130 <cmos_read>
8010318d:	83 c4 04             	add    $0x4,%esp
80103190:	89 c2                	mov    %eax,%edx
80103192:	8b 45 08             	mov    0x8(%ebp),%eax
80103195:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103198:	6a 07                	push   $0x7
8010319a:	e8 91 ff ff ff       	call   80103130 <cmos_read>
8010319f:	83 c4 04             	add    $0x4,%esp
801031a2:	89 c2                	mov    %eax,%edx
801031a4:	8b 45 08             	mov    0x8(%ebp),%eax
801031a7:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031aa:	6a 08                	push   $0x8
801031ac:	e8 7f ff ff ff       	call   80103130 <cmos_read>
801031b1:	83 c4 04             	add    $0x4,%esp
801031b4:	89 c2                	mov    %eax,%edx
801031b6:	8b 45 08             	mov    0x8(%ebp),%eax
801031b9:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031bc:	6a 09                	push   $0x9
801031be:	e8 6d ff ff ff       	call   80103130 <cmos_read>
801031c3:	83 c4 04             	add    $0x4,%esp
801031c6:	89 c2                	mov    %eax,%edx
801031c8:	8b 45 08             	mov    0x8(%ebp),%eax
801031cb:	89 50 14             	mov    %edx,0x14(%eax)
}
801031ce:	90                   	nop
801031cf:	c9                   	leave  
801031d0:	c3                   	ret    

801031d1 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031d1:	55                   	push   %ebp
801031d2:	89 e5                	mov    %esp,%ebp
801031d4:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031d7:	6a 0b                	push   $0xb
801031d9:	e8 52 ff ff ff       	call   80103130 <cmos_read>
801031de:	83 c4 04             	add    $0x4,%esp
801031e1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031e7:	83 e0 04             	and    $0x4,%eax
801031ea:	85 c0                	test   %eax,%eax
801031ec:	0f 94 c0             	sete   %al
801031ef:	0f b6 c0             	movzbl %al,%eax
801031f2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031f5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f8:	50                   	push   %eax
801031f9:	e8 62 ff ff ff       	call   80103160 <fill_rtcdate>
801031fe:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103201:	6a 0a                	push   $0xa
80103203:	e8 28 ff ff ff       	call   80103130 <cmos_read>
80103208:	83 c4 04             	add    $0x4,%esp
8010320b:	25 80 00 00 00       	and    $0x80,%eax
80103210:	85 c0                	test   %eax,%eax
80103212:	75 27                	jne    8010323b <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103214:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103217:	50                   	push   %eax
80103218:	e8 43 ff ff ff       	call   80103160 <fill_rtcdate>
8010321d:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103220:	83 ec 04             	sub    $0x4,%esp
80103223:	6a 18                	push   $0x18
80103225:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103228:	50                   	push   %eax
80103229:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010322c:	50                   	push   %eax
8010322d:	e8 fc 20 00 00       	call   8010532e <memcmp>
80103232:	83 c4 10             	add    $0x10,%esp
80103235:	85 c0                	test   %eax,%eax
80103237:	74 05                	je     8010323e <cmostime+0x6d>
80103239:	eb ba                	jmp    801031f5 <cmostime+0x24>
        continue;
8010323b:	90                   	nop
    fill_rtcdate(&t1);
8010323c:	eb b7                	jmp    801031f5 <cmostime+0x24>
      break;
8010323e:	90                   	nop
  }

  // convert
  if (bcd) {
8010323f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103243:	0f 84 b4 00 00 00    	je     801032fd <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103249:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010324c:	c1 e8 04             	shr    $0x4,%eax
8010324f:	89 c2                	mov    %eax,%edx
80103251:	89 d0                	mov    %edx,%eax
80103253:	c1 e0 02             	shl    $0x2,%eax
80103256:	01 d0                	add    %edx,%eax
80103258:	01 c0                	add    %eax,%eax
8010325a:	89 c2                	mov    %eax,%edx
8010325c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010325f:	83 e0 0f             	and    $0xf,%eax
80103262:	01 d0                	add    %edx,%eax
80103264:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103267:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010326a:	c1 e8 04             	shr    $0x4,%eax
8010326d:	89 c2                	mov    %eax,%edx
8010326f:	89 d0                	mov    %edx,%eax
80103271:	c1 e0 02             	shl    $0x2,%eax
80103274:	01 d0                	add    %edx,%eax
80103276:	01 c0                	add    %eax,%eax
80103278:	89 c2                	mov    %eax,%edx
8010327a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010327d:	83 e0 0f             	and    $0xf,%eax
80103280:	01 d0                	add    %edx,%eax
80103282:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103285:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103288:	c1 e8 04             	shr    $0x4,%eax
8010328b:	89 c2                	mov    %eax,%edx
8010328d:	89 d0                	mov    %edx,%eax
8010328f:	c1 e0 02             	shl    $0x2,%eax
80103292:	01 d0                	add    %edx,%eax
80103294:	01 c0                	add    %eax,%eax
80103296:	89 c2                	mov    %eax,%edx
80103298:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010329b:	83 e0 0f             	and    $0xf,%eax
8010329e:	01 d0                	add    %edx,%eax
801032a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032a6:	c1 e8 04             	shr    $0x4,%eax
801032a9:	89 c2                	mov    %eax,%edx
801032ab:	89 d0                	mov    %edx,%eax
801032ad:	c1 e0 02             	shl    $0x2,%eax
801032b0:	01 d0                	add    %edx,%eax
801032b2:	01 c0                	add    %eax,%eax
801032b4:	89 c2                	mov    %eax,%edx
801032b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b9:	83 e0 0f             	and    $0xf,%eax
801032bc:	01 d0                	add    %edx,%eax
801032be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032c4:	c1 e8 04             	shr    $0x4,%eax
801032c7:	89 c2                	mov    %eax,%edx
801032c9:	89 d0                	mov    %edx,%eax
801032cb:	c1 e0 02             	shl    $0x2,%eax
801032ce:	01 d0                	add    %edx,%eax
801032d0:	01 c0                	add    %eax,%eax
801032d2:	89 c2                	mov    %eax,%edx
801032d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032d7:	83 e0 0f             	and    $0xf,%eax
801032da:	01 d0                	add    %edx,%eax
801032dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e2:	c1 e8 04             	shr    $0x4,%eax
801032e5:	89 c2                	mov    %eax,%edx
801032e7:	89 d0                	mov    %edx,%eax
801032e9:	c1 e0 02             	shl    $0x2,%eax
801032ec:	01 d0                	add    %edx,%eax
801032ee:	01 c0                	add    %eax,%eax
801032f0:	89 c2                	mov    %eax,%edx
801032f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f5:	83 e0 0f             	and    $0xf,%eax
801032f8:	01 d0                	add    %edx,%eax
801032fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103303:	89 10                	mov    %edx,(%eax)
80103305:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103308:	89 50 04             	mov    %edx,0x4(%eax)
8010330b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010330e:	89 50 08             	mov    %edx,0x8(%eax)
80103311:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103314:	89 50 0c             	mov    %edx,0xc(%eax)
80103317:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010331a:	89 50 10             	mov    %edx,0x10(%eax)
8010331d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103320:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103323:	8b 45 08             	mov    0x8(%ebp),%eax
80103326:	8b 40 14             	mov    0x14(%eax),%eax
80103329:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010332f:	8b 45 08             	mov    0x8(%ebp),%eax
80103332:	89 50 14             	mov    %edx,0x14(%eax)
}
80103335:	90                   	nop
80103336:	c9                   	leave  
80103337:	c3                   	ret    

80103338 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103338:	55                   	push   %ebp
80103339:	89 e5                	mov    %esp,%ebp
8010333b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010333e:	83 ec 08             	sub    $0x8,%esp
80103341:	68 90 88 10 80       	push   $0x80108890
80103346:	68 60 22 11 80       	push   $0x80112260
8010334b:	e8 f2 1c 00 00       	call   80105042 <initlock>
80103350:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103353:	83 ec 08             	sub    $0x8,%esp
80103356:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103359:	50                   	push   %eax
8010335a:	ff 75 08             	pushl  0x8(%ebp)
8010335d:	e8 2d e0 ff ff       	call   8010138f <readsb>
80103362:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103365:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103368:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
8010336d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103370:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = dev;
80103375:	8b 45 08             	mov    0x8(%ebp),%eax
80103378:	a3 a4 22 11 80       	mov    %eax,0x801122a4
  recover_from_log();
8010337d:	e8 b2 01 00 00       	call   80103534 <recover_from_log>
}
80103382:	90                   	nop
80103383:	c9                   	leave  
80103384:	c3                   	ret    

80103385 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103385:	55                   	push   %ebp
80103386:	89 e5                	mov    %esp,%ebp
80103388:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010338b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103392:	e9 95 00 00 00       	jmp    8010342c <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103397:	8b 15 94 22 11 80    	mov    0x80112294,%edx
8010339d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a0:	01 d0                	add    %edx,%eax
801033a2:	83 c0 01             	add    $0x1,%eax
801033a5:	89 c2                	mov    %eax,%edx
801033a7:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033ac:	83 ec 08             	sub    $0x8,%esp
801033af:	52                   	push   %edx
801033b0:	50                   	push   %eax
801033b1:	e8 00 ce ff ff       	call   801001b6 <bread>
801033b6:	83 c4 10             	add    $0x10,%esp
801033b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033bf:	83 c0 10             	add    $0x10,%eax
801033c2:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801033c9:	89 c2                	mov    %eax,%edx
801033cb:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033d0:	83 ec 08             	sub    $0x8,%esp
801033d3:	52                   	push   %edx
801033d4:	50                   	push   %eax
801033d5:	e8 dc cd ff ff       	call   801001b6 <bread>
801033da:	83 c4 10             	add    $0x10,%esp
801033dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e3:	8d 50 18             	lea    0x18(%eax),%edx
801033e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e9:	83 c0 18             	add    $0x18,%eax
801033ec:	83 ec 04             	sub    $0x4,%esp
801033ef:	68 00 02 00 00       	push   $0x200
801033f4:	52                   	push   %edx
801033f5:	50                   	push   %eax
801033f6:	e8 8b 1f 00 00       	call   80105386 <memmove>
801033fb:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033fe:	83 ec 0c             	sub    $0xc,%esp
80103401:	ff 75 ec             	pushl  -0x14(%ebp)
80103404:	e8 e6 cd ff ff       	call   801001ef <bwrite>
80103409:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
8010340c:	83 ec 0c             	sub    $0xc,%esp
8010340f:	ff 75 f0             	pushl  -0x10(%ebp)
80103412:	e8 17 ce ff ff       	call   8010022e <brelse>
80103417:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010341a:	83 ec 0c             	sub    $0xc,%esp
8010341d:	ff 75 ec             	pushl  -0x14(%ebp)
80103420:	e8 09 ce ff ff       	call   8010022e <brelse>
80103425:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103428:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010342c:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103431:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103434:	0f 8c 5d ff ff ff    	jl     80103397 <install_trans+0x12>
  }
}
8010343a:	90                   	nop
8010343b:	c9                   	leave  
8010343c:	c3                   	ret    

8010343d <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010343d:	55                   	push   %ebp
8010343e:	89 e5                	mov    %esp,%ebp
80103440:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103443:	a1 94 22 11 80       	mov    0x80112294,%eax
80103448:	89 c2                	mov    %eax,%edx
8010344a:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	52                   	push   %edx
80103453:	50                   	push   %eax
80103454:	e8 5d cd ff ff       	call   801001b6 <bread>
80103459:	83 c4 10             	add    $0x10,%esp
8010345c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010345f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103462:	83 c0 18             	add    $0x18,%eax
80103465:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103468:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346b:	8b 00                	mov    (%eax),%eax
8010346d:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
80103472:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103479:	eb 1b                	jmp    80103496 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010347b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103481:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103485:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103488:	83 c2 10             	add    $0x10,%edx
8010348b:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103492:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103496:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010349b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010349e:	7c db                	jl     8010347b <read_head+0x3e>
  }
  brelse(buf);
801034a0:	83 ec 0c             	sub    $0xc,%esp
801034a3:	ff 75 f0             	pushl  -0x10(%ebp)
801034a6:	e8 83 cd ff ff       	call   8010022e <brelse>
801034ab:	83 c4 10             	add    $0x10,%esp
}
801034ae:	90                   	nop
801034af:	c9                   	leave  
801034b0:	c3                   	ret    

801034b1 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034b1:	55                   	push   %ebp
801034b2:	89 e5                	mov    %esp,%ebp
801034b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034b7:	a1 94 22 11 80       	mov    0x80112294,%eax
801034bc:	89 c2                	mov    %eax,%edx
801034be:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801034c3:	83 ec 08             	sub    $0x8,%esp
801034c6:	52                   	push   %edx
801034c7:	50                   	push   %eax
801034c8:	e8 e9 cc ff ff       	call   801001b6 <bread>
801034cd:	83 c4 10             	add    $0x10,%esp
801034d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d6:	83 c0 18             	add    $0x18,%eax
801034d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034dc:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
801034e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e5:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ee:	eb 1b                	jmp    8010350b <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f3:	83 c0 10             	add    $0x10,%eax
801034f6:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
801034fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103500:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103503:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103507:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010350b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103510:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103513:	7c db                	jl     801034f0 <write_head+0x3f>
  }
  bwrite(buf);
80103515:	83 ec 0c             	sub    $0xc,%esp
80103518:	ff 75 f0             	pushl  -0x10(%ebp)
8010351b:	e8 cf cc ff ff       	call   801001ef <bwrite>
80103520:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103523:	83 ec 0c             	sub    $0xc,%esp
80103526:	ff 75 f0             	pushl  -0x10(%ebp)
80103529:	e8 00 cd ff ff       	call   8010022e <brelse>
8010352e:	83 c4 10             	add    $0x10,%esp
}
80103531:	90                   	nop
80103532:	c9                   	leave  
80103533:	c3                   	ret    

80103534 <recover_from_log>:

static void
recover_from_log(void)
{
80103534:	55                   	push   %ebp
80103535:	89 e5                	mov    %esp,%ebp
80103537:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010353a:	e8 fe fe ff ff       	call   8010343d <read_head>
  install_trans(); // if committed, copy from log to disk
8010353f:	e8 41 fe ff ff       	call   80103385 <install_trans>
  log.lh.n = 0;
80103544:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
8010354b:	00 00 00 
  write_head(); // clear the log
8010354e:	e8 5e ff ff ff       	call   801034b1 <write_head>
}
80103553:	90                   	nop
80103554:	c9                   	leave  
80103555:	c3                   	ret    

80103556 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103556:	55                   	push   %ebp
80103557:	89 e5                	mov    %esp,%ebp
80103559:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010355c:	83 ec 0c             	sub    $0xc,%esp
8010355f:	68 60 22 11 80       	push   $0x80112260
80103564:	e8 fb 1a 00 00       	call   80105064 <acquire>
80103569:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010356c:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103571:	85 c0                	test   %eax,%eax
80103573:	74 17                	je     8010358c <begin_op+0x36>
      sleep(&log, &log.lock);
80103575:	83 ec 08             	sub    $0x8,%esp
80103578:	68 60 22 11 80       	push   $0x80112260
8010357d:	68 60 22 11 80       	push   $0x80112260
80103582:	e8 e4 17 00 00       	call   80104d6b <sleep>
80103587:	83 c4 10             	add    $0x10,%esp
8010358a:	eb e0                	jmp    8010356c <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010358c:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103592:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103597:	8d 50 01             	lea    0x1(%eax),%edx
8010359a:	89 d0                	mov    %edx,%eax
8010359c:	c1 e0 02             	shl    $0x2,%eax
8010359f:	01 d0                	add    %edx,%eax
801035a1:	01 c0                	add    %eax,%eax
801035a3:	01 c8                	add    %ecx,%eax
801035a5:	83 f8 1e             	cmp    $0x1e,%eax
801035a8:	7e 17                	jle    801035c1 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035aa:	83 ec 08             	sub    $0x8,%esp
801035ad:	68 60 22 11 80       	push   $0x80112260
801035b2:	68 60 22 11 80       	push   $0x80112260
801035b7:	e8 af 17 00 00       	call   80104d6b <sleep>
801035bc:	83 c4 10             	add    $0x10,%esp
801035bf:	eb ab                	jmp    8010356c <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035c1:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801035c6:	83 c0 01             	add    $0x1,%eax
801035c9:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
801035ce:	83 ec 0c             	sub    $0xc,%esp
801035d1:	68 60 22 11 80       	push   $0x80112260
801035d6:	e8 f0 1a 00 00       	call   801050cb <release>
801035db:	83 c4 10             	add    $0x10,%esp
      break;
801035de:	90                   	nop
    }
  }
}
801035df:	90                   	nop
801035e0:	c9                   	leave  
801035e1:	c3                   	ret    

801035e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035e2:	55                   	push   %ebp
801035e3:	89 e5                	mov    %esp,%ebp
801035e5:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035ef:	83 ec 0c             	sub    $0xc,%esp
801035f2:	68 60 22 11 80       	push   $0x80112260
801035f7:	e8 68 1a 00 00       	call   80105064 <acquire>
801035fc:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035ff:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103604:	83 e8 01             	sub    $0x1,%eax
80103607:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
8010360c:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103611:	85 c0                	test   %eax,%eax
80103613:	74 0d                	je     80103622 <end_op+0x40>
    panic("log.committing");
80103615:	83 ec 0c             	sub    $0xc,%esp
80103618:	68 94 88 10 80       	push   $0x80108894
8010361d:	e8 45 cf ff ff       	call   80100567 <panic>
  if(log.outstanding == 0){
80103622:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103627:	85 c0                	test   %eax,%eax
80103629:	75 13                	jne    8010363e <end_op+0x5c>
    do_commit = 1;
8010362b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103632:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
80103639:	00 00 00 
8010363c:	eb 10                	jmp    8010364e <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010363e:	83 ec 0c             	sub    $0xc,%esp
80103641:	68 60 22 11 80       	push   $0x80112260
80103646:	e8 0b 18 00 00       	call   80104e56 <wakeup>
8010364b:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010364e:	83 ec 0c             	sub    $0xc,%esp
80103651:	68 60 22 11 80       	push   $0x80112260
80103656:	e8 70 1a 00 00       	call   801050cb <release>
8010365b:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010365e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103662:	74 3f                	je     801036a3 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103664:	e8 f5 00 00 00       	call   8010375e <commit>
    acquire(&log.lock);
80103669:	83 ec 0c             	sub    $0xc,%esp
8010366c:	68 60 22 11 80       	push   $0x80112260
80103671:	e8 ee 19 00 00       	call   80105064 <acquire>
80103676:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103679:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
80103680:	00 00 00 
    wakeup(&log);
80103683:	83 ec 0c             	sub    $0xc,%esp
80103686:	68 60 22 11 80       	push   $0x80112260
8010368b:	e8 c6 17 00 00       	call   80104e56 <wakeup>
80103690:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	68 60 22 11 80       	push   $0x80112260
8010369b:	e8 2b 1a 00 00       	call   801050cb <release>
801036a0:	83 c4 10             	add    $0x10,%esp
  }
}
801036a3:	90                   	nop
801036a4:	c9                   	leave  
801036a5:	c3                   	ret    

801036a6 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036a6:	55                   	push   %ebp
801036a7:	89 e5                	mov    %esp,%ebp
801036a9:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036b3:	e9 95 00 00 00       	jmp    8010374d <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036b8:	8b 15 94 22 11 80    	mov    0x80112294,%edx
801036be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036c1:	01 d0                	add    %edx,%eax
801036c3:	83 c0 01             	add    $0x1,%eax
801036c6:	89 c2                	mov    %eax,%edx
801036c8:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801036cd:	83 ec 08             	sub    $0x8,%esp
801036d0:	52                   	push   %edx
801036d1:	50                   	push   %eax
801036d2:	e8 df ca ff ff       	call   801001b6 <bread>
801036d7:	83 c4 10             	add    $0x10,%esp
801036da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e0:	83 c0 10             	add    $0x10,%eax
801036e3:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801036ea:	89 c2                	mov    %eax,%edx
801036ec:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801036f1:	83 ec 08             	sub    $0x8,%esp
801036f4:	52                   	push   %edx
801036f5:	50                   	push   %eax
801036f6:	e8 bb ca ff ff       	call   801001b6 <bread>
801036fb:	83 c4 10             	add    $0x10,%esp
801036fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103701:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103704:	8d 50 18             	lea    0x18(%eax),%edx
80103707:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010370a:	83 c0 18             	add    $0x18,%eax
8010370d:	83 ec 04             	sub    $0x4,%esp
80103710:	68 00 02 00 00       	push   $0x200
80103715:	52                   	push   %edx
80103716:	50                   	push   %eax
80103717:	e8 6a 1c 00 00       	call   80105386 <memmove>
8010371c:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010371f:	83 ec 0c             	sub    $0xc,%esp
80103722:	ff 75 f0             	pushl  -0x10(%ebp)
80103725:	e8 c5 ca ff ff       	call   801001ef <bwrite>
8010372a:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
8010372d:	83 ec 0c             	sub    $0xc,%esp
80103730:	ff 75 ec             	pushl  -0x14(%ebp)
80103733:	e8 f6 ca ff ff       	call   8010022e <brelse>
80103738:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	ff 75 f0             	pushl  -0x10(%ebp)
80103741:	e8 e8 ca ff ff       	call   8010022e <brelse>
80103746:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103749:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010374d:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103752:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103755:	0f 8c 5d ff ff ff    	jl     801036b8 <write_log+0x12>
  }
}
8010375b:	90                   	nop
8010375c:	c9                   	leave  
8010375d:	c3                   	ret    

8010375e <commit>:

static void
commit()
{
8010375e:	55                   	push   %ebp
8010375f:	89 e5                	mov    %esp,%ebp
80103761:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103764:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103769:	85 c0                	test   %eax,%eax
8010376b:	7e 1e                	jle    8010378b <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010376d:	e8 34 ff ff ff       	call   801036a6 <write_log>
    write_head();    // Write header to disk -- the real commit
80103772:	e8 3a fd ff ff       	call   801034b1 <write_head>
    install_trans(); // Now install writes to home locations
80103777:	e8 09 fc ff ff       	call   80103385 <install_trans>
    log.lh.n = 0; 
8010377c:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103783:	00 00 00 
    write_head();    // Erase the transaction from the log
80103786:	e8 26 fd ff ff       	call   801034b1 <write_head>
  }
}
8010378b:	90                   	nop
8010378c:	c9                   	leave  
8010378d:	c3                   	ret    

8010378e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010378e:	55                   	push   %ebp
8010378f:	89 e5                	mov    %esp,%ebp
80103791:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103794:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103799:	83 f8 1d             	cmp    $0x1d,%eax
8010379c:	7f 12                	jg     801037b0 <log_write+0x22>
8010379e:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801037a3:	8b 15 98 22 11 80    	mov    0x80112298,%edx
801037a9:	83 ea 01             	sub    $0x1,%edx
801037ac:	39 d0                	cmp    %edx,%eax
801037ae:	7c 0d                	jl     801037bd <log_write+0x2f>
    panic("too big a transaction");
801037b0:	83 ec 0c             	sub    $0xc,%esp
801037b3:	68 a3 88 10 80       	push   $0x801088a3
801037b8:	e8 aa cd ff ff       	call   80100567 <panic>
  if (log.outstanding < 1)
801037bd:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801037c2:	85 c0                	test   %eax,%eax
801037c4:	7f 0d                	jg     801037d3 <log_write+0x45>
    panic("log_write outside of trans");
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	68 b9 88 10 80       	push   $0x801088b9
801037ce:	e8 94 cd ff ff       	call   80100567 <panic>

  acquire(&log.lock);
801037d3:	83 ec 0c             	sub    $0xc,%esp
801037d6:	68 60 22 11 80       	push   $0x80112260
801037db:	e8 84 18 00 00       	call   80105064 <acquire>
801037e0:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037ea:	eb 1d                	jmp    80103809 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ef:	83 c0 10             	add    $0x10,%eax
801037f2:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801037f9:	89 c2                	mov    %eax,%edx
801037fb:	8b 45 08             	mov    0x8(%ebp),%eax
801037fe:	8b 40 08             	mov    0x8(%eax),%eax
80103801:	39 c2                	cmp    %eax,%edx
80103803:	74 10                	je     80103815 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
80103805:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103809:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010380e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103811:	7c d9                	jl     801037ec <log_write+0x5e>
80103813:	eb 01                	jmp    80103816 <log_write+0x88>
      break;
80103815:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103816:	8b 45 08             	mov    0x8(%ebp),%eax
80103819:	8b 40 08             	mov    0x8(%eax),%eax
8010381c:	89 c2                	mov    %eax,%edx
8010381e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103821:	83 c0 10             	add    $0x10,%eax
80103824:	89 14 85 6c 22 11 80 	mov    %edx,-0x7feedd94(,%eax,4)
  if (i == log.lh.n)
8010382b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103830:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103833:	75 0d                	jne    80103842 <log_write+0xb4>
    log.lh.n++;
80103835:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010383a:	83 c0 01             	add    $0x1,%eax
8010383d:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
80103842:	8b 45 08             	mov    0x8(%ebp),%eax
80103845:	8b 00                	mov    (%eax),%eax
80103847:	83 c8 04             	or     $0x4,%eax
8010384a:	89 c2                	mov    %eax,%edx
8010384c:	8b 45 08             	mov    0x8(%ebp),%eax
8010384f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103851:	83 ec 0c             	sub    $0xc,%esp
80103854:	68 60 22 11 80       	push   $0x80112260
80103859:	e8 6d 18 00 00       	call   801050cb <release>
8010385e:	83 c4 10             	add    $0x10,%esp
}
80103861:	90                   	nop
80103862:	c9                   	leave  
80103863:	c3                   	ret    

80103864 <v2p>:
80103864:	55                   	push   %ebp
80103865:	89 e5                	mov    %esp,%ebp
80103867:	8b 45 08             	mov    0x8(%ebp),%eax
8010386a:	05 00 00 00 80       	add    $0x80000000,%eax
8010386f:	5d                   	pop    %ebp
80103870:	c3                   	ret    

80103871 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103871:	55                   	push   %ebp
80103872:	89 e5                	mov    %esp,%ebp
80103874:	8b 45 08             	mov    0x8(%ebp),%eax
80103877:	05 00 00 00 80       	add    $0x80000000,%eax
8010387c:	5d                   	pop    %ebp
8010387d:	c3                   	ret    

8010387e <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010387e:	55                   	push   %ebp
8010387f:	89 e5                	mov    %esp,%ebp
80103881:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103884:	8b 55 08             	mov    0x8(%ebp),%edx
80103887:	8b 45 0c             	mov    0xc(%ebp),%eax
8010388a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010388d:	f0 87 02             	lock xchg %eax,(%edx)
80103890:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103893:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103896:	c9                   	leave  
80103897:	c3                   	ret    

80103898 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103898:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010389c:	83 e4 f0             	and    $0xfffffff0,%esp
8010389f:	ff 71 fc             	pushl  -0x4(%ecx)
801038a2:	55                   	push   %ebp
801038a3:	89 e5                	mov    %esp,%ebp
801038a5:	51                   	push   %ecx
801038a6:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038a9:	83 ec 08             	sub    $0x8,%esp
801038ac:	68 00 00 40 80       	push   $0x80400000
801038b1:	68 3c 51 11 80       	push   $0x8011513c
801038b6:	e8 78 f2 ff ff       	call   80102b33 <kinit1>
801038bb:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038be:	e8 dc 45 00 00       	call   80107e9f <kvmalloc>
  mpinit();        // collect info about this machine
801038c3:	e8 3d 04 00 00       	call   80103d05 <mpinit>
  lapicinit();
801038c8:	e8 e7 f5 ff ff       	call   80102eb4 <lapicinit>
  seginit();       // set up segments
801038cd:	e8 76 3f 00 00       	call   80107848 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038d2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038d8:	0f b6 00             	movzbl (%eax),%eax
801038db:	0f b6 c0             	movzbl %al,%eax
801038de:	83 ec 08             	sub    $0x8,%esp
801038e1:	50                   	push   %eax
801038e2:	68 d4 88 10 80       	push   $0x801088d4
801038e7:	e8 d8 ca ff ff       	call   801003c4 <cprintf>
801038ec:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038ef:	e8 69 06 00 00       	call   80103f5d <picinit>
  ioapicinit();    // another interrupt controller
801038f4:	e8 2f f1 ff ff       	call   80102a28 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038f9:	e8 26 d2 ff ff       	call   80100b24 <consoleinit>
  uartinit();      // serial port
801038fe:	e8 a1 32 00 00       	call   80106ba4 <uartinit>
  pinit();         // process table
80103903:	e8 5c 0b 00 00       	call   80104464 <pinit>
  tvinit();        // trap vectors
80103908:	e8 5f 2e 00 00       	call   8010676c <tvinit>
  binit();         // buffer cache
8010390d:	e8 22 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103912:	e8 69 d6 ff ff       	call   80100f80 <fileinit>
  ideinit();       // disk
80103917:	e8 14 ed ff ff       	call   80102630 <ideinit>
  if(!ismp)
8010391c:	a1 44 23 11 80       	mov    0x80112344,%eax
80103921:	85 c0                	test   %eax,%eax
80103923:	75 05                	jne    8010392a <main+0x92>
    timerinit();   // uniprocessor timer
80103925:	e8 9f 2d 00 00       	call   801066c9 <timerinit>
  startothers();   // start other processors
8010392a:	e8 7f 00 00 00       	call   801039ae <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010392f:	83 ec 08             	sub    $0x8,%esp
80103932:	68 00 00 00 8e       	push   $0x8e000000
80103937:	68 00 00 40 80       	push   $0x80400000
8010393c:	e8 2b f2 ff ff       	call   80102b6c <kinit2>
80103941:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103944:	e8 4c 0c 00 00       	call   80104595 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103949:	e8 1a 00 00 00       	call   80103968 <mpmain>

8010394e <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010394e:	55                   	push   %ebp
8010394f:	89 e5                	mov    %esp,%ebp
80103951:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103954:	e8 5e 45 00 00       	call   80107eb7 <switchkvm>
  seginit();
80103959:	e8 ea 3e 00 00       	call   80107848 <seginit>
  lapicinit();
8010395e:	e8 51 f5 ff ff       	call   80102eb4 <lapicinit>
  mpmain();
80103963:	e8 00 00 00 00       	call   80103968 <mpmain>

80103968 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010396e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103974:	0f b6 00             	movzbl (%eax),%eax
80103977:	0f b6 c0             	movzbl %al,%eax
8010397a:	83 ec 08             	sub    $0x8,%esp
8010397d:	50                   	push   %eax
8010397e:	68 eb 88 10 80       	push   $0x801088eb
80103983:	e8 3c ca ff ff       	call   801003c4 <cprintf>
80103988:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010398b:	e8 52 2f 00 00       	call   801068e2 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103990:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103996:	05 a8 00 00 00       	add    $0xa8,%eax
8010399b:	83 ec 08             	sub    $0x8,%esp
8010399e:	6a 01                	push   $0x1
801039a0:	50                   	push   %eax
801039a1:	e8 d8 fe ff ff       	call   8010387e <xchg>
801039a6:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039a9:	e8 94 11 00 00       	call   80104b42 <scheduler>

801039ae <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039ae:	55                   	push   %ebp
801039af:	89 e5                	mov    %esp,%ebp
801039b1:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039b4:	68 00 70 00 00       	push   $0x7000
801039b9:	e8 b3 fe ff ff       	call   80103871 <p2v>
801039be:	83 c4 04             	add    $0x4,%esp
801039c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039c4:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039c9:	83 ec 04             	sub    $0x4,%esp
801039cc:	50                   	push   %eax
801039cd:	68 0c b5 10 80       	push   $0x8010b50c
801039d2:	ff 75 f0             	pushl  -0x10(%ebp)
801039d5:	e8 ac 19 00 00       	call   80105386 <memmove>
801039da:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039dd:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
801039e4:	e9 92 00 00 00       	jmp    80103a7b <startothers+0xcd>
    if(c == cpus+cpunum())  // We've started already.
801039e9:	e8 e5 f5 ff ff       	call   80102fd3 <cpunum>
801039ee:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039f4:	05 60 23 11 80       	add    $0x80112360,%eax
801039f9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039fc:	74 75                	je     80103a73 <startothers+0xc5>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039fe:	e8 67 f2 ff ff       	call   80102c6a <kalloc>
80103a03:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a09:	83 e8 04             	sub    $0x4,%eax
80103a0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a0f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a15:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a1a:	83 e8 08             	sub    $0x8,%eax
80103a1d:	c7 00 4e 39 10 80    	movl   $0x8010394e,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a23:	83 ec 0c             	sub    $0xc,%esp
80103a26:	68 00 a0 10 80       	push   $0x8010a000
80103a2b:	e8 34 fe ff ff       	call   80103864 <v2p>
80103a30:	83 c4 10             	add    $0x10,%esp
80103a33:	89 c2                	mov    %eax,%edx
80103a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a38:	83 e8 0c             	sub    $0xc,%eax
80103a3b:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->id, v2p(code));
80103a3d:	83 ec 0c             	sub    $0xc,%esp
80103a40:	ff 75 f0             	pushl  -0x10(%ebp)
80103a43:	e8 1c fe ff ff       	call   80103864 <v2p>
80103a48:	83 c4 10             	add    $0x10,%esp
80103a4b:	89 c2                	mov    %eax,%edx
80103a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a50:	0f b6 00             	movzbl (%eax),%eax
80103a53:	0f b6 c0             	movzbl %al,%eax
80103a56:	83 ec 08             	sub    $0x8,%esp
80103a59:	52                   	push   %edx
80103a5a:	50                   	push   %eax
80103a5b:	e8 ed f5 ff ff       	call   8010304d <lapicstartap>
80103a60:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a63:	90                   	nop
80103a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a67:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a6d:	85 c0                	test   %eax,%eax
80103a6f:	74 f3                	je     80103a64 <startothers+0xb6>
80103a71:	eb 01                	jmp    80103a74 <startothers+0xc6>
      continue;
80103a73:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103a74:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a7b:	a1 40 29 11 80       	mov    0x80112940,%eax
80103a80:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a86:	05 60 23 11 80       	add    $0x80112360,%eax
80103a8b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a8e:	0f 82 55 ff ff ff    	jb     801039e9 <startothers+0x3b>
      ;
  }
}
80103a94:	90                   	nop
80103a95:	c9                   	leave  
80103a96:	c3                   	ret    

80103a97 <p2v>:
80103a97:	55                   	push   %ebp
80103a98:	89 e5                	mov    %esp,%ebp
80103a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9d:	05 00 00 00 80       	add    $0x80000000,%eax
80103aa2:	5d                   	pop    %ebp
80103aa3:	c3                   	ret    

80103aa4 <inb>:
{
80103aa4:	55                   	push   %ebp
80103aa5:	89 e5                	mov    %esp,%ebp
80103aa7:	83 ec 14             	sub    $0x14,%esp
80103aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80103aad:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ab1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ab5:	89 c2                	mov    %eax,%edx
80103ab7:	ec                   	in     (%dx),%al
80103ab8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103abb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103abf:	c9                   	leave  
80103ac0:	c3                   	ret    

80103ac1 <outb>:
{
80103ac1:	55                   	push   %ebp
80103ac2:	89 e5                	mov    %esp,%ebp
80103ac4:	83 ec 08             	sub    $0x8,%esp
80103ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80103aca:	8b 55 0c             	mov    0xc(%ebp),%edx
80103acd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ad1:	89 d0                	mov    %edx,%eax
80103ad3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ad6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ada:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ade:	ee                   	out    %al,(%dx)
}
80103adf:	90                   	nop
80103ae0:	c9                   	leave  
80103ae1:	c3                   	ret    

80103ae2 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103ae2:	55                   	push   %ebp
80103ae3:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103ae5:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103aea:	2d 60 23 11 80       	sub    $0x80112360,%eax
80103aef:	c1 f8 02             	sar    $0x2,%eax
80103af2:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103af8:	5d                   	pop    %ebp
80103af9:	c3                   	ret    

80103afa <sum>:

static uchar
sum(uchar *addr, int len)
{
80103afa:	55                   	push   %ebp
80103afb:	89 e5                	mov    %esp,%ebp
80103afd:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b00:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b07:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b0e:	eb 15                	jmp    80103b25 <sum+0x2b>
    sum += addr[i];
80103b10:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b13:	8b 45 08             	mov    0x8(%ebp),%eax
80103b16:	01 d0                	add    %edx,%eax
80103b18:	0f b6 00             	movzbl (%eax),%eax
80103b1b:	0f b6 c0             	movzbl %al,%eax
80103b1e:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b21:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b28:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b2b:	7c e3                	jl     80103b10 <sum+0x16>
  return sum;
80103b2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b30:	c9                   	leave  
80103b31:	c3                   	ret    

80103b32 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b32:	55                   	push   %ebp
80103b33:	89 e5                	mov    %esp,%ebp
80103b35:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b38:	ff 75 08             	pushl  0x8(%ebp)
80103b3b:	e8 57 ff ff ff       	call   80103a97 <p2v>
80103b40:	83 c4 04             	add    $0x4,%esp
80103b43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b46:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b4c:	01 d0                	add    %edx,%eax
80103b4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b57:	eb 36                	jmp    80103b8f <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b59:	83 ec 04             	sub    $0x4,%esp
80103b5c:	6a 04                	push   $0x4
80103b5e:	68 fc 88 10 80       	push   $0x801088fc
80103b63:	ff 75 f4             	pushl  -0xc(%ebp)
80103b66:	e8 c3 17 00 00       	call   8010532e <memcmp>
80103b6b:	83 c4 10             	add    $0x10,%esp
80103b6e:	85 c0                	test   %eax,%eax
80103b70:	75 19                	jne    80103b8b <mpsearch1+0x59>
80103b72:	83 ec 08             	sub    $0x8,%esp
80103b75:	6a 10                	push   $0x10
80103b77:	ff 75 f4             	pushl  -0xc(%ebp)
80103b7a:	e8 7b ff ff ff       	call   80103afa <sum>
80103b7f:	83 c4 10             	add    $0x10,%esp
80103b82:	84 c0                	test   %al,%al
80103b84:	75 05                	jne    80103b8b <mpsearch1+0x59>
      return (struct mp*)p;
80103b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b89:	eb 11                	jmp    80103b9c <mpsearch1+0x6a>
  for(p = addr; p < e; p += sizeof(struct mp))
80103b8b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b92:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b95:	72 c2                	jb     80103b59 <mpsearch1+0x27>
  return 0;
80103b97:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b9c:	c9                   	leave  
80103b9d:	c3                   	ret    

80103b9e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b9e:	55                   	push   %ebp
80103b9f:	89 e5                	mov    %esp,%ebp
80103ba1:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ba4:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bae:	83 c0 0f             	add    $0xf,%eax
80103bb1:	0f b6 00             	movzbl (%eax),%eax
80103bb4:	0f b6 c0             	movzbl %al,%eax
80103bb7:	c1 e0 08             	shl    $0x8,%eax
80103bba:	89 c2                	mov    %eax,%edx
80103bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbf:	83 c0 0e             	add    $0xe,%eax
80103bc2:	0f b6 00             	movzbl (%eax),%eax
80103bc5:	0f b6 c0             	movzbl %al,%eax
80103bc8:	09 d0                	or     %edx,%eax
80103bca:	c1 e0 04             	shl    $0x4,%eax
80103bcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bd4:	74 21                	je     80103bf7 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bd6:	83 ec 08             	sub    $0x8,%esp
80103bd9:	68 00 04 00 00       	push   $0x400
80103bde:	ff 75 f0             	pushl  -0x10(%ebp)
80103be1:	e8 4c ff ff ff       	call   80103b32 <mpsearch1>
80103be6:	83 c4 10             	add    $0x10,%esp
80103be9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bf0:	74 51                	je     80103c43 <mpsearch+0xa5>
      return mp;
80103bf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bf5:	eb 61                	jmp    80103c58 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfa:	83 c0 14             	add    $0x14,%eax
80103bfd:	0f b6 00             	movzbl (%eax),%eax
80103c00:	0f b6 c0             	movzbl %al,%eax
80103c03:	c1 e0 08             	shl    $0x8,%eax
80103c06:	89 c2                	mov    %eax,%edx
80103c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0b:	83 c0 13             	add    $0x13,%eax
80103c0e:	0f b6 00             	movzbl (%eax),%eax
80103c11:	0f b6 c0             	movzbl %al,%eax
80103c14:	09 d0                	or     %edx,%eax
80103c16:	c1 e0 0a             	shl    $0xa,%eax
80103c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1f:	2d 00 04 00 00       	sub    $0x400,%eax
80103c24:	83 ec 08             	sub    $0x8,%esp
80103c27:	68 00 04 00 00       	push   $0x400
80103c2c:	50                   	push   %eax
80103c2d:	e8 00 ff ff ff       	call   80103b32 <mpsearch1>
80103c32:	83 c4 10             	add    $0x10,%esp
80103c35:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c3c:	74 05                	je     80103c43 <mpsearch+0xa5>
      return mp;
80103c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c41:	eb 15                	jmp    80103c58 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c43:	83 ec 08             	sub    $0x8,%esp
80103c46:	68 00 00 01 00       	push   $0x10000
80103c4b:	68 00 00 0f 00       	push   $0xf0000
80103c50:	e8 dd fe ff ff       	call   80103b32 <mpsearch1>
80103c55:	83 c4 10             	add    $0x10,%esp
}
80103c58:	c9                   	leave  
80103c59:	c3                   	ret    

80103c5a <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c5a:	55                   	push   %ebp
80103c5b:	89 e5                	mov    %esp,%ebp
80103c5d:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c60:	e8 39 ff ff ff       	call   80103b9e <mpsearch>
80103c65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c6c:	74 0a                	je     80103c78 <mpconfig+0x1e>
80103c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c71:	8b 40 04             	mov    0x4(%eax),%eax
80103c74:	85 c0                	test   %eax,%eax
80103c76:	75 0a                	jne    80103c82 <mpconfig+0x28>
    return 0;
80103c78:	b8 00 00 00 00       	mov    $0x0,%eax
80103c7d:	e9 81 00 00 00       	jmp    80103d03 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c85:	8b 40 04             	mov    0x4(%eax),%eax
80103c88:	83 ec 0c             	sub    $0xc,%esp
80103c8b:	50                   	push   %eax
80103c8c:	e8 06 fe ff ff       	call   80103a97 <p2v>
80103c91:	83 c4 10             	add    $0x10,%esp
80103c94:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c97:	83 ec 04             	sub    $0x4,%esp
80103c9a:	6a 04                	push   $0x4
80103c9c:	68 01 89 10 80       	push   $0x80108901
80103ca1:	ff 75 f0             	pushl  -0x10(%ebp)
80103ca4:	e8 85 16 00 00       	call   8010532e <memcmp>
80103ca9:	83 c4 10             	add    $0x10,%esp
80103cac:	85 c0                	test   %eax,%eax
80103cae:	74 07                	je     80103cb7 <mpconfig+0x5d>
    return 0;
80103cb0:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb5:	eb 4c                	jmp    80103d03 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cba:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cbe:	3c 01                	cmp    $0x1,%al
80103cc0:	74 12                	je     80103cd4 <mpconfig+0x7a>
80103cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cc9:	3c 04                	cmp    $0x4,%al
80103ccb:	74 07                	je     80103cd4 <mpconfig+0x7a>
    return 0;
80103ccd:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd2:	eb 2f                	jmp    80103d03 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cdb:	0f b7 c0             	movzwl %ax,%eax
80103cde:	83 ec 08             	sub    $0x8,%esp
80103ce1:	50                   	push   %eax
80103ce2:	ff 75 f0             	pushl  -0x10(%ebp)
80103ce5:	e8 10 fe ff ff       	call   80103afa <sum>
80103cea:	83 c4 10             	add    $0x10,%esp
80103ced:	84 c0                	test   %al,%al
80103cef:	74 07                	je     80103cf8 <mpconfig+0x9e>
    return 0;
80103cf1:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf6:	eb 0b                	jmp    80103d03 <mpconfig+0xa9>
  *pmp = mp;
80103cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80103cfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cfe:	89 10                	mov    %edx,(%eax)
  return conf;
80103d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d03:	c9                   	leave  
80103d04:	c3                   	ret    

80103d05 <mpinit>:

void
mpinit(void)
{
80103d05:	55                   	push   %ebp
80103d06:	89 e5                	mov    %esp,%ebp
80103d08:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d0b:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103d12:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d15:	83 ec 0c             	sub    $0xc,%esp
80103d18:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d1b:	50                   	push   %eax
80103d1c:	e8 39 ff ff ff       	call   80103c5a <mpconfig>
80103d21:	83 c4 10             	add    $0x10,%esp
80103d24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d2b:	0f 84 96 01 00 00    	je     80103ec7 <mpinit+0x1c2>
    return;
  ismp = 1;
80103d31:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103d38:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3e:	8b 40 24             	mov    0x24(%eax),%eax
80103d41:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d49:	83 c0 2c             	add    $0x2c,%eax
80103d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d52:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d56:	0f b7 d0             	movzwl %ax,%edx
80103d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5c:	01 d0                	add    %edx,%eax
80103d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d61:	e9 f2 00 00 00       	jmp    80103e58 <mpinit+0x153>
    switch(*p){
80103d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d69:	0f b6 00             	movzbl (%eax),%eax
80103d6c:	0f b6 c0             	movzbl %al,%eax
80103d6f:	83 f8 04             	cmp    $0x4,%eax
80103d72:	0f 87 bc 00 00 00    	ja     80103e34 <mpinit+0x12f>
80103d78:	8b 04 85 44 89 10 80 	mov    -0x7fef76bc(,%eax,4),%eax
80103d7f:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d84:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d8a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d8e:	0f b6 d0             	movzbl %al,%edx
80103d91:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d96:	39 c2                	cmp    %eax,%edx
80103d98:	74 2b                	je     80103dc5 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d9d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103da1:	0f b6 d0             	movzbl %al,%edx
80103da4:	a1 40 29 11 80       	mov    0x80112940,%eax
80103da9:	83 ec 04             	sub    $0x4,%esp
80103dac:	52                   	push   %edx
80103dad:	50                   	push   %eax
80103dae:	68 06 89 10 80       	push   $0x80108906
80103db3:	e8 0c c6 ff ff       	call   801003c4 <cprintf>
80103db8:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103dbb:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103dc2:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103dc8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103dcc:	0f b6 c0             	movzbl %al,%eax
80103dcf:	83 e0 02             	and    $0x2,%eax
80103dd2:	85 c0                	test   %eax,%eax
80103dd4:	74 15                	je     80103deb <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103dd6:	a1 40 29 11 80       	mov    0x80112940,%eax
80103ddb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103de1:	05 60 23 11 80       	add    $0x80112360,%eax
80103de6:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103deb:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103df1:	a1 40 29 11 80       	mov    0x80112940,%eax
80103df6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dfc:	05 60 23 11 80       	add    $0x80112360,%eax
80103e01:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e03:	a1 40 29 11 80       	mov    0x80112940,%eax
80103e08:	83 c0 01             	add    $0x1,%eax
80103e0b:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103e10:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e14:	eb 42                	jmp    80103e58 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e1f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e23:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103e28:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e2c:	eb 2a                	jmp    80103e58 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e2e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e32:	eb 24                	jmp    80103e58 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e37:	0f b6 00             	movzbl (%eax),%eax
80103e3a:	0f b6 c0             	movzbl %al,%eax
80103e3d:	83 ec 08             	sub    $0x8,%esp
80103e40:	50                   	push   %eax
80103e41:	68 24 89 10 80       	push   $0x80108924
80103e46:	e8 79 c5 ff ff       	call   801003c4 <cprintf>
80103e4b:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e4e:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103e55:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e5e:	0f 82 02 ff ff ff    	jb     80103d66 <mpinit+0x61>
    }
  }
  if(!ismp){
80103e64:	a1 44 23 11 80       	mov    0x80112344,%eax
80103e69:	85 c0                	test   %eax,%eax
80103e6b:	75 1d                	jne    80103e8a <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e6d:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103e74:	00 00 00 
    lapic = 0;
80103e77:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103e7e:	00 00 00 
    ioapicid = 0;
80103e81:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103e88:	eb 3e                	jmp    80103ec8 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e91:	84 c0                	test   %al,%al
80103e93:	74 33                	je     80103ec8 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e95:	83 ec 08             	sub    $0x8,%esp
80103e98:	6a 70                	push   $0x70
80103e9a:	6a 22                	push   $0x22
80103e9c:	e8 20 fc ff ff       	call   80103ac1 <outb>
80103ea1:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ea4:	83 ec 0c             	sub    $0xc,%esp
80103ea7:	6a 23                	push   $0x23
80103ea9:	e8 f6 fb ff ff       	call   80103aa4 <inb>
80103eae:	83 c4 10             	add    $0x10,%esp
80103eb1:	83 c8 01             	or     $0x1,%eax
80103eb4:	0f b6 c0             	movzbl %al,%eax
80103eb7:	83 ec 08             	sub    $0x8,%esp
80103eba:	50                   	push   %eax
80103ebb:	6a 23                	push   $0x23
80103ebd:	e8 ff fb ff ff       	call   80103ac1 <outb>
80103ec2:	83 c4 10             	add    $0x10,%esp
80103ec5:	eb 01                	jmp    80103ec8 <mpinit+0x1c3>
    return;
80103ec7:	90                   	nop
  }
}
80103ec8:	c9                   	leave  
80103ec9:	c3                   	ret    

80103eca <outb>:
{
80103eca:	55                   	push   %ebp
80103ecb:	89 e5                	mov    %esp,%ebp
80103ecd:	83 ec 08             	sub    $0x8,%esp
80103ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ed6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103eda:	89 d0                	mov    %edx,%eax
80103edc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103edf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ee3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ee7:	ee                   	out    %al,(%dx)
}
80103ee8:	90                   	nop
80103ee9:	c9                   	leave  
80103eea:	c3                   	ret    

80103eeb <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103eeb:	55                   	push   %ebp
80103eec:	89 e5                	mov    %esp,%ebp
80103eee:	83 ec 04             	sub    $0x4,%esp
80103ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ef8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103efc:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f02:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f06:	0f b6 c0             	movzbl %al,%eax
80103f09:	50                   	push   %eax
80103f0a:	6a 21                	push   $0x21
80103f0c:	e8 b9 ff ff ff       	call   80103eca <outb>
80103f11:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f14:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f18:	66 c1 e8 08          	shr    $0x8,%ax
80103f1c:	0f b6 c0             	movzbl %al,%eax
80103f1f:	50                   	push   %eax
80103f20:	68 a1 00 00 00       	push   $0xa1
80103f25:	e8 a0 ff ff ff       	call   80103eca <outb>
80103f2a:	83 c4 08             	add    $0x8,%esp
}
80103f2d:	90                   	nop
80103f2e:	c9                   	leave  
80103f2f:	c3                   	ret    

80103f30 <picenable>:

void
picenable(int irq)
{
80103f30:	55                   	push   %ebp
80103f31:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f33:	8b 45 08             	mov    0x8(%ebp),%eax
80103f36:	ba 01 00 00 00       	mov    $0x1,%edx
80103f3b:	89 c1                	mov    %eax,%ecx
80103f3d:	d3 e2                	shl    %cl,%edx
80103f3f:	89 d0                	mov    %edx,%eax
80103f41:	f7 d0                	not    %eax
80103f43:	89 c2                	mov    %eax,%edx
80103f45:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f4c:	21 d0                	and    %edx,%eax
80103f4e:	0f b7 c0             	movzwl %ax,%eax
80103f51:	50                   	push   %eax
80103f52:	e8 94 ff ff ff       	call   80103eeb <picsetmask>
80103f57:	83 c4 04             	add    $0x4,%esp
}
80103f5a:	90                   	nop
80103f5b:	c9                   	leave  
80103f5c:	c3                   	ret    

80103f5d <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f5d:	55                   	push   %ebp
80103f5e:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f60:	68 ff 00 00 00       	push   $0xff
80103f65:	6a 21                	push   $0x21
80103f67:	e8 5e ff ff ff       	call   80103eca <outb>
80103f6c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f6f:	68 ff 00 00 00       	push   $0xff
80103f74:	68 a1 00 00 00       	push   $0xa1
80103f79:	e8 4c ff ff ff       	call   80103eca <outb>
80103f7e:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103f81:	6a 11                	push   $0x11
80103f83:	6a 20                	push   $0x20
80103f85:	e8 40 ff ff ff       	call   80103eca <outb>
80103f8a:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f8d:	6a 20                	push   $0x20
80103f8f:	6a 21                	push   $0x21
80103f91:	e8 34 ff ff ff       	call   80103eca <outb>
80103f96:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f99:	6a 04                	push   $0x4
80103f9b:	6a 21                	push   $0x21
80103f9d:	e8 28 ff ff ff       	call   80103eca <outb>
80103fa2:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fa5:	6a 03                	push   $0x3
80103fa7:	6a 21                	push   $0x21
80103fa9:	e8 1c ff ff ff       	call   80103eca <outb>
80103fae:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fb1:	6a 11                	push   $0x11
80103fb3:	68 a0 00 00 00       	push   $0xa0
80103fb8:	e8 0d ff ff ff       	call   80103eca <outb>
80103fbd:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103fc0:	6a 28                	push   $0x28
80103fc2:	68 a1 00 00 00       	push   $0xa1
80103fc7:	e8 fe fe ff ff       	call   80103eca <outb>
80103fcc:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103fcf:	6a 02                	push   $0x2
80103fd1:	68 a1 00 00 00       	push   $0xa1
80103fd6:	e8 ef fe ff ff       	call   80103eca <outb>
80103fdb:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103fde:	6a 03                	push   $0x3
80103fe0:	68 a1 00 00 00       	push   $0xa1
80103fe5:	e8 e0 fe ff ff       	call   80103eca <outb>
80103fea:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103fed:	6a 68                	push   $0x68
80103fef:	6a 20                	push   $0x20
80103ff1:	e8 d4 fe ff ff       	call   80103eca <outb>
80103ff6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ff9:	6a 0a                	push   $0xa
80103ffb:	6a 20                	push   $0x20
80103ffd:	e8 c8 fe ff ff       	call   80103eca <outb>
80104002:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104005:	6a 68                	push   $0x68
80104007:	68 a0 00 00 00       	push   $0xa0
8010400c:	e8 b9 fe ff ff       	call   80103eca <outb>
80104011:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104014:	6a 0a                	push   $0xa
80104016:	68 a0 00 00 00       	push   $0xa0
8010401b:	e8 aa fe ff ff       	call   80103eca <outb>
80104020:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104023:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010402a:	66 83 f8 ff          	cmp    $0xffff,%ax
8010402e:	74 13                	je     80104043 <picinit+0xe6>
    picsetmask(irqmask);
80104030:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104037:	0f b7 c0             	movzwl %ax,%eax
8010403a:	50                   	push   %eax
8010403b:	e8 ab fe ff ff       	call   80103eeb <picsetmask>
80104040:	83 c4 04             	add    $0x4,%esp
}
80104043:	90                   	nop
80104044:	c9                   	leave  
80104045:	c3                   	ret    

80104046 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104046:	55                   	push   %ebp
80104047:	89 e5                	mov    %esp,%ebp
80104049:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010404c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104053:	8b 45 0c             	mov    0xc(%ebp),%eax
80104056:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010405c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405f:	8b 10                	mov    (%eax),%edx
80104061:	8b 45 08             	mov    0x8(%ebp),%eax
80104064:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104066:	e8 33 cf ff ff       	call   80100f9e <filealloc>
8010406b:	89 c2                	mov    %eax,%edx
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	89 10                	mov    %edx,(%eax)
80104072:	8b 45 08             	mov    0x8(%ebp),%eax
80104075:	8b 00                	mov    (%eax),%eax
80104077:	85 c0                	test   %eax,%eax
80104079:	0f 84 ca 00 00 00    	je     80104149 <pipealloc+0x103>
8010407f:	e8 1a cf ff ff       	call   80100f9e <filealloc>
80104084:	89 c2                	mov    %eax,%edx
80104086:	8b 45 0c             	mov    0xc(%ebp),%eax
80104089:	89 10                	mov    %edx,(%eax)
8010408b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408e:	8b 00                	mov    (%eax),%eax
80104090:	85 c0                	test   %eax,%eax
80104092:	0f 84 b1 00 00 00    	je     80104149 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104098:	e8 cd eb ff ff       	call   80102c6a <kalloc>
8010409d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040a4:	0f 84 a2 00 00 00    	je     8010414c <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ad:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040b4:	00 00 00 
  p->writeopen = 1;
801040b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ba:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040c1:	00 00 00 
  p->nwrite = 0;
801040c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c7:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040ce:	00 00 00 
  p->nread = 0;
801040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d4:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040db:	00 00 00 
  initlock(&p->lock, "pipe");
801040de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e1:	83 ec 08             	sub    $0x8,%esp
801040e4:	68 58 89 10 80       	push   $0x80108958
801040e9:	50                   	push   %eax
801040ea:	e8 53 0f 00 00       	call   80105042 <initlock>
801040ef:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040f2:	8b 45 08             	mov    0x8(%ebp),%eax
801040f5:	8b 00                	mov    (%eax),%eax
801040f7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104100:	8b 00                	mov    (%eax),%eax
80104102:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104106:	8b 45 08             	mov    0x8(%ebp),%eax
80104109:	8b 00                	mov    (%eax),%eax
8010410b:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010410f:	8b 45 08             	mov    0x8(%ebp),%eax
80104112:	8b 00                	mov    (%eax),%eax
80104114:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104117:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010411a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010411d:	8b 00                	mov    (%eax),%eax
8010411f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104125:	8b 45 0c             	mov    0xc(%ebp),%eax
80104128:	8b 00                	mov    (%eax),%eax
8010412a:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010412e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104131:	8b 00                	mov    (%eax),%eax
80104133:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104137:	8b 45 0c             	mov    0xc(%ebp),%eax
8010413a:	8b 00                	mov    (%eax),%eax
8010413c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413f:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104142:	b8 00 00 00 00       	mov    $0x0,%eax
80104147:	eb 51                	jmp    8010419a <pipealloc+0x154>
    goto bad;
80104149:	90                   	nop
8010414a:	eb 01                	jmp    8010414d <pipealloc+0x107>
    goto bad;
8010414c:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010414d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104151:	74 0e                	je     80104161 <pipealloc+0x11b>
    kfree((char*)p);
80104153:	83 ec 0c             	sub    $0xc,%esp
80104156:	ff 75 f4             	pushl  -0xc(%ebp)
80104159:	e8 6f ea ff ff       	call   80102bcd <kfree>
8010415e:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104161:	8b 45 08             	mov    0x8(%ebp),%eax
80104164:	8b 00                	mov    (%eax),%eax
80104166:	85 c0                	test   %eax,%eax
80104168:	74 11                	je     8010417b <pipealloc+0x135>
    fileclose(*f0);
8010416a:	8b 45 08             	mov    0x8(%ebp),%eax
8010416d:	8b 00                	mov    (%eax),%eax
8010416f:	83 ec 0c             	sub    $0xc,%esp
80104172:	50                   	push   %eax
80104173:	e8 e4 ce ff ff       	call   8010105c <fileclose>
80104178:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010417b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010417e:	8b 00                	mov    (%eax),%eax
80104180:	85 c0                	test   %eax,%eax
80104182:	74 11                	je     80104195 <pipealloc+0x14f>
    fileclose(*f1);
80104184:	8b 45 0c             	mov    0xc(%ebp),%eax
80104187:	8b 00                	mov    (%eax),%eax
80104189:	83 ec 0c             	sub    $0xc,%esp
8010418c:	50                   	push   %eax
8010418d:	e8 ca ce ff ff       	call   8010105c <fileclose>
80104192:	83 c4 10             	add    $0x10,%esp
  return -1;
80104195:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010419a:	c9                   	leave  
8010419b:	c3                   	ret    

8010419c <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010419c:	55                   	push   %ebp
8010419d:	89 e5                	mov    %esp,%ebp
8010419f:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041a2:	8b 45 08             	mov    0x8(%ebp),%eax
801041a5:	83 ec 0c             	sub    $0xc,%esp
801041a8:	50                   	push   %eax
801041a9:	e8 b6 0e 00 00       	call   80105064 <acquire>
801041ae:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041b5:	74 23                	je     801041da <pipeclose+0x3e>
    p->writeopen = 0;
801041b7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ba:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041c1:	00 00 00 
    wakeup(&p->nread);
801041c4:	8b 45 08             	mov    0x8(%ebp),%eax
801041c7:	05 34 02 00 00       	add    $0x234,%eax
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	50                   	push   %eax
801041d0:	e8 81 0c 00 00       	call   80104e56 <wakeup>
801041d5:	83 c4 10             	add    $0x10,%esp
801041d8:	eb 21                	jmp    801041fb <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801041da:	8b 45 08             	mov    0x8(%ebp),%eax
801041dd:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041e4:	00 00 00 
    wakeup(&p->nwrite);
801041e7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ea:	05 38 02 00 00       	add    $0x238,%eax
801041ef:	83 ec 0c             	sub    $0xc,%esp
801041f2:	50                   	push   %eax
801041f3:	e8 5e 0c 00 00       	call   80104e56 <wakeup>
801041f8:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104204:	85 c0                	test   %eax,%eax
80104206:	75 2c                	jne    80104234 <pipeclose+0x98>
80104208:	8b 45 08             	mov    0x8(%ebp),%eax
8010420b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104211:	85 c0                	test   %eax,%eax
80104213:	75 1f                	jne    80104234 <pipeclose+0x98>
    release(&p->lock);
80104215:	8b 45 08             	mov    0x8(%ebp),%eax
80104218:	83 ec 0c             	sub    $0xc,%esp
8010421b:	50                   	push   %eax
8010421c:	e8 aa 0e 00 00       	call   801050cb <release>
80104221:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104224:	83 ec 0c             	sub    $0xc,%esp
80104227:	ff 75 08             	pushl  0x8(%ebp)
8010422a:	e8 9e e9 ff ff       	call   80102bcd <kfree>
8010422f:	83 c4 10             	add    $0x10,%esp
80104232:	eb 0f                	jmp    80104243 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104234:	8b 45 08             	mov    0x8(%ebp),%eax
80104237:	83 ec 0c             	sub    $0xc,%esp
8010423a:	50                   	push   %eax
8010423b:	e8 8b 0e 00 00       	call   801050cb <release>
80104240:	83 c4 10             	add    $0x10,%esp
}
80104243:	90                   	nop
80104244:	c9                   	leave  
80104245:	c3                   	ret    

80104246 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104246:	55                   	push   %ebp
80104247:	89 e5                	mov    %esp,%ebp
80104249:	53                   	push   %ebx
8010424a:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010424d:	8b 45 08             	mov    0x8(%ebp),%eax
80104250:	83 ec 0c             	sub    $0xc,%esp
80104253:	50                   	push   %eax
80104254:	e8 0b 0e 00 00       	call   80105064 <acquire>
80104259:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010425c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104263:	e9 ae 00 00 00       	jmp    80104316 <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104268:	8b 45 08             	mov    0x8(%ebp),%eax
8010426b:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104271:	85 c0                	test   %eax,%eax
80104273:	74 0d                	je     80104282 <pipewrite+0x3c>
80104275:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010427b:	8b 40 24             	mov    0x24(%eax),%eax
8010427e:	85 c0                	test   %eax,%eax
80104280:	74 19                	je     8010429b <pipewrite+0x55>
        release(&p->lock);
80104282:	8b 45 08             	mov    0x8(%ebp),%eax
80104285:	83 ec 0c             	sub    $0xc,%esp
80104288:	50                   	push   %eax
80104289:	e8 3d 0e 00 00       	call   801050cb <release>
8010428e:	83 c4 10             	add    $0x10,%esp
        return -1;
80104291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104296:	e9 a9 00 00 00       	jmp    80104344 <pipewrite+0xfe>
      }
      wakeup(&p->nread);
8010429b:	8b 45 08             	mov    0x8(%ebp),%eax
8010429e:	05 34 02 00 00       	add    $0x234,%eax
801042a3:	83 ec 0c             	sub    $0xc,%esp
801042a6:	50                   	push   %eax
801042a7:	e8 aa 0b 00 00       	call   80104e56 <wakeup>
801042ac:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042af:	8b 45 08             	mov    0x8(%ebp),%eax
801042b2:	8b 55 08             	mov    0x8(%ebp),%edx
801042b5:	81 c2 38 02 00 00    	add    $0x238,%edx
801042bb:	83 ec 08             	sub    $0x8,%esp
801042be:	50                   	push   %eax
801042bf:	52                   	push   %edx
801042c0:	e8 a6 0a 00 00       	call   80104d6b <sleep>
801042c5:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042c8:	8b 45 08             	mov    0x8(%ebp),%eax
801042cb:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042d1:	8b 45 08             	mov    0x8(%ebp),%eax
801042d4:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042da:	05 00 02 00 00       	add    $0x200,%eax
801042df:	39 c2                	cmp    %eax,%edx
801042e1:	74 85                	je     80104268 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801042e9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042ec:	8b 45 08             	mov    0x8(%ebp),%eax
801042ef:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f5:	8d 48 01             	lea    0x1(%eax),%ecx
801042f8:	8b 55 08             	mov    0x8(%ebp),%edx
801042fb:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104301:	25 ff 01 00 00       	and    $0x1ff,%eax
80104306:	89 c1                	mov    %eax,%ecx
80104308:	0f b6 13             	movzbl (%ebx),%edx
8010430b:	8b 45 08             	mov    0x8(%ebp),%eax
8010430e:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104312:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104319:	3b 45 10             	cmp    0x10(%ebp),%eax
8010431c:	7c aa                	jl     801042c8 <pipewrite+0x82>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010431e:	8b 45 08             	mov    0x8(%ebp),%eax
80104321:	05 34 02 00 00       	add    $0x234,%eax
80104326:	83 ec 0c             	sub    $0xc,%esp
80104329:	50                   	push   %eax
8010432a:	e8 27 0b 00 00       	call   80104e56 <wakeup>
8010432f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104332:	8b 45 08             	mov    0x8(%ebp),%eax
80104335:	83 ec 0c             	sub    $0xc,%esp
80104338:	50                   	push   %eax
80104339:	e8 8d 0d 00 00       	call   801050cb <release>
8010433e:	83 c4 10             	add    $0x10,%esp
  return n;
80104341:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104344:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104347:	c9                   	leave  
80104348:	c3                   	ret    

80104349 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104349:	55                   	push   %ebp
8010434a:	89 e5                	mov    %esp,%ebp
8010434c:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010434f:	8b 45 08             	mov    0x8(%ebp),%eax
80104352:	83 ec 0c             	sub    $0xc,%esp
80104355:	50                   	push   %eax
80104356:	e8 09 0d 00 00       	call   80105064 <acquire>
8010435b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010435e:	eb 3f                	jmp    8010439f <piperead+0x56>
    if(proc->killed){
80104360:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104366:	8b 40 24             	mov    0x24(%eax),%eax
80104369:	85 c0                	test   %eax,%eax
8010436b:	74 19                	je     80104386 <piperead+0x3d>
      release(&p->lock);
8010436d:	8b 45 08             	mov    0x8(%ebp),%eax
80104370:	83 ec 0c             	sub    $0xc,%esp
80104373:	50                   	push   %eax
80104374:	e8 52 0d 00 00       	call   801050cb <release>
80104379:	83 c4 10             	add    $0x10,%esp
      return -1;
8010437c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104381:	e9 be 00 00 00       	jmp    80104444 <piperead+0xfb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104386:	8b 45 08             	mov    0x8(%ebp),%eax
80104389:	8b 55 08             	mov    0x8(%ebp),%edx
8010438c:	81 c2 34 02 00 00    	add    $0x234,%edx
80104392:	83 ec 08             	sub    $0x8,%esp
80104395:	50                   	push   %eax
80104396:	52                   	push   %edx
80104397:	e8 cf 09 00 00       	call   80104d6b <sleep>
8010439c:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010439f:	8b 45 08             	mov    0x8(%ebp),%eax
801043a2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043a8:	8b 45 08             	mov    0x8(%ebp),%eax
801043ab:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043b1:	39 c2                	cmp    %eax,%edx
801043b3:	75 0d                	jne    801043c2 <piperead+0x79>
801043b5:	8b 45 08             	mov    0x8(%ebp),%eax
801043b8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043be:	85 c0                	test   %eax,%eax
801043c0:	75 9e                	jne    80104360 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043c9:	eb 48                	jmp    80104413 <piperead+0xca>
    if(p->nread == p->nwrite)
801043cb:	8b 45 08             	mov    0x8(%ebp),%eax
801043ce:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043d4:	8b 45 08             	mov    0x8(%ebp),%eax
801043d7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043dd:	39 c2                	cmp    %eax,%edx
801043df:	74 3c                	je     8010441d <piperead+0xd4>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043e1:	8b 45 08             	mov    0x8(%ebp),%eax
801043e4:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043ea:	8d 48 01             	lea    0x1(%eax),%ecx
801043ed:	8b 55 08             	mov    0x8(%ebp),%edx
801043f0:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043f6:	25 ff 01 00 00       	and    $0x1ff,%eax
801043fb:	89 c1                	mov    %eax,%ecx
801043fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104400:	8b 45 0c             	mov    0xc(%ebp),%eax
80104403:	01 c2                	add    %eax,%edx
80104405:	8b 45 08             	mov    0x8(%ebp),%eax
80104408:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010440d:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010440f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104416:	3b 45 10             	cmp    0x10(%ebp),%eax
80104419:	7c b0                	jl     801043cb <piperead+0x82>
8010441b:	eb 01                	jmp    8010441e <piperead+0xd5>
      break;
8010441d:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010441e:	8b 45 08             	mov    0x8(%ebp),%eax
80104421:	05 38 02 00 00       	add    $0x238,%eax
80104426:	83 ec 0c             	sub    $0xc,%esp
80104429:	50                   	push   %eax
8010442a:	e8 27 0a 00 00       	call   80104e56 <wakeup>
8010442f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104432:	8b 45 08             	mov    0x8(%ebp),%eax
80104435:	83 ec 0c             	sub    $0xc,%esp
80104438:	50                   	push   %eax
80104439:	e8 8d 0c 00 00       	call   801050cb <release>
8010443e:	83 c4 10             	add    $0x10,%esp
  return i;
80104441:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104444:	c9                   	leave  
80104445:	c3                   	ret    

80104446 <readeflags>:
{
80104446:	55                   	push   %ebp
80104447:	89 e5                	mov    %esp,%ebp
80104449:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010444c:	9c                   	pushf  
8010444d:	58                   	pop    %eax
8010444e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104451:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104454:	c9                   	leave  
80104455:	c3                   	ret    

80104456 <sti>:
{
80104456:	55                   	push   %ebp
80104457:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104459:	fb                   	sti    
}
8010445a:	90                   	nop
8010445b:	5d                   	pop    %ebp
8010445c:	c3                   	ret    

8010445d <halt>:
}

// CS550: to solve the 100%-CPU-utilization-when-idling problem - "hlt" instruction puts CPU to sleep
static inline void
halt()
{
8010445d:	55                   	push   %ebp
8010445e:	89 e5                	mov    %esp,%ebp
    asm volatile("hlt" : : :"memory");
80104460:	f4                   	hlt    
}
80104461:	90                   	nop
80104462:	5d                   	pop    %ebp
80104463:	c3                   	ret    

80104464 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104464:	55                   	push   %ebp
80104465:	89 e5                	mov    %esp,%ebp
80104467:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010446a:	83 ec 08             	sub    $0x8,%esp
8010446d:	68 5d 89 10 80       	push   $0x8010895d
80104472:	68 60 29 11 80       	push   $0x80112960
80104477:	e8 c6 0b 00 00       	call   80105042 <initlock>
8010447c:	83 c4 10             	add    $0x10,%esp
}
8010447f:	90                   	nop
80104480:	c9                   	leave  
80104481:	c3                   	ret    

80104482 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104482:	55                   	push   %ebp
80104483:	89 e5                	mov    %esp,%ebp
80104485:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104488:	83 ec 0c             	sub    $0xc,%esp
8010448b:	68 60 29 11 80       	push   $0x80112960
80104490:	e8 cf 0b 00 00       	call   80105064 <acquire>
80104495:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104498:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
8010449f:	eb 0e                	jmp    801044af <allocproc+0x2d>
    if(p->state == UNUSED)
801044a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a4:	8b 40 0c             	mov    0xc(%eax),%eax
801044a7:	85 c0                	test   %eax,%eax
801044a9:	74 27                	je     801044d2 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044ab:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044af:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
801044b6:	72 e9                	jb     801044a1 <allocproc+0x1f>
      goto found;
  release(&ptable.lock);
801044b8:	83 ec 0c             	sub    $0xc,%esp
801044bb:	68 60 29 11 80       	push   $0x80112960
801044c0:	e8 06 0c 00 00       	call   801050cb <release>
801044c5:	83 c4 10             	add    $0x10,%esp
  return 0;
801044c8:	b8 00 00 00 00       	mov    $0x0,%eax
801044cd:	e9 b4 00 00 00       	jmp    80104586 <allocproc+0x104>
      goto found;
801044d2:	90                   	nop

found:
  p->state = EMBRYO;
801044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d6:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044dd:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044e2:	8d 50 01             	lea    0x1(%eax),%edx
801044e5:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801044eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ee:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801044f1:	83 ec 0c             	sub    $0xc,%esp
801044f4:	68 60 29 11 80       	push   $0x80112960
801044f9:	e8 cd 0b 00 00       	call   801050cb <release>
801044fe:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104501:	e8 64 e7 ff ff       	call   80102c6a <kalloc>
80104506:	89 c2                	mov    %eax,%edx
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	89 50 08             	mov    %edx,0x8(%eax)
8010450e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104511:	8b 40 08             	mov    0x8(%eax),%eax
80104514:	85 c0                	test   %eax,%eax
80104516:	75 11                	jne    80104529 <allocproc+0xa7>
    p->state = UNUSED;
80104518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104522:	b8 00 00 00 00       	mov    $0x0,%eax
80104527:	eb 5d                	jmp    80104586 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	8b 40 08             	mov    0x8(%eax),%eax
8010452f:	05 00 10 00 00       	add    $0x1000,%eax
80104534:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104537:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104541:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104544:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104548:	ba 26 67 10 80       	mov    $0x80106726,%edx
8010454d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104550:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104552:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104559:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010455c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	8b 40 1c             	mov    0x1c(%eax),%eax
80104565:	83 ec 04             	sub    $0x4,%esp
80104568:	6a 14                	push   $0x14
8010456a:	6a 00                	push   $0x0
8010456c:	50                   	push   %eax
8010456d:	e8 55 0d 00 00       	call   801052c7 <memset>
80104572:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104578:	8b 40 1c             	mov    0x1c(%eax),%eax
8010457b:	ba 25 4d 10 80       	mov    $0x80104d25,%edx
80104580:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104583:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104586:	c9                   	leave  
80104587:	c3                   	ret    

80104588 <uprog_shut>:

void uprog_shut(){
80104588:	55                   	push   %ebp
80104589:	89 e5                	mov    %esp,%ebp
8010458b:	83 ec 08             	sub    $0x8,%esp
  return uprog_shut();
8010458e:	e8 f5 ff ff ff       	call   80104588 <uprog_shut>
}
80104593:	c9                   	leave  
80104594:	c3                   	ret    

80104595 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104595:	55                   	push   %ebp
80104596:	89 e5                	mov    %esp,%ebp
80104598:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010459b:	e8 e2 fe ff ff       	call   80104482 <allocproc>
801045a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a6:	a3 4c b6 10 80       	mov    %eax,0x8010b64c
  if((p->pgdir = setupkvm()) == 0)
801045ab:	e8 3d 38 00 00       	call   80107ded <setupkvm>
801045b0:	89 c2                	mov    %eax,%edx
801045b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b5:	89 50 04             	mov    %edx,0x4(%eax)
801045b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bb:	8b 40 04             	mov    0x4(%eax),%eax
801045be:	85 c0                	test   %eax,%eax
801045c0:	75 0d                	jne    801045cf <userinit+0x3a>
    panic("userinit: out of memory?");
801045c2:	83 ec 0c             	sub    $0xc,%esp
801045c5:	68 64 89 10 80       	push   $0x80108964
801045ca:	e8 98 bf ff ff       	call   80100567 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045cf:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d7:	8b 40 04             	mov    0x4(%eax),%eax
801045da:	83 ec 04             	sub    $0x4,%esp
801045dd:	52                   	push   %edx
801045de:	68 e0 b4 10 80       	push   $0x8010b4e0
801045e3:	50                   	push   %eax
801045e4:	e8 5f 3a 00 00       	call   80108048 <inituvm>
801045e9:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801045ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ef:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f8:	8b 40 18             	mov    0x18(%eax),%eax
801045fb:	83 ec 04             	sub    $0x4,%esp
801045fe:	6a 4c                	push   $0x4c
80104600:	6a 00                	push   $0x0
80104602:	50                   	push   %eax
80104603:	e8 bf 0c 00 00       	call   801052c7 <memset>
80104608:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010460b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460e:	8b 40 18             	mov    0x18(%eax),%eax
80104611:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461a:	8b 40 18             	mov    0x18(%eax),%eax
8010461d:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104626:	8b 50 18             	mov    0x18(%eax),%edx
80104629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462c:	8b 40 18             	mov    0x18(%eax),%eax
8010462f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104633:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463a:	8b 50 18             	mov    0x18(%eax),%edx
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	8b 40 18             	mov    0x18(%eax),%eax
80104643:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104647:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464e:	8b 40 18             	mov    0x18(%eax),%eax
80104651:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465b:	8b 40 18             	mov    0x18(%eax),%eax
8010465e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104668:	8b 40 18             	mov    0x18(%eax),%eax
8010466b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104675:	83 c0 6c             	add    $0x6c,%eax
80104678:	83 ec 04             	sub    $0x4,%esp
8010467b:	6a 10                	push   $0x10
8010467d:	68 7d 89 10 80       	push   $0x8010897d
80104682:	50                   	push   %eax
80104683:	e8 42 0e 00 00       	call   801054ca <safestrcpy>
80104688:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010468b:	83 ec 0c             	sub    $0xc,%esp
8010468e:	68 86 89 10 80       	push   $0x80108986
80104693:	e8 92 de ff ff       	call   8010252a <namei>
80104698:	83 c4 10             	add    $0x10,%esp
8010469b:	89 c2                	mov    %eax,%edx
8010469d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a0:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801046a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046ad:	90                   	nop
801046ae:	c9                   	leave  
801046af:	c3                   	ret    

801046b0 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046b0:	55                   	push   %ebp
801046b1:	89 e5                	mov    %esp,%ebp
801046b3:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046bc:	8b 00                	mov    (%eax),%eax
801046be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046c5:	7e 31                	jle    801046f8 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046c7:	8b 55 08             	mov    0x8(%ebp),%edx
801046ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cd:	01 c2                	add    %eax,%edx
801046cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d5:	8b 40 04             	mov    0x4(%eax),%eax
801046d8:	83 ec 04             	sub    $0x4,%esp
801046db:	52                   	push   %edx
801046dc:	ff 75 f4             	pushl  -0xc(%ebp)
801046df:	50                   	push   %eax
801046e0:	e8 b0 3a 00 00       	call   80108195 <allocuvm>
801046e5:	83 c4 10             	add    $0x10,%esp
801046e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046ef:	75 3e                	jne    8010472f <growproc+0x7f>
      return -1;
801046f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f6:	eb 59                	jmp    80104751 <growproc+0xa1>
  } else if(n < 0){
801046f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046fc:	79 31                	jns    8010472f <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801046fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	01 c2                	add    %eax,%edx
80104706:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470c:	8b 40 04             	mov    0x4(%eax),%eax
8010470f:	83 ec 04             	sub    $0x4,%esp
80104712:	52                   	push   %edx
80104713:	ff 75 f4             	pushl  -0xc(%ebp)
80104716:	50                   	push   %eax
80104717:	e8 42 3b 00 00       	call   8010825e <deallocuvm>
8010471c:	83 c4 10             	add    $0x10,%esp
8010471f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104722:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104726:	75 07                	jne    8010472f <growproc+0x7f>
      return -1;
80104728:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010472d:	eb 22                	jmp    80104751 <growproc+0xa1>
  }
  proc->sz = sz;
8010472f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104735:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104738:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010473a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104740:	83 ec 0c             	sub    $0xc,%esp
80104743:	50                   	push   %eax
80104744:	e8 8b 37 00 00       	call   80107ed4 <switchuvm>
80104749:	83 c4 10             	add    $0x10,%esp
  return 0;
8010474c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104751:	c9                   	leave  
80104752:	c3                   	ret    

80104753 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104753:	55                   	push   %ebp
80104754:	89 e5                	mov    %esp,%ebp
80104756:	57                   	push   %edi
80104757:	56                   	push   %esi
80104758:	53                   	push   %ebx
80104759:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010475c:	e8 21 fd ff ff       	call   80104482 <allocproc>
80104761:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104764:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104768:	75 0a                	jne    80104774 <fork+0x21>
    return -1;
8010476a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476f:	e9 6a 01 00 00       	jmp    801048de <fork+0x18b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104774:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477a:	8b 10                	mov    (%eax),%edx
8010477c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104782:	8b 40 04             	mov    0x4(%eax),%eax
80104785:	83 ec 08             	sub    $0x8,%esp
80104788:	52                   	push   %edx
80104789:	50                   	push   %eax
8010478a:	e8 6d 3c 00 00       	call   801083fc <copyuvm>
8010478f:	83 c4 10             	add    $0x10,%esp
80104792:	89 c2                	mov    %eax,%edx
80104794:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104797:	89 50 04             	mov    %edx,0x4(%eax)
8010479a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479d:	8b 40 04             	mov    0x4(%eax),%eax
801047a0:	85 c0                	test   %eax,%eax
801047a2:	75 30                	jne    801047d4 <fork+0x81>
    kfree(np->kstack);
801047a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a7:	8b 40 08             	mov    0x8(%eax),%eax
801047aa:	83 ec 0c             	sub    $0xc,%esp
801047ad:	50                   	push   %eax
801047ae:	e8 1a e4 ff ff       	call   80102bcd <kfree>
801047b3:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047cf:	e9 0a 01 00 00       	jmp    801048de <fork+0x18b>
  }
  np->sz = proc->sz;
801047d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047da:	8b 10                	mov    (%eax),%edx
801047dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047df:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801047e1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047eb:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801047ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f4:	8b 48 18             	mov    0x18(%eax),%ecx
801047f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047fa:	8b 40 18             	mov    0x18(%eax),%eax
801047fd:	89 c2                	mov    %eax,%edx
801047ff:	89 cb                	mov    %ecx,%ebx
80104801:	b8 13 00 00 00       	mov    $0x13,%eax
80104806:	89 d7                	mov    %edx,%edi
80104808:	89 de                	mov    %ebx,%esi
8010480a:	89 c1                	mov    %eax,%ecx
8010480c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010480e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104811:	8b 40 18             	mov    0x18(%eax),%eax
80104814:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010481b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104822:	eb 43                	jmp    80104867 <fork+0x114>
    if(proc->ofile[i])
80104824:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010482a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010482d:	83 c2 08             	add    $0x8,%edx
80104830:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104834:	85 c0                	test   %eax,%eax
80104836:	74 2b                	je     80104863 <fork+0x110>
      np->ofile[i] = filedup(proc->ofile[i]);
80104838:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104841:	83 c2 08             	add    $0x8,%edx
80104844:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104848:	83 ec 0c             	sub    $0xc,%esp
8010484b:	50                   	push   %eax
8010484c:	e8 ba c7 ff ff       	call   8010100b <filedup>
80104851:	83 c4 10             	add    $0x10,%esp
80104854:	89 c1                	mov    %eax,%ecx
80104856:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104859:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010485c:	83 c2 08             	add    $0x8,%edx
8010485f:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  for(i = 0; i < NOFILE; i++)
80104863:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104867:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010486b:	7e b7                	jle    80104824 <fork+0xd1>
  np->cwd = idup(proc->cwd);
8010486d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104873:	8b 40 68             	mov    0x68(%eax),%eax
80104876:	83 ec 0c             	sub    $0xc,%esp
80104879:	50                   	push   %eax
8010487a:	e8 bc d0 ff ff       	call   8010193b <idup>
8010487f:	83 c4 10             	add    $0x10,%esp
80104882:	89 c2                	mov    %eax,%edx
80104884:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104887:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010488a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104890:	8d 50 6c             	lea    0x6c(%eax),%edx
80104893:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104896:	83 c0 6c             	add    $0x6c,%eax
80104899:	83 ec 04             	sub    $0x4,%esp
8010489c:	6a 10                	push   $0x10
8010489e:	52                   	push   %edx
8010489f:	50                   	push   %eax
801048a0:	e8 25 0c 00 00       	call   801054ca <safestrcpy>
801048a5:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ab:	8b 40 10             	mov    0x10(%eax),%eax
801048ae:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048b1:	83 ec 0c             	sub    $0xc,%esp
801048b4:	68 60 29 11 80       	push   $0x80112960
801048b9:	e8 a6 07 00 00       	call   80105064 <acquire>
801048be:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048cb:	83 ec 0c             	sub    $0xc,%esp
801048ce:	68 60 29 11 80       	push   $0x80112960
801048d3:	e8 f3 07 00 00       	call   801050cb <release>
801048d8:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048db:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048de:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048e1:	5b                   	pop    %ebx
801048e2:	5e                   	pop    %esi
801048e3:	5f                   	pop    %edi
801048e4:	5d                   	pop    %ebp
801048e5:	c3                   	ret    

801048e6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048e6:	55                   	push   %ebp
801048e7:	89 e5                	mov    %esp,%ebp
801048e9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801048ec:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048f3:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
801048f8:	39 c2                	cmp    %eax,%edx
801048fa:	75 0d                	jne    80104909 <exit+0x23>
    panic("init exiting");
801048fc:	83 ec 0c             	sub    $0xc,%esp
801048ff:	68 88 89 10 80       	push   $0x80108988
80104904:	e8 5e bc ff ff       	call   80100567 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104909:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104910:	eb 48                	jmp    8010495a <exit+0x74>
    if(proc->ofile[fd]){
80104912:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104918:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010491b:	83 c2 08             	add    $0x8,%edx
8010491e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104922:	85 c0                	test   %eax,%eax
80104924:	74 30                	je     80104956 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104926:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010492f:	83 c2 08             	add    $0x8,%edx
80104932:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104936:	83 ec 0c             	sub    $0xc,%esp
80104939:	50                   	push   %eax
8010493a:	e8 1d c7 ff ff       	call   8010105c <fileclose>
8010493f:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104948:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494b:	83 c2 08             	add    $0x8,%edx
8010494e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104955:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104956:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010495a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010495e:	7e b2                	jle    80104912 <exit+0x2c>
    }
  }

  begin_op();
80104960:	e8 f1 eb ff ff       	call   80103556 <begin_op>
  iput(proc->cwd);
80104965:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496b:	8b 40 68             	mov    0x68(%eax),%eax
8010496e:	83 ec 0c             	sub    $0xc,%esp
80104971:	50                   	push   %eax
80104972:	e8 ce d1 ff ff       	call   80101b45 <iput>
80104977:	83 c4 10             	add    $0x10,%esp
  end_op();
8010497a:	e8 63 ec ff ff       	call   801035e2 <end_op>
  proc->cwd = 0;
8010497f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104985:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010498c:	83 ec 0c             	sub    $0xc,%esp
8010498f:	68 60 29 11 80       	push   $0x80112960
80104994:	e8 cb 06 00 00       	call   80105064 <acquire>
80104999:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010499c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a2:	8b 40 14             	mov    0x14(%eax),%eax
801049a5:	83 ec 0c             	sub    $0xc,%esp
801049a8:	50                   	push   %eax
801049a9:	e8 69 04 00 00       	call   80104e17 <wakeup1>
801049ae:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b1:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801049b8:	eb 3c                	jmp    801049f6 <exit+0x110>
    if(p->parent == proc){
801049ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bd:	8b 50 14             	mov    0x14(%eax),%edx
801049c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c6:	39 c2                	cmp    %eax,%edx
801049c8:	75 28                	jne    801049f2 <exit+0x10c>
      p->parent = initproc;
801049ca:	8b 15 4c b6 10 80    	mov    0x8010b64c,%edx
801049d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d3:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d9:	8b 40 0c             	mov    0xc(%eax),%eax
801049dc:	83 f8 05             	cmp    $0x5,%eax
801049df:	75 11                	jne    801049f2 <exit+0x10c>
        wakeup1(initproc);
801049e1:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
801049e6:	83 ec 0c             	sub    $0xc,%esp
801049e9:	50                   	push   %eax
801049ea:	e8 28 04 00 00       	call   80104e17 <wakeup1>
801049ef:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f2:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801049f6:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
801049fd:	72 bb                	jb     801049ba <exit+0xd4>
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801049ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a05:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a0c:	e8 fa 01 00 00       	call   80104c0b <sched>
  panic("zombie exit");
80104a11:	83 ec 0c             	sub    $0xc,%esp
80104a14:	68 95 89 10 80       	push   $0x80108995
80104a19:	e8 49 bb ff ff       	call   80100567 <panic>

80104a1e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a1e:	55                   	push   %ebp
80104a1f:	89 e5                	mov    %esp,%ebp
80104a21:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a24:	83 ec 0c             	sub    $0xc,%esp
80104a27:	68 60 29 11 80       	push   $0x80112960
80104a2c:	e8 33 06 00 00       	call   80105064 <acquire>
80104a31:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a3b:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a42:	e9 a6 00 00 00       	jmp    80104aed <wait+0xcf>
      if(p->parent != proc)
80104a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4a:	8b 50 14             	mov    0x14(%eax),%edx
80104a4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a53:	39 c2                	cmp    %eax,%edx
80104a55:	0f 85 8d 00 00 00    	jne    80104ae8 <wait+0xca>
        continue;
      havekids = 1;
80104a5b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a65:	8b 40 0c             	mov    0xc(%eax),%eax
80104a68:	83 f8 05             	cmp    $0x5,%eax
80104a6b:	75 7c                	jne    80104ae9 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a70:	8b 40 10             	mov    0x10(%eax),%eax
80104a73:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a79:	8b 40 08             	mov    0x8(%eax),%eax
80104a7c:	83 ec 0c             	sub    $0xc,%esp
80104a7f:	50                   	push   %eax
80104a80:	e8 48 e1 ff ff       	call   80102bcd <kfree>
80104a85:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a95:	8b 40 04             	mov    0x4(%eax),%eax
80104a98:	83 ec 0c             	sub    $0xc,%esp
80104a9b:	50                   	push   %eax
80104a9c:	e8 7a 38 00 00       	call   8010831b <freevm>
80104aa1:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac5:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acc:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104ad3:	83 ec 0c             	sub    $0xc,%esp
80104ad6:	68 60 29 11 80       	push   $0x80112960
80104adb:	e8 eb 05 00 00       	call   801050cb <release>
80104ae0:	83 c4 10             	add    $0x10,%esp
        return pid;
80104ae3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ae6:	eb 58                	jmp    80104b40 <wait+0x122>
        continue;
80104ae8:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ae9:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104aed:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104af4:	0f 82 4d ff ff ff    	jb     80104a47 <wait+0x29>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104afa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104afe:	74 0d                	je     80104b0d <wait+0xef>
80104b00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b06:	8b 40 24             	mov    0x24(%eax),%eax
80104b09:	85 c0                	test   %eax,%eax
80104b0b:	74 17                	je     80104b24 <wait+0x106>
      release(&ptable.lock);
80104b0d:	83 ec 0c             	sub    $0xc,%esp
80104b10:	68 60 29 11 80       	push   $0x80112960
80104b15:	e8 b1 05 00 00       	call   801050cb <release>
80104b1a:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b22:	eb 1c                	jmp    80104b40 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2a:	83 ec 08             	sub    $0x8,%esp
80104b2d:	68 60 29 11 80       	push   $0x80112960
80104b32:	50                   	push   %eax
80104b33:	e8 33 02 00 00       	call   80104d6b <sleep>
80104b38:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104b3b:	e9 f4 fe ff ff       	jmp    80104a34 <wait+0x16>
  }
}
80104b40:	c9                   	leave  
80104b41:	c3                   	ret    

80104b42 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b42:	55                   	push   %ebp
80104b43:	89 e5                	mov    %esp,%ebp
80104b45:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int ran = 0; // CS550: to solve the 100%-CPU-utilization-when-idling problem
80104b48:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b4f:	e8 02 f9 ff ff       	call   80104456 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b54:	83 ec 0c             	sub    $0xc,%esp
80104b57:	68 60 29 11 80       	push   $0x80112960
80104b5c:	e8 03 05 00 00       	call   80105064 <acquire>
80104b61:	83 c4 10             	add    $0x10,%esp
    ran = 0;
80104b64:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b6b:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104b72:	eb 6a                	jmp    80104bde <scheduler+0x9c>
      if(p->state != RUNNABLE)
80104b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b77:	8b 40 0c             	mov    0xc(%eax),%eax
80104b7a:	83 f8 03             	cmp    $0x3,%eax
80104b7d:	75 5a                	jne    80104bd9 <scheduler+0x97>
        continue;

      ran = 1;
80104b7f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b89:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b8f:	83 ec 0c             	sub    $0xc,%esp
80104b92:	ff 75 f4             	pushl  -0xc(%ebp)
80104b95:	e8 3a 33 00 00       	call   80107ed4 <switchuvm>
80104b9a:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba0:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104ba7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bad:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bb0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bb7:	83 c2 04             	add    $0x4,%edx
80104bba:	83 ec 08             	sub    $0x8,%esp
80104bbd:	50                   	push   %eax
80104bbe:	52                   	push   %edx
80104bbf:	e8 77 09 00 00       	call   8010553b <swtch>
80104bc4:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104bc7:	e8 eb 32 00 00       	call   80107eb7 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104bcc:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104bd3:	00 00 00 00 
80104bd7:	eb 01                	jmp    80104bda <scheduler+0x98>
        continue;
80104bd9:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bda:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104bde:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104be5:	72 8d                	jb     80104b74 <scheduler+0x32>
    }
    release(&ptable.lock);
80104be7:	83 ec 0c             	sub    $0xc,%esp
80104bea:	68 60 29 11 80       	push   $0x80112960
80104bef:	e8 d7 04 00 00       	call   801050cb <release>
80104bf4:	83 c4 10             	add    $0x10,%esp

    if (ran == 0){
80104bf7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bfb:	0f 85 4e ff ff ff    	jne    80104b4f <scheduler+0xd>
        halt();
80104c01:	e8 57 f8 ff ff       	call   8010445d <halt>
    sti();
80104c06:	e9 44 ff ff ff       	jmp    80104b4f <scheduler+0xd>

80104c0b <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c0b:	55                   	push   %ebp
80104c0c:	89 e5                	mov    %esp,%ebp
80104c0e:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c11:	83 ec 0c             	sub    $0xc,%esp
80104c14:	68 60 29 11 80       	push   $0x80112960
80104c19:	e8 79 05 00 00       	call   80105197 <holding>
80104c1e:	83 c4 10             	add    $0x10,%esp
80104c21:	85 c0                	test   %eax,%eax
80104c23:	75 0d                	jne    80104c32 <sched+0x27>
    panic("sched ptable.lock");
80104c25:	83 ec 0c             	sub    $0xc,%esp
80104c28:	68 a1 89 10 80       	push   $0x801089a1
80104c2d:	e8 35 b9 ff ff       	call   80100567 <panic>
  if(cpu->ncli != 1)
80104c32:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c38:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c3e:	83 f8 01             	cmp    $0x1,%eax
80104c41:	74 0d                	je     80104c50 <sched+0x45>
    panic("sched locks");
80104c43:	83 ec 0c             	sub    $0xc,%esp
80104c46:	68 b3 89 10 80       	push   $0x801089b3
80104c4b:	e8 17 b9 ff ff       	call   80100567 <panic>
  if(proc->state == RUNNING)
80104c50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c56:	8b 40 0c             	mov    0xc(%eax),%eax
80104c59:	83 f8 04             	cmp    $0x4,%eax
80104c5c:	75 0d                	jne    80104c6b <sched+0x60>
    panic("sched running");
80104c5e:	83 ec 0c             	sub    $0xc,%esp
80104c61:	68 bf 89 10 80       	push   $0x801089bf
80104c66:	e8 fc b8 ff ff       	call   80100567 <panic>
  if(readeflags()&FL_IF)
80104c6b:	e8 d6 f7 ff ff       	call   80104446 <readeflags>
80104c70:	25 00 02 00 00       	and    $0x200,%eax
80104c75:	85 c0                	test   %eax,%eax
80104c77:	74 0d                	je     80104c86 <sched+0x7b>
    panic("sched interruptible");
80104c79:	83 ec 0c             	sub    $0xc,%esp
80104c7c:	68 cd 89 10 80       	push   $0x801089cd
80104c81:	e8 e1 b8 ff ff       	call   80100567 <panic>
  intena = cpu->intena;
80104c86:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c8c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c92:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104c95:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c9b:	8b 40 04             	mov    0x4(%eax),%eax
80104c9e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ca5:	83 c2 1c             	add    $0x1c,%edx
80104ca8:	83 ec 08             	sub    $0x8,%esp
80104cab:	50                   	push   %eax
80104cac:	52                   	push   %edx
80104cad:	e8 89 08 00 00       	call   8010553b <swtch>
80104cb2:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104cb5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cbe:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cc4:	90                   	nop
80104cc5:	c9                   	leave  
80104cc6:	c3                   	ret    

80104cc7 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104cc7:	55                   	push   %ebp
80104cc8:	89 e5                	mov    %esp,%ebp
80104cca:	83 ec 08             	sub    $0x8,%esp
  if (sched_trace_enabled)
80104ccd:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104cd2:	85 c0                	test   %eax,%eax
80104cd4:	74 1a                	je     80104cf0 <yield+0x29>
  {
    cprintf("[%d]", proc->pid);
80104cd6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cdc:	8b 40 10             	mov    0x10(%eax),%eax
80104cdf:	83 ec 08             	sub    $0x8,%esp
80104ce2:	50                   	push   %eax
80104ce3:	68 e1 89 10 80       	push   $0x801089e1
80104ce8:	e8 d7 b6 ff ff       	call   801003c4 <cprintf>
80104ced:	83 c4 10             	add    $0x10,%esp
  }

  acquire(&ptable.lock);  //DOC: yieldlock
80104cf0:	83 ec 0c             	sub    $0xc,%esp
80104cf3:	68 60 29 11 80       	push   $0x80112960
80104cf8:	e8 67 03 00 00       	call   80105064 <acquire>
80104cfd:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104d00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d06:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d0d:	e8 f9 fe ff ff       	call   80104c0b <sched>
  release(&ptable.lock);
80104d12:	83 ec 0c             	sub    $0xc,%esp
80104d15:	68 60 29 11 80       	push   $0x80112960
80104d1a:	e8 ac 03 00 00       	call   801050cb <release>
80104d1f:	83 c4 10             	add    $0x10,%esp
}
80104d22:	90                   	nop
80104d23:	c9                   	leave  
80104d24:	c3                   	ret    

80104d25 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d25:	55                   	push   %ebp
80104d26:	89 e5                	mov    %esp,%ebp
80104d28:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d2b:	83 ec 0c             	sub    $0xc,%esp
80104d2e:	68 60 29 11 80       	push   $0x80112960
80104d33:	e8 93 03 00 00       	call   801050cb <release>
80104d38:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d3b:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d40:	85 c0                	test   %eax,%eax
80104d42:	74 24                	je     80104d68 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d44:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d4b:	00 00 00 
    iinit(ROOTDEV);
80104d4e:	83 ec 0c             	sub    $0xc,%esp
80104d51:	6a 01                	push   $0x1
80104d53:	e8 f1 c8 ff ff       	call   80101649 <iinit>
80104d58:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104d5b:	83 ec 0c             	sub    $0xc,%esp
80104d5e:	6a 01                	push   $0x1
80104d60:	e8 d3 e5 ff ff       	call   80103338 <initlog>
80104d65:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d68:	90                   	nop
80104d69:	c9                   	leave  
80104d6a:	c3                   	ret    

80104d6b <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d6b:	55                   	push   %ebp
80104d6c:	89 e5                	mov    %esp,%ebp
80104d6e:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d77:	85 c0                	test   %eax,%eax
80104d79:	75 0d                	jne    80104d88 <sleep+0x1d>
    panic("sleep");
80104d7b:	83 ec 0c             	sub    $0xc,%esp
80104d7e:	68 e6 89 10 80       	push   $0x801089e6
80104d83:	e8 df b7 ff ff       	call   80100567 <panic>

  if(lk == 0)
80104d88:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d8c:	75 0d                	jne    80104d9b <sleep+0x30>
    panic("sleep without lk");
80104d8e:	83 ec 0c             	sub    $0xc,%esp
80104d91:	68 ec 89 10 80       	push   $0x801089ec
80104d96:	e8 cc b7 ff ff       	call   80100567 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d9b:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104da2:	74 1e                	je     80104dc2 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104da4:	83 ec 0c             	sub    $0xc,%esp
80104da7:	68 60 29 11 80       	push   $0x80112960
80104dac:	e8 b3 02 00 00       	call   80105064 <acquire>
80104db1:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104db4:	83 ec 0c             	sub    $0xc,%esp
80104db7:	ff 75 0c             	pushl  0xc(%ebp)
80104dba:	e8 0c 03 00 00       	call   801050cb <release>
80104dbf:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104dc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc8:	8b 55 08             	mov    0x8(%ebp),%edx
80104dcb:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104dce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd4:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104ddb:	e8 2b fe ff ff       	call   80104c0b <sched>

  // Tidy up.
  proc->chan = 0;
80104de0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de6:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ded:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104df4:	74 1e                	je     80104e14 <sleep+0xa9>
    release(&ptable.lock);
80104df6:	83 ec 0c             	sub    $0xc,%esp
80104df9:	68 60 29 11 80       	push   $0x80112960
80104dfe:	e8 c8 02 00 00       	call   801050cb <release>
80104e03:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104e06:	83 ec 0c             	sub    $0xc,%esp
80104e09:	ff 75 0c             	pushl  0xc(%ebp)
80104e0c:	e8 53 02 00 00       	call   80105064 <acquire>
80104e11:	83 c4 10             	add    $0x10,%esp
  }
}
80104e14:	90                   	nop
80104e15:	c9                   	leave  
80104e16:	c3                   	ret    

80104e17 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e17:	55                   	push   %ebp
80104e18:	89 e5                	mov    %esp,%ebp
80104e1a:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e1d:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104e24:	eb 24                	jmp    80104e4a <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104e26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e29:	8b 40 0c             	mov    0xc(%eax),%eax
80104e2c:	83 f8 02             	cmp    $0x2,%eax
80104e2f:	75 15                	jne    80104e46 <wakeup1+0x2f>
80104e31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e34:	8b 40 20             	mov    0x20(%eax),%eax
80104e37:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e3a:	75 0a                	jne    80104e46 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e3f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e46:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e4a:	81 7d fc 94 48 11 80 	cmpl   $0x80114894,-0x4(%ebp)
80104e51:	72 d3                	jb     80104e26 <wakeup1+0xf>
}
80104e53:	90                   	nop
80104e54:	c9                   	leave  
80104e55:	c3                   	ret    

80104e56 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e56:	55                   	push   %ebp
80104e57:	89 e5                	mov    %esp,%ebp
80104e59:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e5c:	83 ec 0c             	sub    $0xc,%esp
80104e5f:	68 60 29 11 80       	push   $0x80112960
80104e64:	e8 fb 01 00 00       	call   80105064 <acquire>
80104e69:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e6c:	83 ec 0c             	sub    $0xc,%esp
80104e6f:	ff 75 08             	pushl  0x8(%ebp)
80104e72:	e8 a0 ff ff ff       	call   80104e17 <wakeup1>
80104e77:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e7a:	83 ec 0c             	sub    $0xc,%esp
80104e7d:	68 60 29 11 80       	push   $0x80112960
80104e82:	e8 44 02 00 00       	call   801050cb <release>
80104e87:	83 c4 10             	add    $0x10,%esp
}
80104e8a:	90                   	nop
80104e8b:	c9                   	leave  
80104e8c:	c3                   	ret    

80104e8d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e8d:	55                   	push   %ebp
80104e8e:	89 e5                	mov    %esp,%ebp
80104e90:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e93:	83 ec 0c             	sub    $0xc,%esp
80104e96:	68 60 29 11 80       	push   $0x80112960
80104e9b:	e8 c4 01 00 00       	call   80105064 <acquire>
80104ea0:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea3:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104eaa:	eb 45                	jmp    80104ef1 <kill+0x64>
    if(p->pid == pid){
80104eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eaf:	8b 40 10             	mov    0x10(%eax),%eax
80104eb2:	39 45 08             	cmp    %eax,0x8(%ebp)
80104eb5:	75 36                	jne    80104eed <kill+0x60>
      p->killed = 1;
80104eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eba:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec7:	83 f8 02             	cmp    $0x2,%eax
80104eca:	75 0a                	jne    80104ed6 <kill+0x49>
        p->state = RUNNABLE;
80104ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ed6:	83 ec 0c             	sub    $0xc,%esp
80104ed9:	68 60 29 11 80       	push   $0x80112960
80104ede:	e8 e8 01 00 00       	call   801050cb <release>
80104ee3:	83 c4 10             	add    $0x10,%esp
      return 0;
80104ee6:	b8 00 00 00 00       	mov    $0x0,%eax
80104eeb:	eb 22                	jmp    80104f0f <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eed:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ef1:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104ef8:	72 b2                	jb     80104eac <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104efa:	83 ec 0c             	sub    $0xc,%esp
80104efd:	68 60 29 11 80       	push   $0x80112960
80104f02:	e8 c4 01 00 00       	call   801050cb <release>
80104f07:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f0f:	c9                   	leave  
80104f10:	c3                   	ret    

80104f11 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f11:	55                   	push   %ebp
80104f12:	89 e5                	mov    %esp,%ebp
80104f14:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f17:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104f1e:	e9 d7 00 00 00       	jmp    80104ffa <procdump+0xe9>
    if(p->state == UNUSED)
80104f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f26:	8b 40 0c             	mov    0xc(%eax),%eax
80104f29:	85 c0                	test   %eax,%eax
80104f2b:	0f 84 c4 00 00 00    	je     80104ff5 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f34:	8b 40 0c             	mov    0xc(%eax),%eax
80104f37:	83 f8 05             	cmp    $0x5,%eax
80104f3a:	77 23                	ja     80104f5f <procdump+0x4e>
80104f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f3f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f42:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f49:	85 c0                	test   %eax,%eax
80104f4b:	74 12                	je     80104f5f <procdump+0x4e>
      state = states[p->state];
80104f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f50:	8b 40 0c             	mov    0xc(%eax),%eax
80104f53:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f5d:	eb 07                	jmp    80104f66 <procdump+0x55>
    else
      state = "???";
80104f5f:	c7 45 ec fd 89 10 80 	movl   $0x801089fd,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f69:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6f:	8b 40 10             	mov    0x10(%eax),%eax
80104f72:	52                   	push   %edx
80104f73:	ff 75 ec             	pushl  -0x14(%ebp)
80104f76:	50                   	push   %eax
80104f77:	68 01 8a 10 80       	push   $0x80108a01
80104f7c:	e8 43 b4 ff ff       	call   801003c4 <cprintf>
80104f81:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f87:	8b 40 0c             	mov    0xc(%eax),%eax
80104f8a:	83 f8 02             	cmp    $0x2,%eax
80104f8d:	75 54                	jne    80104fe3 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f92:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f95:	8b 40 0c             	mov    0xc(%eax),%eax
80104f98:	83 c0 08             	add    $0x8,%eax
80104f9b:	89 c2                	mov    %eax,%edx
80104f9d:	83 ec 08             	sub    $0x8,%esp
80104fa0:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104fa3:	50                   	push   %eax
80104fa4:	52                   	push   %edx
80104fa5:	e8 73 01 00 00       	call   8010511d <getcallerpcs>
80104faa:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fb4:	eb 1c                	jmp    80104fd2 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fbd:	83 ec 08             	sub    $0x8,%esp
80104fc0:	50                   	push   %eax
80104fc1:	68 0a 8a 10 80       	push   $0x80108a0a
80104fc6:	e8 f9 b3 ff ff       	call   801003c4 <cprintf>
80104fcb:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fd2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104fd6:	7f 0b                	jg     80104fe3 <procdump+0xd2>
80104fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fdf:	85 c0                	test   %eax,%eax
80104fe1:	75 d3                	jne    80104fb6 <procdump+0xa5>
    }
    cprintf("\n");
80104fe3:	83 ec 0c             	sub    $0xc,%esp
80104fe6:	68 0e 8a 10 80       	push   $0x80108a0e
80104feb:	e8 d4 b3 ff ff       	call   801003c4 <cprintf>
80104ff0:	83 c4 10             	add    $0x10,%esp
80104ff3:	eb 01                	jmp    80104ff6 <procdump+0xe5>
      continue;
80104ff5:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff6:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104ffa:	81 7d f0 94 48 11 80 	cmpl   $0x80114894,-0x10(%ebp)
80105001:	0f 82 1c ff ff ff    	jb     80104f23 <procdump+0x12>
  }
}
80105007:	90                   	nop
80105008:	c9                   	leave  
80105009:	c3                   	ret    

8010500a <readeflags>:
{
8010500a:	55                   	push   %ebp
8010500b:	89 e5                	mov    %esp,%ebp
8010500d:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105010:	9c                   	pushf  
80105011:	58                   	pop    %eax
80105012:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105015:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105018:	c9                   	leave  
80105019:	c3                   	ret    

8010501a <cli>:
{
8010501a:	55                   	push   %ebp
8010501b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010501d:	fa                   	cli    
}
8010501e:	90                   	nop
8010501f:	5d                   	pop    %ebp
80105020:	c3                   	ret    

80105021 <sti>:
{
80105021:	55                   	push   %ebp
80105022:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105024:	fb                   	sti    
}
80105025:	90                   	nop
80105026:	5d                   	pop    %ebp
80105027:	c3                   	ret    

80105028 <xchg>:
{
80105028:	55                   	push   %ebp
80105029:	89 e5                	mov    %esp,%ebp
8010502b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010502e:	8b 55 08             	mov    0x8(%ebp),%edx
80105031:	8b 45 0c             	mov    0xc(%ebp),%eax
80105034:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105037:	f0 87 02             	lock xchg %eax,(%edx)
8010503a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010503d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105040:	c9                   	leave  
80105041:	c3                   	ret    

80105042 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105042:	55                   	push   %ebp
80105043:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105045:	8b 45 08             	mov    0x8(%ebp),%eax
80105048:	8b 55 0c             	mov    0xc(%ebp),%edx
8010504b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010504e:	8b 45 08             	mov    0x8(%ebp),%eax
80105051:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105057:	8b 45 08             	mov    0x8(%ebp),%eax
8010505a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105061:	90                   	nop
80105062:	5d                   	pop    %ebp
80105063:	c3                   	ret    

80105064 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105064:	55                   	push   %ebp
80105065:	89 e5                	mov    %esp,%ebp
80105067:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010506a:	e8 52 01 00 00       	call   801051c1 <pushcli>
  if(holding(lk))
8010506f:	8b 45 08             	mov    0x8(%ebp),%eax
80105072:	83 ec 0c             	sub    $0xc,%esp
80105075:	50                   	push   %eax
80105076:	e8 1c 01 00 00       	call   80105197 <holding>
8010507b:	83 c4 10             	add    $0x10,%esp
8010507e:	85 c0                	test   %eax,%eax
80105080:	74 0d                	je     8010508f <acquire+0x2b>
    panic("acquire");
80105082:	83 ec 0c             	sub    $0xc,%esp
80105085:	68 3a 8a 10 80       	push   $0x80108a3a
8010508a:	e8 d8 b4 ff ff       	call   80100567 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010508f:	90                   	nop
80105090:	8b 45 08             	mov    0x8(%ebp),%eax
80105093:	83 ec 08             	sub    $0x8,%esp
80105096:	6a 01                	push   $0x1
80105098:	50                   	push   %eax
80105099:	e8 8a ff ff ff       	call   80105028 <xchg>
8010509e:	83 c4 10             	add    $0x10,%esp
801050a1:	85 c0                	test   %eax,%eax
801050a3:	75 eb                	jne    80105090 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050a5:	8b 45 08             	mov    0x8(%ebp),%eax
801050a8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050af:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050b2:	8b 45 08             	mov    0x8(%ebp),%eax
801050b5:	83 c0 0c             	add    $0xc,%eax
801050b8:	83 ec 08             	sub    $0x8,%esp
801050bb:	50                   	push   %eax
801050bc:	8d 45 08             	lea    0x8(%ebp),%eax
801050bf:	50                   	push   %eax
801050c0:	e8 58 00 00 00       	call   8010511d <getcallerpcs>
801050c5:	83 c4 10             	add    $0x10,%esp
}
801050c8:	90                   	nop
801050c9:	c9                   	leave  
801050ca:	c3                   	ret    

801050cb <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050cb:	55                   	push   %ebp
801050cc:	89 e5                	mov    %esp,%ebp
801050ce:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050d1:	83 ec 0c             	sub    $0xc,%esp
801050d4:	ff 75 08             	pushl  0x8(%ebp)
801050d7:	e8 bb 00 00 00       	call   80105197 <holding>
801050dc:	83 c4 10             	add    $0x10,%esp
801050df:	85 c0                	test   %eax,%eax
801050e1:	75 0d                	jne    801050f0 <release+0x25>
    panic("release");
801050e3:	83 ec 0c             	sub    $0xc,%esp
801050e6:	68 42 8a 10 80       	push   $0x80108a42
801050eb:	e8 77 b4 ff ff       	call   80100567 <panic>

  lk->pcs[0] = 0;
801050f0:	8b 45 08             	mov    0x8(%ebp),%eax
801050f3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050fa:	8b 45 08             	mov    0x8(%ebp),%eax
801050fd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105104:	8b 45 08             	mov    0x8(%ebp),%eax
80105107:	83 ec 08             	sub    $0x8,%esp
8010510a:	6a 00                	push   $0x0
8010510c:	50                   	push   %eax
8010510d:	e8 16 ff ff ff       	call   80105028 <xchg>
80105112:	83 c4 10             	add    $0x10,%esp

  popcli();
80105115:	e8 ec 00 00 00       	call   80105206 <popcli>
}
8010511a:	90                   	nop
8010511b:	c9                   	leave  
8010511c:	c3                   	ret    

8010511d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010511d:	55                   	push   %ebp
8010511e:	89 e5                	mov    %esp,%ebp
80105120:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105123:	8b 45 08             	mov    0x8(%ebp),%eax
80105126:	83 e8 08             	sub    $0x8,%eax
80105129:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010512c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105133:	eb 38                	jmp    8010516d <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105135:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105139:	74 53                	je     8010518e <getcallerpcs+0x71>
8010513b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105142:	76 4a                	jbe    8010518e <getcallerpcs+0x71>
80105144:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105148:	74 44                	je     8010518e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010514a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010514d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105154:	8b 45 0c             	mov    0xc(%ebp),%eax
80105157:	01 c2                	add    %eax,%edx
80105159:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010515c:	8b 40 04             	mov    0x4(%eax),%eax
8010515f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105161:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105164:	8b 00                	mov    (%eax),%eax
80105166:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105169:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010516d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105171:	7e c2                	jle    80105135 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105173:	eb 19                	jmp    8010518e <getcallerpcs+0x71>
    pcs[i] = 0;
80105175:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105178:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010517f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105182:	01 d0                	add    %edx,%eax
80105184:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010518a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010518e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105192:	7e e1                	jle    80105175 <getcallerpcs+0x58>
}
80105194:	90                   	nop
80105195:	c9                   	leave  
80105196:	c3                   	ret    

80105197 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105197:	55                   	push   %ebp
80105198:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010519a:	8b 45 08             	mov    0x8(%ebp),%eax
8010519d:	8b 00                	mov    (%eax),%eax
8010519f:	85 c0                	test   %eax,%eax
801051a1:	74 17                	je     801051ba <holding+0x23>
801051a3:	8b 45 08             	mov    0x8(%ebp),%eax
801051a6:	8b 50 08             	mov    0x8(%eax),%edx
801051a9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051af:	39 c2                	cmp    %eax,%edx
801051b1:	75 07                	jne    801051ba <holding+0x23>
801051b3:	b8 01 00 00 00       	mov    $0x1,%eax
801051b8:	eb 05                	jmp    801051bf <holding+0x28>
801051ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051bf:	5d                   	pop    %ebp
801051c0:	c3                   	ret    

801051c1 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051c1:	55                   	push   %ebp
801051c2:	89 e5                	mov    %esp,%ebp
801051c4:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051c7:	e8 3e fe ff ff       	call   8010500a <readeflags>
801051cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801051cf:	e8 46 fe ff ff       	call   8010501a <cli>
  if(cpu->ncli++ == 0)
801051d4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051db:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801051e1:	8d 48 01             	lea    0x1(%eax),%ecx
801051e4:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801051ea:	85 c0                	test   %eax,%eax
801051ec:	75 15                	jne    80105203 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801051ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051f7:	81 e2 00 02 00 00    	and    $0x200,%edx
801051fd:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105203:	90                   	nop
80105204:	c9                   	leave  
80105205:	c3                   	ret    

80105206 <popcli>:

void
popcli(void)
{
80105206:	55                   	push   %ebp
80105207:	89 e5                	mov    %esp,%ebp
80105209:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010520c:	e8 f9 fd ff ff       	call   8010500a <readeflags>
80105211:	25 00 02 00 00       	and    $0x200,%eax
80105216:	85 c0                	test   %eax,%eax
80105218:	74 0d                	je     80105227 <popcli+0x21>
    panic("popcli - interruptible");
8010521a:	83 ec 0c             	sub    $0xc,%esp
8010521d:	68 4a 8a 10 80       	push   $0x80108a4a
80105222:	e8 40 b3 ff ff       	call   80100567 <panic>
  if(--cpu->ncli < 0)
80105227:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010522d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105233:	83 ea 01             	sub    $0x1,%edx
80105236:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010523c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105242:	85 c0                	test   %eax,%eax
80105244:	79 0d                	jns    80105253 <popcli+0x4d>
    panic("popcli");
80105246:	83 ec 0c             	sub    $0xc,%esp
80105249:	68 61 8a 10 80       	push   $0x80108a61
8010524e:	e8 14 b3 ff ff       	call   80100567 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105253:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105259:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010525f:	85 c0                	test   %eax,%eax
80105261:	75 15                	jne    80105278 <popcli+0x72>
80105263:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105269:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010526f:	85 c0                	test   %eax,%eax
80105271:	74 05                	je     80105278 <popcli+0x72>
    sti();
80105273:	e8 a9 fd ff ff       	call   80105021 <sti>
}
80105278:	90                   	nop
80105279:	c9                   	leave  
8010527a:	c3                   	ret    

8010527b <stosb>:
{
8010527b:	55                   	push   %ebp
8010527c:	89 e5                	mov    %esp,%ebp
8010527e:	57                   	push   %edi
8010527f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105280:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105283:	8b 55 10             	mov    0x10(%ebp),%edx
80105286:	8b 45 0c             	mov    0xc(%ebp),%eax
80105289:	89 cb                	mov    %ecx,%ebx
8010528b:	89 df                	mov    %ebx,%edi
8010528d:	89 d1                	mov    %edx,%ecx
8010528f:	fc                   	cld    
80105290:	f3 aa                	rep stos %al,%es:(%edi)
80105292:	89 ca                	mov    %ecx,%edx
80105294:	89 fb                	mov    %edi,%ebx
80105296:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105299:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010529c:	90                   	nop
8010529d:	5b                   	pop    %ebx
8010529e:	5f                   	pop    %edi
8010529f:	5d                   	pop    %ebp
801052a0:	c3                   	ret    

801052a1 <stosl>:
{
801052a1:	55                   	push   %ebp
801052a2:	89 e5                	mov    %esp,%ebp
801052a4:	57                   	push   %edi
801052a5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a9:	8b 55 10             	mov    0x10(%ebp),%edx
801052ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801052af:	89 cb                	mov    %ecx,%ebx
801052b1:	89 df                	mov    %ebx,%edi
801052b3:	89 d1                	mov    %edx,%ecx
801052b5:	fc                   	cld    
801052b6:	f3 ab                	rep stos %eax,%es:(%edi)
801052b8:	89 ca                	mov    %ecx,%edx
801052ba:	89 fb                	mov    %edi,%ebx
801052bc:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052bf:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052c2:	90                   	nop
801052c3:	5b                   	pop    %ebx
801052c4:	5f                   	pop    %edi
801052c5:	5d                   	pop    %ebp
801052c6:	c3                   	ret    

801052c7 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052c7:	55                   	push   %ebp
801052c8:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052ca:	8b 45 08             	mov    0x8(%ebp),%eax
801052cd:	83 e0 03             	and    $0x3,%eax
801052d0:	85 c0                	test   %eax,%eax
801052d2:	75 43                	jne    80105317 <memset+0x50>
801052d4:	8b 45 10             	mov    0x10(%ebp),%eax
801052d7:	83 e0 03             	and    $0x3,%eax
801052da:	85 c0                	test   %eax,%eax
801052dc:	75 39                	jne    80105317 <memset+0x50>
    c &= 0xFF;
801052de:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801052e5:	8b 45 10             	mov    0x10(%ebp),%eax
801052e8:	c1 e8 02             	shr    $0x2,%eax
801052eb:	89 c1                	mov    %eax,%ecx
801052ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f0:	c1 e0 18             	shl    $0x18,%eax
801052f3:	89 c2                	mov    %eax,%edx
801052f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f8:	c1 e0 10             	shl    $0x10,%eax
801052fb:	09 c2                	or     %eax,%edx
801052fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105300:	c1 e0 08             	shl    $0x8,%eax
80105303:	09 d0                	or     %edx,%eax
80105305:	0b 45 0c             	or     0xc(%ebp),%eax
80105308:	51                   	push   %ecx
80105309:	50                   	push   %eax
8010530a:	ff 75 08             	pushl  0x8(%ebp)
8010530d:	e8 8f ff ff ff       	call   801052a1 <stosl>
80105312:	83 c4 0c             	add    $0xc,%esp
80105315:	eb 12                	jmp    80105329 <memset+0x62>
  } else
    stosb(dst, c, n);
80105317:	8b 45 10             	mov    0x10(%ebp),%eax
8010531a:	50                   	push   %eax
8010531b:	ff 75 0c             	pushl  0xc(%ebp)
8010531e:	ff 75 08             	pushl  0x8(%ebp)
80105321:	e8 55 ff ff ff       	call   8010527b <stosb>
80105326:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105329:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010532c:	c9                   	leave  
8010532d:	c3                   	ret    

8010532e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010532e:	55                   	push   %ebp
8010532f:	89 e5                	mov    %esp,%ebp
80105331:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105334:	8b 45 08             	mov    0x8(%ebp),%eax
80105337:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010533a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105340:	eb 30                	jmp    80105372 <memcmp+0x44>
    if(*s1 != *s2)
80105342:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105345:	0f b6 10             	movzbl (%eax),%edx
80105348:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010534b:	0f b6 00             	movzbl (%eax),%eax
8010534e:	38 c2                	cmp    %al,%dl
80105350:	74 18                	je     8010536a <memcmp+0x3c>
      return *s1 - *s2;
80105352:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105355:	0f b6 00             	movzbl (%eax),%eax
80105358:	0f b6 d0             	movzbl %al,%edx
8010535b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010535e:	0f b6 00             	movzbl (%eax),%eax
80105361:	0f b6 c0             	movzbl %al,%eax
80105364:	29 c2                	sub    %eax,%edx
80105366:	89 d0                	mov    %edx,%eax
80105368:	eb 1a                	jmp    80105384 <memcmp+0x56>
    s1++, s2++;
8010536a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010536e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105372:	8b 45 10             	mov    0x10(%ebp),%eax
80105375:	8d 50 ff             	lea    -0x1(%eax),%edx
80105378:	89 55 10             	mov    %edx,0x10(%ebp)
8010537b:	85 c0                	test   %eax,%eax
8010537d:	75 c3                	jne    80105342 <memcmp+0x14>
  }

  return 0;
8010537f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105384:	c9                   	leave  
80105385:	c3                   	ret    

80105386 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105386:	55                   	push   %ebp
80105387:	89 e5                	mov    %esp,%ebp
80105389:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010538c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105392:	8b 45 08             	mov    0x8(%ebp),%eax
80105395:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105398:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010539e:	73 54                	jae    801053f4 <memmove+0x6e>
801053a0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053a3:	8b 45 10             	mov    0x10(%ebp),%eax
801053a6:	01 d0                	add    %edx,%eax
801053a8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801053ab:	73 47                	jae    801053f4 <memmove+0x6e>
    s += n;
801053ad:	8b 45 10             	mov    0x10(%ebp),%eax
801053b0:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053b3:	8b 45 10             	mov    0x10(%ebp),%eax
801053b6:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053b9:	eb 13                	jmp    801053ce <memmove+0x48>
      *--d = *--s;
801053bb:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053bf:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053c6:	0f b6 10             	movzbl (%eax),%edx
801053c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053cc:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053ce:	8b 45 10             	mov    0x10(%ebp),%eax
801053d1:	8d 50 ff             	lea    -0x1(%eax),%edx
801053d4:	89 55 10             	mov    %edx,0x10(%ebp)
801053d7:	85 c0                	test   %eax,%eax
801053d9:	75 e0                	jne    801053bb <memmove+0x35>
  if(s < d && s + n > d){
801053db:	eb 24                	jmp    80105401 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801053dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053e0:	8d 42 01             	lea    0x1(%edx),%eax
801053e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801053e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053e9:	8d 48 01             	lea    0x1(%eax),%ecx
801053ec:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801053ef:	0f b6 12             	movzbl (%edx),%edx
801053f2:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053f4:	8b 45 10             	mov    0x10(%ebp),%eax
801053f7:	8d 50 ff             	lea    -0x1(%eax),%edx
801053fa:	89 55 10             	mov    %edx,0x10(%ebp)
801053fd:	85 c0                	test   %eax,%eax
801053ff:	75 dc                	jne    801053dd <memmove+0x57>

  return dst;
80105401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105404:	c9                   	leave  
80105405:	c3                   	ret    

80105406 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105406:	55                   	push   %ebp
80105407:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105409:	ff 75 10             	pushl  0x10(%ebp)
8010540c:	ff 75 0c             	pushl  0xc(%ebp)
8010540f:	ff 75 08             	pushl  0x8(%ebp)
80105412:	e8 6f ff ff ff       	call   80105386 <memmove>
80105417:	83 c4 0c             	add    $0xc,%esp
}
8010541a:	c9                   	leave  
8010541b:	c3                   	ret    

8010541c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010541c:	55                   	push   %ebp
8010541d:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010541f:	eb 0c                	jmp    8010542d <strncmp+0x11>
    n--, p++, q++;
80105421:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105425:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105429:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010542d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105431:	74 1a                	je     8010544d <strncmp+0x31>
80105433:	8b 45 08             	mov    0x8(%ebp),%eax
80105436:	0f b6 00             	movzbl (%eax),%eax
80105439:	84 c0                	test   %al,%al
8010543b:	74 10                	je     8010544d <strncmp+0x31>
8010543d:	8b 45 08             	mov    0x8(%ebp),%eax
80105440:	0f b6 10             	movzbl (%eax),%edx
80105443:	8b 45 0c             	mov    0xc(%ebp),%eax
80105446:	0f b6 00             	movzbl (%eax),%eax
80105449:	38 c2                	cmp    %al,%dl
8010544b:	74 d4                	je     80105421 <strncmp+0x5>
  if(n == 0)
8010544d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105451:	75 07                	jne    8010545a <strncmp+0x3e>
    return 0;
80105453:	b8 00 00 00 00       	mov    $0x0,%eax
80105458:	eb 16                	jmp    80105470 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010545a:	8b 45 08             	mov    0x8(%ebp),%eax
8010545d:	0f b6 00             	movzbl (%eax),%eax
80105460:	0f b6 d0             	movzbl %al,%edx
80105463:	8b 45 0c             	mov    0xc(%ebp),%eax
80105466:	0f b6 00             	movzbl (%eax),%eax
80105469:	0f b6 c0             	movzbl %al,%eax
8010546c:	29 c2                	sub    %eax,%edx
8010546e:	89 d0                	mov    %edx,%eax
}
80105470:	5d                   	pop    %ebp
80105471:	c3                   	ret    

80105472 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105472:	55                   	push   %ebp
80105473:	89 e5                	mov    %esp,%ebp
80105475:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105478:	8b 45 08             	mov    0x8(%ebp),%eax
8010547b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010547e:	90                   	nop
8010547f:	8b 45 10             	mov    0x10(%ebp),%eax
80105482:	8d 50 ff             	lea    -0x1(%eax),%edx
80105485:	89 55 10             	mov    %edx,0x10(%ebp)
80105488:	85 c0                	test   %eax,%eax
8010548a:	7e 2c                	jle    801054b8 <strncpy+0x46>
8010548c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010548f:	8d 42 01             	lea    0x1(%edx),%eax
80105492:	89 45 0c             	mov    %eax,0xc(%ebp)
80105495:	8b 45 08             	mov    0x8(%ebp),%eax
80105498:	8d 48 01             	lea    0x1(%eax),%ecx
8010549b:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010549e:	0f b6 12             	movzbl (%edx),%edx
801054a1:	88 10                	mov    %dl,(%eax)
801054a3:	0f b6 00             	movzbl (%eax),%eax
801054a6:	84 c0                	test   %al,%al
801054a8:	75 d5                	jne    8010547f <strncpy+0xd>
    ;
  while(n-- > 0)
801054aa:	eb 0c                	jmp    801054b8 <strncpy+0x46>
    *s++ = 0;
801054ac:	8b 45 08             	mov    0x8(%ebp),%eax
801054af:	8d 50 01             	lea    0x1(%eax),%edx
801054b2:	89 55 08             	mov    %edx,0x8(%ebp)
801054b5:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801054b8:	8b 45 10             	mov    0x10(%ebp),%eax
801054bb:	8d 50 ff             	lea    -0x1(%eax),%edx
801054be:	89 55 10             	mov    %edx,0x10(%ebp)
801054c1:	85 c0                	test   %eax,%eax
801054c3:	7f e7                	jg     801054ac <strncpy+0x3a>
  return os;
801054c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054c8:	c9                   	leave  
801054c9:	c3                   	ret    

801054ca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054ca:	55                   	push   %ebp
801054cb:	89 e5                	mov    %esp,%ebp
801054cd:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054d0:	8b 45 08             	mov    0x8(%ebp),%eax
801054d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054da:	7f 05                	jg     801054e1 <safestrcpy+0x17>
    return os;
801054dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054df:	eb 31                	jmp    80105512 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801054e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054e9:	7e 1e                	jle    80105509 <safestrcpy+0x3f>
801054eb:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ee:	8d 42 01             	lea    0x1(%edx),%eax
801054f1:	89 45 0c             	mov    %eax,0xc(%ebp)
801054f4:	8b 45 08             	mov    0x8(%ebp),%eax
801054f7:	8d 48 01             	lea    0x1(%eax),%ecx
801054fa:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054fd:	0f b6 12             	movzbl (%edx),%edx
80105500:	88 10                	mov    %dl,(%eax)
80105502:	0f b6 00             	movzbl (%eax),%eax
80105505:	84 c0                	test   %al,%al
80105507:	75 d8                	jne    801054e1 <safestrcpy+0x17>
    ;
  *s = 0;
80105509:	8b 45 08             	mov    0x8(%ebp),%eax
8010550c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010550f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105512:	c9                   	leave  
80105513:	c3                   	ret    

80105514 <strlen>:

int
strlen(const char *s)
{
80105514:	55                   	push   %ebp
80105515:	89 e5                	mov    %esp,%ebp
80105517:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010551a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105521:	eb 04                	jmp    80105527 <strlen+0x13>
80105523:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105527:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010552a:	8b 45 08             	mov    0x8(%ebp),%eax
8010552d:	01 d0                	add    %edx,%eax
8010552f:	0f b6 00             	movzbl (%eax),%eax
80105532:	84 c0                	test   %al,%al
80105534:	75 ed                	jne    80105523 <strlen+0xf>
    ;
  return n;
80105536:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105539:	c9                   	leave  
8010553a:	c3                   	ret    

8010553b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010553b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010553f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105543:	55                   	push   %ebp
  pushl %ebx
80105544:	53                   	push   %ebx
  pushl %esi
80105545:	56                   	push   %esi
  pushl %edi
80105546:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105547:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105549:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010554b:	5f                   	pop    %edi
  popl %esi
8010554c:	5e                   	pop    %esi
  popl %ebx
8010554d:	5b                   	pop    %ebx
  popl %ebp
8010554e:	5d                   	pop    %ebp
  ret
8010554f:	c3                   	ret    

80105550 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105550:	55                   	push   %ebp
80105551:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105553:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105559:	8b 00                	mov    (%eax),%eax
8010555b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010555e:	73 12                	jae    80105572 <fetchint+0x22>
80105560:	8b 45 08             	mov    0x8(%ebp),%eax
80105563:	8d 50 04             	lea    0x4(%eax),%edx
80105566:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010556c:	8b 00                	mov    (%eax),%eax
8010556e:	39 c2                	cmp    %eax,%edx
80105570:	76 07                	jbe    80105579 <fetchint+0x29>
    return -1;
80105572:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105577:	eb 0f                	jmp    80105588 <fetchint+0x38>
  *ip = *(int*)(addr);
80105579:	8b 45 08             	mov    0x8(%ebp),%eax
8010557c:	8b 10                	mov    (%eax),%edx
8010557e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105581:	89 10                	mov    %edx,(%eax)
  return 0;
80105583:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105588:	5d                   	pop    %ebp
80105589:	c3                   	ret    

8010558a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010558a:	55                   	push   %ebp
8010558b:	89 e5                	mov    %esp,%ebp
8010558d:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105590:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105596:	8b 00                	mov    (%eax),%eax
80105598:	39 45 08             	cmp    %eax,0x8(%ebp)
8010559b:	72 07                	jb     801055a4 <fetchstr+0x1a>
    return -1;
8010559d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055a2:	eb 46                	jmp    801055ea <fetchstr+0x60>
  *pp = (char*)addr;
801055a4:	8b 55 08             	mov    0x8(%ebp),%edx
801055a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055aa:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801055ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b2:	8b 00                	mov    (%eax),%eax
801055b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801055b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ba:	8b 00                	mov    (%eax),%eax
801055bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055bf:	eb 1c                	jmp    801055dd <fetchstr+0x53>
    if(*s == 0)
801055c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c4:	0f b6 00             	movzbl (%eax),%eax
801055c7:	84 c0                	test   %al,%al
801055c9:	75 0e                	jne    801055d9 <fetchstr+0x4f>
      return s - *pp;
801055cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ce:	8b 00                	mov    (%eax),%eax
801055d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055d3:	29 c2                	sub    %eax,%edx
801055d5:	89 d0                	mov    %edx,%eax
801055d7:	eb 11                	jmp    801055ea <fetchstr+0x60>
  for(s = *pp; s < ep; s++)
801055d9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055e3:	72 dc                	jb     801055c1 <fetchstr+0x37>
  return -1;
801055e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055ea:	c9                   	leave  
801055eb:	c3                   	ret    

801055ec <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055ec:	55                   	push   %ebp
801055ed:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f5:	8b 40 18             	mov    0x18(%eax),%eax
801055f8:	8b 40 44             	mov    0x44(%eax),%eax
801055fb:	8b 55 08             	mov    0x8(%ebp),%edx
801055fe:	c1 e2 02             	shl    $0x2,%edx
80105601:	01 d0                	add    %edx,%eax
80105603:	83 c0 04             	add    $0x4,%eax
80105606:	ff 75 0c             	pushl  0xc(%ebp)
80105609:	50                   	push   %eax
8010560a:	e8 41 ff ff ff       	call   80105550 <fetchint>
8010560f:	83 c4 08             	add    $0x8,%esp
}
80105612:	c9                   	leave  
80105613:	c3                   	ret    

80105614 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105614:	55                   	push   %ebp
80105615:	89 e5                	mov    %esp,%ebp
80105617:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010561a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010561d:	50                   	push   %eax
8010561e:	ff 75 08             	pushl  0x8(%ebp)
80105621:	e8 c6 ff ff ff       	call   801055ec <argint>
80105626:	83 c4 08             	add    $0x8,%esp
80105629:	85 c0                	test   %eax,%eax
8010562b:	79 07                	jns    80105634 <argptr+0x20>
    return -1;
8010562d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105632:	eb 3b                	jmp    8010566f <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105634:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010563a:	8b 00                	mov    (%eax),%eax
8010563c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010563f:	39 d0                	cmp    %edx,%eax
80105641:	76 16                	jbe    80105659 <argptr+0x45>
80105643:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105646:	89 c2                	mov    %eax,%edx
80105648:	8b 45 10             	mov    0x10(%ebp),%eax
8010564b:	01 c2                	add    %eax,%edx
8010564d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105653:	8b 00                	mov    (%eax),%eax
80105655:	39 c2                	cmp    %eax,%edx
80105657:	76 07                	jbe    80105660 <argptr+0x4c>
    return -1;
80105659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010565e:	eb 0f                	jmp    8010566f <argptr+0x5b>
  *pp = (char*)i;
80105660:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105663:	89 c2                	mov    %eax,%edx
80105665:	8b 45 0c             	mov    0xc(%ebp),%eax
80105668:	89 10                	mov    %edx,(%eax)
  return 0;
8010566a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010566f:	c9                   	leave  
80105670:	c3                   	ret    

80105671 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105671:	55                   	push   %ebp
80105672:	89 e5                	mov    %esp,%ebp
80105674:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105677:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010567a:	50                   	push   %eax
8010567b:	ff 75 08             	pushl  0x8(%ebp)
8010567e:	e8 69 ff ff ff       	call   801055ec <argint>
80105683:	83 c4 08             	add    $0x8,%esp
80105686:	85 c0                	test   %eax,%eax
80105688:	79 07                	jns    80105691 <argstr+0x20>
    return -1;
8010568a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010568f:	eb 0f                	jmp    801056a0 <argstr+0x2f>
  return fetchstr(addr, pp);
80105691:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105694:	ff 75 0c             	pushl  0xc(%ebp)
80105697:	50                   	push   %eax
80105698:	e8 ed fe ff ff       	call   8010558a <fetchstr>
8010569d:	83 c4 08             	add    $0x8,%esp
}
801056a0:	c9                   	leave  
801056a1:	c3                   	ret    

801056a2 <syscall>:

};

void
syscall(void)
{
801056a2:	55                   	push   %ebp
801056a3:	89 e5                	mov    %esp,%ebp
801056a5:	83 ec 18             	sub    $0x18,%esp
  int num;

  num = proc->tf->eax;
801056a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ae:	8b 40 18             	mov    0x18(%eax),%eax
801056b1:	8b 40 1c             	mov    0x1c(%eax),%eax
801056b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056bb:	7e 32                	jle    801056ef <syscall+0x4d>
801056bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c0:	83 f8 17             	cmp    $0x17,%eax
801056c3:	77 2a                	ja     801056ef <syscall+0x4d>
801056c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c8:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056cf:	85 c0                	test   %eax,%eax
801056d1:	74 1c                	je     801056ef <syscall+0x4d>
    proc->tf->eax = syscalls[num]();
801056d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d6:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056dd:	ff d0                	call   *%eax
801056df:	89 c2                	mov    %eax,%edx
801056e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e7:	8b 40 18             	mov    0x18(%eax),%eax
801056ea:	89 50 1c             	mov    %edx,0x1c(%eax)
801056ed:	eb 34                	jmp    80105723 <syscall+0x81>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056f5:	8d 50 6c             	lea    0x6c(%eax),%edx
801056f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("%d %s: unknown sys call %d\n",
801056fe:	8b 40 10             	mov    0x10(%eax),%eax
80105701:	ff 75 f4             	pushl  -0xc(%ebp)
80105704:	52                   	push   %edx
80105705:	50                   	push   %eax
80105706:	68 68 8a 10 80       	push   $0x80108a68
8010570b:	e8 b4 ac ff ff       	call   801003c4 <cprintf>
80105710:	83 c4 10             	add    $0x10,%esp
    proc->tf->eax = -1;
80105713:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105719:	8b 40 18             	mov    0x18(%eax),%eax
8010571c:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105723:	90                   	nop
80105724:	c9                   	leave  
80105725:	c3                   	ret    

80105726 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105726:	55                   	push   %ebp
80105727:	89 e5                	mov    %esp,%ebp
80105729:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010572c:	83 ec 08             	sub    $0x8,%esp
8010572f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105732:	50                   	push   %eax
80105733:	ff 75 08             	pushl  0x8(%ebp)
80105736:	e8 b1 fe ff ff       	call   801055ec <argint>
8010573b:	83 c4 10             	add    $0x10,%esp
8010573e:	85 c0                	test   %eax,%eax
80105740:	79 07                	jns    80105749 <argfd+0x23>
    return -1;
80105742:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105747:	eb 50                	jmp    80105799 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010574c:	85 c0                	test   %eax,%eax
8010574e:	78 21                	js     80105771 <argfd+0x4b>
80105750:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105753:	83 f8 0f             	cmp    $0xf,%eax
80105756:	7f 19                	jg     80105771 <argfd+0x4b>
80105758:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010575e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105761:	83 c2 08             	add    $0x8,%edx
80105764:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105768:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010576b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010576f:	75 07                	jne    80105778 <argfd+0x52>
    return -1;
80105771:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105776:	eb 21                	jmp    80105799 <argfd+0x73>
  if(pfd)
80105778:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010577c:	74 08                	je     80105786 <argfd+0x60>
    *pfd = fd;
8010577e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105781:	8b 45 0c             	mov    0xc(%ebp),%eax
80105784:	89 10                	mov    %edx,(%eax)
  if(pf)
80105786:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010578a:	74 08                	je     80105794 <argfd+0x6e>
    *pf = f;
8010578c:	8b 45 10             	mov    0x10(%ebp),%eax
8010578f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105792:	89 10                	mov    %edx,(%eax)
  return 0;
80105794:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105799:	c9                   	leave  
8010579a:	c3                   	ret    

8010579b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010579b:	55                   	push   %ebp
8010579c:	89 e5                	mov    %esp,%ebp
8010579e:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057a8:	eb 30                	jmp    801057da <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b3:	83 c2 08             	add    $0x8,%edx
801057b6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057ba:	85 c0                	test   %eax,%eax
801057bc:	75 18                	jne    801057d6 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057c7:	8d 4a 08             	lea    0x8(%edx),%ecx
801057ca:	8b 55 08             	mov    0x8(%ebp),%edx
801057cd:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d4:	eb 0f                	jmp    801057e5 <fdalloc+0x4a>
  for(fd = 0; fd < NOFILE; fd++){
801057d6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057da:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057de:	7e ca                	jle    801057aa <fdalloc+0xf>
    }
  }
  return -1;
801057e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057e5:	c9                   	leave  
801057e6:	c3                   	ret    

801057e7 <sys_dup>:

int
sys_dup(void)
{
801057e7:	55                   	push   %ebp
801057e8:	89 e5                	mov    %esp,%ebp
801057ea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057ed:	83 ec 04             	sub    $0x4,%esp
801057f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f3:	50                   	push   %eax
801057f4:	6a 00                	push   $0x0
801057f6:	6a 00                	push   $0x0
801057f8:	e8 29 ff ff ff       	call   80105726 <argfd>
801057fd:	83 c4 10             	add    $0x10,%esp
80105800:	85 c0                	test   %eax,%eax
80105802:	79 07                	jns    8010580b <sys_dup+0x24>
    return -1;
80105804:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105809:	eb 31                	jmp    8010583c <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010580b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580e:	83 ec 0c             	sub    $0xc,%esp
80105811:	50                   	push   %eax
80105812:	e8 84 ff ff ff       	call   8010579b <fdalloc>
80105817:	83 c4 10             	add    $0x10,%esp
8010581a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010581d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105821:	79 07                	jns    8010582a <sys_dup+0x43>
    return -1;
80105823:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105828:	eb 12                	jmp    8010583c <sys_dup+0x55>
  filedup(f);
8010582a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582d:	83 ec 0c             	sub    $0xc,%esp
80105830:	50                   	push   %eax
80105831:	e8 d5 b7 ff ff       	call   8010100b <filedup>
80105836:	83 c4 10             	add    $0x10,%esp
  return fd;
80105839:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010583c:	c9                   	leave  
8010583d:	c3                   	ret    

8010583e <sys_read>:

int
sys_read(void)
{
8010583e:	55                   	push   %ebp
8010583f:	89 e5                	mov    %esp,%ebp
80105841:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105844:	83 ec 04             	sub    $0x4,%esp
80105847:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010584a:	50                   	push   %eax
8010584b:	6a 00                	push   $0x0
8010584d:	6a 00                	push   $0x0
8010584f:	e8 d2 fe ff ff       	call   80105726 <argfd>
80105854:	83 c4 10             	add    $0x10,%esp
80105857:	85 c0                	test   %eax,%eax
80105859:	78 2e                	js     80105889 <sys_read+0x4b>
8010585b:	83 ec 08             	sub    $0x8,%esp
8010585e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105861:	50                   	push   %eax
80105862:	6a 02                	push   $0x2
80105864:	e8 83 fd ff ff       	call   801055ec <argint>
80105869:	83 c4 10             	add    $0x10,%esp
8010586c:	85 c0                	test   %eax,%eax
8010586e:	78 19                	js     80105889 <sys_read+0x4b>
80105870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105873:	83 ec 04             	sub    $0x4,%esp
80105876:	50                   	push   %eax
80105877:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010587a:	50                   	push   %eax
8010587b:	6a 01                	push   $0x1
8010587d:	e8 92 fd ff ff       	call   80105614 <argptr>
80105882:	83 c4 10             	add    $0x10,%esp
80105885:	85 c0                	test   %eax,%eax
80105887:	79 07                	jns    80105890 <sys_read+0x52>
    return -1;
80105889:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588e:	eb 17                	jmp    801058a7 <sys_read+0x69>
  return fileread(f, p, n);
80105890:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105893:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105899:	83 ec 04             	sub    $0x4,%esp
8010589c:	51                   	push   %ecx
8010589d:	52                   	push   %edx
8010589e:	50                   	push   %eax
8010589f:	e8 f7 b8 ff ff       	call   8010119b <fileread>
801058a4:	83 c4 10             	add    $0x10,%esp
}
801058a7:	c9                   	leave  
801058a8:	c3                   	ret    

801058a9 <sys_write>:

int
sys_write(void)
{
801058a9:	55                   	push   %ebp
801058aa:	89 e5                	mov    %esp,%ebp
801058ac:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058af:	83 ec 04             	sub    $0x4,%esp
801058b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058b5:	50                   	push   %eax
801058b6:	6a 00                	push   $0x0
801058b8:	6a 00                	push   $0x0
801058ba:	e8 67 fe ff ff       	call   80105726 <argfd>
801058bf:	83 c4 10             	add    $0x10,%esp
801058c2:	85 c0                	test   %eax,%eax
801058c4:	78 2e                	js     801058f4 <sys_write+0x4b>
801058c6:	83 ec 08             	sub    $0x8,%esp
801058c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058cc:	50                   	push   %eax
801058cd:	6a 02                	push   $0x2
801058cf:	e8 18 fd ff ff       	call   801055ec <argint>
801058d4:	83 c4 10             	add    $0x10,%esp
801058d7:	85 c0                	test   %eax,%eax
801058d9:	78 19                	js     801058f4 <sys_write+0x4b>
801058db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058de:	83 ec 04             	sub    $0x4,%esp
801058e1:	50                   	push   %eax
801058e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058e5:	50                   	push   %eax
801058e6:	6a 01                	push   $0x1
801058e8:	e8 27 fd ff ff       	call   80105614 <argptr>
801058ed:	83 c4 10             	add    $0x10,%esp
801058f0:	85 c0                	test   %eax,%eax
801058f2:	79 07                	jns    801058fb <sys_write+0x52>
    return -1;
801058f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f9:	eb 17                	jmp    80105912 <sys_write+0x69>
  return filewrite(f, p, n);
801058fb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058fe:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105904:	83 ec 04             	sub    $0x4,%esp
80105907:	51                   	push   %ecx
80105908:	52                   	push   %edx
80105909:	50                   	push   %eax
8010590a:	e8 44 b9 ff ff       	call   80101253 <filewrite>
8010590f:	83 c4 10             	add    $0x10,%esp
}
80105912:	c9                   	leave  
80105913:	c3                   	ret    

80105914 <sys_close>:

int
sys_close(void)
{
80105914:	55                   	push   %ebp
80105915:	89 e5                	mov    %esp,%ebp
80105917:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010591a:	83 ec 04             	sub    $0x4,%esp
8010591d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105920:	50                   	push   %eax
80105921:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105924:	50                   	push   %eax
80105925:	6a 00                	push   $0x0
80105927:	e8 fa fd ff ff       	call   80105726 <argfd>
8010592c:	83 c4 10             	add    $0x10,%esp
8010592f:	85 c0                	test   %eax,%eax
80105931:	79 07                	jns    8010593a <sys_close+0x26>
    return -1;
80105933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105938:	eb 28                	jmp    80105962 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010593a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105940:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105943:	83 c2 08             	add    $0x8,%edx
80105946:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010594d:	00 
  fileclose(f);
8010594e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105951:	83 ec 0c             	sub    $0xc,%esp
80105954:	50                   	push   %eax
80105955:	e8 02 b7 ff ff       	call   8010105c <fileclose>
8010595a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010595d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105962:	c9                   	leave  
80105963:	c3                   	ret    

80105964 <sys_fstat>:

int
sys_fstat(void)
{
80105964:	55                   	push   %ebp
80105965:	89 e5                	mov    %esp,%ebp
80105967:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010596a:	83 ec 04             	sub    $0x4,%esp
8010596d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105970:	50                   	push   %eax
80105971:	6a 00                	push   $0x0
80105973:	6a 00                	push   $0x0
80105975:	e8 ac fd ff ff       	call   80105726 <argfd>
8010597a:	83 c4 10             	add    $0x10,%esp
8010597d:	85 c0                	test   %eax,%eax
8010597f:	78 17                	js     80105998 <sys_fstat+0x34>
80105981:	83 ec 04             	sub    $0x4,%esp
80105984:	6a 14                	push   $0x14
80105986:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105989:	50                   	push   %eax
8010598a:	6a 01                	push   $0x1
8010598c:	e8 83 fc ff ff       	call   80105614 <argptr>
80105991:	83 c4 10             	add    $0x10,%esp
80105994:	85 c0                	test   %eax,%eax
80105996:	79 07                	jns    8010599f <sys_fstat+0x3b>
    return -1;
80105998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599d:	eb 13                	jmp    801059b2 <sys_fstat+0x4e>
  return filestat(f, st);
8010599f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a5:	83 ec 08             	sub    $0x8,%esp
801059a8:	52                   	push   %edx
801059a9:	50                   	push   %eax
801059aa:	e8 95 b7 ff ff       	call   80101144 <filestat>
801059af:	83 c4 10             	add    $0x10,%esp
}
801059b2:	c9                   	leave  
801059b3:	c3                   	ret    

801059b4 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059b4:	55                   	push   %ebp
801059b5:	89 e5                	mov    %esp,%ebp
801059b7:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059ba:	83 ec 08             	sub    $0x8,%esp
801059bd:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059c0:	50                   	push   %eax
801059c1:	6a 00                	push   $0x0
801059c3:	e8 a9 fc ff ff       	call   80105671 <argstr>
801059c8:	83 c4 10             	add    $0x10,%esp
801059cb:	85 c0                	test   %eax,%eax
801059cd:	78 15                	js     801059e4 <sys_link+0x30>
801059cf:	83 ec 08             	sub    $0x8,%esp
801059d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059d5:	50                   	push   %eax
801059d6:	6a 01                	push   $0x1
801059d8:	e8 94 fc ff ff       	call   80105671 <argstr>
801059dd:	83 c4 10             	add    $0x10,%esp
801059e0:	85 c0                	test   %eax,%eax
801059e2:	79 0a                	jns    801059ee <sys_link+0x3a>
    return -1;
801059e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e9:	e9 68 01 00 00       	jmp    80105b56 <sys_link+0x1a2>

  begin_op();
801059ee:	e8 63 db ff ff       	call   80103556 <begin_op>
  if((ip = namei(old)) == 0){
801059f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801059f6:	83 ec 0c             	sub    $0xc,%esp
801059f9:	50                   	push   %eax
801059fa:	e8 2b cb ff ff       	call   8010252a <namei>
801059ff:	83 c4 10             	add    $0x10,%esp
80105a02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a09:	75 0f                	jne    80105a1a <sys_link+0x66>
    end_op();
80105a0b:	e8 d2 db ff ff       	call   801035e2 <end_op>
    return -1;
80105a10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a15:	e9 3c 01 00 00       	jmp    80105b56 <sys_link+0x1a2>
  }

  ilock(ip);
80105a1a:	83 ec 0c             	sub    $0xc,%esp
80105a1d:	ff 75 f4             	pushl  -0xc(%ebp)
80105a20:	e8 50 bf ff ff       	call   80101975 <ilock>
80105a25:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a2f:	66 83 f8 01          	cmp    $0x1,%ax
80105a33:	75 1d                	jne    80105a52 <sys_link+0x9e>
    iunlockput(ip);
80105a35:	83 ec 0c             	sub    $0xc,%esp
80105a38:	ff 75 f4             	pushl  -0xc(%ebp)
80105a3b:	e8 f5 c1 ff ff       	call   80101c35 <iunlockput>
80105a40:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a43:	e8 9a db ff ff       	call   801035e2 <end_op>
    return -1;
80105a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4d:	e9 04 01 00 00       	jmp    80105b56 <sys_link+0x1a2>
  }

  ip->nlink++;
80105a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a55:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a59:	83 c0 01             	add    $0x1,%eax
80105a5c:	89 c2                	mov    %eax,%edx
80105a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a61:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a65:	83 ec 0c             	sub    $0xc,%esp
80105a68:	ff 75 f4             	pushl  -0xc(%ebp)
80105a6b:	e8 2b bd ff ff       	call   8010179b <iupdate>
80105a70:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a73:	83 ec 0c             	sub    $0xc,%esp
80105a76:	ff 75 f4             	pushl  -0xc(%ebp)
80105a79:	e8 55 c0 ff ff       	call   80101ad3 <iunlock>
80105a7e:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a81:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a84:	83 ec 08             	sub    $0x8,%esp
80105a87:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a8a:	52                   	push   %edx
80105a8b:	50                   	push   %eax
80105a8c:	e8 b5 ca ff ff       	call   80102546 <nameiparent>
80105a91:	83 c4 10             	add    $0x10,%esp
80105a94:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a9b:	74 71                	je     80105b0e <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a9d:	83 ec 0c             	sub    $0xc,%esp
80105aa0:	ff 75 f0             	pushl  -0x10(%ebp)
80105aa3:	e8 cd be ff ff       	call   80101975 <ilock>
80105aa8:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aae:	8b 10                	mov    (%eax),%edx
80105ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab3:	8b 00                	mov    (%eax),%eax
80105ab5:	39 c2                	cmp    %eax,%edx
80105ab7:	75 1d                	jne    80105ad6 <sys_link+0x122>
80105ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abc:	8b 40 04             	mov    0x4(%eax),%eax
80105abf:	83 ec 04             	sub    $0x4,%esp
80105ac2:	50                   	push   %eax
80105ac3:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ac6:	50                   	push   %eax
80105ac7:	ff 75 f0             	pushl  -0x10(%ebp)
80105aca:	e8 c3 c7 ff ff       	call   80102292 <dirlink>
80105acf:	83 c4 10             	add    $0x10,%esp
80105ad2:	85 c0                	test   %eax,%eax
80105ad4:	79 10                	jns    80105ae6 <sys_link+0x132>
    iunlockput(dp);
80105ad6:	83 ec 0c             	sub    $0xc,%esp
80105ad9:	ff 75 f0             	pushl  -0x10(%ebp)
80105adc:	e8 54 c1 ff ff       	call   80101c35 <iunlockput>
80105ae1:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ae4:	eb 29                	jmp    80105b0f <sys_link+0x15b>
  }
  iunlockput(dp);
80105ae6:	83 ec 0c             	sub    $0xc,%esp
80105ae9:	ff 75 f0             	pushl  -0x10(%ebp)
80105aec:	e8 44 c1 ff ff       	call   80101c35 <iunlockput>
80105af1:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105af4:	83 ec 0c             	sub    $0xc,%esp
80105af7:	ff 75 f4             	pushl  -0xc(%ebp)
80105afa:	e8 46 c0 ff ff       	call   80101b45 <iput>
80105aff:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b02:	e8 db da ff ff       	call   801035e2 <end_op>

  return 0;
80105b07:	b8 00 00 00 00       	mov    $0x0,%eax
80105b0c:	eb 48                	jmp    80105b56 <sys_link+0x1a2>
    goto bad;
80105b0e:	90                   	nop

bad:
  ilock(ip);
80105b0f:	83 ec 0c             	sub    $0xc,%esp
80105b12:	ff 75 f4             	pushl  -0xc(%ebp)
80105b15:	e8 5b be ff ff       	call   80101975 <ilock>
80105b1a:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b20:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b24:	83 e8 01             	sub    $0x1,%eax
80105b27:	89 c2                	mov    %eax,%edx
80105b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b30:	83 ec 0c             	sub    $0xc,%esp
80105b33:	ff 75 f4             	pushl  -0xc(%ebp)
80105b36:	e8 60 bc ff ff       	call   8010179b <iupdate>
80105b3b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b3e:	83 ec 0c             	sub    $0xc,%esp
80105b41:	ff 75 f4             	pushl  -0xc(%ebp)
80105b44:	e8 ec c0 ff ff       	call   80101c35 <iunlockput>
80105b49:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b4c:	e8 91 da ff ff       	call   801035e2 <end_op>
  return -1;
80105b51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b56:	c9                   	leave  
80105b57:	c3                   	ret    

80105b58 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b58:	55                   	push   %ebp
80105b59:	89 e5                	mov    %esp,%ebp
80105b5b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b5e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b65:	eb 40                	jmp    80105ba7 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6a:	6a 10                	push   $0x10
80105b6c:	50                   	push   %eax
80105b6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b70:	50                   	push   %eax
80105b71:	ff 75 08             	pushl  0x8(%ebp)
80105b74:	e8 65 c3 ff ff       	call   80101ede <readi>
80105b79:	83 c4 10             	add    $0x10,%esp
80105b7c:	83 f8 10             	cmp    $0x10,%eax
80105b7f:	74 0d                	je     80105b8e <isdirempty+0x36>
      panic("isdirempty: readi");
80105b81:	83 ec 0c             	sub    $0xc,%esp
80105b84:	68 84 8a 10 80       	push   $0x80108a84
80105b89:	e8 d9 a9 ff ff       	call   80100567 <panic>
    if(de.inum != 0)
80105b8e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b92:	66 85 c0             	test   %ax,%ax
80105b95:	74 07                	je     80105b9e <isdirempty+0x46>
      return 0;
80105b97:	b8 00 00 00 00       	mov    $0x0,%eax
80105b9c:	eb 1b                	jmp    80105bb9 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba1:	83 c0 10             	add    $0x10,%eax
80105ba4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80105baa:	8b 50 18             	mov    0x18(%eax),%edx
80105bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb0:	39 c2                	cmp    %eax,%edx
80105bb2:	77 b3                	ja     80105b67 <isdirempty+0xf>
  }
  return 1;
80105bb4:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bb9:	c9                   	leave  
80105bba:	c3                   	ret    

80105bbb <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bbb:	55                   	push   %ebp
80105bbc:	89 e5                	mov    %esp,%ebp
80105bbe:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bc1:	83 ec 08             	sub    $0x8,%esp
80105bc4:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bc7:	50                   	push   %eax
80105bc8:	6a 00                	push   $0x0
80105bca:	e8 a2 fa ff ff       	call   80105671 <argstr>
80105bcf:	83 c4 10             	add    $0x10,%esp
80105bd2:	85 c0                	test   %eax,%eax
80105bd4:	79 0a                	jns    80105be0 <sys_unlink+0x25>
    return -1;
80105bd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdb:	e9 bf 01 00 00       	jmp    80105d9f <sys_unlink+0x1e4>

  begin_op();
80105be0:	e8 71 d9 ff ff       	call   80103556 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105be5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105be8:	83 ec 08             	sub    $0x8,%esp
80105beb:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bee:	52                   	push   %edx
80105bef:	50                   	push   %eax
80105bf0:	e8 51 c9 ff ff       	call   80102546 <nameiparent>
80105bf5:	83 c4 10             	add    $0x10,%esp
80105bf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bff:	75 0f                	jne    80105c10 <sys_unlink+0x55>
    end_op();
80105c01:	e8 dc d9 ff ff       	call   801035e2 <end_op>
    return -1;
80105c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0b:	e9 8f 01 00 00       	jmp    80105d9f <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c10:	83 ec 0c             	sub    $0xc,%esp
80105c13:	ff 75 f4             	pushl  -0xc(%ebp)
80105c16:	e8 5a bd ff ff       	call   80101975 <ilock>
80105c1b:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c1e:	83 ec 08             	sub    $0x8,%esp
80105c21:	68 96 8a 10 80       	push   $0x80108a96
80105c26:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c29:	50                   	push   %eax
80105c2a:	e8 8e c5 ff ff       	call   801021bd <namecmp>
80105c2f:	83 c4 10             	add    $0x10,%esp
80105c32:	85 c0                	test   %eax,%eax
80105c34:	0f 84 49 01 00 00    	je     80105d83 <sys_unlink+0x1c8>
80105c3a:	83 ec 08             	sub    $0x8,%esp
80105c3d:	68 98 8a 10 80       	push   $0x80108a98
80105c42:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c45:	50                   	push   %eax
80105c46:	e8 72 c5 ff ff       	call   801021bd <namecmp>
80105c4b:	83 c4 10             	add    $0x10,%esp
80105c4e:	85 c0                	test   %eax,%eax
80105c50:	0f 84 2d 01 00 00    	je     80105d83 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c56:	83 ec 04             	sub    $0x4,%esp
80105c59:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c5c:	50                   	push   %eax
80105c5d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c60:	50                   	push   %eax
80105c61:	ff 75 f4             	pushl  -0xc(%ebp)
80105c64:	e8 6f c5 ff ff       	call   801021d8 <dirlookup>
80105c69:	83 c4 10             	add    $0x10,%esp
80105c6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c73:	0f 84 0d 01 00 00    	je     80105d86 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105c79:	83 ec 0c             	sub    $0xc,%esp
80105c7c:	ff 75 f0             	pushl  -0x10(%ebp)
80105c7f:	e8 f1 bc ff ff       	call   80101975 <ilock>
80105c84:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c8e:	66 85 c0             	test   %ax,%ax
80105c91:	7f 0d                	jg     80105ca0 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c93:	83 ec 0c             	sub    $0xc,%esp
80105c96:	68 9b 8a 10 80       	push   $0x80108a9b
80105c9b:	e8 c7 a8 ff ff       	call   80100567 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ca7:	66 83 f8 01          	cmp    $0x1,%ax
80105cab:	75 25                	jne    80105cd2 <sys_unlink+0x117>
80105cad:	83 ec 0c             	sub    $0xc,%esp
80105cb0:	ff 75 f0             	pushl  -0x10(%ebp)
80105cb3:	e8 a0 fe ff ff       	call   80105b58 <isdirempty>
80105cb8:	83 c4 10             	add    $0x10,%esp
80105cbb:	85 c0                	test   %eax,%eax
80105cbd:	75 13                	jne    80105cd2 <sys_unlink+0x117>
    iunlockput(ip);
80105cbf:	83 ec 0c             	sub    $0xc,%esp
80105cc2:	ff 75 f0             	pushl  -0x10(%ebp)
80105cc5:	e8 6b bf ff ff       	call   80101c35 <iunlockput>
80105cca:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ccd:	e9 b5 00 00 00       	jmp    80105d87 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105cd2:	83 ec 04             	sub    $0x4,%esp
80105cd5:	6a 10                	push   $0x10
80105cd7:	6a 00                	push   $0x0
80105cd9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cdc:	50                   	push   %eax
80105cdd:	e8 e5 f5 ff ff       	call   801052c7 <memset>
80105ce2:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ce5:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ce8:	6a 10                	push   $0x10
80105cea:	50                   	push   %eax
80105ceb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cee:	50                   	push   %eax
80105cef:	ff 75 f4             	pushl  -0xc(%ebp)
80105cf2:	e8 3e c3 ff ff       	call   80102035 <writei>
80105cf7:	83 c4 10             	add    $0x10,%esp
80105cfa:	83 f8 10             	cmp    $0x10,%eax
80105cfd:	74 0d                	je     80105d0c <sys_unlink+0x151>
    panic("unlink: writei");
80105cff:	83 ec 0c             	sub    $0xc,%esp
80105d02:	68 ad 8a 10 80       	push   $0x80108aad
80105d07:	e8 5b a8 ff ff       	call   80100567 <panic>
  if(ip->type == T_DIR){
80105d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d13:	66 83 f8 01          	cmp    $0x1,%ax
80105d17:	75 21                	jne    80105d3a <sys_unlink+0x17f>
    dp->nlink--;
80105d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d20:	83 e8 01             	sub    $0x1,%eax
80105d23:	89 c2                	mov    %eax,%edx
80105d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d28:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d2c:	83 ec 0c             	sub    $0xc,%esp
80105d2f:	ff 75 f4             	pushl  -0xc(%ebp)
80105d32:	e8 64 ba ff ff       	call   8010179b <iupdate>
80105d37:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d3a:	83 ec 0c             	sub    $0xc,%esp
80105d3d:	ff 75 f4             	pushl  -0xc(%ebp)
80105d40:	e8 f0 be ff ff       	call   80101c35 <iunlockput>
80105d45:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d4f:	83 e8 01             	sub    $0x1,%eax
80105d52:	89 c2                	mov    %eax,%edx
80105d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d57:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d5b:	83 ec 0c             	sub    $0xc,%esp
80105d5e:	ff 75 f0             	pushl  -0x10(%ebp)
80105d61:	e8 35 ba ff ff       	call   8010179b <iupdate>
80105d66:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d69:	83 ec 0c             	sub    $0xc,%esp
80105d6c:	ff 75 f0             	pushl  -0x10(%ebp)
80105d6f:	e8 c1 be ff ff       	call   80101c35 <iunlockput>
80105d74:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d77:	e8 66 d8 ff ff       	call   801035e2 <end_op>

  return 0;
80105d7c:	b8 00 00 00 00       	mov    $0x0,%eax
80105d81:	eb 1c                	jmp    80105d9f <sys_unlink+0x1e4>
    goto bad;
80105d83:	90                   	nop
80105d84:	eb 01                	jmp    80105d87 <sys_unlink+0x1cc>
    goto bad;
80105d86:	90                   	nop

bad:
  iunlockput(dp);
80105d87:	83 ec 0c             	sub    $0xc,%esp
80105d8a:	ff 75 f4             	pushl  -0xc(%ebp)
80105d8d:	e8 a3 be ff ff       	call   80101c35 <iunlockput>
80105d92:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d95:	e8 48 d8 ff ff       	call   801035e2 <end_op>
  return -1;
80105d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d9f:	c9                   	leave  
80105da0:	c3                   	ret    

80105da1 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105da1:	55                   	push   %ebp
80105da2:	89 e5                	mov    %esp,%ebp
80105da4:	83 ec 38             	sub    $0x38,%esp
80105da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105daa:	8b 55 10             	mov    0x10(%ebp),%edx
80105dad:	8b 45 14             	mov    0x14(%ebp),%eax
80105db0:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105db4:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105db8:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dbc:	83 ec 08             	sub    $0x8,%esp
80105dbf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dc2:	50                   	push   %eax
80105dc3:	ff 75 08             	pushl  0x8(%ebp)
80105dc6:	e8 7b c7 ff ff       	call   80102546 <nameiparent>
80105dcb:	83 c4 10             	add    $0x10,%esp
80105dce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dd5:	75 0a                	jne    80105de1 <create+0x40>
    return 0;
80105dd7:	b8 00 00 00 00       	mov    $0x0,%eax
80105ddc:	e9 90 01 00 00       	jmp    80105f71 <create+0x1d0>
  ilock(dp);
80105de1:	83 ec 0c             	sub    $0xc,%esp
80105de4:	ff 75 f4             	pushl  -0xc(%ebp)
80105de7:	e8 89 bb ff ff       	call   80101975 <ilock>
80105dec:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105def:	83 ec 04             	sub    $0x4,%esp
80105df2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105df5:	50                   	push   %eax
80105df6:	8d 45 de             	lea    -0x22(%ebp),%eax
80105df9:	50                   	push   %eax
80105dfa:	ff 75 f4             	pushl  -0xc(%ebp)
80105dfd:	e8 d6 c3 ff ff       	call   801021d8 <dirlookup>
80105e02:	83 c4 10             	add    $0x10,%esp
80105e05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e0c:	74 50                	je     80105e5e <create+0xbd>
    iunlockput(dp);
80105e0e:	83 ec 0c             	sub    $0xc,%esp
80105e11:	ff 75 f4             	pushl  -0xc(%ebp)
80105e14:	e8 1c be ff ff       	call   80101c35 <iunlockput>
80105e19:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e1c:	83 ec 0c             	sub    $0xc,%esp
80105e1f:	ff 75 f0             	pushl  -0x10(%ebp)
80105e22:	e8 4e bb ff ff       	call   80101975 <ilock>
80105e27:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e2a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e2f:	75 15                	jne    80105e46 <create+0xa5>
80105e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e34:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e38:	66 83 f8 02          	cmp    $0x2,%ax
80105e3c:	75 08                	jne    80105e46 <create+0xa5>
      return ip;
80105e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e41:	e9 2b 01 00 00       	jmp    80105f71 <create+0x1d0>
    iunlockput(ip);
80105e46:	83 ec 0c             	sub    $0xc,%esp
80105e49:	ff 75 f0             	pushl  -0x10(%ebp)
80105e4c:	e8 e4 bd ff ff       	call   80101c35 <iunlockput>
80105e51:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e54:	b8 00 00 00 00       	mov    $0x0,%eax
80105e59:	e9 13 01 00 00       	jmp    80105f71 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e5e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e65:	8b 00                	mov    (%eax),%eax
80105e67:	83 ec 08             	sub    $0x8,%esp
80105e6a:	52                   	push   %edx
80105e6b:	50                   	push   %eax
80105e6c:	e8 53 b8 ff ff       	call   801016c4 <ialloc>
80105e71:	83 c4 10             	add    $0x10,%esp
80105e74:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e7b:	75 0d                	jne    80105e8a <create+0xe9>
    panic("create: ialloc");
80105e7d:	83 ec 0c             	sub    $0xc,%esp
80105e80:	68 bc 8a 10 80       	push   $0x80108abc
80105e85:	e8 dd a6 ff ff       	call   80100567 <panic>

  ilock(ip);
80105e8a:	83 ec 0c             	sub    $0xc,%esp
80105e8d:	ff 75 f0             	pushl  -0x10(%ebp)
80105e90:	e8 e0 ba ff ff       	call   80101975 <ilock>
80105e95:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e9f:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105eaa:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb1:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105eb7:	83 ec 0c             	sub    $0xc,%esp
80105eba:	ff 75 f0             	pushl  -0x10(%ebp)
80105ebd:	e8 d9 b8 ff ff       	call   8010179b <iupdate>
80105ec2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ec5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105eca:	75 6a                	jne    80105f36 <create+0x195>
    dp->nlink++;  // for ".."
80105ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ed3:	83 c0 01             	add    $0x1,%eax
80105ed6:	89 c2                	mov    %eax,%edx
80105ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edb:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105edf:	83 ec 0c             	sub    $0xc,%esp
80105ee2:	ff 75 f4             	pushl  -0xc(%ebp)
80105ee5:	e8 b1 b8 ff ff       	call   8010179b <iupdate>
80105eea:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef0:	8b 40 04             	mov    0x4(%eax),%eax
80105ef3:	83 ec 04             	sub    $0x4,%esp
80105ef6:	50                   	push   %eax
80105ef7:	68 96 8a 10 80       	push   $0x80108a96
80105efc:	ff 75 f0             	pushl  -0x10(%ebp)
80105eff:	e8 8e c3 ff ff       	call   80102292 <dirlink>
80105f04:	83 c4 10             	add    $0x10,%esp
80105f07:	85 c0                	test   %eax,%eax
80105f09:	78 1e                	js     80105f29 <create+0x188>
80105f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0e:	8b 40 04             	mov    0x4(%eax),%eax
80105f11:	83 ec 04             	sub    $0x4,%esp
80105f14:	50                   	push   %eax
80105f15:	68 98 8a 10 80       	push   $0x80108a98
80105f1a:	ff 75 f0             	pushl  -0x10(%ebp)
80105f1d:	e8 70 c3 ff ff       	call   80102292 <dirlink>
80105f22:	83 c4 10             	add    $0x10,%esp
80105f25:	85 c0                	test   %eax,%eax
80105f27:	79 0d                	jns    80105f36 <create+0x195>
      panic("create dots");
80105f29:	83 ec 0c             	sub    $0xc,%esp
80105f2c:	68 cb 8a 10 80       	push   $0x80108acb
80105f31:	e8 31 a6 ff ff       	call   80100567 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f39:	8b 40 04             	mov    0x4(%eax),%eax
80105f3c:	83 ec 04             	sub    $0x4,%esp
80105f3f:	50                   	push   %eax
80105f40:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f43:	50                   	push   %eax
80105f44:	ff 75 f4             	pushl  -0xc(%ebp)
80105f47:	e8 46 c3 ff ff       	call   80102292 <dirlink>
80105f4c:	83 c4 10             	add    $0x10,%esp
80105f4f:	85 c0                	test   %eax,%eax
80105f51:	79 0d                	jns    80105f60 <create+0x1bf>
    panic("create: dirlink");
80105f53:	83 ec 0c             	sub    $0xc,%esp
80105f56:	68 d7 8a 10 80       	push   $0x80108ad7
80105f5b:	e8 07 a6 ff ff       	call   80100567 <panic>

  iunlockput(dp);
80105f60:	83 ec 0c             	sub    $0xc,%esp
80105f63:	ff 75 f4             	pushl  -0xc(%ebp)
80105f66:	e8 ca bc ff ff       	call   80101c35 <iunlockput>
80105f6b:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f71:	c9                   	leave  
80105f72:	c3                   	ret    

80105f73 <sys_open>:

int
sys_open(void)
{
80105f73:	55                   	push   %ebp
80105f74:	89 e5                	mov    %esp,%ebp
80105f76:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f79:	83 ec 08             	sub    $0x8,%esp
80105f7c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f7f:	50                   	push   %eax
80105f80:	6a 00                	push   $0x0
80105f82:	e8 ea f6 ff ff       	call   80105671 <argstr>
80105f87:	83 c4 10             	add    $0x10,%esp
80105f8a:	85 c0                	test   %eax,%eax
80105f8c:	78 15                	js     80105fa3 <sys_open+0x30>
80105f8e:	83 ec 08             	sub    $0x8,%esp
80105f91:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f94:	50                   	push   %eax
80105f95:	6a 01                	push   $0x1
80105f97:	e8 50 f6 ff ff       	call   801055ec <argint>
80105f9c:	83 c4 10             	add    $0x10,%esp
80105f9f:	85 c0                	test   %eax,%eax
80105fa1:	79 0a                	jns    80105fad <sys_open+0x3a>
    return -1;
80105fa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa8:	e9 61 01 00 00       	jmp    8010610e <sys_open+0x19b>

  begin_op();
80105fad:	e8 a4 d5 ff ff       	call   80103556 <begin_op>

  if(omode & O_CREATE){
80105fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fb5:	25 00 02 00 00       	and    $0x200,%eax
80105fba:	85 c0                	test   %eax,%eax
80105fbc:	74 2a                	je     80105fe8 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fc1:	6a 00                	push   $0x0
80105fc3:	6a 00                	push   $0x0
80105fc5:	6a 02                	push   $0x2
80105fc7:	50                   	push   %eax
80105fc8:	e8 d4 fd ff ff       	call   80105da1 <create>
80105fcd:	83 c4 10             	add    $0x10,%esp
80105fd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd7:	75 75                	jne    8010604e <sys_open+0xdb>
      end_op();
80105fd9:	e8 04 d6 ff ff       	call   801035e2 <end_op>
      return -1;
80105fde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe3:	e9 26 01 00 00       	jmp    8010610e <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105fe8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105feb:	83 ec 0c             	sub    $0xc,%esp
80105fee:	50                   	push   %eax
80105fef:	e8 36 c5 ff ff       	call   8010252a <namei>
80105ff4:	83 c4 10             	add    $0x10,%esp
80105ff7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ffa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ffe:	75 0f                	jne    8010600f <sys_open+0x9c>
      end_op();
80106000:	e8 dd d5 ff ff       	call   801035e2 <end_op>
      return -1;
80106005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010600a:	e9 ff 00 00 00       	jmp    8010610e <sys_open+0x19b>
    }
    ilock(ip);
8010600f:	83 ec 0c             	sub    $0xc,%esp
80106012:	ff 75 f4             	pushl  -0xc(%ebp)
80106015:	e8 5b b9 ff ff       	call   80101975 <ilock>
8010601a:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010601d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106020:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106024:	66 83 f8 01          	cmp    $0x1,%ax
80106028:	75 24                	jne    8010604e <sys_open+0xdb>
8010602a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010602d:	85 c0                	test   %eax,%eax
8010602f:	74 1d                	je     8010604e <sys_open+0xdb>
      iunlockput(ip);
80106031:	83 ec 0c             	sub    $0xc,%esp
80106034:	ff 75 f4             	pushl  -0xc(%ebp)
80106037:	e8 f9 bb ff ff       	call   80101c35 <iunlockput>
8010603c:	83 c4 10             	add    $0x10,%esp
      end_op();
8010603f:	e8 9e d5 ff ff       	call   801035e2 <end_op>
      return -1;
80106044:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106049:	e9 c0 00 00 00       	jmp    8010610e <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010604e:	e8 4b af ff ff       	call   80100f9e <filealloc>
80106053:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106056:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010605a:	74 17                	je     80106073 <sys_open+0x100>
8010605c:	83 ec 0c             	sub    $0xc,%esp
8010605f:	ff 75 f0             	pushl  -0x10(%ebp)
80106062:	e8 34 f7 ff ff       	call   8010579b <fdalloc>
80106067:	83 c4 10             	add    $0x10,%esp
8010606a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010606d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106071:	79 2e                	jns    801060a1 <sys_open+0x12e>
    if(f)
80106073:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106077:	74 0e                	je     80106087 <sys_open+0x114>
      fileclose(f);
80106079:	83 ec 0c             	sub    $0xc,%esp
8010607c:	ff 75 f0             	pushl  -0x10(%ebp)
8010607f:	e8 d8 af ff ff       	call   8010105c <fileclose>
80106084:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106087:	83 ec 0c             	sub    $0xc,%esp
8010608a:	ff 75 f4             	pushl  -0xc(%ebp)
8010608d:	e8 a3 bb ff ff       	call   80101c35 <iunlockput>
80106092:	83 c4 10             	add    $0x10,%esp
    end_op();
80106095:	e8 48 d5 ff ff       	call   801035e2 <end_op>
    return -1;
8010609a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609f:	eb 6d                	jmp    8010610e <sys_open+0x19b>
  }
  iunlock(ip);
801060a1:	83 ec 0c             	sub    $0xc,%esp
801060a4:	ff 75 f4             	pushl  -0xc(%ebp)
801060a7:	e8 27 ba ff ff       	call   80101ad3 <iunlock>
801060ac:	83 c4 10             	add    $0x10,%esp
  end_op();
801060af:	e8 2e d5 ff ff       	call   801035e2 <end_op>

  f->type = FD_INODE;
801060b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b7:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060c3:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060d3:	83 e0 01             	and    $0x1,%eax
801060d6:	85 c0                	test   %eax,%eax
801060d8:	0f 94 c0             	sete   %al
801060db:	89 c2                	mov    %eax,%edx
801060dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e0:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e6:	83 e0 01             	and    $0x1,%eax
801060e9:	85 c0                	test   %eax,%eax
801060eb:	75 0a                	jne    801060f7 <sys_open+0x184>
801060ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f0:	83 e0 02             	and    $0x2,%eax
801060f3:	85 c0                	test   %eax,%eax
801060f5:	74 07                	je     801060fe <sys_open+0x18b>
801060f7:	b8 01 00 00 00       	mov    $0x1,%eax
801060fc:	eb 05                	jmp    80106103 <sys_open+0x190>
801060fe:	b8 00 00 00 00       	mov    $0x0,%eax
80106103:	89 c2                	mov    %eax,%edx
80106105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106108:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010610b:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010610e:	c9                   	leave  
8010610f:	c3                   	ret    

80106110 <sys_mkdir>:

int
sys_mkdir(void)
{
80106110:	55                   	push   %ebp
80106111:	89 e5                	mov    %esp,%ebp
80106113:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106116:	e8 3b d4 ff ff       	call   80103556 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010611b:	83 ec 08             	sub    $0x8,%esp
8010611e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106121:	50                   	push   %eax
80106122:	6a 00                	push   $0x0
80106124:	e8 48 f5 ff ff       	call   80105671 <argstr>
80106129:	83 c4 10             	add    $0x10,%esp
8010612c:	85 c0                	test   %eax,%eax
8010612e:	78 1b                	js     8010614b <sys_mkdir+0x3b>
80106130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106133:	6a 00                	push   $0x0
80106135:	6a 00                	push   $0x0
80106137:	6a 01                	push   $0x1
80106139:	50                   	push   %eax
8010613a:	e8 62 fc ff ff       	call   80105da1 <create>
8010613f:	83 c4 10             	add    $0x10,%esp
80106142:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106149:	75 0c                	jne    80106157 <sys_mkdir+0x47>
    end_op();
8010614b:	e8 92 d4 ff ff       	call   801035e2 <end_op>
    return -1;
80106150:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106155:	eb 18                	jmp    8010616f <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106157:	83 ec 0c             	sub    $0xc,%esp
8010615a:	ff 75 f4             	pushl  -0xc(%ebp)
8010615d:	e8 d3 ba ff ff       	call   80101c35 <iunlockput>
80106162:	83 c4 10             	add    $0x10,%esp
  end_op();
80106165:	e8 78 d4 ff ff       	call   801035e2 <end_op>
  return 0;
8010616a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010616f:	c9                   	leave  
80106170:	c3                   	ret    

80106171 <sys_mknod>:

int
sys_mknod(void)
{
80106171:	55                   	push   %ebp
80106172:	89 e5                	mov    %esp,%ebp
80106174:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106177:	e8 da d3 ff ff       	call   80103556 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010617c:	83 ec 08             	sub    $0x8,%esp
8010617f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106182:	50                   	push   %eax
80106183:	6a 00                	push   $0x0
80106185:	e8 e7 f4 ff ff       	call   80105671 <argstr>
8010618a:	83 c4 10             	add    $0x10,%esp
8010618d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106190:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106194:	78 4f                	js     801061e5 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106196:	83 ec 08             	sub    $0x8,%esp
80106199:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010619c:	50                   	push   %eax
8010619d:	6a 01                	push   $0x1
8010619f:	e8 48 f4 ff ff       	call   801055ec <argint>
801061a4:	83 c4 10             	add    $0x10,%esp
  if((len=argstr(0, &path)) < 0 ||
801061a7:	85 c0                	test   %eax,%eax
801061a9:	78 3a                	js     801061e5 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
801061ab:	83 ec 08             	sub    $0x8,%esp
801061ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061b1:	50                   	push   %eax
801061b2:	6a 02                	push   $0x2
801061b4:	e8 33 f4 ff ff       	call   801055ec <argint>
801061b9:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801061bc:	85 c0                	test   %eax,%eax
801061be:	78 25                	js     801061e5 <sys_mknod+0x74>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061c3:	0f bf c8             	movswl %ax,%ecx
801061c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061c9:	0f bf d0             	movswl %ax,%edx
801061cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061cf:	51                   	push   %ecx
801061d0:	52                   	push   %edx
801061d1:	6a 03                	push   $0x3
801061d3:	50                   	push   %eax
801061d4:	e8 c8 fb ff ff       	call   80105da1 <create>
801061d9:	83 c4 10             	add    $0x10,%esp
801061dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
     argint(2, &minor) < 0 ||
801061df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061e3:	75 0c                	jne    801061f1 <sys_mknod+0x80>
    end_op();
801061e5:	e8 f8 d3 ff ff       	call   801035e2 <end_op>
    return -1;
801061ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ef:	eb 18                	jmp    80106209 <sys_mknod+0x98>
  }
  iunlockput(ip);
801061f1:	83 ec 0c             	sub    $0xc,%esp
801061f4:	ff 75 f0             	pushl  -0x10(%ebp)
801061f7:	e8 39 ba ff ff       	call   80101c35 <iunlockput>
801061fc:	83 c4 10             	add    $0x10,%esp
  end_op();
801061ff:	e8 de d3 ff ff       	call   801035e2 <end_op>
  return 0;
80106204:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106209:	c9                   	leave  
8010620a:	c3                   	ret    

8010620b <sys_chdir>:

int
sys_chdir(void)
{
8010620b:	55                   	push   %ebp
8010620c:	89 e5                	mov    %esp,%ebp
8010620e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106211:	e8 40 d3 ff ff       	call   80103556 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106216:	83 ec 08             	sub    $0x8,%esp
80106219:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010621c:	50                   	push   %eax
8010621d:	6a 00                	push   $0x0
8010621f:	e8 4d f4 ff ff       	call   80105671 <argstr>
80106224:	83 c4 10             	add    $0x10,%esp
80106227:	85 c0                	test   %eax,%eax
80106229:	78 18                	js     80106243 <sys_chdir+0x38>
8010622b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622e:	83 ec 0c             	sub    $0xc,%esp
80106231:	50                   	push   %eax
80106232:	e8 f3 c2 ff ff       	call   8010252a <namei>
80106237:	83 c4 10             	add    $0x10,%esp
8010623a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010623d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106241:	75 0c                	jne    8010624f <sys_chdir+0x44>
    end_op();
80106243:	e8 9a d3 ff ff       	call   801035e2 <end_op>
    return -1;
80106248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624d:	eb 6e                	jmp    801062bd <sys_chdir+0xb2>
  }
  ilock(ip);
8010624f:	83 ec 0c             	sub    $0xc,%esp
80106252:	ff 75 f4             	pushl  -0xc(%ebp)
80106255:	e8 1b b7 ff ff       	call   80101975 <ilock>
8010625a:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010625d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106260:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106264:	66 83 f8 01          	cmp    $0x1,%ax
80106268:	74 1a                	je     80106284 <sys_chdir+0x79>
    iunlockput(ip);
8010626a:	83 ec 0c             	sub    $0xc,%esp
8010626d:	ff 75 f4             	pushl  -0xc(%ebp)
80106270:	e8 c0 b9 ff ff       	call   80101c35 <iunlockput>
80106275:	83 c4 10             	add    $0x10,%esp
    end_op();
80106278:	e8 65 d3 ff ff       	call   801035e2 <end_op>
    return -1;
8010627d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106282:	eb 39                	jmp    801062bd <sys_chdir+0xb2>
  }
  iunlock(ip);
80106284:	83 ec 0c             	sub    $0xc,%esp
80106287:	ff 75 f4             	pushl  -0xc(%ebp)
8010628a:	e8 44 b8 ff ff       	call   80101ad3 <iunlock>
8010628f:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106292:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106298:	8b 40 68             	mov    0x68(%eax),%eax
8010629b:	83 ec 0c             	sub    $0xc,%esp
8010629e:	50                   	push   %eax
8010629f:	e8 a1 b8 ff ff       	call   80101b45 <iput>
801062a4:	83 c4 10             	add    $0x10,%esp
  end_op();
801062a7:	e8 36 d3 ff ff       	call   801035e2 <end_op>
  proc->cwd = ip;
801062ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062bd:	c9                   	leave  
801062be:	c3                   	ret    

801062bf <sys_exec>:

int
sys_exec(void)
{
801062bf:	55                   	push   %ebp
801062c0:	89 e5                	mov    %esp,%ebp
801062c2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062c8:	83 ec 08             	sub    $0x8,%esp
801062cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062ce:	50                   	push   %eax
801062cf:	6a 00                	push   $0x0
801062d1:	e8 9b f3 ff ff       	call   80105671 <argstr>
801062d6:	83 c4 10             	add    $0x10,%esp
801062d9:	85 c0                	test   %eax,%eax
801062db:	78 18                	js     801062f5 <sys_exec+0x36>
801062dd:	83 ec 08             	sub    $0x8,%esp
801062e0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062e6:	50                   	push   %eax
801062e7:	6a 01                	push   $0x1
801062e9:	e8 fe f2 ff ff       	call   801055ec <argint>
801062ee:	83 c4 10             	add    $0x10,%esp
801062f1:	85 c0                	test   %eax,%eax
801062f3:	79 0a                	jns    801062ff <sys_exec+0x40>
    return -1;
801062f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fa:	e9 c6 00 00 00       	jmp    801063c5 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801062ff:	83 ec 04             	sub    $0x4,%esp
80106302:	68 80 00 00 00       	push   $0x80
80106307:	6a 00                	push   $0x0
80106309:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010630f:	50                   	push   %eax
80106310:	e8 b2 ef ff ff       	call   801052c7 <memset>
80106315:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106318:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010631f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106322:	83 f8 1f             	cmp    $0x1f,%eax
80106325:	76 0a                	jbe    80106331 <sys_exec+0x72>
      return -1;
80106327:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632c:	e9 94 00 00 00       	jmp    801063c5 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106334:	c1 e0 02             	shl    $0x2,%eax
80106337:	89 c2                	mov    %eax,%edx
80106339:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010633f:	01 c2                	add    %eax,%edx
80106341:	83 ec 08             	sub    $0x8,%esp
80106344:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010634a:	50                   	push   %eax
8010634b:	52                   	push   %edx
8010634c:	e8 ff f1 ff ff       	call   80105550 <fetchint>
80106351:	83 c4 10             	add    $0x10,%esp
80106354:	85 c0                	test   %eax,%eax
80106356:	79 07                	jns    8010635f <sys_exec+0xa0>
      return -1;
80106358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635d:	eb 66                	jmp    801063c5 <sys_exec+0x106>
    if(uarg == 0){
8010635f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106365:	85 c0                	test   %eax,%eax
80106367:	75 27                	jne    80106390 <sys_exec+0xd1>
      argv[i] = 0;
80106369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106373:	00 00 00 00 
      break;
80106377:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637b:	83 ec 08             	sub    $0x8,%esp
8010637e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106384:	52                   	push   %edx
80106385:	50                   	push   %eax
80106386:	e8 f1 a7 ff ff       	call   80100b7c <exec>
8010638b:	83 c4 10             	add    $0x10,%esp
8010638e:	eb 35                	jmp    801063c5 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80106390:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106396:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106399:	c1 e2 02             	shl    $0x2,%edx
8010639c:	01 c2                	add    %eax,%edx
8010639e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063a4:	83 ec 08             	sub    $0x8,%esp
801063a7:	52                   	push   %edx
801063a8:	50                   	push   %eax
801063a9:	e8 dc f1 ff ff       	call   8010558a <fetchstr>
801063ae:	83 c4 10             	add    $0x10,%esp
801063b1:	85 c0                	test   %eax,%eax
801063b3:	79 07                	jns    801063bc <sys_exec+0xfd>
      return -1;
801063b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ba:	eb 09                	jmp    801063c5 <sys_exec+0x106>
  for(i=0;; i++){
801063bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801063c0:	e9 5a ff ff ff       	jmp    8010631f <sys_exec+0x60>
}
801063c5:	c9                   	leave  
801063c6:	c3                   	ret    

801063c7 <sys_pipe>:

int
sys_pipe(void)
{
801063c7:	55                   	push   %ebp
801063c8:	89 e5                	mov    %esp,%ebp
801063ca:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063cd:	83 ec 04             	sub    $0x4,%esp
801063d0:	6a 08                	push   $0x8
801063d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063d5:	50                   	push   %eax
801063d6:	6a 00                	push   $0x0
801063d8:	e8 37 f2 ff ff       	call   80105614 <argptr>
801063dd:	83 c4 10             	add    $0x10,%esp
801063e0:	85 c0                	test   %eax,%eax
801063e2:	79 0a                	jns    801063ee <sys_pipe+0x27>
    return -1;
801063e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e9:	e9 af 00 00 00       	jmp    8010649d <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801063ee:	83 ec 08             	sub    $0x8,%esp
801063f1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063f4:	50                   	push   %eax
801063f5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063f8:	50                   	push   %eax
801063f9:	e8 48 dc ff ff       	call   80104046 <pipealloc>
801063fe:	83 c4 10             	add    $0x10,%esp
80106401:	85 c0                	test   %eax,%eax
80106403:	79 0a                	jns    8010640f <sys_pipe+0x48>
    return -1;
80106405:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640a:	e9 8e 00 00 00       	jmp    8010649d <sys_pipe+0xd6>
  fd0 = -1;
8010640f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106416:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106419:	83 ec 0c             	sub    $0xc,%esp
8010641c:	50                   	push   %eax
8010641d:	e8 79 f3 ff ff       	call   8010579b <fdalloc>
80106422:	83 c4 10             	add    $0x10,%esp
80106425:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106428:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010642c:	78 18                	js     80106446 <sys_pipe+0x7f>
8010642e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106431:	83 ec 0c             	sub    $0xc,%esp
80106434:	50                   	push   %eax
80106435:	e8 61 f3 ff ff       	call   8010579b <fdalloc>
8010643a:	83 c4 10             	add    $0x10,%esp
8010643d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106440:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106444:	79 3f                	jns    80106485 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106446:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010644a:	78 14                	js     80106460 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010644c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106452:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106455:	83 c2 08             	add    $0x8,%edx
80106458:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010645f:	00 
    fileclose(rf);
80106460:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106463:	83 ec 0c             	sub    $0xc,%esp
80106466:	50                   	push   %eax
80106467:	e8 f0 ab ff ff       	call   8010105c <fileclose>
8010646c:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010646f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106472:	83 ec 0c             	sub    $0xc,%esp
80106475:	50                   	push   %eax
80106476:	e8 e1 ab ff ff       	call   8010105c <fileclose>
8010647b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010647e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106483:	eb 18                	jmp    8010649d <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106485:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106488:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010648b:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010648d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106490:	8d 50 04             	lea    0x4(%eax),%edx
80106493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106496:	89 02                	mov    %eax,(%edx)
  return 0;
80106498:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010649d:	c9                   	leave  
8010649e:	c3                   	ret    

8010649f <outw>:
{
8010649f:	55                   	push   %ebp
801064a0:	89 e5                	mov    %esp,%ebp
801064a2:	83 ec 08             	sub    $0x8,%esp
801064a5:	8b 55 08             	mov    0x8(%ebp),%edx
801064a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801064ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801064af:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064b3:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
801064b7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801064bb:	66 ef                	out    %ax,(%dx)
}
801064bd:	90                   	nop
801064be:	c9                   	leave  
801064bf:	c3                   	ret    

801064c0 <sys_uprog_shut>:
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_uprog_shut(void){
801064c0:	55                   	push   %ebp
801064c1:	89 e5                	mov    %esp,%ebp
  outw(0xB004, 0x0|0x2000);
801064c3:	68 00 20 00 00       	push   $0x2000
801064c8:	68 04 b0 00 00       	push   $0xb004
801064cd:	e8 cd ff ff ff       	call   8010649f <outw>
801064d2:	83 c4 08             	add    $0x8,%esp
  outw(0x604, 0x0|0x2000);
801064d5:	68 00 20 00 00       	push   $0x2000
801064da:	68 04 06 00 00       	push   $0x604
801064df:	e8 bb ff ff ff       	call   8010649f <outw>
801064e4:	83 c4 08             	add    $0x8,%esp
  return 0;
801064e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064ec:	c9                   	leave  
801064ed:	c3                   	ret    

801064ee <sys_fork>:

int
sys_fork(void)
{
801064ee:	55                   	push   %ebp
801064ef:	89 e5                	mov    %esp,%ebp
801064f1:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064f4:	e8 5a e2 ff ff       	call   80104753 <fork>
}
801064f9:	c9                   	leave  
801064fa:	c3                   	ret    

801064fb <sys_exit>:

int
sys_exit(void)
{
801064fb:	55                   	push   %ebp
801064fc:	89 e5                	mov    %esp,%ebp
801064fe:	83 ec 08             	sub    $0x8,%esp
  exit();
80106501:	e8 e0 e3 ff ff       	call   801048e6 <exit>
  return 0;  // not reached
80106506:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010650b:	c9                   	leave  
8010650c:	c3                   	ret    

8010650d <sys_wait>:

int
sys_wait(void)
{
8010650d:	55                   	push   %ebp
8010650e:	89 e5                	mov    %esp,%ebp
80106510:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106513:	e8 06 e5 ff ff       	call   80104a1e <wait>
}
80106518:	c9                   	leave  
80106519:	c3                   	ret    

8010651a <sys_kill>:

int
sys_kill(void)
{
8010651a:	55                   	push   %ebp
8010651b:	89 e5                	mov    %esp,%ebp
8010651d:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106520:	83 ec 08             	sub    $0x8,%esp
80106523:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106526:	50                   	push   %eax
80106527:	6a 00                	push   $0x0
80106529:	e8 be f0 ff ff       	call   801055ec <argint>
8010652e:	83 c4 10             	add    $0x10,%esp
80106531:	85 c0                	test   %eax,%eax
80106533:	79 07                	jns    8010653c <sys_kill+0x22>
    return -1;
80106535:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653a:	eb 0f                	jmp    8010654b <sys_kill+0x31>
  return kill(pid);
8010653c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653f:	83 ec 0c             	sub    $0xc,%esp
80106542:	50                   	push   %eax
80106543:	e8 45 e9 ff ff       	call   80104e8d <kill>
80106548:	83 c4 10             	add    $0x10,%esp
}
8010654b:	c9                   	leave  
8010654c:	c3                   	ret    

8010654d <sys_getpid>:

int
sys_getpid(void)
{
8010654d:	55                   	push   %ebp
8010654e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106550:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106556:	8b 40 10             	mov    0x10(%eax),%eax
}
80106559:	5d                   	pop    %ebp
8010655a:	c3                   	ret    

8010655b <sys_sbrk>:

int
sys_sbrk(void)
{
8010655b:	55                   	push   %ebp
8010655c:	89 e5                	mov    %esp,%ebp
8010655e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106561:	83 ec 08             	sub    $0x8,%esp
80106564:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106567:	50                   	push   %eax
80106568:	6a 00                	push   $0x0
8010656a:	e8 7d f0 ff ff       	call   801055ec <argint>
8010656f:	83 c4 10             	add    $0x10,%esp
80106572:	85 c0                	test   %eax,%eax
80106574:	79 07                	jns    8010657d <sys_sbrk+0x22>
    return -1;
80106576:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010657b:	eb 28                	jmp    801065a5 <sys_sbrk+0x4a>
  addr = proc->sz;
8010657d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106583:	8b 00                	mov    (%eax),%eax
80106585:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106588:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010658b:	83 ec 0c             	sub    $0xc,%esp
8010658e:	50                   	push   %eax
8010658f:	e8 1c e1 ff ff       	call   801046b0 <growproc>
80106594:	83 c4 10             	add    $0x10,%esp
80106597:	85 c0                	test   %eax,%eax
80106599:	79 07                	jns    801065a2 <sys_sbrk+0x47>
    return -1;
8010659b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a0:	eb 03                	jmp    801065a5 <sys_sbrk+0x4a>
  return addr;
801065a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065a5:	c9                   	leave  
801065a6:	c3                   	ret    

801065a7 <sys_sleep>:

int
sys_sleep(void)
{
801065a7:	55                   	push   %ebp
801065a8:	89 e5                	mov    %esp,%ebp
801065aa:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801065ad:	83 ec 08             	sub    $0x8,%esp
801065b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065b3:	50                   	push   %eax
801065b4:	6a 00                	push   $0x0
801065b6:	e8 31 f0 ff ff       	call   801055ec <argint>
801065bb:	83 c4 10             	add    $0x10,%esp
801065be:	85 c0                	test   %eax,%eax
801065c0:	79 07                	jns    801065c9 <sys_sleep+0x22>
    return -1;
801065c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c7:	eb 77                	jmp    80106640 <sys_sleep+0x99>
  acquire(&tickslock);
801065c9:	83 ec 0c             	sub    $0xc,%esp
801065cc:	68 a0 48 11 80       	push   $0x801148a0
801065d1:	e8 8e ea ff ff       	call   80105064 <acquire>
801065d6:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065d9:	a1 e0 50 11 80       	mov    0x801150e0,%eax
801065de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065e1:	eb 39                	jmp    8010661c <sys_sleep+0x75>
    if(proc->killed){
801065e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065e9:	8b 40 24             	mov    0x24(%eax),%eax
801065ec:	85 c0                	test   %eax,%eax
801065ee:	74 17                	je     80106607 <sys_sleep+0x60>
      release(&tickslock);
801065f0:	83 ec 0c             	sub    $0xc,%esp
801065f3:	68 a0 48 11 80       	push   $0x801148a0
801065f8:	e8 ce ea ff ff       	call   801050cb <release>
801065fd:	83 c4 10             	add    $0x10,%esp
      return -1;
80106600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106605:	eb 39                	jmp    80106640 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106607:	83 ec 08             	sub    $0x8,%esp
8010660a:	68 a0 48 11 80       	push   $0x801148a0
8010660f:	68 e0 50 11 80       	push   $0x801150e0
80106614:	e8 52 e7 ff ff       	call   80104d6b <sleep>
80106619:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010661c:	a1 e0 50 11 80       	mov    0x801150e0,%eax
80106621:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106624:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106627:	39 d0                	cmp    %edx,%eax
80106629:	72 b8                	jb     801065e3 <sys_sleep+0x3c>
  }
  release(&tickslock);
8010662b:	83 ec 0c             	sub    $0xc,%esp
8010662e:	68 a0 48 11 80       	push   $0x801148a0
80106633:	e8 93 ea ff ff       	call   801050cb <release>
80106638:	83 c4 10             	add    $0x10,%esp
  return 0;
8010663b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106640:	c9                   	leave  
80106641:	c3                   	ret    

80106642 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106642:	55                   	push   %ebp
80106643:	89 e5                	mov    %esp,%ebp
80106645:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106648:	83 ec 0c             	sub    $0xc,%esp
8010664b:	68 a0 48 11 80       	push   $0x801148a0
80106650:	e8 0f ea ff ff       	call   80105064 <acquire>
80106655:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106658:	a1 e0 50 11 80       	mov    0x801150e0,%eax
8010665d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106660:	83 ec 0c             	sub    $0xc,%esp
80106663:	68 a0 48 11 80       	push   $0x801148a0
80106668:	e8 5e ea ff ff       	call   801050cb <release>
8010666d:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106670:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106673:	c9                   	leave  
80106674:	c3                   	ret    

80106675 <sys_enable_sched_trace>:

extern int sched_trace_enabled;
int sys_enable_sched_trace(void)
{
80106675:	55                   	push   %ebp
80106676:	89 e5                	mov    %esp,%ebp
80106678:	83 ec 08             	sub    $0x8,%esp
  if (argint(0, &sched_trace_enabled) < 0)
8010667b:	83 ec 08             	sub    $0x8,%esp
8010667e:	68 48 b6 10 80       	push   $0x8010b648
80106683:	6a 00                	push   $0x0
80106685:	e8 62 ef ff ff       	call   801055ec <argint>
8010668a:	83 c4 10             	add    $0x10,%esp
8010668d:	85 c0                	test   %eax,%eax
8010668f:	79 10                	jns    801066a1 <sys_enable_sched_trace+0x2c>
  {
    cprintf("enable_sched_trace() failed!\n");
80106691:	83 ec 0c             	sub    $0xc,%esp
80106694:	68 e7 8a 10 80       	push   $0x80108ae7
80106699:	e8 26 9d ff ff       	call   801003c4 <cprintf>
8010669e:	83 c4 10             	add    $0x10,%esp
  }

  return 0;
801066a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066a6:	c9                   	leave  
801066a7:	c3                   	ret    

801066a8 <outb>:
{
801066a8:	55                   	push   %ebp
801066a9:	89 e5                	mov    %esp,%ebp
801066ab:	83 ec 08             	sub    $0x8,%esp
801066ae:	8b 45 08             	mov    0x8(%ebp),%eax
801066b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801066b4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066b8:	89 d0                	mov    %edx,%eax
801066ba:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066bd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066c1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066c5:	ee                   	out    %al,(%dx)
}
801066c6:	90                   	nop
801066c7:	c9                   	leave  
801066c8:	c3                   	ret    

801066c9 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801066c9:	55                   	push   %ebp
801066ca:	89 e5                	mov    %esp,%ebp
801066cc:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801066cf:	6a 34                	push   $0x34
801066d1:	6a 43                	push   $0x43
801066d3:	e8 d0 ff ff ff       	call   801066a8 <outb>
801066d8:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801066db:	68 9c 00 00 00       	push   $0x9c
801066e0:	6a 40                	push   $0x40
801066e2:	e8 c1 ff ff ff       	call   801066a8 <outb>
801066e7:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801066ea:	6a 2e                	push   $0x2e
801066ec:	6a 40                	push   $0x40
801066ee:	e8 b5 ff ff ff       	call   801066a8 <outb>
801066f3:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801066f6:	83 ec 0c             	sub    $0xc,%esp
801066f9:	6a 00                	push   $0x0
801066fb:	e8 30 d8 ff ff       	call   80103f30 <picenable>
80106700:	83 c4 10             	add    $0x10,%esp
}
80106703:	90                   	nop
80106704:	c9                   	leave  
80106705:	c3                   	ret    

80106706 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106706:	1e                   	push   %ds
  pushl %es
80106707:	06                   	push   %es
  pushl %fs
80106708:	0f a0                	push   %fs
  pushl %gs
8010670a:	0f a8                	push   %gs
  pushal
8010670c:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010670d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106711:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106713:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106715:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106719:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010671b:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010671d:	54                   	push   %esp
  call trap
8010671e:	e8 d7 01 00 00       	call   801068fa <trap>
  addl $4, %esp
80106723:	83 c4 04             	add    $0x4,%esp

80106726 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106726:	61                   	popa   
  popl %gs
80106727:	0f a9                	pop    %gs
  popl %fs
80106729:	0f a1                	pop    %fs
  popl %es
8010672b:	07                   	pop    %es
  popl %ds
8010672c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010672d:	83 c4 08             	add    $0x8,%esp
  iret
80106730:	cf                   	iret   

80106731 <lidt>:
{
80106731:	55                   	push   %ebp
80106732:	89 e5                	mov    %esp,%ebp
80106734:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106737:	8b 45 0c             	mov    0xc(%ebp),%eax
8010673a:	83 e8 01             	sub    $0x1,%eax
8010673d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106741:	8b 45 08             	mov    0x8(%ebp),%eax
80106744:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106748:	8b 45 08             	mov    0x8(%ebp),%eax
8010674b:	c1 e8 10             	shr    $0x10,%eax
8010674e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106752:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106755:	0f 01 18             	lidtl  (%eax)
}
80106758:	90                   	nop
80106759:	c9                   	leave  
8010675a:	c3                   	ret    

8010675b <rcr2>:
{
8010675b:	55                   	push   %ebp
8010675c:	89 e5                	mov    %esp,%ebp
8010675e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106761:	0f 20 d0             	mov    %cr2,%eax
80106764:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106767:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010676a:	c9                   	leave  
8010676b:	c3                   	ret    

8010676c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010676c:	55                   	push   %ebp
8010676d:	89 e5                	mov    %esp,%ebp
8010676f:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106779:	e9 c3 00 00 00       	jmp    80106841 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010677e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106781:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106788:	89 c2                	mov    %eax,%edx
8010678a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678d:	66 89 14 c5 e0 48 11 	mov    %dx,-0x7feeb720(,%eax,8)
80106794:	80 
80106795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106798:	66 c7 04 c5 e2 48 11 	movw   $0x8,-0x7feeb71e(,%eax,8)
8010679f:	80 08 00 
801067a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a5:	0f b6 14 c5 e4 48 11 	movzbl -0x7feeb71c(,%eax,8),%edx
801067ac:	80 
801067ad:	83 e2 e0             	and    $0xffffffe0,%edx
801067b0:	88 14 c5 e4 48 11 80 	mov    %dl,-0x7feeb71c(,%eax,8)
801067b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ba:	0f b6 14 c5 e4 48 11 	movzbl -0x7feeb71c(,%eax,8),%edx
801067c1:	80 
801067c2:	83 e2 1f             	and    $0x1f,%edx
801067c5:	88 14 c5 e4 48 11 80 	mov    %dl,-0x7feeb71c(,%eax,8)
801067cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067cf:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801067d6:	80 
801067d7:	83 e2 f0             	and    $0xfffffff0,%edx
801067da:	83 ca 0e             	or     $0xe,%edx
801067dd:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801067e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e7:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801067ee:	80 
801067ef:	83 e2 ef             	and    $0xffffffef,%edx
801067f2:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801067f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fc:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
80106803:	80 
80106804:	83 e2 9f             	and    $0xffffff9f,%edx
80106807:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
8010680e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106811:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
80106818:	80 
80106819:	83 ca 80             	or     $0xffffff80,%edx
8010681c:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
80106823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106826:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
8010682d:	c1 e8 10             	shr    $0x10,%eax
80106830:	89 c2                	mov    %eax,%edx
80106832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106835:	66 89 14 c5 e6 48 11 	mov    %dx,-0x7feeb71a(,%eax,8)
8010683c:	80 
  for(i = 0; i < 256; i++)
8010683d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106841:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106848:	0f 8e 30 ff ff ff    	jle    8010677e <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010684e:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106853:	66 a3 e0 4a 11 80    	mov    %ax,0x80114ae0
80106859:	66 c7 05 e2 4a 11 80 	movw   $0x8,0x80114ae2
80106860:	08 00 
80106862:	0f b6 05 e4 4a 11 80 	movzbl 0x80114ae4,%eax
80106869:	83 e0 e0             	and    $0xffffffe0,%eax
8010686c:	a2 e4 4a 11 80       	mov    %al,0x80114ae4
80106871:	0f b6 05 e4 4a 11 80 	movzbl 0x80114ae4,%eax
80106878:	83 e0 1f             	and    $0x1f,%eax
8010687b:	a2 e4 4a 11 80       	mov    %al,0x80114ae4
80106880:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
80106887:	83 c8 0f             	or     $0xf,%eax
8010688a:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
8010688f:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
80106896:	83 e0 ef             	and    $0xffffffef,%eax
80106899:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
8010689e:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
801068a5:	83 c8 60             	or     $0x60,%eax
801068a8:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
801068ad:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
801068b4:	83 c8 80             	or     $0xffffff80,%eax
801068b7:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
801068bc:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801068c1:	c1 e8 10             	shr    $0x10,%eax
801068c4:	66 a3 e6 4a 11 80    	mov    %ax,0x80114ae6
  
  initlock(&tickslock, "time");
801068ca:	83 ec 08             	sub    $0x8,%esp
801068cd:	68 08 8b 10 80       	push   $0x80108b08
801068d2:	68 a0 48 11 80       	push   $0x801148a0
801068d7:	e8 66 e7 ff ff       	call   80105042 <initlock>
801068dc:	83 c4 10             	add    $0x10,%esp
}
801068df:	90                   	nop
801068e0:	c9                   	leave  
801068e1:	c3                   	ret    

801068e2 <idtinit>:

void
idtinit(void)
{
801068e2:	55                   	push   %ebp
801068e3:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801068e5:	68 00 08 00 00       	push   $0x800
801068ea:	68 e0 48 11 80       	push   $0x801148e0
801068ef:	e8 3d fe ff ff       	call   80106731 <lidt>
801068f4:	83 c4 08             	add    $0x8,%esp
}
801068f7:	90                   	nop
801068f8:	c9                   	leave  
801068f9:	c3                   	ret    

801068fa <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801068fa:	55                   	push   %ebp
801068fb:	89 e5                	mov    %esp,%ebp
801068fd:	57                   	push   %edi
801068fe:	56                   	push   %esi
801068ff:	53                   	push   %ebx
80106900:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106903:	8b 45 08             	mov    0x8(%ebp),%eax
80106906:	8b 40 30             	mov    0x30(%eax),%eax
80106909:	83 f8 40             	cmp    $0x40,%eax
8010690c:	75 3e                	jne    8010694c <trap+0x52>
    if(proc->killed)
8010690e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106914:	8b 40 24             	mov    0x24(%eax),%eax
80106917:	85 c0                	test   %eax,%eax
80106919:	74 05                	je     80106920 <trap+0x26>
      exit();
8010691b:	e8 c6 df ff ff       	call   801048e6 <exit>
    proc->tf = tf;
80106920:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106926:	8b 55 08             	mov    0x8(%ebp),%edx
80106929:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010692c:	e8 71 ed ff ff       	call   801056a2 <syscall>
    if(proc->killed)
80106931:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106937:	8b 40 24             	mov    0x24(%eax),%eax
8010693a:	85 c0                	test   %eax,%eax
8010693c:	0f 84 1b 02 00 00    	je     80106b5d <trap+0x263>
      exit();
80106942:	e8 9f df ff ff       	call   801048e6 <exit>
    return;
80106947:	e9 11 02 00 00       	jmp    80106b5d <trap+0x263>
  }

  switch(tf->trapno){
8010694c:	8b 45 08             	mov    0x8(%ebp),%eax
8010694f:	8b 40 30             	mov    0x30(%eax),%eax
80106952:	83 e8 20             	sub    $0x20,%eax
80106955:	83 f8 1f             	cmp    $0x1f,%eax
80106958:	0f 87 c0 00 00 00    	ja     80106a1e <trap+0x124>
8010695e:	8b 04 85 b0 8b 10 80 	mov    -0x7fef7450(,%eax,4),%eax
80106965:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106967:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010696d:	0f b6 00             	movzbl (%eax),%eax
80106970:	84 c0                	test   %al,%al
80106972:	75 3d                	jne    801069b1 <trap+0xb7>
      acquire(&tickslock);
80106974:	83 ec 0c             	sub    $0xc,%esp
80106977:	68 a0 48 11 80       	push   $0x801148a0
8010697c:	e8 e3 e6 ff ff       	call   80105064 <acquire>
80106981:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106984:	a1 e0 50 11 80       	mov    0x801150e0,%eax
80106989:	83 c0 01             	add    $0x1,%eax
8010698c:	a3 e0 50 11 80       	mov    %eax,0x801150e0
      wakeup(&ticks);
80106991:	83 ec 0c             	sub    $0xc,%esp
80106994:	68 e0 50 11 80       	push   $0x801150e0
80106999:	e8 b8 e4 ff ff       	call   80104e56 <wakeup>
8010699e:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801069a1:	83 ec 0c             	sub    $0xc,%esp
801069a4:	68 a0 48 11 80       	push   $0x801148a0
801069a9:	e8 1d e7 ff ff       	call   801050cb <release>
801069ae:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801069b1:	e8 76 c6 ff ff       	call   8010302c <lapiceoi>
    break;
801069b6:	e9 1c 01 00 00       	jmp    80106ad7 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801069bb:	e8 7c be ff ff       	call   8010283c <ideintr>
    lapiceoi();
801069c0:	e8 67 c6 ff ff       	call   8010302c <lapiceoi>
    break;
801069c5:	e9 0d 01 00 00       	jmp    80106ad7 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801069ca:	e8 5c c4 ff ff       	call   80102e2b <kbdintr>
    lapiceoi();
801069cf:	e8 58 c6 ff ff       	call   8010302c <lapiceoi>
    break;
801069d4:	e9 fe 00 00 00       	jmp    80106ad7 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801069d9:	e8 62 03 00 00       	call   80106d40 <uartintr>
    lapiceoi();
801069de:	e8 49 c6 ff ff       	call   8010302c <lapiceoi>
    break;
801069e3:	e9 ef 00 00 00       	jmp    80106ad7 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069e8:	8b 45 08             	mov    0x8(%ebp),%eax
801069eb:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801069ee:	8b 45 08             	mov    0x8(%ebp),%eax
801069f1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069f5:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801069f8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069fe:	0f b6 00             	movzbl (%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a01:	0f b6 c0             	movzbl %al,%eax
80106a04:	51                   	push   %ecx
80106a05:	52                   	push   %edx
80106a06:	50                   	push   %eax
80106a07:	68 10 8b 10 80       	push   $0x80108b10
80106a0c:	e8 b3 99 ff ff       	call   801003c4 <cprintf>
80106a11:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106a14:	e8 13 c6 ff ff       	call   8010302c <lapiceoi>
    break;
80106a19:	e9 b9 00 00 00       	jmp    80106ad7 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a24:	85 c0                	test   %eax,%eax
80106a26:	74 11                	je     80106a39 <trap+0x13f>
80106a28:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a2f:	0f b7 c0             	movzwl %ax,%eax
80106a32:	83 e0 03             	and    $0x3,%eax
80106a35:	85 c0                	test   %eax,%eax
80106a37:	75 40                	jne    80106a79 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a39:	e8 1d fd ff ff       	call   8010675b <rcr2>
80106a3e:	89 c3                	mov    %eax,%ebx
80106a40:	8b 45 08             	mov    0x8(%ebp),%eax
80106a43:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106a46:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a4c:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a4f:	0f b6 d0             	movzbl %al,%edx
80106a52:	8b 45 08             	mov    0x8(%ebp),%eax
80106a55:	8b 40 30             	mov    0x30(%eax),%eax
80106a58:	83 ec 0c             	sub    $0xc,%esp
80106a5b:	53                   	push   %ebx
80106a5c:	51                   	push   %ecx
80106a5d:	52                   	push   %edx
80106a5e:	50                   	push   %eax
80106a5f:	68 34 8b 10 80       	push   $0x80108b34
80106a64:	e8 5b 99 ff ff       	call   801003c4 <cprintf>
80106a69:	83 c4 20             	add    $0x20,%esp
      panic("trap");
80106a6c:	83 ec 0c             	sub    $0xc,%esp
80106a6f:	68 66 8b 10 80       	push   $0x80108b66
80106a74:	e8 ee 9a ff ff       	call   80100567 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a79:	e8 dd fc ff ff       	call   8010675b <rcr2>
80106a7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a81:	8b 45 08             	mov    0x8(%ebp),%eax
80106a84:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a87:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a8d:	0f b6 00             	movzbl (%eax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a90:	0f b6 d8             	movzbl %al,%ebx
80106a93:	8b 45 08             	mov    0x8(%ebp),%eax
80106a96:	8b 48 34             	mov    0x34(%eax),%ecx
80106a99:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9c:	8b 50 30             	mov    0x30(%eax),%edx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aa5:	8d 78 6c             	lea    0x6c(%eax),%edi
80106aa8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106aae:	8b 40 10             	mov    0x10(%eax),%eax
80106ab1:	ff 75 e4             	pushl  -0x1c(%ebp)
80106ab4:	56                   	push   %esi
80106ab5:	53                   	push   %ebx
80106ab6:	51                   	push   %ecx
80106ab7:	52                   	push   %edx
80106ab8:	57                   	push   %edi
80106ab9:	50                   	push   %eax
80106aba:	68 6c 8b 10 80       	push   $0x80108b6c
80106abf:	e8 00 99 ff ff       	call   801003c4 <cprintf>
80106ac4:	83 c4 20             	add    $0x20,%esp
            rcr2());
    proc->killed = 1;
80106ac7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106acd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ad4:	eb 01                	jmp    80106ad7 <trap+0x1dd>
    break;
80106ad6:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ad7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106add:	85 c0                	test   %eax,%eax
80106adf:	74 24                	je     80106b05 <trap+0x20b>
80106ae1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ae7:	8b 40 24             	mov    0x24(%eax),%eax
80106aea:	85 c0                	test   %eax,%eax
80106aec:	74 17                	je     80106b05 <trap+0x20b>
80106aee:	8b 45 08             	mov    0x8(%ebp),%eax
80106af1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106af5:	0f b7 c0             	movzwl %ax,%eax
80106af8:	83 e0 03             	and    $0x3,%eax
80106afb:	83 f8 03             	cmp    $0x3,%eax
80106afe:	75 05                	jne    80106b05 <trap+0x20b>
    exit();
80106b00:	e8 e1 dd ff ff       	call   801048e6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106b05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b0b:	85 c0                	test   %eax,%eax
80106b0d:	74 1e                	je     80106b2d <trap+0x233>
80106b0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b15:	8b 40 0c             	mov    0xc(%eax),%eax
80106b18:	83 f8 04             	cmp    $0x4,%eax
80106b1b:	75 10                	jne    80106b2d <trap+0x233>
80106b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b20:	8b 40 30             	mov    0x30(%eax),%eax
80106b23:	83 f8 20             	cmp    $0x20,%eax
80106b26:	75 05                	jne    80106b2d <trap+0x233>
    yield();
80106b28:	e8 9a e1 ff ff       	call   80104cc7 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b33:	85 c0                	test   %eax,%eax
80106b35:	74 27                	je     80106b5e <trap+0x264>
80106b37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b3d:	8b 40 24             	mov    0x24(%eax),%eax
80106b40:	85 c0                	test   %eax,%eax
80106b42:	74 1a                	je     80106b5e <trap+0x264>
80106b44:	8b 45 08             	mov    0x8(%ebp),%eax
80106b47:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b4b:	0f b7 c0             	movzwl %ax,%eax
80106b4e:	83 e0 03             	and    $0x3,%eax
80106b51:	83 f8 03             	cmp    $0x3,%eax
80106b54:	75 08                	jne    80106b5e <trap+0x264>
    exit();
80106b56:	e8 8b dd ff ff       	call   801048e6 <exit>
80106b5b:	eb 01                	jmp    80106b5e <trap+0x264>
    return;
80106b5d:	90                   	nop
}
80106b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b61:	5b                   	pop    %ebx
80106b62:	5e                   	pop    %esi
80106b63:	5f                   	pop    %edi
80106b64:	5d                   	pop    %ebp
80106b65:	c3                   	ret    

80106b66 <inb>:
{
80106b66:	55                   	push   %ebp
80106b67:	89 e5                	mov    %esp,%ebp
80106b69:	83 ec 14             	sub    $0x14,%esp
80106b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b6f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b73:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b77:	89 c2                	mov    %eax,%edx
80106b79:	ec                   	in     (%dx),%al
80106b7a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b7d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b81:	c9                   	leave  
80106b82:	c3                   	ret    

80106b83 <outb>:
{
80106b83:	55                   	push   %ebp
80106b84:	89 e5                	mov    %esp,%ebp
80106b86:	83 ec 08             	sub    $0x8,%esp
80106b89:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80106b8f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106b93:	89 d0                	mov    %edx,%eax
80106b95:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b98:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b9c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ba0:	ee                   	out    %al,(%dx)
}
80106ba1:	90                   	nop
80106ba2:	c9                   	leave  
80106ba3:	c3                   	ret    

80106ba4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ba4:	55                   	push   %ebp
80106ba5:	89 e5                	mov    %esp,%ebp
80106ba7:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106baa:	6a 00                	push   $0x0
80106bac:	68 fa 03 00 00       	push   $0x3fa
80106bb1:	e8 cd ff ff ff       	call   80106b83 <outb>
80106bb6:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106bb9:	68 80 00 00 00       	push   $0x80
80106bbe:	68 fb 03 00 00       	push   $0x3fb
80106bc3:	e8 bb ff ff ff       	call   80106b83 <outb>
80106bc8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106bcb:	6a 0c                	push   $0xc
80106bcd:	68 f8 03 00 00       	push   $0x3f8
80106bd2:	e8 ac ff ff ff       	call   80106b83 <outb>
80106bd7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106bda:	6a 00                	push   $0x0
80106bdc:	68 f9 03 00 00       	push   $0x3f9
80106be1:	e8 9d ff ff ff       	call   80106b83 <outb>
80106be6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106be9:	6a 03                	push   $0x3
80106beb:	68 fb 03 00 00       	push   $0x3fb
80106bf0:	e8 8e ff ff ff       	call   80106b83 <outb>
80106bf5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106bf8:	6a 00                	push   $0x0
80106bfa:	68 fc 03 00 00       	push   $0x3fc
80106bff:	e8 7f ff ff ff       	call   80106b83 <outb>
80106c04:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c07:	6a 01                	push   $0x1
80106c09:	68 f9 03 00 00       	push   $0x3f9
80106c0e:	e8 70 ff ff ff       	call   80106b83 <outb>
80106c13:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c16:	68 fd 03 00 00       	push   $0x3fd
80106c1b:	e8 46 ff ff ff       	call   80106b66 <inb>
80106c20:	83 c4 04             	add    $0x4,%esp
80106c23:	3c ff                	cmp    $0xff,%al
80106c25:	74 6e                	je     80106c95 <uartinit+0xf1>
    return;
  uart = 1;
80106c27:	c7 05 50 b6 10 80 01 	movl   $0x1,0x8010b650
80106c2e:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c31:	68 fa 03 00 00       	push   $0x3fa
80106c36:	e8 2b ff ff ff       	call   80106b66 <inb>
80106c3b:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106c3e:	68 f8 03 00 00       	push   $0x3f8
80106c43:	e8 1e ff ff ff       	call   80106b66 <inb>
80106c48:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106c4b:	83 ec 0c             	sub    $0xc,%esp
80106c4e:	6a 04                	push   $0x4
80106c50:	e8 db d2 ff ff       	call   80103f30 <picenable>
80106c55:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106c58:	83 ec 08             	sub    $0x8,%esp
80106c5b:	6a 00                	push   $0x0
80106c5d:	6a 04                	push   $0x4
80106c5f:	e8 7a be ff ff       	call   80102ade <ioapicenable>
80106c64:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c67:	c7 45 f4 30 8c 10 80 	movl   $0x80108c30,-0xc(%ebp)
80106c6e:	eb 19                	jmp    80106c89 <uartinit+0xe5>
    uartputc(*p);
80106c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c73:	0f b6 00             	movzbl (%eax),%eax
80106c76:	0f be c0             	movsbl %al,%eax
80106c79:	83 ec 0c             	sub    $0xc,%esp
80106c7c:	50                   	push   %eax
80106c7d:	e8 16 00 00 00       	call   80106c98 <uartputc>
80106c82:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106c85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c8c:	0f b6 00             	movzbl (%eax),%eax
80106c8f:	84 c0                	test   %al,%al
80106c91:	75 dd                	jne    80106c70 <uartinit+0xcc>
80106c93:	eb 01                	jmp    80106c96 <uartinit+0xf2>
    return;
80106c95:	90                   	nop
}
80106c96:	c9                   	leave  
80106c97:	c3                   	ret    

80106c98 <uartputc>:

void
uartputc(int c)
{
80106c98:	55                   	push   %ebp
80106c99:	89 e5                	mov    %esp,%ebp
80106c9b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c9e:	a1 50 b6 10 80       	mov    0x8010b650,%eax
80106ca3:	85 c0                	test   %eax,%eax
80106ca5:	74 53                	je     80106cfa <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106cae:	eb 11                	jmp    80106cc1 <uartputc+0x29>
    microdelay(10);
80106cb0:	83 ec 0c             	sub    $0xc,%esp
80106cb3:	6a 0a                	push   $0xa
80106cb5:	e8 8d c3 ff ff       	call   80103047 <microdelay>
80106cba:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cbd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cc1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106cc5:	7f 1a                	jg     80106ce1 <uartputc+0x49>
80106cc7:	83 ec 0c             	sub    $0xc,%esp
80106cca:	68 fd 03 00 00       	push   $0x3fd
80106ccf:	e8 92 fe ff ff       	call   80106b66 <inb>
80106cd4:	83 c4 10             	add    $0x10,%esp
80106cd7:	0f b6 c0             	movzbl %al,%eax
80106cda:	83 e0 20             	and    $0x20,%eax
80106cdd:	85 c0                	test   %eax,%eax
80106cdf:	74 cf                	je     80106cb0 <uartputc+0x18>
  outb(COM1+0, c);
80106ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce4:	0f b6 c0             	movzbl %al,%eax
80106ce7:	83 ec 08             	sub    $0x8,%esp
80106cea:	50                   	push   %eax
80106ceb:	68 f8 03 00 00       	push   $0x3f8
80106cf0:	e8 8e fe ff ff       	call   80106b83 <outb>
80106cf5:	83 c4 10             	add    $0x10,%esp
80106cf8:	eb 01                	jmp    80106cfb <uartputc+0x63>
    return;
80106cfa:	90                   	nop
}
80106cfb:	c9                   	leave  
80106cfc:	c3                   	ret    

80106cfd <uartgetc>:

static int
uartgetc(void)
{
80106cfd:	55                   	push   %ebp
80106cfe:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106d00:	a1 50 b6 10 80       	mov    0x8010b650,%eax
80106d05:	85 c0                	test   %eax,%eax
80106d07:	75 07                	jne    80106d10 <uartgetc+0x13>
    return -1;
80106d09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d0e:	eb 2e                	jmp    80106d3e <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106d10:	68 fd 03 00 00       	push   $0x3fd
80106d15:	e8 4c fe ff ff       	call   80106b66 <inb>
80106d1a:	83 c4 04             	add    $0x4,%esp
80106d1d:	0f b6 c0             	movzbl %al,%eax
80106d20:	83 e0 01             	and    $0x1,%eax
80106d23:	85 c0                	test   %eax,%eax
80106d25:	75 07                	jne    80106d2e <uartgetc+0x31>
    return -1;
80106d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d2c:	eb 10                	jmp    80106d3e <uartgetc+0x41>
  return inb(COM1+0);
80106d2e:	68 f8 03 00 00       	push   $0x3f8
80106d33:	e8 2e fe ff ff       	call   80106b66 <inb>
80106d38:	83 c4 04             	add    $0x4,%esp
80106d3b:	0f b6 c0             	movzbl %al,%eax
}
80106d3e:	c9                   	leave  
80106d3f:	c3                   	ret    

80106d40 <uartintr>:

void
uartintr(void)
{
80106d40:	55                   	push   %ebp
80106d41:	89 e5                	mov    %esp,%ebp
80106d43:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106d46:	83 ec 0c             	sub    $0xc,%esp
80106d49:	68 fd 6c 10 80       	push   $0x80106cfd
80106d4e:	e8 af 9a ff ff       	call   80100802 <consoleintr>
80106d53:	83 c4 10             	add    $0x10,%esp
}
80106d56:	90                   	nop
80106d57:	c9                   	leave  
80106d58:	c3                   	ret    

80106d59 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $0
80106d5b:	6a 00                	push   $0x0
  jmp alltraps
80106d5d:	e9 a4 f9 ff ff       	jmp    80106706 <alltraps>

80106d62 <vector1>:
.globl vector1
vector1:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $1
80106d64:	6a 01                	push   $0x1
  jmp alltraps
80106d66:	e9 9b f9 ff ff       	jmp    80106706 <alltraps>

80106d6b <vector2>:
.globl vector2
vector2:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $2
80106d6d:	6a 02                	push   $0x2
  jmp alltraps
80106d6f:	e9 92 f9 ff ff       	jmp    80106706 <alltraps>

80106d74 <vector3>:
.globl vector3
vector3:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $3
80106d76:	6a 03                	push   $0x3
  jmp alltraps
80106d78:	e9 89 f9 ff ff       	jmp    80106706 <alltraps>

80106d7d <vector4>:
.globl vector4
vector4:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $4
80106d7f:	6a 04                	push   $0x4
  jmp alltraps
80106d81:	e9 80 f9 ff ff       	jmp    80106706 <alltraps>

80106d86 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $5
80106d88:	6a 05                	push   $0x5
  jmp alltraps
80106d8a:	e9 77 f9 ff ff       	jmp    80106706 <alltraps>

80106d8f <vector6>:
.globl vector6
vector6:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $6
80106d91:	6a 06                	push   $0x6
  jmp alltraps
80106d93:	e9 6e f9 ff ff       	jmp    80106706 <alltraps>

80106d98 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $7
80106d9a:	6a 07                	push   $0x7
  jmp alltraps
80106d9c:	e9 65 f9 ff ff       	jmp    80106706 <alltraps>

80106da1 <vector8>:
.globl vector8
vector8:
  pushl $8
80106da1:	6a 08                	push   $0x8
  jmp alltraps
80106da3:	e9 5e f9 ff ff       	jmp    80106706 <alltraps>

80106da8 <vector9>:
.globl vector9
vector9:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $9
80106daa:	6a 09                	push   $0x9
  jmp alltraps
80106dac:	e9 55 f9 ff ff       	jmp    80106706 <alltraps>

80106db1 <vector10>:
.globl vector10
vector10:
  pushl $10
80106db1:	6a 0a                	push   $0xa
  jmp alltraps
80106db3:	e9 4e f9 ff ff       	jmp    80106706 <alltraps>

80106db8 <vector11>:
.globl vector11
vector11:
  pushl $11
80106db8:	6a 0b                	push   $0xb
  jmp alltraps
80106dba:	e9 47 f9 ff ff       	jmp    80106706 <alltraps>

80106dbf <vector12>:
.globl vector12
vector12:
  pushl $12
80106dbf:	6a 0c                	push   $0xc
  jmp alltraps
80106dc1:	e9 40 f9 ff ff       	jmp    80106706 <alltraps>

80106dc6 <vector13>:
.globl vector13
vector13:
  pushl $13
80106dc6:	6a 0d                	push   $0xd
  jmp alltraps
80106dc8:	e9 39 f9 ff ff       	jmp    80106706 <alltraps>

80106dcd <vector14>:
.globl vector14
vector14:
  pushl $14
80106dcd:	6a 0e                	push   $0xe
  jmp alltraps
80106dcf:	e9 32 f9 ff ff       	jmp    80106706 <alltraps>

80106dd4 <vector15>:
.globl vector15
vector15:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $15
80106dd6:	6a 0f                	push   $0xf
  jmp alltraps
80106dd8:	e9 29 f9 ff ff       	jmp    80106706 <alltraps>

80106ddd <vector16>:
.globl vector16
vector16:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $16
80106ddf:	6a 10                	push   $0x10
  jmp alltraps
80106de1:	e9 20 f9 ff ff       	jmp    80106706 <alltraps>

80106de6 <vector17>:
.globl vector17
vector17:
  pushl $17
80106de6:	6a 11                	push   $0x11
  jmp alltraps
80106de8:	e9 19 f9 ff ff       	jmp    80106706 <alltraps>

80106ded <vector18>:
.globl vector18
vector18:
  pushl $0
80106ded:	6a 00                	push   $0x0
  pushl $18
80106def:	6a 12                	push   $0x12
  jmp alltraps
80106df1:	e9 10 f9 ff ff       	jmp    80106706 <alltraps>

80106df6 <vector19>:
.globl vector19
vector19:
  pushl $0
80106df6:	6a 00                	push   $0x0
  pushl $19
80106df8:	6a 13                	push   $0x13
  jmp alltraps
80106dfa:	e9 07 f9 ff ff       	jmp    80106706 <alltraps>

80106dff <vector20>:
.globl vector20
vector20:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $20
80106e01:	6a 14                	push   $0x14
  jmp alltraps
80106e03:	e9 fe f8 ff ff       	jmp    80106706 <alltraps>

80106e08 <vector21>:
.globl vector21
vector21:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $21
80106e0a:	6a 15                	push   $0x15
  jmp alltraps
80106e0c:	e9 f5 f8 ff ff       	jmp    80106706 <alltraps>

80106e11 <vector22>:
.globl vector22
vector22:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $22
80106e13:	6a 16                	push   $0x16
  jmp alltraps
80106e15:	e9 ec f8 ff ff       	jmp    80106706 <alltraps>

80106e1a <vector23>:
.globl vector23
vector23:
  pushl $0
80106e1a:	6a 00                	push   $0x0
  pushl $23
80106e1c:	6a 17                	push   $0x17
  jmp alltraps
80106e1e:	e9 e3 f8 ff ff       	jmp    80106706 <alltraps>

80106e23 <vector24>:
.globl vector24
vector24:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $24
80106e25:	6a 18                	push   $0x18
  jmp alltraps
80106e27:	e9 da f8 ff ff       	jmp    80106706 <alltraps>

80106e2c <vector25>:
.globl vector25
vector25:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $25
80106e2e:	6a 19                	push   $0x19
  jmp alltraps
80106e30:	e9 d1 f8 ff ff       	jmp    80106706 <alltraps>

80106e35 <vector26>:
.globl vector26
vector26:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $26
80106e37:	6a 1a                	push   $0x1a
  jmp alltraps
80106e39:	e9 c8 f8 ff ff       	jmp    80106706 <alltraps>

80106e3e <vector27>:
.globl vector27
vector27:
  pushl $0
80106e3e:	6a 00                	push   $0x0
  pushl $27
80106e40:	6a 1b                	push   $0x1b
  jmp alltraps
80106e42:	e9 bf f8 ff ff       	jmp    80106706 <alltraps>

80106e47 <vector28>:
.globl vector28
vector28:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $28
80106e49:	6a 1c                	push   $0x1c
  jmp alltraps
80106e4b:	e9 b6 f8 ff ff       	jmp    80106706 <alltraps>

80106e50 <vector29>:
.globl vector29
vector29:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $29
80106e52:	6a 1d                	push   $0x1d
  jmp alltraps
80106e54:	e9 ad f8 ff ff       	jmp    80106706 <alltraps>

80106e59 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $30
80106e5b:	6a 1e                	push   $0x1e
  jmp alltraps
80106e5d:	e9 a4 f8 ff ff       	jmp    80106706 <alltraps>

80106e62 <vector31>:
.globl vector31
vector31:
  pushl $0
80106e62:	6a 00                	push   $0x0
  pushl $31
80106e64:	6a 1f                	push   $0x1f
  jmp alltraps
80106e66:	e9 9b f8 ff ff       	jmp    80106706 <alltraps>

80106e6b <vector32>:
.globl vector32
vector32:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $32
80106e6d:	6a 20                	push   $0x20
  jmp alltraps
80106e6f:	e9 92 f8 ff ff       	jmp    80106706 <alltraps>

80106e74 <vector33>:
.globl vector33
vector33:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $33
80106e76:	6a 21                	push   $0x21
  jmp alltraps
80106e78:	e9 89 f8 ff ff       	jmp    80106706 <alltraps>

80106e7d <vector34>:
.globl vector34
vector34:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $34
80106e7f:	6a 22                	push   $0x22
  jmp alltraps
80106e81:	e9 80 f8 ff ff       	jmp    80106706 <alltraps>

80106e86 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $35
80106e88:	6a 23                	push   $0x23
  jmp alltraps
80106e8a:	e9 77 f8 ff ff       	jmp    80106706 <alltraps>

80106e8f <vector36>:
.globl vector36
vector36:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $36
80106e91:	6a 24                	push   $0x24
  jmp alltraps
80106e93:	e9 6e f8 ff ff       	jmp    80106706 <alltraps>

80106e98 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $37
80106e9a:	6a 25                	push   $0x25
  jmp alltraps
80106e9c:	e9 65 f8 ff ff       	jmp    80106706 <alltraps>

80106ea1 <vector38>:
.globl vector38
vector38:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $38
80106ea3:	6a 26                	push   $0x26
  jmp alltraps
80106ea5:	e9 5c f8 ff ff       	jmp    80106706 <alltraps>

80106eaa <vector39>:
.globl vector39
vector39:
  pushl $0
80106eaa:	6a 00                	push   $0x0
  pushl $39
80106eac:	6a 27                	push   $0x27
  jmp alltraps
80106eae:	e9 53 f8 ff ff       	jmp    80106706 <alltraps>

80106eb3 <vector40>:
.globl vector40
vector40:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $40
80106eb5:	6a 28                	push   $0x28
  jmp alltraps
80106eb7:	e9 4a f8 ff ff       	jmp    80106706 <alltraps>

80106ebc <vector41>:
.globl vector41
vector41:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $41
80106ebe:	6a 29                	push   $0x29
  jmp alltraps
80106ec0:	e9 41 f8 ff ff       	jmp    80106706 <alltraps>

80106ec5 <vector42>:
.globl vector42
vector42:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $42
80106ec7:	6a 2a                	push   $0x2a
  jmp alltraps
80106ec9:	e9 38 f8 ff ff       	jmp    80106706 <alltraps>

80106ece <vector43>:
.globl vector43
vector43:
  pushl $0
80106ece:	6a 00                	push   $0x0
  pushl $43
80106ed0:	6a 2b                	push   $0x2b
  jmp alltraps
80106ed2:	e9 2f f8 ff ff       	jmp    80106706 <alltraps>

80106ed7 <vector44>:
.globl vector44
vector44:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $44
80106ed9:	6a 2c                	push   $0x2c
  jmp alltraps
80106edb:	e9 26 f8 ff ff       	jmp    80106706 <alltraps>

80106ee0 <vector45>:
.globl vector45
vector45:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $45
80106ee2:	6a 2d                	push   $0x2d
  jmp alltraps
80106ee4:	e9 1d f8 ff ff       	jmp    80106706 <alltraps>

80106ee9 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $46
80106eeb:	6a 2e                	push   $0x2e
  jmp alltraps
80106eed:	e9 14 f8 ff ff       	jmp    80106706 <alltraps>

80106ef2 <vector47>:
.globl vector47
vector47:
  pushl $0
80106ef2:	6a 00                	push   $0x0
  pushl $47
80106ef4:	6a 2f                	push   $0x2f
  jmp alltraps
80106ef6:	e9 0b f8 ff ff       	jmp    80106706 <alltraps>

80106efb <vector48>:
.globl vector48
vector48:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $48
80106efd:	6a 30                	push   $0x30
  jmp alltraps
80106eff:	e9 02 f8 ff ff       	jmp    80106706 <alltraps>

80106f04 <vector49>:
.globl vector49
vector49:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $49
80106f06:	6a 31                	push   $0x31
  jmp alltraps
80106f08:	e9 f9 f7 ff ff       	jmp    80106706 <alltraps>

80106f0d <vector50>:
.globl vector50
vector50:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $50
80106f0f:	6a 32                	push   $0x32
  jmp alltraps
80106f11:	e9 f0 f7 ff ff       	jmp    80106706 <alltraps>

80106f16 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $51
80106f18:	6a 33                	push   $0x33
  jmp alltraps
80106f1a:	e9 e7 f7 ff ff       	jmp    80106706 <alltraps>

80106f1f <vector52>:
.globl vector52
vector52:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $52
80106f21:	6a 34                	push   $0x34
  jmp alltraps
80106f23:	e9 de f7 ff ff       	jmp    80106706 <alltraps>

80106f28 <vector53>:
.globl vector53
vector53:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $53
80106f2a:	6a 35                	push   $0x35
  jmp alltraps
80106f2c:	e9 d5 f7 ff ff       	jmp    80106706 <alltraps>

80106f31 <vector54>:
.globl vector54
vector54:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $54
80106f33:	6a 36                	push   $0x36
  jmp alltraps
80106f35:	e9 cc f7 ff ff       	jmp    80106706 <alltraps>

80106f3a <vector55>:
.globl vector55
vector55:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $55
80106f3c:	6a 37                	push   $0x37
  jmp alltraps
80106f3e:	e9 c3 f7 ff ff       	jmp    80106706 <alltraps>

80106f43 <vector56>:
.globl vector56
vector56:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $56
80106f45:	6a 38                	push   $0x38
  jmp alltraps
80106f47:	e9 ba f7 ff ff       	jmp    80106706 <alltraps>

80106f4c <vector57>:
.globl vector57
vector57:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $57
80106f4e:	6a 39                	push   $0x39
  jmp alltraps
80106f50:	e9 b1 f7 ff ff       	jmp    80106706 <alltraps>

80106f55 <vector58>:
.globl vector58
vector58:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $58
80106f57:	6a 3a                	push   $0x3a
  jmp alltraps
80106f59:	e9 a8 f7 ff ff       	jmp    80106706 <alltraps>

80106f5e <vector59>:
.globl vector59
vector59:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $59
80106f60:	6a 3b                	push   $0x3b
  jmp alltraps
80106f62:	e9 9f f7 ff ff       	jmp    80106706 <alltraps>

80106f67 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $60
80106f69:	6a 3c                	push   $0x3c
  jmp alltraps
80106f6b:	e9 96 f7 ff ff       	jmp    80106706 <alltraps>

80106f70 <vector61>:
.globl vector61
vector61:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $61
80106f72:	6a 3d                	push   $0x3d
  jmp alltraps
80106f74:	e9 8d f7 ff ff       	jmp    80106706 <alltraps>

80106f79 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $62
80106f7b:	6a 3e                	push   $0x3e
  jmp alltraps
80106f7d:	e9 84 f7 ff ff       	jmp    80106706 <alltraps>

80106f82 <vector63>:
.globl vector63
vector63:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $63
80106f84:	6a 3f                	push   $0x3f
  jmp alltraps
80106f86:	e9 7b f7 ff ff       	jmp    80106706 <alltraps>

80106f8b <vector64>:
.globl vector64
vector64:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $64
80106f8d:	6a 40                	push   $0x40
  jmp alltraps
80106f8f:	e9 72 f7 ff ff       	jmp    80106706 <alltraps>

80106f94 <vector65>:
.globl vector65
vector65:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $65
80106f96:	6a 41                	push   $0x41
  jmp alltraps
80106f98:	e9 69 f7 ff ff       	jmp    80106706 <alltraps>

80106f9d <vector66>:
.globl vector66
vector66:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $66
80106f9f:	6a 42                	push   $0x42
  jmp alltraps
80106fa1:	e9 60 f7 ff ff       	jmp    80106706 <alltraps>

80106fa6 <vector67>:
.globl vector67
vector67:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $67
80106fa8:	6a 43                	push   $0x43
  jmp alltraps
80106faa:	e9 57 f7 ff ff       	jmp    80106706 <alltraps>

80106faf <vector68>:
.globl vector68
vector68:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $68
80106fb1:	6a 44                	push   $0x44
  jmp alltraps
80106fb3:	e9 4e f7 ff ff       	jmp    80106706 <alltraps>

80106fb8 <vector69>:
.globl vector69
vector69:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $69
80106fba:	6a 45                	push   $0x45
  jmp alltraps
80106fbc:	e9 45 f7 ff ff       	jmp    80106706 <alltraps>

80106fc1 <vector70>:
.globl vector70
vector70:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $70
80106fc3:	6a 46                	push   $0x46
  jmp alltraps
80106fc5:	e9 3c f7 ff ff       	jmp    80106706 <alltraps>

80106fca <vector71>:
.globl vector71
vector71:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $71
80106fcc:	6a 47                	push   $0x47
  jmp alltraps
80106fce:	e9 33 f7 ff ff       	jmp    80106706 <alltraps>

80106fd3 <vector72>:
.globl vector72
vector72:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $72
80106fd5:	6a 48                	push   $0x48
  jmp alltraps
80106fd7:	e9 2a f7 ff ff       	jmp    80106706 <alltraps>

80106fdc <vector73>:
.globl vector73
vector73:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $73
80106fde:	6a 49                	push   $0x49
  jmp alltraps
80106fe0:	e9 21 f7 ff ff       	jmp    80106706 <alltraps>

80106fe5 <vector74>:
.globl vector74
vector74:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $74
80106fe7:	6a 4a                	push   $0x4a
  jmp alltraps
80106fe9:	e9 18 f7 ff ff       	jmp    80106706 <alltraps>

80106fee <vector75>:
.globl vector75
vector75:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $75
80106ff0:	6a 4b                	push   $0x4b
  jmp alltraps
80106ff2:	e9 0f f7 ff ff       	jmp    80106706 <alltraps>

80106ff7 <vector76>:
.globl vector76
vector76:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $76
80106ff9:	6a 4c                	push   $0x4c
  jmp alltraps
80106ffb:	e9 06 f7 ff ff       	jmp    80106706 <alltraps>

80107000 <vector77>:
.globl vector77
vector77:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $77
80107002:	6a 4d                	push   $0x4d
  jmp alltraps
80107004:	e9 fd f6 ff ff       	jmp    80106706 <alltraps>

80107009 <vector78>:
.globl vector78
vector78:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $78
8010700b:	6a 4e                	push   $0x4e
  jmp alltraps
8010700d:	e9 f4 f6 ff ff       	jmp    80106706 <alltraps>

80107012 <vector79>:
.globl vector79
vector79:
  pushl $0
80107012:	6a 00                	push   $0x0
  pushl $79
80107014:	6a 4f                	push   $0x4f
  jmp alltraps
80107016:	e9 eb f6 ff ff       	jmp    80106706 <alltraps>

8010701b <vector80>:
.globl vector80
vector80:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $80
8010701d:	6a 50                	push   $0x50
  jmp alltraps
8010701f:	e9 e2 f6 ff ff       	jmp    80106706 <alltraps>

80107024 <vector81>:
.globl vector81
vector81:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $81
80107026:	6a 51                	push   $0x51
  jmp alltraps
80107028:	e9 d9 f6 ff ff       	jmp    80106706 <alltraps>

8010702d <vector82>:
.globl vector82
vector82:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $82
8010702f:	6a 52                	push   $0x52
  jmp alltraps
80107031:	e9 d0 f6 ff ff       	jmp    80106706 <alltraps>

80107036 <vector83>:
.globl vector83
vector83:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $83
80107038:	6a 53                	push   $0x53
  jmp alltraps
8010703a:	e9 c7 f6 ff ff       	jmp    80106706 <alltraps>

8010703f <vector84>:
.globl vector84
vector84:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $84
80107041:	6a 54                	push   $0x54
  jmp alltraps
80107043:	e9 be f6 ff ff       	jmp    80106706 <alltraps>

80107048 <vector85>:
.globl vector85
vector85:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $85
8010704a:	6a 55                	push   $0x55
  jmp alltraps
8010704c:	e9 b5 f6 ff ff       	jmp    80106706 <alltraps>

80107051 <vector86>:
.globl vector86
vector86:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $86
80107053:	6a 56                	push   $0x56
  jmp alltraps
80107055:	e9 ac f6 ff ff       	jmp    80106706 <alltraps>

8010705a <vector87>:
.globl vector87
vector87:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $87
8010705c:	6a 57                	push   $0x57
  jmp alltraps
8010705e:	e9 a3 f6 ff ff       	jmp    80106706 <alltraps>

80107063 <vector88>:
.globl vector88
vector88:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $88
80107065:	6a 58                	push   $0x58
  jmp alltraps
80107067:	e9 9a f6 ff ff       	jmp    80106706 <alltraps>

8010706c <vector89>:
.globl vector89
vector89:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $89
8010706e:	6a 59                	push   $0x59
  jmp alltraps
80107070:	e9 91 f6 ff ff       	jmp    80106706 <alltraps>

80107075 <vector90>:
.globl vector90
vector90:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $90
80107077:	6a 5a                	push   $0x5a
  jmp alltraps
80107079:	e9 88 f6 ff ff       	jmp    80106706 <alltraps>

8010707e <vector91>:
.globl vector91
vector91:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $91
80107080:	6a 5b                	push   $0x5b
  jmp alltraps
80107082:	e9 7f f6 ff ff       	jmp    80106706 <alltraps>

80107087 <vector92>:
.globl vector92
vector92:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $92
80107089:	6a 5c                	push   $0x5c
  jmp alltraps
8010708b:	e9 76 f6 ff ff       	jmp    80106706 <alltraps>

80107090 <vector93>:
.globl vector93
vector93:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $93
80107092:	6a 5d                	push   $0x5d
  jmp alltraps
80107094:	e9 6d f6 ff ff       	jmp    80106706 <alltraps>

80107099 <vector94>:
.globl vector94
vector94:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $94
8010709b:	6a 5e                	push   $0x5e
  jmp alltraps
8010709d:	e9 64 f6 ff ff       	jmp    80106706 <alltraps>

801070a2 <vector95>:
.globl vector95
vector95:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $95
801070a4:	6a 5f                	push   $0x5f
  jmp alltraps
801070a6:	e9 5b f6 ff ff       	jmp    80106706 <alltraps>

801070ab <vector96>:
.globl vector96
vector96:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $96
801070ad:	6a 60                	push   $0x60
  jmp alltraps
801070af:	e9 52 f6 ff ff       	jmp    80106706 <alltraps>

801070b4 <vector97>:
.globl vector97
vector97:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $97
801070b6:	6a 61                	push   $0x61
  jmp alltraps
801070b8:	e9 49 f6 ff ff       	jmp    80106706 <alltraps>

801070bd <vector98>:
.globl vector98
vector98:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $98
801070bf:	6a 62                	push   $0x62
  jmp alltraps
801070c1:	e9 40 f6 ff ff       	jmp    80106706 <alltraps>

801070c6 <vector99>:
.globl vector99
vector99:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $99
801070c8:	6a 63                	push   $0x63
  jmp alltraps
801070ca:	e9 37 f6 ff ff       	jmp    80106706 <alltraps>

801070cf <vector100>:
.globl vector100
vector100:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $100
801070d1:	6a 64                	push   $0x64
  jmp alltraps
801070d3:	e9 2e f6 ff ff       	jmp    80106706 <alltraps>

801070d8 <vector101>:
.globl vector101
vector101:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $101
801070da:	6a 65                	push   $0x65
  jmp alltraps
801070dc:	e9 25 f6 ff ff       	jmp    80106706 <alltraps>

801070e1 <vector102>:
.globl vector102
vector102:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $102
801070e3:	6a 66                	push   $0x66
  jmp alltraps
801070e5:	e9 1c f6 ff ff       	jmp    80106706 <alltraps>

801070ea <vector103>:
.globl vector103
vector103:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $103
801070ec:	6a 67                	push   $0x67
  jmp alltraps
801070ee:	e9 13 f6 ff ff       	jmp    80106706 <alltraps>

801070f3 <vector104>:
.globl vector104
vector104:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $104
801070f5:	6a 68                	push   $0x68
  jmp alltraps
801070f7:	e9 0a f6 ff ff       	jmp    80106706 <alltraps>

801070fc <vector105>:
.globl vector105
vector105:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $105
801070fe:	6a 69                	push   $0x69
  jmp alltraps
80107100:	e9 01 f6 ff ff       	jmp    80106706 <alltraps>

80107105 <vector106>:
.globl vector106
vector106:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $106
80107107:	6a 6a                	push   $0x6a
  jmp alltraps
80107109:	e9 f8 f5 ff ff       	jmp    80106706 <alltraps>

8010710e <vector107>:
.globl vector107
vector107:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $107
80107110:	6a 6b                	push   $0x6b
  jmp alltraps
80107112:	e9 ef f5 ff ff       	jmp    80106706 <alltraps>

80107117 <vector108>:
.globl vector108
vector108:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $108
80107119:	6a 6c                	push   $0x6c
  jmp alltraps
8010711b:	e9 e6 f5 ff ff       	jmp    80106706 <alltraps>

80107120 <vector109>:
.globl vector109
vector109:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $109
80107122:	6a 6d                	push   $0x6d
  jmp alltraps
80107124:	e9 dd f5 ff ff       	jmp    80106706 <alltraps>

80107129 <vector110>:
.globl vector110
vector110:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $110
8010712b:	6a 6e                	push   $0x6e
  jmp alltraps
8010712d:	e9 d4 f5 ff ff       	jmp    80106706 <alltraps>

80107132 <vector111>:
.globl vector111
vector111:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $111
80107134:	6a 6f                	push   $0x6f
  jmp alltraps
80107136:	e9 cb f5 ff ff       	jmp    80106706 <alltraps>

8010713b <vector112>:
.globl vector112
vector112:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $112
8010713d:	6a 70                	push   $0x70
  jmp alltraps
8010713f:	e9 c2 f5 ff ff       	jmp    80106706 <alltraps>

80107144 <vector113>:
.globl vector113
vector113:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $113
80107146:	6a 71                	push   $0x71
  jmp alltraps
80107148:	e9 b9 f5 ff ff       	jmp    80106706 <alltraps>

8010714d <vector114>:
.globl vector114
vector114:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $114
8010714f:	6a 72                	push   $0x72
  jmp alltraps
80107151:	e9 b0 f5 ff ff       	jmp    80106706 <alltraps>

80107156 <vector115>:
.globl vector115
vector115:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $115
80107158:	6a 73                	push   $0x73
  jmp alltraps
8010715a:	e9 a7 f5 ff ff       	jmp    80106706 <alltraps>

8010715f <vector116>:
.globl vector116
vector116:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $116
80107161:	6a 74                	push   $0x74
  jmp alltraps
80107163:	e9 9e f5 ff ff       	jmp    80106706 <alltraps>

80107168 <vector117>:
.globl vector117
vector117:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $117
8010716a:	6a 75                	push   $0x75
  jmp alltraps
8010716c:	e9 95 f5 ff ff       	jmp    80106706 <alltraps>

80107171 <vector118>:
.globl vector118
vector118:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $118
80107173:	6a 76                	push   $0x76
  jmp alltraps
80107175:	e9 8c f5 ff ff       	jmp    80106706 <alltraps>

8010717a <vector119>:
.globl vector119
vector119:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $119
8010717c:	6a 77                	push   $0x77
  jmp alltraps
8010717e:	e9 83 f5 ff ff       	jmp    80106706 <alltraps>

80107183 <vector120>:
.globl vector120
vector120:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $120
80107185:	6a 78                	push   $0x78
  jmp alltraps
80107187:	e9 7a f5 ff ff       	jmp    80106706 <alltraps>

8010718c <vector121>:
.globl vector121
vector121:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $121
8010718e:	6a 79                	push   $0x79
  jmp alltraps
80107190:	e9 71 f5 ff ff       	jmp    80106706 <alltraps>

80107195 <vector122>:
.globl vector122
vector122:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $122
80107197:	6a 7a                	push   $0x7a
  jmp alltraps
80107199:	e9 68 f5 ff ff       	jmp    80106706 <alltraps>

8010719e <vector123>:
.globl vector123
vector123:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $123
801071a0:	6a 7b                	push   $0x7b
  jmp alltraps
801071a2:	e9 5f f5 ff ff       	jmp    80106706 <alltraps>

801071a7 <vector124>:
.globl vector124
vector124:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $124
801071a9:	6a 7c                	push   $0x7c
  jmp alltraps
801071ab:	e9 56 f5 ff ff       	jmp    80106706 <alltraps>

801071b0 <vector125>:
.globl vector125
vector125:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $125
801071b2:	6a 7d                	push   $0x7d
  jmp alltraps
801071b4:	e9 4d f5 ff ff       	jmp    80106706 <alltraps>

801071b9 <vector126>:
.globl vector126
vector126:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $126
801071bb:	6a 7e                	push   $0x7e
  jmp alltraps
801071bd:	e9 44 f5 ff ff       	jmp    80106706 <alltraps>

801071c2 <vector127>:
.globl vector127
vector127:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $127
801071c4:	6a 7f                	push   $0x7f
  jmp alltraps
801071c6:	e9 3b f5 ff ff       	jmp    80106706 <alltraps>

801071cb <vector128>:
.globl vector128
vector128:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $128
801071cd:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801071d2:	e9 2f f5 ff ff       	jmp    80106706 <alltraps>

801071d7 <vector129>:
.globl vector129
vector129:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $129
801071d9:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801071de:	e9 23 f5 ff ff       	jmp    80106706 <alltraps>

801071e3 <vector130>:
.globl vector130
vector130:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $130
801071e5:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801071ea:	e9 17 f5 ff ff       	jmp    80106706 <alltraps>

801071ef <vector131>:
.globl vector131
vector131:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $131
801071f1:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801071f6:	e9 0b f5 ff ff       	jmp    80106706 <alltraps>

801071fb <vector132>:
.globl vector132
vector132:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $132
801071fd:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107202:	e9 ff f4 ff ff       	jmp    80106706 <alltraps>

80107207 <vector133>:
.globl vector133
vector133:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $133
80107209:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010720e:	e9 f3 f4 ff ff       	jmp    80106706 <alltraps>

80107213 <vector134>:
.globl vector134
vector134:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $134
80107215:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010721a:	e9 e7 f4 ff ff       	jmp    80106706 <alltraps>

8010721f <vector135>:
.globl vector135
vector135:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $135
80107221:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107226:	e9 db f4 ff ff       	jmp    80106706 <alltraps>

8010722b <vector136>:
.globl vector136
vector136:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $136
8010722d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107232:	e9 cf f4 ff ff       	jmp    80106706 <alltraps>

80107237 <vector137>:
.globl vector137
vector137:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $137
80107239:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010723e:	e9 c3 f4 ff ff       	jmp    80106706 <alltraps>

80107243 <vector138>:
.globl vector138
vector138:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $138
80107245:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010724a:	e9 b7 f4 ff ff       	jmp    80106706 <alltraps>

8010724f <vector139>:
.globl vector139
vector139:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $139
80107251:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107256:	e9 ab f4 ff ff       	jmp    80106706 <alltraps>

8010725b <vector140>:
.globl vector140
vector140:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $140
8010725d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107262:	e9 9f f4 ff ff       	jmp    80106706 <alltraps>

80107267 <vector141>:
.globl vector141
vector141:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $141
80107269:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010726e:	e9 93 f4 ff ff       	jmp    80106706 <alltraps>

80107273 <vector142>:
.globl vector142
vector142:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $142
80107275:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010727a:	e9 87 f4 ff ff       	jmp    80106706 <alltraps>

8010727f <vector143>:
.globl vector143
vector143:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $143
80107281:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107286:	e9 7b f4 ff ff       	jmp    80106706 <alltraps>

8010728b <vector144>:
.globl vector144
vector144:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $144
8010728d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107292:	e9 6f f4 ff ff       	jmp    80106706 <alltraps>

80107297 <vector145>:
.globl vector145
vector145:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $145
80107299:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010729e:	e9 63 f4 ff ff       	jmp    80106706 <alltraps>

801072a3 <vector146>:
.globl vector146
vector146:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $146
801072a5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801072aa:	e9 57 f4 ff ff       	jmp    80106706 <alltraps>

801072af <vector147>:
.globl vector147
vector147:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $147
801072b1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801072b6:	e9 4b f4 ff ff       	jmp    80106706 <alltraps>

801072bb <vector148>:
.globl vector148
vector148:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $148
801072bd:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801072c2:	e9 3f f4 ff ff       	jmp    80106706 <alltraps>

801072c7 <vector149>:
.globl vector149
vector149:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $149
801072c9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801072ce:	e9 33 f4 ff ff       	jmp    80106706 <alltraps>

801072d3 <vector150>:
.globl vector150
vector150:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $150
801072d5:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801072da:	e9 27 f4 ff ff       	jmp    80106706 <alltraps>

801072df <vector151>:
.globl vector151
vector151:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $151
801072e1:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801072e6:	e9 1b f4 ff ff       	jmp    80106706 <alltraps>

801072eb <vector152>:
.globl vector152
vector152:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $152
801072ed:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801072f2:	e9 0f f4 ff ff       	jmp    80106706 <alltraps>

801072f7 <vector153>:
.globl vector153
vector153:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $153
801072f9:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801072fe:	e9 03 f4 ff ff       	jmp    80106706 <alltraps>

80107303 <vector154>:
.globl vector154
vector154:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $154
80107305:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010730a:	e9 f7 f3 ff ff       	jmp    80106706 <alltraps>

8010730f <vector155>:
.globl vector155
vector155:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $155
80107311:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107316:	e9 eb f3 ff ff       	jmp    80106706 <alltraps>

8010731b <vector156>:
.globl vector156
vector156:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $156
8010731d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107322:	e9 df f3 ff ff       	jmp    80106706 <alltraps>

80107327 <vector157>:
.globl vector157
vector157:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $157
80107329:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010732e:	e9 d3 f3 ff ff       	jmp    80106706 <alltraps>

80107333 <vector158>:
.globl vector158
vector158:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $158
80107335:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010733a:	e9 c7 f3 ff ff       	jmp    80106706 <alltraps>

8010733f <vector159>:
.globl vector159
vector159:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $159
80107341:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107346:	e9 bb f3 ff ff       	jmp    80106706 <alltraps>

8010734b <vector160>:
.globl vector160
vector160:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $160
8010734d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107352:	e9 af f3 ff ff       	jmp    80106706 <alltraps>

80107357 <vector161>:
.globl vector161
vector161:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $161
80107359:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010735e:	e9 a3 f3 ff ff       	jmp    80106706 <alltraps>

80107363 <vector162>:
.globl vector162
vector162:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $162
80107365:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010736a:	e9 97 f3 ff ff       	jmp    80106706 <alltraps>

8010736f <vector163>:
.globl vector163
vector163:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $163
80107371:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107376:	e9 8b f3 ff ff       	jmp    80106706 <alltraps>

8010737b <vector164>:
.globl vector164
vector164:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $164
8010737d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107382:	e9 7f f3 ff ff       	jmp    80106706 <alltraps>

80107387 <vector165>:
.globl vector165
vector165:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $165
80107389:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010738e:	e9 73 f3 ff ff       	jmp    80106706 <alltraps>

80107393 <vector166>:
.globl vector166
vector166:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $166
80107395:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010739a:	e9 67 f3 ff ff       	jmp    80106706 <alltraps>

8010739f <vector167>:
.globl vector167
vector167:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $167
801073a1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801073a6:	e9 5b f3 ff ff       	jmp    80106706 <alltraps>

801073ab <vector168>:
.globl vector168
vector168:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $168
801073ad:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801073b2:	e9 4f f3 ff ff       	jmp    80106706 <alltraps>

801073b7 <vector169>:
.globl vector169
vector169:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $169
801073b9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801073be:	e9 43 f3 ff ff       	jmp    80106706 <alltraps>

801073c3 <vector170>:
.globl vector170
vector170:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $170
801073c5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801073ca:	e9 37 f3 ff ff       	jmp    80106706 <alltraps>

801073cf <vector171>:
.globl vector171
vector171:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $171
801073d1:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801073d6:	e9 2b f3 ff ff       	jmp    80106706 <alltraps>

801073db <vector172>:
.globl vector172
vector172:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $172
801073dd:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801073e2:	e9 1f f3 ff ff       	jmp    80106706 <alltraps>

801073e7 <vector173>:
.globl vector173
vector173:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $173
801073e9:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801073ee:	e9 13 f3 ff ff       	jmp    80106706 <alltraps>

801073f3 <vector174>:
.globl vector174
vector174:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $174
801073f5:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801073fa:	e9 07 f3 ff ff       	jmp    80106706 <alltraps>

801073ff <vector175>:
.globl vector175
vector175:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $175
80107401:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107406:	e9 fb f2 ff ff       	jmp    80106706 <alltraps>

8010740b <vector176>:
.globl vector176
vector176:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $176
8010740d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107412:	e9 ef f2 ff ff       	jmp    80106706 <alltraps>

80107417 <vector177>:
.globl vector177
vector177:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $177
80107419:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010741e:	e9 e3 f2 ff ff       	jmp    80106706 <alltraps>

80107423 <vector178>:
.globl vector178
vector178:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $178
80107425:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010742a:	e9 d7 f2 ff ff       	jmp    80106706 <alltraps>

8010742f <vector179>:
.globl vector179
vector179:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $179
80107431:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107436:	e9 cb f2 ff ff       	jmp    80106706 <alltraps>

8010743b <vector180>:
.globl vector180
vector180:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $180
8010743d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107442:	e9 bf f2 ff ff       	jmp    80106706 <alltraps>

80107447 <vector181>:
.globl vector181
vector181:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $181
80107449:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010744e:	e9 b3 f2 ff ff       	jmp    80106706 <alltraps>

80107453 <vector182>:
.globl vector182
vector182:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $182
80107455:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010745a:	e9 a7 f2 ff ff       	jmp    80106706 <alltraps>

8010745f <vector183>:
.globl vector183
vector183:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $183
80107461:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107466:	e9 9b f2 ff ff       	jmp    80106706 <alltraps>

8010746b <vector184>:
.globl vector184
vector184:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $184
8010746d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107472:	e9 8f f2 ff ff       	jmp    80106706 <alltraps>

80107477 <vector185>:
.globl vector185
vector185:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $185
80107479:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010747e:	e9 83 f2 ff ff       	jmp    80106706 <alltraps>

80107483 <vector186>:
.globl vector186
vector186:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $186
80107485:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010748a:	e9 77 f2 ff ff       	jmp    80106706 <alltraps>

8010748f <vector187>:
.globl vector187
vector187:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $187
80107491:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107496:	e9 6b f2 ff ff       	jmp    80106706 <alltraps>

8010749b <vector188>:
.globl vector188
vector188:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $188
8010749d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801074a2:	e9 5f f2 ff ff       	jmp    80106706 <alltraps>

801074a7 <vector189>:
.globl vector189
vector189:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $189
801074a9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801074ae:	e9 53 f2 ff ff       	jmp    80106706 <alltraps>

801074b3 <vector190>:
.globl vector190
vector190:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $190
801074b5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801074ba:	e9 47 f2 ff ff       	jmp    80106706 <alltraps>

801074bf <vector191>:
.globl vector191
vector191:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $191
801074c1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801074c6:	e9 3b f2 ff ff       	jmp    80106706 <alltraps>

801074cb <vector192>:
.globl vector192
vector192:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $192
801074cd:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801074d2:	e9 2f f2 ff ff       	jmp    80106706 <alltraps>

801074d7 <vector193>:
.globl vector193
vector193:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $193
801074d9:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801074de:	e9 23 f2 ff ff       	jmp    80106706 <alltraps>

801074e3 <vector194>:
.globl vector194
vector194:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $194
801074e5:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801074ea:	e9 17 f2 ff ff       	jmp    80106706 <alltraps>

801074ef <vector195>:
.globl vector195
vector195:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $195
801074f1:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801074f6:	e9 0b f2 ff ff       	jmp    80106706 <alltraps>

801074fb <vector196>:
.globl vector196
vector196:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $196
801074fd:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107502:	e9 ff f1 ff ff       	jmp    80106706 <alltraps>

80107507 <vector197>:
.globl vector197
vector197:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $197
80107509:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010750e:	e9 f3 f1 ff ff       	jmp    80106706 <alltraps>

80107513 <vector198>:
.globl vector198
vector198:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $198
80107515:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010751a:	e9 e7 f1 ff ff       	jmp    80106706 <alltraps>

8010751f <vector199>:
.globl vector199
vector199:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $199
80107521:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107526:	e9 db f1 ff ff       	jmp    80106706 <alltraps>

8010752b <vector200>:
.globl vector200
vector200:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $200
8010752d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107532:	e9 cf f1 ff ff       	jmp    80106706 <alltraps>

80107537 <vector201>:
.globl vector201
vector201:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $201
80107539:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010753e:	e9 c3 f1 ff ff       	jmp    80106706 <alltraps>

80107543 <vector202>:
.globl vector202
vector202:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $202
80107545:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010754a:	e9 b7 f1 ff ff       	jmp    80106706 <alltraps>

8010754f <vector203>:
.globl vector203
vector203:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $203
80107551:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107556:	e9 ab f1 ff ff       	jmp    80106706 <alltraps>

8010755b <vector204>:
.globl vector204
vector204:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $204
8010755d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107562:	e9 9f f1 ff ff       	jmp    80106706 <alltraps>

80107567 <vector205>:
.globl vector205
vector205:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $205
80107569:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010756e:	e9 93 f1 ff ff       	jmp    80106706 <alltraps>

80107573 <vector206>:
.globl vector206
vector206:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $206
80107575:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010757a:	e9 87 f1 ff ff       	jmp    80106706 <alltraps>

8010757f <vector207>:
.globl vector207
vector207:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $207
80107581:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107586:	e9 7b f1 ff ff       	jmp    80106706 <alltraps>

8010758b <vector208>:
.globl vector208
vector208:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $208
8010758d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107592:	e9 6f f1 ff ff       	jmp    80106706 <alltraps>

80107597 <vector209>:
.globl vector209
vector209:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $209
80107599:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010759e:	e9 63 f1 ff ff       	jmp    80106706 <alltraps>

801075a3 <vector210>:
.globl vector210
vector210:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $210
801075a5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801075aa:	e9 57 f1 ff ff       	jmp    80106706 <alltraps>

801075af <vector211>:
.globl vector211
vector211:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $211
801075b1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801075b6:	e9 4b f1 ff ff       	jmp    80106706 <alltraps>

801075bb <vector212>:
.globl vector212
vector212:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $212
801075bd:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801075c2:	e9 3f f1 ff ff       	jmp    80106706 <alltraps>

801075c7 <vector213>:
.globl vector213
vector213:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $213
801075c9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801075ce:	e9 33 f1 ff ff       	jmp    80106706 <alltraps>

801075d3 <vector214>:
.globl vector214
vector214:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $214
801075d5:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801075da:	e9 27 f1 ff ff       	jmp    80106706 <alltraps>

801075df <vector215>:
.globl vector215
vector215:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $215
801075e1:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801075e6:	e9 1b f1 ff ff       	jmp    80106706 <alltraps>

801075eb <vector216>:
.globl vector216
vector216:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $216
801075ed:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801075f2:	e9 0f f1 ff ff       	jmp    80106706 <alltraps>

801075f7 <vector217>:
.globl vector217
vector217:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $217
801075f9:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801075fe:	e9 03 f1 ff ff       	jmp    80106706 <alltraps>

80107603 <vector218>:
.globl vector218
vector218:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $218
80107605:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010760a:	e9 f7 f0 ff ff       	jmp    80106706 <alltraps>

8010760f <vector219>:
.globl vector219
vector219:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $219
80107611:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107616:	e9 eb f0 ff ff       	jmp    80106706 <alltraps>

8010761b <vector220>:
.globl vector220
vector220:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $220
8010761d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107622:	e9 df f0 ff ff       	jmp    80106706 <alltraps>

80107627 <vector221>:
.globl vector221
vector221:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $221
80107629:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010762e:	e9 d3 f0 ff ff       	jmp    80106706 <alltraps>

80107633 <vector222>:
.globl vector222
vector222:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $222
80107635:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010763a:	e9 c7 f0 ff ff       	jmp    80106706 <alltraps>

8010763f <vector223>:
.globl vector223
vector223:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $223
80107641:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107646:	e9 bb f0 ff ff       	jmp    80106706 <alltraps>

8010764b <vector224>:
.globl vector224
vector224:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $224
8010764d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107652:	e9 af f0 ff ff       	jmp    80106706 <alltraps>

80107657 <vector225>:
.globl vector225
vector225:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $225
80107659:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010765e:	e9 a3 f0 ff ff       	jmp    80106706 <alltraps>

80107663 <vector226>:
.globl vector226
vector226:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $226
80107665:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010766a:	e9 97 f0 ff ff       	jmp    80106706 <alltraps>

8010766f <vector227>:
.globl vector227
vector227:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $227
80107671:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107676:	e9 8b f0 ff ff       	jmp    80106706 <alltraps>

8010767b <vector228>:
.globl vector228
vector228:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $228
8010767d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107682:	e9 7f f0 ff ff       	jmp    80106706 <alltraps>

80107687 <vector229>:
.globl vector229
vector229:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $229
80107689:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010768e:	e9 73 f0 ff ff       	jmp    80106706 <alltraps>

80107693 <vector230>:
.globl vector230
vector230:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $230
80107695:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010769a:	e9 67 f0 ff ff       	jmp    80106706 <alltraps>

8010769f <vector231>:
.globl vector231
vector231:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $231
801076a1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801076a6:	e9 5b f0 ff ff       	jmp    80106706 <alltraps>

801076ab <vector232>:
.globl vector232
vector232:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $232
801076ad:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801076b2:	e9 4f f0 ff ff       	jmp    80106706 <alltraps>

801076b7 <vector233>:
.globl vector233
vector233:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $233
801076b9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801076be:	e9 43 f0 ff ff       	jmp    80106706 <alltraps>

801076c3 <vector234>:
.globl vector234
vector234:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $234
801076c5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801076ca:	e9 37 f0 ff ff       	jmp    80106706 <alltraps>

801076cf <vector235>:
.globl vector235
vector235:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $235
801076d1:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801076d6:	e9 2b f0 ff ff       	jmp    80106706 <alltraps>

801076db <vector236>:
.globl vector236
vector236:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $236
801076dd:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801076e2:	e9 1f f0 ff ff       	jmp    80106706 <alltraps>

801076e7 <vector237>:
.globl vector237
vector237:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $237
801076e9:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801076ee:	e9 13 f0 ff ff       	jmp    80106706 <alltraps>

801076f3 <vector238>:
.globl vector238
vector238:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $238
801076f5:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801076fa:	e9 07 f0 ff ff       	jmp    80106706 <alltraps>

801076ff <vector239>:
.globl vector239
vector239:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $239
80107701:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107706:	e9 fb ef ff ff       	jmp    80106706 <alltraps>

8010770b <vector240>:
.globl vector240
vector240:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $240
8010770d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107712:	e9 ef ef ff ff       	jmp    80106706 <alltraps>

80107717 <vector241>:
.globl vector241
vector241:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $241
80107719:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010771e:	e9 e3 ef ff ff       	jmp    80106706 <alltraps>

80107723 <vector242>:
.globl vector242
vector242:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $242
80107725:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010772a:	e9 d7 ef ff ff       	jmp    80106706 <alltraps>

8010772f <vector243>:
.globl vector243
vector243:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $243
80107731:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107736:	e9 cb ef ff ff       	jmp    80106706 <alltraps>

8010773b <vector244>:
.globl vector244
vector244:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $244
8010773d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107742:	e9 bf ef ff ff       	jmp    80106706 <alltraps>

80107747 <vector245>:
.globl vector245
vector245:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $245
80107749:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010774e:	e9 b3 ef ff ff       	jmp    80106706 <alltraps>

80107753 <vector246>:
.globl vector246
vector246:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $246
80107755:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010775a:	e9 a7 ef ff ff       	jmp    80106706 <alltraps>

8010775f <vector247>:
.globl vector247
vector247:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $247
80107761:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107766:	e9 9b ef ff ff       	jmp    80106706 <alltraps>

8010776b <vector248>:
.globl vector248
vector248:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $248
8010776d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107772:	e9 8f ef ff ff       	jmp    80106706 <alltraps>

80107777 <vector249>:
.globl vector249
vector249:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $249
80107779:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010777e:	e9 83 ef ff ff       	jmp    80106706 <alltraps>

80107783 <vector250>:
.globl vector250
vector250:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $250
80107785:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010778a:	e9 77 ef ff ff       	jmp    80106706 <alltraps>

8010778f <vector251>:
.globl vector251
vector251:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $251
80107791:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107796:	e9 6b ef ff ff       	jmp    80106706 <alltraps>

8010779b <vector252>:
.globl vector252
vector252:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $252
8010779d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801077a2:	e9 5f ef ff ff       	jmp    80106706 <alltraps>

801077a7 <vector253>:
.globl vector253
vector253:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $253
801077a9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801077ae:	e9 53 ef ff ff       	jmp    80106706 <alltraps>

801077b3 <vector254>:
.globl vector254
vector254:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $254
801077b5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801077ba:	e9 47 ef ff ff       	jmp    80106706 <alltraps>

801077bf <vector255>:
.globl vector255
vector255:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $255
801077c1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801077c6:	e9 3b ef ff ff       	jmp    80106706 <alltraps>

801077cb <lgdt>:
{
801077cb:	55                   	push   %ebp
801077cc:	89 e5                	mov    %esp,%ebp
801077ce:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801077d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801077d4:	83 e8 01             	sub    $0x1,%eax
801077d7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801077db:	8b 45 08             	mov    0x8(%ebp),%eax
801077de:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801077e2:	8b 45 08             	mov    0x8(%ebp),%eax
801077e5:	c1 e8 10             	shr    $0x10,%eax
801077e8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801077ec:	8d 45 fa             	lea    -0x6(%ebp),%eax
801077ef:	0f 01 10             	lgdtl  (%eax)
}
801077f2:	90                   	nop
801077f3:	c9                   	leave  
801077f4:	c3                   	ret    

801077f5 <ltr>:
{
801077f5:	55                   	push   %ebp
801077f6:	89 e5                	mov    %esp,%ebp
801077f8:	83 ec 04             	sub    $0x4,%esp
801077fb:	8b 45 08             	mov    0x8(%ebp),%eax
801077fe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107802:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107806:	0f 00 d8             	ltr    %ax
}
80107809:	90                   	nop
8010780a:	c9                   	leave  
8010780b:	c3                   	ret    

8010780c <loadgs>:
{
8010780c:	55                   	push   %ebp
8010780d:	89 e5                	mov    %esp,%ebp
8010780f:	83 ec 04             	sub    $0x4,%esp
80107812:	8b 45 08             	mov    0x8(%ebp),%eax
80107815:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107819:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010781d:	8e e8                	mov    %eax,%gs
}
8010781f:	90                   	nop
80107820:	c9                   	leave  
80107821:	c3                   	ret    

80107822 <lcr3>:
{
80107822:	55                   	push   %ebp
80107823:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107825:	8b 45 08             	mov    0x8(%ebp),%eax
80107828:	0f 22 d8             	mov    %eax,%cr3
}
8010782b:	90                   	nop
8010782c:	5d                   	pop    %ebp
8010782d:	c3                   	ret    

8010782e <v2p>:
static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010782e:	55                   	push   %ebp
8010782f:	89 e5                	mov    %esp,%ebp
80107831:	8b 45 08             	mov    0x8(%ebp),%eax
80107834:	05 00 00 00 80       	add    $0x80000000,%eax
80107839:	5d                   	pop    %ebp
8010783a:	c3                   	ret    

8010783b <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010783b:	55                   	push   %ebp
8010783c:	89 e5                	mov    %esp,%ebp
8010783e:	8b 45 08             	mov    0x8(%ebp),%eax
80107841:	05 00 00 00 80       	add    $0x80000000,%eax
80107846:	5d                   	pop    %ebp
80107847:	c3                   	ret    

80107848 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107848:	55                   	push   %ebp
80107849:	89 e5                	mov    %esp,%ebp
8010784b:	53                   	push   %ebx
8010784c:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010784f:	e8 7f b7 ff ff       	call   80102fd3 <cpunum>
80107854:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010785a:	05 60 23 11 80       	add    $0x80112360,%eax
8010785f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107865:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010786b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107877:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010787b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107882:	83 e2 f0             	and    $0xfffffff0,%edx
80107885:	83 ca 0a             	or     $0xa,%edx
80107888:	88 50 7d             	mov    %dl,0x7d(%eax)
8010788b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107892:	83 ca 10             	or     $0x10,%edx
80107895:	88 50 7d             	mov    %dl,0x7d(%eax)
80107898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010789f:	83 e2 9f             	and    $0xffffff9f,%edx
801078a2:	88 50 7d             	mov    %dl,0x7d(%eax)
801078a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078ac:	83 ca 80             	or     $0xffffff80,%edx
801078af:	88 50 7d             	mov    %dl,0x7d(%eax)
801078b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078b9:	83 ca 0f             	or     $0xf,%edx
801078bc:	88 50 7e             	mov    %dl,0x7e(%eax)
801078bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078c6:	83 e2 ef             	and    $0xffffffef,%edx
801078c9:	88 50 7e             	mov    %dl,0x7e(%eax)
801078cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078d3:	83 e2 df             	and    $0xffffffdf,%edx
801078d6:	88 50 7e             	mov    %dl,0x7e(%eax)
801078d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078dc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078e0:	83 ca 40             	or     $0x40,%edx
801078e3:	88 50 7e             	mov    %dl,0x7e(%eax)
801078e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078ed:	83 ca 80             	or     $0xffffff80,%edx
801078f0:	88 50 7e             	mov    %dl,0x7e(%eax)
801078f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f6:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fd:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107904:	ff ff 
80107906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107909:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107910:	00 00 
80107912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107915:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010791c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107926:	83 e2 f0             	and    $0xfffffff0,%edx
80107929:	83 ca 02             	or     $0x2,%edx
8010792c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107935:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010793c:	83 ca 10             	or     $0x10,%edx
8010793f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107948:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010794f:	83 e2 9f             	and    $0xffffff9f,%edx
80107952:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107962:	83 ca 80             	or     $0xffffff80,%edx
80107965:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010796b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107975:	83 ca 0f             	or     $0xf,%edx
80107978:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010797e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107981:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107988:	83 e2 ef             	and    $0xffffffef,%edx
8010798b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107994:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010799b:	83 e2 df             	and    $0xffffffdf,%edx
8010799e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079ae:	83 ca 40             	or     $0x40,%edx
801079b1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079c1:	83 ca 80             	or     $0xffffff80,%edx
801079c4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cd:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801079d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801079de:	ff ff 
801079e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801079ea:	00 00 
801079ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ef:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801079f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a00:	83 e2 f0             	and    $0xfffffff0,%edx
80107a03:	83 ca 0a             	or     $0xa,%edx
80107a06:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a16:	83 ca 10             	or     $0x10,%edx
80107a19:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a22:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a29:	83 ca 60             	or     $0x60,%edx
80107a2c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a35:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a3c:	83 ca 80             	or     $0xffffff80,%edx
80107a3f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a48:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a4f:	83 ca 0f             	or     $0xf,%edx
80107a52:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a62:	83 e2 ef             	and    $0xffffffef,%edx
80107a65:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a75:	83 e2 df             	and    $0xffffffdf,%edx
80107a78:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a81:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a88:	83 ca 40             	or     $0x40,%edx
80107a8b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a9b:	83 ca 80             	or     $0xffffff80,%edx
80107a9e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa7:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab1:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ab8:	ff ff 
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107ac4:	00 00 
80107ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac9:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ada:	83 e2 f0             	and    $0xfffffff0,%edx
80107add:	83 ca 02             	or     $0x2,%edx
80107ae0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107af0:	83 ca 10             	or     $0x10,%edx
80107af3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b03:	83 ca 60             	or     $0x60,%edx
80107b06:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b16:	83 ca 80             	or     $0xffffff80,%edx
80107b19:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b22:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b29:	83 ca 0f             	or     $0xf,%edx
80107b2c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b3c:	83 e2 ef             	and    $0xffffffef,%edx
80107b3f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b4f:	83 e2 df             	and    $0xffffffdf,%edx
80107b52:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b62:	83 ca 40             	or     $0x40,%edx
80107b65:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b75:	83 ca 80             	or     $0xffffff80,%edx
80107b78:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b81:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8b:	05 b4 00 00 00       	add    $0xb4,%eax
80107b90:	89 c3                	mov    %eax,%ebx
80107b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b95:	05 b4 00 00 00       	add    $0xb4,%eax
80107b9a:	c1 e8 10             	shr    $0x10,%eax
80107b9d:	89 c2                	mov    %eax,%edx
80107b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba2:	05 b4 00 00 00       	add    $0xb4,%eax
80107ba7:	c1 e8 18             	shr    $0x18,%eax
80107baa:	89 c1                	mov    %eax,%ecx
80107bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baf:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107bb6:	00 00 
80107bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbb:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc5:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bce:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bd5:	83 e2 f0             	and    $0xfffffff0,%edx
80107bd8:	83 ca 02             	or     $0x2,%edx
80107bdb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107beb:	83 ca 10             	or     $0x10,%edx
80107bee:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bfe:	83 e2 9f             	and    $0xffffff9f,%edx
80107c01:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c11:	83 ca 80             	or     $0xffffff80,%edx
80107c14:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c24:	83 e2 f0             	and    $0xfffffff0,%edx
80107c27:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c30:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c37:	83 e2 ef             	and    $0xffffffef,%edx
80107c3a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c43:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c4a:	83 e2 df             	and    $0xffffffdf,%edx
80107c4d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c56:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c5d:	83 ca 40             	or     $0x40,%edx
80107c60:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c69:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c70:	83 ca 80             	or     $0xffffff80,%edx
80107c73:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7c:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c85:	83 c0 70             	add    $0x70,%eax
80107c88:	83 ec 08             	sub    $0x8,%esp
80107c8b:	6a 38                	push   $0x38
80107c8d:	50                   	push   %eax
80107c8e:	e8 38 fb ff ff       	call   801077cb <lgdt>
80107c93:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107c96:	83 ec 0c             	sub    $0xc,%esp
80107c99:	6a 18                	push   $0x18
80107c9b:	e8 6c fb ff ff       	call   8010780c <loadgs>
80107ca0:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca6:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107cac:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107cb3:	00 00 00 00 
}
80107cb7:	90                   	nop
80107cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107cbb:	c9                   	leave  
80107cbc:	c3                   	ret    

80107cbd <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107cbd:	55                   	push   %ebp
80107cbe:	89 e5                	mov    %esp,%ebp
80107cc0:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cc6:	c1 e8 16             	shr    $0x16,%eax
80107cc9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80107cd3:	01 d0                	add    %edx,%eax
80107cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cdb:	8b 00                	mov    (%eax),%eax
80107cdd:	83 e0 01             	and    $0x1,%eax
80107ce0:	85 c0                	test   %eax,%eax
80107ce2:	74 18                	je     80107cfc <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ce7:	8b 00                	mov    (%eax),%eax
80107ce9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cee:	50                   	push   %eax
80107cef:	e8 47 fb ff ff       	call   8010783b <p2v>
80107cf4:	83 c4 04             	add    $0x4,%esp
80107cf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cfa:	eb 48                	jmp    80107d44 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107cfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107d00:	74 0e                	je     80107d10 <walkpgdir+0x53>
80107d02:	e8 63 af ff ff       	call   80102c6a <kalloc>
80107d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d0e:	75 07                	jne    80107d17 <walkpgdir+0x5a>
      return 0;
80107d10:	b8 00 00 00 00       	mov    $0x0,%eax
80107d15:	eb 44                	jmp    80107d5b <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107d17:	83 ec 04             	sub    $0x4,%esp
80107d1a:	68 00 10 00 00       	push   $0x1000
80107d1f:	6a 00                	push   $0x0
80107d21:	ff 75 f4             	pushl  -0xc(%ebp)
80107d24:	e8 9e d5 ff ff       	call   801052c7 <memset>
80107d29:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107d2c:	83 ec 0c             	sub    $0xc,%esp
80107d2f:	ff 75 f4             	pushl  -0xc(%ebp)
80107d32:	e8 f7 fa ff ff       	call   8010782e <v2p>
80107d37:	83 c4 10             	add    $0x10,%esp
80107d3a:	83 c8 07             	or     $0x7,%eax
80107d3d:	89 c2                	mov    %eax,%edx
80107d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d42:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107d44:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d47:	c1 e8 0c             	shr    $0xc,%eax
80107d4a:	25 ff 03 00 00       	and    $0x3ff,%eax
80107d4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d59:	01 d0                	add    %edx,%eax
}
80107d5b:	c9                   	leave  
80107d5c:	c3                   	ret    

80107d5d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d5d:	55                   	push   %ebp
80107d5e:	89 e5                	mov    %esp,%ebp
80107d60:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d71:	8b 45 10             	mov    0x10(%ebp),%eax
80107d74:	01 d0                	add    %edx,%eax
80107d76:	83 e8 01             	sub    $0x1,%eax
80107d79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d81:	83 ec 04             	sub    $0x4,%esp
80107d84:	6a 01                	push   $0x1
80107d86:	ff 75 f4             	pushl  -0xc(%ebp)
80107d89:	ff 75 08             	pushl  0x8(%ebp)
80107d8c:	e8 2c ff ff ff       	call   80107cbd <walkpgdir>
80107d91:	83 c4 10             	add    $0x10,%esp
80107d94:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d9b:	75 07                	jne    80107da4 <mappages+0x47>
      return -1;
80107d9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107da2:	eb 47                	jmp    80107deb <mappages+0x8e>
    if(*pte & PTE_P)
80107da4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107da7:	8b 00                	mov    (%eax),%eax
80107da9:	83 e0 01             	and    $0x1,%eax
80107dac:	85 c0                	test   %eax,%eax
80107dae:	74 0d                	je     80107dbd <mappages+0x60>
      panic("remap");
80107db0:	83 ec 0c             	sub    $0xc,%esp
80107db3:	68 38 8c 10 80       	push   $0x80108c38
80107db8:	e8 aa 87 ff ff       	call   80100567 <panic>
    *pte = pa | perm | PTE_P;
80107dbd:	8b 45 18             	mov    0x18(%ebp),%eax
80107dc0:	0b 45 14             	or     0x14(%ebp),%eax
80107dc3:	83 c8 01             	or     $0x1,%eax
80107dc6:	89 c2                	mov    %eax,%edx
80107dc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dcb:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107dd3:	74 10                	je     80107de5 <mappages+0x88>
      break;
    a += PGSIZE;
80107dd5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ddc:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107de3:	eb 9c                	jmp    80107d81 <mappages+0x24>
      break;
80107de5:	90                   	nop
  }
  return 0;
80107de6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107deb:	c9                   	leave  
80107dec:	c3                   	ret    

80107ded <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ded:	55                   	push   %ebp
80107dee:	89 e5                	mov    %esp,%ebp
80107df0:	53                   	push   %ebx
80107df1:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107df4:	e8 71 ae ff ff       	call   80102c6a <kalloc>
80107df9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107dfc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e00:	75 0a                	jne    80107e0c <setupkvm+0x1f>
    return 0;
80107e02:	b8 00 00 00 00       	mov    $0x0,%eax
80107e07:	e9 8e 00 00 00       	jmp    80107e9a <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107e0c:	83 ec 04             	sub    $0x4,%esp
80107e0f:	68 00 10 00 00       	push   $0x1000
80107e14:	6a 00                	push   $0x0
80107e16:	ff 75 f0             	pushl  -0x10(%ebp)
80107e19:	e8 a9 d4 ff ff       	call   801052c7 <memset>
80107e1e:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107e21:	83 ec 0c             	sub    $0xc,%esp
80107e24:	68 00 00 00 0e       	push   $0xe000000
80107e29:	e8 0d fa ff ff       	call   8010783b <p2v>
80107e2e:	83 c4 10             	add    $0x10,%esp
80107e31:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107e36:	76 0d                	jbe    80107e45 <setupkvm+0x58>
    panic("PHYSTOP too high");
80107e38:	83 ec 0c             	sub    $0xc,%esp
80107e3b:	68 3e 8c 10 80       	push   $0x80108c3e
80107e40:	e8 22 87 ff ff       	call   80100567 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e45:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107e4c:	eb 40                	jmp    80107e8e <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e51:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e57:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5d:	8b 58 08             	mov    0x8(%eax),%ebx
80107e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e63:	8b 40 04             	mov    0x4(%eax),%eax
80107e66:	29 c3                	sub    %eax,%ebx
80107e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6b:	8b 00                	mov    (%eax),%eax
80107e6d:	83 ec 0c             	sub    $0xc,%esp
80107e70:	51                   	push   %ecx
80107e71:	52                   	push   %edx
80107e72:	53                   	push   %ebx
80107e73:	50                   	push   %eax
80107e74:	ff 75 f0             	pushl  -0x10(%ebp)
80107e77:	e8 e1 fe ff ff       	call   80107d5d <mappages>
80107e7c:	83 c4 20             	add    $0x20,%esp
80107e7f:	85 c0                	test   %eax,%eax
80107e81:	79 07                	jns    80107e8a <setupkvm+0x9d>
      return 0;
80107e83:	b8 00 00 00 00       	mov    $0x0,%eax
80107e88:	eb 10                	jmp    80107e9a <setupkvm+0xad>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e8a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e8e:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107e95:	72 b7                	jb     80107e4e <setupkvm+0x61>
  return pgdir;
80107e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e9d:	c9                   	leave  
80107e9e:	c3                   	ret    

80107e9f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e9f:	55                   	push   %ebp
80107ea0:	89 e5                	mov    %esp,%ebp
80107ea2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107ea5:	e8 43 ff ff ff       	call   80107ded <setupkvm>
80107eaa:	a3 38 51 11 80       	mov    %eax,0x80115138
  switchkvm();
80107eaf:	e8 03 00 00 00       	call   80107eb7 <switchkvm>
}
80107eb4:	90                   	nop
80107eb5:	c9                   	leave  
80107eb6:	c3                   	ret    

80107eb7 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107eb7:	55                   	push   %ebp
80107eb8:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107eba:	a1 38 51 11 80       	mov    0x80115138,%eax
80107ebf:	50                   	push   %eax
80107ec0:	e8 69 f9 ff ff       	call   8010782e <v2p>
80107ec5:	83 c4 04             	add    $0x4,%esp
80107ec8:	50                   	push   %eax
80107ec9:	e8 54 f9 ff ff       	call   80107822 <lcr3>
80107ece:	83 c4 04             	add    $0x4,%esp
}
80107ed1:	90                   	nop
80107ed2:	c9                   	leave  
80107ed3:	c3                   	ret    

80107ed4 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ed4:	55                   	push   %ebp
80107ed5:	89 e5                	mov    %esp,%ebp
80107ed7:	56                   	push   %esi
80107ed8:	53                   	push   %ebx
  pushcli();
80107ed9:	e8 e3 d2 ff ff       	call   801051c1 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107ede:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ee4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107eeb:	83 c2 08             	add    $0x8,%edx
80107eee:	89 d6                	mov    %edx,%esi
80107ef0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ef7:	83 c2 08             	add    $0x8,%edx
80107efa:	c1 ea 10             	shr    $0x10,%edx
80107efd:	89 d3                	mov    %edx,%ebx
80107eff:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f06:	83 c2 08             	add    $0x8,%edx
80107f09:	c1 ea 18             	shr    $0x18,%edx
80107f0c:	89 d1                	mov    %edx,%ecx
80107f0e:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107f15:	67 00 
80107f17:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107f1e:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107f24:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f2b:	83 e2 f0             	and    $0xfffffff0,%edx
80107f2e:	83 ca 09             	or     $0x9,%edx
80107f31:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f37:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f3e:	83 ca 10             	or     $0x10,%edx
80107f41:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f47:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f4e:	83 e2 9f             	and    $0xffffff9f,%edx
80107f51:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f57:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f5e:	83 ca 80             	or     $0xffffff80,%edx
80107f61:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f67:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f6e:	83 e2 f0             	and    $0xfffffff0,%edx
80107f71:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f77:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f7e:	83 e2 ef             	and    $0xffffffef,%edx
80107f81:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f87:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f8e:	83 e2 df             	and    $0xffffffdf,%edx
80107f91:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f97:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f9e:	83 ca 40             	or     $0x40,%edx
80107fa1:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107fa7:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107fae:	83 e2 7f             	and    $0x7f,%edx
80107fb1:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107fb7:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107fbd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fc3:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107fca:	83 e2 ef             	and    $0xffffffef,%edx
80107fcd:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107fd3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fd9:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107fdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107fe5:	8b 40 08             	mov    0x8(%eax),%eax
80107fe8:	89 c2                	mov    %eax,%edx
80107fea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ff0:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107ff6:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107ff9:	83 ec 0c             	sub    $0xc,%esp
80107ffc:	6a 30                	push   $0x30
80107ffe:	e8 f2 f7 ff ff       	call   801077f5 <ltr>
80108003:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108006:	8b 45 08             	mov    0x8(%ebp),%eax
80108009:	8b 40 04             	mov    0x4(%eax),%eax
8010800c:	85 c0                	test   %eax,%eax
8010800e:	75 0d                	jne    8010801d <switchuvm+0x149>
    panic("switchuvm: no pgdir");
80108010:	83 ec 0c             	sub    $0xc,%esp
80108013:	68 4f 8c 10 80       	push   $0x80108c4f
80108018:	e8 4a 85 ff ff       	call   80100567 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010801d:	8b 45 08             	mov    0x8(%ebp),%eax
80108020:	8b 40 04             	mov    0x4(%eax),%eax
80108023:	83 ec 0c             	sub    $0xc,%esp
80108026:	50                   	push   %eax
80108027:	e8 02 f8 ff ff       	call   8010782e <v2p>
8010802c:	83 c4 10             	add    $0x10,%esp
8010802f:	83 ec 0c             	sub    $0xc,%esp
80108032:	50                   	push   %eax
80108033:	e8 ea f7 ff ff       	call   80107822 <lcr3>
80108038:	83 c4 10             	add    $0x10,%esp
  popcli();
8010803b:	e8 c6 d1 ff ff       	call   80105206 <popcli>
}
80108040:	90                   	nop
80108041:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108044:	5b                   	pop    %ebx
80108045:	5e                   	pop    %esi
80108046:	5d                   	pop    %ebp
80108047:	c3                   	ret    

80108048 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108048:	55                   	push   %ebp
80108049:	89 e5                	mov    %esp,%ebp
8010804b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010804e:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108055:	76 0d                	jbe    80108064 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108057:	83 ec 0c             	sub    $0xc,%esp
8010805a:	68 63 8c 10 80       	push   $0x80108c63
8010805f:	e8 03 85 ff ff       	call   80100567 <panic>
  mem = kalloc();
80108064:	e8 01 ac ff ff       	call   80102c6a <kalloc>
80108069:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010806c:	83 ec 04             	sub    $0x4,%esp
8010806f:	68 00 10 00 00       	push   $0x1000
80108074:	6a 00                	push   $0x0
80108076:	ff 75 f4             	pushl  -0xc(%ebp)
80108079:	e8 49 d2 ff ff       	call   801052c7 <memset>
8010807e:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108081:	83 ec 0c             	sub    $0xc,%esp
80108084:	ff 75 f4             	pushl  -0xc(%ebp)
80108087:	e8 a2 f7 ff ff       	call   8010782e <v2p>
8010808c:	83 c4 10             	add    $0x10,%esp
8010808f:	83 ec 0c             	sub    $0xc,%esp
80108092:	6a 06                	push   $0x6
80108094:	50                   	push   %eax
80108095:	68 00 10 00 00       	push   $0x1000
8010809a:	6a 00                	push   $0x0
8010809c:	ff 75 08             	pushl  0x8(%ebp)
8010809f:	e8 b9 fc ff ff       	call   80107d5d <mappages>
801080a4:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801080a7:	83 ec 04             	sub    $0x4,%esp
801080aa:	ff 75 10             	pushl  0x10(%ebp)
801080ad:	ff 75 0c             	pushl  0xc(%ebp)
801080b0:	ff 75 f4             	pushl  -0xc(%ebp)
801080b3:	e8 ce d2 ff ff       	call   80105386 <memmove>
801080b8:	83 c4 10             	add    $0x10,%esp
}
801080bb:	90                   	nop
801080bc:	c9                   	leave  
801080bd:	c3                   	ret    

801080be <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801080be:	55                   	push   %ebp
801080bf:	89 e5                	mov    %esp,%ebp
801080c1:	53                   	push   %ebx
801080c2:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801080c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801080c8:	25 ff 0f 00 00       	and    $0xfff,%eax
801080cd:	85 c0                	test   %eax,%eax
801080cf:	74 0d                	je     801080de <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801080d1:	83 ec 0c             	sub    $0xc,%esp
801080d4:	68 80 8c 10 80       	push   $0x80108c80
801080d9:	e8 89 84 ff ff       	call   80100567 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801080de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080e5:	e9 95 00 00 00       	jmp    8010817f <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801080ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801080ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f0:	01 d0                	add    %edx,%eax
801080f2:	83 ec 04             	sub    $0x4,%esp
801080f5:	6a 00                	push   $0x0
801080f7:	50                   	push   %eax
801080f8:	ff 75 08             	pushl  0x8(%ebp)
801080fb:	e8 bd fb ff ff       	call   80107cbd <walkpgdir>
80108100:	83 c4 10             	add    $0x10,%esp
80108103:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108106:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010810a:	75 0d                	jne    80108119 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010810c:	83 ec 0c             	sub    $0xc,%esp
8010810f:	68 a3 8c 10 80       	push   $0x80108ca3
80108114:	e8 4e 84 ff ff       	call   80100567 <panic>
    pa = PTE_ADDR(*pte);
80108119:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010811c:	8b 00                	mov    (%eax),%eax
8010811e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108123:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108126:	8b 45 18             	mov    0x18(%ebp),%eax
80108129:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010812c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108131:	77 0b                	ja     8010813e <loaduvm+0x80>
      n = sz - i;
80108133:	8b 45 18             	mov    0x18(%ebp),%eax
80108136:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108139:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010813c:	eb 07                	jmp    80108145 <loaduvm+0x87>
    else
      n = PGSIZE;
8010813e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108145:	8b 55 14             	mov    0x14(%ebp),%edx
80108148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010814e:	83 ec 0c             	sub    $0xc,%esp
80108151:	ff 75 e8             	pushl  -0x18(%ebp)
80108154:	e8 e2 f6 ff ff       	call   8010783b <p2v>
80108159:	83 c4 10             	add    $0x10,%esp
8010815c:	ff 75 f0             	pushl  -0x10(%ebp)
8010815f:	53                   	push   %ebx
80108160:	50                   	push   %eax
80108161:	ff 75 10             	pushl  0x10(%ebp)
80108164:	e8 75 9d ff ff       	call   80101ede <readi>
80108169:	83 c4 10             	add    $0x10,%esp
8010816c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010816f:	74 07                	je     80108178 <loaduvm+0xba>
      return -1;
80108171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108176:	eb 18                	jmp    80108190 <loaduvm+0xd2>
  for(i = 0; i < sz; i += PGSIZE){
80108178:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010817f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108182:	3b 45 18             	cmp    0x18(%ebp),%eax
80108185:	0f 82 5f ff ff ff    	jb     801080ea <loaduvm+0x2c>
  }
  return 0;
8010818b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108193:	c9                   	leave  
80108194:	c3                   	ret    

80108195 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108195:	55                   	push   %ebp
80108196:	89 e5                	mov    %esp,%ebp
80108198:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010819b:	8b 45 10             	mov    0x10(%ebp),%eax
8010819e:	85 c0                	test   %eax,%eax
801081a0:	79 0a                	jns    801081ac <allocuvm+0x17>
    return 0;
801081a2:	b8 00 00 00 00       	mov    $0x0,%eax
801081a7:	e9 b0 00 00 00       	jmp    8010825c <allocuvm+0xc7>
  if(newsz < oldsz)
801081ac:	8b 45 10             	mov    0x10(%ebp),%eax
801081af:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081b2:	73 08                	jae    801081bc <allocuvm+0x27>
    return oldsz;
801081b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b7:	e9 a0 00 00 00       	jmp    8010825c <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
801081bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801081bf:	05 ff 0f 00 00       	add    $0xfff,%eax
801081c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801081cc:	eb 7f                	jmp    8010824d <allocuvm+0xb8>
    mem = kalloc();
801081ce:	e8 97 aa ff ff       	call   80102c6a <kalloc>
801081d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801081d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081da:	75 2b                	jne    80108207 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801081dc:	83 ec 0c             	sub    $0xc,%esp
801081df:	68 c1 8c 10 80       	push   $0x80108cc1
801081e4:	e8 db 81 ff ff       	call   801003c4 <cprintf>
801081e9:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801081ec:	83 ec 04             	sub    $0x4,%esp
801081ef:	ff 75 0c             	pushl  0xc(%ebp)
801081f2:	ff 75 10             	pushl  0x10(%ebp)
801081f5:	ff 75 08             	pushl  0x8(%ebp)
801081f8:	e8 61 00 00 00       	call   8010825e <deallocuvm>
801081fd:	83 c4 10             	add    $0x10,%esp
      return 0;
80108200:	b8 00 00 00 00       	mov    $0x0,%eax
80108205:	eb 55                	jmp    8010825c <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108207:	83 ec 04             	sub    $0x4,%esp
8010820a:	68 00 10 00 00       	push   $0x1000
8010820f:	6a 00                	push   $0x0
80108211:	ff 75 f0             	pushl  -0x10(%ebp)
80108214:	e8 ae d0 ff ff       	call   801052c7 <memset>
80108219:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010821c:	83 ec 0c             	sub    $0xc,%esp
8010821f:	ff 75 f0             	pushl  -0x10(%ebp)
80108222:	e8 07 f6 ff ff       	call   8010782e <v2p>
80108227:	83 c4 10             	add    $0x10,%esp
8010822a:	89 c2                	mov    %eax,%edx
8010822c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822f:	83 ec 0c             	sub    $0xc,%esp
80108232:	6a 06                	push   $0x6
80108234:	52                   	push   %edx
80108235:	68 00 10 00 00       	push   $0x1000
8010823a:	50                   	push   %eax
8010823b:	ff 75 08             	pushl  0x8(%ebp)
8010823e:	e8 1a fb ff ff       	call   80107d5d <mappages>
80108243:	83 c4 20             	add    $0x20,%esp
  for(; a < newsz; a += PGSIZE){
80108246:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010824d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108250:	3b 45 10             	cmp    0x10(%ebp),%eax
80108253:	0f 82 75 ff ff ff    	jb     801081ce <allocuvm+0x39>
  }
  return newsz;
80108259:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010825c:	c9                   	leave  
8010825d:	c3                   	ret    

8010825e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010825e:	55                   	push   %ebp
8010825f:	89 e5                	mov    %esp,%ebp
80108261:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108264:	8b 45 10             	mov    0x10(%ebp),%eax
80108267:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010826a:	72 08                	jb     80108274 <deallocuvm+0x16>
    return oldsz;
8010826c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010826f:	e9 a5 00 00 00       	jmp    80108319 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108274:	8b 45 10             	mov    0x10(%ebp),%eax
80108277:	05 ff 0f 00 00       	add    $0xfff,%eax
8010827c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108281:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108284:	e9 81 00 00 00       	jmp    8010830a <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828c:	83 ec 04             	sub    $0x4,%esp
8010828f:	6a 00                	push   $0x0
80108291:	50                   	push   %eax
80108292:	ff 75 08             	pushl  0x8(%ebp)
80108295:	e8 23 fa ff ff       	call   80107cbd <walkpgdir>
8010829a:	83 c4 10             	add    $0x10,%esp
8010829d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801082a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082a4:	75 09                	jne    801082af <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
801082a6:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801082ad:	eb 54                	jmp    80108303 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801082af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082b2:	8b 00                	mov    (%eax),%eax
801082b4:	83 e0 01             	and    $0x1,%eax
801082b7:	85 c0                	test   %eax,%eax
801082b9:	74 48                	je     80108303 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
801082bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082be:	8b 00                	mov    (%eax),%eax
801082c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801082c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082cc:	75 0d                	jne    801082db <deallocuvm+0x7d>
        panic("kfree");
801082ce:	83 ec 0c             	sub    $0xc,%esp
801082d1:	68 d9 8c 10 80       	push   $0x80108cd9
801082d6:	e8 8c 82 ff ff       	call   80100567 <panic>
      char *v = p2v(pa);
801082db:	83 ec 0c             	sub    $0xc,%esp
801082de:	ff 75 ec             	pushl  -0x14(%ebp)
801082e1:	e8 55 f5 ff ff       	call   8010783b <p2v>
801082e6:	83 c4 10             	add    $0x10,%esp
801082e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801082ec:	83 ec 0c             	sub    $0xc,%esp
801082ef:	ff 75 e8             	pushl  -0x18(%ebp)
801082f2:	e8 d6 a8 ff ff       	call   80102bcd <kfree>
801082f7:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801082fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108303:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010830a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108310:	0f 82 73 ff ff ff    	jb     80108289 <deallocuvm+0x2b>
    }
  }
  return newsz;
80108316:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108319:	c9                   	leave  
8010831a:	c3                   	ret    

8010831b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010831b:	55                   	push   %ebp
8010831c:	89 e5                	mov    %esp,%ebp
8010831e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108321:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108325:	75 0d                	jne    80108334 <freevm+0x19>
    panic("freevm: no pgdir");
80108327:	83 ec 0c             	sub    $0xc,%esp
8010832a:	68 df 8c 10 80       	push   $0x80108cdf
8010832f:	e8 33 82 ff ff       	call   80100567 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108334:	83 ec 04             	sub    $0x4,%esp
80108337:	6a 00                	push   $0x0
80108339:	68 00 00 00 80       	push   $0x80000000
8010833e:	ff 75 08             	pushl  0x8(%ebp)
80108341:	e8 18 ff ff ff       	call   8010825e <deallocuvm>
80108346:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108350:	eb 4f                	jmp    801083a1 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108355:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010835c:	8b 45 08             	mov    0x8(%ebp),%eax
8010835f:	01 d0                	add    %edx,%eax
80108361:	8b 00                	mov    (%eax),%eax
80108363:	83 e0 01             	and    $0x1,%eax
80108366:	85 c0                	test   %eax,%eax
80108368:	74 33                	je     8010839d <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010836a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108374:	8b 45 08             	mov    0x8(%ebp),%eax
80108377:	01 d0                	add    %edx,%eax
80108379:	8b 00                	mov    (%eax),%eax
8010837b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108380:	83 ec 0c             	sub    $0xc,%esp
80108383:	50                   	push   %eax
80108384:	e8 b2 f4 ff ff       	call   8010783b <p2v>
80108389:	83 c4 10             	add    $0x10,%esp
8010838c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010838f:	83 ec 0c             	sub    $0xc,%esp
80108392:	ff 75 f0             	pushl  -0x10(%ebp)
80108395:	e8 33 a8 ff ff       	call   80102bcd <kfree>
8010839a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010839d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083a1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801083a8:	76 a8                	jbe    80108352 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801083aa:	83 ec 0c             	sub    $0xc,%esp
801083ad:	ff 75 08             	pushl  0x8(%ebp)
801083b0:	e8 18 a8 ff ff       	call   80102bcd <kfree>
801083b5:	83 c4 10             	add    $0x10,%esp
}
801083b8:	90                   	nop
801083b9:	c9                   	leave  
801083ba:	c3                   	ret    

801083bb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801083bb:	55                   	push   %ebp
801083bc:	89 e5                	mov    %esp,%ebp
801083be:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083c1:	83 ec 04             	sub    $0x4,%esp
801083c4:	6a 00                	push   $0x0
801083c6:	ff 75 0c             	pushl  0xc(%ebp)
801083c9:	ff 75 08             	pushl  0x8(%ebp)
801083cc:	e8 ec f8 ff ff       	call   80107cbd <walkpgdir>
801083d1:	83 c4 10             	add    $0x10,%esp
801083d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801083d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083db:	75 0d                	jne    801083ea <clearpteu+0x2f>
    panic("clearpteu");
801083dd:	83 ec 0c             	sub    $0xc,%esp
801083e0:	68 f0 8c 10 80       	push   $0x80108cf0
801083e5:	e8 7d 81 ff ff       	call   80100567 <panic>
  *pte &= ~PTE_U;
801083ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ed:	8b 00                	mov    (%eax),%eax
801083ef:	83 e0 fb             	and    $0xfffffffb,%eax
801083f2:	89 c2                	mov    %eax,%edx
801083f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f7:	89 10                	mov    %edx,(%eax)
}
801083f9:	90                   	nop
801083fa:	c9                   	leave  
801083fb:	c3                   	ret    

801083fc <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801083fc:	55                   	push   %ebp
801083fd:	89 e5                	mov    %esp,%ebp
801083ff:	53                   	push   %ebx
80108400:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108403:	e8 e5 f9 ff ff       	call   80107ded <setupkvm>
80108408:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010840b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010840f:	75 0a                	jne    8010841b <copyuvm+0x1f>
    return 0;
80108411:	b8 00 00 00 00       	mov    $0x0,%eax
80108416:	e9 f8 00 00 00       	jmp    80108513 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010841b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108422:	e9 c4 00 00 00       	jmp    801084eb <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842a:	83 ec 04             	sub    $0x4,%esp
8010842d:	6a 00                	push   $0x0
8010842f:	50                   	push   %eax
80108430:	ff 75 08             	pushl  0x8(%ebp)
80108433:	e8 85 f8 ff ff       	call   80107cbd <walkpgdir>
80108438:	83 c4 10             	add    $0x10,%esp
8010843b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010843e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108442:	75 0d                	jne    80108451 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108444:	83 ec 0c             	sub    $0xc,%esp
80108447:	68 fa 8c 10 80       	push   $0x80108cfa
8010844c:	e8 16 81 ff ff       	call   80100567 <panic>
    if(!(*pte & PTE_P))
80108451:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108454:	8b 00                	mov    (%eax),%eax
80108456:	83 e0 01             	and    $0x1,%eax
80108459:	85 c0                	test   %eax,%eax
8010845b:	75 0d                	jne    8010846a <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010845d:	83 ec 0c             	sub    $0xc,%esp
80108460:	68 14 8d 10 80       	push   $0x80108d14
80108465:	e8 fd 80 ff ff       	call   80100567 <panic>
    pa = PTE_ADDR(*pte);
8010846a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010846d:	8b 00                	mov    (%eax),%eax
8010846f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108474:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108477:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010847a:	8b 00                	mov    (%eax),%eax
8010847c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108481:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108484:	e8 e1 a7 ff ff       	call   80102c6a <kalloc>
80108489:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010848c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108490:	74 6a                	je     801084fc <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108492:	83 ec 0c             	sub    $0xc,%esp
80108495:	ff 75 e8             	pushl  -0x18(%ebp)
80108498:	e8 9e f3 ff ff       	call   8010783b <p2v>
8010849d:	83 c4 10             	add    $0x10,%esp
801084a0:	83 ec 04             	sub    $0x4,%esp
801084a3:	68 00 10 00 00       	push   $0x1000
801084a8:	50                   	push   %eax
801084a9:	ff 75 e0             	pushl  -0x20(%ebp)
801084ac:	e8 d5 ce ff ff       	call   80105386 <memmove>
801084b1:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801084b4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801084b7:	83 ec 0c             	sub    $0xc,%esp
801084ba:	ff 75 e0             	pushl  -0x20(%ebp)
801084bd:	e8 6c f3 ff ff       	call   8010782e <v2p>
801084c2:	83 c4 10             	add    $0x10,%esp
801084c5:	89 c2                	mov    %eax,%edx
801084c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ca:	83 ec 0c             	sub    $0xc,%esp
801084cd:	53                   	push   %ebx
801084ce:	52                   	push   %edx
801084cf:	68 00 10 00 00       	push   $0x1000
801084d4:	50                   	push   %eax
801084d5:	ff 75 f0             	pushl  -0x10(%ebp)
801084d8:	e8 80 f8 ff ff       	call   80107d5d <mappages>
801084dd:	83 c4 20             	add    $0x20,%esp
801084e0:	85 c0                	test   %eax,%eax
801084e2:	78 1b                	js     801084ff <copyuvm+0x103>
  for(i = 0; i < sz; i += PGSIZE){
801084e4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084f1:	0f 82 30 ff ff ff    	jb     80108427 <copyuvm+0x2b>
      goto bad;
  }
  return d;
801084f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084fa:	eb 17                	jmp    80108513 <copyuvm+0x117>
      goto bad;
801084fc:	90                   	nop
801084fd:	eb 01                	jmp    80108500 <copyuvm+0x104>
      goto bad;
801084ff:	90                   	nop

bad:
  freevm(d);
80108500:	83 ec 0c             	sub    $0xc,%esp
80108503:	ff 75 f0             	pushl  -0x10(%ebp)
80108506:	e8 10 fe ff ff       	call   8010831b <freevm>
8010850b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010850e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108513:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108516:	c9                   	leave  
80108517:	c3                   	ret    

80108518 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108518:	55                   	push   %ebp
80108519:	89 e5                	mov    %esp,%ebp
8010851b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010851e:	83 ec 04             	sub    $0x4,%esp
80108521:	6a 00                	push   $0x0
80108523:	ff 75 0c             	pushl  0xc(%ebp)
80108526:	ff 75 08             	pushl  0x8(%ebp)
80108529:	e8 8f f7 ff ff       	call   80107cbd <walkpgdir>
8010852e:	83 c4 10             	add    $0x10,%esp
80108531:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108537:	8b 00                	mov    (%eax),%eax
80108539:	83 e0 01             	and    $0x1,%eax
8010853c:	85 c0                	test   %eax,%eax
8010853e:	75 07                	jne    80108547 <uva2ka+0x2f>
    return 0;
80108540:	b8 00 00 00 00       	mov    $0x0,%eax
80108545:	eb 2a                	jmp    80108571 <uva2ka+0x59>
  if((*pte & PTE_U) == 0)
80108547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854a:	8b 00                	mov    (%eax),%eax
8010854c:	83 e0 04             	and    $0x4,%eax
8010854f:	85 c0                	test   %eax,%eax
80108551:	75 07                	jne    8010855a <uva2ka+0x42>
    return 0;
80108553:	b8 00 00 00 00       	mov    $0x0,%eax
80108558:	eb 17                	jmp    80108571 <uva2ka+0x59>
  return (char*)p2v(PTE_ADDR(*pte));
8010855a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855d:	8b 00                	mov    (%eax),%eax
8010855f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108564:	83 ec 0c             	sub    $0xc,%esp
80108567:	50                   	push   %eax
80108568:	e8 ce f2 ff ff       	call   8010783b <p2v>
8010856d:	83 c4 10             	add    $0x10,%esp
80108570:	90                   	nop
}
80108571:	c9                   	leave  
80108572:	c3                   	ret    

80108573 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108573:	55                   	push   %ebp
80108574:	89 e5                	mov    %esp,%ebp
80108576:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108579:	8b 45 10             	mov    0x10(%ebp),%eax
8010857c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010857f:	eb 7f                	jmp    80108600 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108581:	8b 45 0c             	mov    0xc(%ebp),%eax
80108584:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108589:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010858c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010858f:	83 ec 08             	sub    $0x8,%esp
80108592:	50                   	push   %eax
80108593:	ff 75 08             	pushl  0x8(%ebp)
80108596:	e8 7d ff ff ff       	call   80108518 <uva2ka>
8010859b:	83 c4 10             	add    $0x10,%esp
8010859e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801085a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801085a5:	75 07                	jne    801085ae <copyout+0x3b>
      return -1;
801085a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085ac:	eb 61                	jmp    8010860f <copyout+0x9c>
    n = PGSIZE - (va - va0);
801085ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085b1:	2b 45 0c             	sub    0xc(%ebp),%eax
801085b4:	05 00 10 00 00       	add    $0x1000,%eax
801085b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801085bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085bf:	3b 45 14             	cmp    0x14(%ebp),%eax
801085c2:	76 06                	jbe    801085ca <copyout+0x57>
      n = len;
801085c4:	8b 45 14             	mov    0x14(%ebp),%eax
801085c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801085ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801085cd:	2b 45 ec             	sub    -0x14(%ebp),%eax
801085d0:	89 c2                	mov    %eax,%edx
801085d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085d5:	01 d0                	add    %edx,%eax
801085d7:	83 ec 04             	sub    $0x4,%esp
801085da:	ff 75 f0             	pushl  -0x10(%ebp)
801085dd:	ff 75 f4             	pushl  -0xc(%ebp)
801085e0:	50                   	push   %eax
801085e1:	e8 a0 cd ff ff       	call   80105386 <memmove>
801085e6:	83 c4 10             	add    $0x10,%esp
    len -= n;
801085e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ec:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801085ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f2:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801085f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085f8:	05 00 10 00 00       	add    $0x1000,%eax
801085fd:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108600:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108604:	0f 85 77 ff ff ff    	jne    80108581 <copyout+0xe>
  }
  return 0;
8010860a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010860f:	c9                   	leave  
80108610:	c3                   	ret    
