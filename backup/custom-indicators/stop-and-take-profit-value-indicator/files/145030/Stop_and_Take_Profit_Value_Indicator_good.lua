-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69240

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Stop and Take Profit Value");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("font_size", "Font size", "", 16);
    indicator.parameters:addColor("stop_color", "Stop color", "", core.colors().Red);
    indicator.parameters:addColor("limit_color", "Limit color", "", core.colors().Green);
end

local source;
local offer;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    offer = core.host:findTable("offers"):find("Instrument", source:instrument());
    instance:ownerDrawn(true);
end

function Update(period, mode)
--

 


end

local init = false;
local FONT = 1;

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(instance.parameters.font_size), 0);
    end
	
	local lowestBuyStop=0;
	local highestBuyLimit=0;
	local highestSellStop=0;
	local lowestSellLimit=0;
	local sumBuyStop=0;
	local sumBuyLimit=0;
	local sumSellStop=0;
	local sumSellLimit=0;
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.Instrument == source:instrument() then
            if row.Stop ~= 0 then
                local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, row.AccountID);
                local distance = -math.abs(row.Stop - row.Open) / source:pipSize();
                local cost = distance * offer.PipCost * row.Lot / base_unit_size;
				
				if row.BS == "B" then
					sumBuyStop = sumBuyStop + cost
					if lowestBuyStop ~= 0 and lowestBuyStop > row.Stop then
						lowestBuyStop = row.Stop
					end
					if lowestBuyStop == 0 then
						lowestBuyStop = row.Stop
					end
				end
				if row.BS == "S" then
					sumSellStop = sumSellStop + cost
					if highestSellStop ~= 0 and highestSellStop < row.Stop then
						highestSellStop = row.Stop
					end
					if highestSellStop == 0 then
						highestSellStop = row.Stop
					end
				end
                
				local cost_text = win32.formatNumber(cost, false, 2);
                local w, h = context:measureText(FONT, cost_text, 0);
                local _, y = context:pointOfPrice(row.Stop);
                context:drawText(FONT, cost_text, instance.parameters.stop_color, -1, context:right() - w, y - h, context:right(), y, 0);
            end
            if row.Limit ~= 0 then
                local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, row.AccountID);
                local distance = math.abs(row.Limit - row.Open) / source:pipSize();
                local cost = distance * offer.PipCost * row.Lot / base_unit_size;
				
				if row.BS == "B" then
					sumBuyLimit = sumBuyLimit + cost
					if highestBuyLimit ~= 0 and highestBuyLimit < row.Limit then
						highestBuyLimit = row.Limit
					end
					if highestBuyLimit == 0 then
						highestBuyLimit = row.Limit
					end
				end
				if row.BS == "S" then
					sumSellLimit = sumSellLimit + cost
					if lowestSellLimit ~= 0 and lowestSellLimit > row.Limit then
						lowestSellLimit = row.Limit
					end
					if lowestSellLimit == 0 then
						lowestSellLimit = row.Limit
					end
					
				end
				
                local cost_text = win32.formatNumber(cost, false, 2);
                local w, h = context:measureText(FONT, cost_text, 0);
                local _, y = context:pointOfPrice(row.Limit);
                context:drawText(FONT, cost_text, instance.parameters.limit_color, -1, context:right() - w, y - h, context:right(), y, 0);
            end
        end
        row = enum:next();
    end
	
	local cost_text = win32.formatNumber(sumBuyStop, false, 2);
	local w, h = context:measureText(FONT, cost_text, 0);
	local _, y = context:pointOfPrice(lowestBuyStop);
	context:drawText(FONT, cost_text, instance.parameters.stop_color, -1, context:right() - w-100, y - h, context:right(), y, 0);
	
	local cost_text = win32.formatNumber(sumBuyLimit, false, 2);
	local w, h = context:measureText(FONT, cost_text, 0);
	local _, y = context:pointOfPrice(highestBuyLimit);
	context:drawText(FONT, cost_text, instance.parameters.limit_color, -1, context:right() - w-100, y - h, context:right(), y, 0);

	local cost_text = win32.formatNumber(sumSellStop, false, 2);
	local w, h = context:measureText(FONT, cost_text, 0);
	local _, y = context:pointOfPrice(highestSellStop);
	context:drawText(FONT, cost_text, instance.parameters.stop_color, -1, context:right() - w-100, y - h, context:right(), y, 0);

	local cost_text = win32.formatNumber(sumSellLimit, false, 2);
	local w, h = context:measureText(FONT, cost_text, 0);
	local _, y = context:pointOfPrice(lowestSellLimit);
	context:drawText(FONT, cost_text, instance.parameters.limit_color, -1, context:right() - w-100, y - h, context:right(), y, 0);	
	
    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.Instrument == source:instrument() then
            if row.Stop ~= 0 then
                local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, row.AccountID);
                local distance = -math.abs(row.Stop - row.Rate) / source:pipSize();
                local cost = distance * offer.PipCost * row.Lot / base_unit_size;
								
				local cost_text = win32.formatNumber(cost, false, 2);
                local w, h = context:measureText(FONT, cost_text, 0);
                local _, y = context:pointOfPrice(row.Stop);
                context:drawText(FONT, cost_text, instance.parameters.stop_color, -1, context:right() - w, y - h, context:right(), y, 0);
            end
            if row.Limit ~= 0 then
                local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, row.AccountID);
                local distance = math.abs(row.Limit - row.Rate) / source:pipSize();
                local cost = distance * offer.PipCost * row.Lot / base_unit_size;
						
                local cost_text = win32.formatNumber(cost, false, 2);
                local w, h = context:measureText(FONT, cost_text, 0);
                local _, y = context:pointOfPrice(row.Limit);
                context:drawText(FONT, cost_text, instance.parameters.limit_color, -1, context:right() - w, y - h, context:right(), y, 0);
            end
        end
        row = enum:next();
    end
	
end
