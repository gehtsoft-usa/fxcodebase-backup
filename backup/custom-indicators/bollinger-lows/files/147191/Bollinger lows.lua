-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72651

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
    indicator:name("Bollinger lows");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("MA_Period", "MA Period", "", 30, 1, 2000);
    indicator.parameters:addInteger("r", "Min Max Period", "", 100, 1, 2000);
	
     indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");		
	
    indicator.parameters:addDouble("multi", "Multiplier", "", 2, 0.001, 2);	
	
    indicator.parameters:addInteger("window_len1", "Window Period 1", "", 28, 1, 2000);	
    indicator.parameters:addInteger("window_len2", "Window Period 2", "", 14, 1, 2000);	
	
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);	
    indicator.parameters:addDouble("ATR_Multi", "ATR Multiplier", "", 1, 0 , 2);		
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "", 2, 2, 2000);		
	
    indicator.parameters:addDouble("factor", "Factor", "", 0.001, 0 , 2);		
 
 
 
 
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	 
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);		 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local MA_Period,Price,multi,window_len1,window_len2,r,Period, ATR_Multi,ATR_Period,factor; 
local EMA;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	MA_Period=instance.parameters.MA_Period;
	Price=instance.parameters.Price;
	multi=instance.parameters.multi;
	window_len1=instance.parameters.window_len1;
	window_len2 =instance.parameters.window_len2;
	r=instance.parameters.r;
	Period=instance.parameters.Period;
	ATR_Multi=instance.parameters.ATR_Multi;
	ATR_Period=instance.parameters.ATR_Period;
	factor=instance.parameters.factor;
	
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  MA_Period .. "," ..  Price  .. "," ..  multi  .. "," ..  r .. "," ..  window_len1 .. "," .. window_len2.. "," .. Period.. "," .. ATR_Multi.. "," ..ATR_Period.. "," .. factor  ..  ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	EMA1= core.indicators:create("EMA", source[Price], MA_Period);
	ATR= core.indicators:create("ATR", source , ATR_Period);
	first=math.max(EMA1.DATA:first() ,ATR.DATA:first())  ; 
	
	
	b= instance:addInternalStream(0, 0);
	s= instance:addInternalStream(0, 0); 
    last_open_long= instance:addInternalStream(0, 0); 
    last_open_short= instance:addInternalStream(0, 0);
    spreadvol= instance:addInternalStream(0, 0);	
    cumspreadvol= instance:addInternalStream(0, 0);
	
	highlow= instance:addInternalStream(0, 0);
	vp= instance:addInternalStream(0, 0);
	out= instance:addInternalStream(0, 0);
	vpsmooth= instance:addInternalStream(0, 0);
	
	hb= instance:addInternalStream(0, 0);
	hl= instance:addInternalStream(0, 0);

	lb= instance:addInternalStream(0, 0);
	l1= instance:addInternalStream(0, 0);
	
	trend= instance:addInternalStream(0, 0); 
	highb= instance:addInternalStream(0, 0); 
	lowb= instance:addInternalStream(0, 0); 
	
	EMA2= core.indicators:create("EMA", out, Period);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
	up_arrow = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down_arrow = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center,core.V_Top , instance.parameters.clrDN, 0);
 
 
end


function Update(period, mode)

	  EMA1:update(mode); 
	  ATR:update(mode); 
	  
    up_arrow:setNoData(period);
    down_arrow:setNoData(period);		  

     highlow[period]=source.high[period]-source.low[period];
	 
	 if period <= first then 
	 return;
	 end
	  
    local stddev = multi * mathex.stdev(source[Price], period-MA_Period+1, period)  
	b[period] = EMA1.DATA[period] + stddev;
	s[period] = EMA1.DATA[period] - stddev;
	
	
	last_open_long[period]=last_open_long[period-1];
	last_open_short[period]=last_open_short[period-1];	
	
    if source[Price][period]>  s[period]
	and  source[Price][period-1]<=  s[period-1]
	then
    last_open_long[period]=source.close[period];
    elseif source[Price][period]<  s[period]
	and  source[Price][period-1]>=  s[period-1]
	then	
	last_open_short[period]=source.close[period];
	end
	
 
	 if period < r then
	 return;
	 end
	 
	 
    lowb[period]= mathex.min(last_open_short ,period-r+1,period); 
    highb[period]= mathex.max(last_open_long,period-r+1,period); 	
	
 
	local hilow = ((source.high[period] - source.low[period])*100)
	local openclose = ((source.close[period] - source.open[period])*100)
	spreadvol[period] = (openclose * source[Price][period])
    cumspreadvol[period]=cumspreadvol[period]+spreadvol[period];	 
	
	
	
	if period <window_len1 then
    return;
    end	
 
	local price_spread= mathex.stdev(highlow, period-window_len1+1, period);
	vp[period] =  spreadvol[period] + cumspreadvol[period];
	
	if period <window_len1 + window_len2 then
    return;
    end		
	
	local smooth = mathex.avg(vp, period-window_len2+1,period);
	vpsmooth[period]=vp[period]-smooth;
	
	
	local v_spread = mathex.stdev(vpsmooth, period-window_len1+1, period);
    local shadow = (vp[period] - smooth) / v_spread * price_spread;
	
	
	if shadow > 0  then
	out[period]=source.high[period] + shadow;
	else
	out[period]=source.low[period] + shadow;	
	end
	
	EMA2:update(mode); 	
	if period <= EMA2.DATA:first() then --or not EMA2.DATA:hasData(period)or not ATR.DATA:hasData(period) then
	return;
	end	 
 
    local up= EMA2.DATA[period] - (ATR_Multi * ATR.DATA[period])
    local dn = EMA2.DATA[period] + (ATR_Multi * ATR.DATA[period]) 
 
 
	hb[period]=  hb[period-1] 
	hl[period]=  hl[period-1] 

	lb[period]=  lb[period-1] 
	l1[period]=  l1[period-1]  
	 
	trend[period]=  trend[period-1]  
	
	
	local n = dn
	local x =up	
	
	
	
	
	if trend[period]==0 or trend[period]==nil  then
		if x >= hb[period-1] then
			hb[period]= x
			hl[period]= source.close[period];
			trend[period]= 1  
			 
		else
			lb[period]= n
			l1[period]= source.close[period] 
			trend[period]= -1 
		end
	
	else

					    if trend[period-1] > 0   then
								hl[period]=  math.max(hl[period-1], source.close[period])
								if x >= hb[period-1]  then
									hb[period]= x
								  
								else

									
									if n < hb[period-1] - hb[period-1] * factor  then
										lb[period]= n
										l1[period]= source.close[period]

										trend[period]= -1   
									end	
								end	
						else

						   
							l1[period] = math.min(l1[period-1], source.close[period] )

							if n <= lb[period-1]   then
								lb[period]= n 
								 
							else

							   
								if x > lb[period-1] + lb[period-1] * factor then
									hb[period]= x 
									hl[period]= source.close[period]

									trend[period]= 1  
									 
								end	
                            end 
						end

       end
		 
	if trend[period]==1 then
	Line[period]= hb[period];
    elseif trend[period]==-1 then
	Line[period]= lb[period];	
    end
	
	
	
	if Line[period]> lowb[period]
	and  Line[period-1]<= lowb[period-1] 
	then
    up_arrow:set(period, source.low[period], "\217", source.low[period]);	 
	
	elseif Line[period]< highb[period]
	and  Line[period-1]>= highb[period-1] 
	then
    down_arrow:set(period, source.high[period], "\218", source.high[period]);		
	end
	

	
 
end


 




