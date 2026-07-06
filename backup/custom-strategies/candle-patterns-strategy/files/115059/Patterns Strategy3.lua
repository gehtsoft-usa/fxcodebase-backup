-- Id: 19094
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    strategy:name("Candle patterns Strategy");
    strategy:description("");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addInteger("EQ", "Maximum of pips distance between equal prices", "", 1, 0, 100);
    strategy.parameters:addBoolean("PAT_DOUBLE_INSIDE", "Enable Double Inside", "", true);
    strategy.parameters:addBoolean("PAT_INSIDE", "Enable Inside", "", true);
    strategy.parameters:addBoolean("PAT_OUTSIDE", "Enable Outside", "", true);
    strategy.parameters:addBoolean("PAT_PINUP", "Enable Pin Up", "", true);
    strategy.parameters:addBoolean("PAT_PINDOWN", "Enable Pin Down", "", true);
    strategy.parameters:addBoolean("PAT_PPRUP", "Enable Pivot Point Reversal Up", "", true);
    strategy.parameters:addBoolean("PAT_PPRDN", "Enable Pivot Point Reversal Down", "", true);
    strategy.parameters:addBoolean("PAT_DBLHC", "Enable Double Bar Low With A Higher Close", "", true);
    strategy.parameters:addBoolean("PAT_DBHLC", "Enable Double Bar High With A Lower Close", "", true);
    strategy.parameters:addBoolean("PAT_CPRU", "Enable Close Price Reversal Up", "", true);
    strategy.parameters:addBoolean("PAT_CPRD", "Enable Close Price Reversal Down", "", true);
    strategy.parameters:addBoolean("PAT_NB", "Enable Neutral Bar", "", true);
    strategy.parameters:addBoolean("PAT_FBU", "Enable Force Bar Up", "", true);
    strategy.parameters:addBoolean("PAT_FBD", "Enable Force Bar Down", "", true);
    strategy.parameters:addBoolean("PAT_MB", "Enable Mirror Bar", "", true);
    strategy.parameters:addBoolean("PAT_HAMMER", "Enable Hammer", "", true);
    strategy.parameters:addBoolean("PAT_SHOOTSTAR", "Enable Shooting Star", "", true);
    strategy.parameters:addBoolean("PAT_EVSTAR", "Enable Evening Star", "", true);
    strategy.parameters:addBoolean("PAT_MORNSTAR", "Enable Morning Star", "", true);
    strategy.parameters:addBoolean("PAT_EVDJSTAR", "Enable Evening Doji Star", "", true);
    strategy.parameters:addBoolean("PAT_MORNDJSTAR", "Enable Morning Doji Star", "", true);
    strategy.parameters:addBoolean("PAT_BEARHARAMI", "Enable Bearish Harami", "", true);
    strategy.parameters:addBoolean("PAT_BEARHARAMICROSS", "Enable Bearish Harami Cross", "", true);
    strategy.parameters:addBoolean("PAT_BULLHARAMI", "Enable Bullish Harami", "", true);
    strategy.parameters:addBoolean("PAT_BULLHARAMICROSS", "Enable Bullish Harami Cross", "", true);
    strategy.parameters:addBoolean("PAT_DARKCLOUD", "Enable Dark Cloud Cover", "", true);
    strategy.parameters:addBoolean("PAT_DOJISTAR", "Enable Doji Star", "", true);
    strategy.parameters:addBoolean("PAT_ENGBEARLINE", "Enable Engulfing Bearish Line", "", true);
    strategy.parameters:addBoolean("PAT_ENGBULLLINE", "Enable Engulfing Bullish Line", "", true);

    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct");
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct");
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse");

    Trading_Parameters();
end

local gSource = nil;

local PAT_NONE = 0;
local PAT_DOUBLE_INSIDE = 1;
local PAT_INSIDE = 2;
local PAT_OUTSIDE = 4;
local PAT_PINUP = 5;
local PAT_PINDOWN = 6;
local PAT_PPRUP = 7;
local PAT_PPRDN = 8;
local PAT_DBLHC = 9;
local PAT_DBHLC = 10;
local PAT_CPRU = 11;
local PAT_CPRD = 12;
local PAT_NB = 13;
local PAT_FBU = 14;
local PAT_FBD = 15;
local PAT_MB = 16;

