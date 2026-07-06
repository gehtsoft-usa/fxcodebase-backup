-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=10136

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
    indicator:name("Kalman filter");
    indicator:description("Kalman filter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("K", "K", "", 1);
    indicator.parameters:addDouble("Sharpness", "Sharpness", "", 1);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local K;
local Sharpness;
local ColorMode;
local KalmanFilter;
local Velocity;
local ShK;

function Prepare(nameOnly)  
    source = instance.source;
    K=instance.parameters.K;
    Sharpness=instance.parameters.Sharpness;
    ColorMode=instance.parameters.ColorMode;
    first = source:first()+2;
    Velocity = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.K .. ", " .. instance.parameters.Sharpness .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    KalmanFilter = instance:addStream("KalmanFilter", core.Line, name .. ".KalmanFilter", "KalmanFilter", instance.parameters.MainClr, first);
    KalmanFilter:setWidth(instance.parameters.widthLinReg);
    KalmanFilter:setStyle(instance.parameters.styleLinReg);
    ShK=math.sqrt(Sharpness*K/100);
end

function Update(period, mode)
   if (period>first) then
    local Distance=source[period]-KalmanFilter[period-1];
    local Error=KalmanFilter[period-1]+Distance*ShK;
    Velocity[period]=Velocity[period-1]+Distance*K/100;
    KalmanFilter[period]=Error+Velocity[period];
    if ColorMode then
     if Velocity[period]>=0 then
      KalmanFilter:setColor(period,instance.parameters.UPclr);
     else
      KalmanFilter:setColor(period,instance.parameters.DNclr);
     end
    end
   elseif period==first then
    Velocity[period]=0; 
    KalmanFilter[period]=source[period];
   end 
end

