module Lib
    ( Token(..)
    , Op(..)
    , takeWhile
    , dropWhile
    , break
    , splitOn
    , lex
    , tokenize
    , interpret
    , shunt
    ) where

import Prelude hiding (lex, dropWhile, takeWhile, break)
import Data.Char (isDigit)
import Text.Read hiding (lex)

takeWhile, dropWhile :: (a -> Bool) -> [a] -> [a]


takeWhile _ [] = []
takeWhile pred (x:xs)
        | pred x    = x : takeWhile pred xs
        | otherwise = []

dropWhile _ [] = []
dropWhile pred list@(x:xs)
        | pred x    =  dropWhile pred xs
        | otherwise = list 


-- solution from implementation of actual break
break :: (a -> Bool) -> [a] -> ([a], [a])
break _ [] = ([],[])
break pred list@(x:xs)
    | pred x     =([] , list)
    | otherwise  = let (ys,zs) =  break pred xs  in (x:ys, zs)


-- null function returns True if a list is empty
-- removing list if empty 
-- filter arg1 er funksjon, arg2 er en liste
splitOn :: Eq a => a -> [a] -> [[a]]
splitOn a lst = filter (not . null ) (helper a lst)
    where 
        helper a [] = []
        helper a lst =  let (xs, ys) = break (==a) $ dropWhile (==a) lst in  xs : (helper a ys)
            

data Token = TokOp Op
           | TokInt Int
           | TokErr
           deriving (Eq, Show)

data Op = Plus
        | Minus
        | Div
        | Mult
        | Dup
        |AddInv
        deriving (Show, Eq)

lex :: String -> [String]
lex = splitOn ' ' 

tokenize :: [String] -> [Token]
tokenize list = [ makeToken x | x <- list ]

makeToken :: String -> Token 
makeToken str 
        | isInt(str) = TokInt ( read str :: Int )
        | str == "+"    = TokOp Plus 
        | str == "-"    = TokOp Minus
        | str == "/"    = TokOp Div
        | str == "*"    = TokOp Mult 
        | str == "#"    = TokOp Dup
        | str == "--"   = TokOp AddInv
        | otherwise     = TokErr




isInt :: String -> Bool
isInt str = case readMaybe str :: Maybe Int of
                 Nothing  -> False
                 Just _ -> True 

-- foldl: takes the second argument and the first item of the list and applies the function to them
-- then feeds the function with this result and the second argument and so on          

-- Thinking f the problem as a stack (RPN calculator)
-- Using pattern matching to get top items of a stack and to do pattern matching against operators. 
interpret :: [Token] -> [Token]
interpret list = foldl fop [] list 
        where 
              fop ((TokInt x) : (TokInt y) : ys) (TokOp Plus)   = (TokInt ( y + x )) : ys
              fop ((TokInt x) : (TokInt y) : ys) (TokOp Minus)  = (TokInt ( y - x )) : ys
              -- Using div operator because it returns integer and not doubl:
              fop ((TokInt x) : (TokInt y) : ys) (TokOp Div)    = (TokInt ( div y x )) : ys
              fop ((TokInt x) : (TokInt y) : ys) (TokOp Mult)   = (TokInt ( y * x )) : ys
              fop xs                       number@(TokInt n)    =  number : xs -- hvis det er et tall, legg det til i stacken
              fop _ _                                           = [TokErr]

 
-- Added operators ( add types for # and – which duplicates an element and takes the assitive inverse of a sumber)
-- 2. Using Shunting-Yard algoritm to convert infix notation to postfix notation

-- 2.1Implement a function that checks if one operator has a higher precedence than another.
-- Defining operator precedence
-- Spørsmål:  Hvordan bestemmer vi egentlig prioritet? 
opPrec ::Token -> Int 
opPrec (TokOp operator) = case operator of 
                        Plus -> 2
                        Minus -> 2
                        Mult -> 1
                        Div -> 1
                        Dup -> 0
                        AddInv -> 0

opLeq :: Token -> Token -> Bool
opLeq op1 op2 = opPrec op1 > opPrec op2

shunt :: [Token] -> [Token]
shunt tokens = shuntInternal tokens [] []

-- input stack -> output stack -> operator stack 
-- input stack, output stack, operator stack
shuntInternal :: [Token] -> [Token] -> [Token] -> [Token]
shuntInternal [] outstack opstack             = (reverse outstack) ++ opstack

-- forklar dette:
shuntInternal (t@(TokInt _):inp) out oper     = shuntInternal inp (t:out) oper
shuntInternal (t@(TokOp _):inp) out []        = shuntInternal inp out [t]
-- dersom du henter fra operatorstacken skal du velge den med høyest presendens 
shuntInternal inp@(t1:inps) out oper@(t2:opers)
        | opLeq t1 t2                         = shuntInternal inp (t2:out) opers 
        | otherwise                           = shuntInternal inps out (t1:oper)



