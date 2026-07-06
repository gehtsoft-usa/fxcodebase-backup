-- Id: 17287
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64251

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
    indicator:name("Trading commands");
    indicator:description("Trading commands");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator:name("Close All trades commands");
    indicator.parameters:addDouble("ProfitLevel", "Profit level", "Profit level for close command", 0);
    
    indicator.parameters:addString("ProfitType", "Profit Level Type", "", "$");
    indicator.parameters:addStringAlternative("ProfitType", "$", " ", "$", "$");
    indicator.parameters:addStringAlternative("ProfitType", "Pips", " ", "P/L","Pips");
end

local CLOSE_ALL_TRADES_COMMAND_ID = 101;
local CLOSE_LONG_COMMAND_ID=106;
local CLOSE_SHORT_COMMAND_ID=107;
local HEDGE_TRADES_COMMAND_ID = 102;
local CLOSE_HALF_TRADES_COMMAND_ID = 103;
local REVERSE_TRADES_COMMAND_ID = 1044;
local CLOSE_ALL_PROFITABLE_TRADES_COMMAND_ID = 105;

function Prepare(nameOnly)
    local name = profile:id();
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    
    stub = instance:addStream("stub", core.Line, "stub", "stub", core.rgb(255, 0, 0), 0);
    
    core.host:execute("addCommand", CLOSE_ALL_TRADES_COMMAND_ID, "Close all trades");
	core.host:execute("addCommand", CLOSE_LONG_COMMAND_ID, "Close all Long trades");
    core.host:execute("addCommand", CLOSE_SHORT_COMMAND_ID, "Close all Short trades");
	
    core.host:execute("addCommand", HEDGE_TRADES_COMMAND_ID, "Hedge your position");
    core.host:execute("addCommand", REVERSE_TRADES_COMMAND_ID, "Reverse your position");
    core.host:execute("addCommand", CLOSE_HALF_TRADES_COMMAND_ID, "Close 1/2 of your position");
    
    core.host:execute("addCommand", CLOSE_ALL_PROFITABLE_TRADES_COMMAND_ID, "Close all trades if above " .. instance.parameters.ProfitLevel .. " " .. instance.parameters.ProfitType);
end

function Update(period)
end

function CloseSpecifiedAmount(offer_id, account_id, bs, amountK)
    local total = 0;
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        if row.OfferID == offer_id and row.AccountID == account_id and row.BS == bs then
            local amount_to_close = math.min(amountK, row.AmountK);
            CloseTradeByAmount(row, amount_to_close);
            amountK = amountK - amount_to_close;
            if amountK == 0 then
                return;
            end
        end
        row = enum:next();
    end
end

