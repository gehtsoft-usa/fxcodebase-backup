-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72345

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Bear and Bull volume indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Fast MA", "", 22, 1, 2000); 
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Bull Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Bear Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color5", "Delta Color", "", core.rgb(0, 0, 255)); 	 
	
	indicator.parameters:addGroup("Average Line Style"); 
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	 
	indicator.parameters:addColor("color3", "Average Bull Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color4", "Average Bear Color", "", core.rgb(255, 0, 0)); 
	 
	  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first() ; 
	
	
 
    Up= instance:addInternalStream(0, 0);
    Down= instance:addInternalStream(0, 0);	
	
    UpVolume= instance:addInternalStream(0, 0);
    DownVolume= instance:addInternalStream(0, 0);	
	
 
	
    bull = instance:addStream("bull", core.Bar, name, "bull", instance.parameters.color1, first );
    bull:setPrecision(math.max(2, instance.source:getPrecision())); 
    bull:addLevel(0);	
   -- bull:setWidth(instance.parameters.width1);
  -- bull:setStyle(instance.parameters.style1);

    bear = instance:addStream("bear", core.Bar, name, "bear", instance.parameters.color2, first );
    bear:setPrecision(math.max(2, instance.source:getPrecision()));  
   -- bear:setWidth(instance.parameters.width1);
   -- bear:setStyle(instance.parameters.style1);

    green	= instance:addStream("green", core.Line, name, "green", instance.parameters.color3, first+Period );
    green:setPrecision(math.max(2, instance.source:getPrecision()));  
    green:setWidth(instance.parameters.width2);
    green:setStyle(instance.parameters.style2);
	
    red	= instance:addStream("red", core.Line, name, "red", instance.parameters.color4, first+Period );
    red:setPrecision(math.max(2, instance.source:getPrecision()));  
    red:setWidth(instance.parameters.width2);
    red:setStyle(instance.parameters.style2);
	
    delta	= instance:addStream("delta", core.Line, name, "delta", instance.parameters.color5, first+Period );
    delta:setPrecision(math.max(2, instance.source:getPrecision()));  
    delta:setWidth(instance.parameters.width1);
    delta:setStyle(instance.parameters.style1);	
end


function Update(period, mode)

	 -- Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    local range=source.high[period]-source.low[period];
	local ref1=(source.close[period]-source.low[period])/range;
	local ref2=(source.high[period]-source.close[period])/range;	
	
    bull[period]=ref1*source.volume[period];
    bear[period]=-ref2*source.volume[period];
	
	
	if source.close[period]> source.open[period] then
	Up[period]=1;
	Down[period]=0;	
	UpVolume[period]=source.volume[period];
	DownVolume[period]=0;		
 		
	else
	Up[period]=0;
	Down[period]=1;	
	UpVolume[period]=0;
	DownVolume[period]=source.volume[period]
 
	end
	
	if period <= first +Period then
	return;
	end	
	
	green[period]=mathex.sum(UpVolume, period-Period+1, period)/mathex.sum(Up, period-Period+1, period);
	red[period]=(mathex.sum(DownVolume , period-Period+1, period)/mathex.sum(Down, period-Period+1, period));
	
	delta[period]=bull[period]+bear[period];
end

 