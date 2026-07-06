-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72617

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
    indicator:name("Mean Reversion");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("movingAverage", "Moving Average", "", 28, 1, 2000);
    indicator.parameters:addDouble("deviation", "Deviation Increment (%)", "", 3, 0.01, 100);
	

  	

	for i= 1, 11, 1 do
	Style(i);
	end
end


function Style(i)

    local Label={"S5","S4","S3","S2","S1","Cental","R1","R2","R3","R4","R5"};
	 indicator.parameters:addGroup(Label[i].. " Line Style");	
	 
	 

	 
    indicator.parameters:addInteger("width"..i, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE); 
	
	if i <= 5 then
	 indicator.parameters:addColor("color"..i, "Line Color", "", core.rgb(255, 0, 0)); 	
	elseif i>=7 then
	 indicator.parameters:addColor("color"..i, "Line Color", "", core.rgb(0, 255, 0)); 	
	else
	 indicator.parameters:addColor("color"..i, "Line Color", "", core.rgb(0, 0, 255)); 	
	end
	

	 
	 
end	 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local movingAverage, deviation; 
local Indicator;
local Line={};	
local Label={"S5","S4","S3","S2","S1","Cental","R1","R2","R3","R4","R5"};
-- Routine
 function Prepare(nameOnly)   
 
    
	movingAverage=instance.parameters.movingAverage;
	deviation=instance.parameters.deviation/ 100;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  movingAverage.. "," ..  deviation  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("MVA", source, movingAverage);
	first=Indicator.DATA:first() ; 
	
	 
	
	for i= 1, 11, 1 do
    Line[i] = instance:addStream("Line" .. i, core.Line, name, Label[i], instance.parameters:getColor("color" .. i)   , first );
    Line[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Line[i]:setWidth(instance.parameters:getInteger("width" .. i));
    Line[i]:setStyle(instance.parameters:getInteger("style" .. i));
    Line[i]:addLevel(0);	
	end
 
end


function Update(period, mode)

	  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
 
 
	fL = 1.0 + deviation
	fH = fL + deviation
	gL = fH
	gH = gL + deviation
	hL = gH
	hH = hL + deviation
	iL = hH
	iH = iL + deviation
	jL = iH	
	
	
 
	aH = 1.0 - deviation
	aL = aH - deviation
	bH = aL
	bL = bH - deviation
	cH = bL
	cL = cH - deviation
	dH = cL
	dL = dH - deviation
	eH = dL	
 
	Line[1][period] = jL * Indicator.DATA[period]; 
	Line[2][period] = iL * Indicator.DATA[period];  
	Line[3][period] = hL * Indicator.DATA[period];  
	Line[4][period] = gL * Indicator.DATA[period];  
	Line[5][period] = fL * Indicator.DATA[period];  
	Line[6][period] = Indicator.DATA[period];  
	Line[7][period] = aH * Indicator.DATA[period];  
	Line[8][period] = bH * Indicator.DATA[period];  
	Line[9][period] = cH * Indicator.DATA[period];  
	Line[10][period] = dH * Indicator.DATA[period];  
	Line[11][period] =eH * Indicator.DATA[period];  
	
end


 