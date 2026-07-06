-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=277

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("MTF MCP Vortex List");
    indicator:description("MTF MCP Vortex List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m1" ,false );
	Parameters (2 , "m15" ,false );
	Parameters (3 , "m30" ,false );
	Parameters (4 , "H1" ,true  );
	Parameters (5 , "H2" ,false  );
	Parameters (6 , "H3",false   );
	Parameters (7 , "H4",false   );
	Parameters (8 , "H8",false   );
	Parameters (9 , "D1",true   );
	Parameters (10 , "W1",true  );	
	Parameters (11 , "M1",true  );
	
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME , ItIs)
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", ItIs);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
    indicator.parameters:addInteger("Period"..id, "Period", "", 14);
   
	
	indicator.parameters:addString("Type"..id, "Indicaton Type", "", "Numeric");
    indicator.parameters:addStringAlternative("Type"..id, "Numeric", "", "Numeric");
    indicator.parameters:addStringAlternative("Type"..id, "Trend", "", "Trend");

	
end

local loading={};
local SourceData={};
local Indicator={};
local Pair;
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first={};
local Test={};
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num;
local Period={};
local Type={};
local timer;
function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		core.host:execute ("killTimer", 1);
 end  

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    
	Shift=instance.parameters.Shift; 
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
   
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
	 
	 Pair, Count = getInstrumentList();
	  

	Num=0;
	
	for i = 1 , 11 , 1 do   
	
 
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   Num = Num+1;
	   Period[Num]=  instance.parameters:getInteger ("Period"..i);
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Type[Num]=  instance.parameters:getString ("Type"..i);
			  
			   Test[Num] =   core.indicators:create("VORTEX", source, Period[Num]) ; 
	           first[Num]= Test[Num]:getStream(0):first() ;	
			    
	
	  end
	end	
 
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	assert(core.indicators:findIndicator("VORTEX") ~= nil, "Please, download and install VORTEX.LUA indicator");	
	

	
	
		
	local ID=0;
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};			 
             loading[j] = {};			
			 Indicator[j] = {};
			 
			
	   
	   
		 for i = 1, Num, 1 do		 
		       ID=ID+1;
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(),math.min(300, first[i]) , 2000 + ID , 1000 + ID);
			   loading[j][i] = true;  
			  			   
			   Indicator[j][i] =  core.indicators:create("VORTEX",  SourceData[j][i], Period[i]) ; 
			  

		end
	end
    
    core.host:execute("setTimer", 1, 1);
	 
end




function Update(period)


			
			
    
end

function DrawLabels()

local i, j;
local id=1;
 
for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*1.1*5+(i)*Size*1.1*5 ,  core.CR_LEFT, Size*1.1*3  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*1.1*5 ,  core.CR_LEFT,Size*1.1*4+(j-1)* Size*1.1*2 +Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				--Size*1.1*5+(i)*Size*1.1*10
 
	
	for i = 1, Num, 1  do
--close
				
				
				
				
			 	 if  Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-1) and Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-2) then	
                    		

						local Color1 =nil;			
						local Style1 = nil 
						local Color2 =nil;			
						local Style2 = nil 
						local Font=nil;
						
						Style1 = Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1];	
                        Style2 = Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1];						

						 if Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] >  Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2] then
										
											
											Color1 = Up;
											Style1= "\225";
						elseif Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] <  Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2] then
											
											  Color1 = Down;									
												Style1= "\226";	
												
						 else				
                                              Style1= "\158";							 
											 Color1 = No;
						 end 		

                           if Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] >  Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-2] then
										
											
											Color2 = Up;
											Style2= "\225";
						elseif Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] <  Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-2] then
											
											  Color2 = Down;									
												Style2= "\226";	
												
						 else				
                                              Style2= "\158";							 
											 Color2 = No;
						 end 							 

						 
						 
                        if Type[i]~= "Trend" then
						Font= font;	
						Style1=   string.format("%." .. 5 .. "f", Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] );   
						Style2=  string.format("%." .. 5 .. "f", Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] );  
						else
						Font= Wingdings;						
                        end				

                  						
						
						
						if Style1 ~= nil then
						core.host:execute("drawLabel1", id,  Size*1.1*5+(i)*Size*1.1*5 ,  core.CR_LEFT, Size*1.1*4+(j-1)* Size*1.1*2 +Shift    , core.CR_TOP, core.H_Left, core.V_Center, Font, Color1,  Style1 );			  
						id = id+1;
						
						end
						
						if Style2 ~= nil then
						core.host:execute("drawLabel1", id, Size*1.1*5+(i)*Size*1.1*5 ,  core.CR_LEFT,  Size*1.1*5+(j-1)* Size*1.1*2 +Shift   , core.CR_TOP, core.H_Left, core.V_Center, Font, Color2,    Style2 );			  
						id = id+1;
					
						end

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


local ID=0;

    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		      ID=ID+1;
			  if cookie == (1000 + ID) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + ID) then
			  loading[j][i] = false;            
			
			  
			  end
		       
          end
	end    
	
	
	
    local FLAG=false;
			
			local i,j;
			local id =1;
			local Number=0;
			
			for j = 1, Count, 1 do
				 for i = 1, Num, 1 do	

						 if loading[j][i] then
						 FLAG= true;
						 Number=Number+1;
						 end
				 
				 end  	
			end
			
	
           if cookie == 1 and not FLAG then
	
	        for j = 1, Count, 1 do
				 for i = 1, Num, 1 do	

						  
						  Indicator[j][i]:update(core.UpdateLast);
					 
				 
				 end  	
			end
	  
	  
	       DrawLabels();
		   
		    
		   end
	  
			
			if FLAG then
			 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );
			else
			 core.host:execute ("setStatus", " " );
			 instance:updateFrom(0);
			end
			
          
 
   
        
    return core.ASYNC_REDRAW ;
end



