-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71622

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine

function Init()
    indicator:name("Compound Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 12, 1, 2000);
    indicator.parameters:addDouble("Multiplicator", "Multiplicator", "", 2, 1, 2000);
    indicator.parameters:addDouble("load_ftr", "Load Balance", "", 0);	
    indicator.parameters:addBoolean("Log", "Allow Log Scale", "", false);	
    indicator.parameters:addBoolean("opt_vwma", "Allow Volume Weighted Moving Average", "", false);		
	 
  
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Multiplicator,Log,load_ftr,opt_vwma; 
local first;
local source = nil;
 
local Line;

local len_ma_01, len_ma_02, len_ma_03;
local MA1, MA2, MA3;
local WMA1, WMA2, WMA3;
local Volume1, Volume2, Volume3;
local WMAVolume1, WMAVolume2, WMAVolume3;
local Source;
local sig_ema;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Multiplicator= instance.parameters.Multiplicator;
	Log= instance.parameters.Log;
	load_ftr= instance.parameters.load_ftr;
	opt_vwma= instance.parameters.opt_vwma;
	
	
	local Parameters= Period..", "..Multiplicator;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    len_ma_01= Period;
	len_ma_02 = (len_ma_01 * Multiplicator);
    len_ma_03 = (len_ma_02 * Multiplicator);

	
    source = instance.source; 
    first=source:first() ;
	
    Source= instance:addInternalStream(0, 0);
	sig_ema= instance:addInternalStream(0, 0);
	
	MA1 = core.indicators:create("EMA", Source, len_ma_01);
	MA2 = core.indicators:create("EMA", Source, len_ma_02);
	MA3 = core.indicators:create("EMA", Source, len_ma_03);	
	
	WMA1 = core.indicators:create("LWMA", Source, len_ma_01);
	WMA2 = core.indicators:create("LWMA", Source, len_ma_02);
	WMA3 = core.indicators:create("LWMA", Source, len_ma_03);
 
 	Volume1 = core.indicators:create("EMA", source.volume, len_ma_01);
	Volume2 = core.indicators:create("EMA", source.volume, len_ma_02);
	Volume3 = core.indicators:create("EMA", source.volume, len_ma_03);
	
	WMAVolume1 = core.indicators:create("LWMA", source.volume, len_ma_01);
	WMAVolume2 = core.indicators:create("LWMA", source.volume, len_ma_02);
	WMAVolume3 = core.indicators:create("LWMA", source.volume, len_ma_03);
	
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color1, first +len_ma_03 );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end 
		
	local Price=source.close[period]
 
	
	if Log then
	Price=math.log(Price); 
	end
	
	
	Source[period]=Price;	
	
	if opt_vwma then
	Source[period]=Price*source.volume[period];	
	
	Volume1:update(mode);
	Volume2:update(mode);
	Volume3:update(mode);
	
	WMAVolume1:update(mode);
	WMAVolume2:update(mode);
	WMAVolume3:update(mode);
	
	end
	
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);

	WMA1:update(mode);
	WMA2:update(mode);
	WMA3:update(mode);	
	
	if period < first + len_ma_03
	then
	return;
	end 

    local ma1, ma2, ma3;
	
    if opt_vwma then 
	ma1=MA1.DATA[period]/Volume1.DATA[period];
	ma2=MA2.DATA[period]/Volume2.DATA[period];
	ma3=MA3.DATA[period]/Volume3.DATA[period];
    else
	ma1=MA1.DATA[period];
	ma2=MA2.DATA[period];
	ma3=MA3.DATA[period];	
    end	
		
	sig_ema[period] = ((ma1 * (4 - load_ftr)) + (ma2 * 2) + ((ma3) * (1 + load_ftr)))/ 7;
	
	
	

    if opt_vwma then 
	ma1=WMA1.DATA[period]/WMAVolume1.DATA[period];
	ma2=WMA2.DATA[period]/WMAVolume2.DATA[period];
	ma3=WMA3.DATA[period]/WMAVolume3.DATA[period];
    else
	ma1=WMA1.DATA[period];
	ma2=WMA2.DATA[period];
	ma3=WMA3.DATA[period];	
    end	
	
	
    local sig_wma = ((ma1 * (4 - load_ftr)) + (ma2 * 2) + ((ma3) * (1 + load_ftr)))/ 7;
	
	
	if period <= first + len_ma_03 +sig_wma
	then
	return;
	end 
	
	
	
	Line[period]=mathex.avg(sig_ema, period - sig_wma+1, period);
 
    if Log then
	Line[period]= math.exp(Line[period]);
	end
	
	
	if source.close[period] > Line[period] then
	Line:setColor(period, instance.parameters.color1);	
    else	
	Line:setColor(period, instance.parameters.color2);
	end
 
end


