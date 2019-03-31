
// Task 1
// sbt clean compile run 
// b) Generate an array containing the values 1 up to (and including) 50 using
//    a for loop.

//(c) Unlike Haskell where only immutable data structures are allowed, in Scala,
//  we may use both. Array is one such mutable data structure. Append to
//  the previous array the values 51 to 100 (inclusive) using a Range. (Hint:
//  Use 51 to 100 (evaluates to a Range), the map method, and a lambda
//  (anonymous function))

// (d) Create a function that sums the elements in an array of integers using a
//     for loop.

// (e) Create a function that sums the elements in an array of integers using
//     recursion.

// (f) Create a function to compute the nth Fibonacci number using recursion,
// without using memoization (or other optimizations). Use BigInt instead
// of Int. What is the difference?

object Hello extends App {
    // b
    var upToFifty: Array[Int] = Array()
    for (a <- 1 to 50) {
        upToFifty :+= a
    }
    // c
    for (a <- 51 to 100) {
        upToFifty :+= a
    }
    // (51 to 100).map((x:Int) => upToFifty :+=x)
    // for (i <- upToFifty) println(i)

    // d
     def sumOfList( sum_array:Array[Int] ) : Int = {
         var sum:Int = 0
         for (a <- sum_array) {
             sum += a 
         }
      return sum
   }
   println(sumOfList(upToFifty))
    // e
   def sumOfListRecursion( sum_array:Array[Int] ): Int =
        sum_array match {
           case Array() => 0
           case arr => arr.head + sumOfListRecursion(arr.tail)
       }
    println(sumOfListRecursion(upToFifty))
    // f
    def fibonacci( n:Int ): BigInt = 
        n match {
            case 1 => 1
            case 2 => 1
            case num => fibonacci(n-2) + fibonacci(n-1)
        }
    println(fibonacci(7))
    // Using BigInt let the user work with very large numbers. 


    // Task 2: Lazy Evaluation
    // 
    // a) What are its arguments and what does it do? What is t, and what is so
    //  special about it?

    def my_func(f: () => BigInt, b: Boolean) = {
        lazy val t = f()
        if (b) println (t)
    }

    // f: () => BigInt  : Takes a function that recieves no arguments and returns a BigInt as argument1. 
    // b: Boolean       : Takes a Boolean value (True/False) as argument2.
    // my_func          : Prints the output from argument1 (BigInt) if the Boolean value from argument2 is True. 
    // t:               : Lazy val which means that it is executed when it is accessed the 
    //                    first time, which here is when it is being printed. If the boolean value from argument2
    //                    is False, then the function f will never run because it is Lazy. 


    // (b) Create a function with the same operations as in a), but use val instead
    // of lazy val. Explain their differences.
    def my_func2(f: () => BigInt, b: Boolean) = {
        val t = f()
        if (b) println (t)
    }

    // Differences: In my_func2 the function f is being executed when val t is defined. Which means that 
    // f will be executed independently of the boolean value b. 

    // (c) When do you think it is helpful to use lazy evaluation?
    // It is helpful if you are working with infinite numbers/lists and don't know if you need all numbers. 
    // Also if you are defining something that you are not sure will be used. Like the function my_func. 



    // Task 3: Concurrency in Scala
    // 
    // (a) Create a function that takes as argument a function and returns a Thread
    // initialized with the input function. Make sure that the returned thread is
    // not started.
    // Last statement within a block will be returned.
    def thread_func( f: () => Any ): Thread = {
        new Thread { override def run() = f() }
    }

    // (b) Create a recursive function that creates n lambdas. Each lambda prints its
    // corresponding nth Fibonacci number. (This means you return an Array
    // of functions, the return type being Array[ () => Unit ])
    def recursive_fib_array_func(n:Int): Array[() => Unit] =
        n match {
            case 0 => Array()
            case num => (() => println(fibonacci(n))) +: recursive_fib_array_func(n-1)
        }

    // (c) Use the result from your lambda generator in b) and thread generator
    // from a) and map each lambda to a thread. (Hint: Use the map method
    // on the Array with the argument being the function you made in a).
    def map_lambda_thread(n:Int): Array[Thread] = {
        val lambda_array = recursive_fib_array_func(n)
        lambda_array.map(lambda => thread_func(lambda))
    }
    // OBS - litt usikker på om dette er riktig! 

    // (d) Map each thread from c) to start. What does this do and what kind of
    //    Array does this return?


    // (e) The code snippet below is not thread-safe. Why is this so and how would
    //  you change it so that it is thread-safe? Hint: atomicity.
    //
    // Avoid using "var" as a shared mutable state. Because if you have a shared state 
    // expressed as vars, you'd better synchronize it (it gets ugly fast). It's better to avoid it.
    // In case we need mutable shared state, we can use an atomic reference and store 
    // immutable things in it instead.
    //import org.sincron.atomic._
    import java.util.concurrent.atomic._

    private val counter = new AtomicReference(0)
    //def increaseCounter(): Int = {
   
    //}

    // (f) One problem you will often meet in concurrency programming is deadlock.
    // What is deadlock, and what can be done to prevent it? Write in Scala an
    // example of a deadlock using lazy val.
    //
    // A deadlock is a state where two, or more,  threads are blocked waiting for the other blocked waiting thread
    // (or threads) to finish and thus none of the threads will ever complete.
    // Threads use resources such as objects, and these tesources may require that only one thread access them at a
    // given point in time, otherwise we may get unexpected results. 
    //
    // Ways to avoid deadlock:
    // - Lock ordering
    // - Open calls
    // - Acquire multiple locks in an atomic action
    //    + if it fails, then any acquired locks must be released
    //    + Try again possible after a delay
    //    + Can use polling or timeout to acquire locks 
    // 
    // To avoid these, it’s recommended to use a privately held object as a 
    // lock to prevent accidental sharing or escapement of locks.

        // syncronized: monitor. (låser)
        // atomic integer: sjekker hva den tror verdien er og hva den faktisk er. 
        // lazy val bruker syncronized 

    
}

