

--ライブラリの指定
local scroll  = require("scroll")
local physics = require("physics")
local widget  = require "widget"

--定数
local _W = display.contentWidth
local _H = display.contentHeight

-- 物理演算開始
physics.start()
physics.setGravity(0, 0)

--背景設定
local Back
bg 					= display.newRect( 0, 0, _W, _H )
bg.anchorX 	= 0
bg.anchorY 	= 0
bg:setFillColor( 0,0.5,0.5 )

------------------------------------------------------------------------------
--壁の定義
------------------------------------------------------------------------------
local walls = {
            display.newRect(3, _H/2, 6, _H), -- 左の壁
            display.newRect(_W/2, 3, _W, 6), -- 上の壁
            display.newRect(_W -3, _H/2, 6, _H), -- 右の壁
      }
for i=1, #walls, 1 do -- 壁の初期設定
        walls[i]:setFillColor(1, 1, 1) -- 白
        physics.addBody( walls[i], "static", {density = 0.0, friction = 0.0, bounce = 1.0} ) -- 壁は重力で動かない静的なオブジェ
        walls[i].tag = "wall"
end

local bottomWall = display.newRect(_W/2, _H -3, _W, 6) -- 下の壁
bottomWall:setFillColor(1, 1, 1) -- 白
physics.addBody( bottomWall, "static", {density = 0.0, friction = 0.0, bounce = 1.0} ) -- 壁は重力で動かない静的なオブジェ
bottomWall.tag = "bottomWall"


------------------------------------------------------------------------------
 -- ボールの定義、ゲーム開始設定
------------------------------------------------------------------------------

local myBall = display.newImage("ball.png", 100, 100) -- ボール
physics.addBody(myBall, {density = 0.0, friction = 0.0, bounce = 1.0}) --ボールの物理属性
myBall.tag = "ball"


function resetBallPos()
    myBall.x = _W/2
    myBall.y = _H/2
end

function gameStart()
    resetBallPos()
    myBall:setLinearVelocity(0, 100) -- y方向の初速度
end

gameStart()

------------------------------------------------------------------------------
 -- ブロックの定義
------------------------------------------------------------------------------

local maxNumBlocks = 0 -- ブロックの最大数
local numBlocks = 0
local blocks = {}

function deleteBlock(index)
    -- ブロックが存在しない場合は無視する
    if (blocks[index] == nil) then
        return -- ここで関数を終了させる
    end
      blocks[index]:removeSelf() -- 画面から消す関数
      blocks[index] = nil -- メモリ解放
      numBlocks = numBlocks - 1 -- 一つブロックを削除したので、 numBlocksを -1する
end

function deleteAllBlocks()
    -- for文でブロックを全て削除
    for i = 0, maxNumBlocks, 1 do
        deleteBlock(i)
    end
      -- ブロックを管理している変数を全て初期化する
      maxNumBlocks = 0
      numBlocks = 0
      blocks = {}
end

function deployBlocks()
    -- ブロックを配置する前に全てのブロックを削除
    deleteAllBlocks()

    -- ブロックを配置
    for y = 0, 1, 1 do
        for x = 0, 4, 1 do
            -- 何番目の要素か
            local index = x + (y * 5) -- indexは0-9まで
            blocks[index] = display.newImage("block.png", _W * 1/8, 100) -- この後再配置するためこの座標(_W * 1/8, 100)は意味なし

            -- (width * 1/6) => 画面を6つに分ける、2つは両端なので、実際に使えるのは4つ
            -- (x + 1) => 分けた4つのうちの何番目か、0は端っこなので+1して無視する
            blocks[index].x = (x + 1) * _W/6

            blocks[index].y = _H/6 + (_H/6 * y)
            blocks[index].tag = "block"

            blocks[index].index = index  -- 後で識別しやすいように生成した順番を入れておく
            physics.addBody(blocks[index], "static", {density = 0.0, friction = 0.0, bounce = 1.0})

            -- 現在のブロック数を追加
            numBlocks = numBlocks + 1
        end
    end

    -- 生成したブロック数を保存
    maxNumBlocks = numBlocks
end

deployBlocks()

------------------------------------------------------------------------------
 -- 線の定義
------------------------------------------------------------------------------

local myLines    = {} -- 線の定義
local lineCount  = 1 -- 線の初期値
local maxLineNum = 100
local resetJudge = false -- 線の数の最大値を判定
local tx; local ty; -- 線の始点



function DrawLine(event) -- 線を書く(最重要)

    if(event.y >= _H/3*2)then -- 下1/3の範囲でのみ描画可能
        local t     = event.target
        local phase = event.phase

            if(phase == "began" )then
              elseif("moved" == phase)then

              -- ドラッグしている際の線引き

              tx                              = event.x;
              ty                              = event.y;
              myLines[lineCount]              = display.newLine(tx, ty, tx+5, ty)
              myLines[lineCount].strokeWidth  = 5
              physics.addBody(myLines[lineCount], "static",{density = 0.0, friction = 0.0, bounce = 1.0})
              myLines[lineCount].tag = "var"

                      if (lineCount == maxLineNum) then -- 線(点のつながり)の最大は100個
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

function deleteLine(index)
    -- ブロックが存在しない場合は無視する
    if (myLines[index] == nil) then
        return -- ここで関数を終了させる
    end
      display.remove(myLines[index]) -- 画面から消す関数
      myLines[index] = nil -- メモリ解放
      lineCount = lineCount - 1

end

function deleteAllLines()
    -- for文で全て削除
    for i = 0, maxLineNum, 1 do
        deleteLine(i)
    end
      -- ブロックを管理している変数を全て初期化する
      maxLineNum = 0
      lineCount = 1
      myLines = {}
end
------------------------------------------------------------------------------
 -- ゲームロジック
------------------------------------------------------------------------------

function ballStabilization()
    -- 速度を取得して、x,yの速度を500に固定する
    local vx, vy = myBall:getLinearVelocity()
      if (0 < vx) then
          vx = 300
      else
          vx = -300
      end
      if (0 < vy) then
          vy = 300
      else
          vy = -300
      end
    -- 速度を安定させる
    myBall:setLinearVelocity(vx, vy)
    -- 回転させる
    --myBall:applyTorque(90)
end


local completeText = nil

function completeGame()
    physics.pause()
    completeText = display.newText("Complete", _W/2, _H/2, native.systemFont, 40)
    completeText:setTextColor(1.0, 1.0, 1.0)
     Runtime:addEventListener("tap", resetGame)
end

function failGame()
    physics.pause()
    completeText = display.newText("Fail", _W/2, _H/2, native.systemFont, 40)
    completeText:setTextColor(1.0, 1.0, 1.0)
     Runtime:addEventListener("tap", resetGame)
end

function resetGame()
    Runtime:removeEventListener("tap", resetGame)

    completeText:removeSelf()
    completeText = nil

    physics.start()

deleteAllLines()
    deployBlocks()
    resetBallPos()
    gameStart()
end

function ballCollision(event)
    if (event.phase == "began") then
        print("collision: "..event.other.tag)
    elseif (event.phase == "ended") then
        ballStabilization()

        -- ブロックに当たった時はブロックを削除
        if (event.other.tag == "block") then
            local hitBlock = event.other
            deleteBlock(hitBlock.index)
            -- ブロックがなくなった場合はクリア判定
            if (numBlocks == 0) then
              completeGame()
            end
        elseif (event.other.tag == "bottomWall") then
              failGame()
        end
    end
end

-- 衝突イベントをボールに設定
myBall:addEventListener("collision", ballCollision)
-- 線を引く(最重要)
Runtime:addEventListener("touch", DrawLine)
