
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63645

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("GRaB Candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("length", "Look back Length", "",100);
	indicator.parameters:addInteger("emaPeriod", "EMA Period", "",34);
	
	indicator.parameters:addBoolean("showmidline", "Show Midline", "", true);
	indicator.parameters:addBoolean("showrange", "Show Range", "", true);
	indicator.parameters:addBoolean("showWave", "Show Wave", "", true);
	

     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up in Up Trend bar color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownUp", "Down in Up Trend bar color", "", core.rgb(0, 200, 0));
	
	indicator.parameters:addColor("UpDown", "Up in Down Trend bar color", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend bar color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("UpNeutral", "Up in Neutral Trend bar color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("DownNeutral", "Down in Neutral Trend bar color", "", core.rgb(100, 100, 100));
	
	indicator.parameters:addGroup("EMA Line Style");
	indicator.parameters:addColor("waveClose", "Wave Close Line color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("waveHigh", "Wave High Line color", "", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("waveLow", "Wave Low Line color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Range Line Style");
	indicator.parameters:addColor("MMLH", "Range High Line color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("MMLL", "Range Low Line color", "", core.rgb(128, 128, 128));	
	indicator.parameters:addColor("MMLM", "Range Midline Line color", "", core.rgb(128, 128, 128));
end

 

local first;
local source = nil;
local emaHigh, emaLow, emaClose; 
local length;
local UpUp,DownUp, UpDown, DownDown, UpNeutral, DownNeutral;
local emaPeriod;
local showmidline,showrange, showWave;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local volume=nil;

local waveHigh, waveLow, waveClose;
local MMLL, MMLM,MMLH;


function Prepare(nameOnly)
 
    source = instance.source;

	length = instance.parameters.length;
	emaPeriod = instance.parameters.emaPeriod;
	showmidline = instance.parameters.showmidline;
	showrange = instance.parameters.showrange;
	showWave = instance.parameters.showWave;
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. length  .. ", " .. emaPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	emaClose=core.indicators:create("EMA", source.close, emaPeriod);
	emaHigh=core.indicators:create("EMA", source.high, emaPeriod);
	emaLow=core.indicators:create("EMA", source.low, emaPeriod);
    first = emaClose.DATA:first();
  
    UpUp = instance.parameters.UpUp;
	DownUp = instance.parameters.DownUp;
	UpDown = instance.parameters.UpDown;
	DownDown = instance.parameters.DownDown;
	UpNeutral = instance.parameters.UpNeutral;
	DownNeutral = instance.parameters.DownNeutral;
	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
	volume = instance:addStream("volume", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close, volume);
	
	if showWave then
	waveClose = instance:addStream("waveClose", core.Line, name, "", instance.parameters.waveClose, first);
    waveHigh = instance:addStream("waveHigh", core.Line, name, "", instance.parameters.waveHigh, first);
    waveLow = instance:addStream("waveLow", core.Line, name, "", instance.parameters.waveLow, first);
	else
	waveClose = instance:addInternalStream(first, 0);
	waveHigh = instance:addInternalStream(first, 0);
	waveLow = instance:addInternalStream(first, 0);
	end
	
	if showrange then
		if showmidline then
		MMLM = instance:addStream("MMLM", core.Line, name, "", instance.parameters.MMLM, source:first()+length);
		else
		MMLM = instance:addInternalStream(source:first()+length, 0);
		end
    MMLH = instance:addStream("MMLH", core.Line, name, "", instance.parameters.MMLH, source:first()+length);
    MMLL = instance:addStream("MMLL", core.Line, name, "", instance.parameters.MMLL, source:first()+length);
	else
	MMLM = instance:addInternalStream(source:first()+length, 0);
	MMLL = instance:addInternalStream(source:first()+length, 0);
	MMLH = instance:addInternalStream(source:first()+length, 0);
	end
	
  
end

function Update(period, mode)
	 
	Caculation1(period, mode);
    Caculation2(period, mode);  
end

function Caculation1(period, mode)   
	
	if period < source:first()+length then
	return;
	end 
	
	local min,max=mathex.minmax(source, period-length+1, period);
	local range = max - min
    local midline = min + range / 2;

	
	MMLM[period]=midline;
	MMLH[period]=max;
	MMLL[period]=min;
end

function Caculation2(period, mode)


     open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	volume[period] = source.volume[period];

    if period < first then
	
	     if source.close[period]> source.open[period] then
		 open:setColor(period, UpNeutral);
		 else
		 open:setColor(period, DownNeutral);
		 end 
	return;
	end
	emaClose:update(mode);
    emaLow:update(mode);
	emaHigh:update(mode);
	
	
	waveClose[period]=emaClose.DATA[period];
	waveHigh[period]=emaHigh.DATA[period];
	waveLow[period]=emaLow.DATA[period];
	 
	 if source.close[period]> emaLow.DATA[period] then
		 if source.close[period]> source.open[period] then
		 open:setColor(period, UpUp);
		 else
		 open:setColor(period, DownUp);
		 end
	 elseif source.close[period]< emaHigh.DATA[period] then
	      if source.close[period]> source.open[period] then
		 open:setColor(period, UpDown);
		 else
		 open:setColor(period, DownDown);
		 end
	 else
	     if source.close[period]> source.open[period] then
		 open:setColor(period, UpNeutral);
		 else
		 open:setColor(period, DownNeutral);
		 end
	 end
	 
end
 