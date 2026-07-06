-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71687

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

--Support that the service we provide to the community be continued onward.
--+------------------------------------------------------------------------------------------------+
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Arnaud Legoux Moving Average Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
	
	indicator.parameters:addGroup("Calculation"); 
	
 
    indicator.parameters:addInteger("windowsize", "windowsize", "", 100);	
    indicator.parameters:addDouble("offset", "offset", "", 0.85);
    indicator.parameters:addDouble("sigma", "sigma", "", 6);

    indicator.parameters:addInteger("ATRlength", "ATRlength", "", 100);
    indicator.parameters:addInteger("ATRMult1", "1. ATR Multplier", "", 2);
	indicator.parameters:addInteger("ATRMult2", "2. ATR Multplier", "", 4);
	indicator.parameters:addInteger("ATRMult3", "3. ATR Multplier", "", 6);
	
	
	indicator.parameters:addGroup("Cental Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("1. Top Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);

	indicator.parameters:addGroup("2. Top Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);


	indicator.parameters:addGroup("3. Top Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);	
	
	indicator.parameters:addGroup("1. Bottom Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);	
	
	indicator.parameters:addGroup("2. Bottom Line Style"); 	
    indicator.parameters:addColor("color5", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style5", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width5", "Line Width", "", 3, 1, 5);	

	indicator.parameters:addGroup("3. Bottom Line Style"); 	
    indicator.parameters:addColor("color6", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style6", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width6", "Line Width", "", 3, 1, 5);		
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local offset, sigma, ATRlength,ATRMult1, ATRMult2, ATRMult3,windowsize; 
local first;
local source = nil;
 local ATR, ALMA;
 
-- Routine
 function Prepare(nameOnly)   
 
 
    offset= instance.parameters.offset;
    sigma= instance.parameters.sigma;
	ATRlength= instance.parameters.ATRlength;
	ATRMult1= instance.parameters.ATRMult1;
	ATRMult2= instance.parameters.ATRMult2;
	ATRMult3= instance.parameters.ATRMult3;
	windowsize= instance.parameters.windowsize;
	
	local Parameters= windowsize..", "..   offset..", "..sigma..", "..ATRlength ..", ".. ATRMult1..", "..ATRMult2..", "..ATRMult3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("ALMA") ~= nil, "Please, download and install ALMA.LUA indicator");    
			
    source = instance.source;
	
	ATR = core.indicators:create("ATR", source, ATRlength);
	ALMA = core.indicators:create("ALMA", source.close, windowsize, sigma, offset);
	first=math.max(ATR.DATA:first(), ALMA.DATA:first()) ;
	
	-- Average= instance:addInternalStream(0, 0);
   
 
	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.color, first );
	Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
    Central:setPrecision(math.max(2, source:getPrecision())); 
	
	Top1 = instance:addStream("Top1" , core.Line, " Top1"," Top1",instance.parameters.color1, first );
	Top1:setWidth(instance.parameters.width1);
    Top1:setStyle(instance.parameters.style1);
    Top1:setPrecision(math.max(2, source:getPrecision()));

	Top2 = instance:addStream("Top2" , core.Line, " Top2"," Top2",instance.parameters.color2, first );
	Top2:setWidth(instance.parameters.width2);
    Top2:setStyle(instance.parameters.style2);
    Top2:setPrecision(math.max(2, source:getPrecision()));


	Top3 = instance:addStream("Top3" , core.Line, " Top3"," Top3",instance.parameters.color3, first );
	Top3:setWidth(instance.parameters.width3);
    Top3:setStyle(instance.parameters.style3);
    Top3:setPrecision(math.max(2, source:getPrecision()));


	Bottom1 = instance:addStream("Bottom1" , core.Line, " Bottom1"," Bottom1",instance.parameters.color4, first );
	Bottom1:setWidth(instance.parameters.width4);
    Bottom1:setStyle(instance.parameters.style4);
    Bottom1:setPrecision(math.max(2, source:getPrecision()));

	Bottom2 = instance:addStream("Bottom2" , core.Line, " Bottom2"," Bottom2",instance.parameters.color5, first );
	Bottom2:setWidth(instance.parameters.width5);
    Bottom2:setStyle(instance.parameters.style5);
    Bottom2:setPrecision(math.max(2, source:getPrecision()));

	Bottom3 = instance:addStream("Bottom3" , core.Line, " Bottom3"," Bottom3",instance.parameters.color6, first );
	Bottom3:setWidth(instance.parameters.width6);
    Bottom3:setStyle(instance.parameters.style6);
    Bottom3:setPrecision(math.max(2, source:getPrecision()));	
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    ATR:update(mode);
    ALMA:update(mode);	
	
	if period <  first 
	then
	return;
	end
 
    Central[period]= ALMA.DATA[period];
    Top1[period]= ALMA.DATA[period]+ATR.DATA[period]*ATRMult1;
    Top2[period]= ALMA.DATA[period]+ATR.DATA[period]*ATRMult2;
    Top3[period]= ALMA.DATA[period]+ATR.DATA[period]*ATRMult3;
    Bottom1[period]= ALMA.DATA[period]-ATR.DATA[period]*ATRMult1;
    Bottom2[period]= ALMA.DATA[period]-ATR.DATA[period]*ATRMult2;
    Bottom3[period]= ALMA.DATA[period]-ATR.DATA[period]*ATRMult3;	
end


--[[

 plot(almamed,linewidth=2,color=purple)
 
plot(emaup, title="EMAUP", color=red)
plot(emadw, title="EMADW", color=green)
plot(emahigh, title="EMAHigh", color=red)
plot(emalow, title="EMALow", color=green)
plot(emahighx, title="StopLossShort", color=silver)
plot(emalowx, title="StopLossLong", color=silver)
 
 

]]
