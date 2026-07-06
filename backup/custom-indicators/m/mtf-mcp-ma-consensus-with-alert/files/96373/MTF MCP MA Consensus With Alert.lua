-- Id: 12667
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61300

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
    indicator:name("MTF MCP MA Consensus With Alert");
    indicator:description("MTF MCP MA Consensus With Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	 
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
	
	
	indicator.parameters:addString("UpdateType", "Update Type", "Update Type" , "Live");
    indicator.parameters:addStringAlternative("UpdateType", "Live", "Live" , "Live");
    indicator.parameters:addStringAlternative("UpdateType", "End of Turn", "End of Turn" , "EndOfTurn");
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	indicator.parameters:addGroup("Currency Pair Selector");	
	
	AddCurrencyPair (1 , "EUR/USD" , true);
	AddCurrencyPair(2 , "USD/JPY"  , true);
	AddCurrencyPair (3 , "GBP/USD" , true );
	AddCurrencyPair (4 , "USD/CHF"  , true);
	AddCurrencyPair(5 , "EUR/CHF"  , true);
	AddCurrencyPair (6 , "AUD/USD" , true );
	AddCurrencyPair(7 , "USD/CAD" , true );
	AddCurrencyPair (8 , "NZD/USD" , true );
	AddCurrencyPair (9 , "EUR/GBP"  , true);
	AddCurrencyPair (10 , "EUR/JPY" , true );

	 
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m15", true ,20);
	AddTimeFrame (2 , "H1" , true ,20);
	AddTimeFrame (3 , "H4", false,20);
	AddTimeFrame (4 , "H8" , false,20 );
	AddTimeFrame (5 , "D1" , false,20);
	
	indicator.parameters:addGroup("Style");    
	
	indicator.parameters:addInteger("Size", "Font Size", "", 15);
	indicator.parameters:addInteger("RESET", "Number of Rows", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up1", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down1", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No1", "Neutral Color", "", core.rgb(0, 0, 255));
	
	--Up
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	

	
	
	ParametersAlert (1, "Consensus");

	
end
function AddCurrencyPair(id, Pair, Flag)


 indicator.parameters:addBoolean("Dodaj"..id , "Show " .. Pair  , "", Flag);
 indicator.parameters:addString("Pair"..id, id.. ". Currency Pair", "", Pair);
end



function ParametersAlert ( id, Label , Flag)
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
	
	 
    indicator.parameters:addFile("Sound"..id, Label .. " Consensus Sound", "", "");
    indicator.parameters:setFlag("Sound"..id, core.FLAG_SOUND);

	
	 indicator.parameters:addString("Labels"..id, "Label", "", Label);


end 


function AddTimeFrame(id , FRAME , DEFAULT, P1 )

    
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("USE"..id , "Show This Time Frame"  , "", DEFAULT); 
	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);	
	
	indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");
	  
	indicator.parameters:addInteger("Period1" ..id,   "1. MA Period", "", P1, 2, 2000);
	
	indicator.parameters:addString("Method1"..id, "MA Method", "Method" , "MVA");
	indicator.parameters:addStringAlternative("Method1"..id, "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method1"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1"..id, "WMA", "WMA" , "WMA");
	
	
	
end
local LastSerial={};
local Dodaj={};
local Trend={};
local loading={};
local SourceData={};
local UpdateType;
local Pair={};
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first ;
local Test ;
local Count;
local Up1, Down1, No1, LabelColor;
local Shift;
local Small;
local Sound={};
local USE={};
local RESET;
local Label={};
local ON={};
local Index;
local IndexTF;
local Email;
local SendEmail;
local RecurrentSound ,SoundFile  ;
local Alert;
local PlaySound;
local U={};
local D={};
local Number=1;
local Num=0;
local Consensus={};
local id;
local Corection =0;
local HShift={};
local VShift={};
local Type;
 
local Method1={};
local Period1={};

local Method2={};
local Period2={};

local Method3={};
local Period3={};
local Show;
local Price={};
local Indicator={};

function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
        core.host:execute("deleteFont", Small );
end  


function FindInstrument(Instrument)
  
   
    local row, enum;   
	local Flag= false;
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
       
        if Instrument == row.Instrument then
		Flag= true;
		break;
		end
         row = enum:next(); 
    end

    return Flag;
end

function ReleaseInstance()
 
    core.host:execute("killTimer", timer);
	core.host:execute("deleteFont", Wingdings);
	core.host:execute("deleteFont", font);
	core.host:execute("deleteFont", Small);
	core.host:execute("deleteFont", Bold);
	
end	

function Prepare(nameOnly) 
	Shift=instance.parameters.Shift; 
	RESET=instance.parameters.RESET;
	Type=instance.parameters.Type;
	Show=instance.parameters.Show;
	UpdateType=instance.parameters.UpdateType;
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.Size;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
		instance:name(name);
	if   (nameOnly) then
        return;
    end
	local i,j ;
	
	Up1 = instance.parameters.Up1;
	Down1 = instance.parameters.Down1;
	No1 = instance.parameters.No1;
	LabelColor = instance.parameters.Label;
	
	
		
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 10 , 1 do	 
					Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					  Instrument = FindInstrument(Pair[Count])
				      assert(  Instrument , "Please subscribe to " ..  Pair[Count] );
					 end
				 
				
				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
				Count=1;
	end
		
	Index=nil;
	
	
	Num=0;
		for i = 1 , 5 , 1 do  
	
	   USE[i]=instance.parameters:getBoolean("USE" .. i);
	   
	   if USE[i] then
	    Num=Num+1;
	    
		
		TF[Num]=  instance.parameters:getString ("TF"..i);	
        Period1[Num]=  instance.parameters:getInteger ("Period1"..i);	
        Method1[Num]=  instance.parameters:getString ("Method1"..i);	
		assert(core.indicators:findIndicator( Method1[Num]) ~= nil, "Please, download and install ".. Method1[Num] .. ".LUA indicator");
		Price[Num]=  instance.parameters:getString ("Price"..i);	
        
		
		if Index== nil then
		Index=Num;
		IndexTF=TF[Num];
		end
		
		 s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
         s2, e2 = core.getcandle(TF[Num], 0, 0, 0);
		 
		 size2= e2-s2;
		 size1= e1-s1;
		 
		 if size1 > size2 then
		 Index=Num;
		 IndexTF=TF[Num];
		 end
		 
		
      end		
	end	
	

		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	Small  = core.host:execute("createFont", "Courier", Size, false, false); 
	
	         
 
 Indicator[1]={}; 
  Indicator[2]={};

  
 ID=0;
 for j = 1, Count, 1 do
          
 
 
   SourceData[j] = {};
   Indicator[1][j] = {};
   Indicator[2][j] = {};
 
   loading[j] = {}; 
   
     
   
     
   for i = 1, Num, 1 do 
   
          ID=ID+1;
    
    assert(core.indicators:findIndicator(Method1[i]) ~= nil, Method1[i] .. " indicator must be installed");
            Indicator[2][j][i] =  core.indicators:create(Method1[i], source.close , Period1[i] )
            first=Indicator[2][j][i].DATA:first();
      
      
      SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(),  math.min(300,first*2)   , 2000 + ID , 1000+ID);
      loading[j][i] = true;  
   
      Indicator[1][j][i] = core.indicators:create(Method1[i], SourceData[j][i][Price[i]] , Period1[i]);
       
      
                  
     
  end
 end
			  
  
	
	Initialization();
	  timer = core.host:execute("setTimer", 1, 1);
end

 

function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Labels" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Sound[i]=instance.parameters:getString("Sound" .. i);
	
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Sound[i]=nil;	  
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Sound[i] ~= "") or (PlaySound and Sound[i] ~= ""), "Sound file must be chosen"); 

	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;
	
		
	end
		
		
