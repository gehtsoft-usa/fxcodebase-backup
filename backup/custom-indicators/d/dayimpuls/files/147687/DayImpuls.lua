-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72782

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("Day Impuls");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("per", "1. Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("t3period", "2. Period", "", 8, 1, 2000);
    indicator.parameters:addDouble("b", "Coefficient ", "", 0.7, 0, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(255,0,255)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("color3", "1. Top Line Color", "", core.rgb(218,165,32));
	 indicator.parameters:addColor("color4", "2. Top Line Color", "", core.rgb(0, 255, 255));
	 indicator.parameters:addColor("color5", "1. Bottom Line Color", "", core.rgb(218,165,32));
	 indicator.parameters:addColor("color6", "2. Bottom Line Color", "", core.rgb(0, 100, 0));	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local per, t3period, b; 
local w1, w2, c1, c2, c3, c4;
local N;
-- Routine
 function Prepare(nameOnly)   
 
    
	per=instance.parameters.per;
	t3period=instance.parameters.t3period;
	b=instance.parameters.b;
	source = instance.source
	
	local b2=b*b
	local b3=b2*b
	c1=-b3
	c2=(3*(b2+b3))
	c3=-3*(2*b2+b+b3)
	c4=(1+3*b+b3+3*b2)
 
	local n= t3period 
	local n=1 + 0.5*(n-1)
	w1=2/(n + 1)
	w2=1 - w1
 
 
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  per.. "," ..  t3period .. "," ..  b  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 

	
 
	
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    tf= (s-e)*1440;	
 
	if tf==5 then 
	N=288
	elseif tf==15 then 
	N=96
	elseif tf==30 then 
	N=48
	elseif tf==60 then 
	N=24
	else
	N=288
	end 
	
	
	first=source:first()+math.max(per,N) ; 	
	
	e1= instance:addInternalStream(0, 0);
	e2= instance:addInternalStream(0, 0);
	e3= instance:addInternalStream(0, 0);
	e4= instance:addInternalStream(0, 0);
	e5= instance:addInternalStream(0, 0);
	e6= instance:addInternalStream(0, 0);
	
    DayImp = instance:addStream("DayImp", core.Line, name, "DayImp", instance.parameters.color1, first );
    DayImp:setPrecision(math.max(2, instance.source:getPrecision()));
    DayImp:setWidth(instance.parameters.width);
    DayImp:setStyle(instance.parameters.style);
    DayImp:addLevel(0);	
 

    T3 = instance:addStream("T3", core.Line, name, "T3", instance.parameters.color2, first );
    T3:setPrecision(math.max(2, instance.source:getPrecision()));
    T3:setWidth(instance.parameters.width);
    T3:setStyle(instance.parameters.style);
    T3:addLevel(0);	


    MaxLine = instance:addStream("MaxLine", core.Line, name, "MaxLine", instance.parameters.color3, first );
    MaxLine:setPrecision(math.max(2, instance.source:getPrecision()));
    MaxLine:setWidth(instance.parameters.width);
    MaxLine:setStyle(instance.parameters.style);
    MaxLine:addLevel(0);	
 

    MinLine = instance:addStream("MinLine", core.Line, name, "MinLine", instance.parameters.color5, first );
    MinLine:setPrecision(math.max(2, instance.source:getPrecision()));
    MinLine:setWidth(instance.parameters.width);
    MinLine:setStyle(instance.parameters.style);
    MinLine:addLevel(0);
	
	
    ChanLineMax = instance:addStream("ChanLineMax", core.Line, name, "ChanLineMax", instance.parameters.color4, first );
    ChanLineMax:setPrecision(math.max(2, instance.source:getPrecision()));
    ChanLineMax:setWidth(instance.parameters.width);
    ChanLineMax:setStyle(instance.parameters.style);
    ChanLineMax:addLevel(0);	
 

    ChanLineMin = instance:addStream("ChanLineMin", core.Line, name, "ChanLineMin", instance.parameters.color6, first );
    ChanLineMin:setPrecision(math.max(2, instance.source:getPrecision()));
    ChanLineMin:setWidth(instance.parameters.width);
    ChanLineMin:setStyle(instance.parameters.style);
    ChanLineMin:addLevel(0);	
	
  
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    imp=0 
 
	for i=0,per, 1 do 
	 imp=imp+(source.open[period-i]-source.close[period-i])
	end
	imp=math.floor(imp/source:pipSize())
	 
	if (imp==0 ) then 
	 imp=0.0001
	end 
	if (imp~=0 ) then 
	 imp=-imp
	 DayImp[period]=imp
	end 
 
	ddpo=DayImp[period]
	e1[period]=w1*ddpo + w2*e1[period-1]
	e2[period]=w1*e1[period] + w2*e2[period-1]
	e3[period]=w1*e2[period] + w2*e3[period-1]
	e4[period]=w1*e3[period] + w2*e4[period-1]
	e5[period]=w1*e4[period] + w2*e5[period-1]
	e6[period]=w1*e5[period] + w2*e6[period-1]
	T3[period]=c1*e6[period] + c2*e5[period] + c3*e4[period] + c4*e3[period]	
	
	
	mMax=DayImp[period-N+1]
	mMin=DayImp[period-N+1]
	 
	for i = 0, N-1, 1 do 
		if (mMax<DayImp[period-i]) then 
		mMax=DayImp[period-i]
		end 
		if (mMin>DayImp[period-i]) then 
		mMin=DayImp[period-i]
		end 
	end
	 
	MaxLine[period] = mMax
	MinLine[period] = mMin
	 
	ChanLineMax[period]=mMax/2
	ChanLineMin[period]=mMin/2
 
	

	
 
	
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