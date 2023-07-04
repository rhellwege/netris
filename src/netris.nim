import raylib
import std/random, strformat, lenientops
import system
include "settings.nims"

const songStr = staticRead("../assets/Tetris.wav")
const hitSoundStr = staticRead("../assets/blip.wav")
const clearSoundStr = staticRead("../assets/bitbounce.wav")
const gameOverStr = staticRead("../assets/gameover.wav")

initAudioDevice() # TODO: REFACTOR SOUNDS
let song = loadSoundFromWave(loadWaveFromMemory(".wav", songStr.toOpenArrayByte(0, len(songStr)-1)))
let hitSound = loadSoundFromWave(loadWaveFromMemory(".wav", hitSoundStr.toOpenArrayByte(0, len(hitSoundStr)-1)))
let clearSound = loadSoundFromWave(loadWaveFromMemory(".wav", clearSoundStr.toOpenArrayByte(0, len(clearSoundStr)-1)))
let gameOverSound = loadSoundFromWave(loadWaveFromMemory(".wav", gameOverStr.toOpenArrayByte(0, len(gameOverStr)-1)))

type
  GameState = object
    paused: bool
    activeTetromino: TetrominoType
    nextTetromino: TetrominoType
    speed: Natural
    frames: Natural
    score: Natural
    lastBreath: Natural ## amount of frames during a collision you are allowed to change position
    posX: int
    posY: int
    rotation: Rotation
    board: array[boardRows, array[boardCols, TetrominoType]]

proc inBounds(g: GameState): bool =
  for i in countUp(0, 3):
    for j in countUp(0, 3):
      if tetrominos[ord g.activeTetromino][ord g.rotation][i][j]:
        if (g.posX + j) < 0 or g.posY + i < 0 or g.posX + j >= boardCols or
            g.posY + i >= boardRows:
          return false
        if g.board[i + g.posY][j + g.posX] != None:
          return false
  return true


proc attemptMove(g: var GameState, dx: int, dy: int): bool =
  let curX = g.posX
  let curY = g.posY
  g.posX = g.posX + dx
  g.posY = g.posY + dy
  if not g.inBounds():
    g.posX = curX
    g.posY = curY
    return false
  return true

proc attemptRotation(g: var GameState): bool =
  let curRotation = g.rotation
  g.rotation = if g.rotation == 3: 0 else: g.rotation + 1
  if not g.inBounds():
    g.rotation = curRotation
    return false
  return true


proc collides(g: GameState): bool =
  if not g.inBounds(): return false
  for i in countDown(3, 0):
    for j in countUp(0, 3):
      if tetrominos[ord g.activeTetromino][ord g.rotation][i][j]:
        if g.posY + i >= boardRows - 1 or g.board[g.posY + i + 1][g.posX + j] !=
            None: return true
  return false

proc clearFilledRows(g: var GameState) =
  var
    clearedRows = 0
    startRow = g.posY + 3
    endRow: int
  for row in countDown(startRow, g.posY):
    var clear = true
    for col in countUp(0, boardCols-1):
      if g.board[row][col] == None:
        clear = false
        break
    if clear:
      if clearedRows == 0: startRow = row
      inc clearedRows

  if clearedRows == 0: return
  playSound(clearSound)

  endRow = startRow - clearedRows + 1
  
  # shift all rows above the cleared rows down
  for row in countDown(endRow-1, 0):
    let swapRow = startRow - ((endRow - 1) - row)
    for col in countUp(0, boardCols-1):
      g.board[swapRow][col] = g.board[row][col]
      g.board[row][col] = None

  g.score += clearedRows
  dec g.speed

