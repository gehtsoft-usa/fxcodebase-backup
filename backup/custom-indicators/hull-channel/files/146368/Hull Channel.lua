-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72384

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
    indicator:name("Hull Channel");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
 
	
	 indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
local Indicator1,Indicator2;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


	
	Indicator1= core.indicators:create("LWMA", source, Period/2);
	Indicator2= core.indicators:create("LWMA", source,  Period );	

	MM1 = instance:addInternalStream(0, 0);
	
	Indicator3= core.indicators:create("LWMA", MM1, math.sqrt(Period) );		
	first= Indicator2.DATA:first()  ; 
  
	
    Centralite = instance:addStream("Centralite", core.Line, name, "Centralite", instance.parameters.Up, Indicator3.DATA:first() );
    Centralite:setPrecision(math.max(2, instance.source:getPrecision()));
    Centralite:setWidth(instance.parameters.width);
    Centralite:setStyle(core.LINE_SOLID);
    Centralite:addLevel(0);	
	
    Top1 = instance:addStream("Top1", core.Line, name, "1. Top", instance.parameters.Up, Indicator3.DATA:first() );
    Top1:setPrecision(math.max(2, instance.source:getPrecision()));
    Top1:setWidth(instance.parameters.width);
    Top1:setStyle(core.LINE_SOLID);
    Top1:addLevel(0);	

    Bottom1 = instance:addStream("Bottom1", core.Line, name, "1. Bottom", instance.parameters.Up, Indicator3.DATA:first() );
    Bottom1:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom1:setWidth(instance.parameters.width);
    Bottom1:setStyle(core.LINE_SOLID);
    Bottom1:addLevel(0);


    Top2 = instance:addStream("Top2", core.Line, name, "2. Top", instance.parameters.Up, Indicator3.DATA:first() );
    Top2:setPrecision(math.max(2, instance.source:getPrecision()));
    Top2:setWidth(instance.parameters.width);
    Top2:setStyle(core.LINE_DOT );
    Top2:addLevel(0);	

    Bottom2 = instance:addStream("Bottom2", core.Line, name, "2. Bottom", instance.parameters.Up, Indicator3.DATA:first() );
    Bottom2:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom2:setWidth(instance.parameters.width);
    Bottom2:setStyle(core.LINE_DOT );
    Bottom2:addLevel(0);		


    Top3 = instance:addStream("Top3", core.Line, name, "3. Top", instance.parameters.Up, Indicator3.DATA:first() );
    Top3:setPrecision(math.max(2, instance.source:getPrecision()));
    Top3:setWidth(instance.parameters.width);
    Top3:setStyle(core.LINE_DOT );
    Top3:addLevel(0);	

    Bottom3 = instance:addStream("Bottom3", core.Line, name, "3. Bottom", instance.parameters.Up, Indicator3.DATA:first() );
    Bottom3:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom3:setWidth(instance.parameters.width);
    Bottom3:setStyle(core.LINE_DOT );
    Bottom3:addLevel(0);		
	
 
end


function Update(period, mode)

	  Indicator1:update(mode); 
	  Indicator2:update(mode); 
	  
	 if period <= first then
	 return;
	 end
	 
    MM1[period]=2*Indicator1.DATA[period]-Indicator2.DATA[period];
	
	Indicator3:update(mode); 
	
	if period <= Indicator3.DATA:first() or period <= 52 then
	return;
	end
	 
	
	local STD1 = mathex.stdev(source, period-9+1, period);
	local STD2 = mathex.stdev(source, period-26+1, period);
	local STD3 = mathex.stdev(source, period-52+1, period);
	
	local MM=Indicator3.DATA[period];
 
 
    local Bolup1 = MM+STD1*1.0
    local Boldw1 = MM-STD1*1.0
    local Bolup2 = MM+STD2*1.0
    local Boldw2 = MM-STD2*1.0
    local Bolup3 = MM+STD3*1.0
    local Boldw3 = MM-STD3*1.0
	
    Top1[period] = (Bolup1+Bolup2+Bolup3)/3
    Bottom1[period]  = (Boldw1+Boldw2+Boldw3)/3
    Centralite[period] = ( Top1[period]+Bottom1[period])/2
	
	
	local Bolup11 = MM+STD1*1.25
	local Boldw11 = MM-STD1*1.25
	local Bolup22 = MM+STD2*1.25
	local Boldw22 = MM-STD2*1.25
	local Bolup33 = MM+STD3*1.25
	local Boldw33 = MM-STD3*1.25
	Top2[period] = (Bolup11+Bolup22+Bolup33)/3
	Bottom2[period] = (Boldw11+Boldw22+Boldw33)/3
	 
	local Bolup111 = MM+STD1*0.75
	local Boldw111 = MM-STD1*0.75
	local Bolup222 = MM+STD2*0.75
	local Boldw222 = MM-STD2*0.75
	local Bolup333 = MM+STD3*0.75
	local Boldw333 = MM-STD3*0.75
	Top3[period] = (Bolup111+Bolup222+Bolup333)/3
	Bottom3[period] = (Boldw111+Boldw222+Boldw333)/3
 
	if Centralite[period]> Centralite[period-1] then 
	Top1:setColor(period,  instance.parameters.Up);	
	Bottom1:setColor(period,  instance.parameters.Up);	
	Centralite:setColor(period,  instance.parameters.Up);	
	Top2:setColor(period,  instance.parameters.Up);	
	Bottom2:setColor(period,  instance.parameters.Up);	
	Top3:setColor(period,  instance.parameters.Up);	
	Bottom3:setColor(period,  instance.parameters.Up);		
	else
	Top1:setColor(period,  instance.parameters.Down);	
	Bottom1:setColor(period,  instance.parameters.Down);	
	Centralite:setColor(period,  instance.parameters.Down);	
	Top2:setColor(period,  instance.parameters.Down);	
	Bottom2:setColor(period,  instance.parameters.Down);	
	Top3:setColor(period,  instance.parameters.Down);	
	Bottom3:setColor(period,  instance.parameters.Down);	
	end
		 	
end

 