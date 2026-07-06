-- Id: 21490
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66162

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
    indicator:name("RSI Bar Chart");
    indicator:description("RSI Bar Chart");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "RSI Method", "", "Regular");
    indicator.parameters:addStringAlternative("Method", "Regular RSI", "", "Regular");
    indicator.parameters:addStringAlternative("Method", "Slow RSI", "", "Slow");
    indicator.parameters:addStringAlternative("Method", "Rapid RSI", "", "Rapid");
    indicator.parameters:addStringAlternative("Method","Harris RSI", "", "Harris");
    indicator.parameters:addStringAlternative("Method", "RSX", "", "RSX");
    indicator.parameters:addStringAlternative("Method", "Cuttlers RSI", "", "Cuttlers");	
	
 
	
    indicator.parameters:addInteger("Period", "RSI Period", "", 14, 2, 1000);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Method;
local Data={};
local Up,Down,Neutral;

local Period; 
local RSI = nil;
local Work1={};
local Work2={}; 
local Work3={};
local Work4={}; 
local Work5={};
local Work6={}; 
local Work7={};
local Work8={};
local Work9={};
local Work10={}; 
local Work11={};
local Work12={}; 
function Prepare(nameOnly)   

    Period = instance.parameters.Period;
	source = instance.source;
	first=source:first()+Period; 
    local name = profile:id() .. "(" .. source:name() ..", ".. Period.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
	Method= instance.parameters.Method;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral; 
	 
 
      

    for i= 1, 4 , 1 do
    Work1[i]= instance:addInternalStream(0, 0);
	Work2[i]= instance:addInternalStream(0, 0);
	Work3[i]= instance:addInternalStream(0, 0);
	Work4[i]= instance:addInternalStream(0, 0);
	Work5[i]= instance:addInternalStream(0, 0);
	Work6[i]= instance:addInternalStream(0, 0);
	Work7[i]= instance:addInternalStream(0, 0);
	Work8[i]= instance:addInternalStream(0, 0);
	Work9[i]= instance:addInternalStream(0, 0);
	Work10[i]= instance:addInternalStream(0, 0);
	Work11[i]= instance:addInternalStream(0, 0);
	Work12[i]= instance:addInternalStream(0, 0);
	end
	
	Data[1] = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    Data[1]:setPrecision(math.max(2, instance.source:getPrecision()));
    Data[2] = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    Data[2]:setPrecision(math.max(2, instance.source:getPrecision()));
    Data[3]= instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    Data[3]:setPrecision(math.max(2, instance.source:getPrecision()));
    Data[4] = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
    Data[4]:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("RSI", "RSI", Data[1], Data[2], Data[3], Data[4]);
	
	Data[1]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Data[1]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	 
		
end

-- Indicator calculation routine
function Update(period, mode)
		   
		   if period < Period then
		   Data[1]:setColor(period, Neutral);
		   return;
		   end
		   
		
    if Method== "Regular" then
 
	RegularRSI(period,source.open,1);
	RegularRSI(period,source.high,2);
	RegularRSI(period,source.low,3);
	RegularRSI(period,source.close,4);
	
	elseif Method== "Slow" then
 
	SlowRSI(period,source.open,1);
	SlowRSI(period,source.high,2);
	SlowRSI(period,source.low,3);
	SlowRSI(period,source.close,4);
	
	elseif Method== "Rapid" then
 
	RapidRSI(period,source.open,1);
	RapidRSI(period,source.high,2);
	RapidRSI(period,source.low,3);
	RapidRSI(period,source.close,4);
	
	elseif Method== "Harris" then
 
	HarrisRSI(period,source.open,1);
	HarrisRSI(period,source.high,2);
	HarrisRSI(period,source.low,3);
	HarrisRSI(period,source.close,4);
	
	
	elseif Method== "RSX" then
 
	RSXRSI(period,source.open,1);
	RSXRSI(period,source.high,2);
	RSXRSI(period,source.low,3);
	RSXRSI(period,source.close,4);
	
	
	elseif Method== "Cuttlers" then
 
	CuttlersRSI(period,source.open,1);
	CuttlersRSI(period,source.high,2);
	CuttlersRSI(period,source.low,3);
	CuttlersRSI(period,source.close,4);
	end
		
						 
							if Data[4][period]>Data[1][period] then 	
							Data[1]:setColor(period, Up); 
							elseif Data[4][period]<Data[1][period] then 
                            Data[1]:setColor(period, Down); 							
							else
							Data[1]:setColor(period, Neutral); 
							end
							
						 
	 
end		

function RegularRSI(period,LocalData,Index)

 local  alpha = 1.0/math.max(Period,1); 
 
         if (period<first ) then
          
               local sum = 0;
			
			  for i= 0, Period-1, 1 do
			  sum= sum +math.abs(LocalData[period-i]-LocalData[period-1-i])
			  end
			   
                  Work1[Index][period] = (LocalData[period]-LocalData[period-Period+1])/math.max(Period,1);
                  Work2[Index][period] = sum/math.max(P,1);
             
         else
            
              local  change = (LocalData[period]-LocalData[period-1])
              Work1[Index][period] = Work1[Index][period-1] + alpha*(     change  - Work1[Index][period-1]);
              Work2[Index][period] = Work2[Index][period-1] + alpha*(math.abs(change) - Work2[Index][period-1]);
         end
		 
	 
			 if (Work2[Index][period] ~= 0) then
			 Data[Index][period]=(50.0*( Work1[Index][period]/ Work2[Index][period] +1 ));
			 else
			 Data[Index][period]=50.0;
			 end		 
		 
	 

