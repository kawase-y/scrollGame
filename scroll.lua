-- by: jStrahan c2012 --

local lf = {}
    lf.insert   = table.insert
    lf.remove   = table.remove

local function move( arg )
    local arg = arg
    local b = #arg.img
    
    for a = 1, b do
    	arg.img[a]:translate( ( arg.dir[1] * arg.spd ), ( arg.dir[2] * arg.spd ) )
    	
    	if arg.dir[2] == -1 and ( arg.img[a].y + ( arg.img[a].height*0.5 ) ) < 0  then
            arg.img[a].y = arg.img[b].y + ( arg.img[b].height )
			lf.insert( arg.img, arg.img[a])
			lf.remove( arg.img, 1 )
        end

        if arg.dir[2] == 1 and ( arg.img[a].y - ( arg.img[a].height*0.5 ) ) > display.contentHeight  then
			arg.img[a].y = arg.img[b].y - ( arg.img[b].height )
			lf.insert( arg.img, arg.img[a])
			lf.remove( arg.img, 1 )
        end

        if arg.dir[1] == -1 and ( arg.img[a].x + ( arg.img[a].width*0.5 ) ) < 0  then
			arg.img[a].x = arg.img[b].x + ( arg.img[b].width )
			lf.insert( arg.img, arg.img[a])
			lf.remove( arg.img, 1 )
        end

        if arg.dir[1] == 1 and ( arg.img[a].x - ( arg.img[a].width*0.5 ) ) > display.contentWidth  then
			arg.img[a].x = arg.img[b].x - ( arg.img[b].width )
			lf.insert( arg.img, arg.img[a])
			lf.remove( arg.img, 1 )
        end
    end
    
end

local scroll = {}

	scroll.newBackGround = function( png, params )
            local bgList = {}
                local listGroup     = display.newGroup()
                local png           = png           or {}
                local params        = params        or {}
                    bgList.img      = {}
                    bgList.spd      = params.speed  or 1
                    bgList.focus    = params.focus  or nil
                    params.dir      = params.dir    or "down"

                    if      params.dir == "up"      then bgList.dir = { 0, -1, "up"    }
                    elseif  params.dir == "right"   then bgList.dir = { -1, 0, "right" }
                    elseif  params.dir == "left"    then bgList.dir = {  1, 0, "left"  }
                    else                                 bgList.dir = {  0, 1, "down"  }
                    end

                if not png then return false end

                if #png == 1 then lf.insert(png, png[1]) end

                for a = 1, #png do
                    local pic = png[a]..".png"
                    bgList.img[a]           = display.newImage( listGroup, pic, true )
                    bgList.img[a].isVisible = false

                    if bgList.dir[1]        == -1 then
                        bgList.img[a].y     = display.contentHeight * 0.5
			bgList.img[a].x     = ( ( a - 1 ) * ( bgList.img[a].width  ) )
                    elseif bgList.dir[1]    == 1 then
			bgList.img[a].y     = display.contentHeight * 0.5
			bgList.img[a].x     = -( ( a - 2 ) * ( bgList.img[a].width ) )
                    elseif bgList.dir[2]    == -1 then
			bgList.img[a].x     = display.contentWidth * 0.5
			bgList.img[a].y     = ( ( a - 1 ) * ( bgList.img[a].height ) )
                    else
			bgList.img[a].x     = display.contentWidth * 0.5
			bgList.img[a].y     = -( ( a - 2 ) * ( bgList.img[a].height) )
                    end
                end

                function bgList:show()
                    for a = 1, #self.img do
                        self.img[a].isVisible = true
                    end
                end

                function bgList:hide()
                    for a = 1, #self.img do
                        self.img[a].isVisible = false
                    end
                end

                function bgList:direction( arg )
                    local arg = arg or nil
                    if arg == nil then
                        return self.dir[3]
                    else

                        if arg == "right" then
                            for a = 1, #self.img do
                                self.img[a].y = display.contentHeight * 0.5
                                self.img[a].x = ( ( a - 1 ) * ( self.img[a].width ) )
                            end
                            self.dir[1], self.dir[2], self.dir[3] = -1, 0, "right"

                        elseif arg == "left" then
                            for a = 1, #self.img do
                                self.img[a].y = display.contentHeight * 0.5
                                self.img[a].x = -( ( a - 2 ) * ( self.img[a].width ) )
                            end
                            self.dir[1], self.dir[2], self.dir[3] = 1, 0, "left"

                        elseif arg == "up" then
                            for a = 1, #self.img do
                                self.img[a].x = display.contentWidth * 0.5
                                self.img[a].y = ( ( a - 1 ) * ( self.img[a].height ) )
                            end
                            self.dir[1], self.dir[2], self.dir[3] = 0, -1, "up"

                        else
                            for a = 1, #self.img do
                                self.img[a].x = display.contentWidth * 0.5
                                self.img[a].y = -( ( a - 2 ) * ( self.img[a].height ) )
                            end
                            self.dir[1], self.dir[2], self.dir[3] = 0, 1, "down"

                        end
                    end
                end

                function bgList:speed( arg )
                    local arg       = arg   or nil
                    if arg          == nil  then
                        return      self.spd
                    elseif type(arg) == "number" then
                        self.spd = arg
                    else
                        arg.time    = arg.time  or 1000
                        arg.speed   = arg.speed or 0
                        transition.to( self, { time = arg.time, spd = arg.speed } )
                    end
                end

                function bgList:color( arg )
                    local arg = arg or {}
                        arg[1] = arg[1] or 255
                        arg[2] = arg[2] or 255
                        arg[3] = arg[3] or 255
                        arg[4] = arg[4] or 255
                    for a = 1, #self.img do
                        self.img[a]:setFillColor( arg[1], arg[2], arg[3], arg[4] )
                    end
                end

                function bgList:clean()
                    for a = 1, #self.img do
			self.img[a]:removeSelf()
                    end
                    self = nil
                end

                function bgList:start()
                    self.run = timer.performWithDelay( 10, function() move(self) end, 0 )
                end

                function bgList:stop()
                    timer.cancel( self.run )
                end

           return bgList
       end

return scroll
