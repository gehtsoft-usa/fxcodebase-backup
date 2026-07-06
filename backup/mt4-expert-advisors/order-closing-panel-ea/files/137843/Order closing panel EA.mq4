// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70476

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#define     NL    "\n" 

input int    ProfitTarget     = 25;             // closes all orders once profit hits this $ amount
input int    StopLoss         = 25;             // closes all orders once loss hits this $ amount
input bool   CloseAllNow      = false;          // closes all orders now
input bool   CloseProfitableTradesOnly = false; // closes only profitable trades
input double ProftableTradeAmount      = 1;     // Only trades above this amount close out
input bool   ClosePendingOnly = false;          // closes pending orders only
input bool   UseAlerts        = false;
input int x = 50; // Button X coordinate
input int y = 50; // Button Y coordinate

string buttonId;
string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      CloseAll();
   }
}

void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
   ObjectDelete(0,buttonID);
   ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
   ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
   ObjectSetString(0,buttonID,OBJPROP_FONT,font);
   ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
   ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
   ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
}

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("ocp");
   IndicatorShortName("Order closing panel");
   buttonId = IndicatorObjPrefix + "button";
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   createButton(buttonId, "Close all", 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   return 0;
}

//+----------------+
//| Custom DE-init |
//+----------------+
int deinit()
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   return 0;
}

//+------------------------------------------------------------------------+
//| Closes everything
//+------------------------------------------------------------------------+
void CloseAll()
{
   int i;
   bool result = false;

   // Close open positions first to lock in profit/loss
   for(i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i, SELECT_BY_POS)==false) continue;

      result = false;
      if ( OrderType() == OP_BUY)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 15, Red );
      if ( OrderType() == OP_SELL)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 15, Red );
      if (UseAlerts) PlaySound("alert.wav");
   }
   for(i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i, SELECT_BY_POS)==false) continue;

      result = false;
      if ( OrderType()== OP_BUYSTOP)  result = OrderDelete( OrderTicket() );
      if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
      if ( OrderType()== OP_BUYLIMIT)  result = OrderDelete( OrderTicket() );
      if ( OrderType()== OP_SELLLIMIT)  result = OrderDelete( OrderTicket() );
      if (UseAlerts) PlaySound("alert.wav");
   }
}
   
//+------------------------------------------------------------------------+
//| cancels all orders that are in profit
//+------------------------------------------------------------------------+
void CloseAllinProfit()
{
  for(int i=OrdersTotal()-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
        if ( OrderType() == OP_BUY && OrderProfit()+OrderSwap()>ProftableTradeAmount)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
        if ( OrderType() == OP_SELL && OrderProfit()+OrderSwap()>ProftableTradeAmount)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
        if (UseAlerts) PlaySound("alert.wav");
 }
  return; 
}

//+------------------------------------------------------------------------+
//| cancels all pending orders 
//+------------------------------------------------------------------------+
void ClosePendingOrdersOnly()
{
  for(int i=OrdersTotal()-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
        if ( OrderType()== OP_BUYSTOP)   result = OrderDelete( OrderTicket() );
        if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
  }
  return; 
  }

//+-----------+
//| Main      |
//+-----------+
int start()
{
   int      OrdersBUY;
   int      OrdersSELL;
   double   BuyLots, SellLots, BuyProfit, SellProfit;

//+------------------------------------------------------------------+
//  Determine last order price                                       |
//-------------------------------------------------------------------+
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
      if(OrderType()==OP_BUY)  
      {
         OrdersBUY++;
         BuyLots += OrderLots();
         BuyProfit += OrderProfit() + OrderCommission() + OrderSwap();
      }
      if(OrderType()==OP_SELL) 
      {
         OrdersSELL++;
         SellLots += OrderLots();
         SellProfit += OrderProfit() + OrderCommission() + OrderSwap();
      }
   }               
   
   if(CloseAllNow) CloseAll();
   
   if(CloseProfitableTradesOnly) CloseAllinProfit();
    
   if (BuyProfit+SellProfit >= ProfitTarget || BuyProfit + SellProfit <= -StopLoss)
      CloseAll();

   if(ClosePendingOnly) ClosePendingOrdersOnly();
       
   double margin = AccountMargin();
   Comment("                            Comments Last Update 12-12-2006 10:00pm", NL,
           "                            Buys    ", OrdersBUY, NL,
           "                            BuyLots        ", BuyLots, NL,
           "                            Sells    ", OrdersSELL, NL,
           "                            SellLots        ", SellLots, NL,
           "                            Balance ", AccountBalance(), NL,
           "                            Equity        ", AccountEquity(), NL,
           "                            Margin              ", margin, NL,
           "                            MarginPercent        ", margin == 0 ? 0 : MathRound((AccountEquity() / margin) * 100), NL,
           "                            Current Time is  ",TimeHour(CurTime()),":",TimeMinute(CurTime()),".",TimeSeconds(CurTime()));
   return 0;
} // start()

 

