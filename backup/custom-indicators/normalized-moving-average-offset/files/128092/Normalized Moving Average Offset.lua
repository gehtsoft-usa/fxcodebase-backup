-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68826

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams


function AddParam(id, frame )

    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", true);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Pair" .. id, "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);

end


function Init()
    indicator:name("Normalized Moving Average Offset");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
	
	 indicator.parameters:addString("Norm",  "Normalization Time frame", "", "D1");
    indicator.parameters:setFlag("Norm", core.FLAG_PERIODS);
	
	
	indicator.parameters:addBoolean("UseSort" , "Use Sort", "", true);	
	
	indicator.parameters:addBoolean("Chart" , "Use Chart Price Source", "", true); 
    indicator.parameters:addInteger("Period" , "Period", "", 14); 
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    AddParam(1, "m1");	
    AddParam(2, "m5");	
    AddParam(3, "m15");	
    AddParam(4, "m30");
    AddParam(5, "H1");
	AddParam(6, "H2");	
    AddParam(7, "H3");	
    AddParam(8, "H4");	
    AddParam(9, "H6");
    AddParam(10, "H8");
	AddParam(11, "D1");	
    AddParam(12, "W1");
    AddParam(13, "M1");
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90);
	indicator.parameters:addInteger("VShift", "Vertical Shift ", "Shift", 50); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local UP, DN, NO,VShift;
	local source = nil;
	local TF={};
	local Pair={};
	local L={};	
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
	local loading={};  
	local Size;
	local USE={};
	local Count=13;
    local Number;
	local Chart ;
	local Label;
  
    local Method, Period;
	local MA={};
	local Data={};
	local AbsData={};
	local Pips={};
	local Norm;
	local Multiplier; 
	local Table={1, 5, 15, 30,60, 120, 180, 240,360, 480, 1440,10080, 43200 };
	local TableNorm={};
	--local Table={"m1"=1, "m5"=5, "m15"=15,  "m30"=30,"H1"=60, "H2"=120, "H3"=180,  "H4"=240,   "H6"=360,  "D1"=1440, "W1"=10080, "M1"=43200 };
	local UseSort;
	local FinalKey;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    	
	Chart=instance.parameters.Chart;
    source = instance.source;
    UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	NO=instance.parameters.NO;
	VShift=instance.parameters.VShift;
	
	UseSort=instance.parameters.UseSort;
	
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	
	Method=instance.parameters.Method;
	Period=instance.parameters.Period;
	Norm=instance.parameters.Norm;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	
	local s1, e1 = core.getcandle("m1", core.now(), 0, 0);
    local s2, e2 = core.getcandle(Norm, core.now(), 0, 0);
	
	Multiplier=(e2-s2)/(e1-s1);

    local i;
   
	
	Number=0;
	
    for i = 1, Count, 1 do
	
	  
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		 Number=Number+1;
		 
		  
		 
		 		    
		    if  Chart   then		
		    Pair[Number]=source:name();	  
            else
            Pair[Number]= instance.parameters:getString("Pair" .. i);
		    end
	      
			  TF[Number]= instance.parameters:getString("TF" .. i);	 
			  TableNorm[Number]= Table[i];
		 end   
		   
	  
    end
   
   	
 	
	
	

    for i = 1, Number, 1 do	
	
	    	--local Test = core.indicators:create("CCI", source ,10);   
	        --first= Test.DATA:first()*2 ; 	
	  
	  	
	    if (TF[i] == source:barSize() and   Pair[i] == source:name())     then
		SourceData[i]=source;
		loading[i]= false;
		else 	
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  0 , 200+i, 100+i);	   
		loading[i]= true;		
		end
		
		
	   	 MA[i] = core.indicators:create(Method, SourceData [i].close, Period   );
		
		Pips[i]=SourceData[i]:pipSize();
		 
    end
    
	instance:ownerDrawn(true);
    core.host:execute ("setTimer", 1, 1);

end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), offset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	    
end

 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	local Flag = false;	

	
	
	
    for j = 1, Number, 1 do			
		if loading[j] then	
		Flag=true;
		end	 
 
	end    
	
     	if Flag then
		return;
		end
      
	    local xCell = (context:right () -context:left ())/(Number+1);		
        local yCell = (context:bottom () -context:top ())/15;		    
		
		for i = 1, Number, 1 do 	
			local Color;
			
			
			if UseSort then					 
			Index=FinalKey[i];        		
			else
			Index=i;
			end
						 
			if Data[Index]  >  0 then
			Color=UP;
			elseif  Data[Index]  <  0 then
			Color=DN;
			else
			Color=NO;
			end		
					 
            
			
			context:createFont (1, "Arial", (xCell/12)*(Size/100), yCell*(Size/100), 0);	
           
			 width, height = context:measureText (1, tostring(Pair[Index]), 0)			
			 context:drawText (1, tostring(Pair[Index]), Label, -1, context:left ()+(i-1)*xCell    , context:top ()+VShift+yCell/4, context:left ()+(i-1)*xCell + width, context:top ()+VShift+yCell/4 + height, 0);
			 
			  width, height = context:measureText (1, tostring(TF[Index]), 0)				
		    context:drawText (1, tostring(TF[Index]), Color, -1, context:left ()+(i-1)*xCell    , context:top ()+VShift+yCell*(5/4), context:left ()+(i-1)*xCell + width, context:top ()+VShift+yCell*(5/4) + height, 0);
			
			Value =string.format("%." .. 4 .. "f", AbsData[Index]);
			 width, height = context:measureText (1, Value, 0)				
		    context:drawText (1, Value, Color, -1, context:left ()+(i-1)*xCell    , context:top ()+VShift+yCell*(9/4), context:left ()+(i-1)*xCell + width, context:top ()+VShift+yCell*(9/4) + height, 0);
			
		 end
	 
         		 
 
		
end

-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)

     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
 
	end    
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ");
		  
		 instance:updateFrom(0);
		end
		
		
		if cookie== 1 and  not FLAG   then
		
 
			  for i = 1, Number, 1 do	
					MA[i]:update(core.UpdateLast); 			
					if MA[i].DATA:hasData(MA[i].DATA:size()-1)and MA[i].DATA:hasData(MA[i].DATA:size()-2) then
					Data[i]= ((((MA[i].DATA[MA[i].DATA:size()-1]-MA[i].DATA[MA[i].DATA:size()-2])/Pips[i]) /TableNorm[i])*Multiplier);
					AbsData[i]=math.abs(Data[i]);
					else
					Data[i]=0;
					AbsData[i]=0;
					end
					
					
					
			  end
		      
			  
			  if UseSort then
			  FinalKey= BubbleSortKey(AbsData, Number );
			  end
		
		end 
   
        
		return core.ASYNC_REDRAW ;
   
end





function BubbleSortKey(InternalData, columns)
 
 local Key={};
 local Temp;
 local Sort=true;
 
   
   for i=1, columns, 1 do
   Key[i]=i;
   end
   
   

     while Sort do
    Sort=false;
   
            for i = 2, columns , 1 do
                  
                    if InternalData[Key[i]] <  InternalData[Key[i-1]] then
                     Sort=true;                  
                     
                            Temp= Key[i];                     
                     Key[i]=Key[i-1];
                     Key[i-1]=Temp;                       
                    end
           
          end
    
    end
  
  return Key;
end
