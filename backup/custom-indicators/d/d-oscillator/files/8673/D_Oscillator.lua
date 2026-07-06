-- Id: 3285

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3608

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
    indicator:name("D oscillator");
    indicator:description("D oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 13);
    indicator.parameters:addInteger("D_Period", "D_Period", "", 8);
    indicator.parameters:addInteger("CCI_Period", "CCI_Period", "", 8);
    indicator.parameters:addDouble("CCI_Coeff", "CCI_Coeff", "", 0.4);
    indicator.parameters:addInteger("Smooth", "Smooth", "", 4);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Arrows Style");
	indicator.parameters:addBoolean("Show", "Show Arrows", "", false);
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold","Oversold Level","", -100);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
 

end

local first;
local source = nil;
local RSI_Period;
local D_Period;
local CCI_Period;
local CCI_Coeff;
local Smooth;
local RSI;
local CCI;
local Buff1=nil;
local Buff2=nil;
local Show;
local Size;
local Up, Down,Neutral;
function Prepare(nameOnly)
    source = instance.source;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
    RSI_Period=instance.parameters.RSI_Period;
	Show=instance.parameters.Show;
	Size=instance.parameters.Size;
    D_Period=instance.parameters.D_Period;
    CCI_Period=instance.parameters.CCI_Period;
    CCI_Coeff=instance.parameters.CCI_Coeff;
    Smooth=instance.parameters.Smooth;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.D_Period .. ", " .. instance.parameters.CCI_Period .. ", " .. instance.parameters.CCI_Coeff .. ", " .. instance.parameters.Smooth .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	RSI = core.indicators:create("RSI", source.close, RSI_Period);
    CCI = core.indicators:create("CCI", source, CCI_Period);
    first = math.max(RSI.DATA:first(),CCI.DATA:first())+2;
	
	
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr1, first);
	Buff1:setWidth(instance.parameters.width1);
    Buff1:setStyle(instance.parameters.style1);
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr2, first);
	Buff2:setWidth(instance.parameters.width2);
    Buff2:setStyle(instance.parameters.style2);
	
	Buff2:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Buff2:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	Buff2:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   
	instance:ownerDrawn(Show);
	
	Buff1:setPrecision(math.max(2, instance.source:getPrecision()));
	Buff2:setPrecision(math.max(2, instance.source:getPrecision()));

end

function Update(period, mode)
   RSI:update(mode);
   CCI:update(mode);
   
   if (period<first+D_Period) then
   return;
   end
   
    local MaxRSI=core.max(RSI.DATA,core.rangeTo(period,D_Period));
    local MinRSI=core.min(RSI.DATA,core.rangeTo(period,D_Period));
    local StRSI=(RSI.DATA[period]-MinRSI)*200/(MaxRSI-MinRSI)-100;
    local StCCI=CCI_Coeff*CCI.DATA[period]+(1-CCI_Coeff)*StRSI;
    local sk=2/(Smooth+1);
    local sk2=2/(Smooth*0.8+1);
    Buff1[period]=sk*StCCI+(1-sk)*Buff1[period-1];
    Buff2[period]=sk2*Buff1[period-1]+(1-sk2)*Buff2[period-1];
  
end


function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
	Gap=  (context:bottom()-context:top())/2;
	context:createFont (1, "Wingdings",Gap, Gap , 0  ); 
	
	if not Buff1:hasData(Buff1:size()-2) 
	or not Buff1:hasData(Buff1:size()-1) 
	or not Buff2:hasData(Buff2:size()-2) 
	or not Buff2:hasData(Buff2:size()-1) 
	then
	return;
	end
	
	if Buff1[Buff1:size()-1] > Buff1[Buff1:size()-2]  then
	Add(context,Up, "\225","Top");
	elseif Buff1[Buff1:size()-1] < Buff1[Buff1:size()-2]  then
	Add(context, Down, "\226","Top");
	else
	Add(context,Neutral, "\167","Top"); 
	end
	
	
	if Buff1[Buff1:size()-1] > Buff2[Buff1:size()-1]  then
	Add(context,Up, "\225","Bottom");
	elseif Buff1[Buff1:size()-1]< Buff2[Buff1:size()-1]  then
	Add(context,Down,"\226","Bottom");
	else
	Add(context,Neutral, "\167","Bottom"); 
	end
end

function Add(context,Color, Symbol, Position)

 
    width, height = context:measureText (1, Symbol , 0  );
	if Position== "Top" then
	context:drawText (1,  Symbol, Color, -1, context:right()-width, context:top(), context:right()  , context:top()+height, 0   );	
	else
	context:drawText (1,  Symbol, Color, -1, context:right()-width, context:bottom()-height, context:right()  , context:bottom(), 0   );	
	end
	
	
end