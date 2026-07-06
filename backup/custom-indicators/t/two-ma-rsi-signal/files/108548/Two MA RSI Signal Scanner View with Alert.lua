-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=63960
 
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
	indicator:name("All Time Frames All Currency Pairs SSD Scanner View")
	indicator:description("All Time Frames All Currency Pairs SSD Scanner View")
	indicator:requiredSource(core.Bar)
	indicator:type(core.View)

	indicator.parameters:addGroup("Period")
	indicator.parameters:addString("Select", "Tag Data", "", "EUR/USD")
	indicator.parameters:setFlag("Select", core.FLAG_INSTRUMENTS)
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector", "Multiple currency pair");
	indicator.parameters:addStringAlternative(
		"Type",
		"Multiple currency pair",
		"Multiple currency pair",
		"Multiple currency pair"
	)
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair", "All currency pair")

    indicator.parameters:addGroup("1. MA Calculation");
	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
	
	
    indicator.parameters:addInteger("Period1", "Period", "", 10);
	
	indicator.parameters:addString("Method1", "Method", "Method" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");    
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");   
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("2. MA Calculation");
	
    indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addInteger("Period2", "Period", "", 20);
		
	indicator.parameters:addString("Method2", "Method", "Method" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");    
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");   
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("RSI Calculation");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
	 indicator.parameters:addInteger("Period", "Period", "", 30);
	 
	 
	 

	
	indicator.parameters:addString("UpdateType", "Update Type", "Update Type" , "EndOfTurn");
    indicator.parameters:addStringAlternative("UpdateType", "Live", "Live" , "Live");
    indicator.parameters:addStringAlternative("UpdateType", "End of Turn", "End of Turn" , "EndOfTurn");


    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	
 

   
	for i = 1, 20, 1 do
		indicator.parameters:addGroup(i .. ". Currency Pair ")
		Add(i)
	end

	indicator.parameters:addGroup("Time Frame Selector")
	AddTimeFrame(1, "m1", false)
	AddTimeFrame(2, "m5", false)
	AddTimeFrame(3, "m15", false)
	AddTimeFrame(4, "m30", false)
	AddTimeFrame(5, "H1", true)
	AddTimeFrame(6, "H2", false)
	AddTimeFrame(7, "H3", false)
	AddTimeFrame(8, "H4", false)
	AddTimeFrame(9, "H6", false)
	AddTimeFrame(10, "H8", false)
	AddTimeFrame(11, "D1", true)
	AddTimeFrame(12, "W1", true)
	AddTimeFrame(13, "M1", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Label Color", "Label Color",  core.COLOR_LABEL)
	indicator.parameters:addColor("UpColor", "Up Trend Color", "Label Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("DownColor", "Down Trend Color", "Label Color", core.rgb(255, 0, 0))	
	
	indicator.parameters:addColor("NeutralColor", "Neutral Color", "Neutral Color", core.COLOR_LABEL)
	indicator.parameters:addColor("SelectColor", "Select Color", "Select Color", core.rgb(128, 128, 128))
 

	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false)
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100)
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 60, 0, 100)

	--Up
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	ParametersAlert (1, "Cross")


	
end
 

function ParametersAlert ( id, Label , Flag)
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
	
	 
    indicator.parameters:addFile("Sound"..id, Label .. " Consensus Sound", "", "");
    indicator.parameters:setFlag("Sound"..id, core.FLAG_SOUND);

	
	 indicator.parameters:addString("Labels"..id, "Label", "", Label);


end 

function AddTimeFrame(id, FRAME, DEFAULT)
	indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT)
end

function getInstrumentList()
	local list = {}
	local point = {}

	local count = 0
	local row, enum

	enum = core.host:findTable("offers"):enumerator()
	row = enum:next()
	while row ~= nil do
		count = count + 1
		list[count] = row.Instrument
		point[count] = row.PointSize
		row = enum:next()
	end

	return list, count, point
end

function Add(id)
	local Init = {
		"EUR/USD",
		"USD/JPY",
		"GBP/USD",
		"USD/CHF",
		"EUR/CHF",
		"AUD/USD",
		"USD/CAD",
		"NZD/USD",
		"EUR/GBP",
		"EUR/JPY",
		"GBP/JPY",
		"CHF/JPY",
		"GBP/CHF",
		"EUR/AUD",
		"EUR/CAD",
		"AUD/CAD",
		"AUD/JPY",
		"CAD/JPY",
		"NZD/JPY",
		"GBP/CAD"
	}

	if id <= 5 then
		indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", true)
	else
		indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", false)
	end
	indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id])
	indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end

local Number=1; --Number of Alert
local Filter
local Show
local iTF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
local TF = {}
local Period
local pauto = "(%a%a%a)/(%a%a%a)"
local Color
local Source = {}
local Size
local transparency
local loading = {}
local source
local Pair = {}
local Count
local Type
local Dodaj = {}
local Point = {}
local Use = {}
local Num
local ShowCells
local UpColor, DownColor, NeutralColor
local OB, OS
local Select
local SelectColor
local Price
local Indicator = {}
--local OBColor, OSColor