end	
 
function SlowRSI(period,LocalData,Index)

   local  up = 0;
   local  dn = 0;
    local diff;
            for k= 0, Period-1, 1 do
            
                diff =  LocalData[period-k ] -LocalData[period -1-k]
               if(diff>0) then
                     up  = up+diff;
               else  
			   dn = dn-diff;
			   end
            end
            if (period<Period) then
                 Data[Index][period] = 50;
            else               
               if(up + dn == 0) then
               Data[Index][period] = Data[Index][period-1]+(1/math.max(Period,1))*(50            -Data[Index][period-1]);
               else 
			   Data[Index][period] = Data[Index][period-1]+(1/math.max(Period,1))*(100*up/(up+dn)-Data[Index][period-1]);
               end  
			   
			end
end

 
function RapidRSI(period,LocalData,Index)

 local  up = 0;
 local diff;
            local dn = 0;
             for k= 0, Period-1, 1 do
            
                 diff = LocalData[period-k ] -LocalData[period -1-k]
               if(diff>0) then
                     up  = up+diff;
               else 
			   dn = dn-diff;
			   end
            end
            if(up + dn == 0) then
                   Data[Index][period]=50;
            else
			Data[Index][period]=(100 * up / (up + dn));  
            end			
			
end 

function HarrisRSI(period,LocalData,Index)	

 local  avgUp=0;
 local  avgDn=0; 
 local  double up=0;
 local  double dn=0;
 local diff;
            for k= 0, Period-1, 1 do
            
              diff = LocalData[period-k ] -LocalData[period -1-k]
               if(diff>0) then
                     avgUp  = avgUp+diff;
					 up=up+1; 
               else
			    avgDn  =avgDn- diff;
				dn=dn+1;  
			   end
            end
            if (up~=0) then avgUp  = avgUp/ up; end
            if (dn~=0) then avgDn  =avgDn/ dn; end
            
            local rs = 1;
               if (avgDn~=0) then rs = avgUp/avgDn; end
			  
               Data[Index][period]=(100-100/(1.0+rs));
			  
end 

function RSXRSI(period,LocalData,Index)	

  local  Kg = (3.0)/(2.0+Period);
  local  Hg = 1.0-Kg;
		 
            if (period<Period) then
			Data[Index][period]=50;
			end

          
            local  mom = LocalData[period ] -LocalData[period -1]
            local  moa = math.abs(mom);
			local kk;
			
    
			   Work1[Index][period]=  Kg*mom   + Hg*Work1[Index][period-1];
               Work2[Index][period] = Kg*Work1[Index][period] + Hg*Work2[Index][period-1]; 
			   mom = 1.5*Work1[Index][period] - 0.5 * Work2[Index][period];
               Work3[Index][period] = Kg*moa                + Hg*Work3[Index][period-1];
               Work4[Index][period] = Kg*Work3[Index][period] + Hg*Work4[Index][period-1]; 
			   moa = 1.5*Work3[Index][period] - 0.5 * Work4[Index][period];
			   
			   
			   Work5[Index][period]=  Kg*mom   + Hg*Work5[Index][period-1];
               Work6[Index][period] = Kg*Work5[Index][period] + Hg*Work6[Index][period-1]; 
			   mom = 1.5*Work5[Index][period] - 0.5 * Work6[Index][period];
               Work7[Index][period] = Kg*moa                + Hg*Work7[Index][period-1];
               Work8[Index][period] = Kg*Work7[Index][period] + Hg*Work8[Index][period-1]; 
			   moa = 1.5*Work7[Index][period] - 0.5 * Work8[Index][period];
			   
			   
			   Work9[Index][period]=  Kg*mom   + Hg*Work9[Index][period-1];
               Work10[Index][period] = Kg*Work9[Index][period] + Hg*Work10[Index][period-1]; 
			   mom = 1.5*Work9[Index][period] - 0.5 * Work10[Index][period];
               Work11[Index][period] = Kg*moa                + Hg*Work11[Index][period-1];
               Work12[Index][period] = Kg*Work11[Index][period] + Hg*Work12[Index][period-1]; 
			   moa = 1.5*Work11[Index][period] - 0.5 * Work12[Index][period];
      
            if (moa ~= 0) then
            Data[Index][period]=(math.max(math.min((mom/moa+1.0)*50.0,100.00),0.00)); 
            else
			Data[Index][period]=50;
			end
end 

function CuttlersRSI(period,LocalData,Index)	

            local sump = 0;
            local sumn = 0;
			local diff;
            for i= 0, Period-1, 1 do
            
                   diff = LocalData[period-i] -LocalData[period-i-1] ;
                  if (diff > 0) then sump =sump+ diff; end
                  if (diff < 0) then sumn  = sumn-diff; end
            end
			
            if (sumn > 0) then
            Data[Index][period]=(100.0-100.0/(1.0+sump/sumn));
            else  
			Data[Index][period]=50;
			end
end 

 