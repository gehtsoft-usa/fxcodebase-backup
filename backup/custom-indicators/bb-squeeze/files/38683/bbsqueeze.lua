-- Id: 7132
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22407

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
    indicator:name("BB Squeeze");
    indicator:description("BB Squeeze");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BP", "Bollinger Period", " ", 20);
	indicator.parameters:addDouble("BD", "Bollinger Deviations", " ", 2);
	
	indicator.parameters:addInteger("KP", "Keltner Period", " ", 20);
	indicator.parameters:addDouble("KF", "Keltner Factor", " ", 1.5);
	
	indicator.parameters:addDouble("MP", "Momentum Period", " ", 12);
	 indicator.parameters:addString("MS", "Momentum smoothing method", "", "MVA");
	  indicator.parameters:addStringAlternative("MS", "No smoothing", "", "NO");
    indicator.parameters:addStringAlternative("MS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MS", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MS", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MS", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MS", "Wilders", "", "WMA");
	indicator.parameters:addDouble("MSP", "Momentum Smoothing Period", " ", 20);
	indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BBS_up", "Color of Up Momentum", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("BBS_dn", "Color of Down Momentum", " ", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("yes", "BBS Squeeze Color", " ", core.rgb(0, 0, 255));
	  indicator.parameters:addColor("no", "No BBS Squeeze Color", " ", core.rgb(128, 128, 128));
	  indicator.parameters:addInteger("Size", "Font Size", " ", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local BP,BD,KP,KF,MP,MS;
local Size;
local first;
local source = nil;
local yes,no;
-- Streams block
local BBS = nil;
local ATR, Momentum, M,MSP, Def;
local Signal,signal;
-- Routine
function Prepare(nameOnly)
    BP = instance.parameters.BP;
    BD = instance.parameters.BD;
	KP = instance.parameters.KP;
	KF = instance.parameters.KF;
	MP = instance.parameters.MP;
    MS = instance.parameters.MS;
	MSP= instance.parameters.MSP;
	Signal= instance.parameters.Signal;
	Size= instance.parameters.Size;
    source = instance.source;
	
	
	    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(BP)  .. ", " .. tostring(BP) .. ", " .. tostring(KP) .. ", " .. tostring(KF) .. ", " .. tostring(MP).. ", " .. tostring(MS).. ", " .. tostring(MSP).. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	 ATR = core.indicators:create("ATR", source, KP);
     Momentum=instance:addInternalStream (0, 0); 
	 Def=instance:addInternalStream (0, 0); 
	 
	if MS ~= "NO" then	 
		local profile = core.indicators:findIndicator(MS);
		assert(profile ~= nil, "Please, download and install " .. MS .. ".LUA indicator");
		M = core.indicators:create( MS, Momentum, MSP);
	   	first = math.max(MP, BP, KP, M.DATA:first());
	else
	  	first = math.max(MP, BP, KP);
	end
	
    first = math.max(MP, BP, KP);



	
	     if Signal then
		 signal = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.yes, first);
		 signal:setStyle(core.LINE_NONE); 
		 
		 else
		 signal=instance:addInternalStream (0, 0);
		 end
        BBS = instance:addStream("BBSR", core.Line, name, "Momentum", instance.parameters.BBS_up, first);
		instance:createChannelGroup ("BBSL", "BBSL", BBS, Def,instance.parameters.BBS_up, 100);
		 yes = instance:createTextOutput ("yes", "yes", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.yes);
		 no = instance:createTextOutput ("no", "no", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.no);
		 
	    signal:setPrecision(math.max(2, instance.source:getPrecision()));	
	     BBS:setPrecision(math.max(2, instance.source:getPrecision()));	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    signal[period]=99.9999;

     if period < first or not source:hasData(period) then
	 return;
	 end
	 Def[period]= 100;
	  ATR:update(mode);
	 
    Momentum[period]=source.close[period]*100./source.close[period-MP];
    local Dev = mathex.stdev(source.close, period - BP + 1, period);
	
	 if MS ~= "NO" then
	 M:update(mode);
	  BBS[period]=  M.DATA[period];
	 else
	 BBS[period]=  Momentum[period];
	 end
	 
	 if BBS[period] >BBS[period-1] then
	  BBS:setColor(period,instance.parameters.BBS_up);
	 else
	  BBS:setColor(period,instance.parameters.BBS_dn);
	 end
    
       if  (Dev * BD) / (ATR.DATA[period] * KF) < 1 then
	   yes:set(period, 100, "\108");
	   signal[period]=100;
	   else
	   no:set(period, 100, "\108");
	   signal[period]=99.9999;
	   end
	   
    
end

