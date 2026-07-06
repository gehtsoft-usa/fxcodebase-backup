-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34200
-- Id: 8919

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
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
    indicator:name(resources:get("name"));			--indicator:name("Risk Management_1");
    indicator:description(resources:get("description"));	--indicator:description(" A tool which helps you analye your risk in Trading.");
    
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("ACCOUNT", resources:get("account"), "", "");
    indicator.parameters:setFlag("ACCOUNT", core.FLAG_ACCOUNT);
    --added by JM Venet
    indicator.parameters:addString("ACC_CCY", resources:get("acc_ccy"), "", "EUR");
    indicator.parameters:addStringAlternative("ACC_CCY", "AUD", "", "AUD");
    indicator.parameters:addStringAlternative("ACC_CCY", "CAD", "", "CAD");
    indicator.parameters:addStringAlternative("ACC_CCY", "CHF", "", "CHF");
    indicator.parameters:addStringAlternative("ACC_CCY", "EUR", "", "EUR");
    indicator.parameters:addStringAlternative("ACC_CCY", "GBP", "", "GBP");
    indicator.parameters:addStringAlternative("ACC_CCY", "JPY", "", "JPY");
    indicator.parameters:addStringAlternative("ACC_CCY", "NZD", "", "NZD");
    indicator.parameters:addStringAlternative("ACC_CCY", "USD", "", "USD");
    -- //////////////////////
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Risk", resources:get("risk_percent"), "", 1.0, 1.0, 100);
    --indicator.parameters:addInteger("MaxDrawDown", "MaxDrawDown", "", 5.0, 1.0, 100);
    indicator.parameters:addInteger("Limit", resources:get("limit"), "", 100, 1, 100000);
    indicator.parameters:addInteger("Stop", resources:get("stop"), "", 75, 1, 100000);

    indicator.parameters:addColor("Color", resources:get("param_Font_Color"), "", core.rgb(0, 255, 255));	-- Modified for Cyan Color
    indicator.parameters:addInteger("Size", resources:get("param_Font_Size"), "", 10, 1, 20);
    indicator.parameters:addString("Position", resources:get("param_Position"), "", "UR");
    indicator.parameters:addStringAlternative("Position", resources:get("param_Upper_Right"), "", "UR");
    indicator.parameters:addStringAlternative("Position", resources:get("param_Upper_Left"), "", "UL");

    --added for Vertical Middle Positions on Chart
    indicator.parameters:addStringAlternative("Position", resources:get("param_Middle_Right"), "", "MR");
    indicator.parameters:addStringAlternative("Position", resources:get("param_Middle_Left"), "", "ML");
     -- /////////////////////
    indicator.parameters:addStringAlternative("Position", resources:get("param_Bottom_Right"), "", "BR");
    indicator.parameters:addStringAlternative("Position", resources:get("param_Bottom_Left"), "", "BL");
end

local first;
local source;
local AccountCcy;
local risk, maxDrawDown;
local takeProfit, stopLoss;
local index;
local indexCount = 0;
local fileName = "_FXCM_Risk_Management_";
local fontSize;
local fontColor;
local Debug = true;

local accountNumber;
local accountName;
local accountType;

local eachPipMoveWorth = pipCost;
local pipSize, pipCost;
local baseUnitSize;
local equityAmount, equityRiskAmount;
local contactSize;
local gainLossPerEachPip;
local maxDrawDownOnEquityCanStand;
local tpPipsMoveWorthInValue, tpPipsMoveWorthInPercent;
local slPipsMoveWorthInValue, slPipsMoveWorthInPercent;

local lastEquity = 0;
local lastMaxDrawDownOnEquityCanStand = 0;
local lastgainLossPerEachPip = 0;
local lastContractSize = 0;
local id = 0;
local lastId = 0;

local fontCreation1, fontCreation, valuefont;

local i;
local xType, yType, hAlign;

