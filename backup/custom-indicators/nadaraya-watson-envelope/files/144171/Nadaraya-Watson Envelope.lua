-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71621

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
    indicator:name("Nadaraya-Watson Envelope");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length", "length", "", 50, 1, 2000);
    indicator.parameters:addDouble("h", "Bandwidth", "", 8, 1, 2000);
    indicator.parameters:addDouble("mult", "Multiplier", "", 3, 0, 2000);
     indicator.parameters:addInteger("k", "K", "", 2, 1, 2000);
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0));	
    indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end


 


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
local sum_e; 
local length, h, mult,k;
-- Routine
 function Prepare(nameOnly)   
 
 
    length= instance.parameters.length;
    h= instance.parameters.h;
	mult= instance.parameters.mult;
	k= instance.parameters.k;
	
	local Parameters= length..", ".. h ..", ".. mult ..", ".. k;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+length;
	
	sum_e= instance:addInternalStream(0, 0);
   
 
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first+length);
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:setPrecision(math.max(2, source:getPrecision()));

	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first+length);
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end 
	
	
 
	local  sum = 0;
    local  sumw = 0;
 
 
        
        for j= 0, length-1, 1 do
            w = math.exp(-(math.pow(j,2)/(h*h*2)))
            sum =sum + source[period-j]*w
            sumw=  sumw+w;
        end
   
    y2 = sum/sumw
    
	sum_e[period]  =  math.abs(source[period] - y2)
 
 

    Top[period] =y2 + mathex.sum(sum_e, period-length+1, period)/length*mult
    Bottom[period] =y2 - mathex.sum(sum_e, period-length+1, period)/length*mult				  
end

 --[[
 
 // This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo
//@version=5

indicator("Nadaraya-Watson Envelope [LUX]",overlay=true,max_bars_back=1000,max_lines_count=500,max_labels_count=500)
length = input.float(500,'Window Size',maxval=500,minval=0)
h      = input.float(8.,'Bandwidth')
mult   = input.float(3.) 
src    = input.source(close,'Source')

up_col = input.color(#39ff14,'Colors',inline='col')
dn_col = input.color(#ff1100,'',inline='col')
//----
n = bar_index
var k = 2
var upper = array.new_line(0) 
var lower = array.new_line(0) 

lset(l,x1,y1,x2,y2,col)=>
    line.set_xy1(l,x1,y1)
    line.set_xy2(l,x2,y2)
    line.set_color(l,col)
    line.set_width(l,2)

if barstate.isfirst
    for i = 0 to length/k-1
        array.push(upper,line.new(na,na,na,na))
        array.push(lower,line.new(na,na,na,na))
//----
line up = na
line dn = na
//----
cross_up = 0.
cross_dn = 0.
if barstate.islast
    y = array.new_float(0)
    
    sum_e = 0.
    for i = 0 to length-1
        sum = 0.
        sumw = 0.
        
        for j = 0 to length-1
            w = math.exp(-(math.pow(i-j,2)/(h*h*2)))
            sum += src[j]*w
            sumw += w
        
        y2 = sum/sumw
        sum_e += math.abs(src[i] - y2)
        array.push(y,y2)

    mae = sum_e/length*mult
    
    for i = 1 to length-1
        y2 = array.get(y,i)
        y1 = array.get(y,i-1)
        
        up := array.get(upper,i/k)
        dn := array.get(lower,i/k)
        
        lset(up,n-i+1,y1 + mae,n-i,y2 + mae,up_col)
        lset(dn,n-i+1,y1 - mae,n-i,y2 - mae,dn_col)
        
        if src[i] > y1 + mae and src[i+1] < y1 + mae
            label.new(n-i,src[i],'▼',color=#00000000,style=label.style_label_down,textcolor=dn_col,textalign=text.align_center)
        if src[i] < y1 - mae and src[i+1] > y1 - mae
            label.new(n-i,src[i],'▲',color=#00000000,style=label.style_label_up,textcolor=up_col,textalign=text.align_center)
    
    cross_up := array.get(y,0) + mae
    cross_dn := array.get(y,0) - mae

alertcondition(ta.crossover(src,cross_up),'Down','Down')
alertcondition(ta.crossunder(src,cross_dn),'Up','Up')


 ]]