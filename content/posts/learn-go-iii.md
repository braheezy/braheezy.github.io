---
categories:
- Golang A Go Go
date: "2022-09-11T23:10:07Z"
tags:
- Go
- Education
title: 'Learn Go: III'
---
The next item in my Go curriculum is to start writing code. At this point, I haven't installed Go or configured an IDE  and I really don't want to. It's a commitment I'm not ready to make yet. Instead, I hop on the internet to find a Coding challenge site.

There are many websites that provide a straightforward and comfortable environment for eager students to get their hands dirty with actual code and actual coding problems. Early in my software education, these sites were instrumental in (making me feel like I was) sharpening my skills at problem solving and language knowledge. The big ones like LeetCode and HackerRack have gotten so popular that large MAANG companies use these sites to weed out interviewees, like me. They usually have a similar format:
- The problem is described and illustrated with examples
- A text editor with function declaration is given. You must provide the function body
- Automated test cases so you know when you got the problem right. Good sites will have hidden test cases that ensure you meet a certain space and time complexity.

There was one site I particularly enjoyed a few years ago and I grew several Python fluency levels while using it. There was a pleasant UI and different portions of the site to explore with different learning tracks. Navigating the site to find challenges based on skill was intuitive and usually curated. The coding area itself was great and I remember liking the tests and witty edge cases. But alas, in 2022 I can't find the site anymore, or can't remember the name. Either way, I had to find a new one.

I settled on [CodeWars](https://www.codewars.com/). It met all my requirements and it was quick enough to get started with. This would be a productive area to be given elementary programming problems that in another language I knew would be a breeze, but in Go, I would have to look up syntax on how to express the solution. It was a constant recurrence to think *"Okay, in Python I would do this, so to convert to Go I need to write it like this..."*. As I worked through problems, it was interesting to work through this translation penalty.

The site says I've completed 31 [kata](https://en.wikipedia.org/wiki/Kata), the word they chose for problems. This comes from the idea that one way of becoming a better programmer is to practice solving small challenges daily. While this does work to a point, I ultimately disagree with the philosophy when it comes to programming. Kata in martial arts is about learning muscle memory and perfect physical movements. The efficacy of one's fingers moving across the keyboard is typically not the limiting factor in an aspiring engineer's education. There are other domains where the kata learning technique is more applicable, like learning a musical instrument.

I wrote this post several weeks after doing the katas but here are a couple interesting ones I ran into.

## Multiples of Index
> Return a new array consisting of elements which are multiple of their own index in input array (length > 1).

This has classic array operations all over it. Array iteration, working with indexes and values, and creating a new array. There's probably some `map` way of solving this but as a Go noob, I arrived at the following:
```go
func multipleOfIndex (ints []int) (result []int) {
  // Ignore the first element of the `ints` array b/c it's index is 0.
  i := 1
  // As Gophers know, there's multiple way to write a for loop. I like this `range` way
  for _, val := range ints[1:] {
    // No remainder leftover from modulo division means
    // val is a multiple of i.
    if val % i == 0 {
      result = append(result, val)
    }
    i++
  }
  return result
}
```

## Shortest Word
> Simple, given a string of words, return the length of the shortest word(s).
>
> String will never be empty and you do not need to account for different data types.

It's common to work with sentences that need to be broken down into words and then some operation done on those words. This problem gives a chance to look at Go string handling in the standard library.

```go
import (
  "strings"
)

func FindShort(s string) (shortestWordLen int) {
  // `Fields` is a great function that breaks the sentence by whitespace, giving us our words.
  for i, word := range strings.Fields(s) {
    word_length := len(word)
    // If it's the first word, it's the longest we've seen so far. Otherwise, do the check
    if i == 0 || word_length < shortestWordLen {
      shortestWordLen = word_length
    }
  }
  return shortestWordLen
}
```

## Mumbling
> This time no story, no theory. The examples below show you how to write function `accum`:
> Examples:
>
>       accum("abcd") -> "A-Bb-Ccc-Dddd"
>       accum("RqaEzty") -> "R-Qq-Aaa-Eeee-Zzzzz-Tttttt-Yyyyyyy"
>       accum("cwAt") -> "C-Ww-Aaa-Tttt"
>
> The parameter of `accum` is a string which includes only letters from `a..z` and `A..Z`.

Here's one where in Python, I immediately would be looking at the `itertools` library to see what functional programming trick could be used to solve the problem. It's a good opportunity to see what functional programming Go offers.

Not much! The standard library is small compared to Python's and because Generic type support in Go was only just added, generic helpers like `itertools` aren't here yet.

```go
import (
  "strings"
  "fmt"
)

func Accum(s string) string {
  // I learned cool kids use strings.Builder to make strings instead of `+=`
  var sb strings.Builder

  // For each character in the string...
  for i, c := range s {
    // Create a string that repeats the character by the amount of it's index
    repeated_string := strings.Repeat(strings.ToLower(string(c)), i + 1)
    // Add string to builder, making sure to Title case it first
    fmt.Fprintf(&sb, "%s-", strings.Title(repeated_string))
  }
  return strings.TrimRight(sb.String(), "-")
}
```

## NthEven
> Return the Nth Even Number
>
> Example(Input --> Output)
>
>     1 --> 0 (the first even number is 0)
>     3 --> 4 (the 3rd even number is 4 (0, 2, 4))
>     100 --> 198
>     1298734 --> 2597466

> The input will not be 0.

Okay this one I just wanted to show off :grin:

Thought process:
- Every other number is odd, so to get to `n`th even number, you need:  `n * 2`
- Oh, but the first two numbers don't count, `0` and `1`, so subtract: `(n * 2) - 2`
- My Algebra bone is tickling. That can be refactored by pulling the `2` out: `2 * (n - 1)`
- I know a little obfuscation technique in that `x / 2 == x >> 1`. That means I can switch the binary shift if I want to multiply: `(n - 1) * 2` becomes `(n - 1) << 1`

To be clear, this would never go in production code unless you wanted comrade programmers to come a-hunting with pitchforks.

```go
func NthEven(n int) int {
    return (n - 1) << 1
}
```

## Final Thoughts
CodeWars has been fun but like I spewed earlier, single focused problems like katas and their ilk can only take the student so far. The graduation to actual **Projects** needs to take place. Install the language and a build toolchain. Configure a development environment. Write an entire program that does a Whole Thing, not just a single function to a very specific prompt. If you feel stalled in your programming journey and haven't left the curated air conditioned halls of sites like HackerRank, try branching into Projects.
