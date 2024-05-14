---
title: Z85 Format
date: 5/13/24
cover:
    image: assets/demo.png
    alt: z85 encoding and decoding
    caption: Hello World in z-85 land
    hidden: false
    hiddenInSingle: true
summary: Z85 encoding and decoding
tags:
    - Go
ShowToc: false
---

# What
A simple CLI tool for working with the Z85 format, an alternative to Ascii85 for encoding binary data to text.

# Code
https://github.cin/braheezy/z85

# Thoughts
I wanted to create a small, single-focused, low level CLI tool and library for working with data. I came across the [well-documented specification](https://rfc.zeromq.org/spec/32/) for Z85 and it was a great fit for such project goals.

This project showed me the inner workings of binary-to-text encodings in a way that I hadn't seen before. It was a great weekend project.
