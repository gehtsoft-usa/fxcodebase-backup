-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2948
-- Id: 2624

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Gross PL indicator");
    indicator:description("Gross PL indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("ShowTotal", "Show total Gross P/L", "", true);
    indicator.parameters:addInteger("Step", "Step on chart", "", 5, 1, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SymbolClr", "Symbol Color", "Symbol Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TotalClr", "Total Color", "Total Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("FontSize", "Font Size", "", 6, 4, 12);
    indicator.parameters:addColor("LblColor", "Color for pattern labels", "", core.COLOR_LABEL);

end

local first;
local source = nil;
local ShowTotal;
local Step;
local BuffAll=nil;
local Buff=nil;
local Symbols={};
local GrossPLs={};
local SymbolsCount;
local PrevSymbolsCount=0;

function Prepare(nameOnly)
    source = instance.source;
    ShowTotal=instance.parameters.ShowTotal;
    Step=instance.parameters.Step;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff=instance:addStream("GrossPL", core.Bar, name .. ".GrossPL", "GrossPL", instance.parameters.SymbolClr, first);
    Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffAll=instance:addStream("TotalPL", core.Bar, name .. ".TotalPL", "TotalPL", instance.parameters.TotalClr, first);
    BuffAll:setPrecision(math.max(2, instance.source:getPrecision()));
    UP = instance:createTextOutput("L", "L", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.LblColor, 0);
    DN = instance:createTextOutput("L", "L", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.LblColor, 0);
end

function Update(period, mode)
   if (period>first and period==source:size()-1) then
    SymbolsCount=0;
    local trades = core.host:findTable("trades");
    local enum = trades:enumerator();
    local TotalPL=0;
    local Symb;
    while true do
     local row = enum:next();
     if row == nil then break end
     Symb=row.Instrument;
     TotalPL=TotalPL+row.GrossPL;
     local FindSymbol=false;
     for i=1,SymbolsCount,1 do
      if Symbols[i]==Symb then
       FindSymbol=true;
       GrossPLs[i]=GrossPLs[i]+row.GrossPL;
      end
     end
     if FindSymbol==false then
      SymbolsCount=SymbolsCount+1;
      Symbols[SymbolsCount]=Symb;
      GrossPLs[SymbolsCount]=row.GrossPL;
     end
    end
    
    local Position=period;
    local shift;
    
    for shift=1,(PrevSymbolsCount+1)*Step,1 do
     if period-shift>first then
      BuffAll[period-shift]=nil;
      Buff[period-shift]=nil;
      UP:setNoData(period-shift);
      DN:setNoData(period-shift);
     end 
    end
    PrevSymbolsCount=SymbolsCount;
    
    if ShowTotal==true then
     BuffAll[Position]=TotalPL;
     if TotalPL>0 then
      UP:set(Position, TotalPL, "Total");
     else
      DN:set(Position, TotalPL, "Total");
     end 
     Position=Position-Step;
    end
    
    for i=1,SymbolsCount,1 do
     Buff[Position]=GrossPLs[i];
     if GrossPLs[i]>0 then
      UP:set(Position, GrossPLs[i], Symbols[i]);
     else
      DN:set(Position, GrossPLs[i], Symbols[i]);
     end 
     Position=Position-Step;
     if Position<first then
      break;
     end
    end
     
   end 
    
    
end