-- exit from the specified direction
function CloseTradeByAmount(trade, amountK)
    local valuemap = core.valuemap();
    -- switch the direction since the order must be in oppsite direction
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    local base_size = core.host:execute("getTradingProperty", "baseUnitSize", trade.Instrument, trade.AccountID);
    valuemap.Quantity = amountK * base_size;
    success, msg = terminal:execute(201, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

function CalculateTotalAmount(offer_id, account_id, bs)
    local total = 0;
	local count=0;
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        if row.OfferID == offer_id and row.AccountID == account_id and row.BS == bs then
            total = total + row.AmountK;
			count=count+row.Lot;
        end
        row = enum:next();
    end
    return total,count;
end

function OpenMarket(offer_id, account_id, bs, amount)
    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = offer_id;
    valuemap.AcctID = account_id;
    valuemap.Quantity = amount;
    valuemap.BuySell = bs;
    local success, msg = terminal:execute(200, valuemap);
    assert(success, msg);
end

local trades_to_open = {};
function AsyncOperationFinished(cookie, success, message)
    if cookie == 202 then
        for _, command in ipairs(trades_to_open) do
            OpenMarket(command.offer_id, command.account_id, command.side, command.amount);
        end
        trades_to_open = {};
    elseif cookie == CLOSE_ALL_TRADES_COMMAND_ID then
        local offer_id = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
        local enum = core.host:findTable("accounts"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            CloseAll(offer_id, row.AccountID, "B");
            CloseAll(offer_id, row.AccountID, "S");
            row = enum:next();
        end
		
	  elseif cookie == CLOSE_LONG_COMMAND_ID then
        local offer_id = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
        local enum = core.host:findTable("accounts"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            CloseAll(offer_id, row.AccountID, "S");
            row = enum:next();
        end
			
	  elseif cookie == CLOSE_SHORT_COMMAND_ID then
        local offer_id = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
        local enum = core.host:findTable("accounts"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            CloseAll(offer_id, row.AccountID, "B");
            row = enum:next();
        end
		
    elseif cookie == REVERSE_TRADES_COMMAND_ID then
        local offer_id = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
        local enum = core.host:findTable("accounts"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            local total_amount_b,count_b = CalculateTotalAmount(offer_id, row.AccountID, "B");
            local total_amount_s,count_s = CalculateTotalAmount(offer_id, row.AccountID, "S");
            local base_size = core.host:execute("getTradingProperty", "baseUnitSize", instance.source:instrument(), row.AccountID);
            CloseAll(offer_id, row.AccountID, "B");
            CloseAll(offer_id, row.AccountID, "S", 202);
            
            if total_amount_b > 0 then
                local to_open = {};
                to_open.offer_id = offer_id;
                to_open.account_id = row.AccountID;
                to_open.side = "S";
                to_open.amount = total_amount_b * base_size;
                trades_to_open[#trades_to_open + 1] = to_open;
            end
            if total_amount_s > 0 then
                local to_open = {};
                to_open.offer_id = offer_id;
                to_open.account_id = row.AccountID;
                to_open.side = "B";
                to_open.amount = total_amount_s * base_size;
                trades_to_open[#trades_to_open + 1] = to_open;
            end
            row = enum:next();
        end
    elseif cookie == HEDGE_TRADES_COMMAND_ID then
        local offer_id = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
        local enum = core.host:findTable("accounts"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            core.host:trace(row.Hedging);
            if row.Hedging == "Y" then
                local total_amount_b = CalculateTotalAmount(offer_id, row.AccountID, "B");
                local total_amount_s = CalculateTotalAmount(offer_id, row.AccountID, "S");
                local base_size = core.host:execute("getTradingProperty", "baseUnitSize", instance.source:instrument(), row.AccountID);
                if total_amount_b > 0 then
                    OpenMarket(offer_id, row.AccountID, "S", total_amount_b * base_size);
                end
                if total_amount_s > 0 then
                    OpenMarket(offer_id, row.AccountID, "B", total_amount_s * base_size);
                end
            end
            row = enum:next();
        end
    elseif cookie == CLOSE_HALF_TRADES_COMMAND_ID then
        local offer_id = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
        local enum = core.host:findTable("accounts"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            local total_amount_b, count_b = CalculateTotalAmount(offer_id, row.AccountID, "B");
            local total_amount_s, count_s = CalculateTotalAmount(offer_id, row.AccountID, "S");
            local base_size = core.host:execute("getTradingProperty", "baseUnitSize", instance.source:instrument(), row.AccountID);
            if total_amount_b == 1 then            	
				  if row.Hedging == "Y" then
                    CloseSpecifiedAmount(offer_id, row.AccountID, "B", total_amount_b);--don't use * base_size
                else
                    OpenMarket(offer_id, row.AccountID, "S", total_amount_b  * base_size);
                end
            end
				
			 
			if total_amount_s == 1 then
				 if row.Hedging == "Y" then
                    CloseSpecifiedAmount(offer_id, row.AccountID, "S", total_amount_s );--don't use * base_size
                else
                    OpenMarket(offer_id, row.AccountID, "B", total_amount_s  * base_size);
                end
			end
            
            if total_amount_b > 2 and not IsEven(total_amount_b) then	
			     total_amount_b = total_amount_b - 1;
			end
			if total_amount_s > 2 and not IsEven(total_amount_s) then
                total_amount_s = total_amount_s - 1;
			end
            
			if total_amount_b > 1 then
                if row.Hedging == "Y" then
                    CloseSpecifiedAmount(offer_id, row.AccountID, "B", round(total_amount_b / 2));--don't use * base_size
                else
                    OpenMarket(offer_id, row.AccountID, "S", round(total_amount_b / 2) * base_size);
                end
            end
            if total_amount_s > 1 then
                if row.Hedging == "Y" then
                    CloseSpecifiedAmount(offer_id, row.AccountID, "S", round(total_amount_s / 2));--don't use * base_size
                else
                    OpenMarket(offer_id, row.AccountID, "B", round(total_amount_s / 2) * base_size);
                end
            end
            row = enum:next();
        end
    elseif cookie == CLOSE_ALL_PROFITABLE_TRADES_COMMAND_ID then
       
        local profitType = instance.parameters.ProfitType;
        local trades = core.host:findTable("trades");
        local enum = trades:enumerator();
        local PL=0;
        while true do
            local row = enum:next();
            if row == nil then 
                break 
            end
            
			
			   if profitType == "$" then 
						PL=PL+ row.GrossPL; 
			   else
 
			            PL=PL+ row.PL; 
               end
			
        end
       -- core.host:trace(PL);
        if (PL>=instance.parameters.ProfitLevel ) then
            local offer_id = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
            local enum = core.host:findTable("accounts"):enumerator();
            local row = enum:next();
            while (row ~= nil) do
                CloseAll(offer_id, row.AccountID, "B");
                CloseAll(offer_id, row.AccountID, "S");
                row = enum:next();
            end
        end
    end
end

function IsEven(num)
	return num % 2 == 0
end

function Pop(Label, Text)
	local delim = "\013\010";  
   	local Note=  profile:id().. delim.. " " .. Label..  " : " .. Text 
   	local Symbol= " Instrument : " .. instance.source:instrument() ;
    local Text = Note  .. delim ..  Symbol 
	core.host:execute ("prompt", 1, Label , Text );
end

function CloseAll(offer_id, account_id, bs, id)
    if id == nil then
        id = 100;
    end
    local valuemap;
    valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "CM";
    valuemap.OfferID = offer_id;
    valuemap.BuySell = bs;
    valuemap.AcctID = account_id;
    valuemap.NetQtyFlag = "y";
    local success, msg;
    success, msg = terminal:execute(id, valuemap);
    assert(success, msg);
end

function round(num, digits)
    if digits and digits > 0 then
        local mult = 10 ^ digits
        return math.floor(num * mult + 0.5) / mult;
    end
    return math.floor(num + 0.5);
end