local PAT_HAMMER=17;
local PAT_SHOOTSTAR=18;
local PAT_EVSTAR=19;
local PAT_MORNSTAR=20;
local PAT_BEARHARAMI=21;
local PAT_BEARHARAMICROSS=22;
local PAT_BULLHARAMI=23;
local PAT_BULLHARAMICROSS=24;
local PAT_DARKCLOUD=25;
local PAT_DOJISTAR=26;
local PAT_ENGBEARLINE=27;
local PAT_ENGBULLLINE=28;
local PAT_EVDJSTAR=29;
local PAT_MORNDJSTAR=30;

local EQ;


local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowMultiple;
local AllowTrade;
local Offer;
local CanClose;
local Account;
local Amount;
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TrailingStop;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;

function EnableTrading()
  local Day=core.dateToTable(core.now()).day;
  local DayT;
  local trades = core.host:findTable("closed trades");
  local enum = trades:enumerator();
  local PL=0;
  while true do
    local row = enum:next();
    if row == nil then break end
    if row.AccountID == Account then
      DayT=core.dateToTable(row.CloseTime).day;
      if Day==DayT then
        PL=PL+row.GrossPL; 
      end  
    end
  end  

  if PL>0 then
    return false;
  else
    return true;
  end
end


function DecodePattern(pattern)
    if pattern == PAT_NONE then
        return nil, nil, nil, nil;
    elseif pattern == PAT_DOUBLE_INSIDE and instance.parameters:getBoolean("PAT_DOUBLE_INSIDE")==true then
        return "DblIn", "Double Inside", true, 3;
    elseif pattern == PAT_INSIDE and instance.parameters:getBoolean("PAT_INSIDE")==true then
        return "In", "Inside", true, 2;
    elseif pattern == PAT_OUTSIDE and instance.parameters:getBoolean("PAT_OUTSIDE")==true then
        return "Out", "Outside", true, 2;
    elseif pattern == PAT_PINUP and instance.parameters:getBoolean("PAT_PINUP")==true then
        return "PnUp", "Pin Up", true, 2;
    elseif pattern == PAT_PINDOWN and instance.parameters:getBoolean("PAT_PINDOWN")==true then
        return "PnDn", "Pin Down", false, 2;
    elseif pattern == PAT_PPRUP and instance.parameters:getBoolean("PAT_PPRUP")==true then
        return "PPRU", "Pivot Point Reversal Up", false, 3;
    elseif pattern == PAT_PPRDN and instance.parameters:getBoolean("PAT_PPRDN")==true then
        return "PPRD", "Pivot Point Reversal Down", true, 3;
    elseif pattern == PAT_DBLHC and instance.parameters:getBoolean("PAT_DBLHC")==true then
        return "DBLHC", "Double Bar Low With A Higher Close", false, 2;
    elseif pattern == PAT_DBHLC and instance.parameters:getBoolean("PAT_DBHLC")==true then
        return "DBHLC", "Double Bar High With A Lower Close", true, 2;
    elseif pattern == PAT_CPRU and instance.parameters:getBoolean("PAT_CPRU")==true then
        return "CPRU", "Close Price Reversal Up", false, 3;
    elseif pattern == PAT_CPRD and instance.parameters:getBoolean("PAT_CPRD")==true then
        return "CPRD", "Close Price Reversal Down", true, 3;
    elseif pattern == PAT_NB and instance.parameters:getBoolean("PAT_NB")==true then
        return "NB", "Neutral Bar", true, 1;
    elseif pattern == PAT_FBU and instance.parameters:getBoolean("PAT_FBU")==true then
        return "FBU", "Force Bar Up", false, 1;
    elseif pattern == PAT_FBD and instance.parameters:getBoolean("PAT_FBD")==true then
        return "FBD", "Force Bar Down", true, 1;
    elseif pattern == PAT_MB and instance.parameters:getBoolean("PAT_MB")==true then
        return "MB", "Mirror Bar", true, 2;
    elseif pattern == PAT_HAMMER and instance.parameters:getBoolean("PAT_HAMMER")==true then
        return "HAMMER", "Hammer Pattern", true, 1;
    elseif pattern == PAT_SHOOTSTAR and instance.parameters:getBoolean("PAT_SHOOTSTAR")==true then
        return "SHOOTSTAR", "Shooting Star", true, 1;
    elseif pattern == PAT_EVSTAR and instance.parameters:getBoolean("PAT_EVSTAR")==true then
        return "EVSTAR", "Evening Star", true, 3;
    elseif pattern == PAT_MORNSTAR and instance.parameters:getBoolean("PAT_MORNSTAR")==true then
        return "MORNSTAR", "Morning Star", true, 3;
    elseif pattern == PAT_EVDJSTAR and instance.parameters:getBoolean("PAT_EVDJSTAR")==true then
        return "EVDJSTAR", "Evening Doji Star", true, 3;
    elseif pattern == PAT_MORNDJSTAR and instance.parameters:getBoolean("PAT_MORNDJSTAR")==true then
        return "MORNDJSTAR", "Morning Doji Star", true, 3;
    elseif pattern == PAT_BEARHARAMI and instance.parameters:getBoolean("PAT_BEARHARAMI")==true then
        return "BEARHARAMI", "Bearish Harami", true, 2;
    elseif pattern == PAT_BEARHARAMICROSS and instance.parameters:getBoolean("PAT_BEARHARAMICROSS")==true then
        return "BEARHARAMICROSS", "Bearish Harami Cross", true, 2;
    elseif pattern == PAT_BULLHARAMI and instance.parameters:getBoolean("PAT_BULLHARAMI")==true then
        return "BULLHARAMI", "Bullish Harami", true, 2;
    elseif pattern == PAT_BULLHARAMICROSS and instance.parameters:getBoolean("PAT_BULLHARAMICROSS")==true then
        return "BULLHARAMICROSS", "Bullish Harami Cross", true, 2;
    elseif pattern == PAT_DARKCLOUD and instance.parameters:getBoolean("PAT_DARKCLOUD")==true then
        return "DARKCLOUD", "Dark Cloud Cover", true, 2;
    elseif pattern == PAT_DOJISTAR and instance.parameters:getBoolean("PAT_DOJISTAR")==true then
        return "DOJISTAR", "Doji Star", true, 2;
    elseif pattern == PAT_ENGBEARLINE and instance.parameters:getBoolean("PAT_ENGBEARLINE")==true then
        return "ENGBEARLINE", "Engulfing Bearish Line", true, 2;
    elseif pattern == PAT_ENGBULLLINE and instance.parameters:getBoolean("PAT_ENGBULLLINE")==true then
        return "ENGBULLLINE", "Engulfing Bullish Line", true, 2;
    else
        return nil, nil, nil, nil;
    end
