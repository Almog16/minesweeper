{-# OPTIONS -Wall #-}

module Main where

import System.Random
import System.Environment
import MineSweeper


readAction :: BoardCells -> Int -> Int -> IO Action
readAction board width height = do
  inputStr <- getLine
  let actStr = words inputStr
      actionOut =
        if validateAction inputStr width height
          then do
            let x = readArgs (actStr !! 1)
                y = readArgs (actStr !! 2)
                action =
                  if actStr !! 0 == "Dig"
                    then Dig x y
                    else Flag x y
            return action
          else do
            putStrLn "Invalid input, please try again."
            readAction board width height
  actionOut

gameStep :: BoardCells -> BoardCells -> Int -> Int -> [Coordinate] -> IO BoardCells
gameStep playerBoard mineBoard width height mineList = do
  printBoardString (createStringFromBoard playerBoard 1) width
  putStrLn "What's your next move?"
  action <- readAction playerBoard width height
  let currentBoard = act action playerBoard mineBoard width height
      board =
          if isGameOn currentBoard (row action, col action) mineList action
            then gameStep currentBoard mineBoard width height mineList
            else return currentBoard
  board

printBoardStringAux :: [String] -> IO ()
printBoardStringAux [] = return ()
printBoardStringAux (x:xs) = do
 putStrLn x
 printBoardStringAux xs

printBoardString :: [String] -> Int -> IO ()
printBoardString boardStr width = do
  if head boardStr == "you win! all mines cleared"
    then return ()
    else putStrLn (createFirstLine width)
  printBoardStringAux boardStr


main :: IO ()
main = do
  args <- getArgs
  if length args == 3 &&
     validateArgs args &&
     validateDimensions (rInt (args !! 0)) && validateDimensions (rInt (args !! 1)) && validateMineNum (rInt (args !! 2)) (rInt (args !! 0)) (rInt (args !! 1))
    then do
      gen <- getStdGen
      let intArgs = map rInt args
          width = intArgs !! 0
          height = intArgs !! 1
          mines = intArgs !! 2
          playerBoard = initBoard width height
          boardCoordList = initBoardCoords width height
          mineList = randomCoords (width * height) mines boardCoordList gen
          mineBoard = generateMines mineList width height playerBoard
          mineCoordList = createCoordList mineList
      playerBoardAfterGame <- gameStep playerBoard mineBoard width height mineCoordList
      let gameOverBoard = gameOver playerBoardAfterGame mineCoordList
      printBoardString gameOverBoard width
    else putStrLn "Invalid input! Exiting program"