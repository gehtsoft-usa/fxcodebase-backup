-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68191

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("BB stops stochastic");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	 
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addDouble("Risk", "Risk", "", 1);
	
	indicator.parameters:addGroup("BB Calculation");
	indicator.parameters:addInteger("BP", "Period","", 20, 1, 1000);
	indicator.parameters:addDouble("BD", "Deviation","", 2, 1, 1000);
	indicator.parameters:addGroup("Stochastic Calculation");
	 indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");    
     indicator.parameters:addStringAlternative("MVAT_K", "FS", "FS", "FS");   
    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
	
	indicator.parameters:addGroup("Stochastic Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color1", "Neutral Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addColor("colorA", "Down Line Color", "", core.rgb(255, 0,0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color2", "Neutral Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addColor("colorB", "Up Line Color", "", core.rgb(0, 255,0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Stochastic; 
local first;
local source = nil;
local bb,BP, BD; 
local Risk;
local Signal;
local amax, amin,bmax, bmin;
-- Routine
 function Prepare(nameOnly)    
 
    Risk = instance.parameters.Risk; 
	BP = instance.parameters.BP;
	BD = instance.parameters.BD;
	
	local Parameters= Risk;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    
	
	Signal= instance:addInternalStream(0, 0);
    
	amax= instance:addInternalStream(0, 0);
	amin= instance:addInternalStream(0, 0);
	 
	
    source = instance.source;
    
  
    stochastic = core.indicators:create("STOCHASTIC", source ,  instance.parameters.K, instance.parameters.SD,instance.parameters.D, instance.parameters.MVAT_K,instance.parameters.MVAT_D);
    bb = core.indicators:create("BB", stochastic.K, BP, BD);
    
    first=math.max(bb.DATA:first());
	
	 
    Stochastic = instance:addStream("Stochastic" , core.Line, " Stochastic"," Stochastic",instance.parameters.color, first);
	Stochastic:setWidth(instance.parameters.width);
    Stochastic:setStyle(instance.parameters.style);
    Stochastic:setPrecision(math.max(2, source:getPrecision()));
 
	bmax = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first);
	bmax:setWidth(instance.parameters.width1);
    bmax:setStyle(instance.parameters.style1);
    bmax:setPrecision(math.max(2, source:getPrecision()));
	
	bmin = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first);
	bmin:setWidth(instance.parameters.width2);
    bmin:setStyle(instance.parameters.style2);
    bmin:setPrecision(math.max(2, source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    stochastic:update(mode);
	bb:update(mode);
	
    if period < first then
	return;
	end
	
	Stochastic[period]=stochastic.K[period];
	
	
	
		
    amax[period]  = bb.TL[period];
	amin[period]  = bb.BL[period];
	bmax[period]  = amax[period]+0.5*(Risk-1)*(amax[period]-amin[period])
	bmin[period]  = amin[period]-0.5*(Risk-1)*(amax[period]-amin[period])
 
		if Stochastic[period]>amax[period-1] then
		 trend=1
		elseif Stochastic[period]<amin[period-1] then
		 trend=-1
		end
		 
		if trend==-1 and amax[period]>amax[period-1] then
		 amax[period]=amax[period-1]
		elseif trend == 1 and amin[period]<amin[period-1] then
		 amin[period]=amin[period-1]
		elseif trend==-1 and bmax[period]>bmax[period-1] then
		 bmax[period]=bmax[period-1]
		elseif  trend==1 and bmin[period]<bmin[period-1] then
		 bmin[period]=bmin[period-1]
		end
 
 
        if Stochastic[period]>amax[period]
        and	Stochastic[period-1]<=amax[period-1]
        then
  		Signal[period]=1;
		elseif Stochastic[period]<amin[period]
        and	Stochastic[period-1]>=amin[period-1]
        then
  		Signal[period]=-1;
		else		
		Signal[period]=Signal[period-1];
		end
		
		
		if Signal[period]==1 then
		bmax:setColor(period, instance.parameters.color1);
	    bmin:setColor(period, instance.parameters.colorB);
		
		elseif Signal[period]==-1 then
		bmax:setColor(period, instance.parameters.colorA);
	    bmin:setColor(period, instance.parameters.color2);
		
		else
		bmax:setColor(period, instance.parameters.color1);
	    bmin:setColor(period, instance.parameters.color2);
		end
		
end