end

function RegisterPattern(period, pattern)
    local short, long, up, length;
    local price;
    short, long, up, length = DecodePattern(pattern);
    if length~=nil then
     if up then
      if instance.parameters.TypeSignal=="direct" then
        SELL(long);
      else
        BUY(long);
      end  
		 
     else
      if instance.parameters.TypeSignal=="direct" then
         BUY(long);
      else
        SELL(long);
      end   
     end
    end 
end


function Cmp(price1, price2)
    if math.abs(price1 - price2) < EQ then
        return 0;
    elseif price1 > price2 then
        return 1;
    else
        return -1;
    end
end

function Prepare(nameOnly)

   Initialization();

    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");

    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");
    
    EQ = instance.parameters.EQ * gSource:pipSize();

    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. ")";
    instance:name(name);
	
	 if nameOnly then
        return ;
    end
end

local O, H, L, C, T, B, BL, US, LS; 
local O1, H1, L1, C1, T1, B1, BL1, US1, LS1; 
local O2, H2, L2, C2, T2, B2, BL2, US2, LS2; 

-- when tick source is updated
function ExtUpdate(id, source, period)

     if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end

    if period <= 3 then
        return ;
    end

    if not(EnableTrading()) then
      return;
    end
    
    O=gSource.open[period];
    H=gSource.high[period];
    L=gSource.low[period];
    C=gSource.close[period];
    T=math.max(O,C);
    B=math.min(O,C);
    BL=T-B;
    US=H-T;
    LS=B-L;
    O1=gSource.open[period-1];
    H1=gSource.high[period-1];
    L1=gSource.low[period-1];
    C1=gSource.close[period-1];
    T1=math.max(O1,C1);
    B1=math.min(O1,C1);
    BL1=T1-B1;
    US1=H1-T1;
    LS1=B1-L1;
    O2=gSource.open[period-2];
    H2=gSource.high[period-2];
    L2=gSource.low[period-2];
    C2=gSource.close[period-2];
    T2=math.max(O2,C2);
    B2=math.min(O2,C2);
    BL2=T2-B2;
    US2=H2-T2;
    LS2=B2-L2;


