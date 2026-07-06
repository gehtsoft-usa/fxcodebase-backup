-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65187

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Draw diagonal lines");
    indicator:description("Draw diagonal lines");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addFile("File", "File", "", "");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Default Color", "Default Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Default Line width", "Default Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Default Line style", "Default Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local handle;
local LastPeriod;

function Prepare(nameOnly)  
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end	
	
    LastPeriod=nil;
end

function Update(period, mode)
   if (period==source:size()-1) and LastPeriod~=period then
    LastPeriod=period;
    local i=1;
    local line;
    local error;
    handle,error=io.open(instance.parameters.File,"r");
    local T=nil;
    for line in handle:lines() do 
     T=line;
     if T~=nil then
      DrawLine(i,T);
     end 
     i=i+1;
    end
    handle:close();
   end 
end

function DrawLine(id, Str)
 local T, C=core.parseCsv(Str, ",");
 local DT1, DT2, Price1, Price2;
 local Color, Width, Style;
 local R, G, B;
 DT1=T[0] .. " " .. T[1];
 Price1=tonumber(T[2]);
 DT2=T[3] .. " " .. T[4];
 Price2=tonumber(T[5]);

 if C>=11 then
  R=tonumber(T[6]);
  G=tonumber(T[7]);
  B=tonumber(T[8]);
  Color=core.rgb(R,G,B);
  Style=GetStyle(T[9]);
  Width=tonumber(T[10]);
 else
  Color=instance.parameters.clr;
  Style=instance.parameters.styleLinReg;
  Width=instance.parameters.widthLinReg;
 end

 local DT1_=StrToTime(DT1);
 local DT2_=StrToTime(DT2);
 core.host:execute("drawLine", id, DT1_, Price1, DT2_, Price2, Color, Style, Width);
end

function GetStyle(s)
 local Str=string.upper(s);
 if Str=="DASH" then
  return core.LINE_DASH;
 elseif Str=="DASHDOT" then
  return core.LINE_DASHDOT;
 elseif Str=="DOT" then
  return core.LINE_DOT;
 else
  return core.LINE_SOLID;
 end
end

function StrToTime(Str)
 local Y,M,D,Hour,Min;
 local Pos;
 local Str_=Str;
 Pos=string.find(Str_,"/");
 M=(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,"/");
 D=tonumber(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_," ");
 Y=tonumber(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,":");
 Hour=tonumber(string.sub(Str_,1,Pos-1));
 Min=tonumber(string.sub(Str_,Pos+1));
 return core.datetime(Y,M,D,Hour,Min,0);
end

