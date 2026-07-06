-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2356&hilit=round

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
    indicator:name("FIGURE");
    indicator:description("FIGURE");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	local i=1;	
	
	indicator.parameters:addGroup(i..". Level Parametars");	
	indicator.parameters:addBoolean("L"..i, "Show "..i..". Level Lines ", "", true);
	indicator.parameters:addInteger("LW"..i, i..". Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS"..i, i..". level Line Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("LS"..i, core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("LC"..i, "Color of "..i..". Level Lines", "", core.rgb(255, 0, 0));
	i=2;
	indicator.parameters:addGroup(i..". Level Parametars");	
	indicator.parameters:addBoolean("L"..i, "Show "..i..". Level Lines ", "", true);
	indicator.parameters:addInteger("LW"..i, i..". Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS"..i, i..". level Line Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("LS"..i, core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("LC"..i, "Color of "..i..". Level Lines", "", core.rgb(255, 0, 0))
	i=3;
	indicator.parameters:addGroup(i..". Level Parametars");	
	indicator.parameters:addBoolean("L"..i, "Show "..i..". Level Lines ", "", true);
	indicator.parameters:addInteger("LW"..i, i..". Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS"..i, i..". level Line Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("LS"..i, core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("LC"..i, "Color of "..i..". Level Lines", "", core.rgb(255, 0, 0))
	i=4;
	indicator.parameters:addGroup(i..". Level Parametars");	
	indicator.parameters:addBoolean("L"..i, "Show "..i..". Level Lines ", "", false);
	indicator.parameters:addInteger("LW"..i, i..". Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS"..i, i..". level Line Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("LS"..i, core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("LC"..i, "Color of "..i..". Level Lines", "", core.rgb(255, 0, 0))
	
	i=5;
	indicator.parameters:addGroup(i..". Level Parametars");	
	indicator.parameters:addBoolean("L"..i, "Show "..i..". Level Lines ", "", false);
	indicator.parameters:addInteger("LW"..i, i..". Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS"..i, i..". level Line Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("LS"..i, core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("LC"..i, "Color of "..i..". Level Lines", "", core.rgb(255, 0, 0))
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local LC={};
local L={};
local LW={};
local LS={};

local MAX;
local STEPS;
local FLAG=true;
local ON =nil;

-- Routine
function Prepare(nameOnly)  


    local i;
	
	for i=1, 5, 1 do
    LC[i] = instance.parameters:getColor("LC"..i);	
	L[i] = instance.parameters:getBoolean("L"..i);	
	LS[i] = instance.parameters:getInteger("LS"..i);
	LW[i] = instance.parameters:getInteger("LW"..i);
	end

	
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() ..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period == source:size()-1 and source:hasData(period) then
	
	   LEVELS(period);
        
    end
end

function LEVELS(p)

local i;
        
		if FLAG then
		FLAG = false;
		 MAX=round(source[p], 0);
		 
				 if MAX > 10 then
				 STEPS= MAX*2 /0.1;
				 else
				  STEPS= MAX*2 /0.001;
				end
		end
		
		for i = 1 , STEPS,1 do			
		
		ON =nil;
		
		 if MAX > 10 then
		 
		    Level=i*0.1;
		 
  		    if   L[5] and(Level % 1)==0 then
			ON=5;
			end
			
		    if   L[4]and (Level % 5)==0  then
			ON=4;
			end
			
		    if    L[3]and(Level % 10)==0 then
			ON=3;
			end
			
			if  L[2] and(Level % 50)==0    then
			ON=2;
			end
		
			if   L[1]and (Level % 100)==0  then
			ON=1;
			end
		else		
		    
			Level=i*0.001;

--			if (Level % 0.01)==0 and L[5] then
			if  L[5] and modulo(Level, 0.01)==0  then
			ON=5;
			end
			
--		    if (Level % 0.05)==0  and L[4] then
			if  L[4]  and modulo(Level, 0.05)==0  then
			ON=4;
			end
			
--		    if (Level % 0.1)==0  and L[3] then
			if  L[3] and modulo(Level, 0.1)==0  then
            ON=3;
			end
			
--			if (Level % 0.5)==0  and L[2] then
			if  L[2] and modulo(Level, 0.5)==0  then
			ON=2;
			end
		
--			if (Level % 1)==0  and L[1] then
			if  L[1]  and modulo(Level, 1)==0  then
			ON=1;
			end
			 
        end		
		
			if ON ~=nil then
			core.host:execute("drawLine", i, source:date(first),Level, source:date(p), Level, LC[ON],LS[ON], LW[ON]);
					if Level > 2*source[p]  then
					break;
					end
			end		
		end     

end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function modulo(dividend, divisor)
    local dd = 0;
    local dc = 0;
    local fl = 0;
    local rc = 0;
    local rt = 0;
    local ra = 0;
    local rf = 0;

    dd = dividend / divisor;
    dc = dd + 0.1; 
    fl = math.floor(dc);

    rt = fl * divisor;
    rc = dividend - rt;

    if rc < 0 then
        ra = math.abs(rc);

        rf = math.floor(ra * 10^6 + 0.5) / 10^6;
    else
        rf = rc;
    end

    return rf
end
