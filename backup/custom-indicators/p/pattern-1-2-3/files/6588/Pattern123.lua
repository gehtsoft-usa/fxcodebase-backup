-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2891

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
    indicator:name("1-2-3 pattern");
    indicator:description("1-2-3 pattern");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 3, 99);
    indicator.parameters:addInteger("MaxDist", "Maximum distance between 1 and 3 points", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
end

local first;
local source = nil;
local Frame;
local MaxDist;
local UpFrac=nil;
local DnFrac=nil;
local line_id=0;
local pperiod = nil;
local buffUp=nil;
local buffDn=nil;
local Size;
function Prepare(nameOnly)
    source = instance.source;
    Frame=instance.parameters.Frame;
    MaxDist=instance.parameters.MaxDist;
	Size=instance.parameters.Size;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Frame .. ", " .. instance.parameters.MaxDist .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UpFrac = instance:addInternalStream(first, 0);
    DnFrac = instance:addInternalStream(first, 0);
    
    buffUp = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.UPclr, first);
    buffDn = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.DNclr, first);
    
end

function Update(period, mode)
   if pperiod ~= nil and pperiod > period then
       core.host:execute("removeAll");
   end
   pperiod = period;

   if (period>first+Frame) then
    local shift=math.floor((Frame-1)/2)+1;
    local FlUp=true;
    local FlDn=true;
    for i=1,math.floor((Frame-1)/2),1 do
     if source.high[period-i-shift]>=source.high[period-shift] or source.high[period+i-shift]>=source.high[period-shift] then
      FlUp=false;
     end
     if source.low[period-i-shift]<=source.low[period-shift] or source.low[period+i-shift]<=source.low[period-shift] then
      FlDn=false;
     end
    end
    if FlUp==true then
     UpFrac[period-shift]=source.high[period-shift];
    end
    if FlDn==true then
     DnFrac[period-shift]=source.low[period-shift];
    end
    
    local i;
    local Pos1=nil;
    local Pos2=nil;
    local Pos3=nil;
    if UpFrac[period-shift]==source.high[period-shift] then
     Pos3=period-shift;
     for i=1,MaxDist,1 do
      if period>first+shift+i then
       if Pos2==nil then
        if DnFrac[period-shift-i]==source.low[period-shift-i] then
         Pos2=period-shift-i;
        end
       else
        if Pos1==nil then
	 if UpFrac[period-shift-i]==source.high[period-shift-i] then
	  if UpFrac[period-shift-i]>UpFrac[Pos3] then
	   Pos1=period-shift-i;
	  end
	 end
	end 
       end
      end
     end
    end
    
    if Pos1~=nil then
     line_id=line_id+1;
     core.host:execute("drawLine", line_id, source:date(Pos1), UpFrac[Pos1], source:date(Pos2), DnFrac[Pos2], instance.parameters.DNclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
     line_id=line_id+1;
     core.host:execute("drawLine", line_id, source:date(Pos3), UpFrac[Pos3], source:date(Pos2), DnFrac[Pos2], instance.parameters.DNclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
     buffDn:set(Pos3, UpFrac[Pos3], "\226");
    end
    
    Pos1=nil;
    Pos2=nil;
    Pos3=nil;
    if DnFrac[period-shift]==source.low[period-shift] then
     Pos3=period-shift;
     for i=1,MaxDist,1 do
      if period>first+shift+i then
       if Pos2==nil then
        if UpFrac[period-shift-i]==source.high[period-shift-i] then
         Pos2=period-shift-i;
        end
       else
        if Pos1==nil then
	 if DnFrac[period-shift-i]==source.low[period-shift-i] then
	  if DnFrac[period-shift-i]<DnFrac[Pos3] then
	   Pos1=period-shift-i;
	  end
	 end
	end 
       end
      end
     end
    end
    
    if Pos1~=nil then
     line_id=line_id+1;
     core.host:execute("drawLine", line_id, source:date(Pos1), DnFrac[Pos1], source:date(Pos2), UpFrac[Pos2], instance.parameters.UPclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
     line_id=line_id+1;
     core.host:execute("drawLine", line_id, source:date(Pos3), DnFrac[Pos3], source:date(Pos2), UpFrac[Pos2], instance.parameters.UPclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
     buffUp:set(Pos3, DnFrac[Pos3], "\225");
    end
    
    
   end 
    
end

