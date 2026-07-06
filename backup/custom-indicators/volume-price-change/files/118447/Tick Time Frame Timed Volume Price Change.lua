-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65729

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

function Init()
    indicator:name("Tick Time Frame Timed Volume Price Change");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length", "Period Duration in seconds", "", 15, 2, 2000);
	indicator.parameters:addInteger("price_smoothing", "Price Smoothing Duration in seconds", "", 15 );
	indicator.parameters:addInteger("signal_smoothing", "Signal Smoothing Duration in seconds", "", 15 );
  
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Line Color Down", "", core.rgb(0,255,0 ));
	 indicator.parameters:addColor("color2", "Line Color Up", "", core.rgb(255,0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	

	 indicator.parameters:addColor("color3", "Signal Line Color", "", core.rgb(0,0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local length,price_smoothing,signal_smoothing; 
local first;
local source = nil;
local MVA,EMA1;
local vpc,signal;
local Second;
-- Routine
 function Prepare(nameOnly) 

     length = instance.parameters.length; 
	 price_smoothing = instance.parameters.price_smoothing;
	 signal_smoothing= instance.parameters.signal_smoothing;
 
    local name = profile:id() .. "(" ..  instance.source:name().. ", " ..  length .. ", " ..  signal_smoothing  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   Second= 1/86400;
			
    source = instance.source;
    first=source:first();
    
   
	if price_smoothing> 0 then
     EMA1= instance:addInternalStream(0, 0);
	end
 
	vpc = instance:addStream("vpc" , core.Line, "vpc","vpc",instance.parameters.color1, first);
	vpc:setWidth(instance.parameters.width1);
    vpc:setStyle(instance.parameters.style1);
	
	vpc:addLevel(0);
	vpc:setPrecision(math.max(2, source:getPrecision()));
    
    if signal_smoothing > 1 then
	
	 
	signal = instance:addStream("signal" , core.Line, "signal","signal",instance.parameters.color3, first);
	signal:setWidth(instance.parameters.width2);
    signal:setStyle(instance.parameters.style2);
	
	signal:setPrecision(math.max(2, source:getPrecision()));
	end
	
end

-- Indicator calculation routine
function Update(period, mode)


       local P1= core.findDate (source, source:date(period)- Second * price_smoothing, false);
	
		if P1==-1
		or P1< first+1 
		or P1>= period
		then
		return;
		end
		
       local P2= core.findDate (source, source:date(period)- Second * length, false);
	
		if P2==-1
		or P2< first+1 
		or P2>= period
		then
		return;
		end
 
 
 
	if price_smoothing >  0 then
    EMA1[period] =mathex.avg(source, P2, period); 
	vpc[period] = (EMA1[period]- EMA1[P1]) 	
	else
	 
	
	vpc[period] = (source[period]- source[P2]) ;
	end
	
    if signal_smoothing > 0 then

	
	local P3= core.findDate (source, source:date(period)- Second * signal_smoothing, false);
	
	if P3==-1
	or P3< first+1 
	or P3>= period
    then
    return;
    end 
	
	signal[period]=mathex.avg(vpc, P3, period);
	
	if vpc[period]> signal[period] then
	vpc:setColor(period, instance.parameters.color1);
	else
	vpc:setColor(period, instance.parameters.color2);
	end
	
	end
	
	 
end

 