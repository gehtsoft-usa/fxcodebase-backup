-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------------+
--|                                    Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                 http://fxcodebase.com  |
--+------------------------------------------------------------------------+
--|                                      Support our efforts by donating   | 
--|                                         Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------+
--|                                           Developed by : Mario Jemic   |                    
--|                                               mario.jemic@gmail.com    |
--|                                https://AppliedMachineLearning.systems  |
--|                                     Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+
function Init()
    indicator:name("Advanced Fractal Support/Resistance lines");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
	indicator.parameters:addInteger("Fractals", "Number of fractals", "Number of fractals", 5, 5,99);
	indicator.parameters:addString("Show", "Show", "Search for ", "Fractal");
	indicator.parameters:addStringAlternative("Show", "Fractal", "", "Fractal");
    indicator.parameters:addStringAlternative("Show", "Overlay", "", "Overlay");
    indicator.parameters:addStringAlternative("Show", "Both", "", "Both");	
	
	
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addColor("U", "Up Trend color", "Up Trend color", core.rgb(0,255,0));
    indicator.parameters:addColor("D", "Down Trend color", "Down Trend color", core.rgb(255,0,0));

	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
	indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5);
	
	

end

local source;
local Up, Down;
local Fractals=0;
local Rez=0;
local Size;
local first;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Show;
local U,D;

local UP, DOWN, TREND;

function Prepare(nameOnly)
    U = instance.parameters.U;
	D = instance.parameters.D;    
	Fractals=instance.parameters.Fractals
	 Size = instance.parameters.Size;
	Show= instance.parameters.Show;
	
	source = instance.source;
	first= source:first()+ Fractals;
	
	
	local name = profile:id() .. " ( " .. Fractals .. " )";
    instance:name(name);
	
	if nameOnly then
	return;
	end
	
	
 
	if Show == "Overlay" then
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);	
	else
	Up = instance:addStream("Up", core.Dot, name .. ".Up", "Up", instance.parameters.UP, first);		
    Down = instance:addStream("Down", core.Dot, name .. ".Down", "Down", instance.parameters.DOWN, first);	
	Up:setWidth(instance.parameters.widthLinReg);   
	Down:setWidth(instance.parameters.widthLinReg);	
	end
  	
 
  

	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)

	 instance:createCandleGroup("ZONE", "", open, high, low, close);
end

function Update(period, mode)


    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	

     
 
    if (period <= first) then
	return;
	end
	
	Down[period]=Down[period-1];
	Up[period]=Up[period-1];	
	
		 
	
	
	     local x = period - Fractals;
	
       
       local test=true;		
         for i= 1, Fractals, 1 do
		
		     if  source.high[x]  < source.high[x+i]
			 or  source.high[x] < source.high[x-i]
			 then
			 test=false;
			 end
			
		 end	
		 
		  
		 
		 if test then 
		   
		   Up[period - Fractals]= source.high[period - Fractals];	
		   
		   for i= 1, Fractals, 1 do
			   if source.high[period - Fractals] >= source.high[period - Fractals+i] then
			   Up[period - Fractals+i]= source.high[period - Fractals];	
			   else
			    Up[period - Fractals]=nil;
			   end
		   end
		   
		   UP= source.high[period - Fractals];  
		 end

         test=true;	 
	   
         for i= 1, Fractals, 1 do
		
		     if  source.low[x] > source.low[x+i]
			 or  source.low[x] > source.low[x-i]
			 then
			 test=false;
			 end
			
		 end	
	   
	      if test then
		      Down[period-Fractals]= source.low[period - Fractals];
			  for i= 1, Fractals, 1 do	
				  if source.low[period - Fractals] <= source.low[period - Fractals+i] then			  
				  Down[period-Fractals+i]= source.low[period - Fractals];
				  else
				  Down[period - Fractals]=nil;
				  end
              end
 
			  DOWN = source.low[period - Fractals]; 
		 
		 end
 

		  
		  
		  if UP == nil or DOWN == nil then
		  return;
		  end
		  
		 if core.crossesOver (source.close, UP, period ) then   
		  TREND = true;
		 elseif core.crossesUnder (source.close, DOWN, period ) then   
		  TREND = false;
		 end
		 
		if Show ~= "Fractal" then
		  if TREND then
		  open:setColor(period, U);
		  elseif not TREND then
		  open:setColor(period, D);
		  end
        end
    
end
