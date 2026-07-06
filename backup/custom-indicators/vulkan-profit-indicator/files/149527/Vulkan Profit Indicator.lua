-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73343

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
    indicator:name(" Vulkan Profit Indicato");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 
	indicator.parameters:addBoolean("Show", "Show Lines", "", false);
	
    indicator.parameters:addGroup("Tunnel Caclculation");
    indicator.parameters:addInteger("Period1", "1. Period", "", 18);  
    indicator.parameters:addInteger("Period2", "2. Period", "", 28);
	
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	

    indicator.parameters:addGroup("Signal Caclculation");
    indicator.parameters:addInteger("Period3", "1. Period", "", 5);  
    indicator.parameters:addInteger("Period4", "2. Period", "", 8);
	
    indicator.parameters:addString("PriceSignal", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("PriceSignal", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("PriceSignal", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("PriceSignal", "LOW", "", "low");
    indicator.parameters:addStringAlternative("PriceSignal","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("PriceSignal", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("PriceSignal", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("PriceSignal", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("MethodSignal", "MA Method", "Method" , "WMA");
    indicator.parameters:addStringAlternative("MethodSignal", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MethodSignal", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MethodSignal", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MethodSignal", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MethodSignal", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MethodSignal", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MethodSignal", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MethodSignal", "WMA", "WMA" , "WMA");	 	
 	
	
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Long Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Short Arrow", "" , core.COLOR_DOWNCANDLE);	
    indicator.parameters:addColor("clrEXUP", "Exit Long Arrow", "" ,core.COLOR_UPCANDLE );
    indicator.parameters:addColor("clrEXDN",  "Exit Short Arrow", "" ,  core.COLOR_DOWNCANDLE);
	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 


	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(128, 128, 128)); 	 
	 indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color4", "4. Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Signal;	
local first;
local source = nil;  
local Bar;	
local up, down;


-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	Signal=instance.parameters.Signal;
    Show = instance.parameters.Show;	
	
    Period1 = instance.parameters.Period1;
 	Period2 = instance.parameters.Period2;   
	Method = instance.parameters.Method; 
	Price = instance.parameters.Price;
	
	Period3 = instance.parameters.Period3;
 	Period4 = instance.parameters.Period4;   
	MethodSignal = instance.parameters.MethodSignal;  
	PriceSignal = instance.parameters.PriceSignal;	

 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    MA1 = core.indicators:create(Method, source[Price], Period1 );	
    MA2 = core.indicators:create(Method, source[Price], Period2 );	
	
    MA3 = core.indicators:create(MethodSignal, source[PriceSignal], Period3 );	
    MA4 = core.indicators:create(MethodSignal, source[PriceSignal], Period4 );		
	first=math.max(MA1.DATA:first(),MA2.DATA:first(), MA3.DATA:first(),MA4.DATA:first()); 	
 
	
	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	Long = instance:createTextOutput ("Long", "Long", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    Short = instance:createTextOutput ("Short", "Short", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
 
 
    CloseShort = instance:createTextOutput ("CloseShort", "CloseShort", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom,  instance.parameters.clrEXDN, 0);
    CloseLong = instance:createTextOutput ("CloseLong", "CloseLong", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top,instance.parameters.clrEXUP, 0);
	
	
	if Show then
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
	
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);

    Line3 = instance:addStream("Line3", core.Line, name, "3. Line", instance.parameters.color3, first );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style);

    Line4 = instance:addStream("Line4", core.Line, name, "4. Line", instance.parameters.color4, first );
    Line4:setPrecision(math.max(2, instance.source:getPrecision()));
    Line4:setWidth(instance.parameters.width);
    Line4:setStyle(instance.parameters.style);	
	
	else
    Line1 = instance:addInternalStream(0, 0);		
    Line2 = instance:addInternalStream(0, 0);		
    Line3 = instance:addInternalStream(0, 0);		
    Line4 = instance:addInternalStream(0, 0);			
	end
	
end


function Update(period, mode)

    MA1:update(core.UpdateLast);
    MA2:update(core.UpdateLast);
    MA3:update(core.UpdateLast);
    MA4:update(core.UpdateLast);	
	
	if period <= first
	or not source:hasData(period)
	then
        return;
    end 
	
	Line1[period]=MA1.DATA[period];
	Line2[period]=MA2.DATA[period];
	Line3[period]=MA3.DATA[period];
	Line4[period]=MA4.DATA[period];
 
 
    Long:setNoData(period);
    Short:setNoData(period);	
    CloseShort:setNoData(period);
    CloseLong:setNoData(period);
    Bar[period]=Bar[period-1];	
	
	
	local min0=math.min( MA1.DATA[period] ,  MA2.DATA[period]  ) 
	local max0=math.max( MA1.DATA[period] ,  MA2.DATA[period]  ) 
	local min1=math.min( MA1.DATA[period-1] ,  MA2.DATA[period-1]  ) 
	local max1=math.max( MA1.DATA[period-1] ,  MA2.DATA[period-1]  ) 
	
	local Delta=(source.high[period] - source.low[period])/3;
	
    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if    MA3.DATA[period] > max0   and   MA4.DATA[period] > max0 
	and  (MA3.DATA[period-1] <=max1 or MA4.DATA[period-1] <=max1)
	then	
    Long:set(period, source.low[period], "\254", source.low[period]);	
    Bar[period]=  1;	
	
    elseif  MA3.DATA[period] < min0 
    and   MA4.DATA[period] < min0
	and ( MA4.DATA[period-1] >=min1 or MA3.DATA[period-1] >=min1 )
		then
 	Bar[period]= -1;
    Short:set(period, source.high[period], "\254", source.high[period]);	      
    end
	
	
    if   (( MA3.DATA[period] < MA4.DATA[period] 
	or     MA1.DATA[period] < MA2.DATA[period]) 
	and  Bar[period]==1)
    or(Bar[period]==-1	
    and Bar[period-1]==1)
	then
    CloseLong:set(period, source.high[period]+Delta, "\253", source.high[period]+Delta);	
    Bar[period]=  2;	 

	elseif   ((MA3.DATA[period] > MA4.DATA[period]
	or     MA1.DATA[period] > MA2.DATA[period]) 
	and  Bar[period]==-1) 
    or(Bar[period]==1	
    and Bar[period-1]==-1)	
	then	 
    CloseShort:set(period, source.low[period]-Delta, "\253", source.low[period]-Delta);	
    Bar[period]=  -2;
    end	
	
end

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