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
    indicator:name("Advance Parabolic Time/Price System");
    indicator:description("Advance Parabolic Time/Price System");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("HiLoMode", "High/Low Mode 0-off,1-on", "", 0, 0, 1);
	indicator.parameters:addDouble("StartAF", "Start value of Acceleration Factor", "",  0.002);
	indicator.parameters:addDouble("Step", "Acceleration Factor increment", "",  0.002);
	indicator.parameters:addDouble("MaxAF", "Maximum value of Acceleration Factor", "",  0.2);
	indicator.parameters:addDouble("Filter", "Filter in pips", "",  0);
	indicator.parameters:addDouble("MinChange", "Min Change in pips", "",  0);
	indicator.parameters:addInteger("SignalMode", "SignalMode: 0-only Stops,1-Signals & Stops", "", 0, 0, 1);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DOWN_color", "Color of DOWN", "Color of DOWN", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Size", "Font Size", "", 10);
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local prev
local first;
local source = nil;
local HiLoMode,  StartAF, Step, MaxAF, Filter, MinChange, SignalMode,Price;
-- Streams block
local UpTrendSAR,DnTrendSAR; 
local Trend,AF; 
local HighValue={};
local LowValue={};
local font;
local  hiprice={};
local  loprice={};
local Size;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Size = instance.parameters.Size;
	HiLoMode = instance.parameters.HiLoMode;
	Price = instance.parameters.Price;
	StartAF=instance.parameters.StartAF;
	Step=instance.parameters.Step;
	MaxAF=instance.parameters.MaxAF;
	Filter=instance.parameters.Filter;
	MinChange=instance.parameters.MinChange;
	SignalMode=instance.parameters.SignalMode;
    first = source:first();
	font  = core.host:execute("createFont", "Wingdings", Size, false, false);

	 

	  
	
	Trend= instance:addInternalStream(0, 0);
    AF= instance:addInternalStream(0, 0);
    local name = profile:id() .. "(" .. source:name().. ", " .. Price.. ", " .. HiLoMode.. ", " .. StartAF.. ", " .. Step.. ", " .. MaxAF.. ", " .. Filter.. ", " .. MinChange.. ", " .. SignalMode.. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
        UpTrendSAR = instance:addStream("UP", core.Dot, name .. ".UP", "UP", instance.parameters.UP_color, first);
		UpTrendSAR:setWidth(instance.parameters.width);
        DnTrendSAR = instance:addStream("DOWN", core.Dot, name .. ".DOWN", "DOWN", instance.parameters.DOWN_color, first);
		DnTrendSAR:setWidth(instance.parameters.width);
		
		
    
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   
	   
	   

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(shift)


      core.host:execute ("removeLabel", source:serial(shift));
	  
      if prev ~= source:serial(shift) then
       
      HighValue[2] = HighValue[1]; HighValue[1] = HighValue[0];
      LowValue[2]  = LowValue[1] ; LowValue[1]  = LowValue[0] ;
      hiprice[2]   = hiprice[1]  ; hiprice[1]   = hiprice[0]  ;
      loprice[2]   = loprice[1]  ; loprice[1]   = loprice[0]  ;  
      prev     = source:serial(shift);
      end

     if(HiLoMode > 0)then
	  hiprice[0] = source.high[shift];
      loprice[0] = source.low[shift];
	 else
	 hiprice[0] = source[Price][shift];
     loprice[0] = source[Price][shift];
	 end
	 
	 

    if shift < first or not  source:hasData(shift) then
	return;
	end
	
	if shift< 2 then	
	return;
	end
	
	if shift== 2 then	
	  Trend[shift] = 1;
         
      HighValue[1] = hiprice[1];
      HighValue[0] = math.max(hiprice[0],HighValue[1]);
      LowValue[1]  = loprice[1];
      LowValue[0]  = math.min(loprice[0],LowValue[1]);
      AF[shift]    = StartAF;   
      UpTrendSAR[shift] = LowValue[0];
      DnTrendSAR[shift] = nil;
	return;	
	end
	
	  HighValue[0] = HighValue[1];
      LowValue [0] = LowValue [1];
      Trend[shift] = Trend[shift-1];
      AF[shift]    = AF[shift-1];
	  
	  
	   if(Trend[shift-1] > 0) then
		   
            if(Trend[shift-1] == Trend[shift-2]) then
           
            if(HighValue[1] > HighValue[2]) then AF[shift] = AF[shift-1] + Step; end
            if(AF[shift] > MaxAF)then AF[shift] = MaxAF; end
            if(HighValue[1] < HighValue[2]) then AF[shift] = StartAF; end
           else 
			AF[shift] = AF[shift-1];
			end
            
         UpTrendSAR[shift] = UpTrendSAR[shift-1] + AF[shift] * (HighValue[1] - UpTrendSAR[shift-1]); 
		   	   
		   if(UpTrendSAR[shift] > loprice[1]) then UpTrendSAR[shift] = loprice[1]; end
	      if(UpTrendSAR[shift] > loprice[2]) then UpTrendSAR[shift] = loprice[2]; end
        
		   elseif(Trend[shift-1] < 0)  then 
		   
		  
         
            if(Trend[shift-1] == Trend[shift-2]) then
                      
            if(LowValue[1] < LowValue[2]) then AF[shift] = AF[shift-1] + Step;  end
            if(AF[shift] > MaxAF)  then AF[shift] = MaxAF;end
            if(LowValue[1] > LowValue[2]) then AF[shift] = StartAF;  end
            else
			AF[shift] = AF[shift-1];
			end
         
         DnTrendSAR[shift] = DnTrendSAR[shift-1] + AF[shift] * (LowValue[1] - DnTrendSAR[shift-1]); 
		   		   	   
		   if(DnTrendSAR[shift] < hiprice[1]) then DnTrendSAR[shift] = hiprice[1];end
	      if(DnTrendSAR[shift] < hiprice[2])  then DnTrendSAR[shift] = hiprice[2]; end
       end
		 
		 
		if(hiprice[0] > HighValue[0]) then HighValue[0] = hiprice[0]; end
		if(loprice[0] <  LowValue[0])then  LowValue[0]  = loprice[0]; end
         
		 
		 
         if(MinChange > 0) then
		    
		   if(UpTrendSAR[shift] - UpTrendSAR[shift-1] < MinChange* source:pipSize() and UpTrendSAR[shift]~= nil and UpTrendSAR[shift-1]~= nil) then UpTrendSAR[shift] = UpTrendSAR[shift-1]; end 
		   if(DnTrendSAR[shift-1] - DnTrendSAR[shift] < MinChange* source:pipSize() and  DnTrendSAR[shift]~= nil and DnTrendSAR[shift-1]~= nil) then DnTrendSAR[shift] = DnTrendSAR[shift-1]; end
		  end 
      
	  
	  
      if(Trend[shift] < 0 and DnTrendSAR[shift] > DnTrendSAR[shift-1]) then DnTrendSAR[shift] = DnTrendSAR[shift-1]; end
		if(Trend[shift] > 0 and UpTrendSAR[shift] < UpTrendSAR[shift-1]) then UpTrendSAR[shift] = UpTrendSAR[shift-1];end
   
   
   
         if(Trend[shift] < 0 and hiprice[0] >= DnTrendSAR[shift] + Filter*source:pipSize())  then
		  
		   Trend[shift] =  1;		
		   
		   UpTrendSAR[shift] = LowValue[0]; 
		   if(SignalMode  > 0) then
		   --UpSignal  [shift] = LowValue[0];
		    core.host:execute("drawLabel1", source:serial(shift), source:date(shift), core.CR_CHART, LowValue[0], core.CR_CHART, core.H_Center, core.V_Bottom,
                             font,  instance.parameters.UP_color, "\225");
		   end
		   DnTrendSAR[shift] = nil;
		   
		   AF[shift]  = StartAF;
		   LowValue[0]  = loprice[0];
		   HighValue[0] = hiprice[0];
		 
		   elseif(Trend[shift] > 0 and loprice[0] <= UpTrendSAR[shift] - Filter*source:pipSize())  then
		   
		   Trend[shift] = -1; 
		
		   DnTrendSAR[shift] = HighValue[0];
		   if(SignalMode  > 0) then
		  -- DnSignal  [shift] = HighValue[0];
		   core.host:execute("drawLabel1", source:serial(shift), source:date(shift), core.CR_CHART, HighValue[0], core.CR_CHART, core.H_Center, core.V_Bottom,
                             font,  instance.parameters.DOWN_color, "\226");
		   end
		   UpTrendSAR[shift] = nil;
		   
		   AF[shift]  = StartAF;
		   LowValue[0]  = loprice[0];
		   HighValue[0] = hiprice[0];
		  end 
	 
	--[[
	  core.host:execute("drawLabel1", id + 5, 0, core.CR_CENTER, min, core.CR_CHART, core.H_Center, core.V_Bottom,
                             font2, core.rgb(0, 255, 255), "\225");
           id = id + 1;
           core.host:execute("drawLabel1", id + 5, 0, core.CR_CENTER, max, core.CR_CHART, core.H_Center, core.V_Top,
                             font2, core.rgb(0, 255, 255), "\226");

	]]
   
end

