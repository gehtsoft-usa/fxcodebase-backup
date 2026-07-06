-- Id: 21440
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66140

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
    indicator:name("MTF MCP MA Scanner");
    indicator:description("MTF MCP MA Scanner");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	 
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
	
	
	--indicator.parameters:addString("UpdateType", "Update Type", "Update Type" , "Live");
  --  indicator.parameters:addStringAlternative("UpdateType", "Live", "Live" , "Live");
   -- indicator.parameters:addStringAlternative("UpdateType", "End of Turn", "End of Turn" , "EndOfTurn");
	
	
	 indicator.parameters:addGroup("Selector");  
	 indicator.parameters:addBoolean("S1"  , "Use 1.MA"  , "", true); 
	 indicator.parameters:addBoolean("S2"  , "Use 2.MA"  , "", true); 
	 indicator.parameters:addBoolean("S3"  , "Use 3.MA"  , "", true); 
	 indicator.parameters:addBoolean("S4"  , "Use 4.MA"  , "", true); 
	
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

	 
	
	AddTimeFrame (1 , "H1"  );
	AddTimeFrame (2 , "H4"  );
	AddTimeFrame (3 , "H8"  );
    AddTimeFrame (4 , "D1"  );
    AddTimeFrame (5 , "W1"  );
	
	indicator.parameters:addGroup("Style");    
	
	indicator.parameters:addInteger("Size", "Font Size", "", 15);
	indicator.parameters:addInteger("RESET", "Number of Rows", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up1", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down1", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No1", "Neutral Color", "", core.rgb(0, 0, 255));
	
	ParametersAlert (1, "Consensus")
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	 indicator.parameters:addFile("Sound".. 1,  "Consensus Sound", "", "");
    indicator.parameters:setFlag("Sound"..  1, core.FLAG_SOUND);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	
	
	


	
end
function AddCurrencyPair(id, Pair, Flag)


 indicator.parameters:addBoolean("Dodaj"..id , "Show " .. Pair  , "", Flag);
 indicator.parameters:addString("Pair"..id, id.. ". Currency Pair", "", Pair);
end



function ParametersAlert ( id, Label , Flag)
  
  
   indicator.parameters:addGroup(Label .. " Alert");
   
    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
	
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true); 
	
	 indicator.parameters:addString("Labels"..id, "Label", "", Label);


end 


