---
categories:
- Golang A Go Go
date: "2022-08-14T21:13:05Z"
tags:
- Go
- Education
title: 'Learn Go: II'
---
We'll finish the rest of the [Tour of Go](https://go.dev/tour/) this time, which was started in the [previous post]({% post_url 2022-08-09-learn-go-i %}).

## Methoding Around
The Tour's next lesson is called **Methods**. But wait...there's no classes, what are you calling methods on?

Types! A *method* is a specific type of *function* that can be identified by the way they are declared. A **receiver** argument appears after the keyword `func` and before the method name:
```go
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}
//Abs method has a receiver of type Vertex named v
func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs())
}
```
Methods also can:
- Be defined on primitive types like `type MyFloat float64`
- Receive pointers, allowing them to act on the original entity, or be more efficient if the receiver is e.g. a large struct

Next up is **Interfaces**, defined as a collection of method signatures. This immediately sticks out as Go's approach to Abstract types, a powerful OOP concept. You specify the functions you want children to implement before they can call your interface a parent:
```go
package main

import (
	"fmt"
	"math"
)

type Abser interface {
	Abs() float64
}

func main() {
	var a Abser
	f := MyFloat(-math.Sqrt2)
	v := Vertex{3, 4}

	a = f  // a MyFloat implements Abser
	a = &v // a *Vertex implements Abser

	// In the following line, v is a Vertex (not *Vertex)
	// and does NOT implement Abser.
	a = v

	// This results in an error b/c Vertex (the type) doesn't
	// implement Abser b/c Abs() is not defined for Vertex,
	// only *Vertex
	fmt.Println(a.Abs())
}

type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

type Vertex struct {
	X, Y float64
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}
```

The next several notes get into specific behavior about interfaces and type assertions that I skim through. I'll come back to them when I need these language constructs.

They do mention the ubiquitous `error` interface. It's very idiomatic to call a function, get return values, and handle errors by seeing if `error` is `nil` or not:
```go
i, err := strconv.Atoi("42")
if err != nil {
    fmt.Printf("couldn't convert number: %v\n", err)
    return
}
fmt.Println("Converted integer:", i)
```

Finally there are several lesson at the end, trying to show off the `Reader` and `Image` interfaces from the standard library. I can only assume this Tour was aimed at ***REAL PROGRAMMERZ*** and not scrubs like me because I had no idea what the related exercises were asking and had no interest in figuring it out. I figured the Tour was a gentle tutorial for beginners but it seems to assume prior programming experience. Whatever...

## General Generic
I remember seeing on the interwebs all the Go-hate because it didn't support "generics" and the subsequent rejoicing when it finally did. As someone who spent a lot of time with Python, I understand the power of not caring about what type you're working with, you just wanna *do the thing* with it. I'm glad I got into Go when I did.

Functions and Types can be generic. Special syntax and keywords are used to indicate genericity:
```go
package main

import "fmt"

// Index returns the index of x in s, or -1 if not found.
func Index[T comparable](s []T, x T) int {
	for i, v := range s {
		// v and x are type T, which has the comparable
		// constraint, so we can use == here.
		if v == x {
			return i
		}
	}
	return -1
}

// List represents a singly-linked list that holds
// values of any type.
type List[T any] struct {
	next *List[T]
	val  T
}

func main() {
	// Index works on a slice of ints
	si := []int{10, 20, 15, -10}
	fmt.Println(Index(si, 15))

	// Index also works on a slice of strings
	ss := []string{"foo", "bar", "baz"}
	fmt.Println(Index(ss, "hello"))
}
```

## Con Concurrency
This is where Go stands out. **Goroutines** are a lightweight thread managed by the Go runtime and there is the special `go` keyword for running them:
```go
package main

import (
	"fmt"
	"time"
)

func say(s string) {
	for i := 0; i < 5; i++ {
		time.Sleep(1000 * time.Millisecond)
		fmt.Println(s)
	}
}

func main() {
	go say("world")
	say("hello")
}
```
```console
$ run main.go
hello
world
world
hello
hello
world
world
hello
hello
```

**Channels** are a special conduit to send and receive values. Like maps and slices, they must be created before they can be used. `make()` does that too. Reading and writing values to a channel has it's own operator `<-`. These have properties that allow goroutines to synchronize without locking. This is another language feature I need to use before understanding fully:
```go
package main

import "fmt"

func sum(s []int, c chan int) {
	sum := 0
	for _, v := range s {
		sum += v
	}
	c <- sum // send sum to c
}

func main() {
	s := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int)
	go sum(s[:len(s)/2], c)
	go sum(s[len(s)/2:], c)
	x, y := <-c, <-c // receive from c

	fmt.Println(x, y, x+y)
}
```
```console
$ run main.go
-5 17 12
```
Channels can be closed with the `close()` function. No more values can be sent to a closed channel. It's idiomatic to use `range` to iterate over channel values until it's closed.

There's a `select` keyword that allows a goroutine to wait for some condition before operating. It uses the `case` keyword and looks like a switch statement:
```go
func main() {
	tick := time.Tick(100 * time.Millisecond)
	boom := time.After(500 * time.Millisecond)
	for {
		select {
		case <-tick:
			fmt.Println("tick.")
		case <-boom:
			fmt.Println("BOOM!")
			return
		default:
			fmt.Println("    .")
			time.Sleep(50 * time.Millisecond)
		}
	}
}
```
```console
$ run main.go
    .
    .
tick.
    .
    .
tick.
    .
    .
tick.
    .
    .
tick.
    .
    .
BOOM!
```

## Next Steps
And that's essentially the end of the Tour of Go! Overall, Go looks to be an interesting, modern language with some cool constructs built-in. And I haven't even seen the stuff that brought me to it: the build/deploy/management of Go binaries. I'm slightly disheartened by my struggles at certain points in the tutorial but more practice with the language should fix that.

Armed with a thorough introduction to language syntax and design, actually writing code is the next move.