local Price1, Period1, Method1, Price2, Period2, Method2, Price, Period;
	
 
local Sound = {};
local Label = {};
local ON = {};
local UpdateType;		
local LastSerial={};	
local PreviousSignal={};	
local Signal={};
local ToTime;
local FromLast={};
function Prepare(nameOnly)
	local name = profile:id()
	instance:name(name)
	if (nameOnly) then
		return
	end
	instance:initView("Stochastic", 2, 0.01, true, true)
	
	
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


	Size = instance.parameters.Size
	Mode = instance.parameters.Mode
--	OB = instance.parameters.OB
--	OS = instance.parameters.OS
	Select = instance.parameters.Select
	SelectColor = instance.parameters.SelectColor
	Type = instance.parameters.Type
	ShowCells = instance.parameters.ShowCells
	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor
	NeutralColor = instance.parameters.NeutralColor
 
 
	 
	source = instance.source
	
   Price1 = instance.parameters.Price1;
   Period1 = instance.parameters.Period1;
   Method1 = instance.parameters.Method1;
   Price2 = instance.parameters.Price2;
   Period2 = instance.parameters.Period2;
   Method2 = instance.parameters.Method2;
   Price = instance.parameters.Price;
   Period = instance.parameters.Period;
 
 
    assert(core.indicators:findIndicator("TWO MA RSI SIGNAL") ~= nil, "Please, download and install TWO MA RSI SIGNAL.LUA indicator");


	if Type == "Multiple currency pair" then
		Count = 0
		for i = 1, 20, 1 do
			Dodaj[i] = instance.parameters:getBoolean("Dodaj" .. i)
			if Dodaj[i] then
				Count = Count + 1
				Pair[Count] = instance.parameters:getString("Pair" .. i)
				Point[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize
			end
		end
	elseif Type == "All currency pair" then
		Pair, Count, Point = getInstrumentList()
	
	end

	Num = 0
	for i = 1, 13, 1 do
		Use[i] = instance.parameters:getBoolean("Use" .. i)

		if Use[i] then
			Num = Num + 1

			TF[Num] = iTF[i]
		end
	end

	local ID = 0
	Color = instance.parameters.Color

	for i = 1, Count, 1 do
		Source[i] = {}
		loading[i] = {}
		Indicator[i] = {}
		
        
        LastSerial[i]={};	
		PreviousSignal[i]={};	
		Signal[i]={};	
		FromLast[i]={};

		for j = 1, Num, 1 do
		
		
		   PreviousSignal[i][j]=nil;
		
		   
			ID = ID + 1

			Source[i][j] = core.host:execute("getHistory1", 20000 + ID, Pair[i], TF[j], 500, 0, true)
			loading[i][j] = true

			Indicator[i][j] = core.indicators:create("TWO MA RSI SIGNAL", Source[i][j] , true, Price1, Period1, Method1, Price2, Period2, Method2, Price, Period )
			
			
			 
		end
	end
 
	open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
	volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, "m1"); 

	instance:ownerDrawn(true)
	core.host:execute("setTimer", 1, 1)
	
	 Initialization();
	  
	  
end

function  Initialization ()
    UpdateType=instance.parameters.UpdateType;
	Show=instance.parameters.Show;
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
	
	 
		

end	



function ReleaseInstance()
	core.host:execute("killTimer", 1)
end

local added = false;
function AsyncOperationFinished(cookie)
	if not added then
		instance:addViewBar(core.host:execute("getServerTime"));
		core.host:trace("test");
		added = true;
	end
	local i
	local ID = 0
	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			ID = ID + 1
			if cookie == (20000 + ID) then
				loading[i][j] = false
			end
		end
	end

	local FLAG = false
	local iNumber = 0
	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			if loading[i][j] then
				FLAG = true
				iNumber = iNumber + 1
			end
		end
	end

	if not FLAG and cookie == 1 then
	
	
		for i = 1, Count, 1 do
			for j = 1, Num, 1 do
				Indicator[i][j]:update(core.UpdateLast)
				
				
				Activate ( i ,j );
				
			end
		end
		
		
	
	end

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. (Count * 13 - iNumber) .. " / " .. Count * 13)
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end


function FindLast ( i ,j )

local Last=Indicator[i][j].DATA:size() - 1;

	for k= Last, 0 ,-1 do

		if Indicator[i][j].DATA[k]~=  Indicator[i][j].DATA[Last] then
		FirstPeriod=k;
		break;
		end
	end

  
  FromLast[i][j]=Last-FirstPeriod;
  
  
end

