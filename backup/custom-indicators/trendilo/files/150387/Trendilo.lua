-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73591

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trendilo");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("smooth", "Smoothing", "", 1, 1, 2000);
    indicator.parameters:addInteger("length", "Lookback", "", 50, 1, 2000);
    indicator.parameters:addDouble("offset", "ALMA Offset", "", 0.85, 0, 2000);	  

    indicator.parameters:addInteger("sigma", "ALMA Sigma", "", 6, 0, 2000);	
	indicator.parameters:addDouble("bmult", "Band Multiplier", "", 1, 1, 2000);	

	indicator.parameters:addBoolean("cblen", "Custom Band Length ? (Else same as Lookback)", "", false);	
	indicator.parameters:addInteger("blen", "Custom Band Length", "", 20, 1, 2000);

	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(128, 128, 128)); 

	 indicator.parameters:addGroup("Cloud Style");	
	indicator.parameters:addBoolean("Cloud", "Cloud", "", true);	 
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	  
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);		
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 	
-- Routine
 function Prepare(nameOnly)   
 
    
	smooth=instance.parameters.smooth;
	length=instance.parameters.length;
	offset=instance.parameters.offset;	
	sigma=instance.parameters.sigma;
	bmult=instance.parameters.bmult;
	cblen=instance.parameters.cblen;
	blen=instance.parameters.blen;
	
   Up = instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral; 
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;	
   Cloud= instance.parameters.Cloud;

	if cblen then
	blength = blen 
	else
	blength = length
	end
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. ","   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("ALMA") ~= nil, "Please, download and install ALMA.LUA indicator");


	first=source:first()+smooth ; 
	
	
	pch = instance:addInternalStream(0, 0);
	avpchavpch = instance:addInternalStream(0, 0);
    Central=instance:addInternalStream(0, 0); 	
	ALMA= core.indicators:create("ALMA", pch, length, sigma, offset); 
	
	

 
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, ALMA.DATA:first()+blength );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
   --Top:addLevel(0);	

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, ALMA.DATA:first()+blength );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
 	
	
    Line = instance:addStream("Line", core.Line, name, "Line", Up, ALMA.DATA:first()+blength );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
 
	if Cloud then
	instance:createChannelGroup("Group","Group" , Line, Central, Neutral, Transparency);	
    end
	
end


function Update(period, mode)

 
    Central[period]=0;
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	pch[period] =(source[period]-source[period-smooth])/source[period] * 100;  

	
	ALMA:update(mode); 
	if period <= ALMA.DATA:first() 
	then
	return;
	end
	
	
	Line[period]=ALMA.DATA[period]
    avpchavpch[period]=Line[period]*Line[period];	
	
	if period <= ALMA.DATA:first()+blength
	then
	return;
	end	

	Top[period] = bmult*math.sqrt(mathex.avg(avpchavpch, period-blength+1, period))
	Bottom[period] = -Top[period];
	
 
	if Line[period] > Top[period]  then 
	Line:setColor(period, Up);
	elseif Line[period] < Bottom[period]  then
	Line:setColor(period, Down);	
	else
	Line:setColor(period, Neutral);
	end	
end
 
--[[
rc=input(close, title="Source")
smooth = input(1, title="Smoothing", minval=1)
length = input(50, title="Lookback", minval=1)
offset = input(0.85, title= "ALMA Offset", step=0.01)
sigma = input(6, title= "ALMA Sigma", minval=0)

bmult = input(1.0, "Band Multiplier")
cblen = input(false, "Custom Band Length ? (Else same as Lookback)")
blen = input(20, "Custom Band Length")

highlight=input(true)
fill=input(true)
barcol=input(false, "Bar Color")

pch = change(src, smooth)/src * 100
avpch = alma(pch, length, offset, sigma)

blength = cblen ? blen : length
rms = bmult*sqrt(sum(avpch*avpch, blength)/blength)

cdir = avpch>rms ? 1 : avpch<-rms ? -1 : 0
col = cdir==1 ? color.lime : cdir==-1 ? color.red : color.gray


fplot = plot(avpch, color=highlight?col:color.blue, linewidth=2)
 
]]

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


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