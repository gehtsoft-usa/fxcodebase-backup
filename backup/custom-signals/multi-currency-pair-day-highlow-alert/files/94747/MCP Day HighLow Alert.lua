-- Id: 12095
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    strategy:name("Multi Currency Pair Day HighLow Alert");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Multi Currency Pair Day HighLow Alert");

    strategy.parameters:addGroup("Calculation");
	 strategy.parameters:addInteger("Period", "Update Period (in seconds)", "", 10);
    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", true);
	strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	 strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local first;
local ShowAlert;
local SoundFile; 
local Email;
local SendEmail;
local RecurrentSound;
local List, Count;
local Day;
local LastHigh={};
local LastLow={};
local Period;
function Prepare()
   
    ShowAlert = instance.parameters.ShowAlert;
	Period = instance.parameters.Period;
	 
   if PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end
	
	 SendEmail = instance.parameters.SendEmail;
	 RecurrentSound = instance.parameters.RecurrentSound;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    List, Count= getInstrumentList();

     
	
        local name = profile:id() .. "(" ..  instance.bid:instrument()    .. ")";
         instance:name(name);
 
 	
	 core.host:execute ("setTimer", 100, Period);
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



-- when tick source is updated
function ExtUpdate(id, source, period)	
 			 
							   
end


function checkReady(table)
    local rc; 
        rc = core.host:execute("isTableFilled", table);
 
    return rc;
end
 
	 
function Calculation()	

             if not(checkReady("offers")) then
            return ;
			end
    
	for i=1, Count, 1 do
	    
		local High = core.host:findTable("offers"):find("Instrument", List[i]).Hi;
		local Ask = core.host:findTable("offers"):find("Instrument",  List[i]).Ask;
		 
		 
		local Label=nil;
		local Price;
		
		if High~=LastHigh[i] then
		 LastHigh[i]=High;
		Label="New High of Day"
		Price=High;
		end
		
		if Low~=  LastLow[i] then
		LastLow[i]=Low;
		Label="New Low of Day"
		Price=Low;
		end
		
		if Label~= nil then
		Signal (Label, Price, List[i])
		end   
    end    
end

function ExtAsyncOperationFinished(cookie, success, message) 
	  if cookie== 100 then
	  Calculation();
	  end
 end 
 
 function Signal (Label,Price, Instrument)
    if ShowAlert then
        terminal:alertMessage(Instrument, Price,  Label, instance.bid:date(NOW));
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
        terminal:alertEmail(Email, Label, profile:id() .. "(" .. Instrument .. ")" .. Price..", " .. Label..", " .. instance.bid:date(NOW));
    end
end			
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
