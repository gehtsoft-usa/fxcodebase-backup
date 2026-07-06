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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Entry orders");
    indicator:description("Entry orders");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("Name", "Name", "", "1");
    indicator.parameters:addString("PriceType", "Price type", "", "open");
    indicator.parameters:addStringAlternative("PriceType", "open", "", "open");
    indicator.parameters:addStringAlternative("PriceType", "high", "", "high");
    indicator.parameters:addStringAlternative("PriceType", "low", "", "low");
    indicator.parameters:addStringAlternative("PriceType", "close", "", "close");
    indicator.parameters:addStringAlternative("PriceType", "median", "", "median");
    indicator.parameters:addStringAlternative("PriceType", "typical", "", "typical");
    indicator.parameters:addStringAlternative("PriceType", "weighted", "", "weighted");
    indicator.parameters:addStringAlternative("PriceType", "best (low for BUY, high for SELL)", "", "best");
    indicator.parameters:addStringAlternative("PriceType", "worst (high for BUY, low for SELL)", "", "worst");
    indicator.parameters:addColor("Bclr", "BUY color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Sclr", "SELL color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "Arrow size", 14);
end

local PriceType;
local Points={};
local CountPoints;
local Buff_B=nil;
local Buff_S=nil;

local source;
local first;
local useStorage;
local name;
local FirstUpdate;
local UpdateFlag;
local DB;

-- Routine
function Prepare(nameOnly)
  source = instance.source;
  PriceType=instance.parameters.PriceType;
  first=source:first();
  name = "EntryOrders - " .. instance.parameters.Name;
  instance:name(name);
  
  if   (nameOnly) then
        return;
    end
	
 
  useStorage =  pcall(require, "storagedb");
  if useStorage then
   DB=storagedb.get_db(name);
  end
  core.host:execute ("addCommand", 1, "Close SELL (if exist) and BUY", "Close SELL (if exist) and BUY");
  core.host:execute ("addCommand", 2, "Close BUY (if exist) and SELL", "Close BUY (if exist) and SELL");
  core.host:execute ("addCommand", 3, "Remove orders", "Remove orders");
  Buff_B = instance:createTextOutput ("BUY", "BUY", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.Bclr, first);
  Buff_S = instance:createTextOutput ("SELL", "SELL", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.Sclr, first);
  CountPoints=0;
  LoadParameters();
  FirstUpdate=true;
  UpdateFlag=true;
end

function SaveParameters()
 local i;
 if useStorage then
  DB:put("CountPoints", CountPoints);
  for i=0,CountPoints-1,1 do
   DB:put("Point" .. i, Points[i]);
  end
 end 
end

function LoadParameters()
 local i;
 if useStorage then
  CountPoints=tonumber(DB:get("CountPoints", 0));
  for i=0,CountPoints-1,1 do
   Points[i]=tonumber(DB:get("Point" .. i));
  end
 end 
end

function Update(period, mode)    
  if period==source:size()-1 then
   if FirstUpdate then
    FirstUpdate=false;
    Draw();
   end
  else
   FirstUpdate=true;  
   UpdateFlag=true;
  end
end

function DeleteArrows()
 local i;
 for i=0,CountPoints-1,1 do
  local D=core.findDate(source, math.abs(Points[i]), false);
  Buff_B:setNoData(D);
  Buff_S:setNoData(D);
 end
end

function NewPoint(Point)
 if CountPoints==0 then
  Points[0]=Point;
  CountPoints=1;
  return;
 end
 local AbsPoint=math.abs(Point);
 local i;
 DeleteArrows();
 if AbsPoint<math.abs(Points[0]) then
  if Point*Points[0]>0 then
   Points[0]=Point;
  else
   for i=CountPoints-1,0,-1 do
    Points[i+1]=Points[i];
   end
   Points[0]=Point;
   CountPoints=CountPoints+1;
  end
 elseif AbsPoint>math.abs(Points[CountPoints-1]) then
  if Point*Points[CountPoints-1]>0 then
   Points[CountPoints-1]=Point;
  else
   Points[CountPoints]=Point;
   CountPoints=CountPoints+1;
  end
 elseif AbsPoint==math.abs(Points[0]) and Point*Points[0]<0 then
  for i=1,CountPoints-2,1 do
   Points[i]=Points[i+1];
  end
  Points[0]=Point;
  CountPoints=CountPoints-1;
  core.host:execute("removeLine", CountPoints);
 elseif AbsPoint==math.abs(Points[CountPoints-1]) and Point*Points[CountPoints-1]<0 then
  CountPoints=CountPoints-1;
  Points[CountPoints-1]=Point;
  core.host:execute("removeLine", CountPoints);
 else
  local Pos;
  local Precise;
  for i=1,CountPoints-1,1 do
   if AbsPoint>=math.abs(Points[i-1]) and AbsPoint<=math.abs(Points[i]) then
    if AbsPoint==math.abs(Points[i-1]) then
     Pos=i-1;
     Precise=true;
    elseif AbsPoint==math.abs(Points[i]) then
     Pos=i;
     Precise=true;
    else
     Pos=i-1;
     Precise=false;
    end
    break;
   end
  end  
  if Precise then
   if Point*Points[Pos]<0 then
    for i=Pos,CountPoints-3,1 do
     Points[i]=Points[i+2];
    end
    Points[Pos-1]=Point;
    CountPoints=CountPoints-2;
    core.host:execute("removeLine", CountPoints);
    core.host:execute("removeLine", CountPoints+1);
   end
  else
   if Point*Points[Pos]>0 then
    Points[Pos]=Point;
   else
    Points[Pos+1]=Point;
   end
  end
 end
 SaveParameters();
 UpdateFlag=true;
end

function GetPrice(d1, d2, dir)
 if PriceType=="open" then
  return source.open[d1], source.open[d2];
 elseif PriceType=="close" then
  return source.close[d1], source.close[d2];
 elseif PriceType=="high" then
  return source.high[d1], source.high[d2];
 elseif PriceType=="low" then
  return source.low[d1], source.low[d2];
 elseif PriceType=="median" then
  return source.median[d1], source.median[d2];
 elseif PriceType=="typical" then
  return source.typical[d1], source.typical[d2];
 elseif PriceType=="weighted" then
  return source.weighted[d1], source.weighted[d2];
 elseif PriceType=="best" then
  if dir>0 then
   return source.low[d1], source.high[d2];
  else
   return source.high[d1], source.low[d2];
  end
 else
  if dir>0 then
   return source.high[d1], source.low[d2];
  else
   return source.low[d1], source.high[d2];
  end
 end
end

function Draw()
 local i;
 local	 Point1, Point2;
 local D1, D2, P1, P2;
 for i=1,CountPoints-1,1 do
  D1=core.findDate(source, math.abs(Points[i-1]), false);
  D2=core.findDate(source, math.abs(Points[i]), false);
  P1,P2=GetPrice(D1, D2, Points[i-1]);
  Point1=source:date(D1);
  Point2=source:date(D2);
  if i==1 then
   if Points[i-1]>0 then
    Buff_B:set(D1, P1, "\233");
   else
    Buff_S:set(D1, P1, "\234");
   end
  end
  if Points[i]>0 then
   Buff_B:set(D2, P2, "\233");
  else
   Buff_S:set(D2, P2, "\234");
  end
  if Points[i-1]>0 then
   core.host:execute("drawLine", i, Point1, P1, Point2, P2, instance.parameters.Bclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
  else
   core.host:execute("drawLine", i, Point1, P1, Point2, P2, instance.parameters.Sclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
  end 
 end
end

function GetCountPoints() return (CountPoints) end

function GetPriceType() return (PriceType) end

function GetUpdateFlag()
 if UpdateFlag then
  UpdateFlag=false;
  return true;
 else
  return false;
 end
end

function GetPoint(number) 
 if number>=CountPoints then
  return nil;
 else 
  return Points[number];
 end 
end

function AsyncOperationFinished(cookie, success, message)
   t, c = core.parseCsv(message, ";");
   local ArrSize;
   local period;
   local i;
   if cookie==1 then
    NewPoint(tonumber(t[1]));
   elseif cookie==2 then
    NewPoint(-tonumber(t[1]));
   elseif cookie==3 then
    for i=1,CountPoints-1,1 do
     core.host:execute("removeLine",i);
    end
    DeleteArrows();
    CountPoints=0;
    SaveParameters();
    UpdateFlag=true; 
   end
   Draw();
end

