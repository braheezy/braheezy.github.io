---
title: hobby projects
date:
ShowToc: true
---
Some of the things I've made. Most of the repositories have more demo materials.

- [audio](#audio)
- [emulation](#emulation)
- [graphics](#graphics)
- [applications](#applications)
- [languages](#languages)

---

## audio
- **goqoa**
  - A CLI tool for converting and playing handling [Quite OK Audio (QOA)](https://qoaformat.org/) files.
  - **Technologies Used:** `Go`
  - **Features:**
    - convert WAV, FLAC, OGG, or MP3 files to QOA
    - convert QOA files to WAV or MP3
    - play QOA files
  - **Repository:** [goqoa](https://github.com/braheezy/goqoa)

- **QOA Preview for VS Code**
  - VS Code extension to play [Quite OK Audio (QOA)](https://qoaformat.org/) files.
  - **Technologies Used:** `TypeScript`, `HTML/JS/CSS`
  - **Features:**
    - play a QOA file
    - using lots of CSS, looks visually similar to default audio player in VS Code
  - **Repository:** [vscode-qoa-preview](https://github.com/braheezy/vscode-qoa-preview)

- [**wavvy**](https://wavvy.braheezy.net/)
  - Website using WASM to play WAV files.
  - **Technologies Used:** `Go`, `WASM`, `HTML/JS/CSS`
  - **Features:**
    - WAV decoding and playback in Go via WASM
  - **Repository:** [wavvy](https://github.com/braheezy/wavvy)

- **shine-mp3**
  - A working MP3 encoder, perhaps the only one in pure Go. Ported from the Shine MP3 project.
  - **Technologies Used:** `Go`
  - **Features:**
    - Create bit-identical MP3s to those created by the original C implementation.
  - **Repository:** [shine-mp3](https://github.com/braheezy/shine-mp3)

---

## emulation

- **chip-8**
  - A full CHIP-8 interpreter. Runs CHIP-8 ROMs.
  - **Technologies Used:** `Go`
  - **Features:**
    - Run in GUI or TUI mode
    - Timendus [test suite](https://github.com/Timendus/chip8-test-suite) compliant
    - Support for COSMAC VIP and other quirks
  - **Repository:** [chip-8](https://github.com/braheezy/chip-8)

- **space-invaders**
  - An accurate emulation of 1978 Space Invaders arcade hardware.
  - **Technologies Used:** `Go`
  - **Features:**
    - Full 8080 CPU emulator
    - Cycle accurate timing
    - Hardware accurate interrupt handling and sound
    - Input via keyboard
  - **Repository:** [space-invaders](https://github.com/braheezy/space-invaders)

---

## graphics

- [**hobby-spline**](https://hobby-spline.braheezy.net/):
  - An interactive demo website on Hobby Splines.
  - **Technologies Used:** `Go`, `WASM`, `HTML/JS/CSS`
  - **Features:**
    - Embedded WASM GUI
  - **Repository:** [hobby-spline](https://github.com/braheezy/hobby-spline)

- **bubblelife**
  - A bunch of bubbles arranged in a 3D pillar, updating according to Conway's Game of Life.
  - **Technologies Used:** `Go`, `OpenGL`
  - **Features**
    - Live settings to update population, pillar size, etc.
    - Software calculed HDRi cubemap, text rendering, bespoke UI, Blinn-Phong shading
    - Can render thousands of bubbles performantly with instanced point rendering
  - **Repository:** [bubblelife](https://github.com/braheezy/bubblelife)

---

## applications

- **violet**
  - Colorful TUI frontend to run Vagrant commands
  - **Technologies Used:** `Go`
  - **Features:**
    - Supports `up`, `ssh`, `reload`, `provision`, and `halt`
  - **Repository:** [violet](https://github.com/braheezy/violet)

- **kilo**
  - An absolute minimal terminal text editor.
  - **Technologies Used:** `Go`
  - **Features:**
    - About 1k lines of code
    - Able to edit it's own source code
  - **Repository:** [kilo](https://github.com/braheezy/kilo)

- **hangman**
  - The classic game right in your terminal.
  - **Technologies Used:** `Go`
  - **Features:**
    - Free fun
  - **Repository:** [hangman](https://github.com/braheezy/hangman)

---

## languages

- **gravlax**
  - Full implementation of a tree-walk interpreter for the educational language [Lox](https://craftinginterpreters.com).
  - **Technologies Used:** `Go`
  - **Features:**
    - Full Lox language support
    - Extra support for block comments and the `break` keyword
  - **Repository:** [gravlax](https://github.com/braheezy/gravlax)

- **zig-lox**
  - Full implementation of a bytecode VM for the educational language [Lox](https://craftinginterpreters.com).
  - **Technologies Used:** `Zig`
  - **Features:**
    - Full Lox language support
    - Garbage collector
  - **Repository:** [zig-lox](https://github.com/braheezy/zig-lox)
