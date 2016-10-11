-----------------------------------------------------------------------------------------
--
-- main.lua
--uoooooooooooooooooooooooooooooo
-----------------------------------------------------------------------------------------

-- Your code here

--ライブラリの指定
local scroll = require("scroll")
local physics = require("physics")
local SE_coin = audio.loadSound("Coin.mp3")

--定数
local _W = display.contentWidth
local _H = display.contentHeight

--背景設定
local Back
bg 					= display.newRect( 0, 0, _W, _H )
bg.anchorX 	= 0
bg.anchorY 	= 0
bg:setFillColor( 0,0,0 )

-- 物理演算開始
physics.start()


-- 壁の定義
local walls = {
    display.newRect(3, _H/2, 6, _H), -- 左の壁
    display.newRect(_W/2, 3, _W, 6), -- 上の壁
    display.newRect(_W -3, _H/2, 6, _H), -- 右の壁
    display.newRect(_W/2, _H -3, _W, 6) -- 下の壁
}
for i=1, 4, 1 do -- 壁の初期設定
    walls[i]:setFillColor(1, 1, 1)
    physics.addBody( walls[i], "static", {} ) -- 壁は重力で動かない静的なオブジェ
end

--オブジェクトの定義
local myBall = display.newImage("ball.png",50,50)
physics.addBody(myBall, {density = 2, friction = 0.2, bounce = 1.005, radius = 20}) --ボールの物理属性

local coin = display.newImage("coin.png", math.random(40, _W-40), math.random(40, _H-40))
physics.addBody(coin, "kinematic", {isSensor = true}) --コインの物理属性


display.setStatusBar(display.HiddenStatusBar) -- 不明


local myLines = {} -- 線の定義
local lineCount = 1-- 線の初期値
local tx; local ty; -- 線の始点


function DrawLine(event)

-- ゲームオーバーの表示テスト
  if(myBall.y > _H/2)then
      Gameover = display.newText("GAMEOVER",100,400,nil,30)
      Gameover:setFillColor(1,1,1)
  end

  --
    if(event.y >= _H*0.05)then
        local t = event.target
        local phase = event.phase


        if(phase == "began" )then
            tx = event.x;
            ty = event.y;
        elseif("moved" == phase)then

              if(myLines[lineCount])then
                  myLines[lineCount].parent:remove(myLines[lineCount]) -- 線を戻すように動かすとエラーが出る
              end

              -- ドラッグしている際の線引き
                if(  tx ~= event.x)and(  ty ~= event.y)then
                    myLines[lineCount] = display.newLine(tx, ty, event.x, event.y)
                    myLines[lineCount].strokeWidth = 4
                end


        elseif("ended" == phase or "canceled" == phase)then

          -- ドラッグせずにその場で話した際の動作
          if(  math.abs(tx - event.x) < 10 )and(  math.abs(ty - event.y) < 10 )then
            myLines[lineCount] = display.newLine(tx, ty, tx+10, ty)
            myLines[lineCount].strokeWidth = 4
          end

            physics.addBody(myLines[lineCount], "kinematic",{}) -- ":"ではなく"."でないかとエラーが出る

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
    end
end

local function coinReset(event)
  if(coin.isVisible == false) then
     coin.x = math.random(40, _W-40)
     coin.y = math.random(40, _H-40)
     coin.isVisible = true
  end
end

Runtime:addEventListener("enterFrame",coinReset)
coin:addEventListener("collision", onCollision)
