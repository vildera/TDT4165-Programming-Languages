module Tree
    (Tree(..)
    ) where

-- TASK 3.2
-- Binary Trees

{-Num Complex is implemented
  adds, multiplies and subtracts Complex numbers FAILED [1]
  computes the sign of a Complex number FAILED [2]
  computes the absolute value of a Complex number FAILED [3]
  converts integers to complex numbers FAILED [4]

foldable instance of Tree
  can be summed FAILED [5]
  -}

data Tree a = Branch (Tree a) a (Tree a) | Leaf a
  deriving (Eq, Show)

-- The Foldable instance might prove tricky to define, so
-- defining the specific functions first may be easier!
treeSum :: (Num a) => Tree a -> a
treeSum (Leaf a) = a
treeSum (Branch left a right) =  (treeSum left) + (treeSum right) + a


treeConcat :: Tree String -> String
treeConcat (Leaf a) = a
treeConcat (Branch left a right) = (treeConcat left) ++ (treeConcat right) ++ a

treeMaximum :: (Ord a) => Tree a -> a
treeMaximum (Branch _ x right) = treeMaximum right 

-- Write a Foldable instance for Tree.
instance Foldable Tree where
  foldr op acc (Leaf a) = a `op` acc
  foldr op acc (Branch left a right) = foldr op (a `op`  (foldr op acc right)) left
