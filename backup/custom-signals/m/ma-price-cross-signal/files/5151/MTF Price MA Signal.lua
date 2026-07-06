-- Id: 5973
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+


local FRAMES={"H1", "H1"}
local TfNumber =2;

function Init() --The strategy profile initialization
    strategy:name("MTF Price/MA Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
    local i;
	
	 strategy.parameters:addGroup("Cross Type"); 
    strategy.parameters:addString("Cross" , "Method of Cross", "", "Cross");
    strategy.parameters:addStringAlternative("Cross" , "Cross", "", "Cross");
    strategy.parameters:addStringAlternative("Cross", "Touch", "", "Touch");
	
	for i = 1, TfNumber , 1 do
    TIMEFRAME(i, FRAMES[i] );
	end

    CreateTradingParameters();
end

function TIMEFRAME(id, FRAME)	
	local  Label;

	
	if id == 1 then
	Label= "Price"
	else
	Label= "MA"
	end	
	strategy.parameters:addGroup(Label);
	
	
	strategy.parameters:addString(tostring( id*100 + 1), "Time Frame", "", FRAME);
    strategy.parameters:setFlag( tostring(id*100  +1), core.FLAG_PERIODS);
	
	if id == 2 then
	strategy.parameters:addInteger(tostring( id*100 + 2), "MA Period", "", 34);
	
	strategy.parameters:addString(tostring( id*100 + 3), "Method", "Method" , "EMA");
    strategy.parameters:addStringAlternative(tostring( id*100 + 3), "MVA", "", "MVA");
    strategy.parameters:addStringAlternative(tostring( id*100 + 3), "EMA", "", "EMA");
    strategy.parameters:addStringAlternative(tostring( id*100 + 3), "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative(tostring( id*100 + 3), "TMA", "", "TMA");
    strategy.parameters:addStringAlternative(tostring( id*100 + 3), "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative(tostring( id*100 + 3), "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative(tostring( id*100 + 3), "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative(tostring( id*100 + 3), "Wilders*", "", "WMA");
	strategy.parameters:addStringAlternative(tostring( id*100 + 3) , "FRAMA", "", "FRAMA");

	
	strategy.parameters:addString(tostring( id*100 + 4), "Price Type", "", "close");
    strategy.parameters:addStringAlternative(tostring( id*100 + 4), "OPEN", "", "open");
    strategy.parameters:addStringAlternative(tostring( id*100 + 4), "HIGH", "", "high");
    strategy.parameters:addStringAlternative(tostring( id*100 + 4), "LOW", "", "low");
    strategy.parameters:addStringAlternative(tostring( id*100 + 4),"CLOSE", "", "close");
    strategy.parameters:addStringAlternative(tostring( id*100 + 4), "MEDIAN", "", "median");
    strategy.parameters:addStringAlternative(tostring( id*100 + 4), "TYPICAL", "", "typical");
    strategy.parameters:addStringAlternative(tostring( id*100 + 4), "WEIGHTED", "", "weighted");
		
	end

end

function CreateTradingParameters()
    strategy.parameters:addGroup("Signal Parameters");

     strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local SoundFile = nil;
local RecurrentSound = false;
local ShowAlert;
local Email;
local SendEmail;
local Cross;
local Indicator;
local Source={};
local Parameters={};


-- Don't need to store hour + minute + second for each time
local OpenTime, CloseTime, ExitTime;

--
function Prepare(nameOnly)
    
   Cross= instance.parameters.Cross;    
    

	local i;
	 local name;    
	
	 name = profile:id() .. "( " .. instance.bid:name();
		
	for i = 1, TfNumber , 1 do
	
	Parameters[tostring(i*100 + 1)]= instance.parameters:getString(tostring(i*100 + 1));
	
	
    assert(Parameters[tostring(i*100 + 1)] ~= "t1", "The time frame must not be tick");
	
   	
	Source[i] = ExtSubscribe(i, nil, Parameters[tostring(i*100 + 1)], instance.parameters.Type == "Bid", "bar");
			
			 if i == 2 then			 
			 Parameters[tostring(i*100 + 2)]= instance.parameters:getInteger(tostring(i*100 + 2));
			 Parameters[tostring(i*100 + 3)]= instance.parameters:getString(tostring(i*100 + 3));
			 Parameters[tostring(i*100 + 4)]= instance.parameters:getString(tostring(i*100 + 4));
			 
			  assert(core.indicators:findIndicator(Parameters[tostring(i*100 + 3)]) ~= nil, "Please download and install ".. Parameters[tostring(i*100 + 3)] .." Indicator!");
			 if Parameters[tostring(i*100 + 3)] == "FRAMA" then
    assert(core.indicators:findIndicator(Parameters[tostring(i*100 + 3)] ) ~= nil, Parameters[tostring(i*100 + 3)]  .. " indicator must be installed");
			  Indicator = core.indicators:create(Parameters[tostring(i*100 + 3)] , Source[i], Parameters[tostring(i*100 + 2)]   );
             else 			 
			 Indicator = core.indicators:create(Parameters[tostring(i*100 + 3)] , Source[i][Parameters[tostring(i*100 + 4)]], Parameters[tostring(i*100 + 2)]   );
			 end  
			 
		end	 
	
   end

    name = name  ..  " )";
    instance:name(name);


    -- NG: parsing of the time is moved to separate function
    
    PrepareTrading();

    if nameOnly then
        return ;
    end    

end

function PrepareTrading()


    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen");

    ShowAlert = instance.parameters.ShowAlert;
    RecurrentSound = instance.parameters.RecurrentSound;

    SendEmail = instance.parameters.SendEmail;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
    
end



function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.


    if id ~= 1 then
        return;
    end
	
    Indicator:update(core.UpdateLast);
	

    local FLAG = true;
	
	
	if Indicator.DATA:size() <=  Indicator.DATA:first() + 3  then
	 FLAG= false;
	end
	
	if  Source[1].close:size() <=  Source[1].close:first() + 3  then
	 FLAG= false;
	end
	

	if not FLAG then
	return;
	end		
		
		    if Cross == "Cross" then
		
					if  Source[1].close[ Source[1].close:size() -3]  <  Indicator.DATA[ Indicator.DATA:size()-3] 
					and Source[1].close[ Source[1].close:size() -2]  > Indicator.DATA[ Indicator.DATA:size()-2]   
					then   
							Signal("MA Price Crossover");
			     	elseif  Source[1].close[ Source[1].close:size() -3]  >  Indicator.DATA[ Indicator.DATA:size()-3] 
					and Source[1].close[ Source[1].close:size() -2]  < Indicator.DATA[ Indicator.DATA:size()-2] 
					then   		         	
							Signal("MA Price Crossunder");
					end	
		else
		
		
		
		                   if Source[1].high[ Source[1].high:size() -2] >  Indicator.DATA[Indicator.DATA:size()-2] 
             				and Source[1].low[ Source[1].low:size() -2]  < Indicator.DATA[Indicator.DATA:size()-2] then	
							Signal("MA Price Touch");							       
                           end
        end
		
  
end




function Signal(Label)
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],  Label, instance.bid:date(NOW));
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
        terminal:alertEmail(Email, Label, profile:id() .. "(" .. instance.bid:instrument() .. ")" .. instance.bid[NOW]..", " .. Label..", " .. instance.bid:date(NOW));
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



