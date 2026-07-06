//+------------------------------------------------------------------+
//|                                                 SimpleSAR_EA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define MAGICMA  3567510

extern int SAR_Step=300;
extern int TrailingStep=50;
extern double Lots=0.1;

int TicketB, TicketS, TicketBS, TicketSS;

double SAR_Step_Point, TrailingStep_Point;

int init()
  {
   SAR_Step_Point=SAR_Step*Point;
   TrailingStep_Point=TrailingStep*Point;
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
void CalculateCurrentOrders(string symbol)
{
 TicketB=0; TicketS=0; TicketBS=0; TicketSS=0;
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY) TicketB=OrderTicket();
   if(OrderType()==OP_SELL) TicketS=OrderTicket();
   if(OrderType()==OP_BUYSTOP) TicketBS=OrderTicket();
   if(OrderType()==OP_SELLSTOP) TicketSS=OrderTicket();
  }
 }
 return;
}
  

int start()
  {
   int res;
   double Old_Level, New_Level, P_Level;
   CalculateCurrentOrders(Symbol());
   
   if (TicketB>0)
   {
    if (OrderSelect(TicketB,SELECT_BY_TICKET,MODE_TRADES))
    {
     New_Level=NormalizeDouble(Bid-SAR_Step_Point,Digits);
     Old_Level=OrderStopLoss();
     if (New_Level-Old_Level>=TrailingStep_Point)
     {
      New_Level=Old_Level+MathFloor((New_Level-Old_Level)/TrailingStep_Point)*TrailingStep_Point;
      New_Level=NormalizeDouble(New_Level,Digits);
      OrderModify(OrderTicket(), 0, New_Level, 0, 0);
      P_Level=NormalizeDouble(New_Level+SAR_Step_Point-Bid+Ask,Digits);
      if (TicketSS==0)
      {
       res=OrderSend(Symbol(),OP_SELLSTOP,Lots,New_Level,0,P_Level,0,"",MAGICMA,0,Blue);
      }
      else
      {
       if (OrderSelect(TicketSS,SELECT_BY_TICKET,MODE_TRADES))
       {
        OrderModify(OrderTicket(), New_Level, P_Level, 0, 0);
       }
      }
     }
    } 
   }
   
   if (TicketS>0)
   {
    if (OrderSelect(TicketS,SELECT_BY_TICKET,MODE_TRADES))
    {
     New_Level=NormalizeDouble(Ask+SAR_Step_Point,Digits);
     Old_Level=OrderStopLoss();
     if (Old_Level-New_Level>=TrailingStep_Point)
     {
      New_Level=Old_Level-MathFloor((Old_Level-New_Level)/TrailingStep_Point)*TrailingStep_Point;
      New_Level=NormalizeDouble(New_Level,Digits);
      OrderModify(OrderTicket(), 0, New_Level, 0, 0);
      P_Level=NormalizeDouble(New_Level-SAR_Step_Point-Ask+Bid,Digits);
      if (TicketBS==0)
      {
       res=OrderSend(Symbol(),OP_BUYSTOP,Lots,New_Level,0,P_Level,0,"",MAGICMA,0,Blue);
      }
      else
      {
       if (OrderSelect(TicketBS,SELECT_BY_TICKET,MODE_TRADES))
       {
        OrderModify(OrderTicket(), New_Level, P_Level, 0, 0);
       }
      }
     }
    } 
   }
   
   if (TicketB==0 && TicketS==0)
   {
    New_Level=NormalizeDouble(Ask+MathFloor(SAR_Step/2)*Point,Digits);
    P_Level=NormalizeDouble(New_Level-SAR_Step_Point-Ask+Bid,Digits);
    if (TicketBS==0)
    {
     res=OrderSend(Symbol(),OP_BUYSTOP,Lots,New_Level,0,P_Level,0,"",MAGICMA,0,Blue);
    }
    else
    {
     if (OrderSelect(TicketBS,SELECT_BY_TICKET,MODE_TRADES))
     {
      Old_Level=OrderOpenPrice();
      if (Old_Level-New_Level>=TrailingStep_Point)
      {
       New_Level=Old_Level-MathFloor((Old_Level-New_Level)/TrailingStep_Point)*TrailingStep_Point;
       New_Level=NormalizeDouble(New_Level,Digits);
       OrderModify(OrderTicket(), New_Level, P_Level, 0, 0);
      }
     }
    }
    New_Level=NormalizeDouble(Bid-MathCeil(SAR_Step/2)*Point,Digits);
    P_Level=NormalizeDouble(New_Level+SAR_Step_Point-Bid+Ask,Digits);
    if (TicketSS==0)
    {
     res=OrderSend(Symbol(),OP_SELLSTOP,Lots,New_Level,0,P_Level,0,"",MAGICMA,0,Blue);
    }
    else
    {
     if (OrderSelect(TicketSS,SELECT_BY_TICKET,MODE_TRADES))
     {
      Old_Level=OrderOpenPrice();
      if (New_Level-Old_Level>=TrailingStep_Point)
      {
       New_Level=Old_Level+MathFloor((New_Level-Old_Level)/TrailingStep_Point)*TrailingStep_Point;
       New_Level=NormalizeDouble(New_Level,Digits);
       OrderModify(OrderTicket(), New_Level, P_Level, 0, 0);
      }
     }
    }
   }
   
   return(0);
  }