function Prepare(nameOnly)

	source = instance.source;
	first = source:first();

	risk = instance.parameters.Risk;
	--maxDrawDown = instance.parameters.MaxDrawDown;
	stopLoss = instance.parameters.Stop;
	takeProfit = instance.parameters.Limit;

	fontSize = instance.parameters.Size;
	fontColor = instance.parameters.Color;
	Position = instance.parameters.Position;
	pipSize = source:pipSize();

	accountNumber = instance.parameters.ACCOUNT;
	AccountCcy=instance.parameters.ACC_CCY;

	local name = profile:id() .. "(".. source:name() .. ", Risk = " .. risk .. "% , Stop = " .. stopLoss .. ", Limit = " .. takeProfit..")";
	instance:name(name);
	if nameOnly then
		return;
	end
	baseUnitSize = core.host:execute("getTradingProperty", "baseUnitSize", source:instrument(), accountNumber);
	equityAmount = core.host:findTable("accounts"):find("AccountID", accountNumber).Equity;

	core.host:trace(" baseUnitSize = " .. baseUnitSize);
        core.host:trace(" Position = " .. Position);
	pipCost = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).PipCost;

	if (baseUnitSize == 1000) then
		accountType = "MICRO";
	end

	if (baseUnitSize == 10000) then
		accountType = "MINI";
	end

	if (baseUnitSize == 100000) then
		accountType = "Standard";
	end

	if (Debug == true) then
		core.host:trace(" pipCost = $" .. pipCost);
		core.host:trace(" baseUnitSize = " .. baseUnitSize);
	end

	fontCreationHeader = core.host:execute("createFont", "Arial", fontSize+2 , false, false);
	fontCreationNonItalics = core.host:execute("createFont", "Arial", fontSize , false, false);
	valuefont = core.host:execute("createFont", "Arial", fontSize , false, true);
	fontCreationItalics = core.host:execute("createFont", "Arial", fontSize , true, false);
	fontCreationNonItalicsNote = core.host:execute("createFont", "Arial", fontSize-2 , false, false);

    if Position == "UR" then
        xType = core.CR_RIGHT;	yType = core.CR_TOP;		hAlign = core.H_Right;
    elseif Position == "UL" then
        xType = core.CR_LEFT;		yType = core.CR_TOP;		hAlign = core.H_Left;
	
    --added for Vertical Middle Positions on Chart 
     elseif Position == "MR" then
        xType = core.CR_RIGHT;	yType = core.CR_CENTER;	hAlign = core.H_Right;
     elseif Position == "ML" then
        xType = core.CR_LEFT;		yType = core.CR_CENTER;	hAlign = core.H_Left;
     -- end of adding
     
     elseif Position == "BR" then
        xType = core.CR_RIGHT;	yType = core.CR_BOTTOM;	hAlign = core.H_Right;
     elseif Position == "BL" then
        xType = core.CR_LEFT;		yType = core.CR_BOTTOM;	hAlign = core.H_Left;
    end
end

