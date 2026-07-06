-- Id: 4244

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5003

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
    indicator:name("DMI ADX histogram oscillator");
    indicator:description("DMI ADX histogram oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addBoolean("iADX", "Show ADX", "", true);
	indicator.parameters:addBoolean("iDMI", "Show DMI", "", true);
	indicator.parameters:addInteger("LineLevel", "Level", "", 20);
	
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDMI_UP", "Color DMI UP in UP Trend", "Color DMI UP", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("clrDMI_DN", "Color DMI DN", "Color DMI DN", core.rgb(255, 0, 0));
	indicator.parameters:addBoolean("Additional", "Show Additional coloring options", "", true);
	indicator.parameters:addColor("clrDMI_UPDN", "Color DMI DOWN in UP Trend", "Color DMI UP", core.rgb(0, 200, 0));
	indicator.parameters:addColor("clrDMI_DNUP", "Color DMI UP in DOWN Trend", "Color DMI DN", core.rgb(200, 0, 0));
	
	
    indicator.parameters:addColor("clrADX", "Color ADX", "Color ADX", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "ADX width", "ADX width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "ADX style", "ADX style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	
	 
	indicator.parameters:addColor("LineColor", "Level Line Color", "Line Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("LineWidth", "Level Line Width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("LineStyle", "Level Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local DMI;
local ADX;
local BuffDMI=nil;
local BuffADX=nil;
local iADX, iDMI;
local Additional;
local LineColor, LineLevel,LineWidth,LineStyle;
function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
	Additional=instance.parameters.Additional;
	LineColor=instance.parameters.LineColor;
	LineLevel=instance.parameters.LineLevel;
	LineWidth=instance.parameters.LineWidth;
	LineStyle=instance.parameters.LineStyle;
	iADX=instance.parameters.iADX;
	iDMI=instance.parameters.iDMI;
    first = source:first()+Period;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    DMI = core.indicators:create("DMI", source, Period);
    ADX = core.indicators:create("ADX", source, Period);
    
	if iDMI then
    BuffDMI = instance:addStream("BuffDMI", core.Bar, name .. ".DMI", "DMI", instance.parameters.clrDMI_UP, first);
	else
	BuffDMI= instance:addInternalStream(0, 0);
	end
	
    if iADX then
	BuffADX = instance:addStream("BuffADX", core.Line, name .. ".ADX", "ADX", instance.parameters.clrADX, first);
    BuffADX:setWidth(instance.parameters.widthLinReg);
    BuffADX:setStyle(instance.parameters.styleLinReg);
	else
	BuffADX= instance:addInternalStream(0, 0);
	end
	
	BuffDMI:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffADX:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	instance:ownerDrawn(true);
end



local init = false;
 
function Draw(stage, context)
  if stage~= 2 then
  return;
  end
  
        if not init then
			context:createPen (1, context:convertPenStyle (LineStyle), context:pointsToPixels  (LineWidth), LineColor);
            init = true;
        end
		
 
		   
		    visible,Y =context:pointOfPrice (LineLevel);	  
		   
		    context:drawLine (1, context:left (), Y, context:right (), Y);
		 

end


function Update(period, mode)

    DMI:update(mode);
    ADX:update(mode);
	
   if (period<first) then
   return;
   end
   
 
    BuffADX[period]=ADX.DATA[period];
    BuffDMI[period]=DMI.DIP[period]-DMI.DIM[period];
	
    if BuffDMI[period]>0 then
     BuffDMI:setColor(period,instance.parameters.clrDMI_UP);
      if Additional and BuffDMI[period] < BuffDMI[period-1] then
	  BuffDMI:setColor(period,instance.parameters.clrDMI_UPDN);
      end	  
   else
     BuffDMI:setColor(period,instance.parameters.clrDMI_DN);
	  if Additional and BuffDMI[period] > BuffDMI[period-1] then
	  BuffDMI:setColor(period,instance.parameters.clrDMI_DNUP);
      end	   
    end
    
end

