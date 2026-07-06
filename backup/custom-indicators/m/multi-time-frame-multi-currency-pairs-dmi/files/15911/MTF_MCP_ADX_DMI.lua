-- Id: 4738

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5190

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+


function Init()
    indicator:name("Multi Time Frame, Multi Currency Pairs ADX/DMI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   
	
	 indicator.parameters:addBoolean("Lock", "Lock", "", false);
	 
	 indicator.parameters:addString("Type", "Lock Type", "", "Frame");
    indicator.parameters:addStringAlternative("Type", "Time Frame", "", "Frame");
    indicator.parameters:addStringAlternative("Type", "Instrument", "", "Instrument");
   
	
	Parameters (1 , "m30");
	Parameters (2 , "H1" );
	Parameters (3 , "H4" );
	Parameters (4 , "H8" );
	Parameters (5 , "D1"  );
	
		indicator.parameters:addGroup("Common Parameters");	
	 indicator.parameters:addInteger("Position", "Vertical Position", "", 0, 0 , 500);
	  indicator.parameters:addInteger("Size", "Font Size", "", 10, 0 , 100);
	   indicator.parameters:addInteger("Level", "ADX Level", "", 25, 0 , 100);
	 
	 
	  indicator.parameters:addString("Style", "Display Mode", "", "Simple");
    indicator.parameters:addStringAlternative("Style", "Simple", "", "Simple");
    indicator.parameters:addStringAlternative("Style", "Advanced", "", "Advanced");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "DMI Up color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "DMI Down color", "", core.rgb(255, 0, 0));	
    indicator.parameters:addColor("NE", "DMI Neutral color", "", core.rgb(255, 0, 0));		
	
	indicator.parameters:addColor("ADXStrong", "ADX Strong color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("ADXWeak", "ADX Weak color", "", core.rgb(255, 0, 0));	 
	
    indicator.parameters:addColor("LABEL", "Label color", "", core.COLOR_LABEL);
end


function Parameters (id , FRAME , DEFAULT )
    indicator.parameters:addGroup(id ..". DMI Calculation");
	indicator.parameters:addBoolean("ON"..id, "Use This TimeFrame", "", true);
    indicator.parameters:addInteger("N"..id, "DMI Periods", "", 14);
	 indicator.parameters:addInteger("M"..id, "ADX Periods", "", 14);
	
	indicator.parameters:addString("INSTRUMENT"..id, "Instrumet", "", "");
    indicator.parameters:setFlag("INSTRUMENT"..id, core.FLAG_INSTRUMENTS );
   
    indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end


local Lock;
local Type;

local source;
local ADX={};
local DMI = {};
local day_offset, week_offset;
 local loading={};
local stream={};
local host;
local first;

local INSTRUMENT={};
local Label={};
local FRAME={};
local  FrameLabel={};

local Level;

local ON={};
local Position;
local font1;
local font2;
local COUNT=0;
local LABEL;
local Size;
local Style;

local  ADXStrong;
local  ADXWeak;

local PERIOD={};
local ADXPERIOD={};
local Number;
function Prepare(nameOnly)   
    ADXStrong=instance.parameters.ADXStrong;
    ADXWeak=instance.parameters.ADXWeak;
    Level=instance.parameters.Level;
    Size=instance.parameters.Size;
    Style=instance.parameters.Style;
    LABEL=instance.parameters.LABEL;
    Position=instance.parameters.Position;  
    Lock=instance.parameters.Lock;
	Type=instance.parameters.Type;
    source = instance.source;
	first= source:first();
    host = core.host;	
	 
    local name =  profile:id() .. ","  .. instance.source:name() ;
	
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	local i;
   
	
	for i = 1 , 5 , 1 do    
	
	
	   ON[i]=instance.parameters:getBoolean ("ON"..i)
	   
	   if ON[i] then
				   COUNT= COUNT+1;
				   
				   
				   PERIOD[COUNT]= instance.parameters:getInteger ("N"..i);
				   ADXPERIOD[COUNT]= instance.parameters:getInteger ("M"..i);
				   
					 if instance.parameters:getString ("INSTRUMENT"..i) == "" then
					  INSTRUMENT[COUNT]= source:instrument();
				  else
				  INSTRUMENT[COUNT] = instance.parameters:getString ("INSTRUMENT"..i);
				  end
				
				   if Lock and  Type=="Instrument" then
				   INSTRUMENT[COUNT] = INSTRUMENT[1];
				   else
				   INSTRUMENT[COUNT] = INSTRUMENT[COUNT];
				   end
				   
					if Lock and  Type=="Instrument" and i ~= 1 then
					Label[COUNT]="";		  
					else
					 Label[COUNT]=INSTRUMENT[COUNT];
					end

						
				  
				   FRAME[COUNT]=  instance.parameters:getString ("B"..i);
				  
				  if Lock and  Type=="Frame" then
				  FRAME[COUNT]	= FRAME[1];		   
				  end
				  
				   if Lock and  Type=="Frame" and i ~= 1 then
					FrameLabel[COUNT]="";		  
					else
					 FrameLabel[COUNT]=FRAME[COUNT];
					end 	
				 
	   
	   
	   
	   end
	
	 
	  
   
	end	
	
	
	
	font2= core.host:execute("createFont", "Wingdings", Size, false, false);
	 font1 = core.host:execute("createFont", "Arial", Size, false, false);
	 font3 = core.host:execute("createFont", "Arial", Size*3, true, true);

	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset"); 
	
             for i = 1, COUNT, 1  do				  
			stream[i]  = core.host:execute("getSyncHistory", INSTRUMENT[i], FRAME[i], source:isBid(),math.min(300, math.max(ADXPERIOD[i]*2,PERIOD[i]*2 )), 2000 + i , 1000 +i);	 	 
			loading[i]  = true;  
			ADX[i] = core.indicators:create("ADX", stream[i], ADXPERIOD[i]);
			DMI[i] = core.indicators:create("DMI", stream[i], PERIOD[i]);
			end
			
			Number=COUNT;
			
			core.host:execute ("setTimer", 1, 1);
end


function Update(period, mode)


 if   period < source:size()-1 then
 return;
 end
 
 
 
	
	local id= 1;

	for i = 1, COUNT, 1  do
 
				
				if DMI[i].DATA:hasData(DMI[i].DATA:size()-1)  and DMI[i].DATA:hasData(DMI[i].DATA:size()-2)and ADX[i].DATA:hasData(ADX[i].DATA:size()-1)  and ADX[i].DATA:hasData(ADX[i].DATA:size()-2)then					

			 
                  													
						           
								   local Color1, Color2;
								   if DMI[i].DIP[DMI[i].DIP:size()-1] > DMI[i].DIP[DMI[i].DIP:size()-2] then
								    Color1 = 	 instance.parameters.UP;
									
					                elseif DMI[i].DIP[DMI[i].DIP:size()-1] < DMI[i].DIP[DMI[i].DIP:size()-2] then
									Color1 = 	 instance.parameters.DN	;
                                   								
						 			else
									Color1 = 	 instance.parameters.NE	;	
							  								   
								   end 		
								   
								    if DMI[i].DIM[DMI[i].DIM:size()-1] > DMI[i].DIM[DMI[i].DIM:size()-2] then
								    Color2 = 	 instance.parameters.UP;
									
					                elseif DMI[i].DIM[DMI[i].DIM:size()-1] < DMI[i].DIM[DMI[i].DIM:size()-2] then
									Color2 = 	 instance.parameters.DN	;
                                   								
						 			else
									Color2 = 	 instance.parameters.NE	;	
							  								   
								   end 	
								   
								   local Symbol;
								   
								   if DMI[i].DIP[DMI[i].DIP:size()-1] > DMI[i].DIM[DMI[i].DIM:size()-1] then
								   Symbol= "+"
								   else
								   Symbol= "-"
								   end
								   
								    
									

								
								   
								      core.host:execute("drawLabel1", id, -Size*5*i, core.CR_BOTTOM ,Size+ Position+  Size,core.CR_LEFT  , core.H_Right , core.H_Center, font1, LABEL, FrameLabel[i] );
								   id = id + 1;
								   
								     core.host:execute("drawLabel1", id, -Size*5*i, core.CR_BOTTOM , Size+ Position+ Size*2,core.CR_LEFT  , core.H_Right , core.H_Center, font1, LABEL, Label[i] );
								   id = id + 1;
								   
								   local  Trend;								
									
									
									if ADX[i].DATA[ADX[i].DATA:size()-1] > Level then
								   Trend = "Strong";
								   else
								   Trend=  "Weak";
								   end
									 
									 
									local ADXColor; 
									
									
									if ADX[i].DATA[ADX[i].DATA:size()-1] > ADX[i].DATA[ADX[i].DATA:size()-2] then
									ADXColor= ADXStrong;
									else
									ADXColor= ADXWeak;
									end
									
                                 if Style == "Simple" then
								 
								        core.host:execute("drawLabel1", 10000, -Size*30 , core.CR_BOTTOM , Size+ Position+ Size*3 ,core.CR_LEFT  , core.H_Right , core.H_Center, font1, LABEL, "DMI" );
								 
								    if Symbol== "+" then
								       core.host:execute("drawLabel1", id, -Size*5*i , core.CR_BOTTOM , Size+ Position+ Size*3,core.CR_LEFT  , core.H_Right , core.H_Center, font3, Color1, Symbol );
								      id = id + 1;
									 else 
									  
									   core.host:execute("drawLabel1", id, -Size*5*i , core.CR_BOTTOM ,  Size+Position+ Size*3,core.CR_LEFT  , core.H_Right , core.H_Center, font3, Color2, Symbol );
								      id = id + 1;
								     end
									 
									
									    core.host:execute("drawLabel1", 10001, -Size*30 , core.CR_BOTTOM , Size+ Position+ Size*4 ,core.CR_LEFT  , core.H_Right , core.H_Center, font1, LABEL, "ADX" );
									   core.host:execute("drawLabel1", 100000+id,  -Size*5*i  , core.CR_BOTTOM ,  Size+Position+ Size*4 ,core.CR_LEFT  , core.H_Right , core.H_Center, font1, ADXColor, Trend );
									 
									 
                                 else
								 
								 
								             core.host:execute("drawLabel1", 10001, -Size*30 , core.CR_BOTTOM ,  Size+Position+ Size*5 ,core.CR_LEFT  , core.H_Right , core.H_Center, font1, LABEL, "ADX" );
									   core.host:execute("drawLabel1", 100000+id,  -Size*5*i  , core.CR_BOTTOM , Size+ Position+ Size*5 ,core.CR_LEFT  , core.H_Right , core.H_Center, font1, ADXColor,   tostring(  round(ADX[i].DATA[ADX[i].DATA:size()-1], 4))  );
								 
								 
								        core.host:execute("drawLabel1", 10000, -Size*30 , core.CR_BOTTOM , Size+ Position+ Size*4,core.CR_LEFT  , core.H_Right , core.H_Center, font1, LABEL, "DMI" );
								    
									if Symbol== "+" then
																   
											core.host:execute("drawLabel1", id, -Size*5*i, core.CR_BOTTOM ,Size+ Position+ Size*3,core.CR_LEFT  , core.H_Right , core.H_Center, font1, Color1,tostring( "DIP ".. round(DMI[i].DIP[DMI[i].DIP:size()-1], 4)) );
																													
										   id = id + 1;
										   						   
											core.host:execute("drawLabel1", id, -Size*5*i, core.CR_BOTTOM ,Size+ Position+ Size*4,core.CR_LEFT  , core.H_Right , core.H_Center, font1, Color2,tostring( "DIM ".. round(DMI[i].DIM[DMI[i].DIM:size()-1], 4)) );
																													
										   id = id + 1;
										   
									else	   
									     
										  core.host:execute("drawLabel1", id, -Size*5*i, core.CR_BOTTOM ,Size+ Position+ Size*3,core.CR_LEFT  , core.H_Right , core.H_Center, font1, Color2,tostring( "DIM ".. round(DMI[i].DIM[DMI[i].DIM:size()-1], 4)) );
																													
										   id = id + 1;
										   						   
											core.host:execute("drawLabel1", id, -Size*5*i, core.CR_BOTTOM ,Size+ Position+ Size*4,core.CR_LEFT  , core.H_Right , core.H_Center, font1, Color1,tostring( "DIP ".. round(DMI[i].DIP[DMI[i].DIP:size()-1], 4)) );
																													
										   id = id + 1;
								   
								    end  								 
							end		

				end
		 
		
	end
	 
	  
	end
 

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function ReleaseInstance()

       core.host:execute("deleteFont", font1); 
       core.host:execute("deleteFont", font2);  	
        core.host:execute("deleteFont", font3); 
core.host:execute ("killTimer", 1);		
  
  end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 

local j;
local FLAG=false; 
local Num=0;
local Id=0;
    for j = 1, Number, 1 do
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j]  = false;
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
    
   if not FLAG and cookie== 1 then
		for i= 1, Number , 1 do
			  ADX[i]:update(core.UpdateLast );
			  DMI[i]:update(core.UpdateLast );
		end
		
	end
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");	 
    instance:updateFrom(0);    
	end
	
	
   
        
    return core.ASYNC_REDRAW ;
	
	
end

