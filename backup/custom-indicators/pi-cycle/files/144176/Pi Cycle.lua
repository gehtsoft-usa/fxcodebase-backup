-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71623

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
    indicator:name("Pi Cycle");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Selector"); 
    indicator.parameters:addBoolean("is_show_lowma1", "Show Bottom Line", "", true);
    indicator.parameters:addBoolean("is_show_hima1", "Show Top Line", "", true);
    indicator.parameters:addBoolean("is_show_hima2", "Show Long SMA", "", true);
	indicator.parameters:addBoolean("is_show_lowma2", "Show Short EMA", "", true);



	indicator.parameters:addGroup("Calculation"); 	
    indicator.parameters:addInteger("lowma_long", "Bottom SMA Period ", "", 471, 1, 2000);
	indicator.parameters:addInteger("hima_long", "Top SMA Period", "", 350, 1, 2000);
	indicator.parameters:addInteger("hima_short", "Long SMA Period", "", 111, 1, 2000);
	indicator.parameters:addInteger("lowema_short", "Short EMA Period", "", 150, 1, 2000);
	
	indicator.parameters:addDouble("M1", "Bottom Line Multiplier", "", 0.75 );
	indicator.parameters:addDouble("M3", "Top Line Multiplier", "", 1.25);
	indicator.parameters:addDouble("M4", "Long Line Multiplier", "", 1 );
    indicator.parameters:addDouble("M2", "Short Line Multiplier", "", 1 );	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Bottom Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color3", "Top Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("color2", "Short Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color4", "Long Line Color", "", core.rgb(128, 128, 128));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local is_show_lowma1, is_show_lowma2, is_show_hima1, is_show_hima2  ; 
local lowma_long, lowema_short, hima_long,hima_short;
local first;
local source = nil;
local MA1, MA2, MA3,MA4; 
local ma_long_low, ema_short_low, ma_long_hi,ma_short_hi;
local M1, M2, M3, M4; 
-- Routine
 function Prepare(nameOnly)   
 
 
    is_show_lowma1= instance.parameters.is_show_lowma1;
	is_show_lowma2= instance.parameters.is_show_lowma2;
	is_show_hima1= instance.parameters.is_show_hima1;
	is_show_hima2= instance.parameters.is_show_hima2;
	
	 M1= instance.parameters.M1;
	 M2= instance.parameters.M2;
	 M3= instance.parameters.M3;
	 M4= instance.parameters.M4;
	
	lowma_long= instance.parameters.lowma_long;
	lowema_short= instance.parameters.lowema_short;
	hima_long= instance.parameters.hima_long;
	hima_short= instance.parameters.hima_short;
 


	
	
	local Parameters= ""
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;


    ma_long_low= core.indicators:create("MVA", source, lowma_long);
	ema_short_low= core.indicators:create("EMA", source, lowema_short);
	ma_long_hi= core.indicators:create("MVA", source, hima_long);
	ma_short_hi= core.indicators:create("MVA", source, hima_short);

	
    first=math.max(ma_long_low.DATA:first() ,ma_long_hi.DATA:first() , ema_short_low.DATA:first(), ma_short_hi.DATA:first());
	
 
   
    if is_show_lowma1 then
	MA1 = instance:addStream("MA1" , core.Line, " MA1"," MA1",instance.parameters.color1, first );
	MA1:setWidth(instance.parameters.width);
    MA1:setStyle(instance.parameters.style);
    MA1:setPrecision(math.max(2, source:getPrecision()));
	else
	MA1=instance:addInternalStream(0, 0);
	end
	
    if is_show_lowma2 then	
	MA2 = instance:addStream("MA2" , core.Line, " MA2"," MA2",instance.parameters.color2, first );
	MA2:setWidth(instance.parameters.width);
    MA2:setStyle(instance.parameters.style);
    MA2:setPrecision(math.max(2, source:getPrecision()));
	else
	MA2=instance:addInternalStream(0, 0);
	end
	
    if is_show_hima1 then	
	MA3 = instance:addStream("MA3" , core.Line, " MA3"," MA3",instance.parameters.color3, first );
	MA3:setWidth(instance.parameters.width);
    MA3:setStyle(instance.parameters.style);
    MA3:setPrecision(math.max(2, source:getPrecision()));
	else
	MA3=instance:addInternalStream(0, 0);
	end
	
    if is_show_hima2 then	
	MA4 = instance:addStream("MA4" , core.Line, " MA4"," MA4",instance.parameters.color4, first );
	MA4:setWidth(instance.parameters.width);
    MA4:setStyle(instance.parameters.style);
    MA4:setPrecision(math.max(2, source:getPrecision()));	
	else
	MA4=instance:addInternalStream(0, 0);
	end	
end

-- Indicator calculation routine
function Update(period, mode)

    ma_long_low:update(mode);
	ema_short_low:update(mode);
	ma_long_hi:update(mode);
	ma_short_hi:update(mode);
	
	if period < first
	then
	return;
	end 
	
   MA1[period]= ma_long_low.DATA[period]*M1;
   MA2[period]= ema_short_low.DATA[period]*M2;
   MA3[period]= ma_long_hi.DATA[period]*M3;
   MA4[period]= ma_short_hi.DATA[period]*M4; 
