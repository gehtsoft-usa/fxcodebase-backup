-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71898

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
    indicator:name("Distance indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("HalfLength", "Half Length", "", 35, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 0.35 );	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(0, 0, 255)); 
	 
	 
	indicator.parameters:addColor("color3", "Up Trend Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color4", "Down Trend Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local HalfLength,Deviation; 
local Indicator;
local Method;	
-- Routine
 function Prepare(nameOnly)   
 
    
	HalfLength=instance.parameters.HalfLength;
	Deviation=instance.parameters.Deviation;
	Method=instance.parameters.Method;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  HalfLength .. "," ..  Deviation.. "," ..  Method  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+HalfLength ;  
	
	Trend = instance:addInternalStream(0, 0);	
	Sum = instance:addInternalStream(0, 0); 
    Period = instance:addInternalStream(0, 0); 	

	MA = core.indicators:create(Method, Sum, HalfLength);

	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first+HalfLength );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	
	
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first+HalfLength );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);		
	
	
	Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color3, first+HalfLength );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
    Central:addLevel(0);		
 
end


function Update(period, mode)

 

	 if period < first then
	 return;
	 end
 
    period=period-HalfLength;
 
 	Period[period]=0;
	Sum[period]=0;	
 
		for The_Period= period, period+HalfLength, 1 do	
		
			Period[The_Period]=0;
			Sum[The_Period]=0;	
		
			for j= 1, HalfLength, 1 do  
					
					Sum[The_Period]=Sum[The_Period]+source[period-j]; 
					Period[The_Period]=Period[The_Period]+1;
					
					if period+ j<= source:size()-1 then
					Sum[The_Period]=Sum[The_Period]+source[period+j]; 
					Period[The_Period]=Period[The_Period]+1;			
					end		 		
			end
		end
 
	
 
	
	 if period < first+HalfLength then
	 return;
	 end	
	
    MA:update(mode);
	
	
	for period= period, period+HalfLength, 1 do
	
		Top[period] = (1+Deviation/100)* (MA.DATA[period]/(Period[period]));
		Bottom[period] = (1-Deviation/100)* (MA.DATA[period]/(Period[period]))
		Central[period] = (Top[period]+Bottom[period])/2;	
		Trend[period]=Trend[period-1];
		

		if source[period]> Bottom[period]
		and	source[period-1]<= Bottom[period-1]
		then
		Trend[period]=1;
		elseif source[period]< Top[period]
		and	source[period-1]>= Top[period-1]
		then	
		Trend[period]=-1;	
		end
		
		if Trend[period]==1 then
		Central:setColor(period,  instance.parameters.color3);	
		else
		Central:setColor(period,  instance.parameters.color4);		
		end
		
    end
	
end

 
