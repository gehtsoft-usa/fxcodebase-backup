-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74804

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
    indicator:name("Reversal & Breakout Signals Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("len", "Indicator period", "", 20, 1, 2000);
    indicator.parameters:addInteger("malen", "Moving average Indicator period", "", 30, 1, 2000);	
    indicator.parameters:addInteger("vlen", "Volume Strength period", "", 20, 1, 2000);
    indicator.parameters:addDouble("threshold", "Stong Volume Threshold", "", 1.5, 0, 2000); 
    indicator.parameters:addBoolean("trnd", "Trend Based Candles Color", "", true); 
 

	
	 indicator.parameters:addGroup("Line Style");	
     indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
     indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
     indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Upper Level Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Lower Level Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Mid Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color4", "HMA Line Color", "", core.rgb(128, 128, 128)); 
	 
	indicator.parameters:addGroup("Candle Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));	 
	
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
local len, vlen,threshold; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	len=instance.parameters.len;
	malen=instance.parameters.malen;
	vlen=instance.parameters.vlen;
	threshold=instance.parameters.threshold;
	trnd=instance.parameters.trnd;
	
    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;	 
	
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  len.. "," ..   malen .. "," .. vlen .. "," ..  threshold  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	assert(core.indicators:findIndicator("HMA") ~= nil, "Please, download and install HMA.LUA indicator"); 
	
	hma= core.indicators:create("HMA", source.close, malen);
	averagevolume= core.indicators:create("MVA", source.volume, vlen);	
	sh= core.indicators:create("LWMA", source.high, len);	
	sl= core.indicators:create("LWMA", source.low, len);		
 	atr= core.indicators:create("ATR", source, len);
	
	first=math.max(hma.DATA:first(),averagevolume.DATA:first() , sl.DATA:first()) ; 
	
	
	ch = instance:addInternalStream(0, 0);
	cl = instance:addInternalStream(0, 0); 
	breakout = instance:addInternalStream(0, 0); 
	breakdown = instance:addInternalStream(0, 0); 
	bullishbreakout = instance:addInternalStream(0, 0);
	bearishbreakout = instance:addInternalStream(0, 0);
	bullishrej = instance:addInternalStream(0, 0);
	bearishrej = instance:addInternalStream(0, 0);
	state= instance:addInternalStream(0, 0);
	
    UpperLevel = instance:addStream("UpperLevel", core.Line, name, "Upper Level", instance.parameters.color1, first+len );
    UpperLevel:setPrecision(math.max(2, instance.source:getPrecision()));
    UpperLevel:setWidth(instance.parameters.width);
    UpperLevel:setStyle(instance.parameters.style);
	
    LowerLevel = instance:addStream("LowerLevel", core.Line, name, "Lower Level", instance.parameters.color2, first+len );
    LowerLevel:setPrecision(math.max(2, instance.source:getPrecision()));
    LowerLevel:setWidth(instance.parameters.width);
    LowerLevel:setStyle(instance.parameters.style);	
	
    Midline = instance:addStream("Midline", core.Line, name, "Mid Line", instance.parameters.color3, first+len );
    Midline:setPrecision(math.max(2, instance.source:getPrecision()));
    Midline:setWidth(instance.parameters.width);
    Midline:setStyle(instance.parameters.style);	


	open = instance:addStream("openup", core.Line, name, "", core.COLOR_LABEL, first);
    high = instance:addStream("highup", core.Line, name, "", core.COLOR_LABEL, first);
    low = instance:addStream("lowup", core.Line, name, "", core.COLOR_LABEL, first);
    close = instance:addStream("closeup", core.Line, name, "", core.COLOR_LABEL, first);
    instance:createCandleGroup("CandleGroup", "CandleGroup", open, high, low, close);	


	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
	
	
    HMA = instance:addStream("HMA", core.Dot, name, "HMA", instance.parameters.color4, first+len );
    HMA:setPrecision(math.max(2, instance.source:getPrecision()));
    HMA:setWidth(instance.parameters.width);
    HMA:setStyle(instance.parameters.style);	
end


function Update(period, mode)

	hma:update(mode); 
	averagevolume:update(mode); 
	sh:update(mode); 
	sl:update(mode); 
	atr:update(mode);
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];	
	
	if period <= first+len
	or  not source:hasData(period) 
	then
	open:setColor(period, Neutral);		
	return;
	end
	
	HMA[period]=hma.DATA[period];
	
	state[period]=state[period-1];
	UpperLevel[period]=UpperLevel[period-1];
	LowerLevel[period]=LowerLevel[period-1];
	
    rvol=source.volume[period]/averagevolume.DATA[period];
    local strongvol=rvol>threshold	
	
	
	ch[period]= mathex.max(sh.DATA, period-len+1, period);
	cl[period]= mathex.min(sl.DATA, period-len+1, period);	
 
 
	if not (ch[period]<ch[period-1] or ch[period]>ch[period-1]) then
	UpperLevel[period]=ch[period-1]
	elseif not (cl[period]<cl[period-1] or cl[period]>cl[period-1]) then
	LowerLevel[period]=cl[period-1]
	end
	
    Midline[period]=(UpperLevel[period]+LowerLevel[period])/2;
	
	if source.close[period] > source.open[period] then
	candledir = 1
	else
	candledir = -1
	end 
	
	
    if candledir==1 and source.close[period]>UpperLevel[period] and source.open[period]<UpperLevel[period] then
	breakout[period]=1
	else
	breakout[period]=0	
	end
	
	
    if candledir==-1 and source.close[period]<LowerLevel[period] and source.open[period]>LowerLevel[period] then
    breakdown[period]=1
    else
	breakdown[period]=0
    end 	
	

	if (breakout[period]== 1  or ((breakout[period-1] == 1 or breakout[period-2] == 1 or breakout[period-3] == 1 or breakout[period-4]== 1)  and candledir == 1)) and strongvol and not (bullishbreakout[period-1] == 1 or bullishbreakout[period-2] == 1 or bullishbreakout[period-3]== 1) 	then
    bullishbreakout[period]= 1;
    else
    bullishbreakout[period]= 0;
    end
	
	if (breakdown[period]== 1 or ((breakdown[period-1]== 1 or breakdown[period-2] == 1 or breakdown[period-3]== 1  or breakdown[period-4]== 1)  and candledir == -1)) and strongvol and not (bearishbreakout[period-1]== 1 or bearishbreakout[period-2]== 1 or bearishbreakout[period-3]== 1) then
    bearishbreakout[period] =1;
    else
    bearishbreakout[period] =0;	
    end
	
	if (source.low[period] < LowerLevel[period] and source.close[period] > LowerLevel[period]) and not (bullishrej[period-1]== 1 or bullishrej[period-2]== 1 or bullishrej[period-3]== 1 or bullishrej[period-4]== 1)	then
    bullishrej[period] = 1
	else
    bullishrej[period] = 0	
	end
	
	if  (source.high[period] > UpperLevel[period] and source.close[period] < UpperLevel[period]) and not (bearishrej[period-1]== 1 or bearishrej[period-2]== 1 or bearishrej[period-3]== 1 or bearishrej[period-4]== 1)	then
	bearishrej[period]=1;
	else
	bearishrej[period]=0;   
	end
	
	if bullishbreakout[period] == 1  then
	state[period]=1
	elseif bearishbreakout[period]  == 1  then
	state[period]=-1
	elseif
	(source.low[period]> LowerLevel[period] and source.low[period-1]<= LowerLevel[period-1] and state[period]==-1) 
	or 
	(source.high[period] < UpperLevel[period] and source.high[period-1] >= UpperLevel[period-1] and state[period]==1) then
	state[period]=0
	end 
 
 
   
 
	if state[period]==-1 then
		HMA:setColor(period, Down);
		if trnd then
		open:setColor(period, Down);		
		end 
	elseif state[period]==1 then
		HMA:setColor(period, Up);
		if trnd then
		open:setColor(period, Up);
		end 
	end 
 

    up:setNoData(period);
    down:setNoData(period);
	
	
	
	if bullishrej[period]==1 and not (state[period]==-1) then
	up:set(period, source.high[period]+0.25*atr.DATA[period], "\217");	
	elseif bearishrej[period]==1 and not (state[period]==1) then
	down:set(period, source.high[period]+0.25*atr.DATA[period], "\218");	
	end 
	
	if bullishbreakout[period] ==1 then 
	up:set(period, source.low[period]-0.25*atr.DATA[period], "\217");	 
	elseif bearishbreakout[period]==1 then
	down:set(period, source.high[period]+0.25*atr.DATA[period], "\218");	
	open:setColor(period, instance.parameters.Neutral);
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