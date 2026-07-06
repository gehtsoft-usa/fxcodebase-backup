//+------------------------------------------------------------------+
//|                                                Close_At_Time.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

input bool Specified_Order=false;
input string Order_Number="";
input bool Specified_Symbol=false;
input string Symbol_For_Close="";
input bool Close_Buy=true;
input bool Close_Sell=true;
input string Close_Time=""; // format: yyyy.mm.dd hh:mi  

datetime _Close_Time;

int OnInit()
{
 _Close_Time=StringToTime(Close_Time);
 if (_Close_Time<=TimeCurrent())
 {
  _Close_Time=0;
  Alert("The specified time has passed");
 }

 return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{
 if (_Close_Time>Time[1] && _Close_Time<=TimeCurrent())
 {
  double _Pr;
  int OT=OrdersTotal();
  for (int i=OT-1;i>=0;i--)
  {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
   
   if ((Specified_Order && OrderTicket()==Order_Number) || (!Specified_Order && ((Specified_Symbol && OrderSymbol()==Symbol_For_Close) || !Specified_Symbol) && ((Close_Buy && OrderType()==OP_BUY) || (Close_Sell && OrderType()==OP_SELL))))
   {
    if(OrderType()==OP_BUY)  
    {
     _Pr=MarketInfo(OrderSymbol(), MODE_BID);
     OrderClose(OrderTicket(), OrderLots(), _Pr, 5);
    }
     
    if(OrderType()==OP_SELL) 
    {
     _Pr=MarketInfo(OrderSymbol(), MODE_ASK);
     OrderClose(OrderTicket(), OrderLots(), _Pr, 5);
    } 
   }
 }
  
 }
}

