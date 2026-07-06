-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60584

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
    indicator:name("MTF MTC RLW");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "H1" , "EUR/USD"); 
	Parameters (2 , "H4", "EUR/USD" );
	Parameters (3 , "H8", "EUR/USD" );
    Parameters (4 , "D1" , "EUR/USD");
	Parameters (5 , "W1" , "EUR/USD");
	
	
	indicator.parameters:addGroup("Lock Selector");	
	 indicator.parameters:addString("Type", "Lock Type", "", "Instrument");
    indicator.parameters:addStringAlternative("Type", "Time Frame", "", "Frame");
    indicator.parameters:addStringAlternative("Type", "Instrument", "", "Instrument");
	indicator.parameters:addStringAlternative("Type", "Lock Free", "", "Free");
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "No Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
 
	
	
end
 


function Parameters (id, frame , Def )

    indicator.parameters:addGroup(id..".  Time Frame"); 
	 
	indicator.parameters:addString("TF" .. id, id.. ". Time frame", "", frame);	 
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	
	indicator.parameters:addString("Pair" .. id, id.. ". Pair", "", Def);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
  	
    indicator.parameters:addInteger("Period"..id, "Period", "",14);
  
end

local Type;
local TF={};
local widht={};
local style={};
local source; 
local day_offset, week_offset;
local host;
local first={};
local Up, Down, Neutral, Note;
local Shift;
 local font1;
 local font2;
local Show={};	
local Pair={}; 
local SourceData={};
local loading={};
local Size;
local Test={};
local Label;
local Note={};
local id;
local Indicator={};
local Period={};
local Mode={};
local Step={};
local Max={};  
    
		
function Prepare(nameOnly)  

  	
    source = instance.source;	
	Type=instance.parameters.Type;
    host = core.host;
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
	 Size=instance.parameters.Size; 
	
   	local i;
	

	
    for i= 1, 5, 1 do	
	 
	 
	 if Type  == "Frame" then
	 TF[i]= source:barSize();
	 else
     TF[i]= instance.parameters:getString ("TF"..i);
	 end
	 
	 if Type  == "Instrument"  then
	 Pair[i]= source:name();
	 else
	 Pair[i]= instance.parameters:getString("Pair" .. i);	
	 end
	 
	 Period[i]= instance.parameters:getInteger ("Period"..i);
	 
	end
      
   
	
    local name = "(" .. profile:id() .. ", "  .. instance.source:name().. ", "  .. source:barSize().. ")" ;
    instance:name(name);
		
		
    if   (nameOnly) then
        return;
    end
	
	for i= 1, 5, 1 do
	
	 Note[i]= "(" .. TF[i]..", " ..Pair[i]..", " .. Period[i]..")";
	name = name.. ", " .. Note[i] ..  ")";   

   	Test[i] = core.indicators:create("RLW", source ,Period[i]);   
	first[i] = Test[i].DATA:first()+1;
	end
	 

	

	

	  font1 = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
 
	 for i = 1, 5, 1 do	
	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  math.min(300,first[i]) , 200+i, 100+i);
		  loading[i] = true;   
	    
		Indicator[i] = core.indicators:create("RLW", SourceData[i] ,Period[i]);   		
	 
	end
	
	   core.host:execute ("setTimer", 1, 1);
end


function Update(period)


    core.host:execute ("setStatus", "")
 
    if  period <  source:size() - 1 then	
       return;
	end
	
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then	
	core.host:execute ("setStatus", "Loading")
	return;	
	end
	
	
			
	   local i, color;
		id =0;
		
		local date = source:date(period);
		
		                  if Type  == "Instrument" then
		
			                 id=id+1;
							
							   core.host:execute("drawLabel1", id, -65, core.CR_RIGHT,  Size+Shift+1*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,source:name());
						  elseif Type  == "Frame" then	 
						  
						  
						       id=id+1;
							
							   core.host:execute("drawLabel1", id, -65, core.CR_RIGHT,  Size+Shift+1*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,source:barSize());
						  
						  end
							 
							 
		
		for i = 1 ,5 , 1  do			
			
		Calculation( i );	
				 
		end	
	  
