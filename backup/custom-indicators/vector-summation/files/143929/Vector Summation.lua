-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71567
 
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Vector Summation")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
 

	indicator.parameters:addGroup("Style")
 	indicator.parameters:addInteger("size1", "Cross Size", "Size", 10);
 	indicator.parameters:addInteger("size2", "Cross Size", "Size", 20);	
	indicator.parameters:addColor("color1", "1. Vector Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "2. Vector Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Label", "Label Color", "Label Color", core.COLOR_LABEL );	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first
local source = nil
local db;
local pattern = "([^;]*);([^;]*)"
-- Streams block

 
local Date={};
local Level={};
local Label;
-- Routine
function Prepare(nameOnly)
 
	source = instance.source
	first = source:first()
	Label= instance.parameters.Label;

	instance:ownerDrawn(true)

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	
	
	require("storagedb")
	db = storagedb.get_db(source:name())

	core.host:execute("addCommand", 1, "1. Vector Start")
	core.host:execute("addCommand", 2, "1. Vector End")
	core.host:execute("addCommand", 3, "2. Vector Start")
	core.host:execute("addCommand", 4, "2. Vector End")	
	core.host:execute("addCommand", 5, "Reset")

	
	core.host:execute ("setTimer", 10, 1);
		
end


function ReleaseInstance()
core.host:execute ("killTimer", 10);
end 

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	-- initialize GDI objects
	if not init then
		context:createPen(1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.color1) 
		context:createPen(2, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.color2)
	    context:createFont (11, "Wingdings", context:pointsToPixels (instance.parameters.size1),  context:pointsToPixels (instance.parameters.size1), 0);
		 context:createFont (12, "Arial", context:pointsToPixels (instance.parameters.size2),  context:pointsToPixels (instance.parameters.size2), 0);	
		init = true
	end
	
 
	
    width, height= context:measureText (11, "\176", 0);		
	
local x1, x2, x3, x4 =0,0,0,0;
local y1, y2, y3, y4 =0,0,0,0;	

	if Date[1]~= nil 
	and Date[1]~= 0   
	then
	visible, y1 = context:pointOfPrice(Level[1]);
	x1, x, x = context:positionOfDate (Date[1]);	

    context:drawText (11, "\176", Label, -1, x1-width/2, y1-height/2 , x1+width/2, y1+height, 0);	
    end
	
	if Date[2]~= nil 
	and Date[2]~= 0  
	then
	visible, y2 = context:pointOfPrice(Level[2]);
	x2, x, x  = context:positionOfDate (Date[2]);
    context:drawText (11, "\176", Label, -1, x2-width/2, y2-height/2 , x2+width/2, y2+height, 0);		
	end
	
	if  x1~=0 and x2~=0 
	and y1~=0 and y2~=0 
	then  
	
	context:drawLine(1, x1, y1, x2, y2);
	end
	
	if Date[3]~= nil 
	and Date[3]~= 0  
	then
	visible, y3 = context:pointOfPrice(Level[3]);
	x3, x, x  = context:positionOfDate (Date[3]);
    context:drawText (11, "\176", Label, -1, x3-width/2, y3-height/2 , x3+width/2, y3+height, 0);		
	end
	
	if Date[4]~= nil 
	and Date[4]~= 0  	
	then
	visible, y4 = context:pointOfPrice(Level[4]);
	x4, x, x  = context:positionOfDate (Date[4]);
    context:drawText (11, "\176", Label, -1, x4-width/2, y4-height/2 , x4+width/2, y4+height, 0);		
	end
	
	if   x3~=0 and x4~=0 
	and y3~=0 and y4~=0 
	then
	context:drawLine(1, x3, y3, x4, y4);	
	end	

local Summation=0;	
	
	if x1~=0 and x2~=0 
    and x3~=0 and x4~=0   
	then
	Summation=(Level[2]-Level[1])+(Level[4]-Level[3]);
	local Text=  win32.formatNumber(Summation/source:pipSize(), true, 2) .. " Pips";
    width, height= context:measureText (12, Text, 0);		
    context:drawText (12, Text, Label, -1, x4 , y4 -height , x4+width , y4, 0);	
	end

 
end

function Update(period)
end



function AsyncOperationFinished(cookie, success, message)


    if cookie <= 4 then

 		local level, date = string.match(message, pattern, 0)

		if cookie == 1 then
			db:put("Date11", date)
			db:put("Level11", level)
		elseif cookie == 2 then
			db:put("Date12", date)
			db:put("Level12", level)
		elseif cookie == 3 then
			db:put("Date21", date)
			db:put("Level21", level)
		elseif cookie == 4 then
			db:put("Date22", date)
			db:put("Level22", level)
		end
	end	

    if cookie == 10 then
	Date[1]=db:get ("Date11", 0);
	Date[2]=db:get ("Date12", 0);
	Date[3]=db:get ("Date21", 0);
	Date[4]=db:get ("Date22", 0);	

	Level[1]=db:get ("Level11", 0);
	Level[2]=db:get ("Level12", 0);
	Level[3]=db:get ("Level21", 0);
	Level[4]=db:get ("Level22", 0);	
	
	end
	
	
  

	if cookie == 5 then
		db:put("Date11", 0)
		db:put("Date12", 0)
		db:put("Date21", 0)
		db:put("Date22", 0)		
	end
end
