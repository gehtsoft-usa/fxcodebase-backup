-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71315

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



-- Indicator profile initialization routine

function Init()
    indicator:name("KDJ Lines");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 9, 1, 2000);
    indicator.parameters:addInteger("Period1", "K Period", "", 3, 1, 2000);
    indicator.parameters:addInteger("Period2", "D Period", "", 3, 1, 2000);

 
	
	indicator.parameters:addGroup("RSV Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("K Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("D Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("J Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Period1,Period2; 
local first;
local source = nil;
local RSV, K, D, J;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;	
	
	local Parameters= Period.. ", " .. Period1.. ", " .. Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period; 
	
	
	RSV = instance:addStream("RSV" , core.Line, " RSV"," RSV",instance.parameters.color1, first );
	RSV:setWidth(instance.parameters.width1);
    RSV:setStyle(instance.parameters.style1);
    RSV:setPrecision(math.max(2, source:getPrecision()));
	
	K = instance:addStream("K" , core.Line, " K"," K",instance.parameters.color2, first + Period1);
	K:setWidth(instance.parameters.width2);
    K:setStyle(instance.parameters.style2);
    K:setPrecision(math.max(2, source:getPrecision()));

	D = instance:addStream("D" , core.Line, " D"," D",instance.parameters.color3, first  + Period1 + Period2);
	D:setWidth(instance.parameters.width3);
    D:setStyle(instance.parameters.style3);
    D:setPrecision(math.max(2, source:getPrecision()));


	J = instance:addStream("J" , core.Line, " J"," J",instance.parameters.color4, first  + Period1 + Period2 );
	J:setWidth(instance.parameters.width4);
    J:setStyle(instance.parameters.style4);
    J:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)
  
  
 
	if period <  first 
	then
	return;
	end 
	
	
	local min, max=mathex.minmax(source, period-Period+1, period);
	
     RSV[period]= ((source.close[period]-min)/(max-min))*100;

	if period <  first +Period1
	then
	return;
	end 

    K[period]=mathex.avg(RSV, period-Period1+1, period);	

    if period <  first  +Period1+Period2
	then
	return;
	end 	

    D[period]=mathex.avg(K, period-Period1+1, period);	
    J[period]= 3*K[period]-2*D[period];
 	
end

 