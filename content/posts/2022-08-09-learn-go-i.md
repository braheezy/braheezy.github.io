---
categories:
- Golang A Go Go
date: "2022-08-09T02:08:40Z"
tags:
- Go
- Education
title: 'Learn Go: I'
---
In the [last post]({% post_url 2022-07-25-new-language-first-steps %}), I went over why wanted to learn Go. In this post I put my money where my mouth is.

## Readying Up
Coffee poured and hip-hop music on, I sit down at my computer to learn. In the most naive fashion, I decide to start by finding and going to the [Go website](https://go.dev/).

![Go Homepage link](/assets/img/Go_Homepage.png)

This turns out to be the best choice. The [Tour of Go](https://go.dev/tour/) found under the **Get Started** page is an "interactive introduction to Go in three sections". A curated tutorial to the language by the language creators. Okay Google. Making it too easy.

## Setting Out
The Tour starts pleasantly and introduces basic syntax. Often, links are provided out to the Go blog to color in the background of certain topics. These were thoroughly appreciated, like this one on [Declaration Syntax](https://go.dev/blog/declaration-syntax) (I had never heard of the [Clockwise/Spiral Rule](https://c-faq.com/decl/spiral.anderson.html) before. That would have helped a ton when I wrote C).

After working with Python for so long, the first lesson makes a point to remind me of types (`int`, `float64`, etc.) and all the related business of defining them and converting between them. I find the `rune` type, which holds a single character value, and the `complex128` type, which can hold complex numbers, a delightful decision by the language designers. The other cool language feature that sticks out is named return values, allowing you to define the name of the return variable in the function declaration.
```go
// x and y are variables defined in the declaration, used in the body,
// and returned. Less typing!
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return x, y
}
```

## Going In
The next lesson introduces how Go lets the programmer control the flow of execution within their program. Stuff like `if` and loops.

Go has one loop: `for`. But they provided a bunch of flexibility in how it's used. There's the normal `for` from many languages:

```go
package main

import "fmt"

func main() {
	sum := 0
	for i := 0; i < 10; i++ {
		sum += i
	}
	fmt.Println(sum)
}
```
But the first and last statements are optional.
```go
package main

import "fmt"

func main() {
    // This is a while loop.
    sum := 1
	for sum < 10 {
		sum += sum
	}
	fmt.Println(sum)
}
```

Go `if`s have a nice convenience of letting you run a short inline statement:
```go
// v has scope for the if block
if v := math.Pow(x, n); v < lim {
		return v
}
```

Switch statements are next. Python didn't have these [until recently](https://peps.python.org/pep-0636/) so it's nice to see again. It's easy and quick to use in Go, like this idiomatic way of writing long if-else chains:
```go
func main() {
	t := time.Now()
	switch {
	case t.Hour() < 12:
		fmt.Println("Good morning!")
	case t.Hour() < 17:
		fmt.Println("Good afternoon.")
	default:
		fmt.Println("Good evening.")
	}
}
```

The last concept is one I've never seen before and am too lazy to research to see if another language has anything like it. The `defer` keyword lets you run a function when the outer function exits:
```go
func main() {
	defer fmt.Println("world")

	fmt.Println("hello")
}
```
The obvious use case is using `defer` to run cleanup functions in more complicated programs. [Go docs mention this](https://go.dev/blog/defer-panic-and-recover) and point out how it eases the burden of cleanup on the programmer by allowing resource cleanup to be defined right when resources are created.

## Still Going
**Pointers**. They're back (I know, they were never really gone to begin with). Go provides direct access to pointer magic with familiar `*`(dereference) and `&`(address) operators. Thankfully, there's no pointer arithmetic. I suspect that results in less C-like pointer shenanigans.

**Structs** are here too. Go has no `class` keyword so it looks like `struct`s will carry a heavy workload when programmers want to employ object-orientated techniques. The syntax is as expected and members of structs can be access with `.` notation:
```go
type Vertex struct {
	X int
	Y int
}

func main() {
	v := Vertex{1, 2}
	fmt.Println(v.X)
}
```

**Arrays** can be used too but one works with **Slices** much more often. They are "views" into an underlying array. Edit a value in them and the underlying array changes too and you betcha, you can make slices of slices.
```go
func main() {
    // An array initialized with some values
	primes := [6]int{2, 3, 5, 7, 11, 13}

    // Creating a slice by accessing the array with [:] syntax
	var s []int = primes[1:4]
	fmt.Println(s)
}
```
The Tour talks of slices having a length and capacity. These are intuitive: length is how large the slice is, and capacity is how much room the slice could grow based on the underlying array.

Two useful operations are shown: `append` and `range`.
```go
func main() {
    // Initialize an array with values to copy from
    var source []int{1, 2, 3}
    // Initialize an empty array to copy to
    var target []int

    // range iterates over each value in source and returns it.
    // It also returns the index of the value in the array.
    for index, value := range source {
        target = append(target, value)
    }

    fmt.Printf(target)
}
```

## Faltering
The Tour includes Exercises that require actual code implementation to complete. There's one on slices that says this:
> Implement `Pic`. It should return a slice of length `dy`, each element of which is a slice of `dx` 8-bit unsigned integers. When you run the program, it will display your picture, interpreting the integers as grayscale (well, bluescale) values.
>
> The choice of image is up to you. Interesting functions include `(x+y)/2`, `x*y`, and `x^y`.
>
> (You need to use a loop to allocate each `[]uint8` inside the `[][]uint8`.)
>
> (Use `uint8(intValue)` to convert between types.)

I admit it. I didn't really know what this prompt was asking for...ahem...humbling. I found solutions online and the implementations made sense but I still didn't get what was going on. I wiped the tears from my eyes and continued to...

**Maps**! Hashmaps, key-values tables, dictionaries. Whatever you want to call them. These I understand and can regain confidence on. Maps in Go are friendly to work with like in Python
```go
func main() {
	m := make(map[string]int)

	m["Answer"] = 42
	fmt.Println("The value:", m["Answer"])

	m["Answer"] = 48
	fmt.Println("The value:", m["Answer"])

	delete(m, "Answer")
	fmt.Println("The value:", m["Answer"])

	v, ok := m["Answer"]
	fmt.Println("The value:", v, "Present?", ok)
}
```

**Functions** are first-class citizens in Go. They can be passed around and saved to variables like everybody else. This *usually* means the language supports powerful functional programming solutions (many lines of Go code later, I'm finding that might not be the case here).

There's also **Closures** that essentially bind a function to an external variable. These take me some time to digest properly:
```go
// The adder function returns a closure. Each closure is bound to its own `sum` variable.
func adder() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 0; i < 10; i++ {
		fmt.Println(
			pos(i),
			neg(-2*i),
		)
	}
}
```
Using a foreign language construct in an actual program you write is the best way to really understand it and that quickly [became true for me](https://github.com/braheezy/gobites/blob/8646dd27a52d14c277fa8e094cf3aa42ce23cb5d/pkg/_1_wordvalue/data.go).

But on day one in the Tour, I don't have that practice and their Fibonacci Exercise stumps me too:
> Let's have some fun with functions.

> Implement a fibonacci function that returns a function (a closure) that returns successive fibonacci numbers (0, 1, 1, 2, 3, 5, ...).

The code template they provided:
```go
package main

import "fmt"

// fibonacci is a function that returns
// a function that returns an int.
func fibonacci() func() int {
}

func main() {
	f := fibonacci()
	for i := 0; i < 10; i++ {
		fmt.Println(f())
	}
}
```
I am NOT having fun with functions :/
