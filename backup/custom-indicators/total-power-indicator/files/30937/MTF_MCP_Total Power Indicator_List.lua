-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6307
-- Id: 6408

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("MTF_MCP_Total Power Indicator_List");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m30"  );
	Parameters (2 , "H1"  );
	Parameters (3 , "H4" );
	Parameters (4 , "H8"   );
	Parameters (5 , "D1"  );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addString("Type", "Display Style", "", "Simple");
    indicator.parameters:addStringAlternative("Type", "Simple", "", "Simple");
    indicator.parameters:addStringAlternative("Type", "Advanced", "", "Advanced");
end


function Parameters (id , FRAME , DEFAULT )
    indicator.parameters:addGroup(id ..". Time Frame Calculation");
		
	indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
	
	indicator.parameters:addInteger("LB"..id, "Lookback Period", "Lookback Period", 40);
    indicator.parameters:addInteger("PP"..id, "Power Period", "Power Period", 10);
end


local font, Wingdings, Bold;
local  Size;
local source;
local TP=nil;
local day_offset, week_offset;
local stream;
local FRAME={};
local host;
local first;
local TEMP={};
local timer;
local Count;
local Up, Down, No, LabelColor;
local INSTRUMENT;
local LB={};
local PP={};
local Type;
local loading={};
local Num=5;
local offset,weekoffset;
local p={};
function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
 end  

function Prepare(nameOnly)      
	
    source = instance.source;
	
	host=core.host;	
	offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	 
  
	Type=instance.parameters.Type;
    Size=instance.parameters.ArrowSize;   
    local name =  profile:id()  ;
	
	local i;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;

	
	for i = 1 , Num , 1 do   
	   FRAME[i]=  instance.parameters:getString ("B"..i);
	    LB[i]=instance.parameters:getInteger ("LB"..i);
	    PP[i]=instance.parameters:getInteger ("PP"..i);
	 
	  
      name = name..", ("  .. LB[i].. ", " .. PP[i]   .. ")";      
	end	
	
	instance:name(name);
	if nameOnly then
		return;
	end
	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset"); 
	
		
   INSTRUMENT, Count = getInstrumentList();
  

	
	local i,j; 
	TP = {};
    stream={};
	
	for j = 1, Count, 1 do
	 
			stream[j] = {};
			TP[j] = {};	
            loading[j] = {};				
		    p[j]={};
	end

	local Temp;
	
	local ID=0;
	for j = 1, Count, 1 do
		for i = 1, Num , 1 do	 
		
		    ID=ID+1;
			
    assert(core.indicators:findIndicator("TOTAL POWER INDICATOR") ~= nil, "TOTAL POWER INDICATOR" .. " indicator must be installed");
			 Test = core.indicators:create("TOTAL POWER INDICATOR",  source, LB[i], PP[i]);   
	          first=math.max( Test:getStream(0):first() , Test:getStream(1):first(), Test:getStream(2):first());
		
			stream[j][i]= core.host:execute("getSyncHistory", INSTRUMENT[j], FRAME[i], source:isBid(), math.min(300,first*2), 2000 +ID, 1000 + ID);
			TP[j][i] = core.indicators:create("TOTAL POWER INDICATOR", stream[j][i], LB[i], PP[i]);
			loading[j][i] = true;  
			
		end
	
	
  end
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	

	
	-- timer = core.host:execute("setTimer", 1, 1);
end

 

function   Initialization(period,id1, id2)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[id1][id2] or stream[id1][id2]:size() == 0  then
        return false;
    end
 
    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(stream[id1][id2], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	



function Update(period, mode)

 if  period < source:size()-1 then
 return
 end
 
 
 	local FLAG=false; 
	local Number=0;
	local Font=font;
 	
	
	

	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		          
				 p[j][i]= Initialization(period,j,i)
				 
				 if  p[j][i]== false then  
				  FLAG= true;
				 end
				 
         end  	 
    end
	
	if FLAG then
	return;
	end
 
 
 
 for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
        	TP[j][i]:update(mode);
         end
 end
 
 
   local i,j;
	local id =0;
  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, 150+(i-1)*100 ,  core.CR_LEFT, 40  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  FRAME[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, 100 ,  core.CR_LEFT, 60+(j-1)*15  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  INSTRUMENT[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do

			
				if TP[j][i].BearPower:hasData(p[j][i])  and TP[j][i].BearPower:hasData(p[j][i]-1)then					

				local Color =nil;			
				local Style = nil;	


                if Type =="Simple" then				
                    Font=Wingdings;
						 if TP[j][i].BearPower[p[j][i]] <  TP[j][i].BullPower[p[j][i]-1] then
										
											
											Color = Up;
											Style= "\225";
						elseif TP[j][i].BearPower[p[j][i]] >  TP[j][i].BullPower[p[j][i]-1]  then
											
											  Color = Down;									
												Style= "\226";	
						else
										
												Color = No;
												Style= "\223";
						 end 
						 
							if Style ~= nil then
							core.host:execute("drawLabel1", id, 150+(i-1)*100,  core.CR_LEFT, 60+(j-1)*15  , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color,   Style );			  
							id = id+1;
							end

                 else
				 
				      
						 
						
							core.host:execute("drawLabel1", id, 150+(i-1)*100,  core.CR_LEFT, 60+(j-1)*15  , core.CR_TOP, core.H_Left, core.V_Center, font, Up,  string.format("%." .. 2 .. "f",  TP[j][i].BullPower[p[j][i]] ) );			  
							id = id+1;
							core.host:execute("drawLabel1", id, 200+(i-1)*100,  core.CR_LEFT, 60+(j-1)*15  , core.CR_TOP, core.H_Left, core.V_Center, font, Down,  string.format("%." .. 2 .. "f",  TP[j][i].BearPower[p[j][i]] ) );			  
							id = id+1;			
				 
				
                 end   				 
                
				
			

				
				
				end
        end
    end
end




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)



	local i,j;
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
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	else
	 core.host:execute ("setStatus", "  Loaded" );	 
	 instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;

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

 
