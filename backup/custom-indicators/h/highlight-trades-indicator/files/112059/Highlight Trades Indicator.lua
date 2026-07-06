-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64608
-- Id: 18013

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
    indicator:name("Highlight Trades Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Visual");

	indicator.parameters:addColor("buy_color", "Buy Trades Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("buy_transparency", "Transparency of Buy Trades Area", "", 50, 0, 100);
	indicator.parameters:addColor("buy_border_color", "Buy Trades Area Border Color", "", core.rgb(255, 255, 255));
	indicator.parameters:addInteger("buy_border_width", "Buy Trades Area Border Width", "", 1, 1, 5);
	indicator.parameters:addInteger("buy_border_style", "Buy Trades Area Border Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("buy_border_style", core.FLAG_LINE_STYLE);

	indicator.parameters:addColor("sell_color", "Sell Trades Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("sell_transparency", "Transparency of Sell Trades Area", "", 50, 0, 100);
	indicator.parameters:addColor("sell_border_color", "Sell Trades Area Border Color", "", core.rgb(255, 255, 255));
	indicator.parameters:addInteger("sell_border_width", "Sell Trades Area Border Width", "", 1, 1, 5);
	indicator.parameters:addInteger("sell_border_style", "Sell Trades Area Border Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("sell_border_style", core.FLAG_LINE_STYLE);
end

local buy_color;
local buy_transparency;
local buy_border_color;
local buy_border_width;
local buy_border_style;
local sell_color;
local sell_transparency;
local sell_border_color;
local sell_border_width;
local sell_border_style;
local source;

function Prepare(onlyName)
	source = instance.source; 
	local name = profile:id();
    instance:name(name);

    if onlyName then
        return ;
    end
	
	buy_color = instance.parameters.buy_color;
	buy_transparency = instance.parameters.buy_transparency * 2.55;
	buy_border_color = instance.parameters.buy_border_color;
	buy_border_width = instance.parameters.buy_border_width;
	buy_border_style = instance.parameters.buy_border_style;
	sell_color = instance.parameters.sell_color;
	sell_transparency = instance.parameters.sell_transparency * 2.55;
	sell_border_color = instance.parameters.sell_border_color;
	sell_border_width = instance.parameters.sell_border_width;
	sell_border_style = instance.parameters.sell_border_style;
	
	instance:ownerDrawn(true);
end

function Update(period)     
end 

local buy_brush = 1;
local buy_pen = 3;
local sell_brush = 2;
local sell_pen = 4;
local init = false;
function Draw(stage, context)
    if stage ~= 0 then
		return;
	end
	if not init then
		context:createSolidBrush(buy_brush, buy_color);
		context:createSolidBrush(sell_brush, sell_color);
		context:createPen(buy_pen, context:convertPenStyle(buy_border_style), buy_border_width, buy_border_color);
		context:createPen(sell_pen, context:convertPenStyle(sell_border_style), sell_border_width, sell_border_color);
		init = true;
	end
	local enum = core.host:findTable("closed trades"):enumerator();
	local row = enum:next();
	while (row ~= nil) do
		local index_1 = core.findDate(source, row.OpenTime, false);
		local index_2 = core.findDate(source, row.CloseTime, false);
		local x_1 = context:positionOfBar(index_1);
		local x_2 = context:positionOfBar(index_2);
		if x_2 >= context:left() and x_1 <= context:right() then
			if row.BS == "B" then
				context:drawRectangle(buy_pen, buy_brush, x_1, context:top(), x_2, context:bottom(), buy_transparency);
			else
				context:drawRectangle(sell_pen, sell_brush, x_1, context:top(), x_2, context:bottom(), sell_transparency);
			end
		end
		row = enum:next();
	end
end
