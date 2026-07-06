-- Id: 2995

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3262


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

    
	
	local Filter={};
    local Filtered={};
	local Filtered2={};

	local Cumulativ={};
	local DATA;
	local PAINT;
	
	
function Init()
    indicator:name("Filter");
    indicator:description("Filter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	
   local i, j;
   
   local Filters={"PRICE" , "ROC" , "RSI", "PMA", "MAMA"};
   local iTF={"H1", "D1", "W1", "M1"}
	
	for i = 1, 4, 1 do	
			        indicator.parameters:addGroup( i .. ". Filter");	 
					indicator.parameters:addString("Filter"..i, "Filter", "", Filters[i]);
					for j=1,  #Filters, 1 do
					indicator.parameters:addStringAlternative("Filter"..i, Filters[j] , "", Filters[j]);
					end
					
					indicator.parameters:addString("TF"..i, "Time Frame", "", iTF[i]);
					indicator.parameters:setFlag("TF"..i, core.FLAG_PERIODS);
					
					
					
		
	end	
	
	
	
	
	indicator.parameters:addGroup( "Style");	 
	indicator.parameters:addColor("color", "Color of Label", "", core.rgb(0, 128, 192));
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
	
	
	                indicator.parameters:addGroup( "ROC Option");  
	 for i = 1, 4, 1 do	
                 	
					indicator.parameters:addInteger("ROCFrame"..i, i..". Filter Period", "", 14);					
	end				
	
	           indicator.parameters:addGroup( "RSI Option");		
	for i = 1, 4, 1 do	                
					indicator.parameters:addInteger("RSIFrame"..i, i..". Filter Period", "", 14);	
	end				
	
	           indicator.parameters:addGroup( "PMA Option");		
	for i = 1,4, 1 do	                
					indicator.parameters:addInteger("MAFrame"..i, i..". MA Period", "", 30);	
					indicator.parameters:addString("MAMODE"..i, "Pip/Value", "", "PIP");				
					indicator.parameters:addStringAlternative("MAMODE"..i,"PIP" , "", "PIP");
                    indicator.parameters:addStringAlternative("MAMODE"..i,"Value" , "", "VALUE");		
                    
                   	indicator.parameters:addString("Method"..i, "Method", "Method" , "MVA");
					indicator.parameters:addStringAlternative("Method"..i, "MVA", "MVA" , "MVA");
					indicator.parameters:addStringAlternative("Method"..i, "EMA", "EMA" , "EMA");
					indicator.parameters:addStringAlternative("Method"..i, "LWMA", "LWMA" , "LWMA");
					indicator.parameters:addStringAlternative("Method"..i, "TMA", "TMA" , "TMA");
					indicator.parameters:addStringAlternative("Method"..i, "SMMA", "SMMA" , "SMMA");
					indicator.parameters:addStringAlternative("Method"..i, "KAMA", "KAMA" , "KAMA");
					indicator.parameters:addStringAlternative("Method"..i, "WMA", "WMA" , "WMA");					
	end	
	
	           indicator.parameters:addGroup( "MAMA Option");		
	for i = 1,4, 1 do	                
					indicator.parameters:addInteger("MAMAFrame1"..i, i..". MAMA Period 1.", "", 20);	
					indicator.parameters:addInteger("MAMAFrame2"..i, i..". MAMA Period 2.", "", 50);
					indicator.parameters:addString("MAMAMODE"..i, "Pip/Value", "", "PIP");				
					indicator.parameters:addStringAlternative("MAMAMODE"..i,"PIP" , "", "PIP");
                    indicator.parameters:addStringAlternative("MAMAMODE"..i,"Value" , "", "VALUE");		
                    
                   	indicator.parameters:addString("MethodMAMA1"..i, "Method", "Method" , "MVA");
					indicator.parameters:addStringAlternative("MethodMAMA1"..i, "MVA", "MVA" , "MVA");
					indicator.parameters:addStringAlternative("MethodMAMA1"..i, "EMA", "EMA" , "EMA");
					indicator.parameters:addStringAlternative("MethodMAMA1"..i, "LWMA", "LWMA" , "LWMA");
					indicator.parameters:addStringAlternative("MethodMAMA1"..i, "TMA", "TMA" , "TMA");
					indicator.parameters:addStringAlternative("MethodMAMA1"..i, "SMMA", "SMMA" , "SMMA");
					indicator.parameters:addStringAlternative("MethodMAMA1"..i, "KAMA", "KAMA" , "KAMA");
					indicator.parameters:addStringAlternative("MethodMAMA1"..i, "WMA", "WMA" , "WMA");
                  
                    indicator.parameters:addString("MethodMAMA2"..i, "Method", "Method" , "MVA");
					indicator.parameters:addStringAlternative("MethodMAMA2"..i, "MVA", "MVA" , "MVA");
					indicator.parameters:addStringAlternative("MethodMAMA2"..i, "EMA", "EMA" , "EMA");
					indicator.parameters:addStringAlternative("MethodMAMA2"..i, "LWMA", "LWMA" , "LWMA");
					indicator.parameters:addStringAlternative("MethodMAMA2"..i, "TMA", "TMA" , "TMA");
					indicator.parameters:addStringAlternative("MethodMAMA2"..i, "SMMA", "SMMA" , "SMMA");
					indicator.parameters:addStringAlternative("MethodMAMA2"..i, "KAMA", "KAMA" , "KAMA");
					indicator.parameters:addStringAlternative("MethodMAMA2"..i, "WMA", "WMA" , "WMA");						  
	end	

 
	
end

local Filters={"Select","PRICE" , "ROC" , "RSI", "PMA", "MAMA"};

local MAMAFrame1={};
local MAMAFrame2={};
local MAMAMODE={};

local MethodMAMA1={};
local MethodMAMA2={};

local ROCFrame={};
local RSIFrame={};

local color;

local first;
local source = nil;

local day_offset, week_offset;

local font1;
local font2;

 
local host;

local TF={};

local init = {};


local MAMODE = {};
local MAFrame={};
local Method={};

local Pair, Count,Point;
local loading={};
local stream = {};

local Num=4;

function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();
    end
	
	 
    return list, count,point;
end


local Size;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    color=instance.parameters.color;
    Size=instance.parameters.Size;	
	   local i, j;
      
	
	for i=1, 4, 1 do
	Filter[i] = instance.parameters:getString ("Filter"..i);
	TF[i] = instance.parameters:getString ("TF"..i);
	ROCFrame[i]=instance.parameters:getInteger ("ROCFrame"..i);
    RSIFrame[i]=instance.parameters:getInteger ("RSIFrame"..i);
	MAMODE[i]=instance.parameters:getString("MAMODE"..i);
	MAFrame[i]=instance.parameters:getInteger ("MAFrame"..i);
	Method[i]=instance.parameters:getString ("Method"..i);
	
	  MAMAFrame1[i]=instance.parameters:getInteger ("MAMAFrame1"..i);
      MAMAFrame2[i]=instance.parameters:getInteger ("MAMAFrame2"..i);
      MAMAMODE[i]= instance.parameters:getString ("MAMAMODE"..i);
      MethodMAMA1[i]= instance.parameters:getString ("MethodMAMA1"..i);
      MethodMAMA2[i]= instance.parameters:getString ("MethodMAMA2"..i);
	  
	   if (MAMAFrame2[i] <= MAMAFrame1[i]) then
       error("The short First MAMA period must be smaller than Second MAMA period");
       end
	
	end
	
	assert(core.indicators:findIndicator("MAMA") ~= nil, "Please, download and install MAMA.LUA indicator");   
	
     
	host=   core.host;
    source = instance.source;
    first = source:first();
	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

 
	font1 = core.host:execute("createFont", "Courier", Size, false, false);
    font2 = core.host:execute("createFont", "Courier", Size, false, true);
	
    Pair, Count,Point = getInstrumentList();
	
	local ID=0;
	
	core.host:execute ("removeAll");
	for i = 1,  Count, 1 do 
	stream[i]={};
	loading[i]={};
	Filtered[i]={};
	Filtered2[i]={};
	Cumulativ[i]={};
		for j = 1, 4, 1 do 
		
		  ID=ID+1;

	   stream[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),300 ,20000 + ID , 10000 +ID);
		loading [i][j]=true;
		
		
		
		                  if Filter[j] ~= "Select" then	 	  
					       
							if Filter[j] =="RSI" then
							Filtered[i][j] = core.indicators:create("RSI", stream[i][j].close, RSIFrame[j] );
							end
							if Filter[j] =="ROC" then
							Filtered[i][j] = core.indicators:create("ROC", stream[i][j].close, ROCFrame[j] );
							end
							if Filter[j] =="PRICE" then
							Filtered[i][j] = stream[i][j].close;
							end
							
							if Filter[j] =="PMA" then
    assert(core.indicators:findIndicator(Method[j]) ~= nil, Method[j] .. " indicator must be installed");
							Filtered[i][j] = core.indicators:create(Method[j], stream[i][j].close, MAFrame[j] );
							end
							if Filter[j] =="MAMA" then
    assert(core.indicators:findIndicator(MethodMAMA1[j]) ~= nil, MethodMAMA1[j] .. " indicator must be installed");
							Filtered[i][j] = core.indicators:create(MethodMAMA1[j], stream[i][j].close, MAMAFrame1[j] );
    assert(core.indicators:findIndicator(MethodMAMA2[j]) ~= nil, MethodMAMA2[j] .. " indicator must be installed");
							Filtered2[i][j] = core.indicators:create(MethodMAMA2[j], stream[i][j].close, MAMAFrame2[j] );
							end

					end					
		end			
     end
	 
	 
	 core.host:execute ("setTimer", 1, 5);