-- 1 - candle patterns
    
    if Cmp(O, C) == 0 and US > math.max(EQ * 4, gSource:pipSize() * 4) and
       LS > math.max(EQ * 4, gSource:pipSize() * 4) then
     RegisterPattern(period, PAT_NB);
    end

    if C == H then
     RegisterPattern(period, PAT_FBU);
    end

    if C == L then
     RegisterPattern(period, PAT_FBD);
    end

    if US <= math.max(EQ, gSource:pipSize()) and LS>2.*BL then
     RegisterPattern(period, PAT_HAMMER);
    end

    if LS <= math.max(EQ, gSource:pipSize()) and US>2.*BL then
     RegisterPattern(period, PAT_SHOOTSTAR);
    end
    
-- 2 - candle patterns    

       if Cmp(H, H1) < 0 and Cmp(L, L1) > 0 then
           RegisterPattern(period, PAT_INSIDE);
       end
       
       if Cmp(H, H1) > 0 and Cmp(L, L1) < 0 then
           RegisterPattern(period, PAT_OUTSIDE);
       end
       
       if Cmp(H, H1) == 0 and Cmp(C, C1) < 0 and Cmp(L, L1) <= 0 then
           RegisterPattern(period, PAT_DBHLC);
       end
       
       if Cmp(L, L1) == 0 and Cmp(C, C1) > 0 and Cmp(H, H1) >= 0  then
           RegisterPattern(period, PAT_DBLHC);
       end
       
       if Cmp(BL1, BL) == 0 and Cmp(O1, C) == 0 then
           RegisterPattern(period, PAT_MB);
       end
       
       if Cmp(H,H1)<0 and Cmp(L,L1)>0 and Cmp(C1,O1)>0 and 
       Cmp(C,O)<0 and Cmp(BL1,BL)>0 and Cmp(C1,O)>0 and Cmp(O1,C)<0 then
           RegisterPattern(period, PAT_BEARHARAMI);
       end
       
       if Cmp(H,H1)<0 and Cmp(L,L1)>0 and Cmp(C1,O1)>0 and Cmp(O,C)==0 and
       Cmp(BL1,BL)>0 and Cmp(C1,O)>0 and Cmp(O1,C)<0 then
           RegisterPattern(period, PAT_BEARHARAMICROSS);
       end
       
       if Cmp(H,H1)<0 and Cmp(L,L1)>0 and Cmp(C1,O1)<0 and 
       Cmp(C,O)>0 and Cmp(BL1,BL)>0 and Cmp(C1,O)<0 and Cmp(O1,C)>0 then
           RegisterPattern(period, PAT_BULLHARAMI);
       end
       
       if Cmp(H,H1)<0 and Cmp(L,L1)>0 and Cmp(C1,O1)<0 and Cmp(O,C)==0 and
       Cmp(BL1,BL)>0 and Cmp(C1,O)<0 and Cmp(O1,C)>0 then
           RegisterPattern(period, PAT_BULLHARAMICROSS);
       end
       
       if Cmp(C1,O1)>0 and Cmp(C,O)<0 and Cmp(H1,O)<0 and Cmp(C,C1)<0 and Cmp(C,O1)>0 then
           RegisterPattern(period, PAT_DARKCLOUD);
       end
       
       if Cmp(O,C)==0 and ((Cmp(C1,O1)>0 and Cmp(O,H1)>0) or (Cmp(C1,O1)<0 and Cmp(O,L1)<0)) then
           RegisterPattern(period, PAT_DOJISTAR);
       end
       
       if Cmp(C1,O1)>0 and Cmp(C,O)<0 and Cmp(O,C1)>=0 and Cmp(C,O1)<0 then
           RegisterPattern(period, PAT_ENGBEARLINE);
       end
       
       if Cmp(C1,O1)<0 and Cmp(C,O)>0 and Cmp(O,C1)<=0 and Cmp(C,O1)>0 then
           RegisterPattern(period, PAT_ENGBULLLINE);
       end
       
       
