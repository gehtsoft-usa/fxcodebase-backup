-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14990
 
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Draw vertical lines");
    indicator:description("Draw vertical lines");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addFile("File", "File", "", "");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("max_value", "Max Value", "Max Value", 100000);	
    indicator.parameters:addColor("clr", "Default Color", "Default Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Default Line width", "Default Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Default Line style", "Default Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);

    indicator.parameters:addString("LabelHPos", "Label Horizontal position", "", "Right");
    indicator.parameters:addStringAlternative("LabelHPos", "Right", "", "Right");
    indicator.parameters:addStringAlternative("LabelHPos", "Left", "", "Left");
    indicator.parameters:addStringAlternative("LabelHPos", "Center", "", "Center");
    indicator.parameters:addString("LabelVPos", "Label Vertical position", "", "Bottom");
    indicator.parameters:addStringAlternative("LabelVPos", "Top", "", "Top");
    indicator.parameters:addStringAlternative("LabelVPos", "Bottom", "", "Bottom");
    indicator.parameters:addStringAlternative("LabelVPos", "Center", "", "Center");
    indicator.parameters:addColor("LabelClr", "Label Color", "Label Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("FontSize", "Label font size", "Label font size", 10);
end

local first;
local source = nil;
local handle;
local font;
local VPos, HPos, VPos2;
local LastPeriod;
local max_value;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	max_value=instance.parameters.max_value;
	
	
    if nameOnly then
        return;
    end
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
    if instance.parameters.LabelHPos=="Right" then
     HPos=core.H_Right;
    elseif instance.parameters.LabelHPos=="Left" then
     HPos=core.H_Left;
    else
     HPos=core.H_Center;
    end 
    if instance.parameters.LabelVPos=="Top" then
     VPos=core.CR_TOP;
     VPos2=core.V_Bottom;
    elseif instance.parameters.LabelVPos=="Bottom" then
     VPos=core.CR_BOTTOM;
     VPos2=core.V_Top;
    else
     VPos=core.CR_CENTER;
     VPos2=core.V_Center;
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
 local Str_=Str .. " ";
 local Pos;
 local DT;
 local Color, Width, Style, Name;
 Pos=string.find(Str_," ");
 DT=string.sub(Str_,1,Pos-1);
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_," ");
 DT=DT .. " " .. string.sub(Str_,1,Pos-1);
 Str_=string.sub(Str_,Pos+1);
 local R, G, B;
 Pos=string.find(Str_," ");
 if Pos~=nil then
  R=tonumber(string.sub(Str_,1,Pos-1));
  Str_=string.sub(Str_,Pos+1);
  Pos=string.find(Str_," ");
  G=tonumber(string.sub(Str_,1,Pos-1));
  Str_=string.sub(Str_,Pos+1);
  Pos=string.find(Str_," ");
  B=tonumber(string.sub(Str_,1,Pos-1));
  Str_=string.sub(Str_,Pos+1);
  Pos=string.find(Str_," ");
  Style=GetStyle(string.sub(Str_,1,Pos-1));
  Str_=string.sub(Str_,Pos+1);
  Pos=string.find(Str_," ");
  Width=tonumber(string.sub(Str_,1,Pos-1));
  Name=string.sub(Str_,Pos+1);
  Color=core.rgb(math.max(R,0),math.max(G,0),math.max(B,0));
 else
  Color=instance.parameters.clr;
  Style=instance.parameters.styleLinReg;
  Width=instance.parameters.widthLinReg;
  Name=nil;
 end 
 local DT_=StrToTime(DT);
 core.host:execute("drawLine", id, DT_, 0, DT_, max_value, Color, Style, Width);
 if Name~=nil then
  core.host:execute("drawLabel1", id, DT_, core.CR_CHART, 0, VPos, HPos, VPos2, font, instance.parameters.LabelClr, Name)
 end 
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

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--| USDT Donations                                                                                 |
--+------------------------------------------------+-----------------------------------------------+
--| Network                                        |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+
