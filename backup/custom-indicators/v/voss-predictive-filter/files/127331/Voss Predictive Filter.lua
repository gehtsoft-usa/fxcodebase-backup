-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=68660

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Voss Predictive Filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("Predict", "Predict", "", 3, 1, 2000);
	indicator.parameters:addDouble("Bandwidth", "Bandwidth", "", 0.25);
	
 
	
	indicator.parameters:addGroup("Fill Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Voss Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Predict,Bandwidth; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local Average;
local Order,F1, G1, S1;
local Filt, Voss;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Predict= instance.parameters.Predict;
	Bandwidth= instance.parameters.Bandwidth;
	
	
	local Parameters= Period..", "..Predict..", "..Bandwidth;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+2;
	
	Order = 3*Predict;
	--F1 = math.cos(360 / Period);
   -- G1 = math.cos(Bandwidth*360 / Period);
   -- S1 = 1 / G1 - math.sqrt ( 1 / (G1*G1) - 1);
	
	
	F1 = math.cos(2 * math.pi / Period);
	G1 = math.cos( Bandwidth * 2 * math.pi / Period);
	S1 = 1 / G1 - math.sqrt( 1 / (G1*G1) - 1);
	   
 
	Filt = instance:addStream("Filt" , core.Line, " Filt"," Filt",instance.parameters.color1, first);
	Filt:setWidth(instance.parameters.width1);
    Filt:setStyle(instance.parameters.style1);
    Filt:setPrecision(math.max(2, source:getPrecision()));
	
	Voss = instance:addStream("Voss" , core.Line, " Voss"," Voss",instance.parameters.color2, first + Order);
	Voss:setWidth(instance.parameters.width2);
    Voss:setStyle(instance.parameters.style2);
    Voss:setPrecision(math.max(2, source:getPrecision()));
	
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
	
    if period < first then
	Filt[period]=0;
	return;
	end
	
    --Band Limit the input data with a wide band BandPass Filter
    Filt[period] = 0.5*(1 - S1)*(source[period] - source[period-2]) + F1*(1 + S1)*Filt[period-1] - S1*Filt[period-2];
		
    
	if period < first +Order then
	Voss[period]=0;
	return;
	end			

    --Compute Voss predictor
	local SumC = 0;
	for  count = 0 ,  Order - 1, 1 do
	SumC = SumC + ((count + 1) / Order)*Voss[period-Order +count];
	end
 
    Voss[period] = ((3 + Order) / 2)*Filt[period] - SumC;
 	
end
 