-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58830
-- Id: 9647

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("15 puzzle");
    indicator:description("15 puzzle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color", "", core.rgb(0, 128, 128));
end

local source = nil;
local color;
local VSize=0.8;
local PuzzleSize=0.8;
local FontSize=0.6;
local HeightWindow;
local Field={};
local top, size;
local Message=nil;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
    
    color = instance.parameters.color;
    instance:setLabelColor(color);
    PrepareField();
    core.host:execute("addCommand", 1, "Reset the game");
    core.host:execute("addCommand", 2, "Make a turn");
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        PrepareField();
        Message="";
    elseif cookie == 2 then
        local t, c, sx, sy, x, y, cell;
        t, c = core.parseCsv(message, ";");
        if c >= 4 then
            x = tonumber(t[2]);
            y = tonumber(t[3]);
            Message=nil;
            if x>=top and y>=top and x<=top+4*size and y<=top+4*size then
               x=math.floor((x-top)/size);
               y=math.floor((y-top)/size);
               cell=y*4+x;
               if Field[cell]~=0 then
                if MakeTurn(x,y,x-1,y) or MakeTurn(x,y,x+1,y) or MakeTurn(x,y,x,y-1) or MakeTurn(x,y,x,y+1) then
                 if CheckEnd() then
                  Message="Congratulations!!!";
                  return;
                 end
                 return;
                else
                 Message="This turn is impossible";
                 return;
                end
               else
                Message="This cell is empty";
                return;
               end
            else
               Message="Please, use this command on a field";
               return;
            end
        end
     
    end
end

function MakeTurn(FromX,FromY,ToX,ToY)
 local FromCell=FromY*4+FromX;
 local ToCell=ToY*4+ToX;
 if Field[ToCell]==0 then
  Field[ToCell]=Field[FromCell];
  Field[FromCell]=0;
  return (true);
 else
  return (false);
 end
end

function PrepareField()
 math.randomseed(core.dateToTable(core.now()).sec);
 local i;
 for i=0,14,1 do
  Field[i]=i+1;
 end
 Field[15]=0;
 local HoleX, HoleY=3, 3;
 local NewHoleX, NewHoleY;
 local Maxi=500+math.random(500)+math.random(500);
 local R;
 for i=1,Maxi,1 do
  R=math.random(4);
  if R==1 then
   NewHoleX=HoleX+1;
   NewHoleY=HoleY;
  elseif R==2 then
   NewHoleX=HoleX-1;
   NewHoleY=HoleY;
  elseif R==3 then
   NewHoleY=HoleY+1;
   NewHoleX=HoleX;
  else
   NewHoleY=HoleY-1;
   NewHoleX=HoleX;
  end
  if NewHoleX>3 then
   NewHoleX=2;
  elseif NewHoleX<0 then
   NewHoleX=1; 
  end
  if NewHoleY>3 then
   NewHoleY=2;
  elseif NewHoleY<0 then
   NewHoleY=1; 
  end
  MakeTurn(NewHoleX, NewHoleY, HoleX, HoleY);
  HoleX, HoleY = NewHoleX, NewHoleY;
 end 
 return;
end

function CheckEnd()
 local i;
 for i=0,14,1 do
  if Field[i]~=i+1 then
   return (false);
  end
 end
 return (true);
end

function Update(period)
end

local init = false;

function Draw(stage, context)
    if stage == 2 then
        if not init then
            HeightWindow=context:bottom()-context:top();
            size=math.floor(HeightWindow*VSize/4);
            context:createPen(1, context.SOLID, 3, color);
            context:createSolidBrush(2, core.COLOR_BACKGROUND);
            context:createFont(3, "Arial", size*FontSize/2, size*FontSize, 0);
            context:createHatchBrush(4, context.BDIAGONAL, color);
            context:createFont(5, "Arial", size*FontSize/4, size*FontSize/2, 0);
            init = true;
        end
        local H_Window=context:bottom()-context:top();
        if H_Window~=HeightWindow then
         HeightWindow=H_Window;
         size=math.floor(HeightWindow*VSize/4);
         context:deleteObject(3);
         context:createFont(3, "Arial", size*FontSize/2, size*FontSize, 0);
         context:deleteObject(5);
         context:createFont(5, "Arial", size*FontSize/4, size*FontSize/2, 0);
        end
        size=math.floor(HeightWindow*VSize/4);
        top=HeightWindow*(1-VSize)/2;
        if Message~=nil then
         local W, H = context:measureText(5, Message, context.LEFT);
         context:drawText(5, Message, color, -1, top+5*size, top+size, top+5*size+W, top+size+H, context.LEFT);
        end
        
        context:drawRectangle(1, 2, top, top, top+4*size, top+4*size);
        local x, y;
        local i1, i2;
        for i1=0,3,1 do
         for i2=0,3,1 do
          x=top+(i1+(1-PuzzleSize)/2)*size;
          y=top+(i2+(1-PuzzleSize)/2)*size;
          if i2*4+i1+1==Field[i2*4+i1] then
           context:drawRectangle(1, 4, x, y, x+size*PuzzleSize, y+size*PuzzleSize);
          else
           context:drawRectangle(1, -1, x, y, x+size*PuzzleSize, y+size*PuzzleSize);
          end 
          if Field[i2*4+i1]~=0 then
           context:drawText(3, "" .. Field[i2*4+i1], color, -1, x, y, x+size*PuzzleSize, y+size*PuzzleSize, context.CENTER+context.VCENTER);
          end 
         end
        end

    end
end



