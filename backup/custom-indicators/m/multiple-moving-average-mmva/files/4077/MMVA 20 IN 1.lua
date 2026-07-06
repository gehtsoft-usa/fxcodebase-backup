-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1939

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("Multiple Moving Average 20 IN 1");
    indicator:description("Multiple Moving Average 20 IN 1");
    indicator:requiredSource(core.Bar);
	indicator:type(core.Indicator);   	
    local i;	 
	
	 			
			local LENGHT={5,10,15, 20, 25, 50,100, 150, 200,250}
			local B={16,32,64, 128, 255,128,64,32,16,8}
			
			local R=0;
			local G=255;
			local Step=0; 
			
			for i =1 , 10 , 1 do 
			indicator.parameters:addGroup("MA ".. i);
			indicator.parameters:addBoolean("Flag"..i, "Show First", "", true);
			indicator.parameters:addInteger("F"..i, "Period", "", LENGHT[i]);
			indicator.parameters:addInteger("Look"..i, "Look Back Period", "", LENGHT[i]);
			indicator.parameters:addString("M"..i, "Method", "", "MVA");
			indicator.parameters:addStringAlternative("M"..i, "MVA", "", "MVA");
			indicator.parameters:addStringAlternative("M"..i, "EMA", "", "EMA");
			indicator.parameters:addStringAlternative("M"..i, "Wilder", "", "Wilder");
			indicator.parameters:addStringAlternative("M"..i, "LWMA", "", "LWMA");
			indicator.parameters:addStringAlternative("M"..i, "SineWMA", "", "SineWMA");
			indicator.parameters:addStringAlternative("M"..i, "TriMA", "", "TriMA");
			indicator.parameters:addStringAlternative("M"..i, "LSMA", "", "LSMA");
			indicator.parameters:addStringAlternative("M"..i, "SMMA", "", "SMMA");
			indicator.parameters:addStringAlternative("M"..i, "HMA", "", "HMA");
			indicator.parameters:addStringAlternative("M"..i, "ZeroLagEMA", "", "ZeroLagEMA");
			indicator.parameters:addStringAlternative("M"..i, "DEMA", "", "DEMA");
			indicator.parameters:addStringAlternative("M"..i, "T3", "", "T3");
			indicator.parameters:addStringAlternative("M"..i, "ITrend", "", "ITrend");
			indicator.parameters:addStringAlternative("M"..i, "Median", "", "Median");
			indicator.parameters:addStringAlternative("M"..i, "GeoMean", "", "GeoMean");
			indicator.parameters:addStringAlternative("M"..i, "REMA", "", "REMA");
			indicator.parameters:addStringAlternative("M"..i, "ILRS", "", "ILRS");
			indicator.parameters:addStringAlternative("M"..i, "IE/2", "", "IE/2");
			indicator.parameters:addStringAlternative("M"..i, "TriMAgen", "", "TriMAgen");
			indicator.parameters:addStringAlternative("M"..i, "JSmooth", "", "JSmooth");
			indicator.parameters:addInteger("IN"..i , "Data Source", "", 4);
            indicator.parameters:addIntegerAlternative("IN"..i , "Open", "", 1);
            indicator.parameters:addIntegerAlternative("IN"..i, "High", "", 2);
            indicator.parameters:addIntegerAlternative("IN"..i , "Low", "", 3);
			indicator.parameters:addIntegerAlternative("IN"..i , "Close", "", 4);
			indicator.parameters:addIntegerAlternative("IN"..i, "Median", "", 5);
            indicator.parameters:addIntegerAlternative("IN"..i , "Typical", "", 6);
			indicator.parameters:addIntegerAlternative("IN"..i , "Weighted ", "", 7);
			
			
			R=R+Step;
			G= G-Step;
				
			Step= 255/10;
			indicator.parameters:addGroup("MA ".. i .. " Style");
			indicator.parameters:addInteger("Width"..i,"Width", "", 1, 1, 5);
            indicator.parameters:addInteger("Style"..i, "Style", "", core.LINE_SOLID);
            indicator.parameters:setFlag("Style"..i, core.FLAG_LINE_STYLE);
			indicator.parameters:addColor("S"..i.."_color", "Color of " .. i .. " MVA", "", core.rgb( R ,G, B[i]));
			end
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local F={};
local Look = {};
local Color={};
local Flag={};
local M={};
local IN={};
local Style={};
local Width={};

local first;
local source = nil;

-- Streams block
local S = {};
local Row = {};

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    source = instance.source;
    first = source:first();
     
	local i;
    
    for i = 1, 10, 1 do
   	Look[i] = instance.parameters:getInteger("Look" .. i);	
	F[i]= instance.parameters:getInteger("F" .. i);
	Color[i]= instance.parameters:getColor("S".. i.."_color");
	Flag[i]= instance.parameters:getBoolean("Flag".. i);
	M[i]= instance.parameters:getString("M".. i);
	IN[i]= instance.parameters:getInteger("IN".. i);
	Style[i]=instance.parameters:getInteger("Style".. i);
    Width[i]=instance.parameters:getInteger("Width".. i);
	 assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please download and install AVERAGES Indicator!");
	end	
	
	for i = 1, 10, 1 do
		if IN[i]== 1 then
		Row[i]=core.indicators:create("AVERAGES",  source.open, M[i], F[i], false);
		elseif  IN[i]== 2 then
		Row[i]=core.indicators:create("AVERAGES",  source.high, M[i], F[i], false);
		elseif  IN[i]== 3 then
		Row[i]=core.indicators:create("AVERAGES",  source.low, M[i], F[i], false);
		elseif  IN[i]== 4 then
		Row[i]=core.indicators:create("AVERAGES",  source.close, M[i], F[i], false);
		elseif  IN[i]== 5 then
		Row[i]=core.indicators:create("AVERAGES",  source.median, M[i], F[i], false);
		elseif  IN[i]== 6 then
		Row[i]=core.indicators:create("AVERAGES",  source.typical, M[i], F[i], false);
		elseif  IN[i]== 7 then
		Row[i]=core.indicators:create("AVERAGES",  source.weighted, M[i], F[i], false);
		end
	end
 
	
	for i = 1 , 10 do
		if Flag[i] then
		S[i] = instance:addStream("S".. i , core.Line, name .. ".S"..i, F[i]..", ".. Look[i]..", ".. M[i], Color[i], F[i]);
		S[i]:setWidth(Width[i]);
        S[i]:setStyle(Style[i]);
		end
	end
    
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period >= first and source:hasData(period) then
	local last=source:size()-1 ;
	local i;
	
	
			for i = 1 , 10 do 	
				  if Flag[i] then
						if period >= F[i] and  period >= last - Look[i]  then 
						Row[i]:update(mode);
						      if Row[i].DATA:hasData(period) then
						      S[i][period] = Row[i].DATA[period];
							  end
						end
				  end	 
			end
    end

end