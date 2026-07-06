-- Id: 19078
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=7635&p=111559&hilit=Smoothed+ADX#p111559


function Init()
    indicator:name("Smoothed ADX indicator");
    indicator:description("Smoothed ADX indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("ADX Calculation");
    indicator.parameters:addInteger("Period1", "ADX Period", "", 14);	
    indicator.parameters:addDouble("ADX_Alpha1", "ADX Alpha", "", 0.25);
    indicator.parameters:addDouble("ADX_Alpha2", "DMI Alpha", "", 0.33);
	
	indicator.parameters:addGroup("DMI Calculation");
	indicator.parameters:addInteger("Period2", "DMI Period", "", 14);
	indicator.parameters:addDouble("DMI_Alpha1", "ADX Alpha", "", 0.25);
    indicator.parameters:addDouble("DMI_Alpha2", "DMI Alpha", "", 0.33);
	

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DIPclr", "DIP Color", "DIP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DIMclr", "DIM Color", "DIM Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("ADXclr", "ADX Color", "ADX Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthADX", "ADX Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleADX", "ADX Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleADX", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("widthDMI", "DMI Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleDMI", "DMI Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDMI", core.FLAG_LINE_STYLE);
	
	--15,20,25,40,50,60,70.
	
	indicator.parameters:addGroup("OB/OS Levels");	
	
	indicator.parameters:addBoolean("S1", "Show 1. Line", "", true);
    indicator.parameters:addDouble("level1", "1. Level","", 15); 
	indicator.parameters:addColor("color1", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("S2", "Show 2. Line", "", true);
	indicator.parameters:addDouble("level2", "2. Level","", 20); 
	indicator.parameters:addColor("color2", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("S3", "Show 3. Line", "", true);
	indicator.parameters:addDouble("level3", "3. Level","", 25); 
	indicator.parameters:addColor("color3", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width3","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("S4", "Show 4. Line", "", true);
	indicator.parameters:addDouble("level4", "4. Level","", 40); 
	indicator.parameters:addColor("color4", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width4","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("S5", "Show 5. Line", "", true);
	indicator.parameters:addDouble("level5", "5. Level","", 50); 
	indicator.parameters:addColor("color5", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width5","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("S6", "Show 6. Line", "", true);
	indicator.parameters:addDouble("level6", "6. Level","", 60); 
	indicator.parameters:addColor("color6", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width6","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("S7", "Show 7. Line", "", true);
	indicator.parameters:addDouble("level7", "7. Level","", 70); 
	indicator.parameters:addColor("color7", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width7","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LEVEL_STYLE);
	
		
	indicator.parameters:addGroup("Background Style");
	indicator.parameters:addBoolean("Show", "Show Cloud", "", true);
	  indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
 
	  
end

local first;
local source = nil;
local Period1,Period2;
local DMI_Alpha1;
local DMI_Alpha2;
local ADX_Alpha1;
local ADX_Alpha2;
local DIP_Temp;
local DIM_Temp;
local ADX_Temp;
local DMI_I;
local ADX_I;
local DIP=nil;
local DIM=nil;
local ADX=nil;
local Transparency;
local Show;
 function Prepare(nameOnly) 
    source = instance.source;
    Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
    ADX_Alpha1=instance.parameters.ADX_Alpha1;
    ADX_Alpha2=instance.parameters.ADX_Alpha2;
	DMI_Alpha1=instance.parameters.DMI_Alpha1;
    DMI_Alpha2=instance.parameters.DMI_Alpha2;
	Transparency=instance.parameters.Transparency;
	Show=instance.parameters.Show;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.ADX_Alpha1 .. ", " .. instance.parameters.ADX_Alpha2
    .. ", " .. instance.parameters.Period2.. ", " .. instance.parameters.DMI_Alpha1 .. ", " .. instance.parameters.DMI_Alpha2
	.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
   
    DIP_Temp = instance:addInternalStream(0, 0);
    DIM_Temp = instance:addInternalStream(0, 0);
    ADX_Temp = instance:addInternalStream(0, 0);
    DMI_I = core.indicators:create("DMI", source, Period2);
    ADX_I = core.indicators:create("ADX", source, Period1);
	
	first =ADX_I.DATA:first();
	
   
    DIP = instance:addStream("DIP", core.Line, name .. ".DIP", "DIP", instance.parameters.DIPclr, DMI_I.DATA:first());
    DIM = instance:addStream("DIM", core.Line, name .. ".DIM", "DIM", instance.parameters.DIMclr, DMI_I.DATA:first());
	
	if Show then
	instance:createChannelGroup("Group","Group" , DIP, DIM, instance.parameters.DIPclr, Transparency);
	end
	
    ADX = instance:addStream("ADX", core.Line, name .. ".ADX", "ADX", instance.parameters.ADXclr, ADX_I.DATA:first());
    DIP:setWidth(instance.parameters.widthDMI);
    DIP:setStyle(instance.parameters.styleDMI);
    DIM:setWidth(instance.parameters.widthDMI);
    DIM:setStyle(instance.parameters.styleDMI);
    ADX:setWidth(instance.parameters.widthADX);
    ADX:setStyle(instance.parameters.styleADX);
	
	if instance.parameters.S1 then
	ADX:addLevel(instance.parameters.level1, instance.parameters.style1, instance.parameters.width1, instance.parameters.color1);
	end
	
	if instance.parameters.S2 then
	ADX:addLevel(instance.parameters.level2, instance.parameters.style2, instance.parameters.width2, instance.parameters.color2);
	end
	
	if instance.parameters.S3 then
	ADX:addLevel(instance.parameters.level3, instance.parameters.style3, instance.parameters.width3, instance.parameters.color3);
	end
	
	
	if instance.parameters.S4 then
	ADX:addLevel(instance.parameters.level4, instance.parameters.style4, instance.parameters.width4, instance.parameters.color4);
	end
	
	if instance.parameters.S5 then
	ADX:addLevel(instance.parameters.level5, instance.parameters.style5, instance.parameters.width5, instance.parameters.color5);
	end
	
	if instance.parameters.S6 then
	ADX:addLevel(instance.parameters.level6, instance.parameters.style6, instance.parameters.width6, instance.parameters.color6);
	end
	
	if instance.parameters.S7 then
	ADX:addLevel(instance.parameters.level7, instance.parameters.style7, instance.parameters.width7, instance.parameters.color7);
	end
	
	DIP:setPrecision(math.max(2, instance.source:getPrecision()));  
	DIM:setPrecision(math.max(2, instance.source:getPrecision()));  
	ADX:setPrecision(math.max(2, instance.source:getPrecision()));  
 

end

function Update(period, mode)

   
    DMI_I:update(mode);
    ADX_I:update(mode);
	
	
    if (period>= DMI_I.DATA:first()) then
    DIP_Temp[period]=2*DMI_I.DIP[period]+(DMI_Alpha1-2)*DMI_I.DIP[period-1]+(1-DMI_Alpha1)*DIP_Temp[period-1];
    DIM_Temp[period]=2*DMI_I.DIM[period]+(DMI_Alpha1-2)*DMI_I.DIM[period-1]+(1-DMI_Alpha1)*DIM_Temp[period-1];    
    DIP[period]=DMI_Alpha2*DIP_Temp[period]+(1-DMI_Alpha2)*DIP[period-1];
    DIM[period]=DMI_Alpha2*DIM_Temp[period]+(1-DMI_Alpha2)*DIM[period-1];
	end
	
	if Show then
		if  DIP[period] >  DIM[period] then
		DIP:setColor(period,instance.parameters.DIPclr)
		else
		DIP:setColor(period,instance.parameters.DIMclr)
		end
	end
	
	if period >= ADX_I.DATA:first() then
	ADX_Temp[period]=2*ADX_I.DATA[period]+(ADX_Alpha1-2)*ADX_I.DATA[period-1]+(1-ADX_Alpha1)*ADX_Temp[period-1];
    ADX[period]=ADX_Alpha2*ADX_Temp[period]+(1-ADX_Alpha2)*ADX[period-1];
	end
	
 
end

