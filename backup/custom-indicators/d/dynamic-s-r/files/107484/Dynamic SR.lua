
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63736

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

 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Dynamic S&R");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("length", "length", "", 100);
 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("hh", "High High Color", "", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("ll", "Low Low Color", "", core.rgb(255, 0, 0));
	
     indicator.parameters:addColor("mhlc", "Mid. High/Low Color", "", core.rgb(0, 0, 255));

	
	
	indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local hh, hc, ll, lc;
local first;
local source = nil;
 
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
 
local length;
local hhigh,chigh, llow, clow, mhl, mc, mhlc, mcc;
function Prepare(nameOnly)

    hh = instance.parameters.hh;
	ll = instance.parameters.ll;	
	mhlc = instance.parameters.mhlc;
	 
   
    length = instance.parameters.length;
	
	 

	source = instance.source;
	
	
	
	 
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..", ".. length 
	..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	
	first= source:first()+length;
    hhigh = instance:addStream("hhigh", core.Line, name .. ".hhigh", "hhigh", hh,  first);
	llow = instance:addStream("llow", core.Line, name .. ".llow", "llow", ll,  first);
	chigh = instance:addStream("chigh", core.Line, name .. ".chigh", "chigh", hh,  first);
	clow = instance:addStream("clow", core.Line, name .. ".clow", "clow", ll,  first);		 
	
	mhl = instance:addStream("mhl", core.Line, name .. ".mhl", "mhl", mhlc,  first);
	mc = instance:addStream("mc", core.Line, name .. ".mc", "mc", mhlc,  first);	
	
	instance:createChannelGroup("ch1", "ch1", hhigh, chigh, hh, 100 - instance.parameters.transparency);
    instance:createChannelGroup("ch2", "ch2", llow, clow, ll, 100 - instance.parameters.transparency);
    instance:createChannelGroup("ch2", "ch2", mhl, mc, mhlc, 100 - instance.parameters.transparency);
end

-- Indicator calculation routine
function Update(period )
	
    
	
	 if period < first then 
	 return;
	 end
	
 
	  hhigh[period]= mathex.max(source.high, period-length+1, period);
	  chigh[period]= mathex.max(source.close, period-length+1, period);
 	  llow[period]= mathex.min(source.low, period-length+1, period);
	  clow[period]= mathex.min(source.close, period-length+1, period);

		mhl[period] = (hhigh[period]+llow[period])/2;
		mc[period] = (chigh[period]+clow[period])/2;

	 
 end


