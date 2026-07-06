-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71584


--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Price Oscillator");
    indicator:description("Price Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Trend Period", "Period", 14);
    indicator.parameters:addInteger("Period2", "Momentum Period", "Period", 14);	
    indicator.parameters:addInteger("Period3", "Range Period", "Period", 28);	
	indicator.parameters:addBoolean("Trend", "Remove Trend", "", true);
	indicator.parameters:addBoolean("Momentum", "Remove Momentum", "", true);	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDPO", "Color of DPO", "Color of DPO", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local first;
local source = nil;
local MA;
local Period1, Period2,Period3;

local Trend, Momentum;
local Data,Oscillator; 
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
	
	Trend= instance.parameters.Trend;
	Momentum= instance.parameters.Momentum;
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
   Period3= instance.parameters.Period3;	 

    if   (nameOnly) then
        return;
    end
    source = instance.source 
    MA = core.indicators:create("MVA", source, Period1);
    first = MA.DATA:first();
	
	
	Data = instance:addInternalStream(0, 0);
     
    Oscillator = instance:addStream("Oscillator", core.Line, name .. ".Oscillator", "Oscillator", instance.parameters.clrDPO, first+Period2+Period3);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    MA:update(mode);
    if (period<first) then
	return;
	end
	
	
	 
     Data[period]=source[period];
	 
	 if Trend then
	 Data[period]= Data[period]-MA.DATA[period];
     end
	 
    if (period<first+Period2) then
	return;
	end

	
	 if Momentum then
	 Data[period]= Data[period] -Data[period-Period2+1];
     end
	 
    if (period<first+Period2+Period3) then
	return;
	end
	
	
	local min,max=mathex.minmax(Data, period-Period3+1, period);
	
	Oscillator[period]= (Data[period]-min)/(max-min);
end

