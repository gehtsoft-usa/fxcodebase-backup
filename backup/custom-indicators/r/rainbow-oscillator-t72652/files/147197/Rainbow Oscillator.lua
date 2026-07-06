-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72652

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
--|                                                                       https://mario-jemic.com/ |
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
    indicator:name("Rainbow Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

 
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 2, 1, 2000);
    indicator.parameters:addInteger("LengthHHLL", "HHV/LLV Lookback", "", 10, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, LengthHHLL; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	LengthHHLL=instance.parameters.LengthHHLL;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length.. "," ..  LengthHHLL  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("MVA", source, Length);
	Indicator2= core.indicators:create("MVA", Indicator1.DATA, Length);
	Indicator3= core.indicators:create("MVA", Indicator2.DATA, Length);
	Indicator4= core.indicators:create("MVA", Indicator3.DATA, Length);
	Indicator5= core.indicators:create("MVA", Indicator4.DATA, Length);
	Indicator6= core.indicators:create("MVA", Indicator5.DATA, Length);
	Indicator7= core.indicators:create("MVA", Indicator6.DATA, Length);
	Indicator8= core.indicators:create("MVA", Indicator7.DATA, Length);
	Indicator9= core.indicators:create("MVA", Indicator8.DATA, Length);
	Indicator10= core.indicators:create("MVA", Indicator9.DATA, Length);	
	first=Indicator10.DATA:first()+LengthHHLL; 
	
	
	Stream = instance:addInternalStream(0, 0);
 
	
	
    xRBO = instance:addStream("xRBO", core.Bar, name, "xRBO", instance.parameters.color1, first );
    xRBO:setPrecision(math.max(2, instance.source:getPrecision())); 
    xRBO:addLevel(0);	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);		
 
end


function Update(period, mode)

	  Indicator1:update(mode); 
	  Indicator2:update(mode); 
	  Indicator3:update(mode); 
	  Indicator4:update(mode); 
	  Indicator5:update(mode); 
	  Indicator6:update(mode); 
	  Indicator7:update(mode); 
	  Indicator8:update(mode); 
	  Indicator9:update(mode); 
	  Indicator10:update(mode); 
 
	 if period <= first then
	 return;
	 end

 

   local xLL, xHH = mathex.minmax(source, period-LengthHHLL+1, period);
  local xHHMAs = math.max(Indicator1.DATA[period],Indicator2.DATA[period],Indicator3.DATA[period],Indicator4.DATA[period],Indicator5.DATA[period],Indicator6.DATA[period],Indicator7.DATA[period],Indicator8.DATA[period],Indicator9.DATA[period],Indicator10.DATA[period]);
  local xLLMAs = math.min(Indicator1.DATA[period],Indicator2.DATA[period],Indicator3.DATA[period],Indicator4.DATA[period],Indicator5.DATA[period],Indicator6.DATA[period],Indicator7.DATA[period],Indicator8.DATA[period],Indicator9.DATA[period],Indicator10.DATA[period]);   
	
	
	xRBO[period] = 100 * ((source[period] - ((Indicator1.DATA[period]+Indicator2.DATA[period]+Indicator3.DATA[period]+Indicator4.DATA[period]+Indicator5.DATA[period]+Indicator6.DATA[period]+Indicator7.DATA[period]+Indicator8.DATA[period]+Indicator9.DATA[period]+Indicator10.DATA[period]) / 10)) / (xHH - xLL))
	Top[period] = 100 * ((xHHMAs - xLLMAs) / (xHH - xLL))
	Bottom[period] = -Top[period]	
	
	if xRBO[period] > 0 then
	xRBO:setColor(period,  instance.parameters.color1);	
	else
	xRBO:setColor(period,  instance.parameters.color2);	
	end
end
 