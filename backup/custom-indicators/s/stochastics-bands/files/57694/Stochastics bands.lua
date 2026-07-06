-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33974
-- Id: 8825

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Stochastics bands");
    indicator:description("Stochastics bands");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("ShowK"  , "Show  K Line", "", true);	
    indicator.parameters:addBoolean("ShowD"  , "Show  D Line", "", true);
	indicator.parameters:addBoolean("ShowB"  , "Show  Bands", "", true);
	indicator.parameters:addBoolean("ShowTB"  , "Show  Top/Bottom Line", "", false);
	
	indicator.parameters:addGroup("Calculation");
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


    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Kcolor", "%K line color", "The color of the %K line.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Kwidth", "K Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "K Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Kstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Dcolor", "%D line color", "The color of the %D line.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Dwidth", "D Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "D Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Dstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","",80);
    indicator.parameters:addDouble("oversold","Oversold Level","",  20);
	
	indicator.parameters:addColor("OBcolor", "Overought Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("OBwidth","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("OBstyle", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("OBstyle", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("OScolor", "Oversold Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("OSwidth","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("OSstyle", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("OBstyle", core.FLAG_LEVEL_STYLE);

 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShowK, ShowD, ShowB;
local overbought,oversold;
local first;
local source = nil;
-- Streams block
local K = nil;
local D = nil;
local OB = nil;
local OS = nil;
local CL=nil;
local k, d, sd, averageTypeK, averageTypeD;
local Stochastics;
local TL,BL;
-- Routine
function Prepare(nameOnly)
    ShowK = instance.parameters.ShowK;
	ShowD = instance.parameters.ShowD;
	ShowB = instance.parameters.ShowB;
	ShowTB = instance.parameters.ShowTB;
    overbought = instance.parameters.overbought; 
	oversold =instance.parameters.oversold;
    source = instance.source;
	 k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;	

    local name = profile:id() .. "(" .. source:name() .. ", " ..k.. ", " .. d.. ", " .. sd.. ", " .. averageTypeK.. ", " .. averageTypeD .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Stochastics = core.indicators:create("STOCHASTIC", source, k, d,sd, averageTypeK,averageTypeD);
        first = Stochastics.K:first();
	    if ShowK then
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.Kcolor, Stochastics.K:first() );
		K:setWidth(instance.parameters.Kwidth);
        K:setStyle(instance.parameters.Kstyle);
		else
		K = instance:addInternalStream(0, 0);
		end
		
	   
         if ShowD then
        D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.Dcolor,Stochastics.D:first());
		D:setWidth(instance.parameters.Dwidth);
		D:setStyle(instance.parameters.Dstyle);
		else
		D = instance:addInternalStream(0, 0);
		end
		
		 if ShowB then
        OB = instance:addStream("OB", core.Line, name .. ".OB", "OB", instance.parameters.OBcolor, Stochastics.K:first());
		OB:setWidth(instance.parameters.OBwidth);
		OB:setStyle(instance.parameters.OBstyle);
		
		CL = instance:addStream("CL", core.Line, name .. ".CL", "CL", instance.parameters.OBcolor, Stochastics.K:first());
		CL:setWidth(instance.parameters.OBwidth);
		CL:setStyle(instance.parameters.OBstyle);
		
		
        OS = instance:addStream("OS", core.Line, name .. ".OS", "OS", instance.parameters.OScolor, Stochastics.K:first());
		OS:setWidth(instance.parameters.OSwidth);
		OS:setStyle(instance.parameters.OSstyle); 
		else
		
		
		OB = instance:addInternalStream(0, 0);
		OS = instance:addInternalStream(0, 0);
		CL = instance:addInternalStream(0, 0);
		
		
		end
		
		if ShowTB then
		TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.OBcolor, Stochastics.K:first());
		TL:setWidth(instance.parameters.OBwidth);
		TL:setStyle(instance.parameters.OBstyle);
		
		
        BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.OScolor, Stochastics.K:first());
		BL:setWidth(instance.parameters.OSwidth);
		BL:setStyle(instance.parameters.OSstyle);
		else
		TL = instance:addInternalStream(0, 0);
		BL = instance:addInternalStream(0, 0);
		end
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period , mode)

	 Stochastics:update(mode);
	 
      if period < first  then
	  return;
	  end
	  
	  local min,max;
	 min,max= mathex.minmax(source, period-k+1, period)
	  
	 K[period] = Stochastics.K[period]*(max-min)/100+min;	
	 D[period] =  Stochastics.D[period]*(max-min)/100+min;	
     OB[period] =  overbought*(max-min)/100+min;
     OS[period] =  oversold*(max-min)/100+min;
	 
	 TL[period] =  0*(max-min)/100+min;
     BL[period] =  100*(max-min)/100+min;
	 
	 CL[period]=  50*(max-min)/100+min;
     
end

