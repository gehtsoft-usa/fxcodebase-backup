-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4089

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

function Init()
    indicator:name("Multi Time Frame MACD");
    indicator:description("Multi Time Frame MACD");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

    indicator.parameters:addGroup("Price Type");       
   	indicator.parameters:addString("PriceType", "Price", "", "close");
	indicator.parameters:addStringAlternative("PriceType","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("PriceType", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("PriceType", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("PriceType", "LOW", "", "low");
    indicator.parameters:addStringAlternative("PriceType", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("PriceType", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("PriceType", "WEIGHTED", "", "weighted");	
	
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 500);
	 
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
	indicator.parameters:addColor("Up", "Up Arrow Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Arrow Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Arrow Color", "", core.rgb(128, 128, 128));
	
	
end


function Parameters (id , FRAME )
   indicator.parameters:addGroup(id ..".  Time Frame");
   indicator.parameters:addString("TF"..id, "MACD Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);	
	
    
    indicator.parameters:addInteger("ShortPeriod"..id, "Short Periods", "", 12);
	indicator.parameters:addInteger("LongPeriod"..id, "Long Periods", "", 26);
    indicator.parameters:addInteger("SignalPeriod"..id, "Signal Periods", "", 9);
	
    
end

local Label;
local Up, Down, Neutral;
local SourceData={};
local  Size;
local source;
local MACD={};
local day_offset, week_offset;

 
local host;
--local alive;
local first;

local PriceType;
local font1, font2,font3;

local Price;
local loading={};
local Shift;

local id;

function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
	  core.host:execute ("killTimer", 1);
   end

function Prepare(nameOnly) 
   
	Neutral=instance.parameters.Neutral;
    Label=instance.parameters.Label;
	Up=instance.parameters.Up;
    Down=instance.parameters.Down;
    Shift=instance.parameters.Shift;     
    Size=instance.parameters.Size;   
	PriceType=instance.parameters.PriceType;
    local name =  profile:id() .. ","  .. instance.source:name() ;
	instance:name(name);
	if   (nameOnly) then
        return;
    end
	
    source = instance.source;
	
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");   
	
	local i;
	first=source:first();
	local Test={};
	for i= 1, 5, 1 do	
	if (instance.parameters:getInteger ("LongPeriod"..i)<= instance.parameters:getInteger ("TF"..i)) then
       error("The short EMA period must be smaller than long EMA period");	   
	   
	Test[i]  = core.indicators:create("MACD", source.close, instance.parameters:getInteger ("ShortPeriod"..i) , instance.parameters:getInteger ("LongPeriod"..i), instance.parameters:getInteger ("SignalPeriod"..i)); 
     first= math.max(first, Test[i].HISTOGRAM:first() )*2  ;	
	end
	
	 
    for i= 1, 5, 1 do	
	  SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), instance.parameters:getString ("TF"..i), source:isBid(),  math.min(first,300)  , 200+i, 100+i);	 
	  MACD[i] = core.indicators:create("MACD", SourceData[i][PriceType], instance.parameters:getInteger ("ShortPeriod"..i) , instance.parameters:getInteger ("LongPeriod"..i), instance.parameters:getInteger ("SignalPeriod"..i));
	 loading[i] = true;     
    end
	
	
 
	end
	
	
	   font1 = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
	   
	        core.host:execute ("setTimer", 1, 1);
	 
end
function Id()

id = id+1;

return id;

end


function Update(period, mode)

 
    if  period <  source:size() - 1 then	
       return;
	end	
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then		
	return;	
	end
	
	id=0;
	
	core.host:execute ("setStatus", "")
	
 
			for i = 1, 5, 1  do
		  
					--	MACD[i]:update(mode);
						
						
						if  MACD[i].HISTOGRAM:hasData(MACD[i].HISTOGRAM:size()-1)  and  MACD[i].HISTOGRAM:hasData(MACD[i].HISTOGRAM:size()-2)  then	
                      

                     							 
							      core.host:execute("drawLabel1", Id(),  -i*Size*10-Size,  core.CR_RIGHT,Shift + Size + (0)*Size*1.5, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label, instance.parameters:getString ("TF"..i));
							 					 
										
																					
											    local Sorted= Sort(i);
												
								 
															
													core.host:execute("drawLabel1", Id(), -i*Size*10-Size,core.CR_RIGHT,   Shift + Size + (1)*Size*1.5, core.CR_TOP, core.H_Right, core.V_Bottom,
																	font1,  Sorted[3][1] ,  Sorted[1][1]  );	
															
                                                    core.host:execute("drawLabel1", Id(), -i*Size*10-Size,core.CR_RIGHT,   Shift + Size + (2)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Bottom,
																	font1, Sorted[3][2], Sorted[1][2] );	
														
											
										            core.host:execute("drawLabel1", Id(), -i*Size*10-Size,core.CR_RIGHT,   Shift + Size + (3)*Size*1.5 , core.CR_TOP, core.H_Right, core.V_Bottom,
						                                            font1, Sorted[3][3], Sorted[1][3]  );	
																	
                                                     core.host:execute("drawLabel1", Id(), -i*Size*10-Size,core.CR_RIGHT,   Shift + Size + (4)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Bottom,
						                                            font1, Sorted[3][4], Sorted[1][4]  );		 																	
												
																	 
			end 
	 
	    end
 
end


function AKeyOf(Sorted,val)

    local X=1;
	
    for i= 1, 4 ,1 do
        if Sorted[1][i]== val then
		X=i;
		break;
		end
    end
	
	return X;
end


function Sort (i)


	local Unsorted={};
	
	Unsorted[3]={};
	
	                                            if MACD[i].MACD[MACD[i].MACD:size()-1] > MACD[i].MACD[MACD[i].MACD:size()-2] then
																
                                                        Unsorted[3][1] = Up; 
																
																					
												
												elseif MACD[i].MACD[MACD[i].MACD:size()-1] < MACD[i].MACD[MACD[i].MACD:size()-2] then
												
																									 
												        Unsorted[3][1] = Down;    
												else
													
													    Unsorted[3][1] = Neutral;                                                									
												
												end 		
												
												  if MACD[i].HISTOGRAM[MACD[i].HISTOGRAM:size()-1] > MACD[i].HISTOGRAM[MACD[i].HISTOGRAM:size()-2] then
																
                                                        Unsorted[3][4] = Up; 
																
																					
												
												elseif MACD[i].HISTOGRAM[MACD[i].HISTOGRAM:size()-1] < MACD[i].HISTOGRAM[MACD[i].HISTOGRAM:size()-2] then
												
																									 
												        Unsorted[3][4] = Down;    
												else
													
													    Unsorted[3][4] = Neutral;                                                									
												
												end 											
												
												
												
												if MACD[i].SIGNAL[MACD[i].SIGNAL:size()-1] > MACD[i].SIGNAL[MACD[i].SIGNAL:size()-2] then
																
                                                        Unsorted[3][2] = Up; 
																
																					
												
												elseif MACD[i].SIGNAL[MACD[i].SIGNAL:size()-1] < MACD[i].SIGNAL[MACD[i].SIGNAL:size()-2] then
												
																									 
												        Unsorted[3][2] = Down;    
												else
													
													    Unsorted[3][2] = Neutral;                                                									
												
												end 	
												
	                                            Unsorted[3][3] = Neutral; 
	
	Unsorted[1]={};
	Unsorted[1][1]= "MACD";
	Unsorted[1][2]= "SIGNAL"
	Unsorted[1][3]= "ZERO"
	Unsorted[1][4]= "HISTOGRAM"
	
	Unsorted[2]={};
	 
	Unsorted[2][1]= MACD[i].MACD[MACD[i].MACD:size()-1];
	Unsorted[2][2]= MACD[i].SIGNAL[MACD[i].SIGNAL:size()-1];
	Unsorted[2][3]= 0;
	Unsorted[2][4]=  MACD[i].HISTOGRAM[MACD[i].HISTOGRAM:size()-1]; 
								
	return	SortFunction(Unsorted, 2, 3, 4);									
												
end


function SortFunction(old, index, raw, columns)
 
 local new=old;
 local  j,k, temp;

 
   local SortFlag= true;
   
   while SortFlag do
       
	    SortFlag=false;
          
        for j = 2, columns , 1 do
                
                  if new[index][j] >  new[index][j-1] then
				  
				   SortFlag=true;
                                        
                           
                           for k = 1, raw, 1 do
                           temp= new[k][j-1];
                           new[k][j-1]= new[k][j];
                           new[k][j]= temp;
                           end
                      
                  end
            
        end      
      
    end
  
  return new;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     if cookie == 101 then
        loading[1] = true;
    elseif cookie == 102 then
        loading[2] = true;
    elseif cookie == 103 then
        loading[3] = true;
    elseif cookie == 104 then
        loading[4] = true;
    elseif cookie == 105 then
        loading[5] = true;
    elseif cookie == 201 then
        loading[1] = false;
        
    elseif cookie == 202 then
        loading[2] = false;
       
    elseif cookie == 203 then
        loading[3] = false;
        
    elseif cookie == 204 then
        loading[4] = false;
        
    elseif cookie == 205 then
        loading[5] = false; 
    end
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then		
	return;	
	end
	
	   if   cookie== 1 then
		for i= 1, 5 , 1 do
			  MACD[i]:update(core.UpdateLast );
		end
	  end	
	
	
    return core.ASYNC_REDRAW;
end

