-- Id: 7180
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22630

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Wyckoff PV Histogram");
    indicator:description("Wyckoff PV Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Short Period", "Short Period", 5);
    indicator.parameters:addInteger("Period2", "Long Period", "Long Period", 15);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Short_color", "Color of Short", "Color of Short", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("swidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("sstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("sstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Long_color", "Color of Long", "Color of Long", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("lwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("lstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("lstyle", core.FLAG_LINE_STYLE);
	indicator.parameters:addBoolean("Show", "Show Histogram", "", false);
    indicator.parameters:addColor("Histogram_color", "Color of Histogram", "Color of Histogram", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
local Period2;
local Show;
local first;
local source = nil;

-- Streams block
local Short = nil;
local Long = nil;
local Histogram = nil;
local S,L;
local Out;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
	Show = instance.parameters.Show;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	     Histogram = instance:addInternalStream(0, 0);
		 
		 S= core.indicators:create("MVA",Histogram, Period1);
		 L= core.indicators:create("MVA",Histogram, Period2);
		 
		 first = math.max(S.DATA:first(), L.DATA:first());
		 if Show then 
		 Out = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Histogram_color, source:first()+1); 
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
		 else
		 Out = instance:addInternalStream(0, 0);
		 end 
        Short = instance:addStream("Short", core.Line, name .. ".Short", "Short", instance.parameters.Short_color, first);
    Short:setPrecision(math.max(2, instance.source:getPrecision()));
		Short:setWidth(instance.parameters.swidth);
        Short:setStyle(instance.parameters.sstyle);
        Long = instance:addStream("Long", core.Line, name .. ".Long", "Long", instance.parameters.Long_color, first);
    Long:setPrecision(math.max(2, instance.source:getPrecision()));
		Long:setWidth(instance.parameters.lwidth);
        Long:setStyle(instance.parameters.lstyle);
       
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
		
	local UDPC;
	local UDNC;
	local DDPC;
	local DDNC;
	local HVWS;
	local HVNS;
	local LVWS;
	local LVNS;
	
	--UDPC:=(C>=((H-L)*.5)+L) AND C>Ref(C,-1);
	if source.close[period]>= ((source.high[period]-source.low[period])*0.5 +source.low[period]) and source.close[period]> source.close[period-1]  then
	UDPC= true;
	else
	UDPC= false;
	end
	
	--UDNC:=(C<((H-L)*.5)+L) AND C>Ref(C,-1);	
	if source.close[period]< ((source.high[period]-source.low[period])*0.5 +source.low[period]) and source.close[period]> source.close[period-1]  then
	UDNC= true;
	else
	UDNC= false;
	end
	
	
	--DDPC:=(C>=((H-L)*.5)+L) AND C<Ref(C,-1);
	if source.close[period]>= ((source.high[period]-source.low[period])*0.5 +source.low[period]) and source.close[period]< source.close[period-1]  then
	DDPC= true;
	else
	DDPC= false;
	end
	
	
	--DDNC:=(C<((H-L)*.5)+L) AND C<Ref(C,-1);
	if source.close[period]< ((source.high[period]-source.low[period])*0.5 +source.low[period]) and source.close[period]< source.close[period-1]  then
	DDNC= true;
	else
	DDNC= false;
	end
	
	
	--HVWS:=((H-L)>=Ref((H-L),-1)) AND V>Ref(V,-1);
	if  (source.high[period]-source.low[period]) >= (source.high[period-1]-source.low[period]-1)  and source.volume[period] >  source.volume[period-1] then
	HVWS= true;
	else
	HVWS= false;
	end
	
	
	--HVNS:=((H-L)<Ref((H-L),-1)) AND V>Ref(V,-1);
    if  (source.high[period]-source.low[period]) < (source.high[period-1]-source.low[period]-1)  and source.volume[period] >  source.volume[period-1] then
	HVNS= true;
	else
	HVNS= false;
	end
	
	
	--LVWS:=((H-L)>=Ref((H-L),-1)) AND V<Ref(V,-1);
	if  (source.high[period]-source.low[period]) >= (source.high[period-1]-source.low[period]-1)  and source.volume[period] <  source.volume[period-1] then
	LVWS= true;
	else
	LVWS= false;
	end
	
	--LVNS:=((H-L)<Ref((H-L),-1)) AND V<Ref(V,-1);
	if  (source.high[period]-source.low[period]) < (source.high[period-1]-source.low[period]-1)  and source.volume[period] <  source.volume[period-1] then
	LVNS= true;
	else
	LVNS= false;
	end
	
	
	 Histogram[period]=0;
	 
	 if (UDPC and LVWS) then Histogram[period] = 8;
	 elseif(UDPC and HVWS) then Histogram[period] =7; 
	 elseif(UDPC and HVNS) then Histogram[period] =6; 
	 elseif(UDPC and LVNS) then Histogram[period] =5; 
	 elseif(UDNC and LVWS) then Histogram[period] =4; 
	 elseif(UDNC and HVWS) then Histogram[period] =3; 
	 elseif(UDNC and HVNS) then Histogram[period] =2; 
	 elseif(UDNC and LVNS) then Histogram[period] =1; 
	 elseif(DDPC and LVNS) then Histogram[period] =-1; 
	 elseif(DDPC and HVNS) then Histogram[period] =-2; 
	 elseif(DDPC and HVWS) then Histogram[period] =-3; 
	 elseif(DDPC and LVWS) then Histogram[period] =-4; 
	 elseif(DDNC and LVNS) then Histogram[period] =-5; 
	 elseif(DDNC and HVNS) then Histogram[period] =-6; 
	 elseif(DDNC and HVWS) then Histogram[period] =-7; 
	 elseif(DDNC and LVWS) then Histogram[period] =-8;
     else
	 Histogram[period] =0;
     end	
	 S:update(mode);
	 L:update(mode);
	 
	   Out[period] = Histogram[period] -Histogram[period-1];
	  
	  if period >= first and source:hasData(period) then	 
	--Mov(B,5,S);Mov(B,15,S);B-Ref(B,-1);]] 	   		 
        Short[period] = S.DATA[period];
        Long[period] = L.DATA[period];
       
    end
end

