-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74793

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volume Supertrend AI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("k", "Neighbors", "", 3, 1, 100);
    indicator.parameters:addInteger("m", "Slow MA", "", 10, 1, 2000);

    indicator.parameters:addInteger("Len1", "Price Trend", "", 2, 1, 500);
    indicator.parameters:addInteger("Len2", "Price Trend", "", 100, 1, 2000);	
 
    indicator.parameters:addBoolean("aisignals", "AI Trend Signals", "", true);
 
    indicator.parameters:addInteger("len", "Length", "", 10, 1, 500);
    indicator.parameters:addDouble("factor", "Factor", "", 3, 0, 2000); 
 
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
	
	indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Neutral Line Color", "", core.rgb(0, 0, 255)); 	

	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20);  	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local k, m,n,KNNPriceLen,  KNNSTlen; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	k=instance.parameters.k;
	m=instance.parameters.m;
	n = math.max(k,m)
	
	
	Len1=instance.parameters.Len1;
	Len2=instance.parameters.Len2;
	aisignals=instance.parameters.aisignals;
	len =instance.parameters.len;
	factor=instance.parameters.factor;
	
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  k.. "," ..  m ..  "," .. Len1  .. "," .. Len2 .. len .. "," .. factor  .. "," .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	closevolume = instance:addInternalStream(0, 0);
	direction = instance:addInternalStream(0, 0);
    mysupertrend = instance:addInternalStream(0, 0);	
	upperband = instance:addInternalStream(0, 0);
	lowerband = instance:addInternalStream(0, 0);
	label = instance:addInternalStream(0, 0);
	
	ATR= core.indicators:create("ATR", source, len);
	WMA1= core.indicators:create("WMA", source.close, Len1);
	WMA2= core.indicators:create("WMA", mysupertrend, Len2);
 
	first=ATR.DATA:first() ; 
	
 
	
    currentsupertrend = instance:addStream("currentsupertrend", core.Line, name, "Current Super Trend", instance.parameters.color1, first  );
    currentsupertrend:setPrecision(math.max(2, instance.source:getPrecision()));
    currentsupertrend:setWidth(instance.parameters.width);
    currentsupertrend:setStyle(instance.parameters.style);
 	

 	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.color1, 0);
    down = instance:createTextOutput ("Down", "Down", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.color2, 0);
    start = instance:createTextOutput ("Start", "Start", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Center, instance.parameters.color3, 0);	
end


function Update(period, mode)

	ATR:update(mode); 
    up:setNoData(period);
    down:setNoData(period);
    start:setNoData(period);	
	
	closevolume[period]= source.close[period]*source.volume[period];

	if period <= first  
	or  not source:hasData(period) 
	then
	
	direction[period]=1;
	upperband[period] = source.close[period];
	lowerband[period] = source.close[period];
	return;
	end
	
	
	direction[period]=direction[period-1];
	
	local vwma=mathex.avg(closevolume, period-len+1, period) / mathex.avg(source.volume, period-len+1, period)
	  
	  	
	upperband[period] = vwma + factor*ATR.DATA[period];
    lowerband[period] = vwma - factor*ATR.DATA[period];	
	
	
	
	
	
 
 
	if not (upperband[period] < upperband[period-1] or source.close[period-1] > upperband[period-1]) then 
	upperband[period] = upperband[period-1]
	end  
	if not (lowerband[period] > lowerband[period-1] or source.close[period-1] < lowerband[period-1]) then 
	lowerband[period] = lowerband[period-1]
	end 
	
	
	

 
 
	if mysupertrend[period-1] == upperband[period- 1] then
			if source.close[period] > upperband[period] then
			    direction[period] = -1
			else
				direction[period] = 1
			end	
	else
				if source.close[period] < lowerband[period] then
				direction[period] = 1
				else
				direction[period] = -1
				end 
			 
	end 	
	
	
 
	
	 if direction[period] == -1 then
	 mysupertrend[period] = lowerband[period] 
	 else
	 mysupertrend [period] = upperband[period] 
	 end 
	 
	 if period <= Len1
	 or period <= Len2
     then 
     return;
	 end
	
	local data={};
	local labels={}
	local distances={}; 
	
	
	WMA1:update(mode);
	WMA2:update(mode);
	
   if period < first +Len1 +Len2 then
   return;
   end   
	
    for i=0 , n-1, 1 do
		data[i]=mysupertrend[period-i]
		
		if WMA1.DATA[period-i] > WMA2.DATA[period-i] then
		labels[i] = 1
		else
		labels[i] = 0
		end
     end  
	 
    currentsupertrend[period] = mysupertrend[period]	 
 
	for i = 0 , n-1, 1 do
	distances[i] = math.abs(currentsupertrend[period-i]-data[i])
	end  	 
  
	table.sort(distances);
	
	
	 
	weightedsum=0
	totalweight=0
	for i=0 ,  k-1, 1  do 
	weighti = 1 / (distances[i]+math.pow(10,-6) )
	weightedsum = weighti*labels[i]+weightedsum
	totalweight = weighti+totalweight
	end	
	
	

	label[period] = math.floor(weightedsum / totalweight,2)

	 
	if label[period] == 1 then	
    currentsupertrend:setColor(period, instance.parameters.color1);	 
	elseif label[period] == 0 then
	currentsupertrend:setColor(period, instance.parameters.color2);		 
	else
    currentsupertrend:setColor(period, instance.parameters.color3);		 
	end 	
	
	local starttrendup = label[period] == 1 and label[period-1]~=1 and aisignals
	local starttrenddn = label[period] == 0 and label[period-1]~=0 and aisignals
	local TrendUp = direction[period] == -1 and direction[period-1] == 1 and label[period] == 1 and aisignals
	local TrendDn = direction[period] == 1 and direction[period-1] == -1 and label[period] == 0 and aisignals 
	
	if starttrendup or starttrenddn then 
		start:set(period, currentsupertrend[period], "\108");		
	elseif TrendUp then 
		up:set(period, currentsupertrend[period], "\217");		
	elseif TrendDn then
        down:set(period, currentsupertrend[period], "\218");	
	end 	
 
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+