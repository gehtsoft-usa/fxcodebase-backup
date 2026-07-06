-- Id: 12265
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=990

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("FXprime");
    indicator:description("FXprime");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("AngleTreshold", "AngleTreshold", "", 0.2);
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 8);
    
    indicator.parameters:addString("RSI_Price", "Price for RSI", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("RSI_Price", "open", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("RSI_Price", "low", "", "low");
    
    indicator.parameters:addString("chk_rsi", "chk_rsi", "", "false");
    indicator.parameters:addStringAlternative("chk_rsi", "true", "", "true");
    indicator.parameters:addStringAlternative("chk_rsi", "false", "", "false");
    
    indicator.parameters:addString("check_ema_angle", "check_ema_angle", "", "true");
    indicator.parameters:addStringAlternative("check_ema_angle", "true", "", "true");
    indicator.parameters:addStringAlternative("check_ema_angle", "false", "", "false");

    indicator.parameters:addString("display_fxprime_short", "display_fxprime_short", "", "true");
    indicator.parameters:addStringAlternative("display_fxprime_short", "true", "", "true");
    indicator.parameters:addStringAlternative("display_fxprime_short", "false", "", "false");

    indicator.parameters:addString("display_fxprime_long", "display_fxprime_long", "", "true");
    indicator.parameters:addStringAlternative("display_fxprime_long", "true", "", "true");
    indicator.parameters:addStringAlternative("display_fxprime_long", "false", "", "false");
    
    indicator.parameters:addString("display_fxprime_exit", "display_fxprime_exit", "", "true");
    indicator.parameters:addStringAlternative("display_fxprime_exit", "true", "", "true");
    indicator.parameters:addStringAlternative("display_fxprime_exit", "false", "", "false");
        
    indicator.parameters:addInteger("indicator_period", "indicator_period", "", 0);
    indicator.parameters:addInteger("previous_shift", "previous_shift", "", 1);
    indicator.parameters:addInteger("cci_period", "cci_period", "", 50);
    indicator.parameters:addInteger("long_period", "long_period", "", 170);
    indicator.parameters:addInteger("short_rsi", "short_rsi", "", 8);
    indicator.parameters:addInteger("long_rsi", "long_rsi", "", 14);
    indicator.parameters:addInteger("filter_out_cci", "filter_out_cci", "", 5);   
    indicator.parameters:addDouble("filter_out_long", "filter_out_long", "", 165);   
    indicator.parameters:addDouble("filter_out_short", "filter_out_short", "", -165);
     
    indicator.parameters:addDouble("exit_cci_cross_long", "exit_cci_cross_long", "", 0);
    indicator.parameters:addDouble("exit_cci_cross_short", "exit_cci_cross_short", "", 0);
    indicator.parameters:addDouble("long_rsi_cross", "long_rsi_cross", "", 55);
    indicator.parameters:addDouble("short_rsi_cross", "short_rsi_cross", "", 45);
     
    indicator.parameters:addDouble("small_long_cci_cross", "small_long_cci_cross", "", 30);
    indicator.parameters:addDouble("small_short_cci_cross", "small_short_cci_cross", "", -30);
    indicator.parameters:addDouble("large_long_cci_cross", "large_long_cci_cross", "", 25);
    indicator.parameters:addDouble("large_short_cci_cross", "large_short_cci_cross", "", -25);
     
    indicator.parameters:addInteger("sto_K", "sto_K", "", 5);   
    indicator.parameters:addInteger("sto_D", "sto_D", "", 3);
    indicator.parameters:addInteger("sto_S", "sto_S", "", 3);   
    indicator.parameters:addInteger("adx_period", "adx_period", "", 20);   
    indicator.parameters:addDouble("adx_level", "adx_level", "", 15);
     
    indicator.parameters:addString("chk_adx", "chk_adx", "", "false");
    indicator.parameters:addStringAlternative("chk_adx", "true", "", "true");
    indicator.parameters:addStringAlternative("chk_adx", "false", "", "false");
     
    indicator.parameters:addString("CCI_Price", "Price for CCI", "", "typical");
    indicator.parameters:addStringAlternative("CCI_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("CCI_Price", "open", "", "close");
    indicator.parameters:addStringAlternative("CCI_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("CCI_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("CCI_Price", "low", "", "typical");
    
    indicator.parameters:addInteger("ea_EMAPeriod", "ea_EMAPeriod", "", 34);   
    indicator.parameters:addDouble("ea_AngleTreshold", "ea_AngleTreshold", "", 0.2);   
    indicator.parameters:addInteger("ea_StartEMAShift", "ea_StartEMAShift", "", 6);   
    indicator.parameters:addInteger("ea_EndEMAShift", "ea_EndEMAShift", "", 0);   

    indicator.parameters:addString("display_ema_angle", "display_ema_angle", "", "false");
    indicator.parameters:addStringAlternative("display_ema_angle", "true", "", "true");
    indicator.parameters:addStringAlternative("display_ema_angle", "false", "", "false");
    
    indicator.parameters:addInteger("EMAPeriod", "EMAPeriod", "", 34);   
    indicator.parameters:addInteger("StartEMAShift", "StartEMAShift", "", 6);   
    indicator.parameters:addInteger("EndEMAShift", "EndEMAShift", "", 0);   
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Long", "Color of Long", "Color of Long", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("Short", "Color of Short", "Color of Short", core.rgb(255, 0, 0)); 
    indicator.parameters:addColor("Exit", "Color of Exit", "Color of Exit", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128)); 
end

local first;
local source = nil;
local UpBuffer;
local DownBuffer;
local ZeroBuffer;
local EMB5;
local EMB6;
local EMB7;

local AngleTreshold;
local RSI_Period;
local RSI_Price;
local chk_rsi;
local check_ema_angle;
local display_fxprime_short;
local display_fxprime_long;
local display_fxprime_exit;
local indicator_period;
local previous_shift;
local cci_period;
local long_period;
local short_rsi;
local long_rsi;
local filter_out_cci;   
local filter_out_long;   
local filter_out_short;
local exit_cci_cross_long;
local exit_cci_cross_short;
local long_rsi_cross;
local short_rsi_cross;
local small_long_cci_cross;
local small_short_cci_cross;
local large_long_cci_cross;
local large_short_cci_cross;
local sto_K;   
local sto_D;
local sto_S;   
local adx_period;   
local adx_level;
local chk_adx;
local CCI_Price;
local ea_EMAPeriod;   
local ea_AngleTreshold;   
local ea_StartEMAShift;   
local ea_EndEMAShift;   
local display_ema_angle;
local EMAPeriod;   
local StartEMAShift;   
local EndEMAShift;

local RSI1;
local RSI2;  
local CCI1;
local CCI2;
local CCI3; 
local ADX;
local DMI;
local MA;

local buffUp;
local buffDn;
local buffZero;
 
local Neutral, Long, Short, Exit;
local open,close;

function Prepare(nameOnly)
    source = instance.source;
    AngleTreshold=instance.parameters.AngleTreshold;
    RSI_Period=instance.parameters.RSI_Period;
    RSI_Price=instance.parameters.RSI_Price;
    chk_rsi=instance.parameters.chk_rsi;
    check_ema_angle=instance.parameters.check_ema_angle;
    display_fxprime_short=instance.parameters.display_fxprime_short;
    display_fxprime_long=instance.parameters.display_fxprime_long;
    display_fxprime_exit=instance.parameters.display_fxprime_exit;
    indicator_period=instance.parameters.indicator_period;
    previous_shift=instance.parameters.previous_shift;
    cci_period=instance.parameters.cci_period;
    long_period=instance.parameters.long_period;
    short_rsi=instance.parameters.short_rsi;
    long_rsi=instance.parameters.long_rsi;
    filter_out_cci=instance.parameters.filter_out_cci;   
    filter_out_long=instance.parameters.filter_out_long;   
    filter_out_short=instance.parameters.filter_out_short;
    exit_cci_cross_long=instance.parameters.exit_cci_cross_long;
    exit_cci_cross_short=instance.parameters.exit_cci_cross_short;
    long_rsi_cross=instance.parameters.long_rsi_cross;
    short_rsi_cross=instance.parameters.short_rsi_cross;
    small_long_cci_cross=instance.parameters.small_long_cci_cross;
    small_short_cci_cross=instance.parameters.small_short_cci_cross;
    large_long_cci_cross=instance.parameters.large_long_cci_cross;
    large_short_cci_cross=instance.parameters.large_short_cci_cross;
    sto_K=instance.parameters.sto_K;   
    sto_D=instance.parameters.sto_D;
    sto_S=instance.parameters.sto_S;
    adx_period=instance.parameters.adx_period;
    adx_level=instance.parameters.adx_level;
    chk_adx=instance.parameters.chk_adx;
    CCI_Price=instance.parameters.CCI_Price;
    ea_EMAPeriod=instance.parameters.ea_EMAPeriod;
    ea_AngleTreshold=instance.parameters.ea_AngleTreshold;
    ea_StartEMAShift=instance.parameters.ea_StartEMAShift;
    ea_EndEMAShift=instance.parameters.ea_EndEMAShift;
    display_ema_angle=instance.parameters.display_ema_angle;
    EMAPeriod=instance.parameters.EMAPeriod;
    StartEMAShift=instance.parameters.StartEMAShift;
    EndEMAShift=instance.parameters.EndEMAShift;
	Long=instance.parameters.Long;
	Short=instance.parameters.Short;
	Exit=instance.parameters.Exit;
	Neutral=instance.parameters.Neutral;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    if RSI_Price=="open" then
     RSI1 = core.indicators:create("RSI", source.open, RSI_Period);
    elseif RSI_Price=="close" then
     RSI1 = core.indicators:create("RSI", source.close, RSI_Period);
    elseif RSI_Price=="high" then
     RSI1 = core.indicators:create("RSI", source.high, RSI_Period);
    elseif RSI_Price=="low" then
     RSI1 = core.indicators:create("RSI", source.low, RSI_Period);
    end
    RSI2 = core.indicators:create("RSI", source.close, long_rsi);
    
    if CCI_Price=="open" then
     CCI1 = core.indicators:create("CCI", source.open, filter_out_cci);
     CCI2 = core.indicators:create("CCI", source.open, cci_period);
     CCI3 = core.indicators:create("CCI", source.open, long_period);
    elseif CCI_Price=="close" then
     CCI1 = core.indicators:create("CCI", source.close, filter_out_cci);
     CCI2 = core.indicators:create("CCI", source.close, cci_period);
     CCI3 = core.indicators:create("CCI", source.close, long_period);
    elseif CCI_Price=="high" then
     CCI1 = core.indicators:create("CCI", source.high, filter_out_cci);
     CCI2 = core.indicators:create("CCI", source.high, cci_period);
     CCI3 = core.indicators:create("CCI", source.high, long_period);
    elseif CCI_Price=="low" then
     CCI1 = core.indicators:create("CCI", source.low, filter_out_cci);
     CCI2 = core.indicators:create("CCI", source.low, cci_period);
     CCI3 = core.indicators:create("CCI", source.low, long_period);
    elseif CCI_Price=="typical" then
     CCI1 = core.indicators:create("CCI", source, filter_out_cci);
     CCI2 = core.indicators:create("CCI", source, cci_period);
     CCI3 = core.indicators:create("CCI", source, long_period);
    end
    
    ADX = core.indicators:create("ADX", source, adx_period);
    DMI = core.indicators:create("DMI", source, adx_period);
    MA = core.indicators:create("EMA", source.median, EMAPeriod);
    
    first = math.max(
	MA.DATA:first(), DMI.DATA:first() , CCI1.DATA:first(), CCI2.DATA:first(), CCI3.DATA:first(),
	  RSI1.DATA:first(), RSI2.DATA:first())+2;
    buffUp = instance:addInternalStream(0, 0);
    buffDn = instance:addInternalStream(0, 0);
    buffZero = instance:addInternalStream(0, 0);
 	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first);    
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first); 
    close:setPrecision(math.max(2, instance.source:getPrecision()));
	instance:createChannelGroup ("ZONE", "ZONE", open, close, core.rgb(0, 0, 0), 100)
end

function Update(period, mode)
    RSI1:update(mode);
    RSI2:update(mode);
    CCI1:update(mode);
    CCI2:update(mode);
    CCI3:update(mode);
    ADX:update(mode);
    DMI:update(mode);
    MA:update(mode);
	
	close[period] = 0;
	open[period]  = 1;	
	
	
	if period  < first then
	open:setColor(period, Neutral);
	end
	
	open:setColor(period, Neutral);
    
    local ea_green=false;
    local ea_yellow=false;
    local ea_red=false;
    
    local adx_op=0;
    if DMI.DIP[period]>=DMI.DIM[period] and ADX.DATA[period]>adx_level then
     adx_op=1;
    end
    if DMI.DIP[period]<DMI.DIM[period] and ADX.DATA[period]>adx_level then
     adx_op=-1;
    end
    mFactor=10000./(StartEMAShift-EndEMAShift);
    fAngle=mFactor*(MA.DATA[period-EndEMAShift]-MA.DATA[period-StartEMAShift]);
    
    buffUp[period]=0.;
    buffDn[period]=0.;
    buffZero[period]=0.;
    
    if fAngle>AngleTreshold then
     ea_green=true;
     buffUp[period]=fAngle;
    elseif fAngle<-AngleTreshold then
     ea_yellow=true;
     buffDn[period]=fAngle;
    else
     ea_red=true;
     buffZero[period]=fAngle;  
    end
    
    if CCI2.DATA[period]>small_long_cci_cross and CCI3.DATA[period]>large_long_cci_cross and 
       (RSI1.DATA[period]>long_rsi_cross or chk_rsi=="false") and (adx_op==1 or chk_adx=="false") and ea_green then
       open:setColor(period, Long);
    end 
    if CCI2.DATA[period]<small_short_cci_cross and CCI3.DATA[period]<large_short_cci_cross and
       (RSI1.DATA[period]<short_rsi_cross or chk_rsi=="false") and (adx_op==-1 or chk_adx=="false") and ea_yellow then
       open:setColor(period, Short);
    end   
    if (CCI2.DATA[period]>=exit_cci_cross_short and CCI2.DATA[period-previous_shift]<exit_cci_cross_short) or 
       (CCI2.DATA[period]<=exit_cci_cross_long and CCI2.DATA[period-previous_shift]>exit_cci_cross_long) then
        open:setColor(period, Exit);
    end   

end

