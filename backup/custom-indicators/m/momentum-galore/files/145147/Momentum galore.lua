-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71915

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
    indicator:name("Momentum galore");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 
	 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("color1", "Supply Energy Line Color", "", core.rgb(0, 255, 0)); 	
	 indicator.parameters:addColor("color2", "Demand Energy Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "VADER Line Color", "", core.rgb(0, 0, 255)); 
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
 

	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    Volume= instance:addInternalStream(0, 0);	

	first=source:first()+256; 


	Line1 = instance:addInternalStream(0, 0);
	Line2 = instance:addInternalStream(0, 0);
	Line4 = instance:addInternalStream(0, 0);
	Line8 = instance:addInternalStream(0, 0);
	Line16 = instance:addInternalStream(0, 0);	
	Line32 = instance:addInternalStream(0, 0);	
	Line64 = instance:addInternalStream(0, 0);		
	Line128 = instance:addInternalStream(0, 0);		
	Line256 = instance:addInternalStream(0, 0);		
    Source = instance:addInternalStream(0, 0);			
	---WMA4= core.indicators:create("WMA", dem, length);

    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1,  first+128  );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	
	--[[
    Line1 = instance:addStream("Line1", core.Line, name, "Line1", instance.parameters.color1,  first  );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
	
	
	
    Line2 = instance:addStream("Line2", core.Line, name, "Line2", instance.parameters.color2,  first  );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);		
 
	
	Line4 = instance:addStream("Line4", core.Line, name, "Line4", instance.parameters.color3,  first  );
    Line4:setPrecision(math.max(2, instance.source:getPrecision()));
    Line4:setWidth(instance.parameters.width);
    Line4:setStyle(instance.parameters.style);	
    Line4:addLevel(0);

    Line8 = instance:addStream("Line8", core.Line, name, "Line8", instance.parameters.color1,  first  );
    Line8:setPrecision(math.max(2, instance.source:getPrecision()));
    Line8:setWidth(instance.parameters.width);
    Line8:setStyle(instance.parameters.style);
    Line8:addLevel(0);	
	
	
	
    Line16 = instance:addStream("Line16", core.Line, name, "Line16", instance.parameters.color2,  first  );
    Line16:setPrecision(math.max(2, instance.source:getPrecision()));
    Line16:setWidth(instance.parameters.width);
    Line16:setStyle(instance.parameters.style);
    Line16:addLevel(0);		
 
	
	Line32 = instance:addStream("Line32", core.Line, name, "Line32", instance.parameters.color3,  first  );
    Line32:setPrecision(math.max(2, instance.source:getPrecision()));
    Line32:setWidth(instance.parameters.width);
    Line32:setStyle(instance.parameters.style);
    Line32:addLevel(0);
	
	
    Line64 = instance:addStream("Line64", core.Line, name, "Line64", instance.parameters.color1,  first  );
    Line64:setPrecision(math.max(2, instance.source:getPrecision()));
    Line64:setWidth(instance.parameters.width);
    Line64:setStyle(instance.parameters.style);
    Line64:addLevel(0);	
	
	
	
    Line128 = instance:addStream("Line128", core.Line, name, "Line128", instance.parameters.color2,  first  );
    Line128:setPrecision(math.max(2, instance.source:getPrecision()));
    Line128:setWidth(instance.parameters.width);
    Line128:setStyle(instance.parameters.style);
    Line128:addLevel(0);		
 
	
	Line256 = instance:addStream("Line256", core.Line, name, "Line256", instance.parameters.color3,  first  );
    Line256:setPrecision(math.max(2, instance.source:getPrecision()));
    Line256:setWidth(instance.parameters.width);
    Line256:setStyle(instance.parameters.style);
    Line256:addLevel(0);	]]
end


function Update(period, mode)



	 if period < first then
	 return;
	 end
	 
	Line1[period]=(source[period]-source[period-1]);
	Line2[period]=(source[period]-source[period-2])-(Line1[period]*2);
	Line4[period]=(source[period]-source[period-4])-(Line2[period]*2);
	Line8[period]=(source[period]-source[period-8])-(Line4[period]*2);
	Line16[period]=(source[period]-source[period-16])-(Line8[period]*2);
	Line32[period]=(source[period]-source[period-32])-(Line16[period]*2);
	Line64[period]=(source[period]-source[period-64])-(Line32[period]*2);
	Line128[period]=(source[period]-source[period-128])-(Line64[period]*2);
	Line256[period]=(source[period]-source[period-256])-(Line128[period]*2);	
	
	
	Source[period]= Source[period-1]+ Line1[period]+Line2[period]+Line4[period]+Line8[period]+Line16[period]+Line32[period]+Line64[period]+Line128[period]+Line256[period];
	
	 if period < first + 128 then
	 return;
	 end	
	Line[period]=Source[period]- mathex.avg(Source, period-128+1, period);
	
	
	
end
 