end


--[[

 
//@version=4
study("Pi Cycle Bitcoin High/Low", shorttitle="Pi Cycle Bitcoin High/Low", overlay=true)

//Create Inputs for the 4 MAs, and Visual 

lowma_long = input(471, minval=1, title="BTC Low - Long SMA")
is_show_lowma1 = input(true, type=input.bool, title="Show Low Long SMA?")

lowema_short = input(150, minval=1, title="BTC Low - Short EMA")
is_show_lowma2 = input(true, type=input.bool, title="Show Low Short EMA?")

hima_long = input(350, minval=1, title="BTC High - Long SMA")
is_show_hima1 = input(true, type=input.bool, title="Show High Long SMA?")

hima_short = input(111, minval=1, title="BTC High - Short SMA")
is_show_hima2 = input(true, type=input.bool, title="Show High Short SMA?")

//Set resolution to the Daily Chart
resolution = input('D', type=input.string, title="Time interval")

//Run the math for the 4 MAs
ma_long_low = security(syminfo.tickerid, resolution, sma(close, lowma_long)*745)/1000
ema_short_low = security(syminfo.tickerid, resolution, ema(close, lowema_short))
ma_long_hi = security(syminfo.tickerid, resolution, sma(close, hima_long)*2)
ma_short_hi = security(syminfo.tickerid, resolution, sma(close, hima_short))

//Set SRC
src = security(syminfo.tickerid, resolution, close)

//Plot the 4 MAs
plot(is_show_lowma1?ma_long_low:na, color=color.red, linewidth=2, title="Low Long MA")
var lowma_long_label = label.new(x = bar_index, y = lowma_long, color = color.rgb(0, 0, 0, 100), style = label.style_label_left, textcolor = color.red, text = "BTC Low - Long SMA")
label.set_xy(lowma_long_label, x = bar_index, y = ma_long_low)

plot(is_show_lowma2?ema_short_low:na, color=color.green, linewidth=2, title="Low Short EMA")
var lowema_short_label = label.new(x = bar_index, y = lowema_short, color = color.rgb(0, 0, 0, 100), style = label.style_label_left, textcolor = color.green, text = "BTC Low - Short EMA")
label.set_xy(lowema_short_label, x = bar_index, y = ema_short_low)

plot(is_show_hima1?ma_long_hi:na, color=color.white, linewidth=2, title="High Long MA")
var hima_long_label = label.new(x = bar_index, y = hima_long, color = color.rgb(0, 0, 0, 100), style = label.style_label_left, textcolor = color.white, text = "BTC High - Long MA")
label.set_xy(hima_long_label, x = bar_index, y = ma_long_hi)

plot(is_show_hima2?ma_short_hi:na, color=color.yellow, linewidth=2, title="High Short MA")
var hima_short_label = label.new(x = bar_index, y = hima_short, color = color.rgb(0, 0, 0, 100), style = label.style_label_left, textcolor = color.yellow, text = "BTC High - Short MA")
label.set_xy(hima_short_label, x = bar_index, y = ma_short_hi)

//Find where the MAs cross each other
PiCycleLow = crossunder(ema_short_low, ma_long_low) ? src + (src/100 * 10) : na
PiCycleHi = crossunder(ma_long_hi, ma_short_hi) ? src + (src/100 * 10) : na

//Create Labels
plotshape(PiCycleLow, text="Pi Cycle Low", color=color.navy, textcolor=color.white, style=shape.labelup,size=size.normal, location=location.belowbar, title="Cycle Low")
plotshape(PiCycleHi, text="Pi Cycle High", color=color.teal, textcolor=color.white, style=shape.labeldown,size=size.normal, location=location.abovebar, title="Cycle High")

//Generate vertical lines at the BTC Halving Dates
isDate(y, m, d) =>
    val = timestamp(y,m,d)
    if val <= time and val > time[1]
        true
    else 
        false

// First Halving
if isDate(2012, 11, 28)
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, style=line.style_dashed, color=color.yellow)
    label.new(bar_index, low, text="1st Halving - Nov 28, 2012", style=label.style_label_upper_left, textcolor=color.yellow, color=color.black, textalign=text.align_right, yloc=yloc.belowbar)
    
// Second Halving
if isDate(2016, 7, 9)
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, style=line.style_dashed, color=color.yellow)
    label.new(bar_index, low, text="2nd Halving - Jul 9, 2016", style=label.style_label_upper_left, textcolor=color.yellow, color=color.black, textalign=text.align_right, yloc=yloc.belowbar)
    
// Third Halving
if isDate(2020, 5, 11)
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, style=line.style_dashed, color=color.yellow)
    label.new(bar_index, low, text="3rd Halving - May 11, 2020", style=label.style_label_upper_left, textcolor=color.yellow, color=color.black, textalign=text.align_right, yloc=yloc.belowbar)    
         
// Fourth Halving
//if isDate(2024, 3, 26)
//    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend.both, style=line.style_dashed, color=color.yellow)
//    label.new(bar_index, low, text="4th Halving - March 26, 2024", style=label.style_label_upper_left, textcolor=color.yellow, color=color.black, textalign=text.align_right, yloc=yloc.belowbar)    
 


]]

 