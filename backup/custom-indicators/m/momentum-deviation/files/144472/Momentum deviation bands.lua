-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71710

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

function Init()
    indicator:name("Momentum deviation bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Momentum Period", "", 2, 1, 2000);	
    indicator.parameters:addInteger("Period2", "Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Multiplier", "Multiplier", "", 2 );
	
	indicator.parameters:addGroup("Cental Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Multiplier ; 
local first;
local source = nil;
 
local Oscillator;  
local Momentum;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Multiplier= instance.parameters.Multiplier;
 
	
	
	local Parameters= Period1..", "..Period2..", "..Multiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period1+Period2;
	
	Momentum= instance:addInternalStream(0, 0);
   
 
	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.color, first) ;
	Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first) ;
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));

	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first) ;
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first() + Period1
	then
	return;
	end
	
	Momentum[period]=source[period]- source[period-Period1+1];
    Momentum[period]=Momentum[period]*Momentum[period];
	
	
	if period < source:first() + Period1+ Period2
	then
	return;
	end
	
    local Deviation = math.sqrt(mathex.sum(Momentum, period-Period2+1, period)/Period2);
	
	Central[period]= mathex.avg(source, period-Period2+1, period);
	Top[period]=Central[period]+Deviation*Multiplier;			
	Bottom[period]=Central[period]-Deviation*Multiplier;			
end

 