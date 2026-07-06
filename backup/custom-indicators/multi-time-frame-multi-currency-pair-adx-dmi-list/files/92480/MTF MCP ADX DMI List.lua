-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60275

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
    indicator:name("Multi Time Frame, Multi Currency Pair, ADX/DMI List");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	
	Parameters (1 , "m1", false );
	Parameters (2 , "m5", false  );
	Parameters (3 , "m15", false   );
	Parameters (4 , "m30", false  );
	Parameters (5 , "H1", true    );
    Parameters (6 , "H2", false  );
	Parameters (7 , "H3", false   );
	Parameters (8 , "H4", false  );
	Parameters (9 , "H6", false    );
	Parameters (10 , "H8", true   );
	Parameters (11 , "D1", true  );
	Parameters (12 , "W1", false    );
	Parameters (13 , "M1", false    );
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "OB Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "OS Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(128, 128, 128));
end


function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);

	indicator.parameters:addDouble("ADXLevel"..id, "ADX Level", "", 20);
   indicator.parameters:addInteger("ADXPeriod"..id, "ADX Period", "", 14);
   indicator.parameters:addInteger("DMIPeriod"..id, "SMI Period", "", 14);

	
end

local loading={};
local SourceData={};
local ADX={};
local DMI={};
local Pair;
local Font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first;
local Test;
local Count=13;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num;
local Type;
local ADXLevel={};
local ADXPeriod={};
local DMIPeriod={};
function ReleaseInstance()
       core.host:execute("deleteFont", Font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

function Prepare(nameOnly)
   
	Shift=instance.parameters.Shift 
    source = instance.source;	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
		
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
	 
	 Pair, Count = getInstrumentList();
	 

	Num=0;
	
	
	
	for i = 1 ,13 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   ADXLevel[Num]=  instance.parameters:getDouble ("ADXLevel"..i);
       ADXPeriod[Num]=  instance.parameters:getInteger ("ADXPeriod"..i);
	 
	  DMIPeriod[Num]=  instance.parameters:getInteger ("DMIPeriod"..i);
	 


	  
	
	  end
	end	

	
		
   	
	Font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	  core.host:execute ("setTimer", 1, 1);
	
	 
	
	
  local ID=0;
	
	for j = 1, Count, 1 do
	
	
	
	         SourceData[j] = {};
			 ADX[j] = {};
             DMI[j] = {};			 
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		 
		      ID=ID+1;
		 
		      Test1 = core.indicators:create("ADX", source ,ADXPeriod[i]);   
			  Test2 = core.indicators:create("DMI", source ,DMIPeriod[i]); 
	          first= math.max(Test1.DATA:first(),Test2.DATA:first()) *2;
		 
		 			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300,first) , 2000 + ID , 1000 + ID);
			   loading[j][i] = true;  
			  
			   ADX[j][i] = core.indicators:create("ADX", SourceData[j][i],ADXPeriod[i]);
               DMI[j][i] = core.indicators:create("DMI", SourceData[j][i],DMIPeriod[i]);    
             			  
			  
		end
	end
    
	
	
	 core.host:execute("setTimer", 1, 1);
	 
end




function Update(period, mode)

core.host:execute ("setStatus", "")


 if period < source:size()-1 then
 return
 end
 
	local i,j;
	local id =1;
	local FLAG=false; 
	local Number=0;
	local font;
 	
	
	

	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if FLAG then
	return;
	end
 


  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*10+(i-1)*Size*3 ,  core.CR_LEFT, Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*5 ,  core.CR_LEFT, Size*2+(j)*Size*2+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do

				
				--DMI[j][i]:update(core.UpdateLast);
				--ADX[j][i]:update(core.UpdateLast);
				local Color =No;			
				local Style = "\158" 
				 
				 
				if  ADX[j][i].DATA:hasData(ADX[j][i].DATA:size()-1) and  ADX[j][i].DATA:hasData(ADX[j][i].DATA:size()-2)and DMI[j][i].DATA:hasData(DMI[j][i].DATA:size()-1) then					
                       
					 	
						
                       
						
               		   

						 if ADX[j][i].DATA[ADX[j][i].DATA:size()-1] >  ADXLevel[i] 
						and  ADX[j][i].DATA[ADX[j][i].DATA:size()-1] > ADX[j][i].DATA[ADX[j][i].DATA:size()-2]
						and DMI[j][i].DIP[DMI[j][i].DIP:size()-1] >  DMI[j][i].DIM[DMI[j][i].DIM:size()-1] 
						 then
										
											
											Color = Up;
									         Style= "\225";
											
										
						elseif ADX[j][i].DATA[ADX[j][i].DATA:size()-1] >  ADXLevel[i] 
						and ADX[j][i].DATA[ADX[j][i].DATA:size()-1] > ADX[j][i].DATA[ADX[j][i].DATA:size()-2]
						and  DMI[j][i].DIP[DMI[j][i].DIP:size()-1] <  DMI[j][i].DIM[DMI[j][i].DIM:size()-1] 
						then
											
											  Color = Down;	
                                             Style= "\226"; 
                                
												
						 else				
                                           					 
											 Color = No;
											 Style = "\158";
										
						 end 		
						 
						 
						 
							


						
						if Style ~= nil then
						core.host:execute("drawLabel1", id, Size*10+(i-1)*Size*3,  core.CR_LEFT, Size*2+(j)*Size*2 +Shift , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color,  Style );			  
						id = id+1;
						end 
                else
				
				       	core.host:execute("drawLabel1", id, Size*10+(i-1)*Size*3,  core.CR_LEFT, Size*2+(j)*Size*2+Shift , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color,  Style );			  
						id = id+1;
				
				end
				 
				end
        end
    
end




function getInstrumentList()
    local list={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

	
	local i,j;
     local ID=0;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		    ID=ID+1;
		  
			  if cookie == (1000 +  ID) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 +ID) then
			  loading[j][i] = false;            
		
			  
			  end
		       
          end
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	if not FLAG and cookie== 1 then
	            
			for j = 1, Count, 1 do
				 for i = 1, Num, 1 do	
						DMI[j][i]:update(core.UpdateLast);
						ADX[j][i]:update(core.UpdateLast);
						
			end
			end
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	else
		  instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end
 
