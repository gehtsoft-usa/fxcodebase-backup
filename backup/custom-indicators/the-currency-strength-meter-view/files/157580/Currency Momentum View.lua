-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75427

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
function Init()
    indicator:name("Currency Momentum View")
    indicator:description("Currency Momentum View")
    indicator:requiredSource(core.Bar)
    indicator:type(core.View)

    local TF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
    indicator.parameters:addGroup("1. Time Frame")
    indicator.parameters:addInteger("TF1", "Price Time Frame", "", 3)
    for i = 1, 13, 1 do
        indicator.parameters:addIntegerAlternative("TF1", TF[i], "", i)
    end

    indicator.parameters:addGroup("2. Time Frame")
    indicator.parameters:addInteger("TF2", "Price Time Frame", "", 5)
    for i = 1, 13, 1 do
        indicator.parameters:addIntegerAlternative("TF2", TF[i], "", i)
    end

    indicator.parameters:addGroup("3. Time Frame")
    indicator.parameters:addInteger("TF3", "Price Time Frame", "", 8)
    for i = 1, 13, 1 do
        indicator.parameters:addIntegerAlternative("TF3", TF[i], "", i)
    end

    indicator.parameters:addGroup("4. Time Frame")
    indicator.parameters:addInteger("TF4", "Price Time Frame", "", 11)
    for i = 1, 13, 1 do
        indicator.parameters:addIntegerAlternative("TF4", TF[i], "", i)
    end 
	
	
	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.COLOR_LABEL)
	indicator.parameters:addColor("Up", "Up Color", "Label Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Color", "Label Color", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Neutral Color", "Label Color", core.rgb(255, 165, 0))

	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100)
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 60, 0, 100)	

end

local TF = {}
--local Point = {} 
local Source = {}
local loading = {}
local source
local Pair = {}
local Num
 
local Pair = {
      "USD/JPY", "GBP/USD", "USD/CHF",  "EUR/USD", "NZD/USD", "AUD/USD", "USD/CAD"
}

local Instrument = {
     "USD", "EUR", "GBP",  "JPY", "CHF", "AUD",  "NZD", "CAD"
}
local pattern = "(%a%a%a)/(%a%a%a)";


local Count = #Pair
 
local tf = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
local PairPercentages={}; 
local PairCount={};

local InstrumentPercentages={};
local InstrumentCount={};

local FinalPercentages={};
local SortedArrayKey;
local FinalPercentagesMax;

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
	
	Size = instance.parameters.Size
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Neutral = instance.parameters.Neutral  
	Color = instance.parameters.Color	
    
    source = instance.source

    Num = 4
    for i = 1, 4, 1 do
        TF[i] = tf[instance.parameters:getInteger("TF" .. i)]
    end

    Color = instance.parameters.Color
    
    for i= 1, Count, 1 do   
        assert(core.host:findTable("offers"):find("Instrument", Pair[i]) ~= nil, "You must be subscribed to " .. Pair[i]);
    end

    local ID = 0
    for i = 1, Count, 1 do
        Source[Pair[i]] = {}
        loading[Pair[i]] = {}

        --Point[Pair[i]] = core.host:findTable("offers"):find("Instrument", Pair[i]).PointSize

        for j = 1, Num, 1 do
            ID = ID + 1
            Source[Pair[i]][j] = core.host:execute("getHistory1", 20000 + ID, Pair[i], TF[j], 2, 0, true)
            loading[Pair[i]][j] = true
        end
    end
	
	instance:ownerDrawn(true)
	core.host:execute("subscribeTradeEvents", 999, "offers")
	instance:initView("ACS", 0, 1, false, true)

	open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
	open:setVisible(false)

	core.host:execute("setTimer", 1, 1)	
end


function ReleaseInstance()
	core.host:execute("killTimer", 1)
end
 
function AsyncOperationFinished(cookie)
    local i
    local ID = 0
    for i = 1, Count, 1 do
        for j = 1, Num, 1 do
            ID = ID + 1
            if cookie == (20000 + ID) then
                loading[Pair[i]][j] = false
            end
        end
    end

    local FLAG = false
    local Number = 0
    for i = 1, Count, 1 do
        for j = 1, Num, 1 do
            if loading[Pair[i]][j] then
                FLAG = true
                Number = Number + 1
            end
        end
    end

 	if FLAG then
		core.host:execute("setStatus", Number .. " / " .. Count * Num)
	else
		core.host:execute("setStatus", "Loaded")
		for i = 1, Source[Pair[1]][1]:size() - 1 do
			instance:addViewBar(Source[Pair[1]][1]:date(i))
		end 
		for i = 1, Count, 1 do
			for j = 1, Num, 1 do
				CalculatePairPercentages(i, j)
			end
		end
		
				CalculateInstrumentPercentages();
				CalculateFinalPercentages();	 
				SortTheArray()
	end

	if cookie == 999 or cookie == 1 then
 
		for i = 1, Count, 1 do
			for j = 1, Num, 1 do
				CalculatePairPercentages(i, j)
			end
		end
				CalculateInstrumentPercentages();		
				CalculateFinalPercentages();
		        SortTheArray()
	end

	return core.ASYNC_REDRAW
