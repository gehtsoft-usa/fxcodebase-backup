-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72469

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

function AddLevel(id, level, use)

    indicator.parameters:addGroup(id.. ". Fibonacci Level Line Style");
    indicator.parameters:addBoolean("use" .. id, "Use " .. id, "", use or false);
    indicator.parameters:addDouble("level" .. id, "Level " .. id, "", level);
    indicator.parameters:addColor("level_color" .. id, "Level " .. id .. " Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("level_width" .. id, "Level " .. id .. " Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("level_style" .. id, "Level " .. id .. " Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("level_style" .. id, core.FLAG_LINE_STYLE);
end

function Init()
    indicator:name("Fibonacci Rectangle Triangle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
    indicator:setTag("group", "Fibonacci")
	
 
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Unique", "Unique Id" , "Unique Id", 1);	

    AddLevel(1, -0.618);
    AddLevel(2, -0.382);
    AddLevel(3, -0.272);
    AddLevel(4, 0);
    AddLevel(5, 0.236);
    AddLevel(6, 0.382, true);
    AddLevel(7, 0.500, true);
    AddLevel(8, 0.618, true);
    AddLevel(9, 0.764);
    AddLevel(10, 1.0);
    AddLevel(11, 1.272);
    AddLevel(12, 1.618);
    AddLevel(13, 2.618);
    AddLevel(14, 4.236);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("box_color", "Box Color", "", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("line_color", "Line Color", "", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("diagonal_line_color", "Diagonal Line Color", "", core.COLOR_LABEL );	
    indicator.parameters:addInteger("border_width", "Border Width", "", 1, 1, 5);
    indicator.parameters:addInteger("border_style", "Border Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("border_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("transparency", "Transparency", "0 - opaque, 100 - transparent", 25, 0, 100);
end

 
 
local db; 
local Unique;
local pattern = "([^;]*);([^;]*)";
local init = false;

function get_point_coordinates(date, price, context)
    local x, x1, x2 = context:positionOfDate(date);
    local visible, y = context:pointOfPrice(price);
    return x, y;
end

local TOP_PEN = 20;
local TOP_BRUSH = 21;
local Diagonal_BRUSH = 22;
local transparency;

local Level={};
local Date={};
function Draw(stage, context)
    if stage == 2 then
	return;
	end
        if not init then
            context:createPen(TOP_PEN, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, instance.parameters.box_color);
            context:createSolidBrush(TOP_BRUSH, instance.parameters.box_color);		


            context:createPen(Diagonal_BRUSH, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, instance.parameters.diagonal_line_color);

			
			
			for i=1 , 14 , 1 do
			context:createPen(i, context:convertPenStyle(instance.parameters:getInteger("level_style" .. i)), instance.parameters:getInteger("level_width" .. i), instance.parameters:getColor("level_color" .. i));
            end
			
            transparency = context:convertTransparency(instance.parameters.transparency);
       
            
            init = true;
        end
 
 
    if Date[1]== nil or Date[2]== nil then
	return;
	end
	
    if Date[1]== 0 or Date[2]== 0 then
	return;
	end
	
	start_date=0;
	start_rate=0;
	end_date=0;
	end_rate=0;
     
        
		
 
        local x1, y1 = get_point_coordinates(Date[1],Level[1], context);
        local x2, y2 = get_point_coordinates(Date[2], Level[2], context);
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        context:drawRectangle(TOP_PEN, TOP_BRUSH, x1, y1, x2, y2, transparency);
		
        local range = Level[2] - Level[1];
		
		 
	    local m= math.min(y1, y2) + ( math.max(y1, y2) - math.min(y1, y2))/2;

		context:drawLine (Diagonal_BRUSH, x1, y1, x2, m);
		context:drawLine (Diagonal_BRUSH, x1, y2, x2, m);
		
		
			for i=1 , 14 , 1 do
			
					if instance.parameters:getBoolean("use" .. i) then
					

                    visible, y = context:pointOfPrice(Level[1] + range * instance.parameters:getDouble("level" .. i));
					context:drawLine(i, x1, y, x2, y);
		   
					end
			
			end
		 
  
end

function Prepare(onlyName)

	Unique=instance.parameters.Unique;
    local name = profile:name() .. " ".. Unique ;
    instance:name(name);
    
    if onlyName then
        return;
    end
	
    source = instance.source;	

	
    
    init = false; 
	Date={};
	Level={};	
	
	require("storagedb");
    db = storagedb.get_db(name);	
	
    core.host:execute("addCommand", 1, "Start Point");
	core.host:execute("addCommand", 2, "End Point"); 
    core.host:execute("addCommand", 3, "Reset");
	
	
    core.host:execute ("setTimer", 10, 5);   
	instance:ownerDrawn(true);


end

function ReleaseInstance()
core.host:execute ("killTimer", 10);
end


function Update(period, mode)
end 

function AsyncOperationFinished(cookie, success, message)

     
	 
	if cookie== 1 then 
	level, date = string.match(message, pattern, pos);
	
	db:put("Level1" , tostring(level));  
	db:put("Date1" , tostring(date));  
    end	
	
	if cookie== 2 then 
	level, date = string.match(message, pattern, pos);
	
	db:put("Level2" , tostring(level));  
	db:put("Date2" , tostring(date));  
    end		
	
	
	if cookie== 3 then  
	db:put("Level2" , tostring(0));  
	db:put("Date2" , tostring(0));  
	db:put("Level1" , tostring(0));  
	db:put("Date1" , tostring(0)); 	
    end		
	
	
	if cookie == 10 then 
	Date[1]=  tonumber(db:get("Date1", 0));  
 	Date[2]=  tonumber(db:get("Date2", 0));  
	Level[1]=  tonumber(db:get("Level1", 0));  
 	Level[2]=  tonumber(db:get("Level2", 0)); 	
	end
	
		 instance:updateFrom(0);  
		return core.ASYNC_REDRAW ;	
end 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+