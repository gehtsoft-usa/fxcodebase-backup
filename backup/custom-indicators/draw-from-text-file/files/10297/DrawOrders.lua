-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4108

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
    indicator:name("Export");
    indicator:description("Export");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addFile("File", "File", "", "");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrLbl", "Color Label", "Color Label", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);

end

local first;
local source = nil;
local handle;
local Buff=nil;
local Label;
local FN;
local hUP;
local lUP;
local hDN;
local lDN;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    FN=instance.parameters.File;
    hUP=instance:addInternalStream(first, 0);
    lUP=instance:addInternalStream(first, 0);
    hDN=instance:addInternalStream(first, 0);
    lDN=instance:addInternalStream(first, 0);
    instance:createChannelGroup("UpGr","Up" , hUP, lUP, instance.parameters.clrUP, 100-instance.parameters.Transparency);
    instance:createChannelGroup("DnGr","Dn" , hDN, lDN, instance.parameters.clrDN, 100-instance.parameters.Transparency);
    Label = instance:createTextOutput ("Lbl", "Lbl", "Arial", 10, core.H_Center, core.V_Top, instance.parameters.clrLbl, first);
end

function Update(period, mode)
   if (period==source:size()-1) then
    local s=0;
    local line;
    local error;
    handle,error=io.open(FN,"r");
    local T=nil;
    for line in handle:lines() do 
     T=line;
     if T~=nil then
      DrawRectangle(T);
     end 
    s=s+10;
    end
    handle:close();
   end 
end

function DrawRectangle(Str)
 local DT1,DT2,Comm,Dir;
 local Pos;
 local Str_=Str;
 local i;
 Pos=string.find(Str_,";");
 Dir=string.sub(Str_,1,Pos-1);
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,";");
 DT1=string.sub(Str_,1,Pos-1);
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,";");
 Comm=string.sub(Str_,1,Pos-1);
 DT2=string.sub(Str_,Pos+1);
 
 local Time1=StrToTime(DT1);
 local Time2=StrToTime(DT2);
 local Bar1=core.findDate(source,Time1,false);
 local Bar2=core.findDate(source,Time2,false);
 local OpenPrice=source.open[Bar1];
 local ClosePrice=source.close[Bar2];
 local MinPrice=math.min(OpenPrice,ClosePrice);
 local MaxPrice=math.max(OpenPrice,ClosePrice);
 local Profit;
 if string.upper(Dir)=="UP" then
  for i=Bar1,Bar2,1 do
   hUP[i]=MaxPrice;
   lUP[i]=MinPrice;
   hDN[i]=nil;
   lDN[i]=nil;
   Profit=(ClosePrice-OpenPrice)/source:pipSize();
  end 
 elseif string.upper(Dir)=="DN" then
  for i=Bar1,Bar2,1 do
   hDN[i]=MaxPrice;
   lDN[i]=MinPrice;
   hUP[i]=nil;
   lUP[i]=nil;
   Profit=(OpenPrice-ClosePrice)/source:pipSize();
  end 
 end
 Label:set(math.floor((Bar1+Bar2)/2), MaxPrice, Comm .. "(" .. math.floor(Profit) .. ")");
end

function StrToTime(Str)
 local Y,M,D,Hour,Min;
 local Pos;
 local Str_=Str;
 Pos=string.find(Str_,"/");
 D=(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,"/");
 M=tonumber(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_," ");
 Y=tonumber(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,":");
 Hour=tonumber(string.sub(Str_,1,Pos-1));
 Min=tonumber(string.sub(Str_,Pos+1));
 return core.datetime(Y,M,D,Hour,Min,0);
end