proc main =
  initWindow(screenWidthPx, screenHeightPx, windowTitle)
  
  defer: closeAudioDevice()
  setTargetFPS(fps)
  setExitKey(Delete)
  randomize()
  
  playSound(song)
  setSoundVolume(song, 0.3)

  var game = GameState(
    posX: int boardCols/2 - 2, posY: 0,
    activeTetromino: TetrominoType rand(6) + 1,
    nextTetromino: TetrominoType rand(6) + 1,
    speed: initialSpeed, frames: 0, lastBreath: initialLastBreath,
    rotation: 0, paused: false, score: 0)

  var movedDown, movedAround = false

  echo game.activeTetromino

  while not windowShouldClose():
    
    # Update
    # handle input:
    if isKeyPressed(Escape): game.paused = not game.paused

    if not game.paused:
      if not isSoundPlaying(song):
        playSound(song) # replay the song
      if isKeyPressed(Up):
        if game.attemptRotation():
          movedAround = true
      if isKeyDown(Left):
        if game.attemptMove(-1, 0):
          movedAround = true
      if isKeyDown(Right):
        if game.attemptMove(1, 0):
          movedAround = true
      if isKeyDown(Down):
        discard game.attemptMove(0, 1)
        movedDown = true
        movedAround = true
      if isKeyPressed(Space):
        while not game.collides():
          inc game.posY
        movedDown = true
        movedAround = true
      if isKeyDown(Space) or isKeyDown(Up):
        movedAround = true
      # handle collision
      if game.collides():
        if not movedAround or game.lastBreath == 0:
          playSound(hitSound)
          for i in countUp(0, 3):
            for j in countUp(0, 3):
              if tetrominos[ord game.activeTetromino][ord game.rotation][i][j]:
                game.board[game.posY + i][game.posX + j] = game.activeTetromino

          game.clearFilledRows()
          # reset game state for new active tetromino
          game.rotation = 0
          game.activeTetromino = game.nextTetromino
          game.nextTetromino = TetrominoType rand(6) + 1
          game.posX = int boardCols/2 - 2
          game.posY = 0
          game.lastBreath = initialLastBreath
          if not game.inBounds():
            stopSound(song)
            playSound(gameoverSound)
            game.paused = true # you just lost
        else:
          dec game.lastBreath
      else:
        # move tetromino down every few frames
        if game.frames mod game.speed == 0 and not movedDown:
          inc game.posY

      inc game.frames
      movedDown = false
      movedAround = false

    # Draw
    beginDrawing()
    clearBackground(RayWhite)
    if showFps:
      drawText(cstring fmt"{getFps()}fps", 0, 0, 10, Green)
    if not game.paused:
      # draw the board
      for i in countUp(0, 19):
        for j in countUp(0, 9):
          drawRectangle(int32 boardRect.x + (j*cellWidthPx),
                        int32 boardRect.y + (i*cellWidthPx),
                        int32 cellWidthPx, int32 cellHeightPx,
                        colorSettings[game.board[i][j]])
      # draw the active tetromino
      for i in countUp(0, 3):
        for j in countUp(0, 3):
          if tetrominos[ord game.activeTetromino][ord game.rotation][i][j]:
            drawRectangle(int32 boardRect.x + ((game.posX+j)*cellWidthPx),
                          int32 boardRect.y + ((game.posY+i)*cellWidthPx),
                          int32 cellWidthPx, int32 cellHeightPx,
                          colorSettings[game.activeTetromino])
      # draw preview
      for i in countUp(0, 3):
        for j in countUp(0, 3):
          if tetrominos[ord game.nextTetromino][0][i][j]:
            drawRectangle(int32 previewRect.x + ((1+j)*cellWidthPx),
                          int32 previewRect.y + ((1+i)*cellWidthPx) - (cellWidthPx/2),
                          int32 cellWidthPx, int32 cellHeightPx,
                          colorSettings[game.nextTetromino])

      # draw score
      drawText(cstring fmt"Score: {game.score}", 30, int32 boardRect.y, 30, Black)

      # draw board border
      drawRectangleLines(boardRect, 2.0, BLACK)

      # draw preview border
      drawRectangleLines(previewRect, 2.0, BLACK)

    else: # game is paused
      drawText(cstring "Paused...", int32 screenWidthPx / 2,
          int32 screenHeightPx / 2, 20, Black)

    endDrawing()

  closeWindow() # Close window and OpenGL context

main()