end	


 function Calculate()
 
 
     Corection=1;
    local FLAG=false;
	
	local i,j;
	id =1;
	
	 
	local Reset=0;
	
	local Broj=0;--Number
	
	for j = 1, Count, 1 do
	
	Reset= Reset+1;
	
	if Reset == RESET+1 then
	Corection=Corection+1;
	Reset=1;
	end
	
	HShift[j] = Size*10+ (Corection-1)*Size*13;
	VShift[j] =   Size*2+ (Reset-1)*Size +Shift;
	 
	
	     	
	     	 core.host:execute("drawLabel1", id,  HShift[j]-Size*5 ,  core.CR_LEFT,VShift[j]   , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
	         id = id+1;	
			 
			      
	
	
		 for i = 1, Num, 1 do	
 
				 if j== 1 then
				 core.host:execute("drawLabel1", id,i*Size+HShift[j],  core.CR_LEFT,VShift[j]-Size    , core.CR_TOP, core.H_Left, core.V_Center, Small, LabelColor,  i ..""  );			  
                  id = id+1;
                 end 				  
		 
         end  	
    end
	
	
	
	

  for j = 1, Count, 1 do
  
 
  
     Consensus[j]=0;
	
				
	for i = 1, Num, 1  do
	
	    
				Indicator[1][j][i]:update(core.UpdateLast); 			 
				Indicator[2][j][i]:update(core.UpdateLast); 				 

				 
				
				Draw ( 0, j, i);					
				 
												
        end
		
		
 
    end
	
	local C;
	local L;
	
	for i = 1, Count, 1  do
	 
	 
	 
	  if Consensus[i]== Num 	  
	  then
	  C=Up1;
	  L="Buy"
	   Activate ( i, 1 );
	  elseif Consensus[i]== -Num  	 
	  then
	   C=Down1;
	  L="Sell"
	   Activate ( i, -1 );
	  else
	  C=No1;
	  L="Neutral"
	   Activate ( i, 0 );
	  end
		if Num ~= 0 then
		 core.host:execute("drawLabel1", id,  HShift[i] ,  core.CR_LEFT, VShift[i]    , core.CR_TOP, core.H_Left, core.V_Center, Bold, C, L);
		 id=id+1;
		end 
	end
 
 end


function Draw ( p , j, i)

                      if not Indicator[1][j][i].DATA:hasData(Indicator[1][j][i].DATA:size()-2)
					 
                      then
					  return;
					  end
					  
					  
					  
					  local BuyFlag=true;
					  local SellFlag= true;
					  
				 
					 
					   
					   
					   
					   
						  
							   if  Indicator[1][j][i].DATA[Indicator[1][j][i].DATA:size()-1] < Indicator[1][j][i].DATA[Indicator[1][j][i].DATA:size()-2] then
							   BuyFlag= false;
							   elseif  Indicator[1][j][i].DATA[Indicator[1][j][i].DATA:size()-1] > Indicator[1][j][i].DATA[Indicator[1][j][i].DATA:size()-2] then
							   SellFlag= false;
							   end			
                     
 
						local Color1 =nil;			
						local Style1 = nil;				

									 if BuyFlag
									 then
										
										 
										Consensus[j]= Consensus[j]+1;	
										 
										
																		
														
														Color1 = Up1;
														Style1= "\110";
									elseif SellFlag
									then
									
										
										 
										Consensus[j]= Consensus[j]-1;	
										 
										
														  Color1 = Down1;									
															Style1= "\110";	
															
									else
									
														   Color1 = No1;									
															Style1= "\110";	
									 end 				
							 
							if Style1 ~= nil then
							core.host:execute("drawLabel1", id, i*Size+HShift[j],  core.CR_LEFT, VShift[j]     , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color1,   Style1 );			  
							id = id+1;
							end
							
						
					

end


function Update(period)
 
 	  
end

 
function Activate ( i , iFlag )
 
      if  Trend[i]==nil then
	  Trend[i]=0;
	  end
	  
	  
	  if UpdateType == "EndOfTurn"
	  and LastSerial[i] ==SourceData[1][Index]:serial(SourceData[1][Index].close:size()-1)
	  then
	  return;  
	  end
	  
	  LastSerial[i] =SourceData[1][Index]:serial(SourceData[1][Index].close:size()-1);
	 
		
	  if   not  ON[1] 
	  then
	  return;
	  end
	   
	       
						if 	iFlag== 1
                        and    Trend[i]~= 1						
						then
							  
									  
									  Trend[i]=1;
									     SoundAlert(Sound[1]);									
									 EmailAlert(   " Up Trend ", i );
									  
										  if Show then
										 Pop(Label[1], " Up Trend " , i);  	
										end
									 
					  elseif iFlag== -1
					  and    Trend[i]~= -1				   
					  then			
							
							 
						   
											   Trend[i]=-1;
											 
											      SoundAlert(Sound[1]);	 											
											   EmailAlert( " Down Trend ", i);		
												if Show then
												  Pop(Label[1], " Down Trend ", i );  	
												end
					  elseif iFlag==0
					  and    Trend[i]~= 0				   
					  then			
							
							 
						   
											   Trend[i]=0;
											 
											      SoundAlert(Sound[1]);	 											
											   EmailAlert( " Neutral ", i);		
												if Show then
												  Pop(Label[1], " Neutral ", i );  	
												end						
										
						 end			   
 		
	   
end			


function Pop(label , note,i)
 local delim = "\013\010";
  local date =  core.now();
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day  ..delim  .. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

   core.host:execute ("prompt", 1, label , profile:id().. delim .. Pair[i]  .. " : " .. note.. delim .. LABEL );


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
	
	local iCount=0;
	 
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do
              ID=ID+1;
			   
			  if cookie == (1000 + ID) then
			  loading[j][i] = true;		
		      elseif  cookie == (2000 +ID) then
			  iCount=iCount+1;
			  loading[j][i] = false;   
			  
			  end
		       
          end
	end    
	
	
	local iNumber=0;
	local FLAG=true;
	 for j = 1, Count, 1 do
		 for i = 1, Num, 1 do
		 

                 if loading[j][i] then
				 FLAG= false;
				 iNumber=iNumber+1;
				 end
		 
     end    
    end
	
	if not FLAG then
	core.host:execute ("setStatus", "  Loading "..(  Count*Num  - iNumber) .. " / " ..  Count*Num );
    return;	
	else
	core.host:execute ("setStatus", "Loaded");	
	 instance:updateFrom(0);
	end
	 
	if cookie == 1
	then
	Calculate();	
	end
 
	return core.ASYNC_REDRAW;
  
    
end



function SoundAlert(Sound)
  
  if not PlaySound then
  return;
  end
  
  terminal:alertSound(Sound, RecurrentSound);
end


function EmailAlert( Subject, i)

if not SendEmail then
return
end

  
   local date =  core.now();
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 
local delim = "\013\010";
terminal:alertEmail(Email, Subject, profile:id()..delim .. Pair[i]  .. " : " .. Subject..delim .. LABEL);
end
	 
