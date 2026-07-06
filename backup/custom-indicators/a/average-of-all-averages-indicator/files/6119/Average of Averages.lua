-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2698

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Averege of All Averages Indicator");
    indicator:description("Averege of All Averages Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end
  
local   Method = { "MVA", "EMA", "Wilder","LWMA","SineWMA","TriMA","LSMA", "SMMA", "HMA", "ZeroLagEMA", "DEMA", "T3", "ITrend", "Median", "GeoMean", "REMA", "ILRS", "IE/2", "TriMAgen", "JSmooth"};
local first;
local source = nil;
local Frame;
local MA={};
local MainBuff=nil;
local UPBuff=nil;
local DNBuff=nil;
local ColorMode;

function Prepare(nameOnly)
    source = instance.source;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please download and install Averages Indicator!");
    
    Frame=instance.parameters.Period;
    ColorMode=instance.parameters.ColorMode;
   
	local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    first = source:first();
	local i;
	for i= 1,  20, 1 do
    MA[i] = core.indicators:create("AVERAGES", source, Method[i], Frame ,false);
	first=math.max(first, MA[i].DATA:first());
	end
	
    
    if ColorMode then
	MainBuff =instance:addInternalStream(first, 0);
	UPBuff = instance:addStream("UPBuff", core.Line, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DNBuff = instance:addStream("DNBuff", core.Line, name .. ".DN", "DN", instance.parameters.DNclr, first);   
    UPBuff:setWidth(instance.parameters.widthLinReg);
    UPBuff:setStyle(instance.parameters.styleLinReg);
    DNBuff:setWidth(instance.parameters.widthLinReg);
    DNBuff:setStyle(instance.parameters.styleLinReg);
	else
    MainBuff = instance:addStream("MainBuff", core.Line, name .. ".MA", "MA", instance.parameters.MainClr, first);
	MainBuff:setWidth(instance.parameters.widthLinReg);
    MainBuff:setStyle(instance.parameters.styleLinReg);
   end
end

local COUNT;
local SUM;

function Update(period, mode)

   if period < first then
   return;
   end
   
   local i;
   COUNT = 0;
   SUM = 0
   
   for i= 1,  20, 1 do
   MA[i]:update(mode);
	   if  MA[i].DATA:hasData(period) then
	   COUNT= COUNT+1;
	   SUM=SUM+MA[i].DATA[period];
	   end
   end
    
    if COUNT == 20 then
    
     MainBuff[period]=SUM / COUNT;
	 
      if ColorMode then
			  if MainBuff[period]>MainBuff[period-1] then
				   UPBuff[period]=MainBuff[period];
				   if MainBuff[period-1]<MainBuff[period-2] then
					UPBuff[period-1]=MainBuff[period-1];
				   end
			 else
				   DNBuff[period]=MainBuff[period];
				   if MainBuff[period-1]>MainBuff[period-2] then
					DNBuff[period-1]=MainBuff[period-1];
				   end
			  end
      end 
     
   end 
    
end

