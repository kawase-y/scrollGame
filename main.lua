-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

--ライブラリの指定
local scroll = require("scroll")
local SE_coin = audio.loadSound("Coin.mp3")


--定数
local _W = display.contentWidth
local _H = display.contentHeight

--背景の指定
local Back
Back = scroll.newBackGround({"LoopBack"},{dir = "right", speed = 2})
Back:show()


--オブジェクトの定義
local myBall = display.newImage("ball.png",0,50)
local coin = display.newImage("coin.png", math.random(40, _W-40), math.random(40, _H-40))
local wall = display.newRect(_W/2, 20, _W+80, 6)
local leftWall = display.newRect(-40, _H/2, 20, _H)
leftWall:setFillColor(0,0,0)
local rightWall = display.newRect(_W+40, _H/2, 20, _H)
rightWall:setFillColor(0,0,0)
local jamming = display.newRect(math.random(40,_W-40),math.random(40, _H-40),math.random(10,80),20)
local bar = display.newRect(0, _H-20, 50, 20)
local GAMEOVER


if(myBall.y > _H)then

    GAMEOVER = display.newText("GAMEOVER",100,400,nil,30)

end


--物理演算
local physics = require("physics") --物理演算の開始
physics.start()
physics.addBody(myBall, {density = 2, friction = 0.2, bounce = 1.005, radius = 20}) --ボールの物理属性
physics.addBody(coin, "kinematic", {isSensor = true}) --コインの物理属性
physics.addBody(wall, "static",{})
physics.addBody(jamming, "static", {})
physics.addBody(leftWall, "static", {})
physics.addBody(bar, "static", {})
physics.addBody(rightWall, "static", {})

display.setStatusBar(display.HiddenStatusBar)
local myLines = {}
local lineCount = 1
local tx; local ty;


function DrawLine(event)

    if(event.y >= _H*0.05)then

        local t = event.target
        local phase = event.phase

        if(phase == "began" and event.y < _H - 68)then
            tx = event.x;
            ty = event.y;

        elseif("moved" == phase)then

            if(myLines[lineCount])then

                myLines[lineCount].parent:remove(myLines[lineCount])

            end

        myLines[lineCount] = display.newLine(tx, ty, event.x, event.y)
        myLines[lineCount].width = 4

        elseif("ended" == phase or "canceled" == phase)then

            dist_x = event.x - tx
            dist_y = event.y - ty
            physics.addBody(myLines[lineCount], "static",{})
            display.getCurrentStage():setFocus(nil)
            lineCount = lineCount + 1


        end
    return true
    end
end


Runtime:addEventListener("touch", DrawLine)



local function onCollision(event)

    if(event.phase == "began")then
        if(coin.isVisible) then
      audio.play(SE_coin)
      coin.isVisible = false
        end

    if(coin.isVisible == false) then

         coin = display.newImage("coin.png", math.random(40, _W-40), math.random(40, _H-40))

    end

    end

end
coin:addEventListener("collision", onCollision)