function Update(period,mode)
	equityAmount = core.host:findTable("accounts"):find("AccountID", accountNumber).Equity;

	equityRiskAmount = equityAmount * risk/100 ;

	contractSize = (equityRiskAmount / stopLoss) / pipCost;

	--maxDrawDownOnEquityCanStand = (equityAmount*(maxDrawDown/100)) / contractSize / pipCost;

	gainLossPerEachPip = contractSize * pipCost ;

	tpPipsMoveWorthInValue = takeProfit * gainLossPerEachPip;
	tpPipsMoveWorthInPercent = (tpPipsMoveWorthInValue / equityAmount) * 100;

	slPipsMoveWorthInValue = stopLoss * gainLossPerEachPip;
	slPipsMoveWorthInPercent = (slPipsMoveWorthInValue / equityAmount) * 100;

	if 	lastEquity ~= equity or
		--lastMaxDrawDownOnEquityCanStand ~= maxDrawDownOnEquityCanStand or
		lastgainLossPerEachPip ~= gainLossPerEachPip or
		lastContractSize ~= contractSize
		then

		for i=0, lastId, 1 do
			core.host:execute("removeLabel", id);
		end
		lastId = 0;

		if (Debug == true) then
			
			--core.host:trace(" equityRiskAmount =  " );
			--core.host:trace(" baseUnitSize = " .. baseUnitSize);
			--core.host:trace(" eachPipMoveWorth = " .. pipCost);
			--core.host:trace(" equityRiskAmount = " .. equityRiskAmount);
			--core.host:trace(" maxDrawDownOnEquity = $" .. maxDrawDownOnEquity);
			--core.host:trace(" maxDrawDownOnEquityCanStand = " .. maxDrawDownOnEquityCanStand .. " pips.");
			--core.host:trace(" tpPipsMoveWorthInValue = " .. tpPipsMoveWorthInValue);
			--core.host:trace(" tpPipsMoveWorthInPercent = " .. tpPipsMoveWorthInPercent);
			--core.host:trace(" slPipsMoveWorthInValue = " .. slPipsMoveWorthInValue);
			--core.host:trace(" slPipsMoveWorthInPercent = " .. slPipsMoveWorthInPercent);
			
			core.host:trace(" Stop Loss value = " .. stopLoss .. " x " .. gainLossPerEachPip .. "=" ..  slPipsMoveWorthInValue);
			core.host:trace(" Stop Loss value = Stoploss pips x Gain/Loss Per Pip" );
			core.host:trace(" Take profit value = " .. takeProfit .. " x " .. gainLossPerEachPip .. " = " .. tpPipsMoveWorthInValue);
			core.host:trace(" Take profit value = take profit pips x Gain/Loss Per Pip" );
			core.host:trace(" Gain/Loss Per Pip = " .. contractSize .. " x " .. pipCost .. " = " .. gainLossPerEachPip);
			core.host:trace(" Gain/Loss Per Pip = contractSize x pipCost" );
			core.host:trace(" contractSize = " .. "(" .. equityRiskAmount .. "/" .. stopLoss .. ")/" .. pipCost .. "=" .. contractSize);
			core.host:trace(" contractSize = (equityRiskAmount / stopLoss) / pipCost" );
			core.host:trace(" equityRiskAmount = " ..  equityAmount .. " x ("..risk.."/100) = " .. equityRiskAmount);
			core.host:trace(" equityRiskAmount = equity x (risk/100)" );
			core.host:trace(" equity = " .. equityAmount);
		end

		id = 0;

        --Set position of display according to user's selection
        if yType == core.CR_TOP then
            spacing = 10;
	elseif yType == core.CR_CENTER then	-- Added for Vertical Middle Positions on Chart 
	    spacing = -95;				-- Added for Vertical Middle Positions on Chart 
        elseif yType == core.CR_BOTTOM then	-- Modified for Vertical Middle Positions on Chart 
            spacing = -200;
        end
        
        local xCo, xCo1, titleCo;
        if xType == core.CR_RIGHT then
            xCo = 1;
            xCo1 = 1;
            titleCo = 1;
        else
            xCo = -0.1;
            xCo1 = -1;
            titleCo = -1;
        end
		-- - - - - - - - - - - - - - - - -
		core.host:execute("drawLabel1", id, -375*titleCo, xType, spacing , yType, hAlign, core.V_Center, fontCreationNonItalics, fontColor, string.rep ("-", 87));	--"---------------------------------------------------------------------------------------");
		id = id + 1;
		spacing = spacing + 15;

		-- FXCM Risk Management
		core.host:execute("drawLabel1", id, -290*titleCo, xType, spacing , yType, hAlign, core.V_Center, fontCreationHeader, core.rgb(255, 200, 0), resources:get("label_Title_Label"));
		id = id + 1;
		spacing = spacing + 25;

		-- FXCM Programming Services
		core.host:execute("drawLabel1", id, -300*titleCo, xType, spacing , yType, hAlign, core.V_Center, fontCreationNonItalics, fontColor, resources:get("label_Inputs_Outputs"));
		id = id + 1;
		spacing = spacing + 20;

		-- Risk %
		core.host:execute("drawLabel1", id, -340*xCo, xType, spacing, yType, core.H_Right, core.V_Center, fontCreationNonItalics, fontColor, " Risk % :    "  );
		id = id + 1;
		spacing = spacing;
		
		-- Risk % value
		core.host:execute("drawLabel1", id, -340*xCo, xType, spacing, yType, core.H_Right, core.V_Center, valuefont, fontColor, "              " .. round(risk,2) .. "%");
		id = id + 1;
		spacing = spacing;

		-- Trade Size
		core.host:execute("drawLabel1", id, -200*xCo1, xType, spacing, yType, core.H_Right, core.V_Center, fontCreationNonItalics, fontColor, " TradeSize :  ");
		id = id + 1;
		spacing = spacing + 20;
		
		-- Trade Size value
		core.host:execute("drawLabel1", id, -200*xCo1, xType, spacing - 20, yType, core.H_Right, core.V_Center, valuefont, fontColor, "                " .. math.floor(contractSize) .. " Lots");
		id = id + 1;
		spacing = spacing;
		

		-- S/L pips
		core.host:execute("drawLabel1", id, -340*xCo, xType, spacing, yType, core.H_Right, core.V_Center, fontCreationNonItalics, fontColor, " Stop pips :       ");
		id = id + 1;
		spacing = spacing;
		
		-- S/L pips value
		core.host:execute("drawLabel1", id, -340*xCo, xType, spacing, yType, core.H_Right, core.V_Center, valuefont, fontColor, "              " .. tostring(stopLoss));
		id = id + 1;
		spacing = spacing;

		-- SL
		core.host:execute("drawLabel1", id, -200*xCo1, xType, spacing, yType, core.H_Right, core.V_Center, fontCreationNonItalics, fontColor, " Stop :            ");
		id = id + 1;
		spacing = spacing + 20;
		
		-- SL value
		core.host:execute("drawLabel1", id, -200*xCo1, xType, spacing - 20, yType, core.H_Right, core.V_Center, valuefont, fontColor, "            " .. AccountCcy .. " -" .. format_num(slPipsMoveWorthInValue, 2, "", "()") );
		id = id + 1;
		spacing = spacing;
		
		-- T/P pips
		core.host:execute("drawLabel1", id, -340*xCo, xType, spacing, yType, core.H_Right, core.V_Center, fontCreationNonItalics, fontColor, " Limit pips :   " );
		id = id + 1;
		spacing = spacing;
		
		-- T/P pips value
		core.host:execute("drawLabel1", id, -340*xCo, xType, spacing, yType, core.H_Right, core.V_Center, valuefont, fontColor, "              " .. tostring(takeProfit));
		id = id + 1;
		spacing = spacing;

		-- TP
		core.host:execute("drawLabel1", id, -200*xCo1, xType, spacing, yType, core.H_Right, core.V_Center, fontCreationNonItalics, fontColor, " Limit :             ");
		id = id + 1;
		spacing = spacing + 20;
	
		-- TP value
		core.host:execute("drawLabel1", id, -200*xCo1, xType, spacing - 20, yType, core.H_Right, core.V_Center, valuefont, fontColor, "            " .. AccountCcy .. "  " .. format_num(tpPipsMoveWorthInValue, 2, "", "()") );
		id = id + 1;
		
		
		core.host:execute("drawLabel1", id, -340*xCo, xType, spacing, yType, core.H_Right, core.V_Center, fontCreationNonItalics, fontColor, " Equity :     ");
		id = id + 1;
		spacing = spacing + 20;
		
		--Equity value
		core.host:execute("drawLabel1", id, -340*xCo, xType, spacing - 20, yType, core.H_Right, core.V_Center, valuefont, fontColor, "           ".. AccountCcy .. " " .. format_num(equityAmount,2,"", "()"));
		id = id + 1;
		
		-- - - - - - - - - - - - - - - - -
		core.host:execute("drawLabel1", id, -375*titleCo, xType, spacing , yType, hAlign, core.V_Center, fontCreationNonItalics, fontColor, string.rep ("-", 87));	--"---------------------------------------------------------------------------------------");
		id = id + 1;
		spacing = spacing + 20;

		lastEquity = equity;
		--lastMaxDrawDownOnEquityCanStand = maxDrawDownOnEquityCanStand;
		lastgainLossPerEachPip = gainLossPerEachPip;
		lastContractSize = contractSize;
		lastId = id;
	end

