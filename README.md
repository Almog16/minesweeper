Minesweeper (in Haskell)
======
Description:
------
A functional approach to the Minesweeper game with Haskell.

This implementation was done from scratch, with strong emphasis on functional programming principles such as:
* Recursion
* Pattern Matching
* Higher-Order Functions
* Partial Application & Currying
* Anonymous Functions
* List Comprehension
* Immutability

    
 How to use:
------
     1. The game is run from the command-line with the following arguments:
        1. width and height (integer numbers in the range 10 - 20)
        2. mine-count (integer number in the range 4 - 199)
        * example of running the game with a 10x10 board and 16 mines:
            stack run 10 10 16
            
    Here is an example of an initial state of a game with the size board of 10x10:
            001 002 003 004 005 006 007 008 009 010
        001 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        002 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        003 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        004 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        005 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        006 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        007 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        008 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        009 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        010 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        
    At this point the program waits for input from the player. The player can choose between two possible actions:
        1. Dig x y - this is similar to a player left-click in the GUI version of the game.
        2. Flag x y - this is similar to a player right-click in the GUI version.
        
    e.g. the following state is displayed after a Dig 5 5 and Flag 9 8 actions:
            001 002 003 004 005 006 007 008 009 010 011 012 013
        001 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        002 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        003 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        004 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        005 [ ] [ ] [ ] [ ] [2] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        006 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        007 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        008 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [!] [ ] [ ] [ ] [ ]
        009 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        010 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        011 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        012 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
        013 [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
  
  Rules & Notes:
  -----
1. If you flag a location that is already dug nothing happens.
2. If you dig in a location that has a flag, nothing happens.
3. You CAN flag a location that already has a flag in it. The program will interprent this as an un-flag action.
4. The Flag x y action serves as a toggle, it will either flag or un-flag based on the state of the game.
5. It is allowed to put more flags than the known mine count.
6. Note that a game cannot be won with more flags than mines.