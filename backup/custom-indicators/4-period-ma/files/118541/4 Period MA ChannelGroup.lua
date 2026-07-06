-- Id: 20983
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65888

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
    indicator:name("4 Period MA");
    indicator:description("4 Period MA");
    indicator:requiredSource(core.Bar);
	indicator:type(core.Indicator);   	
    local i;	 
	
	 			
			local LENGHT={5,10,15, 20};
  
			
			for i =1 , 4 , 1 do 
			indicator.parameters:addGroup("MA ".. i);
			indicator.parameters:addBoolean("Flag"..i, "Show First", "", true);
			indicator.parameters:addInteger("F"..i, "Period", "", LENGHT[i]);
 
			indicator.parameters:addString("M"..i , "Method for avegage", "", "MVA");
            indicator.parameters:addStringAlternative("M"..i , "MVA", "", "MVA");
            indicator.parameters:addStringAlternative("M"..i, "EMA", "", "EMA");
            indicator.parameters:addStringAlternative("M"..i , "LWMA", "", "LWMA");
			indicator.parameters:addStringAlternative("M"..i, "TMA", "", "TMA");
			indicator.parameters:addStringAlternative("M"..i, "SMMA*", "", "SMMA");
			indicator.parameters:addStringAlternative("M"..i, "Vidya (1995)*", "", "VIDYA");
			indicator.parameters:addStringAlternative("M"..i, "Vidya (1992)*", "", "VIDYA92");
			indicator.parameters:addStringAlternative("M"..i, "Wilders*", "", "WMA");
			
			indicator.parameters:addString("IN"..i, "Price Source", "", "close");
			indicator.parameters:addStringAlternative("IN"..i, "OPEN", "", "open");
			indicator.parameters:addStringAlternative("IN"..i, "HIGH", "", "high");
			indicator.parameters:addStringAlternative("IN"..i, "LOW", "", "low");
			indicator.parameters:addStringAlternative("IN"..i,"CLOSE", "", "close");
			indicator.parameters:addStringAlternative("IN"..i, "MEDIAN", "", "median");
			indicator.parameters:addStringAlternative("IN"..i, "TYPICAL", "", "typical");
			indicator.parameters:addStringAlternative("IN"..i, "WEIGHTED", "", "weighted");	
			
			
			 
			indicator.parameters:addGroup("MA ".. i .. " Style");
			indicator.parameters:addInteger("Width"..i,"Width", "", 1, 1, 5);
            indicator.parameters:addInteger("Style"..i, "Style", "", core.LINE_SOLID);
            indicator.parameters:setFlag("Style"..i, core.FLAG_LINE_STYLE);
			
				if i==1 then
				indicator.parameters:addColor("S"..i.."_color", "Color of " .. i .. " MVA", "", core.rgb( 0 ,255, 0));
				elseif i==2 then
				indicator.parameters:addColor("S"..i.."_color", "Color of " .. i .. " MVA", "", core.rgb( 255 ,0, 0));
				elseif i==3 then
				indicator.parameters:addColor("S"..i.."_color", "Color of " .. i .. " MVA", "", core.rgb( 0 ,0, 255));
				elseif i==4 then			
				indicator.parameters:addColor("S"..i.."_color", "Color of " .. i .. " MVA", "", core.rgb( 128 ,128, 128));			
				end
	        end
			
			
	        local Array={};
			Array[1]={1,2}; 
			Array[2]={1,3}; 
			Array[3]={1,4}; 
			Array[4]={2,3}; 
			Array[5]={2,4}; 
			Array[6]={3,4}; 		
			
			indicator.parameters:addGroup("ChannelGroup Style ");
			
			
			indicator.parameters:addInteger("Transparency", "Transparency", "Transparency", 80, 0, 100);
			for i =1 , 6 , 1 do   
			indicator.parameters:addColor("ColorUp"..i, "Color of " .. Array[i][1] .. " / " .. Array[i][2] .. " Up", "", core.rgb( 0 ,255, 0));
			indicator.parameters:addColor("ColorDown"..i,  "Color of " .. Array[i][1] .. " / " .. Array[i][2] .. " Down", "", core.rgb( 255 ,0, 0));
			end
			
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local F={};
local Color={};
local Flag={};
local M={};
local IN={};
local Style={};
local Width={};

local first;
local source = nil;

local Array={};
Array[1]={1,2}; 
Array[2]={1,3}; 
Array[3]={1,4}; 
Array[4]={2,3}; 
Array[5]={2,4}; 
Array[6]={3,4}; 

local ColorUp={};
local ColorDown={};

local Top={};
local Bottom={};
-- Streams block
local S = {};
local Row = {};

local Transparency;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    source = instance.source;
    first = source:first();
     
	 
    Transparency= 100 - instance.parameters.Transparency;
	
	local i;
    
    for i = 1, 4, 1 do 
	F[i]= instance.parameters:getInteger("F" .. i);
	Color[i]= instance.parameters:getColor("S".. i.."_color");
	Flag[i]= instance.parameters:getBoolean("Flag".. i);
	M[i]= instance.parameters:getString("M".. i);
	IN[i]= instance.parameters:getString("IN".. i);
	Style[i]=instance.parameters:getInteger("Style".. i);
    Width[i]=instance.parameters:getInteger("Width".. i);
	 assert(core.indicators:findIndicator(M[i]) ~= nil, "Please download and install ".. M[i] .." Indicator!");
	end	
	
	for i = 1, 4, 1 do
	 
    assert(core.indicators:findIndicator(M[i]) ~= nil, M[i] .. " indicator must be installed");
		Row[i]=core.indicators:create(M[i],  source[IN[i]], F[i]);
		
		
		 first = math.max(first, Row[i].DATA:first());
		 
	end
 
	
	for i = 1 , 4 do
		if Flag[i] then
		S[i] = instance:addStream("S".. i , core.Line, name .. ".S"..i, F[i]..", ".. M[i], Color[i],  Row[i].DATA:first());
		S[i]:setWidth(Width[i]);
        S[i]:setStyle(Style[i]);
		end
	end
    
	for i = 1 , 6 do
	 Top[i]= instance:addInternalStream(0,0);
	 Bottom[i]= instance:addInternalStream(0,0);
	 instance:createChannelGroup(Array[i][1].."/" .. Array[i][2], Array[i][1].."/" .. Array[i][2], Top[i], Bottom[i], core.rgb( 128 ,128, 128), Transparency);	 
	 
     ColorUp[i]=instance.parameters:getColor("ColorUp".. i);
     ColorDown[i]=instance.parameters:getColor("ColorDown".. i);
	end 
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period <first or  not  source:hasData(period) then
	return;
	end
	
	 
	local i;
	
	
			for i = 1 , 4 do 	
				  if Flag[i] then
						if period >= F[i]   then 
						Row[i]:update(mode);
						      if Row[i].DATA:hasData(period) then
						      S[i][period] = Row[i].DATA[period];
							  end
						end
				  end	 
			end
			
			
			for i= 1 , 6, 1 do
			 Top[i][period]=   S[Array[i][1]][period];
	          Bottom[i][period]=   S[Array[i][2]][period];
			  
			  if S[Array[i][1]][period]>  S[Array[i][2]][period] then
			   Top[i]:setColor(period, ColorUp[i]);
			  else 
			  Top[i]:setColor(period, ColorDown[i]);
			  end
			  
			end
   

end