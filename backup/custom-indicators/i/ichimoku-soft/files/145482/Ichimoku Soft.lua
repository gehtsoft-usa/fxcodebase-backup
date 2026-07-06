-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72018

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
    indicator:name("Ichimoku Soft");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "1. Period", "", 9, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. Period", "", 52, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("tenken", "Tenken Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("kiju", "Kiju Line Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addColor("Up", "Span Cloud Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Span Cloud Down Color", "", core.rgb(255, 0, 0)); 	

	 indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2, Period3; 
local Indicator;
local Period;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	source = instance.source
 
 
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
   
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("ICH", source, Period1, Period2, Period3);
	first=Indicator.DATA:first() ; 
	
	
	g1 = instance:addInternalStream(0, 0);
 
	Period= math.max(Period1, Period2, Period3);
	
    tenken = instance:addStream("tenken", core.Line, name, "tenken", instance.parameters.tenken, first );
    tenken:setPrecision(math.max(2, instance.source:getPrecision()));
    tenken:setWidth(instance.parameters.width);
    tenken:setStyle(instance.parameters.style);
    tenken:addLevel(0);	
	
    kiju = instance:addStream("kiju", core.Line, name, "kiju", instance.parameters.kiju, first );
    kiju:setPrecision(math.max(2, instance.source:getPrecision()));
    kiju:setWidth(instance.parameters.width);
    kiju:setStyle(instance.parameters.style);
    kiju:addLevel(0);	

    spana = instance:addStream("spana", core.Line, name, "spana", instance.parameters.Up, first );
    spana:setPrecision(math.max(2, instance.source:getPrecision()));
    spana:setWidth(instance.parameters.width);
    spana:setStyle(instance.parameters.style);
    spana:addLevel(0);	

    spanb = instance:addStream("spanb", core.Line, name, "spanb", instance.parameters.Down, first );
    spanb:setPrecision(math.max(2, instance.source:getPrecision()));
    spanb:setWidth(instance.parameters.width);
    spanb:setStyle(instance.parameters.style);
    spanb:addLevel(0);	

 
	instance:createChannelGroup("Group","Group" , spana, spanb, instance.parameters.Up, Transparency); 
end


function Update(period, mode)

	  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
 
	
	local f1= Indicator.SL[period];
	local f2= Indicator.TL[period];
    g1[period]=(f1+f2)/2
	
	
	if period < first +Period then
	return;
	end 
	
    local g4,g2=mathex.minmax(g1, period-Period1+1, period);	
    local g5,g3=mathex.minmax(g1, period-Period2+1, period);	
    local g7,g6=mathex.minmax(g1, period-Period3+1, period);		
 
	tenken[period]=(g2+g4)/2
	kiju[period]=(g3+g5)/2
	spana[period]=(tenken[period]+kiju[period])/2
	spanb[period]=(g6+g7)/2
	
	
	if spana[period]> spanb[period]then
	spana:setColor(period, instance.parameters.Up);
	spanb:setColor(period, instance.parameters.Up);		
	else
	spana:setColor(period, instance.parameters.Down);
	spanb:setColor(period, instance.parameters.Down);			
	end
end

 