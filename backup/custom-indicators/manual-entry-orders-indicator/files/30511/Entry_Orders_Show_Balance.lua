-- Id: 6396
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16403

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
    indicator:name("Show balance for Entry orders");
    indicator:description("Show balance for Entry orders");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Name", "Name", "", "1");
    indicator.parameters:addDouble("InitialBalance", "Initial balance", "", 50000);
    indicator.parameters:addDouble("LotSize", "Account lot size", "", 10000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BalanceClr", "Balance color", "Balance color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("BalanceWidth", "Balance width", "Balance width", 1, 1, 5);
    indicator.parameters:addInteger("BalanceStyle", "Balance style", "Balance style", core.LINE_SOLID);
    indicator.parameters:setFlag("BalanceStyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("EquityClr", "Equity Color", "Equity Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("EquityWidth", "Equity width", "Equity width", 1, 1, 5);
    indicator.parameters:addInteger("EquityStyle", "Equity style", "Equity style", core.LINE_SOLID);
    indicator.parameters:setFlag("EquityStyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Name;
local InitialBalance;
local LotSize;
local Balance=nil;
local Equity=nil;
local Orders=nil;
local CountPoints;
local Points={};
local PriceType;
local PipCost;
local St_Orders;
local FirstUpdate;

function Prepare(nameOnly)
    source = instance.source;
    Name=instance.parameters.Name;
    InitialBalance=instance.parameters.InitialBalance;
    LotSize=instance.parameters.LotSize;
    first = source:first()+2;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Name .. ", " .. instance.parameters.InitialBalance .. ", " .. instance.parameters.LotSize .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 St_Orders = instance:addInternalStream(first, 0);
	
    Equity = instance:addStream("Equity", core.Line, name .. ".Equity", "Equity", instance.parameters.EquityClr, first);
    Equity:setPrecision(math.max(2, instance.source:getPrecision()));
    Balance = instance:addStream("Balance", core.Line, name .. ".Balance", "Balance", instance.parameters.BalanceClr, first);
    Balance:setPrecision(math.max(2, instance.source:getPrecision()));
    Balance:setWidth(instance.parameters.BalanceWidth);
    Balance:setStyle(instance.parameters.BalanceStyle);
    Equity:setWidth(instance.parameters.EquityWidth);
    Equity:setStyle(instance.parameters.EquityStyle);
    PipCost = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
    FirstUpdate=true;
end

function FindOrders()
 local i, ii;
 Orders=nil;
 for i = 0, interop:size() - 1, 1 do
  ii = interop:instance(i);
  if ii:name() == "EntryOrders - " .. Name then
   Orders=ii;
  end
 end
end

function GetPoints()
 CountPoints=0;
 if Orders==nil or interop:isalive(Orders)==false then
  FindOrders();
 end
 if Orders~=nil then
  CountPoints=Orders:invoke("GetCountPoints");
  PriceType=Orders:invoke("GetPriceType");
  local i;
  for i=0,CountPoints-1,1 do
   Points[i]=Orders:invoke("GetPoint", i);
  end
 end
end

function GetUpdateFlag()
 if Orders==nil or interop:isalive(Orders)==false then
  FindOrders();
 end
 if Orders~=nil then
  return Orders:invoke("GetUpdateFlag");
 end
end

function GetPrice(d, dir)
 if PriceType=="open" then
  return source.open[d];
 elseif PriceType=="close" then
  return source.close[d];
 elseif PriceType=="high" then
  return source.high[d];
 elseif PriceType=="low" then
  return source.low[d];
 elseif PriceType=="median" then
  return source.median[d];
 elseif PriceType=="typical" then
  return source.typical[d];
 elseif PriceType=="weighted" then
  return source.weighted[d];
 elseif PriceType=="best" then
  if dir>0 then
   return source.low[d];
  else
   return source.high[d];
  end
 else
  if dir>0 then
   return source.high[d];
  else
   return source.low[d];
  end
 end
end

function GetPeriod(DT)
 local dir;
 if DT>=0 then dir=1; else dir=-1; end
 local Period=core.findDate(source, math.abs(DT), false);
 return Period, dir;
end

function Update(period, mode)
   if (period==source:size()-1) then
    if GetUpdateFlag() or FirstUpdate then
     FirstUpdate=false;
     GetPoints();
     if CountPoints>0 then
      local i;
      local Period, dir=GetPeriod(Points[0]);
      local Period2;
      core.drawLine(St_Orders, core.range(first, Period), 0, first, 0, Period);
      for i=1,CountPoints-1,1 do
       Period, dir=GetPeriod(Points[i-1]);
       Period2=GetPeriod(Points[i]);
       if Period~=Period2 then
        core.drawLine(St_Orders, core.range(Period, Period2), dir, Period, dir, Period2);
       end 
      end
      Period=GetPeriod(Points[CountPoints-1]);
      if Period~=source:size()-1 then
       core.drawLine(St_Orders, core.range(Period, source:size()-1), 0, Period, 0, source:size()-1);
      end 
     else
      core.drawLine(St_Orders, core.range(first, period), 0, first, 0, period);
     end 
     Equity[first]=InitialBalance;
     Balance[first]=InitialBalance;
     local d;
     for i=first+1,period,1 do
      local Price1=GetPrice(i,St_Orders[i]);
      local Price2=GetPrice(i-1,St_Orders[i-1]);
      d=(Price1-Price2)*PipCost*LotSize*St_Orders[i-1];
      Equity[i]=Equity[i-1]+d;
      if St_Orders[i]==St_Orders[i-1] then
       Balance[i]=Balance[i-1];
      else
       Balance[i]=Equity[i]; 
      end 
     end
    end
   end 
end

