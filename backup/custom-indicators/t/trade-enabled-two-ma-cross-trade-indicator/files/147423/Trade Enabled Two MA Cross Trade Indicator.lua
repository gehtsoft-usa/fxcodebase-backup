-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72708

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
    indicator:name("Trade Enabled Two MA Cross Trade Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

 


	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("nFast", "Number of fast periods", "Number of fast periods", 5, 1, 1000);	
    indicator.parameters:addInteger("nSlow", "Number of slow periods", "Number of slow periods", 50, 1, 1000);
	
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
    indicator.parameters:addColor("Up", "fast Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "slow Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Trade Parameters"); 	
	indicator.parameters:addString("Type", "Execution Method", "", "EOT");
    indicator.parameters:addStringAlternative("Type", "Immediately", "", "I");
    indicator.parameters:addStringAlternative("Type", "End Of Turn", "", "EOT");
	
    indicator.parameters:addString("Account", "Account2Trade", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
	indicator.parameters:addInteger("Amount", "Amount", "Amount", 1, 1, 10000)	
    indicator.parameters:addInteger(  "stp",   "stp",   "stop pips", 111, 1, 9999);
    indicator.parameters:addInteger(  "lmt",   "lmt",   "limit pips", 111, 1, 9999);
    indicator.parameters:addInteger( "setSL", "setSL", "0=no stop no limit ,,, 1=set stop but no limit ,,, 2=set both stop and limit", 2, 0, 2);
	indicator.parameters:addBoolean("trlStp", "setTrailingStop", "setTrailingStop", false);
end

local first;
local source = nil;
local nFast, nSlow, slow, fast, maFast, maSlow, maType
local Account, Offer, CanClose, Amount, pos , stp, lmt, setSL, trlStp

-- Routine
 function Prepare(nameOnly)   
    nFast= instance.parameters.nFast;
    nSlow= instance.parameters.nSlow;
    maType= instance.parameters.maType; 
	Type= instance.parameters.Type;
	
	Account = instance.parameters.Account
	Offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID
	CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.source:instrument(), Account);
	Amount = instance.parameters.Amount 
	stp = instance.parameters.stp 
	lmt = instance.parameters.lmt 
	setSL = instance.parameters.setSL 
	trlStp = instance.parameters.trlStp 
	
	local Parameters= nFast..", "..nSlow..", "..maType..", "..stp..", "..lmt..", "..setSL
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters ..", Amt="..Amount..")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
			
    source = instance.source;  
	
	maFast = core.indicators:create("AVERAGES", source, maType, nFast);
    maSlow = core.indicators:create("AVERAGES", source, maType, nSlow);   
    first= math.max(maFast.DATA:first(),maSlow.DATA:first())+1;
			 
	  
	fast = instance:addStream("fast" , core.Line, " fast"," fast",instance.parameters.Up, first );
	fast:setWidth(instance.parameters.width);
    fast:setStyle(instance.parameters.style);
    fast:setPrecision(math.max(2, source:getPrecision()));

	slow = instance:addStream("slow" , core.Line, " slow"," slow",instance.parameters.Down, first );
	slow:setWidth(instance.parameters.width);
    slow:setStyle(instance.parameters.style);
    slow:setPrecision(math.max(2, source:getPrecision()));	
end

local Last;
-- Indicator calculation routine
function Update(period, mode)

    maFast:update(mode);
    maSlow:update(mode);
 
	if period <= first or not(maFast.DATA:hasData(period - 1)) or not(maSlow.DATA:hasData(period - 1))
	then
	return;
	end
	
	 
    if Last==source:serial(period) then
	return;
	end
	
	fast[period]=maFast.DATA[period];
	slow[period]=maSlow.DATA[period];
	
	
 
    if Type == "I" then

				if core.crossesOver(maFast.DATA, maSlow.DATA, period) then
					exit("S") enter("B") 
				elseif  core.crossesOver(maSlow.DATA, maFast.DATA, period) then
					exit("B") enter("S") 
				end
				
			    Last=source:serial(period);	
			 
	else
			 
				if  core.crossesOver(maFast.DATA, maSlow.DATA, period-1) then
					exit("S") enter("B") 
				elseif   core.crossesOver(maSlow.DATA, maFast.DATA, period-1) then
					exit("B") enter("S")  
				end
		
			    Last=source:serial(period);			
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
    valuemap.PegTypeLimit = "M";


    if setSL==2 then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit =  lmt
        else
            valuemap.PegPriceOffsetPipsLimit = -lmt
        end
    end

    if setSL~=0 then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop  = -math.floor(stp)
        else
            valuemap.PegPriceOffsetPipsStop  =  math.floor(stp)
        end
        if trlStp then
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

--===========================================================================--
--                      END OF TRADING UTILITY FUNCTIONS                     --
--===========================================================================--

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+