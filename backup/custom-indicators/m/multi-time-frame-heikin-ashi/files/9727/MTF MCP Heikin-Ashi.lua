-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3934

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
    indicator:name("MTF MTC Heikin-Ashi");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "H1" , "EUR/USD"); 
	Parameters (2 , "H4", "EUR/USD" );
	Parameters (3 , "H8", "EUR/USD" );
    Parameters (4 , "D1" , "EUR/USD");
	Parameters (5 , "W1" , "EUR/USD");
	
	
	indicator.parameters:addGroup("Lock Selector");	
	 indicator.parameters:addString("Type", "Lock Type", "", "Free");
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
	
	Style (1 );
	Style (2 );
	Style (3 );
	Style (4 );
	Style (5 );
	
	
end

function Style (id)
    
  	indicator.parameters:addGroup(id.. ".  Time Frame Style Options"); 
    indicator.parameters:addBoolean("Show"..id, "Show Line", "", false);
    indicator.parameters:addInteger("widht"..id, "Line widht", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
--	indicator.parameters:addColor("color"..id, "Color", "", core.rgb(0, 255, 0));
end


function Parameters (id, frame , Def )

    indicator.parameters:addGroup(id..".  Time Frame"); 
	indicator.parameters:addString("TF" .. id, id.. ". Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Pair" .. id, id.. ". Pair", "", Def);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
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
	--()()()()()()Customized segment ()()()()()()()
    	local Indicator={};
        local Period={};
		local Mode={};
		local Step={};
		local Max={};
		--local color={};
	--()()()()()()()()()()()()()()()()()()()()()()()()
	

	

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
	 -- color[i]= instance.parameters:getColor ("color"..i);
	 Show[i]= instance.parameters:getBoolean ("Show"..i);
	 style[i]= instance.parameters:getDouble ("style"..i);
	 widht[i]= instance.parameters:getDouble ("widht"..i);	
	 
	 if Type  == "Frame" then
	 TF[i]= source:barSize();
	 else
     TF[i]= instance.parameters:getString ("TF"..i);
	 end
	 
	 if Type  == "Instrument" then
	 Pair[i]= source:name();
	 else
	 Pair[i]= instance.parameters:getString("Pair" .. i);	
	 end
	 
	
	end
      
   
	
    local name = "(" .. profile:id() .. ", "  .. instance.source:name().. ", "  .. source:barSize().. ")" ;

    name = name .. " Lock Type : " ..Type .. ")";
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	for i= 1, 5, 1 do
	
	 Note[i]= "(" .. TF[i]..", " ..Pair[i]..")";
	 

   	Test[i] = core.indicators:create("HA", source );   
	first[i] = Test[i].DATA:first();
	end
	
	

	

	  font1 = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
	  
	 for i = 1, 5, 1 do	
	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  math.min(300,first[i]*2), 200+i, 100+i);
		  loading[i] = true;   
	  
		 
		Indicator[i] = core.indicators:create("HA", SourceData[i] );   		
		
	end
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
							
							   core.host:execute("drawLabel1", id, -Size*4, core.CR_RIGHT,Size*3+Shift- Size*2, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,source:name());
						  elseif Type  == "Frame" then	 
						  
						  
						       id=id+1;
							
							   core.host:execute("drawLabel1", id, -Size*4, core.CR_RIGHT,Size*3+Shift- Size*2, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,source:barSize());
						  
						  end
							 
							 
		
		for i = 1 ,5 , 1  do			
			
		Calculation( i );	
		
		
		 
		     if Show[i] then
			 
			     
				 local  fromLevel;
				 
				 if Indicator[i].close[Indicator[i].DATA:size()-1]   >  Indicator[i].close[Indicator[i].DATA:size()-2]   then
				 fromLevel=  Indicator[i].close[Indicator[i].DATA:size()-1];
				 color = Up;
       			 elseif Indicator[i].close[Indicator[i].DATA:size()-1]   <  Indicator[i].close[Indicator[i].DATA:size()-2]   then
				 fromLevel=  Indicator[i].close[Indicator[i].DATA:size()-1];
				 color = Down; 	 
				 else
				 fromLevel=  Indicator[i].close[Indicator[i].DATA:size()-1];
				 color = Neutral; 	
				 end
				 
				                           if fromLevel~= nil  then
				                                local fromDate, toDate;
												id=id+1;
											   fromDate, toDate = core.getcandle( TF[i], date, day_offset, week_offset);
											   core.host:execute ("drawLine", id, fromDate, fromLevel, toDate, fromLevel, color, style[i], widht[i]);
											   id=id+1;
											   core.host:execute("drawLabel1", id,  toDate, core.CR_CHART, fromLevel, core.CR_CHART, core.H_Right, core.V_Bottom,
                                                font1, Label,  string.format("%." .. 5 .. "f", fromLevel ) .. " ("  .. TF[i] ..  ")");
											end	
			 end
												
		 
		 
		end	
 

	 
	  
