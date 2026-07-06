-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74383

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Advanced_Price_Action_Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Period", "", 21, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1.  Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 

	first=source:first()+Period ; 
	
	
	sup = instance:addInternalStream(0, 0);
 	res = instance:addInternalStream(0, 0);
	
    rsup = instance:addInternalStream(0, 0);
    rres = instance:addInternalStream(0, 0);
    tot = instance:addInternalStream(0, 0);
	
	MA1= core.indicators:create("LWMA", rsup, Period);	
	MA2= core.indicators:create("LWMA", rres, Period);
	MA3= core.indicators:create("LWMA", tot, Period);	
 
	
    ttperc = instance:addStream("ttperc", core.Line, name, "ttperc", instance.parameters.color1, first );
    ttperc:setPrecision(math.max(2, instance.source:getPrecision()));
    ttperc:setWidth(instance.parameters.width);
    ttperc:setStyle(instance.parameters.style);
    ttperc:addLevel(100);	
	
    ppperc = instance:addStream("ppperc", core.Line, name, "ppperc", instance.parameters.color2, first );
    ppperc:setPrecision(math.max(2, instance.source:getPrecision()));
    ppperc:setWidth(instance.parameters.width);
    ppperc:setStyle(instance.parameters.style);
    ppperc:addLevel(100);		

    ptperc = instance:addStream("ptperc", core.Line, name, "ptperc", instance.parameters.color3, first );
    ptperc:setPrecision(math.max(2, instance.source:getPrecision()));
    ptperc:setWidth(instance.parameters.width);
    ptperc:setStyle(instance.parameters.style);
    ptperc:addLevel(100);	
 
end


function Update(period, mode)

 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  
    local min,max=mathex.minmax(source, period-2, period)
	
	
      
    if (source.low[period- 1] < source.low[period- 2] and source.low[period- 1] == min)then
         sup[period] = sup[period-1] + 1; 
	else
         sup[period] = sup[period-1]; 	
	end	 

 
    if (source.high[period- 1] > source.high[period- 2] and source.high[period- 1] == max) then
         res[period] = res[period-1] + 1;
	else	 
         res[period] = res[period-1];	
    end

    rsup[period] = (sup[period] - sup[period -Period +1]) * 2;
    rres[period] = (res[period] - res[period -Period +1 ]) * 2;
    tot[period] = (rsup[period] + rres[period]) / 2;
    local  ata = ((res[period] + sup[period]) / (period)) * Period;
	
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	
	if period< MA1.DATA:first() then
	return;
	end


--pos
    ttperc[period] = ((MA1.DATA[period] / ata) * 100);
    ppperc[period] = ((MA2.DATA[period] / ata) * 100);
    ptperc[period] = ((MA3.DATA[period] / ata) * 100);	  
	  	
 
 
end

 


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+