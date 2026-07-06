-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58831
-- Id: 9648

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
    indicator:name("Sudoku game");
    indicator:description("Sudoku game");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Game");
    indicator.parameters:addString("Size", "Size", "", "3");
    indicator.parameters:addStringAlternative("Size", "4x4", "", "2");
    indicator.parameters:addStringAlternative("Size", "9x9", "", "3");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color", "", core.rgb(0, 128, 128));
    indicator.parameters:addColor("Fcolor", "Initial numbers color", "", core.rgb(128, 128, 0));
end

local source = nil;
local color;
local Fcolor;
local EnableGame;
local SSize;
local SSize2, SSize4;
local VSize=0.8;
local PuzzleSize=0.8;
local FontSize=0.6;
local HeightWindow;
local Field={};
local FirstField={};
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
    Fcolor = instance.parameters.Fcolor;
    SSize=tonumber(instance.parameters.Size);
    SSize2=SSize*SSize;
    SSize4=SSize2*SSize2;
    instance:setLabelColor(color);
    PrepareField();
    local i;
    for i=1, SSize2, 1 do
     core.host:execute("addCommand", i, "Put " .. i);
    end
    core.host:execute("addCommand", 11, "Erase cell");
    core.host:execute("addCommand", 12, "Start at the beginning");
    core.host:execute("addCommand", 10, "New game");
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 10 then
        PrepareField();
        Message="";
    elseif cookie==11 and EnableGame then    
        local t, c, x, y, cell;
        t, c = core.parseCsv(message, ";");
        if c >= 4 then
            x = tonumber(t[2]);
            y = tonumber(t[3]);
            Message=nil;
            if x>=top and y>=top and x<=top+SSize2*size and y<=top+SSize2*size then
               x=math.floor((x-top)/size);
               y=math.floor((y-top)/size);
               cell=y*SSize2+x;
               if FirstField[cell]==0 then
                Field[cell]=0;
               else
                Message="You can not erase this cell";
               end
            else
               Message="Please, use this command on a field";
               return;
            end
	 end      
    elseif cookie==12 then
        local i;
	for i=0, SSize4-1, 1 do
	 Field[i]=FirstField[i];
	end	 
    elseif cookie<=SSize2 then
        local t, c, x, y, cell;
        local PrevNumber;
        t, c = core.parseCsv(message, ";");
        if c >= 4 and EnableGame then
            x = tonumber(t[2]);
            y = tonumber(t[3]);
            Message=nil;
            if x>=top and y>=top and x<=top+SSize2*size and y<=top+SSize2*size then
               x=math.floor((x-top)/size);
               y=math.floor((y-top)/size);
               cell=y*SSize2+x;
               if FirstField[cell]==0 then
                PrevNumber=Field[cell];
                Field[cell]=cookie;
                if CheckField() then
                 if CheckEnd() then
                  Message="Congratulations. Sudoku is solved";
                  EnableGame=false;
                 end
                else
                 Field[cell]=PrevNumber;
                 Message="This number is wrong";
                end
               else
	        Message="You can not change this cell";
	       end 
            else
               Message="Please, use this command on a field";
               return;
            end
        end
     
    end
end

function PrepareField()
 local i1, i2;
 for i1=0, SSize2-1, 1 do
  for i2=0, SSize2-1, 1 do
   Field[i1*SSize2+i2]=(i2+i1*SSize+math.floor(i1/SSize)) % SSize2 + 1;
  end
 end
 
 math.randomseed(core.dateToTable(core.now()).sec);
 local MaxSteps;
 local index, index1, index2;
 
 MaxSteps=math.random(100);
 for i1=0, MaxSteps, 1 do
  index1=math.random(0, SSize-1);
  index2=math.random(0, SSize-1);
  if index1~=index2 then
   ChangeBigRows(index1, index2);
  end
 end
 
 MaxSteps=math.random(100);
 for i1=0, MaxSteps, 1 do
  index1=math.random(0, SSize-1);
  index2=math.random(0, SSize-1);
  if index1~=index2 then
   ChangeBigColumns(index1, index2);
  end
 end

 MaxSteps=math.random(100);
 for i1=0, MaxSteps, 1 do
  index=math.random(0, SSize-1);
  index1=math.random(0, SSize-1);
  index2=math.random(0, SSize-1);
  if index1~=index2 then
   ChangeSmallRows(index, index1, index2);
  end
 end
 
 MaxSteps=math.random(100);
 for i1=0, MaxSteps, 1 do
  index=math.random(0, SSize-1);
  index1=math.random(0, SSize-1);
  index2=math.random(0, SSize-1);
  if index1~=index2 then
   ChangeSmallColumns(index, index1, index2);
  end
 end
 
 RemoveNumbers();
 
 for i1=0, SSize4-1, 1 do
  FirstField[i1]=Field[i1];
 end
 
 EnableGame=true;
 return;
end

function CheckRow(Row)
 local Numbers={};
 local i;
 local cell;
 for i=0, SSize2-1, 1 do
  cell=Row*SSize2+i;
  if Field[cell]~=0 then
   if Numbers[Field[cell]]~=nil then
    return false;
   end
   Numbers[Field[cell]]=1;
  end
 end
 return true;
end

function CheckColumn(Column)
 local Numbers={};
 local i;
 local cell;
 for i=0, SSize2-1, 1 do
  cell=Column+i*SSize2;
  if Field[cell]~=0 then
   if Numbers[Field[cell]]~=nil then
    return false;
   end
   Numbers[Field[cell]]=1;
  end
 end
 return true;
end