end


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
	   core.host:execute ("killTimer", 1);
 end
   
function Calculation ( i)

         
				local color1= Neutral;
				local color2= Neutral;
				
				

						
						
				        if not Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1) then
                        return;
                        end	
						
                     							
							 if Type  == "Instrument" then
						
							  id=id+1;							
							   core.host:execute("drawLabel1", id, -i*65, core.CR_RIGHT,   Size+Shift+2*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,TF[i]);
							 
					
							
							 elseif Type  == "Frame" then
							
							 
							  id=id+1;
							
							   core.host:execute("drawLabel1", id, -i*65, core.CR_RIGHT,  Size+Shift+2*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,Pair[i]);
							 
							
							 
							 else
							 id=id+1;
							  core.host:execute("drawLabel1", id, -i*65, core.CR_RIGHT,  Size+Shift+1*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label, Pair[i] );
							 id=id+1;
							  core.host:execute("drawLabel1", id, -i*65, core.CR_RIGHT,  Size+Shift+2*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label, TF[i] );
							 end
							 
						
											   if Indicator[i].DATA[Indicator[i].DATA:size()-1]   >  Indicator[i].DATA[Indicator[i].DATA:size()-2] then
												color1=Up; 												
												elseif Indicator[i].DATA[Indicator[i].DATA:size()-1]   <  Indicator[i].DATA[Indicator[i].DATA:size()-2]  then
												color1=Down;
												else							
												color1 =Neutral;
												end 		
												
												local Value="";
												
												if Indicator[i].DATA[Indicator[i].DATA:size()-1]  > -20											
 												and Indicator[i].DATA[Indicator[i].DATA:size()-2]  < -20
												then
													Value= "OB"
													color2 = Up;
												end
												
												if Indicator[i].DATA[Indicator[i].DATA:size()-1]  < -20											
 												and Indicator[i].DATA[Indicator[i].DATA:size()-2]  > -20
												then
													Value= "OB"
													color2 = Down;
												end
												
													if Indicator[i].DATA[Indicator[i].DATA:size()-1]  > -80											
 												and Indicator[i].DATA[Indicator[i].DATA:size()-2]  < -80
												then
													Value= "OS";
													color2 = Up;
												end
												
												if Indicator[i].DATA[Indicator[i].DATA:size()-1]  < -80											
 												and Indicator[i].DATA[Indicator[i].DATA:size()-2]  > -80
												then
													Value= "OS"
													color2 = Down;
												end
												
												if Indicator[i].DATA[Indicator[i].DATA:size()-1]  > -50											
 												and Indicator[i].DATA[Indicator[i].DATA:size()-2]  < -50
												then
												   color2 = Up;
													Value= "CL"
												end
												
												if Indicator[i].DATA[Indicator[i].DATA:size()-1]  < -50											
 												and Indicator[i].DATA[Indicator[i].DATA:size()-2]  > -50
												then
												    color2 = Down;
													Value= "CL"
												end
												
												id=id+1;
												core.host:execute("drawLabel1", id, -i*65, core.CR_RIGHT,   Size+Shift+4*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, color2, Value);
											
											 
									
					                            id=id+1;
													core.host:execute("drawLabel1", id, -i*65, core.CR_RIGHT,   Size+Shift+3*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, color1,  string.format("%." .. 5 .. "f", Indicator[i].DATA[Indicator[i].DATA:size()-1] ));
			
				 
				
   
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
	
	  if not loading[5] and  not loading[4]  and   not loading[3]  and  not loading[2]  and  not loading[1] then
	  
	   if cookie== 1 then
		  for i = 1 ,5 , 1  do		
		  Indicator[i]:update(core.UpdateLast);
		  end	
      end		  
	  
 	  instance:updateFrom(0);
	  end
	  
    return core.ASYNC_REDRAW;
end