function AddTimeFrame(id , TF    )

    
   indicator.parameters:addGroup(id.. ". Time Frame");	
	indicator.parameters:addBoolean("USE"..id , "Use this time Frame"  , "", true); 

    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	
	indicator.parameters:addGroup( id..". TF  1.MA");	
    indicator.parameters:addBoolean("S1"..id , "Use 1.MA"  , "", true); 	
	indicator.parameters:addInteger("Period1"..id, "1.MA Period", "", 34);
	
	indicator.parameters:addString("Price1"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method1"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1"..id, "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup( id..". TF  2.MA");
    indicator.parameters:addBoolean("S2"..id , "Use 2.MA"  , "", true); 	
	
    indicator.parameters:addInteger("Period2"..id, "2.MA Period", "", 50);
	
	
	indicator.parameters:addString("Price2"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method2"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2"..id, "WMA", "WMA" , "WMA");
	

	
	
	indicator.parameters:addGroup( id..". TF  3.MA");
   
	 indicator.parameters:addBoolean("S3"..id , "Use 3.MA"  , "", true); 	
    indicator.parameters:addInteger("Period3"..id, "3.MA Period", "", 50);
	
	
	indicator.parameters:addString("Price3"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price3"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price3"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price3"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price3"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price3"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price3"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price3"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method3"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3"..id, "WMA", "WMA" , "WMA");
	
 
	 
		
	indicator.parameters:addGroup( id..". TF  4.MA");
   
	 indicator.parameters:addBoolean("S4"..id , "Use 4.MA"  , "", true); 	
    indicator.parameters:addInteger("Period4"..id, "4.MA Period", "", 50);
	
	
	indicator.parameters:addString("Price4"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price4"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price4"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price4"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price4"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price4"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price4"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price4"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method4"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method4"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4"..id, "WMA", "WMA" , "WMA");
	
	
		
	indicator.parameters:addGroup( id..". TF  5.MA");
   
	 indicator.parameters:addBoolean("S5"..id , "Use 5.MA"  , "", true); 	
    indicator.parameters:addInteger("Period5"..id, "5.MA Period", "", 50);
	
	
	indicator.parameters:addString("Price5"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price5"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price5"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price5"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price5"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price5"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price5"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price5"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method5"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method5"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method5"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method5"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method5"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method5"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method5"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method5"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method5"..id, "WMA", "WMA" , "WMA");
	
end

local Dodaj={};
local Trend={};
local loading={};
local SourceData={};
--local UpdateType;
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
local Show;
local Price={};
local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}; 
local ToTime;

local MA1={};
local MA2={};
local MA3={};
local MA4={}; 
local MA5={}; 
local Period1={};
local Period2={};
local Period3={};
local Period4={};
local Period5={};
local Method1={};
local Method2={};
local Method1={};
local Method2={};
local Method3={};
local Method4={};
local Method5={};
local Price1={};
local Price2={};
local Price3={};
local Price4={};
local Price5={};

local S1, S2,S3,S4,S5;
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
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	S1=instance.parameters.S1;
	S2=instance.parameters.S2;
	S3=instance.parameters.S3;
	S4=instance.parameters.S4;
	S5=instance.parameters.S5;
	
	ToTime=instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
	end
  
	Shift=instance.parameters.Shift; 
	RESET=instance.parameters.RESET;
	Type=instance.parameters.Type;
	Show=instance.parameters.Show;
	--UpdateType=instance.parameters.UpdateType;
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.Size;   
    
	
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
	
	  
	   
	   if instance.parameters:getBoolean("USE" .. i) then
	    Num=Num+1;
	    USE[Num]=true;		
		TF[Num]=  instance.parameters:getString ("TF"..i);
        Period1[Num]=  instance.parameters:getInteger ("Period1"..i);
        Period2[Num]=  instance.parameters:getInteger("Period2"..i);
        Period3[Num]=  instance.parameters:getInteger ("Period3"..i);	
		Period4[Num]=  instance.parameters:getInteger ("Period4"..i);
		Period5[Num]=  instance.parameters:getInteger ("Period5"..i);		
		Method1[Num]=  instance.parameters:getString ("Method1"..i);
        Method2[Num]=  instance.parameters:getString("Method2"..i);
		Method3[Num]=  instance.parameters:getString("Method3"..i);
		Method4[Num]=  instance.parameters:getString("Method4"..i);
		Method5[Num]=  instance.parameters:getString("Method5"..i);
		Price1[Num]=  instance.parameters:getString ("Price1"..i);
        Price2[Num]=  instance.parameters:getString("Price2"..i);
        Price3[Num]=  instance.parameters:getString("Price3"..i);
		Price4[Num]=  instance.parameters:getString("Price4"..i);
		Price5[Num]=  instance.parameters:getString("Price5"..i);
		
	 
		 
		
      end		
	end	
	
 
	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	Small  = core.host:execute("createFont", "Courier", Size, false, false); 
	


  
 ID=0;
 for j = 1, Count, 1 do
          
 
 
   SourceData[j] = {};
   MA1[j] = {};
   MA2[j] = {};
   MA3[j] = {};
   MA4[j] = {};
   MA5[j] = {};
  
   loading[j] = {}; 
   Trend[j]=nil;
     
   
     
   for i = 1, Num, 1 do 
   
          ID=ID+1;
   
      SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(),  300   , 2000 + ID , 1000+ID);
      loading[j][i] = true;  
    assert(core.indicators:findIndicator(Method1[i]) ~= nil, Method1[i] .. " indicator must be installed");
      MA1[j][i]= core.indicators:create(Method1[i],SourceData[j][i][Price1[i]], Period1[i] );
    assert(core.indicators:findIndicator(Method2[i]) ~= nil, Method2[i] .. " indicator must be installed");
      MA2[j][i]= core.indicators:create(Method2[i],SourceData[j][i][Price2[i]], Period2[i] );      
    assert(core.indicators:findIndicator(Method3[i]) ~= nil, Method3[i] .. " indicator must be installed");
      MA3[j][i]= core.indicators:create(Method3[i],SourceData[j][i][Price3[i]], Period3[i] );  
    assert(core.indicators:findIndicator(Method4[i]) ~= nil, Method4[i] .. " indicator must be installed");
	  MA4[j][i]= core.indicators:create(Method4[i],SourceData[j][i][Price4[i]], Period4[i] );  
    assert(core.indicators:findIndicator(Method5[i]) ~= nil, Method5[i] .. " indicator must be installed");
	  MA5[j][i]= core.indicators:create(Method5[i],SourceData[j][i][Price5[i]], Period5[i] );  	  
      
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
	
 
	
	for j = 1, Count, 1 do
	
	 VShift[j] =  50+ Shift +( j)*Size  ;
	 
	
	     	
	     	 core.host:execute("drawLabel1", id,  Size*8 ,  core.CR_LEFT,VShift[j]   , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
	         id = id+1;	
			 
			      
	
	
		 for i = 1, Num, 1 do
		 
		        
				   if j== 1 then
				 core.host:execute("drawLabel1", id, Size*24 +Size*i ,  core.CR_LEFT, VShift[j]-Size   , core.CR_TOP, core.H_Left, core.V_Center, Small, LabelColor,  i ..""  );			  
                  id = id+1;	
		          end 
         end  	
    end
	
	
	
	

  for j = 1, Count, 1 do
  
 
  
     Consensus[j]=0;
	
				
	for i = 1, Num, 1  do
					
				Draw (  j, i);					
												
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
		 core.host:execute("drawLabel1", id,   Size*16  ,  core.CR_LEFT, VShift[i]    , core.CR_TOP, core.H_Left, core.V_Center, Bold, C, L);
		 id=id+1;
		end 
	end
 
 end


function Draw (j, i)

                     
						local Color1 =nil;			
						local Style1 = nil;				

									 if  ((S1 and MA1[j][i].DATA[MA1[j][i].DATA:size()-1] >  MA1[j][i].DATA[MA1[j][i].DATA:size()-2])   or not S1)
									 and  ((S2 and MA2[j][i].DATA[MA2[j][i].DATA:size()-1] >  MA2[j][i].DATA[MA2[j][i].DATA:size()-2])  or not S2)
									 and  ((S3 and MA3[j][i].DATA[MA3[j][i].DATA:size()-1] >  MA3[j][i].DATA[MA3[j][i].DATA:size()-2])  or not S3)
									 and  ((S4 and MA4[j][i].DATA[MA4[j][i].DATA:size()-1] >  MA4[j][i].DATA[MA4[j][i].DATA:size()-2])  or not S4)
									 and  ((S5 and MA5[j][i].DATA[MA5[j][i].DATA:size()-1] >  MA5[j][i].DATA[MA5[j][i].DATA:size()-2])  or not S5)
									 then
										
										 
										Consensus[j]= Consensus[j]+1;	
										 
										
																		
														
														Color1 = Up1;
														Style1= "\110";
									 elseif  ((S1 and MA1[j][i].DATA[MA1[j][i].DATA:size()-1] < MA1[j][i].DATA[MA1[j][i].DATA:size()-2])   or not S1)
									 and  ((S2 and MA2[j][i].DATA[MA2[j][i].DATA:size()-1] <  MA2[j][i].DATA[MA2[j][i].DATA:size()-2])  or not S2)
									 and  ((S3 and MA3[j][i].DATA[MA3[j][i].DATA:size()-1] <  MA3[j][i].DATA[MA3[j][i].DATA:size()-2])  or not S3)
									 and  ((S4 and MA4[j][i].DATA[MA4[j][i].DATA:size()-1] <  MA4[j][i].DATA[MA4[j][i].DATA:size()-2])  or not S4)
									 and  ((S5 and MA5[j][i].DATA[MA5[j][i].DATA:size()-1] <  MA5[j][i].DATA[MA5[j][i].DATA:size()-2])  or not S5)
									then
									
										
										 
										Consensus[j]= Consensus[j]-1;	
										 
										
														  Color1 = Down1;									
															Style1= "\110";	
															
									else
									
														   Color1 = No1;									
															Style1= "\110";	
									 end 				
							 
							if Style1 ~= nil then
							core.host:execute("drawLabel1", id, Size*24 +Size*i,  core.CR_LEFT, VShift[j]     , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color1,   Style1 );			  
							id = id+1;
							end
							
						
					

end


function Update(period)
 
 	  
end

 
function Activate ( i , iFlag )
 
	  if Trend[i]==nil then
	  Trend[i]= iFlag
	  return;
	  end
	 
	 
		
	  if   not  ON[1] 
	  or Trend[i]==iFlag
	  then
	  return;
	  end
	  
	 
	  
	   
	       
						if 	iFlag== 1
                        and    Trend[i]~= 1						
						then
							  
									  
									  Trend[i]=1;
									     SoundAlert(Sound[1]);									
									     EmailAlert(   " Up Trend ", i );
									  
										 
										 Pop( " Up Trend " , i);  	
								 
									 
					  elseif iFlag== -1
					  and    Trend[i]~= -1				   
					  then			
							
							 
						   
											   Trend[i]=-1;
											 
											      SoundAlert(Sound[1]);	 											
											      EmailAlert( " Down Trend ", i);		
												 
												  Pop( " Down Trend ", i );  	
											 
					  elseif iFlag==0
					  and    Trend[i]~= 0				   
					  then			
							
							 
						   
											   Trend[i]=0;
											 
											   SoundAlert(Sound[1]);	 											
											   EmailAlert( " Neutral ", i);		
												
											   Pop(" Neutral ", i );  	
											 					
										
						 end			   
 		
	   
end			


function Pop( Subject, i)

  if not Show then
  return;
  end
  
  local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " .. Label[1]  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. Pair[i] ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;   
   
     
    local text = Note  .. delim ..  Symbol    .. delim .. Time;
 

   core.host:execute ("prompt", 1, profile:id(), tostring(text) );


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
	
	
 		 

	 
	if FLAG and cookie == 1
	then
	
	       --  MA1[j][i]:update(core.UpdateAll); 
		 for j = 1, Count, 1 do
		 for i = 1, Num, 1 do
		     MA1[j][i]:update(core.UpdateLast); 
			 MA2[j][i]:update(core.UpdateLast); 
			 MA3[j][i]:update(core.UpdateLast); 
			 MA4[j][i]:update(core.UpdateLast); 
			 MA5[j][i]:update(core.UpdateLast); 
	     end
         end		 
			 
	Calculate();	
	end
	
	
		
	if not FLAG then
	core.host:execute ("setStatus", "  Loading "..(  Count*Num  - iNumber) .. " / " ..  Count*Num );
    return;	
	else
	core.host:execute ("setStatus", "Loaded");	
	 instance:updateFrom(0);
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
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " .. Label[1]   .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. Pair[i] ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;   
   
     
    local text = Note  .. delim ..  Symbol    .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
 
end
	 
