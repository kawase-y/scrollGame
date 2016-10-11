-----------------------------------------------------------------------------------------
--
-- main.lua
--uoooooooooooooooooooooooooooooo
-----------------------------------------------------------------------------------------

-- Your code here

--ライブラリの指定
local scroll  = require("scroll")
local physics = require("physics")
local widget  = require "widget"

--定数
local _W = display.contentWidth
local _H = display.contentHeight
local resetBtn


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
              walls[i]:setFillColor(1, 1, 1) -- 白
              physics.addBody( walls[i], "static", {} ) -- 壁は重力で動かない静的なオブジェ
          end

--オブジェクトの定義
local myBall    = display.newImage("ball.png",50,50) -- プレイヤー
local SE_coin   = audio.loadSound("Coin.mp3") -- コインの効果音
local coin      = display.newImage("coin.png", math.random(40, _W-40), math.random(40, _H-40)) -- コイン

Gallery = widget.newButton{
  label        = "Reset",
  labelColor   = { default={255}, over={128} },
  defaultFile  = "btn.png",
  overFile     = "btnover.png",
  width=70, height=35,
  emboss = true,
  onRelease = onresetBtnRelease	-- event listener function
}
Gallery.x = 70
Gallery.y = _H + 25

physics.addBody(myBall, {density = 2, friction = 0.2, bounce = 1.005, radius = 20}) --ボールの物理属性
physics.addBody(coin, "kinematic", {isSensor = true}) --コインの物理属性


display.setStatusBar(display.HiddenStatusBar) -- 不明


local myLines    = {} -- 線の定義
local lineCount  = 1 -- 線の初期値
local resetJudge = false -- 線の数の最大値を判定
local tx; local ty; -- 線の始点



function DrawLine(event) -- 線を書く(最重要)

    if(event.y >= _H/20)then -- あまり高い位置では線を書かせない
        local t     = event.target
        local phase = event.phase

            if(phase == "began" )then
              elseif("moved" == phase)then

              -- ドラッグしている際の線引き

              tx                              = event.x;
              ty                              = event.y;
              myLines[lineCount]              = display.newLine(tx, ty, tx+5, ty)
              myLines[lineCount].strokeWidth  = 5
              physics.addBody(myLines[lineCount], "kinematic",{})

                      if (lineCount == 100) then -- 線(点のつながり)の最大は100個
                          lineCount   = 1
                          resetJudge  = true
                          display.remove(myLines[1])
                      end
                if(resetJudge == true)then
                          display.remove(myLines[lineCount + 1])
                end
                          lineCount = lineCount + 1

        elseif("ended" == phase or "canceled" == phase)then
          end
          return true
    end
end

local function onresetBtnRelease() -- 線のリセット
  for i=1, 100 do
    display.remove(myLines[i])
  end
end

local function onCollision(event) -- コインとの当たり判定

    if(event.phase == "began")then
        if(coin.isVisible) then
      audio.play(SE_coin)
      coin.isVisible = false
        end
    end
end

local function coinReset(event) -- コインの再配置,ゲームオーバーの判定
  -- コインの再配置
  if(coin.isVisible == false) then
     coin.x = math.random(40, _W-40)
     coin.y = math.random(40, _H-40)
     coin.isVisible = true
  end

  -- ゲームオーバーの表示
    if(myBall.y > _H)then
        Gameover = display.newText("GAMEOVER",100,400,nil,30)
        Gameover:setFillColor(1,1,1)
    end
end

Runtime:addEventListener("touch", DrawLine)       -- 線を引く(最重要)
Runtime:addEventListener("enterFrame",coinReset)  -- コインの再配置,ゲームオーバーの判定
coin:addEventListener("collision", onCollision)   -- コインとの当たり判定