end

local  K,L,P; 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	if period ~= source:size() -1 then
	return;
	end
	
	
		 local Loading=false; 
 
	
	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
		
		 
                 if loading [i][j] then
				 Loading= true; 
				 end
		end		 
    end
	
	if Loading then
	return;
	end
	
	
	core.host:execute ("removeAll");

   
	YLabel();

end
function YLabel()
         local i; 
		 
		K=0; 
		L=0;
		P=0;
		i=0; 
		
		core.host:execute ("removeAll");
		
		
		DATA={};
		PAINT={};
		
	    for j= 1, Count, 1 do
		 
		XXX=TEST( j);
		
		
		
		
	              if  XXX== "Long" then		
            		K=K+1;		  
		          core.host:execute("drawLabel1", 400+ j , Size*5, core.CR_LEFT, 0+Size+K*Size, core.CR_TOP, core.H_Center, core.V_Center,  font1, color,  Pair[j] ); 
				  LINE(K, true);
				  end
                  if XXX==  "Short" then	
                  L=L+1;					   
		          core.host:execute("drawLabel1", 200+j,Size*5, core.CR_LEFT, 0+Size+L*Size, core.CR_CENTER, core.H_Center, core.V_Center, font1,color,  Pair[j] );	
                  LINE(L, false);				 
                  end
				  
				  if  XXX== "Neutral" then	
				  P=P+1;					   
		          core.host:execute("drawLabel1", 300+j,Size*5, core.CR_CENTER, 0+Size +P*Size, core.CR_TOP, core.H_Center, core.V_Center, font1,color,  Pair[j] );	
                  LINE(P, "NEUTRAL");				 
				  
                  end
				  
				  
				 
				  
	    end
  
		 XLabel();							    
