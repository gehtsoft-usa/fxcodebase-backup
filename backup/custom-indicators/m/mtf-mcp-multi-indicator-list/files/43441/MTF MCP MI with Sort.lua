-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25257

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
    indicator:name("MTF MCP Multi Indicator List");
    indicator:description("MTF MCP Multi Indicator List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	


    indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addString("SelectorType", "Currency pair Selector", "Currency pair Selector" ,"Multiple currency pair");
    indicator.parameters:addStringAlternative("SelectorType", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("SelectorType", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("SelectorType", "All currency pair", "All currency pair" , "All currency pair");	

 
	
	indicator.parameters:addBoolean("UseSort", "Use Sort", "", false);		
	
	
	indicator.parameters:addInteger("SortIndex", "Sort Selector", "Sort Selector" , 9);
    indicator.parameters:addIntegerAlternative("SortIndex", "m1", "m1" , 1);
	indicator.parameters:addIntegerAlternative("SortIndex", "m15", "m15" , 2);
	indicator.parameters:addIntegerAlternative("SortIndex", "m30", "m30" , 3);
	indicator.parameters:addIntegerAlternative("SortIndex", "H1", "H1" , 4);
	indicator.parameters:addIntegerAlternative("SortIndex", "H2", "H2" , 5);
	indicator.parameters:addIntegerAlternative("SortIndex", "H3", "H3" , 6);
	indicator.parameters:addIntegerAlternative("SortIndex", "H4", "H4" , 7);
	indicator.parameters:addIntegerAlternative("SortIndex", "H8", "H8" , 8);
	indicator.parameters:addIntegerAlternative("SortIndex", "D1", "D1" , 9);
	indicator.parameters:addIntegerAlternative("SortIndex", "W1", "W1" , 10);
	indicator.parameters:addIntegerAlternative("SortIndex", "M1", "M1" , 11);
 
	
	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");

	AddCurrencyPair (i );
	
	end
	
	

	
	
	
	Parameters (1 , "m1" , "MVA", false );
	Parameters (2 , "m15", "MVA" , false  );
	Parameters (3 , "m30", "MVA", false  );
	Parameters (4 , "H1" , "MVA", true   );
	Parameters (5 , "H2", "MVA" , false  );
	Parameters (6 , "H3" , "MVA", false  );
	Parameters (7 , "H4", "MVA", true   );
	Parameters (8 , "H8", "MVA", true  );
	Parameters (9 , "D1" , "MVA", true   );
	Parameters (10 , "W1", "MVA", true   );	
	Parameters (11 , "M1", "MVA" , true  );
	
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME, Method, TF_Flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", TF_Flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
    indicator.parameters:addString("Method"..id, "Indicator", "", Method);
    indicator.parameters:setFlag("Method"..id,core.FLAG_INDICATOR);
	
	indicator.parameters:addString("Type"..id, "Indicaton Type", "", "Numeric");
    indicator.parameters:addStringAlternative("Type"..id, "Numeric", "", "Numeric");
    indicator.parameters:addStringAlternative("Type"..id, "Trend", "", "Trend");
	
	indicator.parameters:addInteger("Lock"..id, "Stream Number", "", 1,1, 100);	
	
end

 
function AddCurrencyPair(id)

     local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"				  
			  };
			  
			  
	if id > 5 then
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);		
    else	
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
    end	
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end

local Pair= {};
local Dodaj={};
local Point={};

local loading={};
local SourceData={};
local Indicator={};
 
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
local  iprofile= {};	
local  iparams= {};
local SC={};
local  tprofile= {};	
local  tparams= {};
local Method={};
local Type={};
local Lock={};

local SortIndex;
local UseSort;

local Key;

local SelectorType;
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

   Key=nil;
	
	Shift=instance.parameters.Shift; 
	SelectorType=instance.parameters.SelectorType;
	
	SortIndex=instance.parameters.SortIndex;
	UseSort=instance.parameters.UseSort;
	
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
	 
	Pair={};
	
	if SelectorType== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
					 end
				 
				 end
				 
	elseif SelectorType== "All currency pair" then 
	
	
	          Pair, Count,Point = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   Count=1;
	end
	  

	Num=0;
	
	for i = 1 , 11 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if instance.parameters.SortIndex ==i and not On[i] then
	    assert(false, "Selected Sort time frame is not available.");
		UseSort=false;
	   end
	   
	   if On[i] then  
	   Num = Num+1;
	   SortIndex=Num;
	   Method[Num]=  instance.parameters:getString ("Method"..i);
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Type[Num]=  instance.parameters:getString ("Type"..i);
	   Lock [Num]=  instance.parameters:getInteger ("Lock"..i);
	 


	           tprofile[Num] = core.indicators:findIndicator(instance.parameters:getString("Method"..i));
			   tparams[Num] = instance.parameters:getCustomParameters("Method"..i);
			   if  tprofile[Num]:requiredSource() == core.Tick then
			   Test[Num] = tprofile[Num]:createInstance(source.close, tparams[Num]);
			   else
			   Test[Num] = tprofile[Num]:createInstance(source, tparams[Num]);
			   end  
			   
			   SC[Num] = Test[Num]:getStreamCount ()
			   
			    if Lock [Num] > SC[Num] then
				  Lock [Num] = SC[Num];
			    end
			   
			   local TS=Test[Num]:getStream(Lock [Num]-1);
	           first[Num]= TS:first() +2;	
			   
			  
	  end
	end	
	
	 
	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	--assert(core.indicators:findIndicator("VORTEX") ~= nil, "Please, download and install VORTEX.LUA indicator");	
	

	
	
		
	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 
             loading[j] = {};	
			 iprofile[j] = {};	
			 iparams[j] = {};
			 Indicator[j] = {};
			 
			
	   
	   
		 for i = 1, Num, 1 do	
		 
		 
		 					  
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), first[i] , 20000 + j*12+i , 10000 + j*12+i);
			   loading[j][i] = true;  
			  
			   
			   iprofile[j][i] = core.indicators:findIndicator(instance.parameters:getString("Method"..i));
			   iparams[j][i] = instance.parameters:getCustomParameters("Method"..i);			
			   
			   if  iprofile[j][i]:requiredSource() == core.Tick then
			   Indicator[j][i] = iprofile[j][i]:createInstance(SourceData[j][i].close, iparams[j][i]);
			   else
			   Indicator[j][i] = iprofile[j][i]:createInstance(SourceData[j][i], iparams[j][i]);
			   end

             			  
			  
		end
	end
    
	
		core.host:execute ("setTimer", 1, 1);
		 
