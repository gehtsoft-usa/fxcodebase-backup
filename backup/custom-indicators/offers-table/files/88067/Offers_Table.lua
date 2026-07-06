-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58744
-- Id: 9621

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Offers table");
    indicator:description("Shows Bid and Ask prices for all instruments of the subscription list.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Position", "Position", "", "Right");
    indicator.parameters:addStringAlternative("Position", "Right", "", "Right");
    indicator.parameters:addStringAlternative("Position", "Left", "", "Left");
    indicator.parameters:addColor("color", "Text Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addColor("UPcolor", "UP Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100);
    indicator.parameters:addInteger("FontSize", "Font size", "0 - default", 0);
end

local first = 0;
local source = nil;
local OffersArray={};
local OffersSize;
local color, UPcolor, DNcolor;
local transparency;
local Offers_Left, Offers_Top;
local MaxOfferStr, MaxOfferLen, MaxAskStr, MaxAskLen;
local IntPositon;
local FontSize;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
    
    core.host:execute("subscribeTradeEvents", 2000, "offers");
    
    color = instance.parameters.color;
    FontSize = instance.parameters.FontSize;
    UPcolor = instance.parameters.UPcolor;
    DNcolor = instance.parameters.DNcolor;
    instance:setLabelColor(color);
    transparency = instance.parameters.transparency;
    if transparency == 100 then
        transparency = 255;
    elseif transparency == 0 then
        transparency = 0;
    else
        transparency = math.floor(255 * (transparency / 100.0) + 0.5);
    end
    OffersSize=0;
    core.host:execute("addCommand", 1000, "Move here", "Move here");
    Offers_Left, Offers_Top = 0, 0;
    MaxOfferLen=0;
    MaxAskLen=0;
    if instance.parameters.Position=="Right" then
     IntPosition=0;
    else
     IntPosition=1;
    end
end

function AddOffer(Data)
 local i;
 local Len;
 local arr={};
 for i=0,OffersSize-1,1 do
  if OffersArray[i].OfferID==Data.OfferID then
   arr=OffersArray[i];
   if Data.Ask~=arr.Ask then
    arr.oldAsk=arr.Ask;
    arr.Ask=Data.Ask; 
   end
   if Data.Bid~=arr.Bid then 
    arr.oldBid=arr.Bid;
    arr.Bid=Data.Bid;
   end 
   OffersArray[i]=arr;
   Len=string.len(Data.Instrument);
   if Len>MaxOfferLen then
    MaxOfferLen=Len;
    MaxOfferStr=Data.Instrument .. "   ";
   end
   Len=string.len(tostring(Data.Ask));
   if Len>MaxAskLen then
    MaxAskLen=Len;
    MaxAskStr=Data.Ask .. "   ";
   end
   return;
  end
 end
 OffersArray[OffersSize]=Data;
 Len=string.len(Data.Instrument);
 if Len>MaxOfferLen then
  MaxOfferLen=Len;
  MaxOfferStr=Data.Instrument .. "   ";
 end
 Len=string.len(tostring(Data.Ask));
 if Len>MaxAskLen then
  MaxAskLen=Len;
  MaxAskStr=Data.Ask .. "   ";
 end
 OffersSize=OffersSize+1;
 return;
end

function LoadOffers()
   local enum, row;
   local Ask, Bid, Instrument;
   local arr={};
   local Len;
   enum = core.host:findTable("offers"):enumerator();
   row = enum:next();
   while row ~= nil do
       Ask=row.Ask;
       Bid=row.Bid;
       Instrument=row.Instrument;
       arr.Ask=Ask;
       arr.Bid=Bid;
       arr.oldAsk=0;
       arr.oldBid=0;
       arr.Instrument=Instrument;
       arr.OfferID=row.OfferID;
       OffersArray[OffersSize]=arr;
       arr={};
       OffersSize = OffersSize + 1;
       Len=string.len(Instrument);
       if Len>MaxOfferLen then
        MaxOfferLen=Len;
        MaxOfferStr=Instrument .. "   ";
       end
       Len=string.len(tostring(Ask));
       if Len>MaxAskLen then
        MaxAskLen=Len;
        MaxAskStr=Ask .. "   ";
       end
       row = enum:next();
   end 
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 2000 then
         if OffersSize==0 then
         	LoadOffers();
         else
	         local offerID=message;
	         local offer = core.host:findTable("offers"):find("OfferID", offerID);
        	 local Ask=offer.Ask;
	         local Bid=offer.Bid;
        	 local Instrument=offer.Instrument;
	         local arr={};
        	 arr.Ask=Ask;
	         arr.Bid=Bid;
	         arr.oldAsk=0;
	         arr.oldBid=0;
        	 arr.Instrument=Instrument;
	         arr.OfferID=offerID;
        	 AddOffer(arr);
        end	 
    elseif cookie == 1000 then   
     local t, c;
     t, c = core.parseCsv(message, ";");
     if c >= 4 then
      Offers_Left = tonumber(t[2]);
      Offers_Top = tonumber(t[3]);
      IntPosition=1;
     end 
    end
end


function Update(period)

end

local init = false;

function Draw(stage, context)
    if stage == 2 then
        if not init then
           if FontSize==0 then
              context:createFont(1, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            else  
              context:createFont(1, "Arial", 0, FontSize, 0);
            end 
            init = true;
        end
        
        if MaxOfferLen==0 or MaxAskLen==0 then
         return;
        end
        local i;
        local colAsk, colBid;
        local Right=context:right();
        local OffersW, OffersH=context:measureText(1, MaxOfferStr, context.LEFT);
        local AskW=context:measureText(1, MaxAskStr, context.LEFT);
        for i=0,OffersSize-1,1 do
         if OffersArray[i].oldAsk==0 then
          colAsk=color;
         elseif OffersArray[i].oldAsk<OffersArray[i].Ask then
          colAsk=UPcolor;
         else
          colAsk=DNcolor;
         end
         if OffersArray[i].oldBid==0 then
          colBid=color;
         elseif OffersArray[i].oldBid<OffersArray[i].Bid then
          colBid=UPcolor;
         else
          colBid=DNcolor;
         end
         if IntPosition==0 then
          context:drawText(1, OffersArray[i].Instrument, color, -1, Right-2*AskW-OffersW, Offers_Top+(i+3)*OffersH, Right-2*AskW, Offers_Top+(i+4)*OffersH, context.LEFT, transparency);
          context:drawText(1, OffersArray[i].Bid, colBid, -1, Right-2*AskW, Offers_Top+(i+3)*OffersH, Right-AskW, Offers_Top+(i+4)*OffersH, context.LEFT, transparency);
          context:drawText(1, OffersArray[i].Ask, colAsk, -1, Right-AskW, Offers_Top+(i+3)*OffersH, Right, Offers_Top+(i+4)*OffersH, context.LEFT, transparency);
         else
          context:drawText(1, OffersArray[i].Instrument, color, -1, Offers_Left, Offers_Top+(i+3)*OffersH, Offers_Left+OffersW, Offers_Top+(i+4)*OffersH, context.LEFT, transparency);
          context:drawText(1, OffersArray[i].Bid, colBid, -1, Offers_Left+OffersW, Offers_Top+(i+3)*OffersH, Offers_Left+OffersW+AskW, Offers_Top+(i+4)*OffersH, context.LEFT, transparency);
          context:drawText(1, OffersArray[i].Ask, colAsk, -1, Offers_Left+OffersW+AskW, Offers_Top+(i+3)*OffersH, Offers_Left+OffersW+2*AskW, Offers_Top+(i+4)*OffersH, context.LEFT, transparency);
         end 
        end
        
    end
end



