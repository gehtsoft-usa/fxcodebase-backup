-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71914

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volume-Accelerated Directional Energy Ratio");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("vlookbk", "Lookback (for Relative)", "", 20, 1, 2000);
	indicator.parameters:addInteger("length", "Length", "", 10, 1, 2000);
	indicator.parameters:addInteger("Average", "Average", "", 5, 1, 2000);	
	indicator.parameters:addInteger("Smoothing", "Smoothing", "", 3, 1, 2000);		
	 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("color1", "Supply Energy Line Color", "", core.rgb(0, 255, 0)); 	
	 indicator.parameters:addColor("color2", "Demand Energy Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "VADER Line Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local vlookbk,length,Average,Smoothing; 
local SupplyEnergy;

	
-- Routine
 function Prepare(nameOnly)   
 
    
	vlookbk=instance.parameters.vlookbk;
	length=instance.parameters.length;
	Average=instance.parameters.Average;
	Smoothing=instance.parameters.Smoothing;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  vlookbk.. "," ..  length.. "," ..  Average.. "," ..  Smoothing  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    Volume= instance:addInternalStream(0, 0);	

	first=source:first()+vlookbk ; 

    c_plus = instance:addInternalStream(0, 0);
	c_minus = instance:addInternalStream(0, 0);
	
	WMA1= core.indicators:create("WMA", c_plus, length);
	WMA2= core.indicators:create("WMA", c_minus, length);
	WMA3= core.indicators:create("WMA", source.volume, length);		
	
    dem = instance:addInternalStream(0, 0);
	sup = instance:addInternalStream(0, 0);
	
	WMA4= core.indicators:create("WMA", dem, length);
	WMA5= core.indicators:create("WMA", sup, length);
	
	
    SupplyEnergy = instance:addStream("SupplyEnergy", core.Line, name, "Supply Energy", instance.parameters.color1,  first +length +Average );
    SupplyEnergy:setPrecision(math.max(2, instance.source:getPrecision()));
    SupplyEnergy:setWidth(instance.parameters.width);
    SupplyEnergy:setStyle(instance.parameters.style);
    SupplyEnergy:addLevel(0);	
	
	
	
    DemandEnergy = instance:addStream("DemandEnergy", core.Line, name, "Demand Energy", instance.parameters.color2,  first +length +Average );
    DemandEnergy:setPrecision(math.max(2, instance.source:getPrecision()));
    DemandEnergy:setWidth(instance.parameters.width);
    DemandEnergy:setStyle(instance.parameters.style);
    DemandEnergy:addLevel(0);		
	
	anp = instance:addInternalStream(0, 0);
	
	WMA6= core.indicators:create("WMA", anp, Smoothing);
	
	VADER = instance:addStream("VADER", core.Line, name, "VADER", instance.parameters.color3,  first +length +Average +Smoothing );
    VADER:setPrecision(math.max(2, instance.source:getPrecision()));
    VADER:setWidth(instance.parameters.width);
    VADER:setStyle(instance.parameters.style);
    VADER:addLevel(0);

 
end


function Update(period, mode)



	 if period < first then
	 return;
	 end
	 
    Volume[period]= RelVol(period);
	
	
    local min,max=mathex.minmax(source,period-2+1, period);     	
	local R       = (max - min) / 2      
    local sr      = (source.close[period]-source.close[period-1]) / R      
    local rsr     = math.max(math.min(sr, 1), -1)   
    local c       = rsr * Volume[period]      



    c_plus[period]  = math.max(c, 0)                     
    c_minus[period] = -math.min(c, 0)
	
	
	WMA1:update(mode); 
	WMA2:update(mode); 
	WMA3:update(mode); 	
	
	 if period < first +length then
	 return;
	 end
	  
	dem[period] = WMA1.DATA[period] / WMA3.DATA[period]; 
    sup[period] = WMA2.DATA[period] / WMA3.DATA[period]; 

 	 if period < first +length +Average then
	 return;
	 end
	 
	WMA4:update(mode); 
	WMA5:update(mode);	
	
	DemandEnergy[period]=WMA4.DATA[period];
	SupplyEnergy[period]=WMA5.DATA[period];	
	
    anp[period]= DemandEnergy[period] - SupplyEnergy[period];
	
	WMA6:update(mode);	
	
	if period < first +length +Average +Smoothing then
	return;
	end
	
	VADER[period]=WMA6.DATA[period];
end


function RelVol(period)

    local min,max=mathex.minmax(source.volume,period-vlookbk+1, period);     
    return (source.volume[period]- min)/(max-min);

end
--[[




// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RedKTrader

//@version=5
indicator('RedK Volume-Accelerated Directional Energy Ratio', 'RedK VADER v2.0', precision=0, timeframe='', timeframe_gaps=false)

// ***********************************************************************************************************
f_RelVol(_value, _length) =>
    min_value = ta.lowest(_value, _length)
    max_value = ta.highest(_value, _length)
    ta.stoch(_value, max_value, min_value, _length) / 100
// ***********************************************************************************************************

// ===========================================================================================================
//      Inputs
// ===========================================================================================================

price   = close
length  = input.int(10, minval=1)
DER_avg = input.int(5, 'Average',   minval=1, inline='DER', group='Directional Energy Ratio')
smooth  = input.int(3, 'Smoothing', minval=1, inline='DER', group='Directional Energy Ratio')

v_calc  = input.string('Relative', 'Calculation', options=['Relative', 'Full', 'None'], group='Volume Parameters')
vlookbk = input.int(20, 'Lookback (for Relative)', minval=1,                            group='Volume Parameters')

// ===========================================================================================================
//          Calculations
// ===========================================================================================================

// Volume Calculation Option  -- will revert to no volume acceleration for instruments with no volume data
vola    = 
  v_calc == 'None' or na(volume) ? 1 : 
  v_calc == 'Relative' ? f_RelVol(volume, vlookbk) : 
  volume

R       = (ta.highest(2) - ta.lowest(2)) / 2                    // R is the 2-bar average bar range - this method accomodates bar gaps
sr      = ta.change(price) / R                                  // calc ratio of change to R
rsr     = math.max(math.min(sr, 1), -1)                         // ensure ratio is restricted to +1/-1 in case of big moves
c       = fixnan(rsr * vola)                                    // add volume accel -- fixnan adresses cases where no price change between bars

c_plus  = math.max(c, 0)                                        // calc directional vol-accel energy
c_minus = -math.min(c, 0)

 

dem     = ta.wma(c_plus, length) / ta.wma(vola, length)         //average directional energy ratio
sup     = ta.wma(c_minus, length) / ta.wma(vola, length)

 

adp     = 100 * ta.wma(dem, DER_avg)
asp     = 100 * ta.wma(sup, DER_avg)


anp_s   = ta.wma(anp, smooth)

// ===========================================================================================================
//      Colors & plots
// ===========================================================================================================
c_adp   = color.new(color.aqua, 50)
c_asp   = color.new(color.orange, 50)
c_fd    = color.new(color.green, 80)
c_fs    = color.new(color.red, 80)
c_zero  = color.new(#ffee00, 70)
c_up    = color.new(#33ff00, 0)
c_dn    = color.new(#ff1111, 0)
up      = anp_s >= 0

hline(0, 'Zero Line', c_zero, hline.style_solid)

s = plot(asp, 'Supply Energy', c_asp, 2, style=plot.style_circles,  join=true)
d = plot(adp, 'Demand Energy', c_adp, 2, style=plot.style_cross,    join=true)
fill(d, s, adp > asp ? c_fd : c_fs)

plot(anp, 'VADER', color.new(color.gray, 30))
plot(anp_s, 'Signal', up ? c_up : c_dn, 3)

 
]]