-- 3 - candle patterns           

        if Cmp(H, H1) < 0 and Cmp(L, L1) > 0 and
           Cmp(H1, H2) < 0 and Cmp(L1, L2) > 0 then
            RegisterPattern(period, PAT_DOUBLE_INSIDE);
        end
        
        if Cmp(H1, H2) > 0 and Cmp(H1, H) > 0 and
           Cmp(L1, L2) > 0 and Cmp(L1, L) > 0 and
           BL1 * 2 < US1 then
            RegisterPattern(period, PAT_PINUP);
        end
        
        if Cmp(H1, H2) < 0 and Cmp(H1, H) < 0 and
           Cmp(L1, L2) < 0 and Cmp(L1, L) < 0 and
           BL1 * 2 < LS1 then
            RegisterPattern(period, PAT_PINDOWN);
        end
        
        if Cmp(H1, H2) > 0 and Cmp(H1, H) > 0 and
           Cmp(L1, L2) > 0 and Cmp(L1, L) > 0 and
           Cmp(C, L1) < 0 then
            RegisterPattern(period, PAT_PPRDN);
        end
        
        if Cmp(H1, H2) < 0 and Cmp(H1, H) < 0 and
           Cmp(L1, L2) < 0 and Cmp(L1, L) < 0 and
           Cmp(C, H1) > 0 then
            RegisterPattern(period, PAT_PPRUP);
        end
        
        if Cmp(H1, H2) < 0 and Cmp(L1, L2) < 0 and
           Cmp(H, H1) < 0 and Cmp(L, L1) < 0 and
           Cmp(C, C1) > 0 and Cmp(O, C) < 0 then
            RegisterPattern(period, PAT_CPRU);
        end
        
        if Cmp(H1, H2) > 0 and Cmp(L1, L2) > 0 and
           Cmp(H, H1) > 0 and Cmp(L, L1) > 0 and
           Cmp(C, C1) < 0 and Cmp(O, C) > 0 then
            RegisterPattern(period, PAT_CPRD);
        end
        
        if Cmp(C2,O2)>0 and Cmp(C1,O1)>0 and Cmp(C,O)<0 and Cmp(C2,O1)<0 and 
	Cmp(BL2,BL1)>0 and Cmp(BL1,BL)<0 and Cmp(C,O2)>0 and Cmp(C,C2)<0 then
	    RegisterPattern(period, PAT_EVSTAR);
	end
	
        if Cmp(C2,O2)<0 and Cmp(C1,O1)>0 and Cmp(C,O)>0 and Cmp(C2,O1)>0 and 
	Cmp(BL2,BL1)>0 and Cmp(BL1,BL)<0 and Cmp(C,C2)>0 and Cmp(C,O2)<0 then
	    RegisterPattern(period, PAT_MORNSTAR);
	end
	
        if Cmp(C2,O2)>0 and Cmp(C1,O1)==0 and Cmp(C,O)<0 and Cmp(C2,O1)<0 and 
	Cmp(BL2,BL1)>0 and Cmp(BL1,BL)<0 and Cmp(C,O2)>0 and Cmp(C,C2)<0 then
	    RegisterPattern(period, PAT_EVDJSTAR);
	end
	
        if Cmp(C2,O2)<0 and Cmp(C1,O1)==0 and Cmp(C,O)>0 and Cmp(C2,O1)>0 and 
	Cmp(BL2,BL1)>0 and Cmp(BL1,BL)<0 and Cmp(C,C2)>0 and Cmp(C,O2)<0 then
	    RegisterPattern(period, PAT_MORNDJSTAR);
	end

end



--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--


