-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72422

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
    indicator:name("Trend Line Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 7, 1, 2000);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color2", "Central Line Color", "", core.rgb(0, 0, 255)); 	 
	 indicator.parameters:addColor("color3", "Bottom Line Color", "", core.rgb(0, 255, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
local RSI;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	RSI= core.indicators:create("RSI", source.close, Period);
	first=RSI.DATA:first() ; 
	
	t1= instance:addInternalStream(0, 0);
	t2= instance:addInternalStream(0, 0);
	t3= instance:addInternalStream(0, 0);
	t4= instance:addInternalStream(0, 0);
	 
	b1= instance:addInternalStream(0, 0);
	b2= instance:addInternalStream(0, 0);
	b3= instance:addInternalStream(0, 0);
	b4= instance:addInternalStream(0, 0);	
 
    top= instance:addInternalStream(0, 0);
	

	
	
    resistance = instance:addStream("resistance", core.Line, name, "resistance", instance.parameters.color1, first );
    resistance:setPrecision(math.max(2, instance.source:getPrecision()));
    resistance:setWidth(instance.parameters.width);
    resistance:setStyle(instance.parameters.style);
    resistance:addLevel(0);	
	
    midpoint = instance:addStream("midpoint", core.Line, name, "midpoint", instance.parameters.color2, first );
    midpoint:setPrecision(math.max(2, instance.source:getPrecision()));
    midpoint:setWidth(instance.parameters.width);
    midpoint:setStyle(instance.parameters.style);
    midpoint:addLevel(0);	
	
    support = instance:addStream("support", core.Line, name, "support", instance.parameters.color3, first );
    support:setPrecision(math.max(2, instance.source:getPrecision()));
    support:setWidth(instance.parameters.width);
    support:setStyle(instance.parameters.style);
    support:addLevel(0);		
 
end


function Update(period, mode)

	  RSI:update(mode); 

	 if period <= first then
	 return;
	 end
	 
 
	t4[period]=t4[period-1]  
	t3[period]=t3[period-1] 
	t2[period]=t2[period-1]    
	t1[period]=t1[period-1]     
	
	b4[period]=b4[period-1]   
	b3[period]=b3[period-1]   
	b2[period]=b2[period-1]     
	b1[period]=b1[period-1] 
	--+
	top[period]= top[period-1];
	
	if RSI.DATA[period-4]>70  and source.high[period-4]>source.high[period-3] and source.high[period-4]>source.high[period-2] and source.high[period-4]>source.high[period-1] and source.high[period-4]>source.high[period] and top[period]==0 then
	t4[period]=t3[period] 
	t3[period]=t2[period]  
	t2[period]=t1[period]  
	t1[period]=period-4
	top[period]=6
	elseif RSI.DATA[period-4]<30  and source.low[period-4]<source.low[period-3] and source.low[period-4]<source.low[period-2] and source.low[period-4]<source.low[period-1] and source.low[period-4]<source.low[period] and top[period]==0 then
	b4[period]=b3[period]  
	b3[period]=b2[period] 
	b2[period]=b1[period]  
	b1[period]=period-4
	top[period]=6
	 
	

	end 
	 
	if top[period]>0 then
	top[period]=top[period]-1 
	end 
 
 
 
	if source.high[t2[period]]>source.high[t1[period]] then
	linet1=source.high[t2[period]]-((( period- t2[period])*math.sqrt(  (source.high[t1[period]]-source.high[t2[period]])^2))/ (t1[period]-t2[period] ))
	else
	linet1=source.high[t2[period]]+((( period- t2[period] )*math.sqrt( (source.high[t1[period]]-source.high[t2[period]])^2))/ ( t1[period]-t2[period] ))
	end 
	 
	if  source.high[t3[period]]>source.high[t2[period]] then
	linet2=source.high[t3[period]]-((( period- t3[period] )*math.sqrt( (source.high[t2[period]]-source.high[t3[period]])^2))/ (t2[period]-t3[period]))
	else
	linet2=source.high[t3[period]]+((( period- t3[period] )*math.sqrt( (source.high[t2[period]]-source.high[t3[period]])^2))/ (t2[period]-t3[period]))
	end
	 
	if source.high[t3[period]]>source.high[t1[period]] then
	linet21=source.high[t3[period]]-((( period- t3[period] )*math.sqrt( (source.high[t1[period]]-source.high[t3[period]])^2))/ (t1[period]-t3[period]))
	else
	linet21=source.high[t3[period]]+((( period- t3[period] )*math.sqrt( (source.high[t1[period]]-source.high[t3[period]])^2))/ ( t1[period]-t3[period]))
	end
	 
	if source.high[t4[period]]>source.high[t1[period]] then
	linet3=source.high[t4[period]]-((( period- t4[period] )*math.sqrt( (source.high[t1[period]]-source.high[t4[period]])^2))/ ( t1[period]-t4[period]))
	else
	linet3=source.high[t4[period]]+((( period- t4[period] )*math.sqrt( (source.high[t1[period]]-source.high[t4[period]])^2))/ ( t1[period]-t4[period]))
	end
	 
	if source.high[t4[period]]>source.high[t2[period]] then
	linet31=source.high[t4[period]]-((( period- t4[period] )*math.sqrt( (source.high[t2[period]]-source.high[t4[period]])^2))/ ( t2[period]-t4[period]))
	else
	linet31=source.high[t4[period]]+((( period- t4[period] )*math.sqrt( (source.high[t2[period]]-source.high[t4[period]])^2))/ (  t2[period]-t4[period]))
	end
	 
	if source.high[t4[period]]>source.high[t3[period]] then
	linet32=source.high[t4[period]]-((( period- t4[period] )*math.sqrt( (source.high[t3[period]]-source.high[t4[period]])^2))/ ( t3[period]-t4[period]))
	else
	linet32=source.high[t4[period]]+((( period- t4[period] )*math.sqrt( (source.high[t3[period]]-source.high[t4[period]])^2))/ ( t3[period]-t4[period]))
	end
 
 
  
	if source.low[b2[period]]>source.low[b1[period]] then
	lineb1=source.low[b2[period]]-((( period- b2[period] )*math.sqrt( (source.low[b1[period]]-source.low[b2[period]])^2))/ ( b1[period]-b2[period]))
	else
	lineb1=source.low[b2[period]]+((( period- b2[period] )*math.sqrt( (source.low[b1[period]]-source.low[b2[period]])^2))/ ( b1[period]-b2[period]))
	end
	 
	if source.low[b3[period]]>source.low[b2[period]] then
	lineb2=source.low[b3[period]]-((( period- b3[period] )*math.sqrt( (source.low[b2[period]]-source.low[b3[period]])^2))/ ( b2[period]-b3[period]))
	else
	lineb2=source.low[b3[period]]+((( period- b3[period] )*math.sqrt( (source.low[b2[period]]-source.low[b3[period]])^2))/ ( b2[period]-b3[period]))
	end
	 
	if source.low[b3[period]]>source.low[b1[period]] then
	lineb21=source.low[b3[period]]-((( period- b3[period] )*math.sqrt( (source.low[b1[period]]-source.low[b3[period]])^2))/ ( b1[period]-b3[period]))
	else
	lineb21=source.low[b3[period]]+((( period- b3[period] )*math.sqrt( (source.low[b1[period]]-source.low[b3[period]])^2))/ ( b1[period]-b3[period]))
	end
	 
	if source.low[b4[period]]>source.low[b1[period]] then
	lineb3=source.low[b4[period]]-((( period- b4[period] )*math.sqrt( (source.low[b1[period]]-source.low[b4[period]])^2))/ (b1[period]-b4[period]))
	else
	lineb3=source.low[b4[period]]+((( period- b4[period] )*math.sqrt( (source.low[b1[period]]-source.low[b4[period]])^2))/ ( b1[period]-b4[period]))
	end
	 
	if source.low[b4[period]]>source.low[b2[period]] then
	lineb31=source.low[b4[period]]-((( period- b4[period] )*math.sqrt( (source.low[b2[period]]-source.low[b4[period]])^2))/ (b2[period]-b4[period]))
	else
	lineb31=source.low[b4[period]]+((( period- b4[period] )*math.sqrt( (source.low[b2[period]]-source.low[b4[period]])^2))/ ( b2[period]-b4[period]))
	end
	 
	if source.low[b4[period]]>source.low[b3[period]] then
	lineb32=source.low[b4[period]]-((( period- b4[period] )*math.sqrt( (source.low[b3[period]]-source.low[b4[period]])^2))/ ( b3[period]-b4[period]))
	else
	lineb32=source.low[b4[period]]+((( period- b4[period] )*math.sqrt( (source.low[b3[period]]-source.low[b4[period]])^2))/ ( b3[period]-b4[period]))
	end

	resistance[period]=(linet1+ linet2+ linet21+ linet3+ linet31+ linet32)/6;
	support[period]=(lineb1+ lineb2+ lineb21+ lineb3+ lineb31+ lineb32)/6;
	midpoint[period]=(resistance[period]+support[period])/2;
 
	
end
 
 
 --[[
 if high[barindex-t2]>high[barindex-t1] then
linet1=high[barindex-t2]-(((barindex-t2)*sqrt(square(high[barindex-t1]-high[barindex-t2])))/(t1-t2))
else
linet1=high[barindex-t2]+(((barindex-t2)*sqrt(square(high[barindex-t1]-high[barindex-t2])))/(t1-t2))
endif
 
if high[barindex-t3]>high[barindex-t2] then
linet2=high[barindex-t3]-(((barindex-t3)*sqrt(square(high[barindex-t2]-high[barindex-t3])))/(t2-t3))
else
linet2=high[barindex-t3]+(((barindex-t3)*sqrt(square(high[barindex-t2]-high[barindex-t3])))/(t2-t3))
endif
 
if high[barindex-t3]>high[barindex-t1] then
linet21=high[barindex-t3]-(((barindex-t3)*sqrt(square(high[barindex-t1]-high[barindex-t3])))/(t1-t3))
else
linet21=high[barindex-t3]+(((barindex-t3)*sqrt(square(high[barindex-t1]-high[barindex-t3])))/(t1-t3))
endif
 
if high[barindex-t4]>high[barindex-t1] then
linet3=high[barindex-t4]-(((barindex-t4)*sqrt(square(high[barindex-t1]-high[barindex-t4])))/(t1-t4))
else
linet3=high[barindex-t4]+(((barindex-t4)*sqrt(square(high[barindex-t1]-high[barindex-t4])))/(t1-t4))
endif
 
if high[barindex-t4]>high[barindex-t2] then
linet31=high[barindex-t4]-(((barindex-t4)*sqrt(square(high[barindex-t2]-high[barindex-t4])))/(t2-t4))
else
linet31=high[barindex-t4]+(((barindex-t4)*sqrt(square(high[barindex-t2]-high[barindex-t4])))/(t2-t4))
endif
 
if high[barindex-t4]>high[barindex-t3] then
linet32=high[barindex-t4]-(((barindex-t4)*sqrt(square(high[barindex-t3]-high[barindex-t4])))/(t3-t4))
else
linet32=high[barindex-t4]+(((barindex-t4)*sqrt(square(high[barindex-t3]-high[barindex-t4])))/(t3-t4))
endif
 
// bots
 
if low[barindex-b2]>low[barindex-b1] then
lineb1=low[barindex-b2]-(((barindex-t2)*sqrt(square(low[barindex-b1]-low[barindex-b2])))/(b1-b2))
else
lineb1=low[barindex-b2]+(((barindex-b2)*sqrt(square(low[barindex-b1]-low[barindex-b2])))/(b1-b2))
endif
 
if low[barindex-b3]>low[barindex-b2] then
lineb2=low[barindex-b3]-(((barindex-b3)*sqrt(square(low[barindex-b2]-low[barindex-b3])))/(b2-b3))
else
lineb2=low[barindex-b3]+(((barindex-b3)*sqrt(square(low[barindex-b2]-low[barindex-b3])))/(b2-b3))
endif
 
if low[barindex-b3]>low[barindex-b1] then
lineb21=low[barindex-b3]-(((barindex-b3)*sqrt(square(low[barindex-b1]-low[barindex-b3])))/(b1-b3))
else
lineb21=low[barindex-b3]+(((barindex-b3)*sqrt(square(low[barindex-b1]-low[barindex-b3])))/(b1-b3))
endif
 
if low[barindex-b4]>low[barindex-b1] then
lineb3=low[barindex-b4]-(((barindex-b4)*sqrt(square(low[barindex-b1]-low[barindex-b4])))/(b1-b4))
else
lineb3=low[barindex-b4]+(((barindex-b4)*sqrt(square(low[barindex-b1]-low[barindex-b4])))/(b1-b4))
endif
 
if low[barindex-b4]>low[barindex-b2] then
lineb31=low[barindex-b4]-(((barindex-b4)*sqrt(square(low[barindex-b2]-low[barindex-b4])))/(b2-b4))
else
lineb31=low[barindex-b4]+(((barindex-b4)*sqrt(square(low[barindex-b2]-low[barindex-b4])))/(b2-b4))
endif
 
if low[barindex-b4]>low[barindex-b3] then
lineb32=low[barindex-b4]-(((barindex-b4)*sqrt(square(low[barindex-b3]-low[barindex-b4])))/(b3-b4))
else
lineb32=low[barindex-b4]+(((barindex-b4)*sqrt(square(low[barindex-b3]-low[barindex-b4])))/(b3-b4))
endif
 
 ]]
 

 

 