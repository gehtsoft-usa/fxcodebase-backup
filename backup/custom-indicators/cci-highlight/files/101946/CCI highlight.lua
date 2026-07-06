-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62576

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Commodity Channel Index with zone and trend highlighting");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addInteger("N", "Number of Periods", "", 17, 2, 1000);	
    indicator.parameters:addInteger("overbought", "Overbought level", "", 100);
    indicator.parameters:addInteger("oversold", "Oversold level", "", -100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", "Line (neutral)", "", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clrCCIUp", "Line (uptrend)", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrCCIDn", "Line (downtrend)", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthCCI", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("fill", "Highlight Areas over/under levels", "", true);

    indicator.parameters:addInteger("transparency", "Highlight transparency (%)", "", 30); 
	 indicator.parameters:addColor("clrFill", "Over Level Fill Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clrBg", "Background Fill Color", "Leave this parameter in its default value", core.COLOR_BACKGROUND);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("level_overboughtsold_width", "Level Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Level Line Style", "", core.LINE_DOT);
    indicator.parameters:addColor("level_overboughtsold_color", "","", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local n;
local source;
local first;
local cci,CCI;
local clr, clrUp, clrDn;

local fill, clrFill, clrBg;
local ob_level;
local ob_highlight1;
local ob_highlight2;
local os_level;
local os_highlight1;
local os_highlight2;
local trend;
function Prepare(onlyName)
    source = instance.source;

    local name;
    n = instance.parameters.N;

    name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    trend = instance:addInternalStream(0, 0);
    
    cci = core.indicators:create("CCI", source, n);
    first = cci.DATA:first();

    clr = instance.parameters.clrCCI;
    clrUp = instance.parameters.clrCCIUp;
    clrDn = instance.parameters.clrCCIDn;


    CCI = instance:addStream("CCI", core.Line, name, "CCI", clr, first);
    CCI:setWidth(instance.parameters.widthCCI);
    CCI:setStyle(instance.parameters.styleCCI);
    CCI:setPrecision(2); 
    CCI:addLevel(0, core.LINE_NONE);
    CCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 

    fill = instance.parameters.fill;
    if fill then
        clrFill = instance.parameters.clrFill;
        clrBg = instance.parameters.clrBg;
        ob_level = instance.parameters.overbought;
        ob_highlight1 = instance:addInternalStream(first, 0);
        ob_highlight2 = instance:addInternalStream(first, 0);
        instance:createChannelGroup("ob", "ob", ob_highlight1, ob_highlight2, clrFill, 100 - instance.parameters.transparency);
        os_level = instance.parameters.oversold;
        os_highlight1 = instance:addInternalStream(first, 0);
        os_highlight2 = instance:addInternalStream(first, 0);
        instance:createChannelGroup("os", "os", os_highlight1, os_highlight2, clrFill, 100 - instance.parameters.transparency);
    end
end

function Update(period, mode)
     
   cci:update(mode);
    if period <= first then
	return;
	end
	
   CCI[period]= cci.DATA[period];
  
  
         trend[period] = trend[period - 1];

        if CCI[period - 1] <= ob_level
		and  CCI[period] > ob_level then
        trend[period] = 1;
        elseif CCI[period - 1] >= os_level
		and CCI[period] < os_level then
        trend[period] = -1;
        end
  
        if trend[period] == 0 then
            CCI:setColor(period, clr);
        elseif trend[period] == 1 then
            CCI:setColor(period, clrUp);
        elseif trend[period] == -1 then
            CCI:setColor(period, clrDn);
        end

		
		 if fill   then
        ob_highlight1[period] = CCI[period];
        ob_highlight1:setColor(period, clrFill);
        ob_highlight2[period] = ob_level;
        if CCI[period] < ob_level then
            if CCI[period - 1] < ob_level then
                ob_highlight1[period] = nil;
            else
                ob_highlight1:setColor(period, clrBg);
            end
        else
            if CCI[period - 1] < ob_level then
                ob_highlight1[period - 1] = CCI[period - 1];
                ob_highlight1:setColor(period - 1, clrBg);
            end
        end
        os_highlight1[period] = CCI[period];
        os_highlight1:setColor(period, clrFill);
        os_highlight2[period] = os_level;

        if CCI[period] > os_level then
            if CCI[period - 1] > os_level then
                os_highlight1[period] = nil;
            else
                os_highlight1:setColor(period, clrBg);
            end
        else
            if CCI[period - 1] > os_level then
               os_highlight1[period - 1] = CCI[period - 1];
               os_highlight1:setColor(period - 1, clrBg);
            end
        end
       end
end
