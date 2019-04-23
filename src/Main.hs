module Main where

import qualified Control.Monad.State as S
import Text.Read

type Set = [Int]

data Status = PlayerTurn | ComputerTurn | PlayerWin | ComputerWin
    deriving (Eq, Show)

data Game = Game Set Status deriving (Eq, Show)

type Row = Int
type Pick = Int
data Move = Move Row Pick deriving (Eq)

setString :: Set -> Int -> String
setString [] _ = "" 
setString (p:ps) n = "\n" ++ (show n) ++ ". " ++ (take p $ repeat '|') ++ (setString ps (n+1))

printGame :: Game -> IO()
printGame (Game set status) = do
    putStrLn $ setString set 0


win :: Set -> Bool
win set = sum set == 1

next :: Move -> S.State Game ()
next (Move row pick) = S.state $ \ (Game set status) ->
    let set' = (take (row) set) ++ [(set !! row) - pick] ++ (drop (row + 1) set)
        status'
            | status == PlayerTurn && (win set') = PlayerWin
            | status == ComputerTurn && (win set') = ComputerWin 
            | status == PlayerTurn = ComputerTurn
            | status == ComputerTurn = PlayerTurn 
     in ((), Game set' status')

makeMove :: IO Move
makeMove = return $ Move 0 1

readMove :: IO Move
readMove = do
    putStr "row: "
    rowStr <- getLine 
    let rowMaybe = readMaybe rowStr :: Maybe Row
    putStr "pick: "
    pickStr <- getLine 
    let pickMaybe = readMaybe pickStr :: Maybe Pick
    case (rowMaybe, pickMaybe) of 
      (Just row, Just pick) -> return $ Move row pick
      otherwise             -> do
          putStrLn "Wrong entry"
          readMove

validMove :: Move -> S.State Game Bool
validMove (Move row pick) = S.state $ \(Game set status) ->
    let isValid = 
            row >= 0 &&
            pick > 0 &&
            row < length set &&
            set !! row > 0 &&
            (set !! row) >= pick
     in (isValid, Game set status)


play :: Game -> IO()
play (Game _ PlayerWin) = putStrLn "You won! Congrats!"
play (Game _ ComputerWin) = putStrLn "You lost... sorry."
play game@(Game set status) = do
    printGame game
    move <- do
        let checkMove = do
            m <- readMove
            if S.evalState (validMove m) game
                then return m
                else do
                    putStrLn ("No good")
                    checkMove
        checkMove
    play $ S.execState (next move) game

set = [7, 5, 3, 1]
game = Game set PlayerTurn


main :: IO ()
main = play game