function CheckSquare(Row, Column)
 local Numbers={};
 local i1, i2;
 local cell;
 for i1=0, SSize-1, 1 do
  for i2=0, SSize-1, 1 do
   cell=Row*SSize2*SSize+Column*SSize+i1*SSize2+i2;
   if Field[cell]~=0 then
    if Numbers[Field[cell]]~=nil then
     return false;
    end
    Numbers[Field[cell]]=1;
   end
  end
 end
 return true;
end

function CheckField()
 local i1, i2;
 for i1=0, SSize-1, 1 do
  for i2=0, SSize-1, 1 do
   if not(CheckRow(i1*SSize+i2)) then
    return false;
   end
   if not(CheckColumn(i1*SSize+i2)) then
    return false;
   end
   if not(CheckSquare(i1, i2)) then
    return false;
   end
  end 
 end
 return true;
end

function RemoveNumbers()
 local Arr={};
 local ArrCount;
 local Enable=true;
 local i1, i2;
 local Number;
 local index;
 while Enable do
  Arr={};
  ArrCount=0;
  for i1=0, SSize4-1, 1 do
   if Field[i1]~=0 then
    Number=Field[i1];
    for i2=1, SSize2, 1 do
     if i2~=Number then
      Field[i1]=i2;
      if CheckField() then
       Field[i1]=Number;
       Number=0;
       break;
      end
     end
    end
    if Number~=0 then
     Field[i1]=Number;
     Arr[ArrCount]=i1;
     ArrCount=ArrCount+1;
    end
   end
  end
  if ArrCount==0 then
   Enable=false;
  else
   index=math.random(0, ArrCount-1);
   Field[Arr[index]]=0;
  end
 end
 return;
end

function ChangeBigRows(Row1, Row2)
 local i1, i2;
 for i1=0, SSize2-1, 1 do
  for i2=0, SSize-1, 1 do
   Field[Row1*SSize2*SSize+i2*SSize2+i1], Field[Row2*SSize2*SSize+i2*SSize2+i1] = Field[Row2*SSize2*SSize+i2*SSize2+i1], Field[Row1*SSize2*SSize+i2*SSize2+i1];
  end
 end
 return;
end

function ChangeBigColumns(Column1, Column2)
 local i1, i2;
 for i1=0, SSize2-1, 1 do
  for i2=0, SSize-1, 1 do
   Field[i1*SSize2+Column1*SSize+i2], Field[i1*SSize2+Column2*SSize+i2] = Field[i1*SSize2+Column2*SSize+i2], Field[i1*SSize2+Column1*SSize+i2];
  end
 end
 return;
end

function ChangeSmallRows(Row, Row1, Row2)
 local i;
 for i=0, SSize2-1, 1 do
  Field[Row*SSize2*SSize+Row1*SSize2+i], Field[Row*SSize2*SSize+Row2*SSize2+i] = Field[Row*SSize2*SSize+Row2*SSize2+i], Field[Row*SSize2*SSize+Row1*SSize2+i];
 end
 return;
end

function ChangeSmallColumns(Column, Column1, Column2)
 local i;
 for i=0, SSize2-1, 1 do
  Field[Column*SSize+Column1+i*SSize2], Field[Column*SSize+Column2+i*SSize2] = Field[Column*SSize+Column2+i*SSize2], Field[Column*SSize+Column1+i*SSize2];
 end
 return;
end

function CheckEnd()
 local i;
 for i=0,SSize4-1,1 do
  if Field[i]==0 then
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
            size=math.floor(HeightWindow*VSize/SSize2);
            context:createPen(1, context.SOLID, 3, color);
            context:createPen(6, context.SOLID, 1, color);
            context:createSolidBrush(2, core.COLOR_BACKGROUND);
            context:createFont(3, "Arial", size*FontSize/2, size*FontSize, 0);
            context:createFont(5, "Arial", size*FontSize/4, size*FontSize/2, 0);
            init = true;
        end
        local H_Window=context:bottom()-context:top();
        if H_Window~=HeightWindow then
         HeightWindow=H_Window;
         size=math.floor(HeightWindow*VSize/SSize2);
         context:deleteObject(3);
         context:createFont(3, "Arial", size*FontSize/2, size*FontSize, 0);
         context:deleteObject(5);
         context:createFont(5, "Arial", size*FontSize/4, size*FontSize/2, 0);
        end
        size=math.floor(HeightWindow*VSize/SSize2);
        top=HeightWindow*(1-VSize)/2;
        if Message~=nil then
         local W, H = context:measureText(5, Message, context.LEFT);
         context:drawText(5, Message, color, core.COLOR_BACKGROUND, top+(SSize2+1)*size, top+size, top+(SSize2+1)*size+W, top+size+H, context.LEFT);
        end
        
        context:drawRectangle(1, 2, top, top, top+SSize2*size, top+SSize2*size);
        local i1, i2;
        for i1=1, SSize2-1, 1 do
         if i1%SSize==0 then
          context:drawLine(1, top, top+i1*size, top+SSize2*size, top+i1*size);
          context:drawLine(1, top+i1*size, top, top+i1*size, top+SSize2*size);
         else
          context:drawLine(6, top, top+i1*size, top+SSize2*size, top+i1*size);
          context:drawLine(6, top+i1*size, top, top+i1*size, top+SSize2*size);
         end
        end
        
        local cell;
        local x, y;
        for i1=0, SSize2-1, 1 do
         for i2=0, SSize2-1, 1 do
          cell=i2*SSize2+i1;
          if Field[cell]~=0 then
           x=top+i1*size;
           y=top+i2*size;
           if FirstField[cell]==0 then
            context:drawText(3, "" .. Field[cell], color, -1, x, y, x+size, y+size, context.CENTER+context.VCENTER);
           else
	    context:drawText(3, "" .. Field[cell], Fcolor, -1, x, y, x+size, y+size, context.CENTER+context.VCENTER);
	   end 
          end 
         end 
        end


    end
end



