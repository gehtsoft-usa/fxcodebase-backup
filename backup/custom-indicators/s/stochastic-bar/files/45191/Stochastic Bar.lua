-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26334
-- Id: 7920

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Stochastic Bar");
    indicator:description("Stochastic Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Custom");

    indicator.parameters:addGroup("Stochastic Calculation");
	
	indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "FS");

    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");

	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addDouble("OB", "OB Level", "", 80);
    indicator.parameters:addDouble("OS", "OS Level", "", 20);
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("OBC", "Up in OB Zone ", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OSC", "Down in OS Zone ", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(128, 128, 128));
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;
local OB, OS;
local firstPeriod;
local source = nil;

local Transparency;
local STOCHASTIC;
local  open=nil;
local  close=nil;
local K, D;

local No;
-- Routine
function Prepare(nameOnly)
   
   No = instance.parameters.No;
   OB = instance.parameters.OB;
   OS = instance.parameters.OS;
	Transparency= (100 -instance.parameters.Transparency);
	
	 k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
	
	averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;
    
    source = instance.source;

    local name = profile:id() .. " Stochastic: " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD.. "";
    instance:name(name);
	if nameOnly then
		return;
	end
	STOCHASTIC=core.indicators:create("STOCHASTIC",  source, k , d ,sd , averageTypeK , averageTypeD);
	K=STOCHASTIC:getStream(0);
	D=STOCHASTIC:getStream(1);
	
    first = STOCHASTIC:getStream(1):first();

	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);   
    close:setPrecision(math.max(2, instance.source:getPrecision()));
   instance:createChannelGroup("Overlay","Overlay" , open, close,  No, Transparency);
end

-- Indicator calculation routine
function Update(period, mode)


    open[period] = 100;
	close[period] = 0;

	
	open:setColor(period,  No);	

    if period < first  then
    return;
    end	
	
	STOCHASTIC:update(mode);
		
		
	
	    if K[period]> D[period] then
				 if K[period]> OB then
				  open:setColor(period,  instance.parameters.OBC);
				 else
				  open:setColor(period, instance.parameters.Up);
				 end
		elseif K[period]< D[period] then
				if K[period]< OS then
				open:setColor(period, instance.parameters.OSC);
				else
				open:setColor(period, instance.parameters.Dn);
			   end
		else
		open:setColor(period, No);			
	    end
		


end






