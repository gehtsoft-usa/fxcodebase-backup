-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60616

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
    indicator:name("Multi Fractal");
    indicator:description("Shows multiple types of Fractal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addColor("clrUP", "Up fractal", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Fractal", "", core.COLOR_DOWNCANDLE);
    indicator.parameters:addBoolean("ShowPrice", "Show Fractal Price", "", false);
	indicator.parameters:addBoolean("ShowType", "Show Fractal Type", "", true);
    indicator.parameters:addColor("clrPrice", "Price color", "", core.rgb(128, 128, 128));
end

local source;
local up, down;

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", 9, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 9, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    up1 = instance:createTextOutput ("", "UpL", "Verdana", 7, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
    down1 = instance:createTextOutput ("", "DnL", "Verdana", 7, core.H_Right, core.V_Bottom, instance.parameters.clrPrice, 0);
end

function Update(period, mode)
    if (period > 6) then
		local fractalHi = source.high[period - 2]; 
		local fractalLo = source.low[period - 2];
-- FRACTALS
-- Ideal
--	  |
--	 | |
--	|	|
		if source.high[period - 3] > source.high[period - 4]
		and fractalHi > source.high[period - 3]
		and fractalHi > source.high[period - 1]
		and source.high[period - 1] > source.high[period]
		and source.high[period - 1] > source.high[period - 4]
		and source.high[period - 3] > source.high[period]
		and source.low[period - 3] > source.low[period - 4]
		and fractalLo > source.low[period - 3]
		and fractalLo > source.low[period - 1]
		and source.low[period - 1] > source.low[period]
		and source.low[period - 1] > source.low[period - 4]
		and source.low[period - 3] > source.low[period]
		then 
            up:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Ideal");
            end
-- Flat bottom
--	  |
--	 |||
--	|||||		
		elseif source.high[period - 3] > source.high[period - 4]
		and fractalHi > source.high[period - 3]
		and fractalHi > source.high[period - 1]
		and source.high[period - 1] > source.high[period]
		and source.high[period - 1] > source.high[period - 4]
		and source.high[period - 3] > source.high[period]
		and source.low[period - 3] >= source.low[period - 4]
		and fractalLo >= source.low[period - 3]
		and fractalLo >= source.low[period - 1]
		and source.low[period - 1] >= source.low[period]
		and source.low[period - 1] >= source.low[period - 4]
		and source.low[period - 3] >= source.low[period]
		then 
            up:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Flat bottom");
            end
-- Flat top
--	|||||
--	|| ||
--	|   |
		elseif source.high[period - 3] >= source.high[period - 4]
		and fractalHi >= source.high[period - 3]
		and fractalHi >= source.high[period - 1]
		and source.high[period - 1] >= source.high[period]
		and source.high[period - 1] >= source.high[period - 4]
		and source.high[period - 3] >= source.high[period]
		and source.low[period - 3] > source.low[period - 4]
		and fractalLo > source.low[period - 3]
		and fractalLo > source.low[period - 1]
		and source.low[period - 1] > source.low[period]
		and source.low[period - 1] > source.low[period - 4]
		and source.low[period - 3] > source.low[period]
		then 
            up:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Flat top");
            end
-- Uptrend
--	  ||
--	 |  |
--	|
		elseif source.high[period - 3] > source.high[period - 4]
		and fractalHi > source.high[period - 3]
		and fractalHi >= source.high[period - 1]
		and source.high[period - 1] >= source.high[period]
		and source.high[period - 1] > source.high[period - 4]
		and source.low[period - 3] > source.low[period - 4]
		and fractalLo > source.low[period - 3]
		and source.low[period - 1] > source.low[period - 3]
		and source.low[period] > source.low[period - 3]
		then
			up:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Uptrend");
            end
-- Downtrend
--	 ||
--	|  |
--		|
		elseif source.high[period - 1] > source.high[period]
		and fractalHi > source.high[period - 1]
		and fractalHi >= source.high[period - 3]
		and source.high[period - 3] >= source.high[period - 4]
		and source.high[period - 3] > source.high[period]
		and source.low[period - 1] > source.low[period]
		and fractalLo > source.low[period - 1]
		and source.low[period - 3] > source.low[period - 1]
		and source.low[period - 3] > source.low[period]
		then
			up:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Downtrend");
            end
        else
            up:setNoData(period - 2);
            up1:setNoData(period - 2);
		end
-- Ideal
--	|   |
--	 | |
--	  |
		if source.low[period - 3] < source.low[period - 4]
		and fractalLo < source.low[period - 3]
		and fractalLo < source.low[period - 1]
		and source.low[period - 1] < source.low[period]
		and source.low[period - 1] < source.low[period - 4]
		and source.low[period - 3] < source.low[period]
		and source.high[period - 3] < source.high[period - 4]
		and fractalHi < source.high[period - 3]
		and fractalHi < source.high[period - 1]
		and source.high[period - 1] < source.high[period]
		and source.high[period - 1] < source.high[period - 4]
		and source.high[period - 3] < source.high[period]
		then
            down:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Ideal");
            end
-- Flat top
-- |||||
--	|||
-- 	 |
		elseif source.low[period - 3] < source.low[period - 4]
		and fractalLo < source.low[period - 3]
		and fractalLo < source.low[period - 1]
		and source.low[period - 1] < source.low[period]
		and source.low[period - 1] < source.low[period - 4]
		and source.low[period - 3] < source.low[period]
		and source.high[period - 3] <= source.high[period - 4]
		and fractalHi <= source.high[period - 3]
		and fractalHi <= source.high[period - 1]
		and source.high[period - 1] <= source.high[period]
		and source.high[period - 1] <= source.high[period - 4]
		and source.high[period - 3] <= source.high[period]
		then
            down:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Flat Top");
            end
-- Flat bottom
--	|	|
--	|| ||
--	|||||
		elseif source.low[period - 3] <= source.low[period - 4]
		and fractalLo <= source.low[period - 3]
		and fractalLo <= source.low[period - 1]
		and source.low[period - 1] <= source.low[period]
		and source.low[period - 1] <= source.low[period - 4]
		and source.low[period - 3] <= source.low[period]
		and source.high[period - 3] < source.high[period - 4]
		and fractalHi < source.high[period - 3]
		and fractalHi < source.high[period - 1]
		and source.high[period - 1] < source.high[period]
		and source.high[period - 1] < source.high[period - 4]
		and source.high[period - 3] < source.high[period]
		then
            down:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Flat Bottom");
            end
-- Uptrend
--	    |
--	|  |
--	 ||
		elseif source.low[period - 1] < source.low[period]
		and fractalLo < source.low[period - 1]
		and fractalLo <= source.low[period - 3]
		and source.low[period - 3] <= source.low[period - 4]
		and source.low[period - 3] < source.low[period]
		and source.high[period - 1] < source.high[period]
		and fractalHi < source.high[period - 1]
		and source.high[period - 3] < source.high[period - 1]
		and source.high[period - 3] < source.high[period]		
		then
			down:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Uptrend");
            end
		elseif source.low[period - 3] < source.low[period - 4]
		and fractalLo < source.low[period - 3]
		and fractalLo <= source.low[period - 1]
		and source.low[period - 1] <= source.low[period]
		and source.low[period - 1] < source.low[period - 4]
		and source.high[period - 3] < source.high[period - 4]
		and fractalHi < source.high[period - 3]
		and source.high[period - 1] < source.high[period - 3]
		and source.high[period] < source.high[period - 3]
		then 
			down:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Downtrend");
            end
        else
            down:setNoData(period - 2);
            down1:setNoData(period - 2);
        end		
    end
end
