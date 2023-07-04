import raylib
type
  TetrominoType = enum 
    None
    Square
    Line  
    ZLeft
    ZRight
    LLeft
    LRight
    Tt
  TetrominoPermutation = array[4, array[4, bool]]
  Tetromino            = array[4, TetrominoPermutation]
  TetrominoTable       = array[8, Tetromino]
  Rotation = range[0..3]

const
  boardCols = 10
  boardRows = 20

  windowTitle = "TETRIS"
  screenWidthPx = 800
  screenHeightPx = 800
  boardRect = 
    Rectangle(x: (screenWidthPx / 2) - (screenWidthPx / 5),
             y: (screenHeightPx / 2) - (screenWidthPx / 2.5),
         width: screenWidthPx / 2.5, 
        height: 2 * screenWidthPx / 2.5)

  cellWidthPx = boardRect.width / boardCols
  cellHeightPx = boardRect.height / boardRows

  previewRect =
    Rectangle(x: boardRect.x + boardRect.width + ((screenWidthPx - (boardRect.x + boardRect.width)) / 2) - (cell_width_px * 3),
              y: boardRect.y,
          width: cellWidthPx * 5, 
          height: cellHeightPx * 5)

  fps = 20
  showFps = true
  initialSpeed = 20
  initialLastBreath = 20
  colorSettings: array[TetrominoType.None..TetrominoType.Tt, Color] = [RayWhite, Yellow, Gold, Red, Green, SkyBlue, Orange, Purple]
  tetrominos: TetrominoTable = 
    [
      Tetromino [ # NULL
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [true,true,false,false]
        ]
      ],
      Tetromino [ # square
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [true,true,false,false]
        ]
      ],
      Tetromino [ # line
        TetrominoPermutation [
          [false,true,false,false],
          [false,true,false,false],
          [false,true,false,false],
          [false,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [false,false,false,false],
          [true,true,true,true]
        ],
        TetrominoPermutation [
          [false,true,false,false],
          [false,true,false,false],
          [false,true,false,false],
          [false,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [false,false,false,false],
          [true,true,true,true]
        ]
      ],
      Tetromino [ # zleft
         TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [false,true,true,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,true,false,false],
          [true,true,false,false],
          [true,false,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,false,false],
          [false,true,true,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,true,false,false],
          [true,true,false,false],
          [true,false,false,false]
        ]
      ],
      Tetromino [ # zright
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [false,true,true,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [true,false,false,false],
          [true,true,false,false],
          [false,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [false,true,true,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [true,false,false,false],
          [true,true,false,false],
          [false,true,false,false]
        ]
      ],
      Tetromino [ # lleft
        TetrominoPermutation [
          [false,false,false,false],
          [false,true,false,false],
          [false,true,false,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,true,false],
          [false,false,true,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [true,true,false,false],
          [true,false,false,false],
          [true,false,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,false,false,false],
          [true,true,true,false]
        ]
      ],
      Tetromino [ # lright
        TetrominoPermutation [
          [false,false,false,false],
          [true,false,false,false],
          [true,false,false,false],
          [true,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [false,false,true,false],
          [true,true,true,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [true,true,false,false],
          [false,true,false,false],
          [false,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,true,false],
          [true,false,false,false]
        ]
      ],
      Tetromino [ # T
       TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [false,true,false,false],
          [true,true,true,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,true,false,false],
          [true,true,false,false],
          [false,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [false,false,false,false],
          [true,true,true,false],
          [false,true,false,false]
        ],
        TetrominoPermutation [
          [false,false,false,false],
          [true,false,false,false],
          [true,true,false,false],
          [true,false,false,false]
        ]
      ]
    ]
  