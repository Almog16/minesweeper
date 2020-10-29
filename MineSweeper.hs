{-# OPTIONS -Wall #-}

module MineSweeper where
import System.Random
import Data.List
import Data.Char
import Safe
import Data.Maybe (fromMaybe)

data Action = Dig {row :: Int, col :: Int}
            | Flag{row :: Int, col :: Int}
            deriving (Read)

type Coordinate = (Int, Int)

type BoardCells = [[(Coordinate, Char)]]

--Initalize a new, empty, board
initBoard :: Int -> Int -> BoardCells
initBoard x y
 | x == 1 = [initLine 1 y]
 | otherwise = initBoard (x-1) y ++ [initLine x y]

--Initalize a single line
initLine :: Int -> Int -> [(Coordinate, Char)]
initLine x y 
 | y == 1 = [((x,1), ' ')]
 | otherwise = initLine x (y-1) ++ [((x,y), ' ')]

-- initializes a list of all of the coordinates of the board
initBoardCoords :: Int -> Int -> [Coordinate]
initBoardCoords x y 
  | x == 1 = initCoordLine 1 y
  | otherwise = (initBoardCoords (x-1) y) ++ (initCoordLine x y)

initCoordLine :: Int -> Int -> [Coordinate]
initCoordLine x y
 | y == 1 = [(x,1)]
 | otherwise = initCoordLine x (y-1) ++ [(x,y)]

-- the following two functions generate random coordinates, which will be used to generate mines
randomCoord :: Int -> StdGen -> (Int, StdGen)
randomCoord size gen =
  let (randX, gen') = randomR (0, size-1) gen
  in (randX, gen')

-- in this function, we generate a random index, which represents a mine coordinate.
-- then we add that coordinate to a list of mine locations (the output list), and delete it from the input list 
randomCoords :: Int -> Int -> [Coordinate] -> StdGen -> [(Coordinate, StdGen)]
randomCoords size numOfMines coordList gen 
 | numOfMines == 0 = []
 | otherwise =
  let (a, gen') = randomCoord (size) gen -- index
  in [((coordList !! a), gen')] ++ randomCoords (size-1) (numOfMines-1) ((take (a) coordList) ++ (takeFromEnd (size-a-1) coordList)) gen'


createCoordList :: [(Coordinate, StdGen)] -> [Coordinate]
createCoordList [] = []
createCoordList ((coord,_):xs) = [coord] ++ createCoordList xs

--take n elements from the end of the list
takeFromEnd :: Int -> [a] -> [a]
takeFromEnd x ys = reverse (take x (reverse ys))

modifyBoard :: Int -> Int -> Int -> Int -> Char -> BoardCells -> BoardCells
modifyBoard x y w h c board = take (x-1) board ++ [take (y-1) (board !! (x-1)) ++ [((x,y),c)] ++ takeFromEnd (w-y) (board !! (x-1))] ++ takeFromEnd (h-x) board

generateMine :: (Coordinate, StdGen) -> Int -> Int -> BoardCells -> BoardCells
generateMine ((x,y), _ ) w h board = modifyBoard x y w h '*' board

generateMines :: [(Coordinate, StdGen)] -> Int -> Int -> BoardCells -> BoardCells
generateMines [] _ _ board = board
generateMines (x:xs) w h board = generateMines xs w h (generateMine x w h board)

isMine :: (Coordinate, Char) -> Int
isMine (_,c) 
 | c == '*' = 1
 | otherwise = 0

-- the following 3 functions' output is the surrounding cells of a given cell
getRelevantRows :: BoardCells -> Int -> Int -> Coordinate -> [[(Coordinate, Char)]]
getRelevantRows board _ _ (1,_) = [board !! 0] ++ [board !! 1]
getRelevantRows board _ h (x, _)
  | x == h = [board !! (x - 2)] ++ [board !! (x - 1)]
  | otherwise = [board !! (x - 2)] ++ [board !! (x - 1)] ++ [board !! x]

getRelevantCols :: BoardCells -> Int -> Int -> Coordinate -> [(Coordinate, Char)]
getRelevantCols [] _ _ _ = []
getRelevantCols (l:ls) w h (x,y)
  | y == 1 = take 2 l ++ getRelevantCols ls w h (x,y)
  | y == w = drop (y-2) l ++ getRelevantCols ls w h (x,y)
  | otherwise = drop (y-2) $ take (y+1) l ++ getRelevantCols ls w h (x,y)

getRelevantCells :: Coordinate -> Int -> Int -> BoardCells -> [(Coordinate, Char)]
getRelevantCells (x,y) w h board = getRelevantCols (getRelevantRows board w h (x,y)) w h (x,y)

countMinesAroundCoord :: Coordinate -> Int -> Int -> BoardCells -> Int
countMinesAroundCoord (x,y) w h board = countMinesAroundCoordAux (getRelevantCells (x,y) w h board)

countMinesAroundCoordAux :: [(Coordinate, Char)] -> Int
countMinesAroundCoordAux = foldr ((+) . isMine) 0

--the following two functions create a string, which will be used in order to print the board
createStringFromLine :: [(Coordinate, Char)] -> String
createStringFromLine [] = []
createStringFromLine ((_,c):xs) = "[" ++ [c] ++ "] " ++ createStringFromLine xs

createStringFromBoard :: BoardCells -> Int -> [String]
createStringFromBoard [] _ = []
createStringFromBoard (x:xs) rowNum
  | rowNum < 10 = ["00" ++ [intToDigit rowNum] ++ " " ++ createStringFromLine x] ++ createStringFromBoard xs (rowNum+1)
  | otherwise = ["0" ++ (show rowNum) ++ " " ++ createStringFromLine x] ++ createStringFromBoard xs (rowNum+1)

--create line of col numbers, which will be printed before printing the board
createFirstLine :: Int -> String
createFirstLine colNum
  | colNum == 1 = "    001"
  | colNum < 10 = createFirstLine (colNum-1) ++ " " ++ "00" ++ [intToDigit colNum]
  | otherwise = createFirstLine (colNum-1)  ++ " " ++ "0" ++ show colNum ++ " "

-- gets a string, which represents a number, and returns it as an Int
rInt :: String -> Int
rInt = read

symEq :: Eq a => (a,a) -> (a,a) -> Bool
symEq (x,y) (u,v) = (x == u && y == v) || (x == v && y == u)

removeDuplTuples :: Eq a => [(a,a)] -> [(a,a)]
removeDuplTuples = nubBy symEq

isFlag :: BoardCells -> Coordinate -> Bool
isFlag board (x,y) = ((board !! (x-1)) !! (y-1)) == ((x,y), '!')

isEmpty :: BoardCells -> Coordinate -> Bool
isEmpty board (x,y) = ((board !! (x-1)) !! (y-1)) == ((x,y), ' ')

flagAction :: BoardCells -> Coordinate -> Int -> Int -> BoardCells
flagAction board (x,y) width height
  | isFlag board (x,y) = modifyBoard x y width height ' ' board
  | isEmpty board (x,y) = modifyBoard x y width height '!' board
  | otherwise = board

digSurroundingCells :: [(Coordinate, Char)] -> Int -> Int -> BoardCells -> BoardCells -> BoardCells
digSurroundingCells [] _ _ playerBoard _ = playerBoard
digSurroundingCells (((x,y),c):xs) width height playerBoard mineBoard
  | c == '!' = digSurroundingCells xs width height playerBoard mineBoard
  | c /= ' ' = digSurroundingCells xs width height playerBoard mineBoard
  | mineNum == 0 = digSurroundingCells (xs ++ getRelevantCells (x,y) width height playerBoard) width height (modifyBoard x y width height (intToDigit mineNum) playerBoard) mineBoard
  | mineNum /= 0 = digSurroundingCells xs width height (modifyBoard x y width height (intToDigit mineNum) playerBoard) mineBoard
  where mineNum = countMinesAroundCoord (x,y) width height mineBoard
digSurroundingCells (((_, _), _):_) _ _ playerBoard _ = playerBoard --Just because we got a warning for missing this pattern

digActionGameBoard :: BoardCells -> BoardCells -> Coordinate -> Int -> Int -> BoardCells
digActionGameBoard playerBoard mineBoard (x, y) width height
  | isFlag playerBoard (x, y) = playerBoard
  | mineNum > 0 = modifyBoard x y width height (intToDigit mineNum) playerBoard
  | otherwise = digSurroundingCells (getRelevantCells (x, y) width height playerBoard) width height playerBoard mineBoard
  where mineNum = countMinesAroundCoord (x, y) width height mineBoard

act :: Action -> BoardCells -> BoardCells -> Int -> Int -> BoardCells
act (Dig x y) playerBoard mineBoard width height = digActionGameBoard playerBoard mineBoard (x,y) width height
act (Flag x y) playerBoard _ width height = flagAction playerBoard (x,y) width height

-- If there is an empty cell, and this cell doesn't contain a mine, returns false
-- Otherwise returns true
noSpacesInRow :: [(Coordinate, Char)] -> [Coordinate] -> Bool
noSpacesInRow [] _ = True
noSpacesInRow (((x,y), ' '):xs) mineList
  | tupleElem (x,y) mineList = noSpacesInRow xs mineList
  | otherwise = False
noSpacesInRow (((x,y), '!'):xs) mineList
   | tupleElem (x,y) mineList = noSpacesInRow xs mineList
   | otherwise = False
noSpacesInRow (_:xs) mineList = noSpacesInRow xs mineList

--Check if the player wins. Gets the player board and returns true or false
winGame :: BoardCells -> [Coordinate] -> Bool
winGame [] _ = True
winGame (x:xs) coordList = noSpacesInRow x coordList && winGame xs coordList

--Elem function for tuples
tupleElem :: Coordinate -> [Coordinate] -> Bool
tupleElem _ [] = False
tupleElem (x,y) ((z,w):xs)
  | x==z && y == w = True
  | otherwise = tupleElem (x,y) xs

--Check if the Player lost. The input is the game board
loseGame ::  Coordinate -> [Coordinate] -> Action -> Bool
loseGame (x,y) mineList (Dig _ _) = tupleElem (x,y) mineList
loseGame _ _ (Flag _ _) = False

--Check if the game is on
isGameOn :: BoardCells -> Coordinate -> [Coordinate] -> Action -> Bool
isGameOn playerBoard coord mineList action = not (loseGame coord mineList action || winGame playerBoard mineList)

-- When the game is over, this function generates the relevant string which will be printed for the user
gameOver :: BoardCells -> [Coordinate] -> [String]
gameOver playerBoard mineList
  | winGame playerBoard mineList = ["you win! all mines cleared"]
  | otherwise = createStringFromBoard (createLoseGameBoard playerBoard mineList) 1 ++ ["BOOM! game is over"]

--Modify the player's board so that is shows mines
createLoseGameBoard :: BoardCells -> [Coordinate] -> BoardCells
createLoseGameBoard playerBoard [] = playerBoard
createLoseGameBoard playerBoard ((x,y):xs) = createLoseGameBoard (modifyBoard x y (length (playerBoard !! 0)) (length playerBoard) '*' playerBoard) xs


--The following functions validate the user's input

isValidAction :: String -> Bool
isValidAction "Dig" = True
isValidAction "Flag" = True
isValidAction _ = False

readArgs :: String -> Int
readArgs x = fromMaybe (-1) (readMay x :: Maybe Int)

validateArgs :: [String] -> Bool
validateArgs = foldr (\x -> (&&) (readArgs x /= (-1))) True

validateActCoord :: Int -> Int -> String -> String -> Bool
validateActCoord width height x y
  | (rInt x <= height && rInt x >= 1) && (rInt y <= width && rInt y >= 1) = True
  | otherwise = False

validateDimensions :: Int -> Bool
validateDimensions x
  | x > 20 || x < 10 = False
  | otherwise = True

validateMineNum :: Int -> Int -> Int -> Bool
validateMineNum x width height
  | x > 199 || x < 4  || x > width * height - 1 = False --We assume the number of mines cannot be width * height, since in that case you win as soon as the game starts
  | otherwise = True

validateAction :: String -> Int -> Int -> Bool
validateAction action width height = length actStr == 3 && isValidAction (actStr !! 0) && validateArgs [(actStr !! 1) ++ (actStr !! 2)] && validateActCoord width height (actStr !! 1) (actStr !! 2)
  where actStr = words action