end


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
 end
   
function Calculation ( i)

        
     
	   
		
			
			--  if Mode[i] == 1 then
				 
			
				--*************************************************************************
				
				local color;
				
				
						Indicator[i]:update(core.UpdateLast);
						
						if not Indicator[i].close:hasData(Indicator[i].DATA:size()-1) then
                        return;
                        end						
				
                     							
							 if Type  == "Instrument" then
						
							  id=id+1;
							
							   core.host:execute("drawLabel1", id, -i*Size*4, core.CR_RIGHT,Size*3+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,TF[i]);
							 
							 
							 elseif Type  == "Frame" then
							
							 
							  id=id+1;
							
							   core.host:execute("drawLabel1", id, -i*Size*4, core.CR_RIGHT,Size*3+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,Pair[i]);
							 
							 else
							 id=id+1;
							  core.host:execute("drawLabel1", id, -i*Size*4, core.CR_RIGHT,Size*3+Shift- Size*2, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label, Pair[i] );
							 id=id+1;
							  core.host:execute("drawLabel1", id, -i*Size*4, core.CR_RIGHT,Size*3+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label, TF[i] );
							 end
							 
						
											   if Indicator[i].close[Indicator[i].DATA:size()-1]   >  Indicator[i].open[Indicator[i].DATA:size()-1] then
												id=id+1;
												core.host:execute("drawLabel1", id, -i*Size*4, core.CR_RIGHT, Size*4+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Up, "\225");
												id=id+1;
													core.host:execute("drawLabel1", id, -i*Size*4, core.CR_RIGHT, Size*5+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Label,  string.format("%." .. 5 .. "f", Indicator[i].close[Indicator[i].DATA:size()-1] ));
											
												color=Up; 
												
												elseif Indicator[i].close[Indicator[i].DATA:size()-1]   <  Indicator[i].open[Indicator[i].DATA:size()-1]  then
												id=id+1;
                                                core.host:execute("drawLabel1", id, -i*Size*4,core.CR_RIGHT, Size*4+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Down, "\226");
												id=id+1;
													core.host:execute("drawLabel1", id, -i*Size*4, core.CR_RIGHT, Size*5+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Label,  string.format("%." .. 5 .. "f", Indicator[i].close[Indicator[i].DATA:size()-1] ));
												
												color=Down;
												else
												id=id+1;	
                                                core.host:execute("drawLabel1", id, -i*Size*4 ,core.CR_RIGHT, Size*4+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Neutral, "\223");	
												id=id+1;
                                                core.host:execute("drawLabel1", id, -i*Size*4, core.CR_RIGHT, Size*5+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Label,  string.format("%." .. 5 .. "f", Indicator[i].close[Indicator[i].DATA:size()-1] ));												
												
												end 		
												
												
											 
									
					 
			
				
				--******************************************************************************
		
		 
				
   
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
	
	 if not loading[5] and not loading[4] and not loading[3] and not loading[2] and not loading[1]
	 then
	 instance:updateFrom(0);
	 end
	 
    return core.ASYNC_REDRAW;
end
