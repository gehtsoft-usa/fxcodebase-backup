-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69730

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Tenkan Kijun Lines");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("TenkanSenPeriod", "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KijunSenPeriod", "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SenkouSpanPeriod", "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);
    
    indicator.parameters:addColor("m1_color", "m1 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("m1_width", "m1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("m1_style", "m1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("m1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("m5_color", "m5 Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("m5_width", "m5 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("m5_style", "m5 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("m5_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("m15_color", "m15 Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("m15_width", "m15 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("m15_style", "m15 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("m15_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("m30_color", "m30 Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("m30_width", "m30 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("m30_style", "m30 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("m30_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("H1_color", "H1 Color", "Color", core.colors().Pink);
    indicator.parameters:addInteger("H1_width", "H1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("H1_style", "H1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("H1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("H4_color", "H4 Color", "Color", core.colors().Lime);
    indicator.parameters:addInteger("H4_width", "H4 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("H4_style", "H4 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("H4_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("D1_color", "D1 Color", "Color", core.colors().Purple);
    indicator.parameters:addInteger("D1_width", "D1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("D1_style", "D1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("D1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("W1_color", "W1 Color", "Color", core.colors().Brown);
    indicator.parameters:addInteger("W1_width", "W1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("W1_style", "W1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("W1_style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("label_color", "Label Color", "Color", core.COLOR_LABEL );
end

-- Sources v1.3
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf, isBid, instrument)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

    if tf == nil then
        tf = source:barSize()
    end
	if isBid == nil then
		isBid = source:isBid()
    end
    if instrument == nil then
        instrument = source:instrument();
    end

	self.items[id] = core.host:execute("getSyncHistory", instrument, tf, isBid, 100, ids.loaded_id, ids.loading_id)
	return self.items[id];
end
function sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
	for index, ids in pairs(self.ids) do
		if ids.loaded_id == cookie then
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
			ids.loaded = false
			self.allLoaded = false
			return false
		end
	end
	return false
end
function sources:IsAllLoaded()
	if self.allLoaded == nil then
		for index, ids in pairs(self.ids) do
			if not ids.loaded then
				self.allLoaded = false
				return false
			end
		end
		self.allLoaded = true
	end
	return self.allLoaded
end

local source;
local ich = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    src = sources:Request(1, source, "m1");
    ich["m1"] = core.indicators:create("ICH", src, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    src = sources:Request(2, source, "m5");
    ich["m5"] = core.indicators:create("ICH", src, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    src = sources:Request(3, source, "m15");
    ich["m15"] = core.indicators:create("ICH", src, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    src = sources:Request(4, source, "m30");
    ich["m30"] = core.indicators:create("ICH", src, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    src = sources:Request(5, source, "H1");
    ich["H1"] = core.indicators:create("ICH", src, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    src = sources:Request(6, source, "H4");
    ich["H4"] = core.indicators:create("ICH", src, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    src = sources:Request(7, source, "D1");
    ich["D1"] = core.indicators:create("ICH", src, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    src = sources:Request(8, source, "W1");
    ich["W1"] = core.indicators:create("ICH", src, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local m1_pen = 1;
local m5_pen = 2;
local m15_pen = 3;
local m30_pen = 4;
local H1_pen = 5;
local H4_pen = 6;
local D1_pen = 7;
local W1_pen = 8;
local FONT = 9;

function DrawLine(context, id, pen,x_shift)
    ich[id]:update(core.UpdateLast);
    if ich[id].TL:size() == 0 then
        return;
    end
	
	local  shift= (context:right()-context:left())/8;
    _, y = context:pointOfPrice(ich[id].TL[NOW]);
    context:drawLine(pen, context:left(), y, context:right(), y);
    w, h = context:measureText(FONT, id .. " KL", 0);
    context:drawText(FONT, id .. " KL", instance.parameters.label_color, -1, context:right() -(x_shift-1)*shift - w, y - h, context:right()-(x_shift-1)*shift, y, 0);

    _, y = context:pointOfPrice(ich[id].SL[NOW]);
    context:drawLine(pen, context:left(), y, context:right(), y);
    w, h = context:measureText(FONT, id .. " TL", 0);
    context:drawText(FONT, id .. " TL", instance.parameters.label_color, -1, context:right() -(x_shift-1)*shift - w, y - h, context:right()-(x_shift-1)*shift, y, 0);
end

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(m1_pen, context:convertPenStyle(instance.parameters.m1_style), instance.parameters.m1_width, instance.parameters.m1_color);
        context:createPen(m5_pen, context:convertPenStyle(instance.parameters.m5_style), instance.parameters.m5_width, instance.parameters.m5_color);
        context:createPen(m15_pen, context:convertPenStyle(instance.parameters.m15_style), instance.parameters.m15_width, instance.parameters.m15_color);
        context:createPen(m30_pen, context:convertPenStyle(instance.parameters.m30_style), instance.parameters.m30_width, instance.parameters.m30_color);
        context:createPen(H1_pen, context:convertPenStyle(instance.parameters.H1_style), instance.parameters.H1_width, instance.parameters.H1_color);
        context:createPen(H4_pen, context:convertPenStyle(instance.parameters.H4_style), instance.parameters.H4_width, instance.parameters.H4_color);
        context:createPen(D1_pen, context:convertPenStyle(instance.parameters.D1_style), instance.parameters.D1_width, instance.parameters.D1_color);
        context:createPen(W1_pen, context:convertPenStyle(instance.parameters.W1_style), instance.parameters.W1_width, instance.parameters.W1_color);
        context:createFont(FONT, "Arial", context:pointsToPixels(12), context:pointsToPixels(12), 0);
        init = true;
    end
    DrawLine(context, "m1", m1_pen ,1);
    DrawLine(context, "m5", m5_pen ,2 );
    DrawLine(context, "m15", m15_pen ,3 );
    DrawLine(context, "m30", m30_pen ,4 );
    DrawLine(context, "H1", H1_pen ,5 );
    DrawLine(context, "H4", H4_pen ,6 );
    DrawLine(context, "D1", D1_pen  ,7);
    DrawLine(context, "W1", W1_pen ,8 );
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    sources:AsyncOperationFinished(cookie, successful, message, message1, message2);
end