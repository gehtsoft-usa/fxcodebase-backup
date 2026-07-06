-- Id: 2507
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2851

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Account indicator");
    indicator:description("Account indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("ShowMethod", "Accounts show method", "", "Together");
    indicator.parameters:addStringAlternative("ShowMethod", "Together", "", "Together");
    indicator.parameters:addStringAlternative("ShowMethod", "Separately", "", "Separately");
    indicator.parameters:addBoolean("ShowBalance", "Show balance", "", true);
    indicator.parameters:addBoolean("ShowEquity", "Show equity", "", true);
    indicator.parameters:addBoolean("ShowDayPL", "Show day profit/loss", "", true);
    indicator.parameters:addBoolean("ShowNontrdEqty", "Show non-trading equity", "", true);
    indicator.parameters:addBoolean("ShowM2MEquity", "Show floating balance at the beginning of the trading day", "", true);
    indicator.parameters:addBoolean("ShowUsedMargin", "Show used margin", "", true);
    indicator.parameters:addBoolean("ShowUsableMargin", "Show usable margin", "", true);
    indicator.parameters:addBoolean("ShowGrossPL", "Show profit/loss on all open position", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BalanceClr", "Balance Color", "Balance Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("EquityClr", "Equity Color", "Equity Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DayPLClr", "DayPL Color", "DayPL Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("NontrdEqtyClr", "NontrdEqty Color", "NontrdEqty Color", core.rgb(255, 128, 0));
    indicator.parameters:addColor("M2MEquityClr", "M2MEquity Color", "M2MEquity Color", core.rgb(255, 0, 128));
    indicator.parameters:addColor("UsedMarginClr", "UsedMargin Color", "UsedMargin Color", core.rgb(0, 128, 255));
    indicator.parameters:addColor("UsableMarginClr", "UsableMargin Color", "UsableMargin Color", core.rgb(128, 0, 255));
    indicator.parameters:addColor("GrossPLClr", "GrossPL Color", "GrossPL Color", core.rgb(128, 0, 128));

end

local first;
local source = nil;
local ShowMethod;
local BalanceArray={};
local EquityArray={};
local DayPLArray={};
local NontrdEqtyArray={};
local M2MEquityArray={};
local UsedMarginArray={};
local UsableMarginArray={};
local GrossPLArray={};
local AccountsNumber;

function Prepare(nameOnly)
    source = instance.source;
    ShowMethod=instance.parameters.ShowMethod;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    if ShowMethod=="Together" then
     if instance.parameters.ShowBalance==true then
      BalanceArray[1] = instance:addStream("Balance", core.Line, name .. ".Balance", "B", instance.parameters.BalanceClr, first);
    BalanceArray[1]:setPrecision(math.max(2, instance.source:getPrecision()));
     end
     if instance.parameters.ShowEquity==true then
      EquityArray[1] = instance:addStream("Equity", core.Line, name .. ".Equity", "Eq", instance.parameters.EquityClr, first);
    EquityArray[1]:setPrecision(math.max(2, instance.source:getPrecision()));
     end
     if instance.parameters.ShowDayPL==true then 
      DayPLArray[1] = instance:addStream("DayPL", core.Line, name .. ".DayPL", "DPL", instance.parameters.DayPLClr, first);
    DayPLArray[1]:setPrecision(math.max(2, instance.source:getPrecision()));
     end
     if instance.parameters.ShowNontrdEqty==true then 
      NontrdEqtyArray[1] = instance:addStream("NontrdEqty", core.Line, name .. ".NontrdEqty", "NEq", instance.parameters.NontrdEqtyClr, first);
    NontrdEqtyArray[1]:setPrecision(math.max(2, instance.source:getPrecision()));
     end
     if instance.parameters.ShowM2MEquity==true then 
      M2MEquityArray[1] = instance:addStream("M2MEquity", core.Line, name .. ".M2MEquity", "M2MEq", instance.parameters.M2MEquityClr, first);
    M2MEquityArray[1]:setPrecision(math.max(2, instance.source:getPrecision()));
     end
     if instance.parameters.ShowUsedMargin==true then 
      UsedMarginArray[1] = instance:addStream("UsedMargin", core.Line, name .. ".UsedMargin", "UsedM", instance.parameters.UsedMarginClr, first);
    UsedMarginArray[1]:setPrecision(math.max(2, instance.source:getPrecision()));
     end
     if instance.parameters.ShowUsableMargin==true then 
      UsableMarginArray[1] = instance:addStream("UsableMargin", core.Line, name .. ".UsableMargin", "UsableM", instance.parameters.UsableMarginClr, first);
    UsableMarginArray[1]:setPrecision(math.max(2, instance.source:getPrecision()));
     end
     if instance.parameters.ShowGrossPL==true then 
      GrossPLArray[1] = instance:addStream("GrossPL", core.Line, name .. ".GrossPL", "GrPL", instance.parameters.GrossPLClr, first);
    GrossPLArray[1]:setPrecision(math.max(2, instance.source:getPrecision()));
     end 
    else
     local accounts = core.host:findTable("accounts");
     local enum = accounts:enumerator();
     AccountsNumber=0;
     while true do
      local row = enum:next();
      if row == nil then break end
      AccountsNumber=AccountsNumber+1;
      if instance.parameters.ShowBalance==true then
       BalanceArray[AccountsNumber]=instance:addStream("Balance" .. AccountsNumber, core.Line, name .. ".Balance " .. row.AccountID, "B " .. row.AccountID, instance.parameters.BalanceClr, first);
    BalanceArray[AccountsNumber]:setPrecision(math.max(2, instance.source:getPrecision()));
      end
      if instance.parameters.ShowEquity==true then 
       EquityArray[AccountsNumber]=instance:addStream("Equity" .. AccountsNumber, core.Line, name .. ".Equity " .. row.AccountID, "Eq " .. row.AccountID, instance.parameters.EquityClr, first);
    EquityArray[AccountsNumber]:setPrecision(math.max(2, instance.source:getPrecision()));
      end
      if instance.parameters.ShowDayPL==true then 
       DayPLArray[AccountsNumber]=instance:addStream("DayPL" .. AccountsNumber, core.Line, name .. ".DayPL " .. row.AccountID, "DPL " .. row.AccountID, instance.parameters.DayPLClr, first);
    DayPLArray[AccountsNumber]:setPrecision(math.max(2, instance.source:getPrecision()));
      end
      if instance.parameters.ShowNontrdEqty==true then 
       NontrdEqtyArray[AccountsNumber]=instance:addStream("NontrdEqty" .. AccountsNumber, core.Line, name .. ".NontrdEqty " .. row.AccountID, "NEq " .. row.AccountID, instance.parameters.NontrdEqtyClr, first);
    NontrdEqtyArray[AccountsNumber]:setPrecision(math.max(2, instance.source:getPrecision()));
      end
      if instance.parameters.ShowM2MEquity==true then 
       M2MEquityArray[AccountsNumber]=instance:addStream("M2MEquity" .. AccountsNumber, core.Line, name .. ".M2MEquity " .. row.AccountID, "M2MEq " .. row.AccountID, instance.parameters.M2MEquityClr, first);
    M2MEquityArray[AccountsNumber]:setPrecision(math.max(2, instance.source:getPrecision()));
      end
      if instance.parameters.ShowUsedMargin==true then 
       UsedMarginArray[AccountsNumber]=instance:addStream("UsedMargin" .. AccountsNumber, core.Line, name .. ".UsedMargin " .. row.AccountID, "UsedM " .. row.AccountID, instance.parameters.UsedMarginClr, first);
    UsedMarginArray[AccountsNumber]:setPrecision(math.max(2, instance.source:getPrecision()));
      end
      if instance.parameters.ShowUsableMargin==true then
       UsableMarginArray[AccountsNumber]=instance:addStream("UsableMargin" .. AccountsNumber, core.Line, name .. ".UsableMargin " .. row.AccountID, "UsableM " .. row.AccountID, instance.parameters.UsableMarginClr, first);
    UsableMarginArray[AccountsNumber]:setPrecision(math.max(2, instance.source:getPrecision()));
      end
      if instance.parameters.ShowGrossPL==true then 
       GrossPLArray[AccountsNumber]=instance:addStream("GrossPL" .. AccountsNumber, core.Line, name .. ".GrossPL " .. row.AccountID, "GrPL " .. row.AccountID, instance.parameters.GrossPLClr, first);
    GrossPLArray[AccountsNumber]:setPrecision(math.max(2, instance.source:getPrecision()));
      end 
     end 
    
    end 
end

function Update(period, mode)
   if (period>first) then
    local accounts = core.host:findTable("accounts");
    local enum = accounts:enumerator();
    local SumBalance=0;
    local SumEquity=0;
    local SumDayPL=0;
    local SumNontrdEqty=0;
    local SumM2MEquity=0;
    local SumUsedMargin=0;
    local SumUsableMargin=0;
    local SumGrossPL=0;
    local i=0;
    while true do
     local row = enum:next();
     if row == nil then break end
     SumBalance=SumBalance+row.Balance;
     SumEquity=SumEquity+row.Equity;
     SumDayPL=SumDayPL+row.DayPL;
     SumNontrdEqty=SumNontrdEqty+row.NontrdEqty;
     SumM2MEquity=SumM2MEquity+row.M2MEquity;
     SumUsedMargin=SumUsedMargin+row.UsedMargin;
     SumUsableMargin=SumUsableMargin+row.UsableMargin;
     SumGrossPL=SumGrossPL+row.GrossPL;
     i=i+1;
     if ShowMethod=="Separately" then
      if instance.parameters.ShowBalance==true then
       core.drawLine(BalanceArray[i],core.range(first,period),row.Balance,first,row.Balance,period);
      end
      if instance.parameters.ShowEquity==true then
       core.drawLine(EquityArray[i],core.range(first,period),row.Equity,first,row.Equity,period);
      end
      if instance.parameters.ShowDayPL==true then 
       core.drawLine(DayPLArray[i],core.range(first,period),row.DayPL,first,row.DayPL,period);
      end
      if instance.parameters.ShowNontrdEqty==true then 
       core.drawLine(NontrdEqtyArray[i],core.range(first,period),row.NontrdEqty,first,row.NontrdEqty,period);
      end
      if instance.parameters.ShowM2MEquity==true then 
       core.drawLine(M2MEquityArray[i],core.range(first,period),row.M2MEquity,first,row.M2MEquity,period);
      end
      if instance.parameters.ShowUsedMargin==true then 
       core.drawLine(UsedMarginArray[i],core.range(first,period),row.UsedMargin,first,row.UsedMargin,period);
      end
      if instance.parameters.ShowUsableMargin==true then 
       core.drawLine(UsableMarginArray[i],core.range(first,period),row.UsableMargin,first,row.UsableMargin,period);
      end
      if instance.parameters.ShowGrossPL==true then 
       core.drawLine(GrossPLArray[i],core.range(first,period),row.GrossPL,first,row.GrossPL,period);
      end 
     end
    end 
    
    if ShowMethod=="Together" then
     if instance.parameters.ShowBalance==true then
      core.drawLine(BalanceArray[1],core.range(first,period),SumBalance,first,SumBalance,period);
     end
     if instance.parameters.ShowEquity==true then 
      core.drawLine(EquityArray[1],core.range(first,period),SumEquity,first,SumEquity,period);
     end
     if instance.parameters.ShowDayPL==true then 
      core.drawLine(DayPLArray[1],core.range(first,period),SumDayPL,first,SumDayPL,period);
     end
     if instance.parameters.ShowNontrdEqty==true then 
      core.drawLine(NontrdEqtyArray[1],core.range(first,period),SumNontrdEqty,first,SumNontrdEqty,period);
     end
     if instance.parameters.ShowM2MEquity==true then 
      core.drawLine(M2MEquityArray[1],core.range(first,period),SumM2MEquity,first,SumM2MEquity,period);
     end
     if instance.parameters.ShowUsedMargin==true then 
      core.drawLine(UsedMarginArray[1],core.range(first,period),SumUsedMargin,first,SumUsedMargin,period);
     end
     if instance.parameters.ShowUsableMargin==true then 
      core.drawLine(UsableMarginArray[1],core.range(first,period),SumUsableMargin,first,SumUsableMargin,period);
     end
     if instance.parameters.ShowGrossPL==true then 
      core.drawLine(GrossPLArray[1],core.range(first,period),SumGrossPL,first,SumGrossPL,period);
     end 
    end 
   end 
    
end

