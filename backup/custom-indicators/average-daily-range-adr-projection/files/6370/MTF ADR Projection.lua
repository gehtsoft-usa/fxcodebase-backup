
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
    indicator:name("MTF ADR Projection");
    indicator:description("MTF ADR Projection");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	   
	
	indicator.parameters:addGroup("ADR Calculation");
    indicator.parameters:addInteger("N", "ADR Periods", "", 14);
	
	 
    indicator.parameters:addString("TF", "ATR Time Frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	
	
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
local N;
local M;
local D;
local TF;
local SHOW;
local color;

local host;
local first;
local TR={};
local size;
  
local day_offset;
local week_offset; 
local width, style,Label;
local loading, Source;
function Prepare(nameOnly)  

    source = instance.source;
	first= source:first();
    host = core.host;
	width=instance.parameters.width;
	style=instance.parameters.style;
    color=instance.parameters.color;
	Label=instance.parameters.Label;
    SHOW=instance.parameters.SHOW; 
    ArrowSize=instance.parameters.ArrowSize;  	
    N=instance.parameters.N;	
	TF=instance.parameters.TF;
    local name =  profile:id() .. ","  .. instance.source:name() ;
	instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), N, 100, 101);
	loading=true;
	ADR = core.indicators:create("ATR", Source, N);
     
	
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
end

local MAX,MIN;

function Update(period, mode)

    if    period < source:size()-1 then  
    return;
    end     
	
	if Source.close:size()-1 < 2 then
    return;
    end	
	          
				TR[1]= TrueRange(0);  
				TR[2]= TrueRange(1);
			 
				 
				ADR:update(mode);	
			  
				if not ADR.DATA:hasData(ADR.DATA:size()-1)  and not ADR.DATA:hasData(ADR.DATA:size()-2)then
				return;
				end					
				
				MAX = Source.low[Source:size()-1] +  ADR.DATA[ADR.DATA:size()-1];
				MIN = Source.high[Source:size()-1] -  ADR.DATA[ADR.DATA:size()-1]; 
			
				 local s, e;
				    s, e = core.getcandle(TF, core.now(), 0, 0);
                if Label then
				
					if TR[1] >TR[2] then
					core.host:execute ("drawLabel", 1, e + 3*size , MAX + 2*(MAX-MIN)/5  , "TR "..tostring( round( TR[1]* M,0)).. " (+)" ); 
					elseif  TR[1] < TR[2] then
					core.host:execute ("drawLabel", 1, e + 3*size , MAX + 2*(MAX-MIN)/5  , "TR "..tostring( round( TR[1]* M,0)) .." (-)" ); 
					else
					core.host:execute ("drawLabel", 1, e + 3*size , MAX + 2*(MAX-MIN)/5 , "TR "..tostring( round( TR[1]* M,0)) .." (0)" ); 
					end
					
					if ADR.DATA[ADR.DATA:size()-1] >ADR.DATA[ADR.DATA:size()-2] then
					core.host:execute ("drawLabel", 2, e + 3*size, MAX + (MAX-MIN)/5 , "ATR "..tostring(round( ADR.DATA[ADR.DATA:size()-1] *M, 0)).. " (+)" );
					elseif  ADR.DATA[ADR.DATA:size()-1] < ADR.DATA[ADR.DATA:size()-2] then
					core.host:execute ("drawLabel", 2, e + 3*size, MAX + (MAX-MIN)/5 , "ATR "..tostring(round( ADR.DATA[ADR.DATA:size()-1] *M, 0)).. " (-)" );
					else
					core.host:execute ("drawLabel", 2, e + 3*size,  MAX + (MAX-MIN)/5 , "ATR "..tostring(round( ADR.DATA[ADR.DATA:size()-1] *M, 0)).. " (0)" );
							
					end		
					
					core.host:execute ("drawLabel", 3, e + 3*size, Source.low[Source:size()-1] +  ADR.DATA[ADR.DATA:size()-1]  , "ATR Projections Up "..tostring(round( Source.low[Source:size()-1] +  ADR.DATA[ADR.DATA:size()-1], D)) ); 
			    	core.host:execute ("drawLabel", 4, e + 3*size, Source.high[Source:size()-1] -  ADR.DATA[ADR.DATA:size()-1]  , "ATR Projections Down "..tostring(round( Source.high[Source:size()-1] -  ADR.DATA[ADR.DATA:size()-1], D)) ); 
				end
				
				
				
				
				if SHOW then
				 core.host:execute ("drawLine", 5,  s, MAX, e, Source.low[Source:size()-1] +  ADR.DATA[ADR.DATA:size()-1], color, style, width, string.format("%." .. 2 .. "f", MAX));
				 core.host:execute ("drawLine", 6, s, MIN, e, Source.high[Source:size()-1] -  ADR.DATA[ADR.DATA:size()-1], color, style, width, string.format("%." .. 2 .. "f", MIN));	
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
    local hl = math.abs(Source.high[Source:size()-1-p] - Source.low[Source:size()-1-p]);
    local hc = math.abs(Source.high[Source:size()-1-p] - Source.close[Source:size()-2-p ]);
    local lc = math.abs(Source.low[Source:size()-1-p] - Source.close[Source:size()-2-p]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end