function Activate ( i ,j )




	  
	if   Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 1]  == 1 then 
		
		 Signal[i][j]= 1  
	elseif  Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 1]  == -1 then
 
		
		 Signal[i][j]= -1 

	else 
		
		 Signal[i][j]= 0; 
	end
	
	
	FindLast ( i ,j  ) 
			 
	  
      if  Signal[i][j] == 0 then
	  return;
	  end
	  
	  if UpdateType == "EndOfTurn"
	  and LastSerial[i][j] ==Source[i][j]:serial(Source[i][j].close:size()-1)
	  then
	  return;  
	  end
	  
	 
	 
	 
	 
		
	  if   not  ON[1] 
	  then
	  return;
	  end
	  
	  
	       
						if Signal[i][j]== 1 
						and PreviousSignal[i][j]~= 1						
						then
							  
									     
										 
                                      
									     
										 if  PreviousSignal[i][j]~= nil then
										 SoundAlert(Sound[1]);									
									     EmailAlert(   " Up Trend ", i,j );
										 Pop(  " Up Trend " ,  i,j );  	
										 end
										 
										    PreviousSignal[i][j]=1;
											
										
						 LastSerial[i][j] =Source[i][j]:serial(Source[i][j].close:size()-1);				
									 
					  elseif  Signal[i][j]== -1 
					  and  PreviousSignal[i][j]~= -1				   
					  then			
							
							 
						   
											
											   
											   if  PreviousSignal[i][j]~= nil then
											   SoundAlert(Sound[1]);	 											
											   EmailAlert( " Down Trend ",  i,j );
											   Pop(  " Down Trend ",  i,j  );  	
											   end
											   
											   --Trend
											      PreviousSignal[i][j]=-1;
												  
												 
							 LastSerial[i][j] =Source[i][j]:serial(Source[i][j].close:size()-1);					 
												 
					
						 end			   
 		
	   
end			

local top, bottom
local left, right
local xGap
local yGap

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false
local iwidth, iheight;
function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	local Loading = false

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			if loading[i][j] then
				Loading = true
			end
		end
	end

	if Loading then
		return
	end
	
	top, bottom = context:top(), context:bottom()
	left, right = context:left(), context:right()

	xGap = (right - left) / (Count + 1)
	yGap = (bottom - top) / (Num + 2)
	

	if not init then
		context:createPen(1, context.SOLID, 1, Color)
		context:createSolidBrush(2, Color)
		context:createSolidBrush(3, SelectColor)

		transparency = context:convertTransparency(instance.parameters.transparency)

		init = true
	end
	
	iwidth = ((xGap / 7) / 100) * Size
	iheight = (yGap / 100) * Size

	context:createFont(7, "Arial", iwidth, iheight, context.ITALIC)
	

	

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			Calculate(context, i, j)
		end
	end
end

function Calculate(context, i, j)
	if not Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size() - 1)   then
		return
	end

	local Symbol = string.format("%." .. 2 .. "f", FromLast[i][j])
	local color1 = Neutral
	local color2 = -1

	if    Signal[i][j]== 1 then
		color1 = instance.parameters.UpColor; 
		
		 
	elseif    Signal[i][j]== -1 then
		color1 = instance.parameters.DownColor;  

	else
		color1 = NeutralColor 
	end

--OB  OS 
	y1 = bottom - j * yGap - yGap
	y2 = bottom - (j - 1) * yGap - yGap

	x1 = left + (i - 1) * xGap
	x2 = left + i * xGap

	

	if j == 1 then
		width, height = context:measureText(7, Pair[i], 0)
		context:drawText(7, Pair[i], Color, -1, x1, y2, x2, context:right(), 0)
	end

	if i == Count then
		width, height = context:measureText(7, TF[j], 0)
		context:drawText(7, TF[j], Color, -1, x2, y1, context:right(), y2, 0)
	end

	if ShowCells then
		context:drawRectangle(1, -1, x1, y1, x2, y2, transparency)
	end

	if Select == Pair[i] then
		context:drawRectangle(-1, 3, x1, y1, x2, y2, transparency)
	end

	width, height = context:measureText(7, Symbol, 0)
	context:drawText(7, Symbol, color1, color2, x1 + (x2 - x1) / 2 - width / 2, y1, x1 + (x2 - x1) / 2 + width / 2, y2, 0)
end





function SoundAlert(InternalSound)
  
   if not PlaySound then
   return;
   end
   
  terminal:alertSound(InternalSound, RecurrentSound);
end


function EmailAlert( Subject, i,j)

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " .. Label[1]   .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. Pair[i] .. " Time Frame : " .. TF[j] ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;   
   
     
    local text = Note  .. delim ..  Symbol    .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), tostring(text) );
 
end
	 
function Pop( Subject, i,j)

  if not Show then
  return;
  end
  
  local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " .. Label[1]  .. delim .. " Alert : " .. Subject ;   
    local Symbol= "Instrument : " .. Pair[i] .. " Time Frame : " .. TF[j] ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;   
   
     
    local text = Note  .. delim ..  Symbol    .. delim .. Time;
 

   core.host:execute ("prompt", 1, profile:id(), tostring(text) );


end