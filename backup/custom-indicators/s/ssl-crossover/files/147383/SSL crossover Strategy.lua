
-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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


-- Indicator profile initialization routine

function Init()
    indicator:name("SSLcrossover Strategy");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 
	indicator.parameters:addBoolean("showEntry", "Show Entry", "", true);
	indicator.parameters:addBoolean("showTrend", "Show Trend", "", true); 
	
    indicator.parameters:addInteger("sslLen", "Number of periods", "The number of periods.", 10, 2, 1000);
	
	indicator.parameters:addString("maType", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("maType", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("maType", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("maType", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("maType", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("maType", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("maType", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("maType", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("maType", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("maType", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("maType", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("maType", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("maType", "T3", "", "T3");
    indicator.parameters:addStringAlternative("maType", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("maType", "Median", "", "Median");
    indicator.parameters:addStringAlternative("maType", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("maType", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("maType", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("maType", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("maType", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("maType", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("maType", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("maType", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("maType", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("maType", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("maType", "VAMA", "", "VAMA");
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Top Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Bottom Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
    indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	
	
	indicator.parameters:addInteger("Size", "Arrow Size","", 15); 

    indicator.parameters:addString("Account", "Account2Trade", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
	indicator.parameters:addInteger("Amount", "Amount", "Amount", 1, 1, 10000)
    indicator.parameters:addInteger("tcd", "trailingCandleDistance", "trailingCandleDistance", 5, 1, 1000);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local sslLen,maType; 
local first;
local source = nil;
local Bottom, Top; 
local maHigh, maLow; 
local Hlv;
local Transparency;
local   showEntry ,showTrend;
local up, down;
local Size;
local Shift;
local Account, Offer, CanClose, Amount, pos, fstTck, tcd

-- Routine
 function Prepare(nameOnly)   
 
    Transparency= instance.parameters.Transparency;
    Transparency= 100-Transparency; 
    sslLen= instance.parameters.sslLen;
    maType= instance.parameters.maType; 
	showEntry= instance.parameters.showEntry;
	showTrend= instance.parameters.showTrend; 
	Size= instance.parameters.Size;
	
	Account = instance.parameters.Account
	Offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID
	CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.source:instrument(), Account);
	Amount = instance.parameters.Amount
	pos=0
	fstTck= true
	tcd = instance.parameters.tcd
	
	
	local Parameters= sslLen..", "..maType;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters ..", Amt="..Amount..", tcd="..tcd..")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
			
    source = instance.source;  
	
	maHigh = core.indicators:create("AVERAGES", source.high, maType, sslLen  );
    maLow = core.indicators:create("AVERAGES", source.low,  maType, sslLen);  
	
    first=maLow.DATA:first() ;
	  
	Trend= instance:addInternalStream(0, 0);
   
 
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.Up, first );
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:setPrecision(math.max(2, source:getPrecision()));

	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.Down, first );
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
	
	if showTrend then
	instance:createChannelGroup("Group","Group" , Top, Bottom, instance.parameters.Up, Transparency);
	end
	
	if showEntry then
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center,core.V_Bottom , instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
	end
end

-- Indicator calculation routine
function Update(period, mode)

    maHigh:update(mode);
    maLow:update(mode);
	
 
	if period < first
	then
	return;
	end
	
	
	if fstTck then
		if haveTrades("B") then pos=1  end
		if haveTrades("S") then pos=-1 end
		fstTck= false
	end
 
 
 
 
	  if source.close[period] > maHigh.DATA[period] then
	  Trend[period]=1;	  
      elseif source.close[period] < maLow.DATA[period] then
	  Trend[period]=-1;	
      else
	  Trend[period]= Trend[period-1];		  
	  end
 
 
    if Trend[period] > 0 then
	Top[period]=maHigh.DATA[period];
	Bottom[period]=maLow.DATA[period];
		if showTrend then
		Top:setColor(period, instance.parameters.Up);
		Bottom:setColor(period, instance.parameters.Up);	
		end
	else
	Top[period]=maLow.DATA[period];
	Bottom[period]=maHigh.DATA[period];
		if showTrend then	
		Top:setColor(period, instance.parameters.Down);
		Bottom:setColor(period, instance.parameters.Down);	
		end
	end
	
	up:setNoData(period);
	down:setNoData(period);
	
	Shift= math.abs(Top[period-1]-Bottom[period-1]);
	
	if Trend[period] > 0 and Trend[period-1]< 0 then
	up:set(period, source.low[period]-Shift, "\217" );
	elseif Trend[period]< 0 and Trend[period-1]> 0 then
	down:set(period, source.high[period]+Shift, "\218" );
	end
	
	if period> source:first()+source:size()-2 then
		if  pos~=1  and source.close[period-1] > maHigh.DATA[period-1]  then
			exit("S") enter("B") pos=1 
		end
		if  pos~=-1 and source.close[period-1] < maLow.DATA[period-1]  then
			exit("B") enter("S") pos=-1
		end
		
		if haveTrades("B") and source.close[period]< maLow.DATA[period-tcd]  then exit("B") pos=0 end
		if haveTrades("S") and source.close[period]> maHigh.DATA[period-tcd] then exit("S") pos=0 end
		--terminal:alertMessage(source:name(), 99, ".." ..Trend[period-1]..".."..Trend[period], core.now())
	end
end


--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

-- -----------------------------------------------------------------------
-- Function checks that specified table is ready (filled) for processing
-- or that we running under debugger/simulation conditions.
-- -----------------------------------------------------------------------
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

-- -----------------------------------------------------------------------
-- Return count of opened trades for spicific direction
-- (both directions if BuySell parameters is 'nil')
-- -----------------------------------------------------------------------
function haveTrades(BuySell)
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end

    return found
end

-- enter into the specified direction
function enter(BuySell)
    --if not(AllowTrade) then
    --    return true;
    --end

    local valuemap, success, msg;

    -- do not enter if position in the
    -- specified direction already exists
    if haveTrades(BuySell) then
        return true;
    end

    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * core.host:execute("getTradingProperty", "baseUnitSize", instance.source:instrument(), Account)
    valuemap.BuySell = BuySell;
    valuemap.PegTypeStop = "M";

    if SetLimit then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit;
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit;
        end
    end

    if SetStop then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateStop = instance.ask[NOW] - Stop;
        else
            valuemap.RateStop = instance.bid[NOW] + Stop;
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1;
        end
    end

    if (not CanClose) and (SetStop or SetLimit) then
        valuemap.EntryLimitStop = 'Y'
    end
    
    success, msg = terminal:execute(100, valuemap);

    if not(success) then
		terminal:alertMessage(source:name(), core.now(), "EnterTradeFailed"..msg, core.now())
        return false;
    end

    return true;
end

-- exit from the specified direction
function exit(BuySell)
    --if not(AllowTrade) then
    --    return ;
    --end

    local valuemap, success, msg;
    if haveTrades(BuySell) then
        valuemap = core.valuemap();

        -- switch the direction since the order must be in oppsite direction
        if BuySell == "B" then
            BuySell = "S";
        else
            BuySell = "B";
        end
        valuemap.OrderType = "CM";
        valuemap.OfferID = Offer;
        valuemap.AcctID = Account;
        valuemap.NetQtyFlag = "Y";
        valuemap.BuySell = BuySell;
        success, msg = terminal:execute(101, valuemap);

        if not(success) then
			terminal:alertMessage(source:name(), core.now(), "ExitTradeFailed"..msg, core.now())
        end
    end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
  