function BUY(Long)
         
		 if AllowTrade then
						
						       		if haveTrades('B')  and not  AllowMultiple then
										if     haveTrades('S')	 then
											exit('S');
											Signal ("Close Short");
										end	
											
						               return;
					              	end
						
					             	if ALLOWEDSIDE == "Sell"   then
										if     haveTrades('S')	 then
											exit('S');
											Signal ("Close Short");
										end	
										
						            return;
						              end 
						
								if haveTrades('S') then
								exit('S');
								Signal ("Close Short");
								end
								enter('B');
								Signal (Long .. " Open Long");
								
						elseif ShowAlert then
						         Signal ("Up Trend");		  
						end
						
		end   
    
	function SELL (Long)		
			           if AllowTrade then
						
						       if haveTrades('S')  and not  AllowMultiple then
									if     haveTrades('B') then
										exit('B');
										Signal ("Close Long");
									end
						         return;
						        end
						
						        if ALLOWEDSIDE == "Buy"  then
										if  haveTrades('B') then
										exit('B');
										Signal ("Close Long");
										end
										
						        return;
						        end



							
							if haveTrades('B') then
							exit('B');
							Signal ("Close Long");
							end
							enter('S');
							Signal (Long .. " Open Short");																				
						else  
							Signal ("Down Trend");	
						end				 
    
end


function Trading_Parameters()
    strategy.parameters:addGroup("Trading Parameters");
		
       strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	 strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
	
	 strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);

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

function Initialization()

	
	  AllowMultiple =  instance.parameters.AllowMultiple; 
	  ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE;
	
  
	
	
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


    AllowTrade = instance.parameters.AllowTrade;
    if AllowTrade then
        Account = instance.parameters.Account;
         Amount = instance.parameters.Amount;
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);	   
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
        SetLimit = instance.parameters.SetLimit;
        Limit = instance.parameters.Limit;
        SetStop = instance.parameters.SetStop;
        Stop = instance.parameters.Stop;
        TrailingStop = instance.parameters.TrailingStop;
    end


end


function Signal (Label)

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




function checkReady(table)
    local rc;
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true;
    else
        rc = core.host:execute("isTableFilled", table);
    end
    return rc;
end

function tradesCount(BuySell) 
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           count = count + 1;
        end
        row = enum:next();
    end

    return count
end


function haveTrades(BuySell) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end

    return found
end

-- enter into the specified direction
function enter(BuySell)
    if not(AllowTrade) then
        return true;
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 and not  AllowMultiple  then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;

    -- add stop/limit

        valuemap.PegTypeStop = "O";
		if SetStop then 
			if BuySell == "B" then
				valuemap.PegPriceOffsetPipsStop = -Stop;
			else
				valuemap.PegPriceOffsetPipsStop = Stop;
			end
		end
        if TrailingStop then
            valuemap.TrailStepStop = 1;
        end
 
        valuemap.PegTypeLimit = "O";
		if SetLimit then
			if BuySell == "B" then
				valuemap.PegPriceOffsetPipsLimit = Limit;
			else
				valuemap.PegPriceOffsetPipsLimit = -Limit;
			end
		end
    
        if (not CanClose) then
            valuemap.EntryLimitStop = 'Y'
        end


    success, msg = terminal:execute(100, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

-- exit from the specified direction
function exit(BuySell, use_net)
    if not (AllowTrade) then
        return true
    end

    if use_net == true then
        local valuemap, success, msg
        if tradesCount(BuySell) > 0 then
            valuemap = core.valuemap()

            -- switch the direction since the order must be in oppsite direction
            if BuySell == "B" then
                BuySell = "S"
            else
                BuySell = "B"
            end
            valuemap.OrderType = "CM"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "Y"
            valuemap.BuySell = BuySell
            success, msg = terminal:execute(101, valuemap)

            if not(success) then
               terminal:alertMessage(
                   instance.bid:instrument(),
                   instance.bid[instance.bid:size() - 1],
                   "Open order failed"..msg,
                   instance.bid:date(instance.bid:size() - 1)
               )
                return false
            end
            return true
        end
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if row.BS == BuySell and row.OfferID == Offer then
                local valuemap = core.valuemap();
                valuemap.BuySell = row.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = row.AccountID;
                valuemap.TradeID = row.TradeID;
                valuemap.Quantity = row.Lot;
                local success, msg = terminal:execute(101, valuemap);
            end
        row = enum: next();
        end
    end
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
		
		
		
