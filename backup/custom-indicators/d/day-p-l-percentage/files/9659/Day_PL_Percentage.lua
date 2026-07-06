-- Id: 3638
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3911

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Shows % Day P/L");
    indicator:description("Shows the Day P/L as % from the account equity balance at the beginning of the trading day (17:00 EST).");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("ACCT", "Account", "Account to watch.", "");
    indicator.parameters:setFlag("ACCT", core.FLAG_ACCOUNT);


--    indicator.parameters:addString("T", resources:get("param_T_name"), resources:get("param_T_description"), "0");
--   indicator.parameters:addStringAlternative("T", resources:get("string_alternative_T_Time"), "", "0");
--   indicator.parameters:addStringAlternative("T", resources:get("string_alternative_T_Percentage"), "", "1");
--   indicator.parameters:addStringAlternative("T", resources:get("string_alternative_T_Both"), "", "2");
    indicator.parameters:addColor("FC", "Font color", "The color of the font.", core.COLOR_LABEL);
end

local source;
local len;
local out;
local L;
local T;
local ACCT;
local DayPL;
local M2M;
local p;
local host;

function Prepare(onlyName)

    host = core.host;

    source = instance.source;
    assert(source:isAlive(), "The chart must be live price, not history.");

--    local name = profile:id();
local name = "Day P/L: ";

    instance:name(name);

    ACCT = instance.parameters.ACCT;

    if onlyName then
        return ;
    end

    out = instance:createTextOutput ("O", "O", "Arial", 9, core.H_Center, core.V_Top, instance.parameters.FC, 0);

end

function Update(period, mode)

  InitAccount();

  if M2M ~= 0 then
      p = (DayPL/M2M)*100;
      p = math.floor(p * (100) + 0.5) / (100)
      host:execute("setStatus", tostring(p).." %");
  else 
      p = "N/A";
      host:execute("setStatus", tostring(p));
  end

end



function InitAccount()
    if not(core.host:execute("isTableFilled", "accounts")) then
        -- relogin??
        return false;
    end

    local acctRow = host:findTable("accounts"):find("AccountID", ACCT);
    if acctRow ~= nil then
        DayPL = acctRow:cell("DayPL");
        M2M = acctRow:cell("M2MEquity");
    end
    
    return true;
end


