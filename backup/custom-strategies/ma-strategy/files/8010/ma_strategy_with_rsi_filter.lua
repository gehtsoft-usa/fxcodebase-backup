-- Id: 3067
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+


-- The sample advisor on the base of the moving average cross

-- initialize the advisor prifile
function Init()
    strategy:name("MA Strategy With RSI Filter");
    strategy:description("");
 

    strategy.parameters:addGroup("Fast Moving Average Parameters");
    strategy.parameters:addString("FMA_M","Moving Average method", "", "MVA");
    strategy.parameters:addStringAlternative("FMA_M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("FMA_M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("FMA_M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("FMA_M", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("FMA_M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("FMA_M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("FMA_M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("FMA_M", "Wilders*", "", "WMA");
    strategy.parameters:addStringAlternative("FMA_M", "TEMA*", "", "TEMA1");
	strategy.parameters:addStringAlternative("FMA_M", "HMA", "", "HMA");
    strategy.parameters:addInteger("FMA_N", "Number of periods", "", 5, 1, 300);
    strategy.parameters:addInteger("FMA_S", "Shift", "", 0, 0, 300);
    strategy.parameters:addString("FMA_P", "Price","", "C");
    strategy.parameters:addStringAlternative("FMA_P", "Open", "", "O");
    strategy.parameters:addStringAlternative("FMA_P", "High", "", "H");
    strategy.parameters:addStringAlternative("FMA_P", "Low", "", "L");
    strategy.parameters:addStringAlternative("FMA_P", "Close", "", "C");
    strategy.parameters:addStringAlternative("FMA_P", "Median", "", "M");
    strategy.parameters:addStringAlternative("FMA_P", "Typical", "", "T");
    strategy.parameters:addStringAlternative("FMA_P", "Weighted", "", "W");

    strategy.parameters:addGroup("Slow Moving Average Parameters");
    strategy.parameters:addString("SMA_M", "Moving Average method", "", "MVA");
    strategy.parameters:addStringAlternative("SMA_M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("SMA_M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("SMA_M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("SMA_M", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("SMA_M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("SMA_M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("SMA_M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("SMA_M", "Wilders*", "", "WMA");
    strategy.parameters:addStringAlternative("SMA_M", "TEMA*", "", "TEMA1");
	strategy.parameters:addStringAlternative("SMA_M", "HMA", "", "HMA");
    strategy.parameters:addInteger("SMA_N", "Number of Periods", "", 20, 1, 300);
    strategy.parameters:addInteger("SMA_S", "Shift", "", 0, 0, 300);
    strategy.parameters:addString("SMA_P", "Price", "", "C");
    strategy.parameters:addStringAlternative("SMA_P", "Open", "", "O");
    strategy.parameters:addStringAlternative("SMA_P", "High", "", "H");
    strategy.parameters:addStringAlternative("SMA_P", "Low", "", "L");
    strategy.parameters:addStringAlternative("SMA_P", "Close", "", "C");
    strategy.parameters:addStringAlternative("SMA_P", "Mesian", "", "M");
    strategy.parameters:addStringAlternative("SMA_P", "Typical", "", "T");
    strategy.parameters:addStringAlternative("SMA_P", "Weighted", "", "W");
	
	strategy.parameters:addGroup("RSI filter");
	strategy.parameters:addInteger("RSI_N", "Number of Periods", "", 20, 1, 300);
	 strategy.parameters:addInteger("RSI_S", "Shift", "", 0, 0, 300);
	
	 strategy.parameters:addString("RSI_P", "Price", "", "C");
    strategy.parameters:addStringAlternative("RSI_P", "Open", "", "O");
    strategy.parameters:addStringAlternative("RSI_P", "High", "", "H");
    strategy.parameters:addStringAlternative("RSI_P", "Low", "", "L");
    strategy.parameters:addStringAlternative("RSI_P", "Close", "", "C");
    strategy.parameters:addStringAlternative("RSI_P", "Mesian", "", "M");
    strategy.parameters:addStringAlternative("RSI_P", "Typical", "", "T");
    strategy.parameters:addStringAlternative("RSI_P", "Weighted", "", "W");

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("TF", "Timeframe", "", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addString("TYPE", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("TYPE", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("TYPE", "Ask", "", "Ask");

    strategy.parameters:addGroup("Trading Parameters");
    --strategy.parameters:addString("CANTRADE", "Allow trading", "", "No");	
   -- strategy.parameters:addStringAlternative("CANTRADE", "Yes", "", "Yes");
  --  strategy.parameters:addStringAlternative("CANTRADE", "No", "", "No");
	   strategy.parameters:addBoolean("CANTRADE", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("CANTRADE", core.FLAG_ALLOW_TRADE);
	
	strategy.parameters:addString("side", "Allow, Long / Short / Both", "", "BOTH");
    strategy.parameters:addStringAlternative("side", "BOTH", "", "BOTH");
    strategy.parameters:addStringAlternative("side", "LONG", "", "LONG");
    strategy.parameters:addStringAlternative("side", "SHORT", "", "SHORT");
	
    strategy.parameters:addString("ACCOUNT", "Account", "", "");
    strategy.parameters:setFlag("ACCOUNT", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("AMOUNT", "Amount", "", 1, 1, 100);
    strategy.parameters:addInteger("LIMIT", "Set Limit", "", 0, 0, 300);
    strategy.parameters:addInteger("STOP", "Set sTOP", "", 0, 0, 300);
    strategy.parameters:addBoolean("PLAY", "Play sound", "", false);
    strategy.parameters:addBoolean("RECURRENTSOUND", "Recurrent", "", false);
    strategy.parameters:addFile("SOUND", "Sound file", "", "");
    strategy.parameters:setFlag("SOUND", core.FLAG_SOUND);
end


-- check parameters and set advisor name
local name;
local SIDE;

function Prepare(onlyName)

    assert(not (instance.parameters.FMA_N > instance.parameters.SMA_N)  , "Fast MA Must have a shorter period from the slow MA.");

   SIDE = instance.parameters.side;
    -- set the name
    name = profile:id() .. "(" .. instance.bid:instrument() .. "." .. instance.parameters.TF .. "." .. instance.parameters.TYPE .. "," ..
                                  instance.parameters.FMA_M .. "(" .. instance.parameters.FMA_P .. "," .. instance.parameters.FMA_N .. "," .. instance.parameters.FMA_S .. ")," ..
                                  instance.parameters.SMA_M .. "(" .. instance.parameters.SMA_P .. "," .. instance.parameters.SMA_N .. "," .. instance.parameters.SMA_S .. "," .. instance.parameters.RSI_N ..", ".. instance.parameters.RSI_S .. "," .. instance.parameters.RSI_P .. "))";
    instance:name(name);
	if onlyName then
        return;
    end
	
    -- check time frame
    assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks.");
    -- check sound alert params
    assert(not(instance.parameters.PLAY) or (instance.parameters.PLAY and instance.parameters.SOUND ~= ""), "The sound file must be chosen.");
    -- check trading params
    if instance.parameters.CANTRADE then
        assert(core.host:findTable("Accounts"):find("AccountID", instance.parameters.ACCOUNT) ~= nil, "The account to trade must be chosen.");
        assert(core.host:findTable("offers"):find("Instrument", instance.bid:instrument()) ~= nil, "The chosen symbol is not found.");
    end

    -- check methods
    assert(core.indicators:findIndicator(instance.parameters.FMA_M) ~= nil, "The chosen moving average method is not installed. Please use fxcodebase.com site to download the approriate moving average method.");
    assert(core.indicators:findIndicator(instance.parameters.SMA_M) ~= nil, "The chosen moving average method is not installed. Please use fxcodebase.com site to download the approriate moving average method.");    
end

-- global data block start
local init = false;
local loaded = false;
local priorbar = nil;

-- price and MVA data (indicator, data and shift)
local TICKSRC;
local SRC;
local SMA, SMADATA, SMASHIFT;
local FMA, FMADATA, FMASHIFT;
local RSI, RSIDATA, RSISHIFT;

-- trade data
local OFFER;
local CANTRADE;
local ACCOUNT;
local AMOUNT;
local PLAY;
local RECURRENTSOUND;
local SOUND;
local LIMIT;
local STOP;
local SELL;
local BUY;
local CANCLOSE;
local CID = "MACROSS";

-- global data block end
function Update()
    if not(init) then
        TICKSRC = instance.bid;
        -- collect the trading parameters
      
        if CANTRADE then
            ACCOUNT = instance.parameters.ACCOUNT;
            AMOUNT = instance.parameters.AMOUNT * core.host:execute("getTradingProperty", "baseUnitSize", TICKSRC:instrument(), ACCOUNT);
            LIMIT = math.floor(instance.parameters.LIMIT + 0.5);
            STOP = math.floor(instance.parameters.STOP + 0.5);
            OFFER = core.host:findTable("offers"):find("Instrument", TICKSRC:instrument()).OfferID;
            CANCLOSE = core.host:execute("getTradingProperty", "canCreateMarketClose", TICKSRC:instrument(), ACCOUNT)
        else
            SELL = "Sell";
            BUY = "Buy";
        end
        PLAY = instance.parameters.PLAY;
        SOUND = instance.parameters.SOUND;
        RECURRENTSOUND = instance.parameters.RECURRENTSOUND;

        -- load the price data
        SRC = core.host:execute("getHistory", 1, TICKSRC:instrument(), instance.parameters.TF, 0, 0, instance.parameters.TYPE == "Bid");
        FMA, FMADATA = CreateMA(instance.parameters.FMA_M, instance.parameters.FMA_N, instance.parameters.FMA_P, SRC);
        SMA, SMADATA = CreateMA(instance.parameters.SMA_M, instance.parameters.SMA_N, instance.parameters.SMA_P, SRC);
		RSI, RSIDATA = CreateRSI( instance.parameters.SMA_N, instance.parameters.RSI_P, SRC);
        FMASHIFT = instance.parameters.FMA_S;
        SMASHIFT = instance.parameters.SMA_S;
		RSISHIFT = instance.parameters.RSI_S;
        init = true;
        return ;
    end

    -- return if the data is not loaded yet
    if not(loaded) or SRC:size() < 2 then
        return ;
    end

    -- the index of the bar to be processed
    local p = SRC:size() - 2;

    -- check if the same bar is still updating
    if priorbar ~= nil and SRC:serial(p) == priorbar then
        return ;
    end

    -- remember the last processed bar
    priorbar = SRC:serial(p);

    -- update moving average
    FMA:update(core.UpdateLast);
    SMA:update(core.UpdateLast);
	RSI:update(core.UpdateLast);

    -- check whether here is enough data to check the
    -- signal conditions
    if p <= FMADATA:first() + FMASHIFT or p <= SMADATA:first() + SMASHIFT or  p <= RSIDATA:first() + RSISHIFT then
        return ;
    end

    if core.crossesOver(FMADATA, SMADATA, p - FMASHIFT, p - SMASHIFT) and SIDE ~= "SHORT" and RSIDATA[p]> 50 then
        -- buy condition met (fast crosses over slow)
        if CANTRADE  then          
			
				close("S");     -- closes all existing longs on the account
                enter("B");     -- and the enter short			  
			
        else
            terminal:alertMessage(TICKSRC:instrument(), TICKSRC[NOW], name .. "." .. BUY, TICKSRC:date(NOW));
        end
        if PLAY then
            terminal:alertSound(SOUND, RECURRENTSOUND);
        end
    elseif core.crossesUnder(FMADATA, SMADATA, p - FMASHIFT, p - SMASHIFT) and SIDE ~= "LONG" and RSIDATA[p]< 50  then
        -- sell condition met (slow crosses over fast)
        if CANTRADE then		
			
				close("B");     -- closes all existing longs on the account
                enter("S");     -- and the enter short		  
            
        else
            terminal:alertMessage(TICKSRC:instrument(), TICKSRC[NOW], name .. "." .. SELL, TICKSRC:date(NOW));
        end
        if PLAY then
            terminal:alertSound(SOUND, RECURRENTSOUND);
        end
    end
end

-- creates moving average with the specified parameters for the specified price
function CreateRSI( n, price, src)

local p;
    if price == "O" then
        p = src.open;
    elseif price == "H" then
        p = src.high;
    elseif price == "L" then
        p = src.low;
    elseif price == "M" then
        p = src.median;
    elseif price == "T" then
        p = src.typical;
    elseif price == "W" then
        p = src.weighted;
    else
        p = src.close;
    end
	
	 local indicator = core.indicators:create("RSI", p, n);
    return indicator, indicator.DATA;

end


function CreateMA(method, n, price, src)
    local p;
    if price == "O" then
        p = src.open;
    elseif price == "H" then
        p = src.high;
    elseif price == "L" then
        p = src.low;
    elseif price == "M" then
        p = src.median;
    elseif price == "T" then
        p = src.typical;
    elseif price == "W" then
        p = src.weighted;
    else
        p = src.close;
    end

    assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
    local indicator = core.indicators:create(method, p, n);
    return indicator, indicator.DATA;
end

-- closes all positions of the specified direction (B for buy, S for sell)
function close(side)
    local enum, row, valuemap;

    enum = core.host:findTable("trades"):enumerator();
    while true do
        row = enum:next();
        if row == nil then
            break;
        end
        if row.AccountID == ACCOUNT and
           row.OfferID == OFFER and
           row.BS == side and
           row.QTXT == CID then
            -- if trade has to be closed

            if CANCLOSE then
                -- non-FIFO account, create a close market order
                valuemap = core.valuemap();
                valuemap.OrderType = "CM";
                valuemap.OfferID = OFFER;
                valuemap.AcctID = ACCOUNT;
                valuemap.Quantity = row.Lot;
                valuemap.TradeID = row.TradeID;
                valuemap.CustomID = CID;
                if row.BS == "B" then
                    valuemap.BuySell = "S";
                else
                    valuemap.BuySell = "B";
                end
                success, msg = terminal:execute(200, valuemap);
                assert(success, msg);
            else
                -- FIFO account, create an opposite market order
                valuemap = core.valuemap();
                valuemap.OrderType = "OM";
                valuemap.OfferID = OFFER;
                valuemap.AcctID = ACCOUNT;
                valuemap.Quantity = AMOUNT;
                valuemap.CustomID = CID;
                if row.BS == "B" then
                    valuemap.BuySell = "S";
                else
                    valuemap.BuySell = "B";
                end
                success, msg = terminal:execute(200, valuemap);
                assert(success, msg);
            end
        end
    end
end

-- the method enters to the market
function enter(side)
    local valuemap;

    valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = OFFER;
    valuemap.AcctID = ACCOUNT;
    valuemap.Quantity = AMOUNT;
    valuemap.CustomID = CID;
    valuemap.BuySell = side;
    if STOP >= 1 then
        valuemap.PegTypeStop = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -STOP;
        else
            valuemap.PegPriceOffsetPipsStop = STOP;
        end
        valuemap.TrailStepStop = 1;
    end
    if LIMIT >= 1 then
        valuemap.PegTypeLimit = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = LIMIT;
        else
            valuemap.PegPriceOffsetPipsLimit = -LIMIT;
        end
        valuemap.TrailStepStop = 1;
    end
    success, msg = terminal:execute(200, valuemap);
    assert(success, msg);
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        loaded = true;
    elseif cookie == 200 then
        assert(success, message);
    end
end
