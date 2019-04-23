module Main where

import qualified Control.Monad.State as S

type Set = [Int]

data Status = PlayerTurn | ComputerTurn | PlayerWin | ComputerWin
    deriving (Eq, Show)

data Game = Game Set Status

type Row = Int
type Pick = Int
data Move = Move Row Pick

setString :: Set -> Int -> String
setString [] _ = "" 
setString (p:ps) n = "\n" ++ (show n) ++ ". " ++ (take p $ repeat '|') ++ (setString ps (n+1))

printGame :: Game -> IO()
printGame (Game set status) = do
    putStrLn $ setString set 0

next :: Move -> S.State Game ()
next = undefined

makeMove :: IO Move
makeMove = undefined

readMove :: IO Move
readMove = undefined

play :: Game -> IO()
play (Game _ PlayerWin) = putStrLn "You won! Congrats!"
play (Game _ ComputerWin) = putStrLn "You lost... sorry."
play game@(Game set status) = do
    printGame game
    move <- if (status == PlayerTurn)
               then readMove
               else makeMove
    play (S.execState (next move) game)

set = [7, 5, 3, 1]
game = Game set PlayerTurn


main :: IO ()
main = do
  putStrLn "hello world"
