//+------------------------------------------------------------------+
//|                                           TrailingTakeProfit.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

extern string TrailingSymbol=""; // if "" - all symbols
extern int TrailingTicket=0;     // if 0 - all tickets
extern int TP=100;
extern int TrailingStep=10;

double TP_Point, TrailingStep_Point;

int init()
  {
   TP_Point=TP*Point;
   TrailingStep_Point=TrailingStep*Point;
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 double OTP, NewOTP;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if (OrderSymbol()==TrailingSymbol || TrailingSymbol=="")
  {
   if (OrderTicket()==TrailingTicket || TrailingTicket==0)
   {
    OTP=OrderTakeProfit();
    if (OrderType()==OP_BUY)
    {
     if (OTP==0)
     {
      NewOTP=NormalizeDouble(Bid+TP_Point,Digits);
      OrderModify(OrderTicket(), 0, OrderStopLoss(), NewOTP, 0);
     }
     else
     {
      NewOTP=NormalizeDouble(Bid+TP_Point,Digits);
      if (OTP-NewOTP>=TrailingStep_Point)
      {
       NewOTP=OTP-MathFloor((OTP-NewOTP)/(TrailingStep_Point))*TrailingStep_Point;
       NewOTP=NormalizeDouble(NewOTP,Digits);
       OrderModify(OrderTicket(), 0, OrderStopLoss(), NewOTP, 0);
      } 
     }
    }
    if (OrderType()==OP_SELL)
    {
     if (OTP==0)
     {
      NewOTP=NormalizeDouble(Ask-TP_Point,Digits);
      OrderModify(OrderTicket(), 0, OrderStopLoss(), NewOTP, 0);
     }
     else
     {
      NewOTP=NormalizeDouble(Ask-TP_Point,Digits);
      if (NewOTP-OTP>=TrailingStep_Point)
      {
       NewOTP=OTP+MathFloor((NewOTP-OTP)/(TrailingStep_Point))*TrailingStep_Point;
       NewOTP=NormalizeDouble(NewOTP,Digits);
       OrderModify(OrderTicket(), 0, OrderStopLoss(), NewOTP, 0);
      } 
     }
    }
   }
  }
  
 }   
 return(0);
}

