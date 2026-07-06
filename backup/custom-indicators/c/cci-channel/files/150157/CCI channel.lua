-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73528

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
    indicator:name("CCI channel ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("CCIPeriod", "CCI Period", "", 12, 1, 2000); 
	
    indicator.parameters:addInteger("HighLowPeriod", "High/Low Period", "", 13, 1, 2000);
    indicator.parameters:addInteger("T3Period", "T3 Period", "", 5, 1, 2000);
    indicator.parameters:addDouble("T3Hot", "T3 Hot", "", 0.8, 0, 2000);
	
    indicator.parameters:addBoolean("T3Original", "T3 Original", "", false); 	
 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("colorA", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("colorB", "Down Line Color", "", core.rgb(255, 0, 0)); 	 
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(128, 128, 128)); 


	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 	 
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local CCIPeriod,CCIPrice,  HighLowPeriod,TF,T3Original; 
local Indicator;
local emas={};	
-- Routine
 function Prepare(nameOnly)   
 
    
	CCIPeriod=instance.parameters.CCIPeriod; 
	HighLowPeriod=instance.parameters.HighLowPeriod;
	T3Period=instance.parameters.T3Period;
	T3Hot=instance.parameters.T3Hot;	
	T3Original=instance.parameters.T3Original;
	Signal=instance.parameters.Signal;
	Period=instance.parameters.Period;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  CCIPeriod  .. "," ..    HighLowPeriod .. "," ..  T3Period  .. "," ..  T3Hot .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	

    a  = T3Hot;
    c1 = -a*a*a;
    c2 =  3*(a*a+a*a*a);
    c3 = -3*(2*a*a+a+a*a*a);
    c4 = 1+3*a+a*a*a+3*a*a;

    for i= 0 , 5 , 1 do
	emas[i] = instance:addInternalStream(0, 0);
	end

      if (T3Original) then
      alpha = 2.0/(1.0 + T3Period);
      else
	  alpha = 2.0/(2.0 + (T3Period-1.0)/2.0);	
	  end
	
	CCI= core.indicators:create("CCI", source, CCIPeriod);
	first=CCI.DATA:first() ; 
	
	
	Trend = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.colorA, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
    High = instance:addStream("High", core.Line, name, "High", instance.parameters.color1, first + HighLowPeriod );
    High:setPrecision(math.max(2, instance.source:getPrecision()));
    High:setWidth(instance.parameters.width);
    High:setStyle(instance.parameters.style);
    High:addLevel(0);		
	
    Low = instance:addStream("Low", core.Line, name, "Low", instance.parameters.color2, first + HighLowPeriod  );
    Low:setPrecision(math.max(2, instance.source:getPrecision()));
    Low:setWidth(instance.parameters.width);
    Low:setStyle(instance.parameters.style);
    Low:addLevel(0);	


	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first + HighLowPeriod  );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
    core.host:execute ("attachTextToChart", "Up")
    core.host:execute ("attachTextToChart", "Dn")
 
end


function Update(period, mode)

	CCI:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
	Line[period]= iT3(period);
	
	
	if period <= first + HighLowPeriod
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	local min, max = mathex.minmax(Line, period-HighLowPeriod+1, period);
	High[period]=max;
	Low[period]=min;

    Trend[period] = 0;
    if (Line[period]>=High[period]) then Trend[period] = 1; end
    if (Line[period]<=Low[period])  then Trend[period] =-1; end 
	

    if Line[period] > Line[period-1] then	
    Line:setColor(period, instance.parameters.colorA);	
	else
    Line:setColor(period, instance.parameters.colorB);
    end	
	
    up:setNoData(period);
    down:setNoData(period);

    if Trend[period] == Trend[period-1] then
	return;
	end
	
	if Trend[period]==1
	then
	Bar[period]= 1;
    up:set(period, source.low[period], "\217");	
	elseif Trend[period]==-1
    then	
    down:set(period, source.high[period], "\218");	
	Bar[period]= -1;	
	end
	
end

 
function iT3(period)
 
         emas[0][period] = emas[0][period-1]+alpha*(CCI.DATA[period]-emas[0][period-1]);
         emas[1][period] = emas[1][period-1]+alpha*(emas[0][period]-emas[1][period-1]);
         emas[2][period] = emas[2][period-1]+alpha*(emas[1][period]-emas[2][period-1]);
         emas[3][period] = emas[3][period-1]+alpha*(emas[2][period]-emas[3][period-1]);
         emas[4][period] = emas[4][period-1]+alpha*(emas[3][period]-emas[4][period-1]);
         emas[5][period] = emas[5][period-1]+alpha*(emas[4][period]-emas[5][period-1]);
 
   return(c1*emas[5][period] + c2*emas[4][period] + c3*emas[3][period] + c4*emas[2][period]);
   
   
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