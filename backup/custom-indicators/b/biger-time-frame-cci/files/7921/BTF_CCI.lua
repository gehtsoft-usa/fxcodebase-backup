-- Id: 3039
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3322

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bigger timeframe CCI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TF", "Time frame to calculate CCI", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("N", "Number of periods for CCI", "", 14, 2, 2000);
	
    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("RSIclr", "Color of CCI", "Color of CCI", core.rgb(0, 255, 0));
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", "CCI Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthCCI","CCI Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "CCI Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Levels");
   
    indicator.parameters:addInteger("overbought", "OverBought Level", "", 100, -1000, 1000);
    indicator.parameters:addInteger("oversold", "OverSold Level","", -100, -1000, 1000);
    indicator.parameters:addInteger("level_overboughtsold_width", "OverBoughtSold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style",  "OverBoughtSold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "OverBoughtSold Color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local source;                   -- the source
 local N;
local TF;

local host;
local CCIout;
local dayoffset,weekoffset;
local Source;
local loading;
function Prepare(nameOnly)

       assert(instance.parameters.oversold < instance.parameters.overbought,  "OverBought must be greater than OverSold");
    source = instance.source;
    host = core.host;

    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

    TF = instance.parameters.TF;
    N = instance.parameters.N;
    extent = N*2;

    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    
    local name = profile:id() .. "(" .. source:name() .. "," .. TF .. "," .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), N*2, 100, 101);
	loading=true;
   
    CCI = core.indicators:create("CCI", Source,N );
    CCIout = instance:addStream("CCIout", core.Line, name .. ".RSI", "RSI", instance.parameters.RSIclr, 0);   
	CCIout:setWidth(instance.parameters.widthCCI);
    CCIout:setStyle(instance.parameters.styleCCI);
    CCIout:setPrecision(2);
	
	CCIout:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCIout:addLevel(0);
   CCIout:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);


end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


-- the function which is called to calculate the period
function Update(period, mode) 
        
         local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
	
	   CCI:update(mode); 	
    
        CCIout[period] = CCI.DATA[p];
  
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end
