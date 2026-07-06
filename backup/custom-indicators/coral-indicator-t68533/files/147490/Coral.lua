-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=68533

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
    indicator:name("Coral");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("gi_84", "Period", "", 34, 1, 2000);
    indicator.parameters:addDouble("gd_88", "K", "", 0.4, 0, 2000);
	
 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", " Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", " Down Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", " Neutral Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local gi_84, Period2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	gi_84=instance.parameters.gi_84;
	gd_88=instance.parameters.gd_88;
	source = instance.source
	
   gd_192 = gd_88 * gd_88; 
   gd_200 = gd_192 * gd_88;
   gd_136 = -gd_200;
   gd_144 = 3.0 * (gd_192 + gd_200);
   gd_152 = -3.0 * (2.0 * gd_192 + gd_88 + gd_200);
   gd_160 = 3.0 * gd_88 + 1.0 + gd_200 + 3.0 * gd_192;
   gd_168 = gi_84; 
   gd_168 = (gd_168 - 1.0) / 2.0 + 1.0;
   gd_176 = 2 / (gd_168 + 1.0);
   gd_184 = 1 - gd_176;	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  gi_84.. "," ..  gd_88  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+ gi_84; 
	
	
 
      gda_112= instance:addInternalStream(0, 0);
      gda_116= instance:addInternalStream(0, 0);
      gda_120= instance:addInternalStream(0, 0);
      gda_124= instance:addInternalStream(0, 0);
      gda_128= instance:addInternalStream(0, 0);
      gda_132= instance:addInternalStream(0, 0);
     
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)



	 if period <= first then
	 return;
	 end
	 
      gda_112[period] = gd_176 * source[period] + gd_184 * (gda_112[period - 1]);
      gda_116[period] = gd_176 * (gda_112[period]) + gd_184 * (gda_116[period - 1]);
      gda_120[period] = gd_176 * (gda_116[period]) + gd_184 * (gda_120[period - 1]);
      gda_124[period] = gd_176 * (gda_120[period]) + gd_184 * (gda_124[period - 1]);
      gda_128[period] = gd_176 * (gda_124[period]) + gd_184 * (gda_128[period - 1]);
      gda_132[period] = gd_176 * (gda_128[period]) + gd_184 * (gda_132[period - 1]);
      Line[period] = gd_136 * (gda_132[period]) + gd_144 * (gda_128[period]) + gd_152 * (gda_124[period]) + gd_160 * (gda_120[period]);
	
    if Line[period] > Line[period-1]  then
	Line:setColor(period,  instance.parameters.color1);	
	elseif Line[period] < Line[period-1]  then
	Line:setColor(period,  instance.parameters.color2);	
	else
	Line:setColor(period,  instance.parameters.color3);	
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