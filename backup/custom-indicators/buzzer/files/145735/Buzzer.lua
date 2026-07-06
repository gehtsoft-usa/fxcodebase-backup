-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72102

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
    indicator:name("Buzzer");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 20, 1, 2000);

	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
local Indicator;
local PctFilter      = 1.36;  
local  Deviation      = 0;
local i, Phase, Len;
local Cycle=4;
local Coeff, beta, t, Sum, Weight, g;
local alfa={};    	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	
	
 
    Del= instance:addInternalStream(0, 0);
	sumpow= instance:addInternalStream(0, 0);
	trend= instance:addInternalStream(0, 0);
	AvgDel= instance:addInternalStream(0, 0);

	
	Coeff =  3*math.pi;
   Phase = Length-1;
   Len = Length*4 + Phase;  
 
   Weight=0;
   for  i=0, Len-1,1 do 
               if (i<=Phase-1) then
			  t = 1.0*i/(Phase-1); 
			  else
			  t = 1.0 + (i-Phase+1)*(2.0*Cycle-1.0)/(Cycle*Length-1.0); 
			  end
	  
	  
		  beta = math.cos(math.pi*t);
		  g = 1.0/(Coeff*t+1);   
		  if (t <= 0.5 ) then g = 1 end;
		  alfa[i] = g * beta;
		  Weight  = Weight + alfa[i];
      end
	  
	  
	first=source:first()+Len ;   
	
	
	MABuffer = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first );
    MABuffer:setPrecision(math.max(2, instance.source:getPrecision()));
    MABuffer:setWidth(instance.parameters.width);
    MABuffer:setStyle(instance.parameters.style);
    MABuffer:addLevel(0);	
	
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
	
	local Filter=0;
	local Sum=0;
	for i=0, Len-1, 1 do      
    Sum =Sum+ alfa[i]*source[period-i];
    end 
	
	
	if (Weight > 0) then MABuffer[period] = (1.0+Deviation/100)*Sum/Weight; end 
		  
	 if (PctFilter>0) then
	   
		  Del[period] = math.abs(MABuffer[period] - MABuffer[period-1]);
	   
	 
	 
		 AvgDel[period]=mathex.avg(Del, period-Length+1, period  );
		   
	 
		  sumpow[period]=math.pow(Del[period]-AvgDel[period],2);
		  
		  local  StdDev =math.sqrt(mathex.avg(sumpow, period-Length+1, period  )); 
		 
		 Filter = PctFilter * StdDev;
		 
		  if( math.abs(MABuffer[period]-MABuffer[period-1]) < Filter )  then   MABuffer[period]=MABuffer[period-1]; end
    
	  end
 
	
	
	
	 trend[period]=trend[period-1];
	 
      if (MABuffer[period]-MABuffer[period-1] > Filter) then trend[period]= 1; end
      if (MABuffer[period-1]-MABuffer[period] > Filter) then trend[period]=-1; end
	  
         if (trend[period]>0) then
         MABuffer:setColor(period,  instance.parameters.Up);			 
         end
         if (trend[period]<0) then   
         MABuffer:setColor(period,  instance.parameters.Down);			 
         end
end

--[[
  Coeff =  3*pi;
   Phase = Length-1;
   Len = Length*4 + Phase;  
   ArrayResize(alfa,Len);
   Weight=0;    
      
      for (i=0;i<Len-1;i++)
      {
      if (i<=Phase-1) t = 1.0*i/(Phase-1);
      else t = 1.0 + (i-Phase+1)*(2.0*Cycle-1.0)/(Cycle*Length-1.0); 
      beta = MathCos(pi*t);
      g = 1.0/(Coeff*t+1);   
      if (t <= 0.5 ) g = 1;
      alfa[i] = g * beta;
      Weight += alfa[i];
      }

   
   for(i=1;i<Length*Cycle+Length;i++) 
   {
   MABuffer[Bars-i]=0;    
   UpBuffer[Bars-i]=0;  
   DnBuffer[Bars-i]=0;  
   }
   
   for(shift=limit;shift>=0;shift--) 
   {	
      Sum = 0;
      for (i=0;i<=Len-1;i++)
	   { 
      price = iMA(Symbol(),TIME_FRAMES,1,0,3,Price,i+shift);      
      Sum += alfa[i]*price;
      
      }
   
	if (Weight > 0) MABuffer[shift] = (1.0+Deviation/100)*Sum/Weight;
   
      
      if (PctFilter>0)
      {
      Del[shift] = MathAbs(MABuffer[shift] - MABuffer[shift+1]);
   
      double sumdel=0;
      for (i=0;i<=Length-1;i++) sumdel = sumdel+Del[shift+i];
      AvgDel[shift] = sumdel/Length;
    
      double sumpow = 0;
      for (i=0;i<=Length-1;i++) sumpow+=MathPow(Del[shift+i]-AvgDel[shift+i],2);
      double StdDev = MathSqrt(sumpow/Length); 
     
      double Filter = PctFilter * StdDev;
     
      if( MathAbs(MABuffer[shift]-MABuffer[shift+1]) < Filter ) MABuffer[shift]=MABuffer[shift+1];
      }
      else
      Filter=0;
      
      if (Color>0)
      {
      trend[shift]=trend[shift+1];
      if (MABuffer[shift]-MABuffer[shift+1] > Filter) trend[shift]= 1; 
      if (MABuffer[shift+1]-MABuffer[shift] > Filter) trend[shift]=-1; 
         if (trend[shift]>0)

]]