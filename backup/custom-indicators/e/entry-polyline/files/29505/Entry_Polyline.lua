-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15667
-- Id: 6296

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Entry Polyline");
    indicator:description("Entry Polyline");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("Name", "Line name", "", "1");
    indicator.parameters:addBoolean("SI", "Self-intersection", "", true);
    indicator.parameters:addColor("clr", "Line color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Label color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("FontSize", "Font size", "Font size", 15);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local xx={};
local xx_={};
local yy={};
local CountPoints;
local Label=nil;

local source;
local first;
local useStorage;
local name;
local FirstUpdate;

-- Routine
function Prepare(nameOnly)
  source = instance.source;
  first=source:first();
  name = "EntryPolyline - " .. instance.parameters.Name;
  instance:name(name);
  if nameOnly then return end
    
  core.host:execute ("addCommand", 0, "Remove polyline", "Remove polyline");
  core.host:execute ("addCommand", 1, "Point #1", "Point #1")
  CountPoints=1;
  useStorage =  pcall(require, "storagedb");
  LoadParameters();
  FirstUpdate=true;
  Label = instance:createTextOutput("Label", "Label", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.Lclr, first);
end

function SaveParameters()
 local i;
 local DB;
 if useStorage then
  DB  = storagedb.get_db(name);
  DB:put("CountPoints", CountPoints);
  for i=1,CountPoints-1,1 do
   DB:put("xx" .. i, xx[i]);
   DB:put("yy" .. i, yy[i]);
  end
 end 
end

function LoadParameters()
 local i;
 if useStorage then
  DB  = storagedb.get_db(name);
  CountPoints=tonumber(DB:get("CountPoints", 1));
  for i=1,CountPoints-1,1 do
   xx[i]=tonumber(DB:get("xx" .. i));
   yy[i]=tonumber(DB:get("yy" .. i));
   xx_[i]=math.floor(xx[i]*86400)+i/100;
   core.host:execute ("addCommand", i+1, "Point #" .. i+1, "Point #" .. i+1);
  end
 end 
end

-- Indicator calculation routine
function Update(period)    
 if period==source:size()-1 then
  if FirstUpdate then
   FirstUpdate=false;
   DrawLines();
   DrawLabels();
  end
 else
  FirstUpdate=true;  
 end
end

function SortArrays()
 local xxx={};
 local xxx_={};
 local yyy={};
 table.sort(xx_);
 local ii=1;
 for i=1,CountPoints,1 do
  if xx_[i]~=nil then
   a,b=math.modf(xx_[i]);
   index=math.floor(b*100+0.5);
   if index~=0 then
    xxx[ii]=xx[index];
    yyy[ii]=yy[index];
    xxx_[ii]=math.floor(xx[index]*86400)+ii/100;
    ii=ii+1;
   end
  end 
 end
 return xxx,yyy,xxx_;
end

function AsyncOperationFinished(cookie, success, message)
 if cookie==0 then
  DeleteLabels();
  DeleteLines();
  CountPoints=1;
  SaveParameters();
  return;
 end
 t, c = core.parseCsv(message, ";");
 DeleteLabels();
 yy[cookie]=tonumber(t[0]);
 xx[cookie]=tonumber(t[1]);
 xx_[cookie]=math.floor(xx[cookie]*86400)+cookie/100;
 if cookie==CountPoints then
  CountPoints=CountPoints+1;
  core.host:execute ("addCommand", CountPoints, "Point #" .. CountPoints, "Point #" .. CountPoints) 
 end
   
 DrawLines();
 DrawLabels();
end

function DrawLines()
 local i;
 if instance.parameters.SI==false then
  xx,yy,xx_=SortArrays();
 end
 SaveParameters();
 for i=2,CountPoints-1,1 do
  core.host:execute("drawLine", i-1, xx[i-1], yy[i-1], xx[i], yy[i], instance.parameters.clr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
 end
end

function DrawLabels()
 local i;
 local D;
 for i=1,CountPoints-1,1 do
  D=core.findDate(source, xx[i], false);
  Label:set(D, yy[i], i);
 end
end

function DeleteLabels()
 local i;
 local D;
 for i=1,CountPoints-1,1 do
  D=core.findDate(source, xx[i], false);
  Label:setNoData(D);
 end
end

function DeleteLines()
 local i;
 for i=1,CountPoints-2,1 do
  core.host:execute("removeLine", i);
 end
end

function GetCountPoints() return (CountPoints-1) end

function GetPoint(number) 
 if number>=CountPoints then
  return nil,nil;
 else 
  return xx[number], yy[number];
 end 
end

function GetPair()   return source:instrument() end

function CrossesSection(time1, price1, time2, price2, number, beam)
 local x0,y0,x1,y1;
 if xx[number+1]>xx[number] then
  x0,y0,x1,y1=xx[number],yy[number],xx[number+1],yy[number+1];
 else
  x0,y0,x1,y1=xx[number+1],yy[number+1],xx[number],yy[number];
 end
 local d1=(y0-y1)*time1+(x1-x0)*price1+(x0*y1-x1*y0);
 local d2=(y0-y1)*time2+(x1-x0)*price2+(x0*y1-x1*y0);
 local d=d1*d2;
 if d<0 and (beam or (time2>=x0 and time2<=x1)) then return true else return false end
end

function Crosses(time1, price1, time2, price2, beam)
 local i;
 for i=1,CountPoints-2,1 do
  if CrossesSection(time1, price1, time2, price2, i, beam) then return true end
 end
 return false;
end
