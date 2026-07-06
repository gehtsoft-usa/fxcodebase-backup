-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64552
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("ChandelierExit Indicator position Close Strategy");
    strategy:description("");
    strategy:setTag("strategy_type", "Money management");
	
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	
	strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	strategy.parameters:addInteger("x_shift", "Shift in periods", "", 0, -100000, 0);
	strategy.parameters:addDouble("y_shift", "Shift in pips", "", 0.0);
	
	strategy.parameters:addString("TF", "Time frame", "", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    
    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("Range", "Range", "", 7);
    strategy.parameters:addInteger("Shift", "Shift", "", 0);
    strategy.parameters:addInteger("ATRPeriod", "ATR Period", "", 9);
    strategy.parameters:addDouble("ATRMultipl", "ATRMultipl", "", 2.5); 
	
	strategy.parameters:addGroup("Trade");
	strategy.parameters:addString("Trade", "(non-FIFO) Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);
 
    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Execution Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	
	strategy.parameters:addString("ExecutionType", "Execution Type", "", "Live");
    strategy.parameters:addStringAlternative("ExecutionType", "End of Turn", "", "EndOfTurn");
	strategy.parameters:addStringAlternative("ExecutionType", "Live", "", "Live");
end

local tradeId
local Source,TickSource;
local AllowTrade;
local ExecutionType;
local x_shift;
local y_shift;
local TF;
--*********************************************************************************************************

--Indicator parameters
local Range,Shift, ATRPeriod, ATRMultipl;

function Prepare( nameOnly)
	ExecutionType = instance.parameters.ExecutionType;
    
	TF= instance.parameters.TF;
	tradeId = instance.parameters.Trade;
    
    local trade = core.host:findTable("trades"):find("TradeID", tradeId);
    assert(trade ~= nil, "Trade can not be found")
		
	--Indicator parameters
	Range = instance.parameters.Range;
	Shift = instance.parameters.Shift;
	ATRPeriod = instance.parameters.ATRPeriod;
	ATRMultipl = instance.parameters.ATRMultipl;
	x_shift = instance.parameters.x_shift;
	y_shift = instance.parameters.y_shift * core.host:findTable("offers"):find("Instrument", trade.Instrument).PointSize;

    assert(TF ~= "t1", "The time frame must not be tick");

    name = profile:id() .. ", " .. instance.bid:name() ;
    instance:name(name);
   
    PrepareTrading();

    if nameOnly then
        return ;
    end
	
	assert(core.indicators:findIndicator("CHANDELIEREXIT_SS") ~= nil, "Please, download and install CHANDELIEREXIT_SS.LUA indicator");            
	
 	if ExecutionType == "Live" then
	 	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
 	end
 
    Source = ExtSubscribe(2, nil, TF, instance.parameters.Type == "Bid", "bar");
    Indicator = core.indicators:create("CHANDELIEREXIT_SS", Source, Range,Shift, ATRPeriod, ATRMultipl,  core.rgb(0, 255, 0),  core.rgb(255, 0, 0)  );
end

function PrepareTrading()
    AllowTrade = instance.parameters.AllowTrade;
end

local order_changing = false;
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
         return ;
        end
	end
	
	Indicator:update(core.UpdateLast);

	if order_changing or Indicator.DATA:size() <= math.abs(x_shift) then
		return;
	end

	local trade = core.host:findTable("trades"):find("TradeID", tradeId);
	if (trade == nil) then
		core.host:execute("stop");
		return;
	end
	local stopOrder = core.host:findTable("orders"):find("OrderID", trade.StopOrderID);
    if stopOrder == nil then
		order_changing = true;

		local valuemap = core.valuemap();
		valuemap.Command = "CreateOrder";
		valuemap.OfferID = trade.OfferID;
		if (trade.BS == "B") then
			valuemap.BuySell = "S";
			valuemap.Rate = Indicator.DATA[NOW + x_shift] + y_shift;
		else
			valuemap.BuySell = "B";
			valuemap.Rate = Indicator.DATA[NOW + x_shift] - y_shift;
		end
		core.host:trace("Setting %d", valuemap.Rate);
		valuemap.OrderType = "S";
		valuemap.AcctID  = trade.AccountID;
		valuemap.TradeID = trade.TradeID;
		valuemap.Quantity = trade.Lot;
		
		local success, msg = terminal:execute(200, valuemap);
	else
		local update_needed = false;
		local new_stop_level;
		if (trade.BS == "B") then
			new_stop_level = Indicator.DATA[NOW + x_shift] + y_shift;
			update_needed = stopOrder.Rate ~= new_stop_level;
		else
			new_stop_level = Indicator.DATA[NOW + x_shift] - y_shift;
			update_needed = stopOrder.Rate ~= new_stop_level;
		end
		if update_needed then
			order_changing = true;

			local valuemap = core.valuemap();
			valuemap.Command = "EditOrder";
			valuemap.AcctID  = stopOrder.AccountID;
			valuemap.OrderID = stopOrder.OrderID;
			valuemap.Rate = new_stop_level;

			local success, msg = terminal:execute(200, valuemap);
		end
	end
end
 
-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
	if cookie == 200 then
		order_changing = false;
	end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function checkReady(table)
    local rc;
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true;
    else
        rc = core.host:execute("isTableFilled", table);
    end

    return rc;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
 