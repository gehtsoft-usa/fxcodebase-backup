-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72868

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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
    indicator:name("Effective Volume");
    indicator:description("Effective Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("jb", "Buy volume Factor", "", 3, 1, 4);
    indicator.parameters:addDouble("js", "Sell volume Factor", "", 3, 1, 4); 	
    indicator.parameters:addInteger("Period", "Period", "", 40, 1, 20000); 	 
	
	 indicator.parameters:addGroup("Style");		
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 255)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 255)); 
	 indicator.parameters:addColor("UpColor", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("DownColor", "Down Color", "", core.rgb(255, 0, 0)); 	

	 indicator.parameters:addColor("Color", "Extreme Value Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local jb, js; 
local Top, Bottom, Period; 
-- Routine
 function Prepare(nameOnly)   
 
    
	jb=instance.parameters.jb;
	js=instance.parameters.js;
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  jb  .. "," ..   js .. "," ..   Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+1 ; 
	
	BuyV = instance:addInternalStream(0, 0);	
	SellV = instance:addInternalStream(0, 0); 
	
	MA1= core.indicators:create("EMA", BuyV, Period);	
	MA2= core.indicators:create("EMA", SellV, Period);		

		EV = instance:addStream("EV", core.Bar, name, "EV", instance.parameters.UpColor, first );
		EV:setPrecision(math.max(2, instance.source:getPrecision()));
		EV:addLevel(0);			
		
 		BVA = instance:addStream("BVA", core.Line, name, "BVA", instance.parameters.color1, first+Period  );
		BVA:setPrecision(math.max(2, instance.source:getPrecision()));
		BVA:addLevel(0);
		 
 		SVA = instance:addStream("SVA", core.Line, name, "SVA", instance.parameters.color2, first+Period );
		SVA:setPrecision(math.max(2, instance.source:getPrecision()));
		SVA:addLevel(0);		
end


function Update(period, mode)


    if period <=first then
	return;
	end
	
	 

	
    local num = source.close[period] - source.close[period-1];
	local Hi  = math.max(source.high[period], source.close[period-1]);
	local Li  = math.min(source.low[period], source.close[period-1]);	
	local EVt = math.abs(num /(Hi-Li));
    if source.close[period] > source.close[period-1] then
	EV[period] =source.volume[period]*EVt
	else
	EV[period] =source.volume[period]*(-1)*EVt;
	end
	
	
	if EV[period]>0 then
	BuyV[period]=EV[period]
	else
	BuyV[period]=0;
	end
	
	if EV[period]<0 then
	SellV[period]=EV[period]
	else
	SellV[period]=0;
	end	
 
 
 	MA1:update(mode); 
 	MA2:update(mode); 
	
    if period <=first +Period then
	return;
	end	

	BVA[period]= MA1.DATA[period];
	SVA[period]= MA2.DATA[period];

 
	if EV[period]>=0 then
	EV:setColor(period,  instance.parameters.UpColor);	
	else
	EV:setColor(period,  instance.parameters.DownColor);	
	end
	
	
	if EV[period]>(jb*BVA[period]) then
	EV:setColor(period,  instance.parameters.Color);	
	end
    if EV[period]<(js*SVA[period]) then
	EV:setColor(period,  instance.parameters.Color);		
	end


 

end
 


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+
