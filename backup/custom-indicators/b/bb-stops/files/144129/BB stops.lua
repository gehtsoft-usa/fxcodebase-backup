-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71613

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
    indicator:name("BB stops");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("BandsPeriod", "BandsPeriod", "", 20, 1, 2000);
    indicator.parameters:addDouble("BandsDeviation1", "1. BandsDeviation", "", 1, 0, 2000);	
    indicator.parameters:addDouble("BandsDeviation2", "2. BandsDeviation", "", 0.5, 0, 2000);		
    indicator.parameters:addDouble("BandsRisk", "BandsRisk", "", 1, 1, 2000);

	indicator.parameters:addString("BandsMaType", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("BandsMaType", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("BandsMaType", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("BandsMaType", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("BandsMaType", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("BandsMaType", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("BandsMaType", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("BandsMaType", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("BandsMaType", "WMA", "WMA" , "WMA"); 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end



 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local BandsMaType, BandsRisk, BandsDeviation1, BandsDeviation2, BandsPeriod; 
local first;
local source = nil;
 
local MVA;
local min,max;
local Min,Max;
local Top, Bottom;

-- Routine
 function Prepare(nameOnly)   
 
 
    BandsMaType= instance.parameters.BandsMaType;
    BandsRisk= instance.parameters.BandsRisk;
	BandsDeviation1= instance.parameters.BandsDeviation1;
	BandsDeviation2= instance.parameters.BandsDeviation2;	
    BandsPeriod= instance.parameters.BandsPeriod;	
	
	local Parameters= BandsMaType ..", ".. BandsRisk ..", ".. BandsDeviation1 ..", ".. BandsDeviation2 ..", ".. BandsPeriod ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	source = instance.source;
	MVA = core.indicators:create(BandsMaType, source, BandsPeriod);
    first=MVA.DATA:first()+BandsPeriod;
	
	min= instance:addInternalStream(0, 0);
 	max= instance:addInternalStream(0, 0);  
	
	Min= instance:addInternalStream(0, 0);
 	Max= instance:addInternalStream(0, 0);  	
	
 	Trend= instance:addInternalStream(0, 0);  
	
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first );
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first );
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

    MVA:update(mode);
 
	if period <  first 
	then
	return;
	end 
    
	local   Stdev= mathex.stdev (source, period-BandsPeriod+1, period);
	min[period]=MVA.DATA[period]-Stdev*BandsDeviation1;
	max[period]=MVA.DATA[period]+Stdev*BandsDeviation1;		  
	

	Min[period]  = min[period]-BandsDeviation2*(BandsRisk-1)*(max[period]-min[period]);		
   	Max[period]  = max[period]+BandsDeviation2*(BandsRisk-1)*(max[period]-min[period]);

	
	
 
		if source[period]> max[period] then
		Trend[period]=1;
		elseif source[period]< min[period] then
		Trend[period]=-1;
		else
		Trend[period]=Trend[period-1];	
		end	
 
	 
	 
	    if (Trend[period]==-1 and max[period]>max[period-1]) then max[period] = max[period-1]; end
        if (Trend[period]== 1 and min[period]<min[period-1]) then min[period] = min[period-1]; end
		
        if (Trend[period]==-1 and Max[period]>Max[period-1]) then Max[period] = Max[period-1]; end
        if (Trend[period]== 1 and Min[period]<Min[period-1]) then Min[period] = Min[period-1]; end
		
		
						   
	
       if (Trend[period] ==  1) then  Bottom[period] = Min[period] end;
       if (Trend[period] == -1) then  Top[period] = Max[period] end;
end

 
