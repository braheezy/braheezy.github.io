---
date: "2023-10-04T19:45:34Z"
tags:
- Go
- Audio
title: 'What I Learned About MP3 Encoding'
---

## The Best MP3 Encoder is LAME
When it comes to MP3 encoding, there is one de-facto leader in the open-source industry: [LAME](https://lame.sourceforge.io/index.php). It's been given the attention of software and audio engineers [for years](https://svn.code.sf.net/p/lame/svn/trunk/lame/doc/html/history.html) which shows in the extensive features it comes with. If you want to encode audio data to MP3 with professional performance and quality, you either use LAME or [something built on top of it](https://lame.sourceforge.io/links.php).

If you're a programmer and want to encode audio to MP3, you likely search your language's ecosystem to piggyback off someone else's work. Let's look at the state of MP3 encoding in some languages and tools:
- The lauded [FFmpeg](https://ffmpeg.org/): `ffmpeg` is the ubiquitous program for processing video and audio. If you've ever watched a YouTube video, you consumed something that `ffmpeg` touched. For MP3 encoding, it uses LAME [underneath the hood](https://trac.ffmpeg.org/wiki/Encode/MP3)
- Python:
    - [LAME bindings](https://pypi.org/project/lameenc/): This provides a Python API to the `libmp3lame` C library. So you need `libmp3lame` installed for this to work.
    - [PyAudio Tools](https://audiotools.sourceforge.net/install.html) but it still requires `libmp3lame` to be for MP3 encoding, specifically.
- Rust: [LAME bindings](https://crates.io/crates/mp3lame-encoder), but Rust flavored.
- Java: Nice! A [native port](https://github.com/Sciss/jump3r)[^1] of LAME.
- Go: More [LAME bindings](https://github.com/viert/go-lame).
- JavaScript: Another [port!](https://github.com/zhuker/lamejs)...well, it's a port of the `jump3r-code` Java port of LAME.

It's LAME all the way down.

During [my play](https://github.com/braheezy/goqoa) with the [Quite OK Audio (QOA)](https://qoaformat.org/) format, I had tons of fun converting QOA files, something that no tool or library knows about, into various audio formats. That included covering `.qoa` files to `.mp3`.

That's when I met LAME for the first time, one dark, stormy night. The [go-lame](https://github.com/viert/go-lame) project introduced us and, like so many projects above, provides Go language bindings to LAME. With all my Go projects, I like to support Linux, Mac, and Windows platforms, but `go-lame` doesn't explicitly state it will support Windows platforms. It was up to me! And maybe ChatGPT.

No matter what I tried with C cross compilers, native Windows environments, and the slew of magic-build-everything-containers out there claiming to have all the tools bundled, I couldn't get `go-lame` to build for Windows.

Exasperated, I pushed out with development on my QOA program by not supporting MP3 on Windows. But this left a bad taste in my mouth...if only I had a Go library that didn't rely on LAME. Maybe I should write one?[^2]

## Where The Encoding At?
Full of hubris, I started researching deeper into MP3 theory. How difficult could this be?

*Narrator: It's very difficult.*

- There's no official MPEG-1 standard for how the encoder should behave. There are only official specifications of the file format and how an encoded MP3 bitstream should be structured. This lets decoders all behave the same but how an encoder creates that bitstream is up to the author. This created a wide variety in quality of 90s-00s encoding implementations.
- The ISO documents describing the nitty-gritty technical details one might use to implement an encoder are tucked behind [paywalls](https://www.iso.org/standard/22412.html). The practice of hiding and gating knowledge is offensive and stifles interest and innovation.
- The basic encoding/decoding technology for [MP3 was under a patent](https://www.wikiwand.com/en/MP3#Licensing,_ownership,_and_legislation) for all of the 90s and 00s. It wasn't patent-free in the US until 2017. Open-source and hobbyist developers like myself are going to avoid anything involving patents.
- The very algorithms that MP3 uses are not for the faint of heart. Check out this great diagram from a PDF I found:

![MP3 Encoding Algorithm](/assets/img/mp3-encoding-algorithm.png)

I'll draw your attention to one block: the psychoacoustic model. Beyond just being a really cool word, it means the encoding algorithm will analyze the characteristics of the audio wave and throw out parts of the sound that humans can't hear that well anyway. As a simple example, humans can only hear frequencies between 20 Hz and 20 kHz, so throw away any frequencies above and below those limits.

If you want more details on the MP3 encoding algorithm, [this PDF is the best introduction](https://github.com/braheezy/shine-mp3/blob/1782d18a1f8fef7faf27f67e99ac8c6f7056cdd4/docs/mp3_theory.pdf) I found.

---

Accepting that I won't be writing a new MP3 implementation from scratch, I next considered porting the C LAME library to Go. I opened a shell to check if that was reasonable and ran this `cloc` command that counts the lines of code in a project:

    $ cloc .
          62 text files.
          62 unique files.
          11 files ignored.

    github.com/AlDanial/cloc v 1.90  T=0.04 s (1381.9 files/s, 735490.1 lines/s)
    ------------------------------------------------------------------------------
    Language                    files          blank        comment           code
    ------------------------------------------------------------------------------
    C                              21           3130           3427          16610
    C/C++ Header                   24            483            726           1670
    Bourne Shell                    1             64            224            503
    make                            3             47             14            164
    Windows Resource File           1              3              1             46
    IDL                             1              1              0             31
    ------------------------------------------------------------------------------
    SUM:                           51           3728           4392          19024
    ------------------------------------------------------------------------------

16k lines of obscure C, riddled with pointer magic and arcane memory manipulations? No thanks!

## Can Other MP3 Encoders Shine?
I had to remember I was only here on a side quest to resolve a bug in my QOA program. MP3 it just is no one special. I needed a quicker path to success. I don't need no fancy MP3 encoder.

LAME is nice enough to [mention alternative encoders](https://lame.sourceforge.io/links.php#Alternatives), bragging when they can about their superior implementation (and they should!). One entry on the list caught my eye:
> **Shine** is a featureless, but clean and readable MP3 encoder by Gabriel Bouvigne of LAME fame. Great as a starting point or learning tool. Also probably the only open source, fixed point math MP3 encoder.

This sounds exactly what I'm looking for:
- [x] Open source
- [x] Featureless i.e. not overly complex
- [x] Readable
- [x] Great as a starting point

A quick internet search led me to the apparent [modern form of Shine](https://github.com/toots/shine). With FAR less code to reason about, I had found an MP3 encoder to port.

## Poof: Turning C to Go
This took my two serious attempts. Which was unfortunate but it did give me a better understanding of the program as a whole =]

In my first attempt, I sat down file by file and wrote each C function to it's Go counterpart. I'll admit it, a lot of it I just threw at ChatGPT and asked it to convert. Here's an example exchange:

![A convo with chatgpt](/assets/img/chatgpt-mp3-convertor.png)

Eventually, I had something that would compile...but the MP3 files it made were 5x larger than reference MP3 files I was comparing against. Audio players refused to play them, which told me they were not even the right format. I troubleshot for a few days but based on my output files, I had a feeling I was way off-base. In despair, I searched the Internet for C to Go help...

And found [cxgo](https://github.com/gotranspile/cxgo)! It claims to transpile C to Go. Despite it's experimental warnings, it offered a glimmer of hope and I quickly downloaded it. I tested it on a small C file and the result looked good. I threw it at the whole Shine library and to my surprise, there were no errors! I had a full Go program in seconds (this is where the sting of failing the first attempt hit).

Here's an example. This C code:
```C

/*
 * shine_putbits:
 * --------
 * write N bits into the bit stream.
 * bs = bit stream structure
 * val = value to write into the buffer
 * N = number of bits of val
 */
void shine_putbits(bitstream_t *bs, unsigned int val, unsigned int N) {
#ifdef DEBUG
  if (N > 32)
    printf("Cannot write more than 32 bits at a time.\n");
  if (N < 32 && (val >> N) != 0)
    printf("Upper bits (higher than %d) are not all zeros.\n", N);
#endif

  if (bs->cache_bits > N) {
    bs->cache_bits -= N;
    bs->cache |= val << bs->cache_bits;
  } else {
    if (bs->data_position + sizeof(unsigned int) >= bs->data_size) {
      bs->data = (unsigned char *)realloc(bs->data,
                                          bs->data_size + (bs->data_size / 2));
      bs->data_size += (bs->data_size / 2);
    }

    N -= bs->cache_bits;
    unsigned int shift = val >> N;
    bs->cache |= shift;
#ifdef SHINE_BIG_ENDIAN
    *(unsigned int *)(bs->data + bs->data_position) = bs->cache;
#else
    *(unsigned int *)(bs->data + bs->data_position) = SWAB32(bs->cache);
#endif
    bs->data_position += sizeof(unsigned int);
    bs->cache_bits = 32 - N;
    if (N != 0)
      bs->cache = val << bs->cache_bits;
    else
      bs->cache = 0;
  }
}
```

Becomes this Go code:
```go
import (
	"github.com/gotranspile/cxgo/runtime/libc"
	"unsafe"
)

func shine_putbits(bs *bitstream_t, val uint64, N uint64) {
	if uint64(bs.Cache_bits) > N {
		bs.Cache_bits -= int64(N)
		bs.Cache |= val << uint64(bs.Cache_bits)
	} else {
		if bs.Data_position+int64(unsafe.Sizeof(uint64(0))) >= bs.Data_size {
			bs.Data = (*uint8)(libc.Realloc(unsafe.Pointer(bs.Data), int(bs.Data_size+bs.Data_size/2)))
			bs.Data_size += bs.Data_size / 2
		}
		N -= uint64(bs.Cache_bits)
		bs.Cache |= val >> N
		*(*uint64)(unsafe.Pointer((*uint8)(unsafe.Add(unsafe.Pointer(bs.Data), bs.Data_position)))) = (bs.Cache >> 24) | ((bs.Cache >> 8) & 0xFF00) | (bs.Cache&0xFF00)<<8 | bs.Cache<<24
		bs.Data_position += int64(unsafe.Sizeof(uint64(0)))
		bs.Cache_bits = int64(32 - N)
		if N != 0 {
			bs.Cache = val << uint64(bs.Cache_bits)
		} else {
			bs.Cache = 0
		}
	}
}
```

Sure, we've got this `libc` import now and I was trying to avoid C, but it works. After more tweaks, I again arrived at a compilable program. This time it produced MP3 files that were byte-for-byte identical to Shine-produced MP3s. Success!! :tada:

## Graduating to a Pure Go Library
The last task was to hunt through the code and remove every use of `cxgo/runtime/libc`. As a bonus, I'd also try to remove the `unsafe` package because safe is better than unsafe, right?

Pruning `libc` ended up being easy work of replacing mathematical functions with their appropriate `math` counterpart. Making the library safe proved more challenging. As of this writing, there is an [open issue on the library](https://github.com/braheezy/shine-mp3/issues/1) to remove the last usage of the `unsafe` package. There's only one more, can you figure it out?

There's no C left, so mission accomplished! Now Windows folks can encode MP3 files in pure Go. Yay?

[^1]: For non-programmers, a port is software written in a different language.
[^2]: Yes I know there are quicker ways to accomplish this than writing a whole library. Get off my lawn!
