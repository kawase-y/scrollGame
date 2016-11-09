-- スプラッシュ画面

-- ライブラリ
local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )

-- 定数
local _W = display.viewableContentWidth
local _H = display.viewableContentHeight


-- オブジェクト
local bg, logo


bg    = display.newRect(0,0, _W, _H)
bg.x  = _W/2
bg.y  = _H/2
bg:setFillColor( 1, 1, 1 )

logo    = display.newImage("Splash.png", 10, 20)
logo.x  = _W/2
logo.y  = _H/2 + 50


-- スプラッシュを閉じる
local function closeSplash()

    display.remove(logo)
    display.remove(bg)
    logo        = nil
    background  = nil

    composer.gotoScene( "top", "fade", 500  )
end
timer.performWithDelay(2000, closeSplash)
