-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=7635&p=111559&hilit=Smoothed+ADX#p111559

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
    indicator:name("Smoothed ADX indicator Overlay");
    indicator:description("Smoothed ADX indicator Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addDouble("Alpha1", "Alpha1", "", 0.25);
    indicator.parameters:addDouble("Alpha2", "Alpha2", "", 0.33);
	
	indicator.parameters:addDouble("Level" , "ADX Level", "", 20);

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("UpStrong", "Up color Strong Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownStrong", "Down color Strong Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
end
	 

local first;
local source = nil;
local Period;
local Alpha1;
local Alpha2;
local Level;
local DIP_Temp;
local DIM_Temp;
local ADX_Temp;
local DMI_I;
local ADX_I;
local DIP=nil;
local DIM=nil;
local ADX=nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;


local Up,Down, Neutral,UpStrong,DownStrong;

function Prepare(nameOnly) 
    source = instance.source;
    Period=instance.parameters.Period;
    Alpha1=instance.parameters.Alpha1;
    Alpha2=instance.parameters.Alpha2;
	Level=instance.parameters.Level;
	
	Up = instance.parameters.Up;
    Down= instance.parameters.Down;
	UpStrong = instance.parameters.UpStrong;
    DownStrong= instance.parameters.DownStrong;
    Neutral= instance.parameters.Neutral;
   
 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Alpha1 .. ", " .. Alpha2.. ", " .. Level .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	DIP_Temp = instance:addInternalStream(0, 0);
    DIM_Temp = instance:addInternalStream(0, 0);
    ADX_Temp = instance:addInternalStream(0, 0);
    DMI_I = core.indicators:create("DMI", source, Period);
    ADX_I = core.indicators:create("ADX", source, Period);
	
	first =ADX_I.DATA:first();
	
	
	DIP = instance:addInternalStream(0, 0);
    DIM = instance:addInternalStream(0, 0);
    ADX = instance:addInternalStream(0, 0);
	
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
 
end

function Update(period, mode)


    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	
   if (period<first) then
   open:setColor(period, Neutral);	
   return;
   end
   
    DMI_I:update(mode);
    ADX_I:update(mode);
    DIP_Temp[period]=2*DMI_I.DIP[period]+(Alpha1-2)*DMI_I.DIP[period-1]+(1-Alpha1)*DIP_Temp[period-1];
    DIM_Temp[period]=2*DMI_I.DIM[period]+(Alpha1-2)*DMI_I.DIM[period-1]+(1-Alpha1)*DIM_Temp[period-1];
    ADX_Temp[period]=2*ADX_I.DATA[period]+(Alpha1-2)*ADX_I.DATA[period-1]+(1-Alpha1)*ADX_Temp[period-1];
    DIP[period]=Alpha2*DIP_Temp[period]+(1-Alpha2)*DIP[period-1];
    DIM[period]=Alpha2*DIM_Temp[period]+(1-Alpha2)*DIM[period-1];
    ADX[period]=Alpha2*ADX_Temp[period]+(1-Alpha2)*ADX[period-1];
	
	
	if DIP[period] > DIM[period] then
		
		if DIP[period] > Level then
		open:setColor(period,UpStrong);	
		else
		open:setColor(period,Up);	
		end	
	elseif DIP[period] < DIM[period] then
	 
		if DIM[period] > Level then
		open:setColor(period,DownStrong);	
		else
		open:setColor(period,Down);	
		end
	end
	
	
	
	
 
end

