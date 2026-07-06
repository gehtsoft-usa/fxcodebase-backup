-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=724

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
function Init()
    indicator:name("Advanced Fractal Trend Chart Background");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
 	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Fractal", "Number of fractals ", "Number of fractals ", 2, 1,99);	
 
	
 	indicator.parameters:addGroup("Style");			
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addColor("Up", "Up Trend Background color", "Up Trend color", core.rgb(0,255,0));
    indicator.parameters:addColor("Down", "Down Trend Background color ", "Down Trend color", core.rgb(255,0,0));

	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
	
	indicator.parameters:addInteger("Transparency", "Transparency", "Transparency",50);
end

local source;
local up, down;
local Fractal=0;
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
	Fractal=instance.parameters.Fractal
	Size = instance.parameters.Size; 
	
	source = instance.source;
	first= source:first()+ Fractal;
   
 
  
    local name = profile:id() .. " ( " .. Fractal  .. " )";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	
	instance:ownerDrawn(true);
	
	
	TREND = instance:addInternalStream(0, 0);
	UP = instance:addInternalStream(0, 0);
	DOWN = instance:addInternalStream(0, 0);	
	
end

function Update(period, mode)
 


    
    if (period <= Fractal) then
	return;
	end
	
	
	
	     local x = period - Fractal; 
		 
	UP[x]=UP[x-1];
	DOWN[x]=DOWN[x-1];
	TREND[period] = TREND[period-1];		 
		
      local test=true;		
         for i= 1, Fractal, 1 do
		
		     if  source.high[x]  < source.high[x+i]
			 or  source.high[x] < source.high[x-i]
			 then
			 test=false;
			 end
			
		 end	
		 
		 if test then 
 		   up:set(x, source.high[x], "\226");
		   
		   UP[x]= source.high[x]; 
		 end

        test=true;	 
	   
         for i= 1, Fractal, 1 do
		
		     if  source.low[x] > source.low[x+i]
			 or  source.low[x] > source.low[x-i]
			 then
			 test=false;
			 end
			
		 end	
	   
	      if test then 
			  down:set(x, source.low[x], "\225"); 
			  
			  DOWN[x] = source.low[x]; 
		  end
		  
		  


		  
		 if core.crossesOver (source.close, UP[period-2], period-1 ) then   
		  TREND[period] = 1;
		 elseif core.crossesUnder (source.close, DOWN[period-2], period-1) then   
		  TREND[period] = -1;
		 end
		 
		 
        
    
end


local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	 
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
	init =true; 
	Transparency=context:convertTransparency (instance.parameters.Transparency);
	
	context:createSolidBrush(1, instance.parameters.Up);
	context:createSolidBrush(2, instance.parameters.Down);

	context:createPen (11, context.SOLID, 2, instance.parameters.Up)
	context:createPen (12, context.SOLID, 2, instance.parameters.Down)	 
	end
	
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    

	    
 
	
 
			    for i= first, last, 1 do	 
			    x0, x1, x2 = context:positionOfBar (i);	
					if TREND[i] == 1 then 
					context:drawRectangle (11, 1, x1, context:top(), x2, context:bottom(), Transparency); 
					elseif TREND[i] == -1 then 
					context:drawRectangle (12, 2, x1, context:top(), x2, context:bottom(), Transparency); 
					end
				end
end	
	
	
	
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