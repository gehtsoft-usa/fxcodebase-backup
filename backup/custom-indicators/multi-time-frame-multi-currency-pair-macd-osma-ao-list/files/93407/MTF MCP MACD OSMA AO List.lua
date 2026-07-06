-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60508

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
    indicator:name("Multi Time Frame, Multi Currency Pair List");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m5", true  );
	Parameters (2 , "m15", false   );
	Parameters (3 , "m30", false  );
	Parameters (4 , "H1", false    );
    Parameters (5 , "H8", false  );
	Parameters (6 , "D1", false   );
	Parameters (7 , "W1", false  );
	Parameters (8 , "M1", false    );
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
	 indicator.parameters:addGroup(id ..". MACD Calculation");
	indicator.parameters:addString("Price1"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1"..id, "WEIGHTED", "", "weighted");	
	
	
    indicator.parameters:addInteger("SN"..id, "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN"..id, "Long EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN"..id, "Signal Line", "", 9, 2, 1000);
	
	
	indicator.parameters:addGroup(id ..". OSMA Calculation");
		indicator.parameters:addString("Price2"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2"..id, "WEIGHTED", "", "weighted");
	indicator.parameters:addString("Method"..id, "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("OSMASN"..id, "Short MA", "The period of the short MA", 12, 2, 1000);
    indicator.parameters:addInteger("OSMALN"..id, "Long MA", "The period of the Long MA", 26, 2, 1000);
    indicator.parameters:addInteger("OSMAIN"..id, "Signal line", "The number of periods for the signal line.", 9, 2, 1000);

indicator.parameters:addGroup(id ..". Awesome Oscillator Calculation");
indicator.parameters:addInteger("FM"..id, "Fast MA Period", "", 5, 2, 10000);
    indicator.parameters:addInteger("SM"..id, "Slow MA Period","", 35, 2, 10000);	
 
	
	
end
local Method={};
local OSMASN={};
local OSMALN={};
local OSMAIN={};

local SN={};
local LN={};
local IN={};
local loading={};
local SourceData={};
local MACD={};
local AO={};
local OSMA={};
local Pair;
local Font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first;
local Test;
local Count;
local Up, Down, No, LabelColor;
local FM={};
local SM={};
local Shift;
local On={};
local Num;
local  SIZE ;
local Type;
local Price1={};
local Price2={};
function ReleaseInstance()
       core.host:execute("deleteFont", Font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

function Prepare(nameOnly) 
    Type=instance.parameters.Type;   
	Shift=instance.parameters.Shift; 
	Level=instance.parameters.Level;
	 
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")";
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
	 getPointSize();    

	Num=0;
	
	assert(core.indicators:findIndicator("OSMA") ~= nil, "Please, download and install OSMA.LUA indicator");
	
	for i = 1 , 8 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Price1[Num]=  instance.parameters:getString ("Price1"..i);
       SN[Num]=  instance.parameters:getInteger ("SN"..i);
	    LN[Num]=  instance.parameters:getInteger ("LN"..i);
		IN[Num]=  instance.parameters:getInteger ("IN"..i);
	   Price2[Num]=  instance.parameters:getString ("Price2"..i);
       OSMASN[Num]=  instance.parameters:getInteger ("OSMASN"..i);
	    OSMALN[Num]=  instance.parameters:getInteger ("OSMALN"..i);
		OSMAIN[Num]=  instance.parameters:getInteger ("OSMAIN"..i);
	  Method[Num]=  instance.parameters:getString ("Method"..i);
	  FM[Num]=  instance.parameters:getInteger ("FM"..i);
		SM[Num]=  instance.parameters:getInteger ("SM"..i);
  
	  end
	end	
 
		
   	
	Font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	 
	
	
  local id = 0;
	
	for j = 1, Count, 1 do
	
	
	
	         SourceData[j] = {};
			 MACD[j] = {};	
			 OSMA[j] = {};	
			 AO[j] = {};
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		 
		      Test1 = core.indicators:create("MACD", source.close ,SN[i],LN[i],IN[i]);   
			  Test2 = core.indicators:create("OSMA", source.close ,Method[i],OSMASN[i],OSMALN[i],OSMAIN[i]);  
			  Test3 = core.indicators:create("AO", source ,FM[i],SM[i]);  
	          first= math.max(Test1.DATA:first(), Test2.DATA:first(),  Test3.DATA:first())+1 ;
		 
		 		id = id +1;		  
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300,first ) , 2000 + id , 1000 + id);
			   loading[j][i] = true;  
			  
			   MACD[j][i] = core.indicators:create("MACD", SourceData[j][i][Price1[i]],SN[i],LN[i],IN[i]);
               OSMA[j][i] = core.indicators:create("OSMA", SourceData[j][i][Price2[i]],Method[i],OSMASN[i],OSMALN[i],OSMAIN[i]);
             	AO[j][i] = core.indicators:create("AO", SourceData[j][i],FM[i],SM[i]);		  
			  
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
 

local Color =No;			
 local Style =   "\167" 
 font = Wingdings
  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*10+(i-1)*Size*5 ,  core.CR_LEFT, 10  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id,  Size*5 ,  core.CR_LEFT, 30+(j-1)*Size*2+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do

				
				--MACD[j][i]:update(mode);
			--	OSMA[j][i]:update(mode);
			--	AO[j][i]:update(mode);
				
				 
				
					     Color =No;			
						  Style =   "\167" 
						 
				
				if  MACD[j][i].DATA:hasData(MACD[j][i].DATA:size()-1) 
				and OSMA[j][i].DATA:hasData(OSMA[j][i].DATA:size()-1) and OSMA[j][i].DATA:hasData(OSMA[j][i].DATA:size()-2) 
				and AO[j][i].DATA:hasData(AO[j][i].DATA:size()-1)
				then					
                       
						 
						
						               		   

						 if MACD[j][i].DATA[MACD[j][i].DATA:size()-1] <  0 
						 and  OSMA[j][i].DATA[OSMA[j][i].DATA:size()-1] >  0 
						  and  AO[j][i].DATA[AO[j][i].DATA:size()-1] < 0 
						 then
										
											
											Color = Up;
										 Style= "\225";
									
											
										
						elseif MACD[j][i].DATA[MACD[j][i].DATA:size()-1] >  0 
						and  OSMA[j][i].DATA[OSMA[j][i].DATA:size()-1] <  0 
						and  AO[j][i].DATA[AO[j][i].DATA:size()-1] > 0 
						then
											
											  Color = Down;	
										 Style= "\226";
																			  
											
						
						 end 		
						if
						(OSMA[j][i].DATA[OSMA[j][i].DATA:size()-1] <  0  and OSMA[j][i].DATA[OSMA[j][i].DATA:size()-2] >= 0 )
 						or 
						(OSMA[j][i].DATA[OSMA[j][i].DATA:size()-1] >  0  and OSMA[j][i].DATA[OSMA[j][i].DATA:size()-2] <= 0 )
						then
		               Style = Style ..  "\108";
                        end  
						
						

				end
				
				       if Style ~= nil then
						core.host:execute("drawLabel1", id,  Size*10+(i-1)*Size*5,  core.CR_LEFT, 30+(j-1)*Size*2 +Shift , core.CR_TOP, core.H_Left, core.V_Center, font, Color,  Style );			  
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
    local id = 0;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		     id = id+1;
			  if cookie == (1000 +id) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 +id) then
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
	            MACD[j][i]:update(core.UpdateLast);
			 	OSMA[j][i]:update(core.UpdateLast);
			 	AO[j][i]:update(core.UpdateLast);
	end
    end	
				
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	 else
	            core.host:execute ("setStatus", "Loaded " );	 
			  instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end

function getPointSize()
    SIZE = {};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
      
        SIZE[count] = row.PointSize;      
      
        row = enum:next();
    end

end

