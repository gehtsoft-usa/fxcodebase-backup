-- Id: 23671
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67278
-- Id: 

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("RSIOMA abstract");
    indicator:description("RSIOMA abstract");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period", "Period", "", 10);
	
	
	indicator.parameters:addInteger("RSI_Period", "RSI Period", "", 10);
	
 
	
    indicator.parameters:addString("SMethod", "Smooth method", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SMethod", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("SPeriod", "Smooth period", "", 14);


    indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	
	indicator.parameters:addColor("Up_Cross", "Up Cross", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("Down_Cross", "Down Cross", "", core.rgb(255, 0, 255));
	
	 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	 indicator.parameters:addInteger("Size", "Size", "", 10);
end

local first;
local source = nil;
local Method;
local Period;
local SMethod;
local SPeriod;
 
 
local MA;
local rsi;
local SignalMA;
 
local RSI=nil;
local Signal=nil;
local RSI_Period;

local Up,Down,Neutral,Transparency;
local Up_Cross,Down_Cross; 
local font_1,font_2;
local Size;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    SMethod=instance.parameters.SMethod;
    SPeriod=instance.parameters.SPeriod;
    RSI_Period=instance.parameters.RSI_Period;
	
   Up = instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral;
   
   
    Up_Cross = instance.parameters.Up_Cross;
   Down_Cross= instance.parameters.Down_Cross;
   
   Size= instance.parameters.Size;
   
   font_1 = core.host:execute("createFont", "Wingdings", Size, false, false);
   font_2 = core.host:execute("createFont", "Arial", Size*2, false, false);

   
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.SMethod .. ", " .. instance.parameters.SPeriod   .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	 
	
   
     
    MA = core.indicators:create("AVERAGES", source, Method, Period, false);
    rsi = core.indicators:create("RSI", MA.DATA, RSI_Period);	 
	
	SignalMA = core.indicators:create("AVERAGES", rsi.DATA, SMethod, SPeriod, false);
	
	
	Zero = instance:addStream("Zero", core.Line, name .. ".Zero", "Zero", Neutral,  SignalMA.DATA:first());
    Zero:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", Neutral,  SignalMA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    
    
	instance:createChannelGroup("Group","Group" , Signal, Zero, Neutral, Transparency);
	 
	
 
end

function Update(period, mode)
 
   
    MA:update(mode);  
	rsi:update(mode);
	SignalMA:update(mode);
	
	
	core.host:execute ("removeLabel", source:serial(period));
	
	 if period < SignalMA.DATA:first() then
	 return;
	 end
	 
	 if rsi.DATA[period]> 50 then
     Signal[period]=1;
	 Signal:setColor(period, Up);
	 elseif rsi.DATA[period]< 50 then
	 Signal[period]=-1;
	 Signal:setColor(period, Down);
	 else
	 Signal[period]=0;
	 Signal:setColor(period, Neutral);
	 end
 
 
     if Signal[period]~= Signal[period-1] then
	 Signal:setBreak (period, true);
	 else
	 Signal:setBreak (period, false);
	 end
 
 
 
    if rsi.DATA[period]> SignalMA.DATA[period] 
	and rsi.DATA[period-1]<= SignalMA.DATA[period-1] 
	then
	core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, 0.5, core.CR_CHART, core.H_Center, core.V_Top,font_1, Up_Cross, "\110");
	elseif rsi.DATA[period]< SignalMA.DATA[period] 
	and rsi.DATA[period-1]>= SignalMA.DATA[period-1] 
	then
	core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, -0.5, core.CR_CHART, core.H_Center, core.V_Top,font_1, Down_Cross, "\110");
	end
	
	local Label="Neutral";
	local Color=Neutral;
	if rsi.DATA[period]> SignalMA.DATA[period] 
	and rsi.DATA[period]> 50
	then
    Color=Up;
    Label="Long Only";
    elseif rsi.DATA[period]< SignalMA.DATA[period] 	
	and rsi.DATA[period]< 50
	then
	Label="Short Only";
	Color=Down;
	end
	
	core.host:execute("drawLabel1", 1, 0, core.CR_RIGHT, 0, core.CR_TOP, core.H_Left, core.V_Bottom,font_2, Color, Label);

end

function ReleaseInstance()
       core.host:execute("deleteFont", font_1);
       core.host:execute("deleteFont", font_2);  
end	   
