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
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Double Grid Trade Enabled Indicator");
    indicator:description("Double Grid Trade Enabled Indicator");
--    indicator:requiredSource(core.Tick);
    indicator:requiredSource(core.Bar);
--    indicator:type(core.Oscillator);
    indicator:type(core.Indicator);

    --indicator.parameters:addGroup("BuySell");
	indicator.parameters:addInteger("tp", "targetProfit", "targetProfit", 5, 1, 10000)
	indicator.parameters:addInteger("gsz", "gridPipSize", "gridPipSize", 111, 1, 10000)
	indicator.parameters:addBoolean("go", "go", "go", true)
	indicator.parameters:addInteger("lots", "lots", "lots", 1, 1, 100)
    indicator.parameters:addString("Account", "Account2Trade", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
 end

local 	source, period, Account, lots, Offer, CanClose
local	fst, go, pos, gsz, gu, gd, psz, equity0, tp
		

function Prepare()
	fst= true
	source = instance.source
	psz= source:pipSize()
	tp = instance.parameters.tp 
	gsz = instance.parameters.gsz 
	go = instance.parameters.go 
	Account = instance.parameters.Account;
	lots = instance.parameters.lots 
	Offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
	CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.source:instrument(), Account);
	equity0= core.host:findTable("accounts"):find("AccountID", Account).Equity
	local name = profile:id().."(".." tp=$"..tp..", gsz="..gsz..", lot="..lots..")" 
	instance:name(name);
end


function closeAll()
    local enum, row, BuySell, valuemap, success, msg;
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next();
    while  (row ~= nil) do
		valuemap = core.valuemap();
		valuemap.OrderType = "CM";
		valuemap.OfferID = row.OfferID;
		valuemap.AcctID = Account;
		valuemap.NetQtyFlag = "Y";
		if row.BS=="B" then  valuemap.BuySell="S"  else  valuemap.BuySell="B"  end
		local success, msg = terminal:execute(101, valuemap);
		if not(success) then
			terminal:alertMessage(source:name(), cur, "alert_OpenOrderFailed" .. msg, core.now());
		end
		row = enum:next()
    end
end



function Update(period)
	if period>source:first()+source:size()-2 and go then
		if fst then
			gu= source.close[period]+ gsz*psz
			gd= source.close[period]- gsz*psz
			if haveTrades() then 
				terminal:alertMessage(source:name(), core.now(), "All existing trades will be closed ", core.now());
				exit("S") exit("B")  
			end
			enter("B") enter("S")
			fst= false
		end

		if source.close[period]> gu then
			exit("B", 1)
			enter("B") enter("S")
			gu= source.close[period]+ gsz*psz
			gd= source.close[period]- gsz*psz
		end
		if source.close[period]< gd then
			exit("S", 1)
			enter("B") enter("S")
			gu= source.close[period]+ gsz*psz
			gd= source.close[period]- gsz*psz
		end
	end
	if (core.host:findTable("accounts"):find("AccountID", Account).Equity-equity0)>tp then 
		closeAll()
		go=false 
		terminal:alertMessage(source:name(), core.now(), "SUCCESS !   You´ve won $"..
		(core.host:findTable("accounts"):find("AccountID", Account).Equity-equity0), core.now());
	end
end


function AsyncOperationFinished(cookie, success, message)
end


--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--===========================================================================--

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

function enter(BuySell, rate)
--    if haveTrades(BuySell) then        return true;    end

    local valuemap, success, msg;
    valuemap = core.valuemap();
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = lots * core.host:execute("getTradingProperty", "baseUnitSize", instance.source:instrument(), Account);
    valuemap.BuySell = BuySell;
    valuemap.PegTypeStop = "M";
    valuemap.PegTypeLimit = "M";
		valuemap.OrderType = "OM" 
 
    success, msg = terminal:execute(100, valuemap);
    assert( success, msg )
    return true;
end

function exit(BuySell, net)
    local valuemap, success, msg;
    if haveTrades(BuySell) then
        valuemap = core.valuemap();
        valuemap.OrderType = "CM";
        valuemap.OfferID = Offer;
        valuemap.AcctID = Account;
		if (net==nil or net=="") then   
			valuemap.NetQtyFlag = "Y"
			if BuySell == "B" then     valuemap.BuySell = "S";  else   valuemap.BuySell = "B";    end
			success, msg = terminal:execute(101, valuemap);
				if not(success) then
			terminal:alertMessage(source:name(), core.now(), "Failed to close netting "..msg, core.now());
	end
		else  
			valuemap.NetQtyFlag = "N"
			local enum, row;
			enum = core.host:findTable("trades"):enumerator();
			row = enum:next();
			while (row ~= nil) do
				if row.AccountID == Account and row.OfferID == Offer and row.GrossPL>=0 then
					if (row.BS=="B" and BuySell=="B") then 
						valuemap.BuySell = "S"
						valuemap.TradeID= row.TradeID
						valuemap.Quantity= row.Lot
						success, msg = terminal:execute(101, valuemap);
						if not(success) then
							terminal:alertMessage(source:name(), core.now(), "Failed to close a B "..msg, core.now());
						end
					end
					if (row.BS == "S" and BuySell=="S") then 
						valuemap.BuySell = "B"
						valuemap.TradeID= row.TradeID
						valuemap.Quantity= row.Lot
						success, msg = terminal:execute(101, valuemap);
						if not(success) then
							terminal:alertMessage(source:name(), core.now(), "Failed to close a S "..msg, core.now());
						end
					end
				end
				row = enum:next();
			end
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


