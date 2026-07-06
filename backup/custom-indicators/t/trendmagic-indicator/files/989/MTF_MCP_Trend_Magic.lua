-- Id: 5913
-- Id: 5918
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=563&start=10

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
    indicator:name("Multi Time Frame, Multi Currency Pairs Trend Magic");
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
	  indicator.parameters:addInteger("Size", "Font Size", "", 20, 0 , 100);
	 
	  indicator.parameters:addString("Style", "Display Mode", "", "Simple");
    indicator.parameters:addStringAlternative("Style", "Simple", "", "Simple");
    indicator.parameters:addStringAlternative("Style", "Advanced", "", "Advanced");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up colo", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Down color", "", core.rgb(255, 0, 0));	
    indicator.parameters:addColor("NE", "Neutral color", "", core.rgb(255, 0, 0));		
    indicator.parameters:addColor("LABEL", "Label color", "", core.COLOR_LABEL);
end


function Parameters (id , FRAME , DEFAULT )
    indicator.parameters:addGroup(id ..". DMI Calculation");
	indicator.parameters:addBoolean("ON"..id, "Use This TimeFrame", "", true);
   
    indicator.parameters:addInteger("CCI"..id, "CCI", "", 50);
    indicator.parameters:addInteger("ATR"..id, "ATR", "", 5);
   
   
	
	indicator.parameters:addString("INSTRUMENT"..id, "Instrumet", "", "");
    indicator.parameters:setFlag("INSTRUMENT"..id, core.FLAG_INSTRUMENTS );
   
    indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end


local Lock;
local Type;

local source;
local day_offset, week_offset;
local host;
local first;

local INSTRUMENT={};
local Label={};
local FRAME={};
local  FrameLabel={};

local ON={};
local Position;
local font1;
local font2;
local COUNT=0;
local LABEL;
local Size;
local Style;

local CCI={};
local ATR={};
local TMI={};
local Number=5;

local Source={};
local loading={};
function Prepare(nameOnly) 
    Size=instance.parameters.Size;
    Style=instance.parameters.Style;
    LABEL=instance.parameters.LABEL;
    Position=instance.parameters.Position;  
    Lock=instance.parameters.Lock;
	Type=instance.parameters.Type;
    source = instance.source;
	first= source:first();
    host = core.host;	
	 
     local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
	 instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	local i;
   assert(core.indicators:findIndicator("TMI") ~= nil, "Please, download and install TMI.LUA indicator");
	
	for i = 1 , 5 , 1 do    
	
	
	   ON[i]=instance.parameters:getBoolean ("ON"..i)
	   
	   if ON[i] then
				   COUNT= COUNT+1;
				   
				   
				  CCI[COUNT]= instance.parameters:getInteger ("CCI"..i);
				  ATR[COUNT]= instance.parameters:getInteger ("ATR"..i);
				   
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
	 font3 = core.host:execute("createFont", "Arial", Size, true, true);

	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset"); 
	
	local x=0;
    for i = 1, Number, 1 do
	x=x+1;
		 
	
	Source[i] = core.host:execute("getSyncHistory",INSTRUMENT[i], FRAME[i], source:isBid(), math.min(300,math.max(CCI[i], ATR[i])), 200+x, 100+x);	 
	loading[i]= true;
	
		TMI[i] = core.indicators:create("TMI", Source[i] ,CCI[i],  ATR[i],  core.rgb(0, 255, 0),  core.rgb(255, 0, 0));
	end
	

end


function Update(period, mode)



 if  period < source:size() - 1 then	
 return;
 end
 
	local i;
	 
	
	local id= 1;

	for i = 1, COUNT, 1  do

				TMI[i]:update(mode);
				if TMI[i].DATA:hasData(TMI[i].DATA:size()-1)  and TMI[i].DATA:hasData(TMI[i].DATA:size()-2)then					

						
                  													
						           
								   local Color1, Color2;
								   if TMI[i].DATA:colorI(TMI[i].DATA:size()-1) ==  core.rgb(0, 255, 0) then
								    Color1 = 	 instance.parameters.UP;
									
					                elseif TMI[i].DATA:colorI(TMI[i].DATA:size()-1) ==  core.rgb(255, 0, 0) then
									Color1 = 	 instance.parameters.DN	;
                                   								
						 			else
									Color1 = 	 instance.parameters.NE	;	
							  								   
								   end 		
								   
								 								   
								   local Symbol;
								   
								   if TMI[i].DATA[TMI[i].DATA:size()-1] > TMI[i].DATA[TMI[i].DATA:size()-2] then
								   Symbol= "+"
								   elseif TMI[i].DATA[TMI[i].DATA:size()-1] < TMI[i].DATA[TMI[i].DATA:size()-2] then
								    Symbol= "-"
								   else
								   Symbol= "o"
								   end
								   
								    
									

								
								   
								      core.host:execute("drawLabel1", id, -(Size*5)*(i+1), core.CR_BOTTOM , Position+  Size*1,core.CR_LEFT  , core.H_Right , core.H_Center, font1, LABEL, FrameLabel[i] );
								   id = id + 1;
								   
								     core.host:execute("drawLabel1", id, -(Size*5)*(i+1), core.CR_BOTTOM ,  Position+ Size*2,core.CR_LEFT  , core.H_Right , core.H_Center, font1, LABEL, Label[i] );
								   id = id + 1;
								   
								  
									
                                 if Style == "Simple" then
								    if Symbol== "+" then
								       core.host:execute("drawLabel1", id, -(Size*5)*(i+1) , core.CR_BOTTOM ,  Position+ Size*3,core.CR_LEFT  , core.H_Right , core.H_Center, font3, Color1, Symbol );
								      id = id + 1;
									 else 
									  
									   core.host:execute("drawLabel1", id, (Size*5)*(i+1) , core.CR_BOTTOM ,  Position+ Size*3,core.CR_LEFT  , core.H_Right , core.H_Center, font3, Color1, Symbol );
								      id = id + 1;
								     end
                                 else
								    
									if Symbol== "+" then
																   
											core.host:execute("drawLabel1", id, -(Size*5)*(i+1), core.CR_BOTTOM , Position+ Size*3,core.CR_LEFT  , core.H_Right , core.H_Center, font1, Color1,tostring( "TMI ".. round(TMI[i].DATA[TMI[i].DATA:size()-1], 4)) );
																													
										   id = id + 1;
										   						   
										
									else	   
									     
										  core.host:execute("drawLabel1", id, -(Size*5)*(i+1), core.CR_BOTTOM , Position+ Size*3,core.CR_LEFT  , core.H_Right , core.H_Center, font1, Color1,tostring( "TMI ".. round(TMI[i].DATA[TMI[i].DATA:size()-1], 4)) );
																													
										   id = id + 1;
										   						   
										
								   
								    end  								 
							end		

				end
			end
		
		 
	  
	

end
 
 
 
 -- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = true;	
	local Count=0;	
	
	
	    local x=0;
		
    for j = 1, Number, 1 do
		x=x+1;
			  if cookie == (100+x) then
			  loading[j] = true;
		      elseif  cookie == (200+x) then
			  loading[j] = false;			  		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=false;
		end	 

		  
		
	end    
	
	    if Flag then
		core.host:execute ("setStatus", " ");
		instance:updateFrom(0);
		else
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		end
			     
        
		return core.ASYNC_REDRAW ;
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
  
  end
