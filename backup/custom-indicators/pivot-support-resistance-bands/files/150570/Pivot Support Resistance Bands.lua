-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73641

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Pivot Support Resistance Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("p", "Period", "", 2, 1, 2000);
    indicator.parameters:addInteger("PivotBAR", "PivotBAR", "", 2, 1, 2000);
    indicator.parameters:addInteger("LookBack", "LookBack", "", 4, 1, 2000);	
 
	
	indicator.parameters:addString("Type", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Type", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Type", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Type", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Type", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Type", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Type", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Type", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Type", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Support Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Resistance Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local p, Type,PivotBAR, LookBack; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	p=instance.parameters.p;
	Type=instance.parameters.Type;
	PivotBAR=instance.parameters.PivotBAR;
	LookBack=instance.parameters.LookBack;
	BarLookBack  = PivotBAR + 1
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  p.. "," ..  Type .. "," ..  PivotBAR .. "," ..  LookBack .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+LookBack; 
	

	Min = instance:addInternalStream(0, 0);
 	Max = instance:addInternalStream(0, 0);
	
	SupportPrice = instance:addInternalStream(0, 0);
 	ResistancePrice = instance:addInternalStream(0, 0);


	Support= core.indicators:create(Type, SupportPrice, p);
	Resistance= core.indicators:create(Type, ResistancePrice, p);	
	
    support = instance:addStream("support", core.Line, name, "support", instance.parameters.color1, Resistance.DATA:first() );
    support:setPrecision(math.max(2, instance.source:getPrecision()));
    support:setWidth(instance.parameters.width);
    support:setStyle(instance.parameters.style);
 
 
    resistance = instance:addStream("resistance", core.Line, name, "resistance", instance.parameters.color2, Resistance.DATA:first() );
    resistance:setPrecision(math.max(2, instance.source:getPrecision()));
    resistance:setWidth(instance.parameters.width);
    resistance:setStyle(instance.parameters.style);
	
    central = instance:addStream("central", core.Line, name, "central", instance.parameters.color3, Resistance.DATA:first() );
    central:setPrecision(math.max(2, instance.source:getPrecision()));
    central:setWidth(instance.parameters.width);
    central:setStyle(instance.parameters.style);	
end


function Update(period, mode)



	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	local min,max=mathex.minmax(source, period-LookBack, period)
	Min[period] = min;
	Max[period] = max;
	
	SupportPrice[period]=SupportPrice[period-1];
	ResistancePrice[period]=ResistancePrice[period-1];
	
	if source.low[period-PivotBAR] < Min[period-BarLookBack] then
	   if source.low[period-PivotBAR] == Min[period] then 
		  SupportPrice[period]  = source.low[period-PivotBAR]
	   end
	end
	if source.high[PivotBAR] > Max[period-BarLookBack] then
	   if source.high[period-PivotBAR] == Max[period] then 
		  ResistancePrice[period] = source.high[period-PivotBAR] 
	   end
	end
	
	Support:update(mode); 	
	Resistance:update(mode); 

    if period <= Resistance.DATA:first() then
    return;
    end	
	  	
    resistance[period]=	Resistance.DATA[period];
    support[period]=Support.DATA[period];

    central[period]= support[period] + ((resistance[period] - support[period]) / 2) 
	
end

--[[
//p          = 2                      //2  periods
//Type       = 1                      //1 = Ema
p            = max(1,min(999,p))      //range 1 - 999
Type         = max(0,min(6,Type))     //range 0 - 6
PivotBAR     = 2                      //2  bars AFTER  pivot
LookBack     = 4                      //4  bars BEFORE pivot
BarLookBack  = PivotBAR + 1
IF low[PivotBAR] < lowest[LookBack](low)[BarLookBack] THEN
   IF low[PivotBAR] = lowest[BarLookBack](low) THEN 
      SupportPrice  = low[PivotBAR]
   ENDIF
ENDIF
IF high[PivotBAR] > highest[LookBack](high)[BarLookBack] THEN
   IF high[PivotBAR]  = highest[BarLookBack](high) THEN 
      ResistancePrice = high[PivotBAR]//high[BarIndex - MyResistance]
   ENDIF
ENDIF
EmaResistance  = average[p,Type](ResistancePrice)
EmaSupport     = average[p,Type](SupportPrice)
MidLine        = EmaSupport + ((EmaResistance - EmaSupport) / 2)
]] 


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


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