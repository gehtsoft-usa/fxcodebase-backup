-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69123

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Shows breakeven price level for the current instrument");
    indicator:description("The indicator shows the price at which the currently held positions will have zero profit");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("IgnoreBidAskChange", "True");
   
   
    indicator.parameters:addGroup("Input Options");
    indicator.parameters:addBoolean("trades", "Include trades", "", true);
    indicator.parameters:addBoolean("orders", "Include orders", "", true);
	
	  indicator.parameters:addGroup("Output Options");
    indicator.parameters:addBoolean("show_buy", "Show buy positions level", "", false);
    indicator.parameters:addBoolean("show_sell", "Show sell positions level", "", false);
    indicator.parameters:addBoolean("show_total", "Show overall positions level", "", true);
    indicator.parameters:addBoolean("show_margin_Warning", "Show margin Warning level", "", true);
	indicator.parameters:addBoolean("show_margin_Liquidation", "Show margin Liquidation level", "", true);
	
	--indicator.parameters:addInteger("Entry_UsedMargin", "Entry Order UsedMargin (per lot)", "",  20);
	

	

    indicator.parameters:addString("Account", "Account", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
	
	
	indicator.parameters:addGroup("Style Options");
    indicator.parameters:addColor("BC", "Buy Positions Level color", "",  core.rgb(0, 255, 0));
    indicator.parameters:addColor("SC", "Sell positions level color", "",   core.rgb(255, 0, 0));
    indicator.parameters:addColor("total_color", "Overall position level color", "",   core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("STYLE", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("STYLE", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("WIDTH", "Line width", "", 1, 1, 5);
	
	
    indicator.parameters:addColor("margin_call_color1", "Margin Warning level color", "",   core.rgb(255, 0, 0));
	indicator.parameters:addColor("margin_call_color2", "Margin Liquidation level color", "",   core.rgb(255, 0, 0));
	indicator.parameters:addInteger("STYLE1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("STYLE1", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("WIDTH1", "Line width", "", 1, 1, 5);
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local BC;
local SC;
local style;
local width;
local style1;
local width1;
local show_buy, show_sell, show_total, total_color, show_margin_call, Account, margin_call_color1, margin_call_color2;
--local Entry_UsedMargin;
local instrument;
local first;
local source = nil;
local format;
local show_margin_Warning,show_margin_Liquidation;
-- Streams block
local BUY = nil;
local SELL = nil;
local timer;
local trades, orders

-- Routine
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    show_buy = instance.parameters.show_buy;
    show_sell = instance.parameters.show_sell;
    show_total = instance.parameters.show_total;
    show_margin_call = instance.parameters.show_margin_call;
    Account = instance.parameters.Account;
    total_color = instance.parameters.total_color;
    margin_call_color1 = instance.parameters.margin_call_color1;
	margin_call_color2 = instance.parameters.margin_call_color2;
	 
	
	show_margin_Warning = instance.parameters.show_margin_Warning;
	show_margin_Liquidation = instance.parameters.show_margin_Liquidation;

    if onlyName then
        return ;
    end
    trades = instance.parameters.trades;
    orders = instance.parameters.orders;
    BC = instance.parameters.BC;
    SC = instance.parameters.SC;
    style = instance.parameters.STYLE;
    width = instance.parameters.WIDTH;
	
	style1 = instance.parameters.STYLE1;
    width1 = instance.parameters.WIDTH1;
    instrument = source:instrument();
    format = "%s:%." .. source:getPrecision() .. "f";

    BUY = instance:addStream("BUY", core.Line, name, "BUY", instance.parameters.BC, 0);
    SELL = instance:addStream("SELL", core.Line, name, "SELL", instance.parameters.SC, 0);
    timer = core.host:execute("setTimer", 1, 10);
end

-- Indicator calculation routine
function Update(period, mode)
    local i, v;
    if period == source:size() - 1 then
        i = BUY:getBookmark(1);
        if i >= 0 and i ~= period then
            v = BUY[i];
            BUY:set(i, nil);
            BUY[period] = v;
            BUY:setBookmark(1, period);
        end
        i = SELL:getBookmark(1);
        if i >= 0 and i ~= period then
            v = SELL[i];
            SELL:set(i, nil);
            SELL[period] = v;
            SELL:setBookmark(1, period);
        end
    end
end

local _sellP = -1;
local _buyP = -1;

function AsyncOperationFinished(cookie, success, message)
    if cookie ~= 1 
	or  source:size()-1 <=0 
	then
	return;
	end
	
 
        local period = source:size() - 1;

        local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", instrument, Account);
        local MMR= core.host:execute("getTradingProperty", "MMR", instrument, Account);
 
        local sell_lots = 0;
        local sellP = 0;
        local buy_lots = 0;
        local buyP = 0;
		
		local UsedMargin=0;
		
        if trades then
            local enum = core.host:findTable("trades"):enumerator();
            local row = enum:next();
            while row ~= nil do
                if row.Instrument == instrument then
                    if row.BS == "B" then
                        buy_lots = buy_lots + row.Lot / base_unit_size;
                        buyP = buyP + row.Open * row.Lot / base_unit_size;
						
                    else
                        sell_lots = sell_lots + row.Lot / base_unit_size;
                        sellP = sellP + row.Open * row.Lot / base_unit_size;
                    end
					
					
                end
                row = enum:next();
            end
        end
        if orders then
            local enum = core.host:findTable("orders"):enumerator();
            local row = enum:next();
            while row ~= nil do
                if row.Instrument == instrument then
                    if row.BS == "B" then
                        buy_lots = buy_lots + row.Lot / base_unit_size;
                        buyP = buyP + row.Rate * row.Lot / base_unit_size;
                    else
                        sell_lots = sell_lots + row.Lot / base_unit_size;
                        sellP = sellP + row.Rate * row.Lot / base_unit_size;
                    end
                end
				
				 
			
				UsedMargin=UsedMargin+MMR*(row.Lot / base_unit_size);
				
                row = enum:next();
            end
        end
        local totalAmount = buy_lots + sell_lots;
        local total;
        if totalAmount ~= 0 then
            total = buyP / totalAmount + sellP / totalAmount; 
        end
        if sell_lots > 0.00001 then
            sellP = sellP / sell_lots;
        end
        if buy_lots > 0.00001 then
            buyP = buyP / buy_lots;
        end

        if BUY:getBookmark(1) < 0 and _buyP > 0 then
            _buyP = -1;
        end
            
        if SELL:getBookmark(1) < 0 and _sellP > 0 then
            _sellP = -1;
        end

        if math.abs(sellP - _sellP) < 0.000001 
            and math.abs(buyP - _buyP) < 0.000001 
        then
            return ;
        end

        _sellP = sellP;
        _buyP = buyP;

        i = BUY:getBookmark(1);
        if i >= 0 then
            BUY:set(i, nil);
            BUY:setBookmark(1, -1);
        end

        i = SELL:getBookmark(1);
        if i >= 0 then
            SELL:set(i, nil);
            SELL:setBookmark(1, -1);
        end

        if show_buy then
            if sell_lots > 0.00001 then
                SELL[period] = sellP;
                SELL:setBookmark(1, period);
                core.host:execute("drawLine", 1, source:date(source:first()), sellP, source:date(source:size() - 1) + 5, sellP, SC, style, width, string.format(format, "breakeven sell", sellP));
            else
                core.host:execute("removeLine", 1);
            end
        end

        if show_sell then
            if buy_lots > 0.00001 then
                BUY[period] = buyP;
                BUY:setBookmark(1, period);
                core.host:execute("drawLine", 2, source:date(source:first()), buyP, source:date(source:size() - 1) + 5, buyP, BC, style, width, string.format(format, "breakeven buy", buyP));
            else
                core.host:execute("removeLine", 2);
            end
        end

        if show_total then
            if total ~= nil then
                core.host:execute("drawLine", 3, source:date(source:first()), 
                    total, source:date(source:size() - 1) + 5, total, 
                    total_color, style, width, string.format(format, "breakeven total", total));
            else
                core.host:execute("removeLine", 3);
            end
        end

        if   totalAmount ~= 0 then
            local account_row = core.host:findTable("accounts"):find("AccountID", Account);
            local PipCost = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
            local net_lots =  (buy_lots-sell_lots);
            local margin_call_level = source[source:size()-1] - ((account_row.UsableMargin - account_row.UsedMargin-UsedMargin) / (net_lots * PipCost)) * source:pipSize();
            local label = string.format(format, "Margin call level", margin_call_level);
			
			
			if show_margin_Warning then
			
            core.host:execute("drawLine", 4, source:date(source:first()), 
                margin_call_level, source:date(source:size() - 1) + 5, margin_call_level, 
                margin_call_color1, style1, width1, label);
            core.host:execute("setStatus",   margin_call_level );
			
			else
			  core.host:execute("removeLine", 4);
			end
			
			
						if show_margin_Liquidation then
						
						 local Liquidation_level = margin_call_level - (( (account_row.UsedMargin+UsedMargin)/2) / (net_lots * PipCost)) * source:pipSize();
                         local label = string.format(format, "Liquidation level", Liquidation_level);
						
						core.host:execute("drawLine", 5, source:date(source:first()), 
							Liquidation_level, source:date(source:size() - 1) + 5, Liquidation_level, 
							margin_call_color2, style1, width1, label);
						core.host:execute("setStatus",   Liquidation_level );
						
						else
						  core.host:execute("removeLine", 5);
						end

        else
            core.host:execute("removeLine", 4);
			 core.host:execute("removeLine", 5);
        end
		
 
      

        return core.ASYNC_REDRAW;
 
end

function ReleaseInstance()
    core.host:execute("killTimer", timer);
end
