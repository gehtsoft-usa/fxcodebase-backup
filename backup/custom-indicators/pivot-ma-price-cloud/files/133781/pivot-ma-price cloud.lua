-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69833

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Pivot-MA-Price cloud");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Selector"); 
    indicator.parameters:addString("tf", "Timeframe", "", "H1");
    indicator.parameters:setFlag("tf", core.FLAG_PERIODS);
	
	
	
	indicator.parameters:addGroup("Selector"); 
	indicator.parameters:addBoolean("Show", "Show Lines", "Show Lines", true);
	indicator.parameters:addBoolean("Show_Cloud", "Show Cloud", "Show Cloud", true);
	
	indicator.parameters:addGroup("Calculation"); 
	
	 indicator.parameters:addInteger("Period1", "1.MA Period","", 100);
	indicator.parameters:addString("Method1", "1. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("Period2", "2.MA Period","", 130);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	 indicator.parameters:addInteger("Period3", "3.MA Period","", 200);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Stochastic Calculation")

	indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 11, 2, 1000)
	indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000)
	indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000)

	indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA")
	indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("MVAT_K", "FS", "FS", "FS")
	
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA")
	indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA")

    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("pivot1_color", "Pivot Up Color", "", core.colors().Green);
    indicator.parameters:addColor("pivot2_color", "Pivot Down Color", "", core.colors().Red);
	indicator.parameters:addColor("pivot3_color", "Pivot Neutral Color", "", core.colors().Gray);
    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
	
	
	indicator.parameters:addGroup("1. Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("2. Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("3. Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("Fractal Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
	indicator.parameters:addInteger("Shift", "Arrow Shift", "", 100 );
end

local source, pivot1, pivot2, p1, p2, line1, line2;
local MA1, MA2, MA3,STOCHASTIC;
local ma1, ma2, ma3;
local first;
local Show;
local Signal;
local up, down;
local Shift;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	Shift=instance.parameters.Shift;
	
	Show=instance.parameters.Show;
	
    pivot1 = core.indicators:create("PIVOT", source, instance.parameters.tf, "Pivot", "HIST");


    MA1 = core.indicators:create(instance.parameters.Method1, source.close, instance.parameters.Period1);
    MA2 = core.indicators:create(instance.parameters.Method2, source.close, instance.parameters.Period2);
    MA3 = core.indicators:create(instance.parameters.Method3, source.close, instance.parameters.Period3);
	
	STOCHASTIC = core.indicators:create("STOCHASTIC", source, instance.parameters.K, instance.parameters.SD, instance.parameters.D, instance.parameters.MVAT_K, instance.parameters.MVAT_D)
	
	first=math.max(MA1.DATA:first(), MA2.DATA:first(), MA3.DATA:first(), STOCHASTIC.D:first());

    p1 = instance:addStream("Pivot", core.Line, name .. ".P1", "P1", instance.parameters.pivot1_color, 0);
    line1 = instance:addInternalStream(0, 0);
    line2 = instance:addInternalStream(0, 0);


    if  instance.parameters.Show_Cloud then
    instance:createChannelGroup("Pivot Channel", "Pivot Channel", line1, line2, instance.parameters.pivot1_color, 100 - instance.parameters.transparency);
	end
    core.host:execute("setTimer", 1, 1);
	
	
	ma1= instance:addStream("ma1" , core.Line, " ma1"," ma1",instance.parameters.color1, first );
	ma1:setWidth(instance.parameters.width1);
    ma1:setStyle(instance.parameters.style1);
    ma1:setPrecision(math.max(2, source:getPrecision()));
	
	ma2= instance:addStream("ma2" , core.Line, " ma2"," ma2",instance.parameters.color2, first );
	ma2:setWidth(instance.parameters.width2);
    ma2:setStyle(instance.parameters.style2);
    ma2:setPrecision(math.max(2, source:getPrecision()));
	
	
	ma3= instance:addStream("ma3" , core.Line, " ma3"," ma3",instance.parameters.color3, first );
	ma3:setWidth(instance.parameters.width3);
    ma3:setStyle(instance.parameters.style3);
    ma3:setPrecision(math.max(2, source:getPrecision()));
	
	Signal= instance:addInternalStream(0, 0);
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.DOWN, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.UP, 0);
end

local loaded = false;

function Update(period, mode)
    pivot1:update(mode);
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	STOCHASTIC:update(mode);
	
	
	
	if period < first then
	return;
	end
	

    p1[period] = pivot1.P[period];
    line1[period] = pivot1.P[period];
    line2[period] = source.close[period];
	
	
	if Show then
	ma1[period]= MA1.DATA[period];
	ma2[period]= MA2.DATA[period];
	ma3[period]= MA3.DATA[period];
	end
	
	
	
	
    if   source.close[period] > pivot1.P[period]  and source.close[period] > MA1.DATA[period] and MA1.DATA[period] > MA2.DATA[period] and MA2.DATA[period] > MA3.DATA[period]   then
        line1:setColor(period, instance.parameters.pivot1_color);
		Signal[period]=1;
    elseif   source.close[period] < pivot1.P[period]  and source.close[period] < MA1.DATA[period] and MA1.DATA[period] < MA2.DATA[period] and MA2.DATA[period] < MA3.DATA[period]   then
        line1:setColor(period, instance.parameters.pivot2_color);
		Signal[period]=-1;
	else 
	
	     line1:setColor(period, instance.parameters.pivot3_color);
	       Signal[period]=0;
         
	
    end
	
	
	 down:setNoData(period);
	 up:setNoData(period);
	
	
	if Signal[period]== 1 
	and STOCHASTIC.K[period]< 20
	and STOCHASTIC.K[period-1]>= 20
	then
	up:set(period, source.high[period] +Shift*source:pipSize() , "\225");
	elseif Signal[period]== -1
	and STOCHASTIC.K[period]> 80
	and STOCHASTIC.K[period-1]<= 80
	then
	down:set(period, source.low[period]-Shift*source:pipSize(), "\226");
	end
	
	
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if pivot1.P:size() ~= 0 then
        if not loaded or p1[NOW] == nil then
            loaded = true;
            instance:updateFrom(0);
        end
    else
        loaded = false;
    end
end