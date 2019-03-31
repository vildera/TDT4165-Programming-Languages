module Lib
    ( f0
    , f1
    , f2
    , take
    , map
    , iterate
    , filterPos
    , filterPosMany
    , flip3
    , Maybe(..)
    , safeHeadList
    , safeHead
    ) where

import Prelude hiding (map, take, iterate, sqrt, Maybe)

-- TASK 1
-- Parametric polymorphism

-- Below are three type signatures. Can you implement them? We
-- say a function or implementation /inhabits/ it's type
-- (signature). How many other inhabitants do these types
-- have? What if we fixed a = Int, does that change your
-- previous answer?
f0 :: a -> a
f0 a = a

f1 :: a -> b -> a
f1 a _ = a

f2 :: a -> b -> b
f2 _ b = b


-- Rewrite the function "takeInt" from exercice 1 as "take" so
-- that it accepts a list of any type. If you used the
-- built-in function "take" on the last assignment, write your
-- own implementation this time. Be sure to include a type
-- signature. (Hint: If you already wrote takeInt, you won't
-- have to change much.)

-- This function takes an Int, the number of elements to take
-- and a list it should draw the elements from. It then uses 
-- recursion and pattern matching.

-- same as takeInt just that the types are not defined 
take :: Int -> [a] -> [a]

-- checks if n is negative or 0 --> then return an empty list
take n _
    | n <= 0         = []

-- checks if n is equal to or larger than the length of the list 
-- --> then returns the whole list
--    | n >= length _ = _

-- returns an empty list if the input list is empty
take _ [] = []

-- main case (same as takeInt). Using pattern matching where I 
--take the head and use recursion on the tail which eventually 
-- will return the first n elements of the list.
take n (x:xs) = [x] ++ take (n-1) xs



-- The function head :: [a] -> a which returns the first
-- element of a list, is /partial/, meaning it will crash for
-- some inputs. (Which?) --> tom liste (uten head)

-- One solution could be to make a
-- /total/ function "safeHeadList :: [a] -> [a]" which either
-- gives the head, or nothing. Can you implement it using take?
safeHeadList :: [a] -> [a]
safeHeadList list = take 1 list

-- The output of safeHeadList is either empty or a singleton,
-- and thus using a list as output-type is a bit misleading. A
-- better choice is Maybe (sometimes called Optional):
-- data betyr at vi definerer en ny datatype. a (under) er tupen vi definerer (som da er en typevariabel)
-- | leses som 'eller'. Slik at a kan ha datatype a eller None 
-- deriving (Eq, Show) sier bare at Maybe a skal  arve typene Eq og Show 

data Maybe a = Some a | None deriving (Eq, Show)

-- Implement 'safeHead', representing failure using None.
safeHead :: [a] -> Maybe a
safeHead list = case take 1 list of 
                [] -> None
                [x] -> Some x



-- TASK 2
-- Higher order functions

-- Task 2.2
--  map takes a function from any type a to any type b and a list of type a.
-- It iterates through the list and applies the function to all of the elements in the list 
-- and returns a list of type b 
-- Using list comperhension
map :: (a -> b) -> [a] -> [b]
map func list = [func x | x <- list ]

-- Tast 2.3 
-- iterate produces an infinite list by repeatebly applying a function f:: a->a to a value
-- the result should look something like this: iterate = [n, f(n), f(fn), f(f(fn))..]
-- Using recursion to generate an infinite list 
iterate :: (a -> a) -> a -> [a]
iterate function value = value : iterate function (function value)




-- TASK 3
-- Currying and partial application

-- complete the function filterPos
-- that takes a list and returns 
-- a filtered list containing only positive
-- integers (including zero)
-- use partial application to achieve this
filterPos :: [Int] -> [Int]
filterPos = filter(>=0 ) -- Tar inn lambdafunksjon istedenfor å måtte definere funksjonen til en identifikator

-- complete the function filterPosMany
-- that takes a list of lists and returns
-- a list of lists with only positive
-- integers (including zero)
-- hint: use filterPos and map
filterPosMany :: [[Int]] -> [[Int]]
filterPosMany list = map filterPos list

flip3 :: (a -> b -> c -> d) -> c -> b -> a -> d
flip3 function a b c = function c b a





-- TASK 4
-- Infinite lists
infApprox :: Double -> Double -> [Double]
infApprox x guess = iterate (\x0 -> x0 - (((x0*x0) - x)/(2*x0))) guess

isDouble :: Double -> Bool
isDouble d = (fromIntegral . truncate) d /= d -- fjernet desimaler, delte på seg selv og sjekker om det fortsatt det samme. Er double hvis de ikke er like

approx :: Double -> [Double] -> Double
approx threshold (x:y:xs) = if (x - y) < threshold then y else approx threshold (y:xs)

isPerfSq :: Double -> Bool
isPerfSq x = not $ isDouble $ approx 0.00000001 (infApprox x x)



--uncomment when isPerfSqr is defined
accuracy :: Int -> Bool
accuracy x = take x generated == take x [x^2 | x <- [1..]]
                where
             zpd       = zip [1..] (map isPerfSq [1..])
             f (x,y)   = y == True
             generated = fst . unzip $ filter f zpd


{-
THEORY

1) 
A null in Java is used to represent nothing, and has no value. Any variable of
any type can be null. Haskell, Nothing acutally is a value.

returnere nothing i Haskell / null i java
 Kan returnere null uansett hvilken returtype du har / tilhører alle typer( mens nothing i Haskell er av typen Maybe / må defineres )
Eksempel - Maybe int er ikke det samme som int 

2) 
$ is an operator, and thus function, that makes function calls right associative 
instead of left associative. Ie
func1 func2 func3 1 is equivalent to (((func1 func2) func3) 1) 
while
func1 $ func2 $ func3 1 is eqivalent to (func1 (func2 (func3 1)))
Alt på høyresiden blir evaluert først. 

3) 
. is function composition, so that (f . g) 1 is the same as f(g(1))

Summary, . is composition, $ is right-association

4)
The code snippet generates the first, second, third, etc fibonachi number, and then prints it
When run with an infinite list in haskell, the results get printed as they become available
while the python code completes all the calculations before printing the list. This is due 
to the lazy evaluation in haskell. The same could have easily been acheved by using generators 
in python.

Vil generere 50 av gangen og evaluere disse 

5)
In any case where computing all the results at once can be too expencive, 
or even impossible.

6) 
The type of (,) is a -> b -> (a, b) m which means it is a function/operator that takes
two arguments and returns a touble of those arguments. 

7) 
Creating a curried function in python is simple
def functionOne(a):
    def functionTwo(b):
        def functionThree(c):
            return a + b + c
        return functionThree
    return functionTwo
functionOne(a)(b)(c)

8) Kan utelate noen argumenter og det fortsatt vil fungere (samme som filterpos )

-}