end

 





function Update(period, mode)

 

 if period < source:size()-1 then
 return
 end
 
   if Key== nil then
   return;
   end
 
  
    local FLAG=false;
	
	local i,j;
	local id =1;
	 
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				  
				 end
		 
         end  	
    end
	
	if FLAG then
	 
	return;
	end
	
	
	
	
  

  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*10+(i)*Size*10 ,  core.CR_LEFT, Size*3 +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*10 ,  core.CR_LEFT, Size*3+(j)*Size*1.5 +Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[Key[j]]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do
 
				
				 
				
				
				if  Indicator[Key[j]][i]:getStream(0):hasData(Indicator[Key[j]][i]:getStream(0):size()-1) and Indicator[Key[j]][i]:getStream(0):hasData(Indicator[Key[j]][i]:getStream(0):size()-2) and SC[i] > 0 then					

						local Color =nil;			
						local Style = nil 
						local Font=nil;
						
						Style = Indicator[Key[j]][i]:getStream(0)[Indicator[Key[j]][i]:getStream(0):size()-1];			

						 if Indicator[Key[j]][i]:getStream(0)[Indicator[Key[j]][i]:getStream(0):size()-1] >  Indicator[Key[j]][i]:getStream(0)[Indicator[Key[j]][i]:getStream(0):size()-2] then
										
											
											Color = Up;
											Style= "\225";
						elseif Indicator[Key[j]][i]:getStream(0)[Indicator[Key[j]][i]:getStream(0):size()-1] <  Indicator[Key[j]][i]:getStream(0)[Indicator[Key[j]][i]:getStream(0):size()-2] then
											
											  Color = Down;									
												Style= "\226";	
												
						 else				
                                              Style= "\158";							 
											 Color = No;
						 end 			

                        if Type[i]~= "Trend" then
						Font= font;	
						Style= string.format("%." .. 5 .. "f", Indicator[Key[j]][i]:getStream(0)[Indicator[Key[j]][i]:getStream(0):size()-1] );   
						else
						Font= Wingdings;						
                        end						
						
						
						if Style ~= nil then
						core.host:execute("drawLabel1", id, Size*10+(i)*Size*10,  core.CR_LEFT, Size*3+(j)*Size*1.5 +Shift , core.CR_TOP, core.H_Left, core.V_Center, Font, Color,   Style );		  		  
						id = id+1;
						end

				end
				
				end
        end
    
end





function BubbleSortKey(Data,  Count)
 
 local Key={};
 local Temp;
 local Sort=true;
 
   
   for i=1, Count, 1 do
   Key[i]=i;
   end
   
   if not UseSort then
   return Key;
   end
   

     while Sort do
    Sort=false;
   
            for i = 2, Count , 1 do
                    if Data[Key[i]]~= nil
					and Data[Key[i-1]]~= nil
					then
                    if Data[Key[i]]  >  Data[Key[i-1]]then
                     Sort=true;                  
                     
                     Temp= Key[i];                     
                     Key[i]=Key[i-1];
                     Key[i-1]=Temp;                       
                    end
                   end
          end
    
    end
  
  return Key;
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


function AsyncOperationFinished(cookie)

	
	local i,j;

    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
			  if cookie == (10000 + j*12+i) then
			  loading[j][i] = true;
		      elseif  cookie == (20000 + j*12+i) then
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
	
	 Indicator[j][i]:update(core.UpdateLast);
	 
	 end
	end
	
				local InputData={};
		  
				for j = 1, Count, 1 do
			for i = 1, Num, 1  do
		 
						 
						
					
						if i==SortIndex then
						InputData[j]=Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1]
						end
						
			end
			end
			
			
		  
		  
		   Key= BubbleSortKey(InputData,Count );
	
  
   end	
   
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	 else
	core.host:execute ("setStatus", "  Loaded "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
	             
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end








