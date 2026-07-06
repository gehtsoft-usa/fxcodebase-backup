
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1589

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MA Cloud with Alternatively Source");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Method One");
	indicator.parameters:addInteger("SF", "First Averege Period", "First Averege  Period", 20);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
	
	indicator.parameters:addString("Type1", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "weighted");
	indicator.parameters:addStringAlternative("Type1", "Indicator", "", "Indicator");
	
	indicator.parameters:addString("Indicator1", "1. Indicator", "", "MVA");
	indicator.parameters:setFlag("Indicator1",core.FLAG_INDICATOR);
	
	
	indicator.parameters:addGroup("Method Two");
	indicator.parameters:addInteger("LF", "Second Averege Period", "Second Averege Period", 100);
	indicator.parameters:addString("Method2", "MA Method", " " , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
	
	
	indicator.parameters:addString("Type2", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type2", "WEIGHTED", "", "weighted");
	indicator.parameters:addStringAlternative("Type2", "Indicator", "", "Indicator");
     
	indicator.parameters:addString("Indicator2", "2. Indicator", "", "MVA");
	indicator.parameters:setFlag("Indicator2",core.FLAG_INDICATOR);
	
	indicator.parameters:addGroup("Style");	
	 indicator.parameters:addBoolean("Lines", "Show MA Lines", "" , false); 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));
    indicator.parameters:addColor("UpDown", "Color of UpDown", "Color of UpDown", core.rgb(125, 255, 125));
	indicator.parameters:addColor("DownUp", "Color of DownUp", "Color of DownUp", core.rgb(255, 125, 125));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("1. MA Shift");
   indicator.parameters:addString("MethodA", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("MethodA", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("MethodA", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("MethodA", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addInteger("SXA", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addDouble("SYA", "Shift in points", "", 0);
	
	indicator.parameters:addGroup("2. MA Shift");
   indicator.parameters:addString("MethodB", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("MethodB", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("MethodB", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("MethodB", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addInteger("SXB", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addDouble("SYB", "Shift in points", "", 0);
	
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortFrame=nil;
local LongFrame=nil;
local Method1=nil;
local Method2=nil;
local Lines;
local Filter1;
local ColorBarBack1;
local Deviation1;
local Filter2;
local ColorBarBack2;
local Deviation2;

local first;
local source = nil;

-- Streams block
local LongDATA = nil;
local ShortDATA = nil;

local Transparency;
local Type1;
local Type2;
local Source1, Source2;
local Indicator1, Indicator2;

local SXA, SYA;
local MethodA;

local SXB, SYB;
local MethodB;

local first1B, first2B;
local first1A, first2A;


-- Routine
function Prepare(nameOnly) 

    source = instance.source;

	local  iprofile1;
    local iparams1;	
	local iprofile2;
    local iparams2;
	
	MethodA=instance.parameters.MethodA;
	SXA = instance.parameters.SXA;
	if MethodA=="Pips" then
    SYA = instance.parameters.SYA * source:pipSize();
    else 
	SYA = instance.parameters.SYA;
	end
	
	MethodB=instance.parameters.MethodB;
	SXB = instance.parameters.SXB;
	if MethodB=="Pips" then
    SYB = instance.parameters.SYB * source:pipSize();
    else 
	SYB = instance.parameters.SYB;
	end
	 
	Type1=instance.parameters.Type1;
	Type2=instance.parameters.Type2;
    Transparency= instance.parameters.Transparency;
    Lines = instance.parameters.Lines;
    ShortFrame = instance.parameters.SF;
    LongFrame = instance.parameters.LF;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	
	
	Transparency= 100-Transparency;
	
	
	   local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame.. ", " .. Method1.. ", ".. Method2  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	if Type1 == "Indicator" then
	           iprofile1 = core.indicators:findIndicator(instance.parameters:getString("Indicator1"));
			   iparams1 = instance.parameters:getCustomParameters("Indicator1");
			   if  iprofile1:requiredSource() == core.Tick then
			   Indicator1 = iprofile1:createInstance(source.close, iparams1);
			   else
			   Indicator1 = iprofile1:createInstance(source, iparams1);
			   end
	Source1=Indicator1.DATA;	
	else
	Source1=source[Type1];
	end
	
	if Type2 == "Indicator" then
	iprofile2 = core.indicators:findIndicator(instance.parameters:getString("Indicator2"));
			   iparams2 = instance.parameters:getCustomParameters("Indicator2");
			   if  iprofile2:requiredSource() == core.Tick then
			   Indicator2 = iprofile2:createInstance(source.close, iparams2);
			   else
			   Indicator2 = iprofile2:createInstance(source, iparams2);
			   end
	Source2=Indicator2.DATA;
	else
	Source2=source[Type2]; 
	end
	
   
   
		 first1A = Source2:first();
		first2A = first1A + SXA;
		if first2A < 0 then
			first2A = 0;
		end
		
		first1B = Source2:first();
		first2B = first1B + SXB;
		if first2B < 0 then
			first2B = 0;
		end
	
	
	
	LongDATA= core.indicators:create(Method1, Source1, ShortFrame);	
	ShortDATA= core.indicators:create(Method2, Source2, LongFrame);
	

	
	first = math.max(ShortDATA.DATA:first(),LongDATA.DATA:first());
	
	
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install "..Method1..  " indicator");
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install "..Method2..  " indicator");

 
    
   if Lines then   
    Top=instance:addStream("Top", core.Line, name, "Top", core.rgb( 128, 128, 128), first2B, SXB);
    Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", core.rgb( 128, 128, 128), first2A, SXA);
	Top:setStyle(core.LINE_SOLID);
    Bottom:setStyle(core.LINE_SOLID);
    else
    Top=instance:addStream("Top", core.Line, name, "Top", core.rgb( 128, 128, 128), first2B, SXB);
    Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", core.rgb( 128, 128, 128), first2A, SXA);
	Top:setStyle(core.LINE_NONE);
    Bottom:setStyle(core.LINE_NONE);
	end
	
	instance:createChannelGroup("UpGroup","Cloud" , Top, Bottom, instance.parameters.Up, Transparency);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

  
        if Type1== "Indicator" then		
	     Indicator1:update(mode)    
		 end
		 if Type2== "Indicator" then	
		  Indicator2:update(mode)   
        end		  
		
	    LongDATA:update(mode);
		ShortDATA:update(mode);
		
	if period < first then
	return;
	end	
		
	local p1A = period + SXA;
	local p1B = period + SXB;
	
	
    if p1A  < 0 or p1B <0  or period < first1A or period < first1B then
	return;
	end
	
	local ShiftA, ShiftB;  
	      if MethodA~="Percentage" then
          ShiftA =  SYA;
		  else
		  ShiftA = (source[period]/100)*SYA;
		  end
		  
		  if MethodB~="Percentage" then
          ShiftB =  SYB;
		  else
		  ShiftB = (source[period]/100)*SYB;
		  end
 
						
						
					 			
						Top[p1B] = LongDATA.DATA[period]+ShiftB;  
						Bottom[p1A] = ShortDATA.DATA[period]+ShiftA;
	
		if period ~= source:size()-1 then
		return;
		end	
		
			for period= math.max(Bottom:first(), Top:first()-1),math.min(Bottom:size()-1, Top:size()-1) , 1 do
			            if Top[period] >= Top[period-1]  then
						
						     if Bottom[period] >= Bottom[period-1]then
					          Top:setColor(period, instance.parameters.Up); 
					     	 else
						      Top:setColor(period, instance.parameters.UpDown); 
							  end
						 
						
						else
						
						      if Bottom[period] >= Bottom[period-1]then
					          Top:setColor(period, instance.parameters.DownUp); 
					     	 else
						      Top:setColor(period, instance.parameters.Down); 
							  end
						
					   
						end
						
						
			end
     
           	
	
end