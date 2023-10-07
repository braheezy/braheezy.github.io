---
title: shine-mp3
date: 10/7/23
cover:
    image: assets/diff.png
    alt: Diff of MP3 files
    caption: Confirming encoded MP3 matches reference file
    hidden: false
    hiddenInSingle: true
summary: Porting the Shine MP3 encoder to pure Go
tags:
  - Go
  - MP3
ShowToc: false
---

# Code
https://github.com/braheezy/shine-mp3

# What
A port of the [Shine MP3 encoding C library](https://github.com/toots/shine) to Go, creating the only pure Go MP3 encoding library.

The C and Go library produce byte-identical binaries, as seen in the screenshot above.

# Demo
A simple WAV file:

{{< audio src="/assets/sounds/test.wav" caption="test.wav" >}}
---
The WAV file converted to MP3 by the Go Shine library:

{{< audio src="/assets/sounds/test.mp3" caption="test.mp3" >}}

---
The WAV file converted to MP3 by the C Shine library:

{{< audio src="/assets/sounds/test.shineenc-C.mp3" caption="test.shineenc-C.mp3" >}}

# Why
In a different project, I wanted to support MP3 encoding on Windows platforms without needing `CGO` enabled.

# Thoughts
See the post here: [MP3 Encoding in Go ](../../posts/mp3-encoder-go).