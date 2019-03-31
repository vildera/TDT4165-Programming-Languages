module Lib
    ( listSum
    , listProduct
    , listConcat
    , listMaximum
    , listMinimum
    , sum
    , concat
    , length
    , elem
    , safeMaximum
    , safeMinimum
    , any
    , all
    , foldr
    , Complex(..)
    ) where

import Prelude hiding (foldr, maximum, minimum, any, all, length
                      , concat, sum, product, elem, Foldable(..))

-- TASK 2
-- Bounded parametric polymorphism

-- Implement the following functions that reduce a list to a single
-- value (or Maybe a single value).

-- Maybe is imported from Prelude and is defined like this:
-- data Maybe a = Just a | Nothing

listSum :: (Num a) => [a] -> a
listSum [] = 0 
listSum (x:xs) = x + listSum xs 


listProduct :: (Num a) => [a] -> a
listProduct [] = 1
listProduct (x:xs) = x * listProduct xs

listConcat :: [[a]] -> [a]
listConcat [] = []
listConcat (x:xs) = x ++ listConcat xs



listMaximum :: (Ord a) => [a] -> Maybe a
listMaximum []       = Nothing  
listMaximum [x]      = Just x
listMaximum (x:y:xs) = listMaximum((if x >= y then x else y):xs)


listMinimum :: (Ord a) => [a] -> Maybe a
listMinimum []       = Nothing 
listMinimum [x]      = Just x
listMinimum (x:y:xs) = listMinimum((if x<=y then x else y):xs)



-- TASK 3 Folds

-- TASK 3.1
-- Below our Foldable class is defined. Now define a list instance of
-- Foldable, and then define the Foldable versions of the functions
-- you defined previously (and some more).
class Foldable t where
  foldr :: (a -> b -> b) -> b -> t a -> b

instance Foldable [] where
  foldr op acc []     = acc
  foldr op acc (x:xs) = op x (foldr op acc xs)
  
 

--
-- USE FOLDR TO DEFINE THESE FUNCTIONS
--
sum :: (Num a, Foldable t) => t a -> a
sum = foldr (+) 0 

concat :: Foldable t => t [a] -> [a]
concat  = foldr (++) []

{- foldr itererer gjennom listen (det har vi sett over i definisjonen av foldr. 
Dermed gir setter vi operator til et lambdauttrykk som legger til 1 (+1) for hvert element
 (som er _ siden det ikke skal brukes) i listen. Ikke nødvendig og ta listen som input 
 fordi det er point free --> Den forstår det selv ettersom at det ville vært eneste input-}
length :: Foldable t => t a -> Int
length  = foldr (\_ acc -> acc +1 ) 0 

elem :: (Eq a, Foldable t) => a -> t a -> Bool
-- er dette elementet vi er ute etter, eller har vi det fra før
elem element  = foldr (\x a -> (x == element) || a) False 

-- (Just y) pakker ut y fra "Just" slik at vi kan sammenligne de to typene. 
safeMaximum :: (Foldable t, Ord a) => t a -> Maybe a
safeMaximum = foldr op Nothing 
                        where 
                            op x Nothing = Just x
                            op x (Just y) = (if x>=y then Just x else Just y)

safeMinimum :: (Foldable t, Ord a) => t a -> Maybe a
safeMinimum = foldr op Nothing 
                        where 
                            op x Nothing = Just x
                            op x (Just y) = (if x<=y then Just x else Just y)

-- The functions "any" and "all" check if any or all elements of a
-- Foldable satisfy the given predicate.
--
-- USE FOLDR
--
-- Using same structure as in elem 
any :: Foldable t => (a -> Bool) -> t a -> Bool
any predicate = foldr (\x a -> (predicate x) || a) False 

all :: Foldable t => (a -> Bool) -> t a -> Bool
all predicate = foldr (\x a -> (predicate x) && a) True



-- TASK 4
-- Num Complex
 
data Complex = Complex Double Double deriving (Eq) 
 
instance Show Complex where 
    show (Complex r i) 
        | i >= 0 = show r ++ "+" ++ show i ++ "i" 
        | otherwise = show r ++ "-" ++ show (abs i) ++ "i" 

instance Num Complex where 
    (+) (Complex a b) (Complex c d) = Complex (a + c) (b + d)
    (*) (Complex a b)(Complex c d) = Complex (a*c - b*d) (a*d + b*c)
    abs (Complex a b) = Complex (sqrt ((a**2) + (b**2))) 0
    signum (Complex a b) = let 
        length = sqrt ((a**2) + (b**2))
        in Complex (a/length) (b/length)
    fromInteger n = Complex (fromInteger n) 0 -- spm: hvorfor skriver vi fromInteger n etter = ? 
    negate (Complex a b) = Complex (-a) (-b)
    (-) (Complex a b) (Complex c d) = Complex (a-c) (b-d)

{--
-- TASK 5
-- Making your own type classes
-- Create a type class Move that is a subclass of Pos. A movable type should be
-- able to be moved and has a position where it belongs.
type Position = (Double, Double)

class Pos a where
    pos :: a -> Position

class (Pos a) => Move a where
    move :: a -> Position -> a
    home :: a -> Position 

data Campus = Kalvskinnet
            | Gløshaugen
            | Tyholt
            | Moholt
            | Dragvoll
            deriving (Show, Eq)

instance Pos Campus where
    pos Kalvskinnet = (63.429, 10.388)
    pos Gløshaugen  = (63.416, 10.403)
    pos Tyholt      = (63.423, 10.435)
    pos Moholt      = (63.413, 10.434)
    pos Dragvoll    = (63.409, 10.471)

-- 5.3
data Car = Car { currentPos :: Position, originalPos :: Position, keys :: Key deriving(Eq, Move, Pos)
-- 5.4
data Key = Key { curKeyPos :: Position, orgKeyPos :: Position deriving(Eq, Move)}
-- 5.5
free :: Move a => a -> Bool
free object = pos object == home object 
-- 5.6
carAvailable :: Car -> Bool 
carAvailable car = car currentPos == car originalPos 
--}