end

function CalculateFinalPercentages() 


    FinalPercentagesMax=0; 
	for i= 1, #Instrument, 1 do
	    FinalPercentages[Instrument[i]]= InstrumentPercentages[Instrument[i]] /  InstrumentCount[Instrument[i]];
		if  FinalPercentages[Instrument[i]] > FinalPercentagesMax  then
		FinalPercentagesMax= FinalPercentages[Instrument[i]]
		end
	end
	
	return;

end

function CalculateInstrumentPercentages()

  	InstrumentPercentages={};
  	InstrumentCount={};


     for i= 1, Count, 1 do
	 
	     local Value=PairPercentages[Pair[i]] / PairCount[Pair[i]];
         
	 	 local First, Second= string.match( Pair[i], pattern);
		 
		 		Write(First, Value );
		 		Write(Second, -Value); 
	 
	 end
	 
 
return;
end

function Write(instrument, instrument_value)


                 if InstrumentPercentages[instrument]==nil then
				 InstrumentPercentages[instrument]=0;
				 InstrumentCount[instrument]=0;
                 end				 

                 InstrumentPercentages[instrument]= InstrumentPercentages[instrument]+instrument_value;
				 InstrumentCount[instrument]=InstrumentCount[instrument]+1;
end

function CalculatePairPercentages(i, j)
	
	
	if PairPercentages[Pair[i]]==nil or j==1 then
    PairPercentages[Pair[i]]=0;
    PairCount[Pair[i]]=0;	
	end
	
	 
       
  	if Source[Pair[i]][j].close:hasData(Source[Pair[i]][j].close:size() - 1) and
	Source[Pair[i]][j].close:hasData(Source[Pair[i]][j].close:size() - 2)
	then
	 
		
	PairPercentages[Pair[i]] = PairPercentages[Pair[i]] +	(Source[Pair[i]][j].close[Source[Pair[i]][j].close:size() - 1] -
                         	Source[Pair[i]][j].close[Source[Pair[i]][j].close:size() - 2]) /
							(Source[Pair[i]][j].close[Source[Pair[i]][j].close:size() - 2]/100) 
	PairCount[Pair[i]]=PairCount[Pair[i]]+1;			
 
	end
	

	return
end



local top, bottom
local left, right 
local yGap
local init = false

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end
 
function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	local Loading = false

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			if loading[Pair[i]][j] then
				Loading = true
			end
		end
	end

	if Loading then
		return
	end

	top, bottom = context:top(), context:bottom()
	left, right = context:left(), context:right()

 
	yGap = (bottom - top) / #Instrument

	width = (yGap/ 100) * Size;
	height = (yGap / 100) * Size;

	context:createFont(7, "Arial", width, height, 0)

	if not init then 
		transparency = context:convertTransparency(instance.parameters.transparency)
		context:createPen(11, context.SOLID, 1, core.COLOR_BACKGROUND); 		
		context:createSolidBrush(12, Up);
		context:createPen(21, context.SOLID, 1, core.COLOR_BACKGROUND);			
		context:createSolidBrush(22, Down); 
		init = true
	end

	DrawTheDraw (context) 
end

function DrawTheDraw (context)


					
	local x_central = left+(right-left)/ 2;
 
	for i= 1, #Instrument, 1 do 
			
			if FinalPercentages[ SortedArrayKey[i]] > 0 then
			Color1, Color2=11,12;
			else
			Color1, Color2=21,22;
			end	
			 
			
			y1=top + yGap*(i-1);
			y2=top + yGap*(i);
			y=y1+(y2-y1)/2
			x1=x_central;
			x2=x_central + x_central * (FinalPercentages[SortedArrayKey[i]] /(FinalPercentagesMax) ) ;	
		 		
			
			context:drawRectangle (Color1, Color2, x1, y1, x2, y2, transparency);
			
			
			
												 
			width, height = context:measureText (7, SortedArrayKey[i], context.CENTER  ); 	
			context:drawText (7,SortedArrayKey[i], Color, -1, x_central- width/2, y-height/2, x_central + width/2  , y+height/2, context.CENTER + context.VCENTER   );	
			 
			
	 
	
    end
	 				 
						 
end						 
						 

function SortTheArray() 
	 SortedArrayKey= BubbleSort(FinalPercentages );
return
end

function BubbleSort(Data)
 
 local Key={};
 local Temp;
 local Sort=true;
 
   
   for i=1, #Instrument, 1 do
   Key[i]=Instrument[i];
   end
   
   

     while Sort do
	 Sort=false;
   
				for i = 2, #Instrument , 1 do
						
						  if Data[Key[i]] <  Data[Key[i-1]] then
						   Sort=true;						
						   
                            Temp= Key[i];						   
							Key[i]=Key[i-1];
							Key[i-1]=Temp;							  
						  end
			  
			 end
	 
	 end
  
  return Key;
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75427

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 