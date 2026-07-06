-- More information about this indicator can be found at:
-- http://fxcodebase.com


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Micro Pivots");
    indicator:description("Micro Pivots");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Method One");
	indicator.parameters:addInteger("SF", "First Averege Period", "First Averege  Period", 20);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");

	
	indicator.parameters:addString("Type1", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addGroup("Method Two");
	indicator.parameters:addInteger("LF", "Second Averege Period", "Second Averege Period", 100);
	indicator.parameters:addString("Method2", "MA Method", " " , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");


	
	
	indicator.parameters:addString("Type2", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type2", "WEIGHTED", "", "weighted");
     
	
	indicator.parameters:addGroup("MA Line Style");			
    indicator.parameters:addColor("Short", "Color of Short", "Color of Short", core.rgb( 0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Long", "Color of Long", "Color of Long", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addGroup("Pivot Levels");	
	Add (11, -423.6)
	Add (10, -261.8)
	Add (1, -81.8 )
	Add (2, -27.1 )
    Add (3, 23.6 )
	Add (4, 38.5 )
	Add (5, 50)
	Add (6, 61.8)
	Add (7, 76.4 )
	Add (8, 127.2)
	Add (9, 161.8)
	Add (12, 261.8)
	Add (13, 423.6)
	
	indicator.parameters:addGroup("Label Style");	
	 indicator.parameters:addColor("Label", "Label Color", " ", core.rgb( 0, 0, 0));
	 indicator.parameters:addInteger("Size", "Font Size", "", 10);
end

function Add(id, Level)


   indicator.parameters:addGroup(id.. ". Level");	

    indicator.parameters:addBoolean("On"..id , "Show " .. id .."   Line", "", true);	
   indicator.parameters:addDouble("Level"..id , "Level"  , "",  Level);	
   indicator.parameters:addColor("Color".. id, "Line Color", "Line Color", core.rgb( 128, 128, 128));
	indicator.parameters:addInteger("Width".. id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style".. id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style".. id, core.FLAG_LINE_STYLE);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Color={};
local Style={};
local Width={};
local Level={};
local On={};
local ShortFrame=nil;
local LongFrame=nil;
local Method1=nil;
local Method2=nil;

local first;
local source = nil;

-- Streams block
local LongDATA = nil;
local ShortDATA = nil;
local Line={};
local Type1;
local Type2;
local Label, Size;
local Short, Long;
local font;
-- Routine
function Prepare(nameOnly)

    local i;
	Label=instance.parameters.Label;
	Size=instance.parameters.Size;

	Type1=instance.parameters.Type1;
	Type2=instance.parameters.Type2;    
    ShortFrame = instance.parameters.SF;
    LongFrame = instance.parameters.LF;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
   font = core.host:execute("createFont", "Courier", Size, true, false);

	
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame.. ", " .. Method1.. ", ".. Method2  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	LongDATA= core.indicators:create(Method1, source[Type1], ShortFrame);	
	ShortDATA= core.indicators:create(Method2, source[Type2], LongFrame);
	
	
	first = math.max(ShortDATA.DATA:first(),LongDATA.DATA:first());
	
	
	
	
	for i = 1, 13 , 1 do
	On[i]=instance.parameters:getBoolean("On" .. i);
	Style[i]=instance.parameters:getInteger("Style" .. i);
	 Width[i]=instance.parameters:getInteger("Width" .. i);
	Color[i]=instance.parameters:getDouble("Color" .. i);
	Level[i]=instance.parameters:getDouble("Level" .. i);
	
		if On[i] then
		Line[i]=instance:addStream("Line".. i, core.Line, name, i..  ". Line", Color[i], first);
		Line[i]:setWidth(Width[i]);
		Line[i]:setStyle(Style[i]);		
		end
	end
	
	
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install "..Method1..  " indicator");
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install "..Method2..  " indicator");


    
  
   
   Short=instance:addStream("Short", core.Line, name, "Short",instance.parameters.Short, first);
   Long=instance:addStream("Long", core.Line, name, "Long", instance.parameters.Long, first);
   Short:setWidth(instance.parameters.width1);
   Short:setStyle(instance.parameters.style1);
	Long:setWidth(instance.parameters.width2);
    Long:setStyle(instance.parameters.style2);
     	
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
       
	    local Delta;
	
	    LongDATA:update(mode);
		ShortDATA:update(mode);
		
		
		
		  if period < first  then
		  return;
		  end
		
		Short[period] = ShortDATA.DATA[period];
	    Long[period] = LongDATA.DATA[period];
		
		Delta= math.abs( Short[period]-Long [period])/ 100;
		
		
		local i;
		
		for i = 1, 13, 1 do
		
			if On[i] then			
				if Short[period]< Long[period] then
				Line[i][period]= Short[period] + Delta* Level[i];
					if period == source:size()-1 then
					core.host:execute("drawLabel1", i,  source:date(period), core.CR_CHART, Line[i][period], core.CR_CHART, core.H_Right, core.V_Bottom, font, Label, Line[i][period] .. " -  (" .. Level[i] .. ")");
					end
				else
				Line[i][period]= Short[period] - Delta* Level[i];
				     if period == source:size()-1 then
					core.host:execute("drawLabel1", i,  source:date(period), core.CR_CHART, Line[i][period], core.CR_CHART, core.H_Right, core.V_Bottom, font, Label, Line[i][period] .. " - (" .. Level[i] .. ")" );
					end
				end
				
				
			end
		
		end
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
end