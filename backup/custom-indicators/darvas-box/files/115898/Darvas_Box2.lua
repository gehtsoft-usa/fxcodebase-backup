-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2275

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
    indicator:name("Darvas Box");
    indicator:description("Darvas Box");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "UP Color", "UP Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDN", "DN Color", "DN Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local BuffUP=nil;
local BuffDN=nil;
local box_top=0.;
local box_bottom=0.;
local state=1;
local i;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end 
	
    BuffUP = instance:addStream("BuffUP", core.Line, name .. ".UP", "UP", instance.parameters.clrUP, first);
	BuffUP:setWidth(instance.parameters.width1);
    BuffUP:setStyle(instance.parameters.style1);
    BuffDN = instance:addStream("BuffDN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN, first);
	BuffDN:setWidth(instance.parameters.width2);
    BuffDN:setStyle(instance.parameters.style2);
end

function Update(period, mode)
  if (period==source:size()-1) then
   box_top=0.;
   box_bottom=0.;
   state=1;
   local ii;
   local prevstate=0;
   local box_start_pos=0;
   local CurPos=0;
   for i=first,period,1 do
    if state==1 then -- SET_BOXTOP
     box_top=source.high[i-1];
     box_bottom=source.low[i-1];
     if prevstate==0 then
      box_start_pos=i-1;
     end
     prevstate=state;
     state=2;
    elseif state==2 then -- SAVE_BOXTOP
     if box_top<=source.high[i-1] then
      box_top=source.high[i-1];
      if box_bottom>source.low[i-1] then
        box_bottom=source.low[i-1];
      end
      if prevstate==0 then
        box_start_pos=i-1;
      end
      prevstate=state;
      state=1;
     else
      prevstate=state;
      state=3; 
     end
    elseif state==3 then -- SET_BOXBOTTOM
     if box_bottom>source.low[i-1] then
      box_bottom=source.low[i-1];
     end
     if box_top<source.high[i-1] then
      box_top=source.high[i-1];
      if box_bottom>source.low[i-1] then
        box_bottom=source.low[i-1];
      end
      if prevstate==0 then
        box_start_pos=i-1;
      end
      prevstate=state;
      state=2;
     else
      prevstate=state;
      state=4;      
     end
    elseif state==4 then -- SAVE_BOXBOTTOM
      if box_top<source.high[i-1] then
        box_top=source.high[i-1];
        if box_bottom>source.low[i-1] then
          box_bottom=source.low[i-1];
        end
        if prevstate==0 then
          box_start_pos=i-1;
        end
        prevstate=state;
        state=2;
      else
        if box_bottom>source.low[i-1] then
          if box_bottom>source.low[i-1] then
            box_bottom=source.low[i-1];
          end
          if box_top<source.high[i-1] then
            box_top=source.high[i-1];
            if box_bottom>source.low[i-1] then
              box_bottom=source.low[i-1];
            end
            if prevstate==0 then
              box_start_pos=i-1;
            end
            prevstate=state;
            state=2;
          else
            prevstate=state;
            state=3;
          end
        else
          prevstate=state;
          state=5;  
        end  
      end
    elseif state==5 then -- WAIT_SIGNAL
      if prevstate==4 and box_top<source.high[i-1] then
        box_top=source.high[i-1];
        if box_bottom>source.low[i-1] then
          box_bottom=source.low[i-1];
        end
        if prevstate==0 then
          box_start_pos=i-1;
        end
        prevstate=state;
        state=2;
      elseif prevstate==4 and box_bottom>source.low[i-1] then
        box_bottom=source.low[i-1];
        if box_top<source.high[i-1] then
          box_top=source.high[i-1];
          if box_bottom>source.low[i-1] then
            box_bottom=source.low[i-1];
          end
          if prevstate==0 then
            box_start_pos=i-1;
          end
          prevstate=state;
          state=2;
        else
          prevstate=state;
          state=4;
        end
      else
         prevstate=state;
         if box_bottom>source.low[i-1] then
          prevstate=0;
          state=1;
         end
         if box_top<source.high[i-1] then
          prevstate=0;
          state=1;
         end
      end
    end
    for ii=box_start_pos, i, 1 do
      BuffUP[ii]=box_top;
      BuffDN[ii]=box_bottom;
    end
   end 
  end 
end

