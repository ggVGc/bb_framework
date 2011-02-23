
dofile("AIController.lua")
dofile("HumanController.lua")
dofile("oceanmap.lua")
dofile("arcade_camera.lua")

ArcadeScreen = {}

function ArcadeScreen.new(texSheet)
  local M = {}

  local arcadeCam = ArcadeCamera.new()
  local uiCam = UICamera.new()
  local arcade_background = nil
  local humanController = HumanController:new()
  local opponentControllers = {}
  local map = OceanMap:new()
  local gameStartTimer = nil
  local goStayCount = nil
  local readyCount = nil
  local setCount = nil
  local gameStartCounter = nil
  local gameRound = 0
  local maxGameRounds = 4
  local gameLeague = 0
  local numOfOpponents = 3
  local resultList = {}
  local scoreTable = {}
  local scoreMultifier = 10
  local inp = framework.Input.new()
  local roundCountDownSprites = {}

  function calculateCenter()
    local characterCount = numOfOpponents+1
    local characterWidth = humanController:getTarget():getSpriteWidth() * 0.6
    local totalDist = characterCount * characterWidth + (characterCount-1)*(characterWidth/2)
    local offsetFromCenter = totalDist/2
    return framework.Window.getWidth()/2 - offsetFromCenter
  end

  function init()
    arcade_background = texSheet.createTexture("reef.png")

    table.insert(roundCountDownSprites, texSheet.createTexture("ready.png"))
    table.insert(roundCountDownSprites, texSheet.createTexture("set.png"))
    table.insert(roundCountDownSprites, texSheet.createTexture("go.png"))

    map:init()

    humanController:init(map, resultList, 0, texSheet, "character.png")
    humanController:getTarget():setX(calculateCenter())

    opponentTextureNames = {"opp1.png", "opp2.png", "opp3.png", "opp4.png"}
    humanPositionX = humanController:getTarget():getX()
    for i = 0, numOfOpponents do
      opponentControllers[i] = AIController:new()
      opponentControllers[i]:init(map, resultList, 1000+i, texSheet, opponentTextureNames[i+1])
      local opponentWidth = opponentControllers[i]:getTarget():getSpriteWidth() * 0.6
      opponentControllers[i]:getTarget():setX(humanPositionX+((i+1)*(opponentWidth+(opponentWidth/2))))
    end

    -- TODO: Fix this ugly hack.
    local centerOpponentPositionX, centerOpponentPositionY = opponentControllers[1]:getTarget():getPosition()
    opponentControllers[1]:getTarget():setPosition(HumanController:getTarget():getPosition())
    HumanController:getTarget():setPosition(centerOpponentPositionX, centerOpponentPositionY)

    local mapWidth, mapHeight = map:getSize()
    arcadeCam.widthBoundary = mapWidth
    arcadeCam.heightBoundary = mapHeight

    --anim = BitmapAnim:new()
    --anim:init({"ff.png", "f.png"}, 500)

    readyCount = 1000
    setCount = readyCount + 1000
    goStayCount = 400
    gameStartTimer = setCount + 2100
    gameStartCounter = 0
    gameRound = 0
    gameLeague = 0
  end

  function M.gameRoundUpdate(deltaMs)
    humanController:getTarget():doInput(inp.cursorPressed())
    
    map:update(deltaMs)

    humanController:update(deltaMs)

    local allDone = true
    for i = 0, numOfOpponents do
      opponentControllers[i]:update(deltaMs)

      if allDone then
        allDone = opponentControllers[i]:getTarget():isDone()
      end
    end

    local characterX, characterY = humanController:getTarget():getPosition()
    arcadeCam.setPosition(characterX - (arcadeCam.width  / 2), characterY - (arcadeCam.height / 2))

    if gameStartCounter > gameStartTimer then
      humanController:getTarget():setGameStarted(true)
      for i = 0, numOfOpponents do
        opponentControllers[i]:getTarget():setGameStarted(true)
      end
    end
    gameStartCounter = gameStartCounter + deltaMs

    if inp.cursorPressed() and gameStartCounter < gameStartTimer then
      print("Premature jump!");
      humanController:getTarget():doPrematureJump()
    end

    if humanController:getTarget():isDone() and inp.cursorPressed() and allDone then
      calculateLeaderboard()

      if gameRound < maxGameRounds then
        gameRound = gameRound + 1
      else
        print("CHANGED GAME LEAGUE")

        humanController:getTarget():setScore(0)
        for i = 0, numOfOpponents do
          opponentControllers[i]:getTarget():setScore(0)
          opponentControllers[i]:changeLevel(1)
        end
        --gameLeague = gameLeague + 1
        gameRound = 0
      end

      for i = 0, numOfOpponents do 
        opponentControllers[i]:reset()
      end

      humanController:getTarget():reset(map:getStartHeight())

      local characterX, characterY = humanController:getTarget():getPosition()
      arcadeCam.setPosition(characterX - (arcadeCam.width  / 2), characterY - (arcadeCam.height/ 2))
      -- TODO: Add league values for random
      gameStartTimer = setCount + math.random(1500,2000)
      gameStartCounter = 0
      return InfoScreen
    end
  end

  function M.frame(deltaMs)
    inp.update()
    local ret = M.gameRoundUpdate(deltaMs)
    M.draw()
    return ret
  end

  function calculateLeaderboard()
    local scorePoints = 0

    for j = #resultList, 1, -1 do
      local targetId = resultList[j]
      scorePoints = scorePoints + 7
      if targetId == humanController:getTarget():getCharacterId() then
        humanController:getTarget():addScorePoints(scorePoints)
      else
        for i = 0, numOfOpponents do
          if targetId == opponentControllers[i]:getTarget():getCharacterId() then
            opponentControllers[i]:getTarget():addScorePoints(scorePoints)
          end
        end
      end
    end

    scoreTable = {}
    for a = 0, numOfOpponents do
      local characterId = opponentControllers[a]:getTarget():getCharacterId()
      local scorePoint = opponentControllers[a]:getTarget():getScorePoints()
      local score = {charId=characterId, scorePt=scorePoint}
      table.insert(scoreTable, score)  
    end

    local characterId = humanController:getTarget():getCharacterId()
    local scorePoint = humanController:getTarget():getScorePoints()
    local score = {charId=characterId, scorePt=scorePoint}
    table.insert(scoreTable, score)

    table.sort(scoreTable, function (a,b)
      return (a.scorePt > b.scorePt)
    end)

    print("---------------------------")
    for k,v in pairs(scoreTable) do
      print(k,v.charId," : ",v.scorePt)
    end

    while #resultList > 0 do
      table.remove(resultList)
    end

  end

  function M.draw()
    arcadeCam.apply()
    arcade_background.draw(0, 0, 0, 0, 0)
    humanController:draw()

    for i = 0, numOfOpponents do
      opponentControllers[i]:draw()
    end

    uiCam.apply()

    local textX = uiCam.width/ 2
    local textY = uiCam.height/ 2

    if(gameStartCounter < readyCount) then
      roundCountDownSprites[1].draw(textX, textY, 0.5, 0)
    elseif(gameStartCounter < setCount) then
      roundCountDownSprites[2].draw(textX, textY, 0.5, 0)
    elseif(gameStartCounter > gameStartTimer and gameStartCounter < gameStartTimer+goStayCount) then
      roundCountDownSprites[3].draw(textX, textY, 0.5, 0)
    end
  end

  init()
  return M
end
