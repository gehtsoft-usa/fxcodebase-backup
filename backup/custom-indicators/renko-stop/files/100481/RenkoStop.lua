-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62223

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
    indicator:name("Renko Stop");
    indicator:description("Renko Stop");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("decay", "Decay", "Decay", 250);
    indicator.parameters:addInteger("detection", "Detection", "Detection", 1);
    indicator.parameters:addInteger("smooth", "Smooth", "Smooth", 2);
	indicator.parameters:addInteger("rma_smooth", "RMA Smooth", "RMA Smooth", 12);
	
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local decay;
local detection;
local smooth;

local first;
local source = nil;

-- Streams block
local topfill = nil;
local botfill = nil;
local smoothprice, rma;
local dosc;
local rma_smooth;
local Up, Down;
local Color;
-- Routine
function Prepare(nameOnly)
   
    detection = instance.parameters.detection;
    smooth = instance.parameters.smooth;
	rma_smooth= instance.parameters.rma_smooth;
    source = instance.source;
    first = source:first()+detection;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	
	decay = instance.parameters.decay*source:pipSize();
	dosc= instance:addInternalStream(source:first(), 0);
	smoothprice= instance:addInternalStream(source:first()+smooth, 0);
	Color= instance:addInternalStream(source:first(), 0);
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(decay) .. ", " .. tostring(detection) .. ", " .. tostring(smooth) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	    rma= instance:addInternalStream(source:first(), 0);
        topfill = instance:addStream("topfill", core.Line, name .. ".topfill", "topfill", Up, math.max(detection, smooth,rma_smooth));
        botfill = instance:addStream("botfill", core.Line, name .. ".botfill", "botfill", Up, math.max(detection, smooth,rma_smooth));
		instance:createChannelGroup("Channel", "Channel", topfill, botfill, Up, 100 - instance.parameters.transparency);

    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or  not  source:hasData(period) then
	return;
	end
	ll, hh= mathex.minmax(source, period-detection+1, period); 
	
	
	local rprice= round(source.close[period]/decay, 0)*decay;
    local predosc= dosc[period-1]; 
	
	if hh > predosc + decay and hh+decay < predosc + decay  then
	dosc[period]= predosc + decay ;
	elseif hh > predosc + decay and hh+decay > predosc + decay  then
	dosc[period]=  rprice ;
	elseif ll < predosc - decay and ll-decay > predosc - decay then 
	dosc[period]= predosc - decay;
    elseif   ll < predosc - decay and ll-decay < predosc - decay then 
	dosc[period]= rprice;
    else
	dosc[period]= predosc;
	end
 
	
	if period < rma_smooth 
	or period < smooth 
	then
	return;
	end
	
	smoothprice[period] =  mathex.avg(source.close, period-smooth +1, period); 
	rma[period]= mathex.avg(dosc, period-rma_smooth+1, period);
	
	Color[period]=Color[period-1];

	if (smoothprice[period] >  rma[period] and smoothprice[period-1] <=  rma[period-1] )
	or (smoothprice[period] <  rma[period] and smoothprice[period-1] >=  rma[period-1] )
	then
	 
	   if source.close[period] > rma[period] then
	   Color[period]=1;
	   elseif source.close[period] < rma[period] then
	   Color[period]=-1;
	   end
	   
	   
	end
	
	if Color[period]== 1 then
	topfill:setColor(period, Up);
	botfill:setColor(period, Up);
	elseif Color[period]== -1 then 
	topfill:setColor(period, Down);
	botfill:setColor(period, Down);
	end
	

        topfill[period] = math.max(smoothprice[period], rma[period]);
        botfill[period] = math.min(smoothprice[period], rma[period]);
    
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end