--[[

//@version=5
//############################################################################//
// This indicator is modified or developed by [DM] D.Martinez
// Original Autor = # Release Date: # Publication: # 
// Copyright      = © D.Martinez 2020 to present
// Title          = xx.1 b.01 Compound Moving Average >[DM]< 
// Release        = OCT/12/2021 : First release 
// Update         = MMM/DD/YYYY : na 
// Script may be freely distributed under the MIT license
//############################################################################//
indicator(title='Compound Moving Average [DM]', shorttitle='CMA [DM]', overlay=true, timeframe='')
//=>fn_Security from cheatcountry 
f_security(_symbol, _res, _source, _repaint) =>
    request.security(_symbol, _res, _source[_repaint ? 0 : barstate.isrealtime ? 1 : 0])[_repaint ? 0 : barstate.isrealtime ? 0 : 1]
/// Inputs ///
ctm_res_1 = input.timeframe(defval=''                                           , title="Custom Resolution                     ",group="Source Settings ")//,tooltip, confirm=false)
opt_rep_1 = input.bool     (defval=true                                         , title="Allow Repainting?                     ",group="Source Settings ")//,tooltip, confirm=false)
opt_log_1 = input.bool     (defval=false                                        , title="Allow Log Scale?                      ",group="Source Settings ")//,tooltip, confirm=false)
opt_vwma  = input.bool     (defval=false                                        , title="Allow Volume Weighted Moving Average? ",group="Source Settings ")//,tooltip, confirm=false)
len_ma_01 = input.int      (defval=00012, minval=00001, maxval=01594, step=00001, title="Master Length                         ",group="Length Settings ")//,tooltip, confirm=false)
load_ftr  = input.float    (defval=00000, minval=00000, maxval=00003, step=00.01, title="Load Balance                          ",group="Length Settings ")//,tooltip, confirm=false)
actv_alrt = input.bool     (defval=false                                        , title="Allow Alerts?                         ",group="Alerts Settings ")//,tooltip, confirm=false)
opt_bar_1 = input.bool     (defval=true                                         , title="Allow Bar Color Change                ",group="Visual Options  ")//,tooltip, confirm=false)
linewidth = input.int      (defval=00003, minval=00001, maxval=00010, step=00001, title="Linewidth Moving Average              ",group="Visual Options  ")//,tooltip, confirm=false)
//=>Auto Inputs
len_ma_02 = (len_ma_01 * 2)
len_ma_03 = (len_ma_02 * 2)
/// Source ///
src_cls = opt_log_1 ? f_security(syminfo.tickerid, ctm_res_1, math.log(close), opt_rep_1) : f_security(syminfo.tickerid, ctm_res_1, close , opt_rep_1)
src_tpc = opt_log_1 ? f_security(syminfo.tickerid, ctm_res_1, math.log(ohlc4), opt_rep_1) : f_security(syminfo.tickerid, ctm_res_1, ohlc4 , opt_rep_1)
src_vol =                                                                                   f_security(syminfo.tickerid, ctm_res_1, volume, opt_rep_1)
/// Brain ///
ma21 = opt_vwma ? ta.ema((src_vol*src_cls), len_ma_01) / ta.ema(src_vol, len_ma_01) : ta.ema(src_cls, len_ma_01)
ma22 = opt_vwma ? ta.ema((src_vol*src_cls), len_ma_02) / ta.ema(src_vol, len_ma_02) : ta.ema(src_cls, len_ma_02)
ma23 = opt_vwma ? ta.ema((src_vol*src_cls), len_ma_03) / ta.ema(src_vol, len_ma_03) : ta.ema(src_cls, len_ma_03)
sig_ema = ((ma21 * (4 - load_ftr)) + (ma22 * 2) + ((ma23) * (1 + load_ftr)))/ 7
ma31 = opt_vwma ? ta.wma((src_vol*src_cls), len_ma_01) / ta.wma(src_vol, len_ma_01) : ta.wma(src_cls, len_ma_01)
ma32 = opt_vwma ? ta.wma((src_vol*src_cls), len_ma_02) / ta.wma(src_vol, len_ma_02) : ta.wma(src_cls, len_ma_02)
ma33 = opt_vwma ? ta.wma((src_vol*src_cls), len_ma_03) / ta.wma(src_vol, len_ma_03) : ta.wma(src_cls, len_ma_03)
sig_wma = ((ma31 * (4 - load_ftr)) + (ma32 * 2) + ((ma33) * (1 + load_ftr)))/ 7
/// OutPut ///
sig_mavg = math.avg(sig_ema, sig_wma)
/// Color ///
col_ma_bull = input.color(color.new(color.blue  , 000), title="Color Bull Moving Average ", group="MA Color  ", confirm=false)
col_ma_bear = input.color(color.new(color.purple, 000), title="Color Bear Moving Average ", group="MA Color  ", confirm=false)
col_bar_01  = input.color(color.new(color.green , 000), title="Color Bull Bar            ", group="Bar Color ", confirm=false)
col_bar_02  = input.color(color.new(color.red   , 000), title="Color Bear Bar            ", group="Bar Color ", confirm=false)
//=>Color condition
cond_col_ma  = src_tpc > sig_mavg ? col_ma_bull : src_tpc < sig_mavg ? col_ma_bear : na
cond_col_bar = src_tpc > sig_mavg and sig_mavg > sig_mavg[1] ? col_bar_01  : src_tpc < sig_mavg and sig_mavg < sig_mavg[1]? col_bar_02  : color.new(color.gray,000)
/// Plot ///
plot(series= opt_log_1 ? math.exp(sig_mavg) : sig_mavg, title='Moving Average Compound', color=cond_col_ma, linewidth=linewidth, style=plot.style_line, editable=false, display=display.all)
/// Bar Color ///
barcolor(opt_bar_1 ? cond_col_bar : na, editable=false, title="Bar Color")
/// Alerts ///
alertcondition(actv_alrt ? ta.crossover (src_tpc, sig_mavg) : na, "Buy Signal  ", "Bullish Change Detected")
alertcondition(actv_alrt ? ta.crossunder(src_tpc, sig_mavg) : na, "Sell Signal ", "Bearish Change Detected")


]]


  