
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2799

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


function Init()
    indicator:name("ADR Projection");
    indicator:description("ADR Projection");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	   
	
	indicator.parameters:addGroup("ADR Calculation");
    indicator.parameters:addInteger("N", "ADR Periods", "", 14);
	
	indicator.parameters:addString("Type", "Projection Type", "", "ADR");
    indicator.parameters:addStringAlternative("Type", "ADR", "", "ADR");
    indicator.parameters:addStringAlternative("Type", "ATR", "", "ATR");
	
	indicator.parameters:addBoolean("SHOW", "Show Projection", "", true);
	indicator.parameters:addBoolean("Label", "Show Label", "", true);
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local ArrowSize;
local source;
local ADR=nil;
local Type;
local N;
local M;
local D;
local SHOW;
local color;
local Label;
local host;
local first;
local DR,TR;
local size;
local width, style;

function Prepare(nameOnly)  
    color=instance.parameters.color;
    SHOW=instance.parameters.SHOW; 
    ArrowSize=instance.parameters.ArrowSize;  
	Type=instance.parameters.Type;
	Label=instance.parameters.Label;
    N=instance.parameters.N;	
	width=instance.parameters.width;
	style=instance.parameters.style;
    local name =  profile:id() .. ","  .. instance.source:name() ;
	instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
    source = instance.source;
	first= source:first()+N;
    host = core.host;
	
	local s, e;
    s,e	= core.getcandle(source:barSize(), 0, 0, 0);
	size = e-s;
	
	if source:pipSize() == 0.0001 then
	M =10000; 
	D= 4;
	else
	M=100;
	D=2;
	end
	
	
	if Type == "ADR" then 	
	DR = instance:addInternalStream (first, 0);
	ADR=  core.indicators:create("MVA", DR, N);
	else
	TR = instance:addInternalStream (first, 0);
	ADR=  core.indicators:create("ATR", source, N);
	end
   	
	
end

local MAX,MIN;

function Update(period, mode)

    if    period < source:size()-1 then
    return;
    end	
		
 
        if Type == "ADR" then 
		DR[period]= source.high[period] - source.low[period];
		else
		TR[period]=TrueRange(period);
        end		
		
		if not period == source:size()-1  then
		return;
		end
		
		ADR:update(mode);	
	  
		if not ADR.DATA:hasData(period)  and not ADR.DATA:hasData(period-1)then
		return;
		end					
		
	    MAX = source.low[period] +  ADR.DATA[period];
		MIN = source.high[period] -  ADR.DATA[period]; 
	
		if Label then 
			if Type == "ADR" then  	
			if DR[period] >DR[period-1] then
			core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5  , "DR "..tostring( round( DR[period]* M ,0)).." (+)" ); 
			elseif  DR[period] < DR[period-1] then
			core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5 , "DR "..tostring( round( DR[period]* M ,0)) .." (-)" ); 
			else
			core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5 , "DR "..tostring( round( DR[period]* M ,0)) .." (0)" ); 
			end
			
			if ADR.DATA[period] >ADR.DATA[period-1] then
			core.host:execute ("drawLabel", 2, source:date(source:size()-1) + 3*size,  MAX + (MAX-MIN)/5 , "ADR "..tostring(round( ADR.DATA[period]* M,0))  .." (+)");
			elseif  ADR.DATA[period] < ADR.DATA[period-1] then
			core.host:execute ("drawLabel", 2, source:date(source:size()-1) + 3*size,  MAX + (MAX-MIN)/5 , "ADR "..tostring(round( ADR.DATA[period]* M,0))  .." (-)");
			else
			core.host:execute ("drawLabel", 2, source:date(source:size()-1) + 3*size,  MAX + (MAX-MIN)/5 , "ADR "..tostring(round( ADR.DATA[period]* M,0))  .." (0)");
			end		
			
			core.host:execute ("drawLabel", 3, source:date(source:size()-1) + 3*size, MAX  , "ADR Projections Up "..tostring(round(source.low[period] +  ADR.DATA[period], D) )); 
			core.host:execute ("drawLabel", 4, source:date(source:size()-1) + 3*size, MIN  , "ADR Projections Down "..tostring(round( source.high[period] -  ADR.DATA[period], D) )); 
			else
			
			if TR[period] >TR[period-1] then
			core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5  , "TR "..tostring( round( TR[period]* M,0)).. " (+)" ); 
			elseif  TR[period] < TR[period-1] then
			core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5  , "TR "..tostring( round( TR[period]* M,0)) .." (-)" ); 
			else
			core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5 , "TR "..tostring( round( TR[period]* M,0)) .." (0)" ); 
			end
			
			if ADR.DATA[period] >ADR.DATA[period-1] then
			core.host:execute ("drawLabel", 2, source:date(source:size()-1) + 3*size, MAX + (MAX-MIN)/5 , "ATR "..tostring(round( ADR.DATA[period] *M, 0)).. " (+)" );
			elseif  ADR.DATA[period] < ADR.DATA[period-1] then
			core.host:execute ("drawLabel", 2, source:date(source:size()-1) + 3*size, MAX + (MAX-MIN)/5 , "ATR "..tostring(round( ADR.DATA[period] *M, 0)).. " (-)" );
			else
			core.host:execute ("drawLabel", 2, source:date(source:size()-1) + 3*size,  MAX + (MAX-MIN)/5 , "ATR "..tostring(round( ADR.DATA[period] *M, 0)).. " (0)" );
			end
			
			core.host:execute ("drawLabel", 3, source:date(source:size()-1) + 3*size, source.low[period] +  ADR.DATA[period]  , "ATR Projections Up "..tostring(round( source.low[period] +  ADR.DATA[period], D)) ); 
			core.host:execute ("drawLabel", 4, source:date(source:size()-1) + 3*size, source.high[period] -  ADR.DATA[period]  , "ATR Projections Down "..tostring(round( source.high[period] -  ADR.DATA[period], D)) ); 
			end		
		end	
		if SHOW then
		 core.host:execute ("drawLine", 5,  source:date(source:size()-1-N), MAX, source:date(source:size()-1), source.low[period] +  ADR.DATA[period], color, style, width, string.format("%." .. 2 .. "f", MAX));
		 core.host:execute ("drawLine", 6, source:date(source:size()-1-N), MIN, source:date(source:size()-1), source.high[period] -  ADR.DATA[period],  color, style, width, string.format("%." .. 2 .. "f",MIN));
	    end
 
		
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function TrueRange(p)
    local hl = math.abs(source.high[p] - source.low[p]);
    local hc = math.abs(source.high[p] - source.close[p - 1]);
    local lc = math.abs(source.low[p] - source.close[p - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