end
--string.format("%." .. 2 .. "f", DATA[i])
function  LINE(KL, SWITCH)
local i;
local Digit;
		 for i = 1, 4, 1 do 	
		    
			if Filter[i] =="PRICE" then 	
					if DATA[i] > 10 then
					Digit= 2;
					else
					Digit= 4;
					end			
			else
			Digit= 2;
			end
			
	local Label;		
			if PAINT[i] then
			Label =core.rgb(0, 255, 0);
			else
			Label =core.rgb(255, 0, 0);
			end
			
			
            if DATA[i] ~= nil then			
		 
		         if SWITCH == true then
				  core.host:execute("drawLabel1", 10000+ KL*#Filter+ i ,Size*5+(i)*Size*5, core.CR_LEFT, Size+KL*Size, core.CR_TOP, core.H_Center, core.V_Center,  font1, Label,  string.format("%." .. Digit .. "f", DATA[i]) ); 
				 elseif SWITCH == false then 
				 core.host:execute("drawLabel1", 20000+KL*#Filter+ i ,Size*5+(i)*Size*5, core.CR_LEFT, Size+KL*Size, core.CR_CENTER, core.H_Center, core.V_Center, font1,Label,  string.format("%." .. Digit .. "f", DATA[i]) );	
				 elseif  SWITCH ==  "NEUTRAL" then
				 core.host:execute("drawLabel1", 30000+KL*#Filter+ i ,Size*5+(i)*Size*5, core.CR_CENTER,Size+KL*Size, core.CR_TOP, core.H_Center, core.V_Center, font1,Label,  string.format("%." .. Digit .. "f", DATA[i]) );	
				 end		
			end	 
		 end
end

function TEST(j)
      local i;
	  local S=0;
	  local L=0;

 
		
			
		
			for i = 1, 4, 1 do 	
				 
				
						if  Filter[i] ~="PRICE" then
						
						 
						 
						 
								if  Filtered[j][i].DATA:hasData(Filtered[j][i].DATA:size() -1)  then
							  
									if Filter[i] =="RSI" then
											if Filtered[j][i].DATA[Filtered[j][i].DATA:size() -1]  >50 then
											Cumulativ[j][i] = true;
											elseif Filtered[j][i].DATA[Filtered[j][i].DATA:size() -1]  <= 50 then
											Cumulativ[j][i] = false;
											end
											
											DATA[i] = Filtered[j][i].DATA[Filtered[j][i].DATA:size() -1] ;
											
											if Filtered[j][i].DATA[Filtered[j][i].DATA:size() -1] > Filtered[j][i].DATA[Filtered[j][i].DATA:size() -2]then
											PAINT[i]= true;
											else
											PAINT[i]= false;
											end
									end
									if Filter[i] =="ROC" then
											if Filtered[j][i].DATA[Filtered[j][i].DATA:size() -1]  >0 then
											Cumulativ[j][i] = true;
											elseif Filtered[j][i].DATA[Filtered[j][i].DATA:size() -1]  <= 0 then
											Cumulativ[j][i] = false;
											end 
											
											DATA[i] = Filtered[j][i].DATA[Filtered[j][i].DATA:size() -1] ;
											
											if Filtered[j][i].DATA[Filtered[j][i].DATA:size() -1] > Filtered[j][i].DATA[Filtered[j][i].DATA:size() -2]then
											PAINT[i]= true;
											else
											PAINT[i]= false;
											end
									end
								end							
						
						
						else
						if Filter[i] =="PRICE" then
						
						        if  stream[j][i].close:hasData(stream[j][i].close:size()-1)	 then
									if stream[j][i].close[stream[j][i].close:size()-1]  > stream[j][i].open[stream[j][i].open:size()-1] then
									Cumulativ[j][i] = true;
									elseif stream[j][i].close[stream[j][i].close:size()-1]  < stream[j][i].open[stream[j][i].open:size()-1] then
									Cumulativ[j][i] = false;
									end
									
									DATA[i] = stream[j][i].close[stream[j][i].close:size()-1];
									if stream[j][i].close[stream[j][i].close:size()-1] > stream[j][i].open[stream[j][i].open:size()-1] then
									PAINT[i]= true;
									else
									PAINT[i]= false;
									end
							  end
							end  
						end
						
						
						if Filter[i] =="PMA" then
						
						        if  Filtered[j][i].DATA:hasData(Filtered[j][i].DATA:size()-1)	 then
									if Filtered[j][i].DATA[Filtered[j][i].DATA:size()-1]  - stream[j][i].close[stream[j][i].close:size()-1] > 0 then
									Cumulativ[j][i] = true;
									PAINT[i]= true;
									elseif Filtered[j][i].DATA[Filtered[j][i].DATA:size()-1]  - stream[j][i].close[stream[j][i].close:size()-1] < 0  then
									Cumulativ[j][i] = false;
									PAINT[i]= false;
									end
									
									if MAMODE[i] == "PIP" then
									DATA[i] =(Filtered[j][i].DATA[Filtered[j][i].DATA:size()-1]  - stream[j][i].close[stream[j][i].close:size()-1])/stream[j][i]:pipSize();
									else
									DATA[i] = Filtered[j][i].DATA[Filtered[j][i].DATA:size()-1]  - stream[j][i].close[stream[j][i].close:size()-1];
									end
									
							 
							end  
						end
					
						if Filter[i] =="MAMA" then
						         
								  if  Filtered[j][i].DATA:hasData(Filtered[j][i].DATA:size()-1)	and Filtered2[j][i].DATA:hasData(Filtered2[j][i].DATA:size()-1) then
									if Filtered[j][i].DATA[Filtered[j][i].DATA:size()-1]  - Filtered2[j][i].DATA[Filtered2[j][i].DATA:size()-1] > 0 then
									Cumulativ[j][i] = true;
									PAINT[i]= true;
									elseif Filtered[j][i].DATA[Filtered[j][i].DATA:size()-1]  - Filtered2[j][i].DATA[Filtered2[j][i].DATA:size()-1] < 0  then
									Cumulativ[j][i] = false;
									PAINT[i]= false;
									end
									
									if MAMAMODE[i] == "PIP" then
									DATA[i] =(Filtered[j][i].DATA[Filtered[j][i].DATA:size()-1]  - Filtered2[j][i].DATA[Filtered2[j][i].DATA:size()-1])/stream[j][i]:pipSize();
									else
									DATA[i] =Filtered[j][i].DATA[Filtered[j][i].DATA:size()-1]  - Filtered2[j][i].DATA[Filtered2[j][i].DATA:size()-1];
									end
									
							 
							    end    
					  
							
						end	  
				end	 			
		 
			
			L=0;
			S=0;
			
				for i = 1, 4, 1 do 	
				   
				
				  
					
									  
											   if Cumulativ[j][i] == true then
											   L=L+1;
											   end 
											   if Cumulativ[j][i] == false  then
											   S=S+1;
											   end 
											   
										
					 
			    end

                                       if L > 0 and S==0 then
									   return "Long";
									   elseif S> 0 and L==0 then
									   return "Short";
									   elseif S> 0 and L>0 then
									   return "Neutral";
									   end
																
end
                             


function  XLabel  ()
	 	 local i;													   
	    for i= 1, 4, 1 do		 
			 
 
					 core.host:execute("drawLabel1", i+100,Size*5+(i)*Size*5, core.CR_LEFT, Size, core.CR_TOP, core.H_Center, core.V_Center,
											  font1, color, Filter[i] );
											  
					 core.host:execute("drawLabel1", i+50,Size*5+(i)*Size*5, core.CR_LEFT, Size, core.CR_CENTER, core.H_Center, core.V_Center,
											  font1, color, Filter[i] );
											  
					 core.host:execute("drawLabel1", i,Size*5+(i)*Size*5, core.CR_CENTER, Size, core.CR_TOP, core.H_Center, core.V_Center,
											  font1, color, Filter[i] );						  
			       
        end												
													
end



  function ReleaseInstance()
       core.host:execute("deleteFont", font1);   
	    core.host:execute("deleteFont", font2); 
		
	 core.host:execute ("killTimer", 1);
   end  
   
   
 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 local ID=0;
 
		 for i = 1, Count, 1 do	
		     for j = 1, Num, 1 do	
			  ID=ID+1;
			  if cookie == ( 10000 +  ID) then
			  loading[i][j] = true;
		      elseif  cookie == (20000+ ID) then
			  loading[i][j] = false;  
			  end
			  
		       end
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 for j = 1, Num, 1 do

                 if loading [i][j] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end
    end
	
 
	if cookie == 1 
	and FLAG== false 
	then
	     for i = 1, Count, 1 do
			 for j = 1, Num, 1 do
			  
			  
			  
						if  Filter[j] ~="PRICE" then						 
						Filtered[i][j]:update(core.UpdateLast );	
						if Filter[j] =="MAMA" then
						Filtered2[i][j]:update(core.UpdateLast );
						end
						end
						
			 end
		 end
		 
	end
	 
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*Num - Number) .. " / " ..  Count*Num );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	 instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end
   