end

--------------------------------------------------------------------
-- CODE below is from http://lua-users.org/wiki/FormattingNumbers --
--------------------------------------------------------------------

---============================================================
-- add comma to separate thousands
--
function comma_value(amount)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

---============================================================
-- rounds a number to the nearest decimal places
--
function round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

--===================================================================
-- given a numeric value formats output with comma to separate thousands
-- and rounded to given decimal places
--
function format_num(amount, decimal, prefix, neg_prefix)
	local str_amount,  formatted, famount, remain

	decimal = decimal or 2  -- default 2 decimal places
	neg_prefix = neg_prefix or "-" -- default negative sign

	famount = math.abs(round(amount,decimal))
	famount = math.floor(famount)

	remain = round(math.abs(amount) - famount, decimal)

	-- comma to separate the thousands
	formatted = comma_value(famount)

	-- attach the decimal portion
	if (decimal > 0) then
		remain = string.sub(tostring(remain),3)
		formatted = formatted .. "." .. remain ..
		string.rep("0", decimal - string.len(remain))
	end

	-- attach prefix string e.g '$'
	formatted = (prefix or "") .. formatted

	-- if value is negative then format accordingly
	if (amount<0) then
		if (neg_prefix=="()") then
		formatted = "("..formatted ..")"
		else
		formatted = neg_prefix .. formatted
		end
	end
	return formatted
end





