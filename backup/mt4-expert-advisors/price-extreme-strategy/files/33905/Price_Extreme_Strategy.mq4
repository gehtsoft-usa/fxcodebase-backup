// Id: 6620
//+------------------------------------------------------------------+
//|                                       Price_Extreme_Strategy.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#define MAGICMA  1236467

extern int Multiplier=5;
extern bool EnableBUY=true;
extern bool EnableSELL=true;
extern bool Reverse=false;
extern double Lots=0.1;
extern int Slippage=5;
extern int SL=0;
extern int TP=0;

datetime LastTime;

int init()
  {
       double temp = iCustom(NULL, 0, "Price_Extreme_Indicator", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Price_Extreme_Indicator' indicator");
       return INIT_FAILED;
   }
   LastTime=Time[0];
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
int CloseOrders(int Operation)
{
 int res;
 int Count=0;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY)
   {
    if (Operation==OP_BUY) 
    {
     res=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage);
    }
    else
    {
     Count++;
    }
   }  
   if(OrderType()==OP_SELL)
   {
    if (Operation==OP_SELL) 
    {
     res=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage);
    }
    else
    {
     Count++;
    }
   }  
  }
 }
 return (Count);
}

void ChangeOrders(int Operation)
{
 int res;
 double PrSL, PrTP;
 int CountOrders;
 if (Operation==OP_BUY)
 {
  CountOrders=CloseOrders(OP_SELL);
  if (CountOrders==0 && EnableBUY)
  {
   if (SL==0) PrSL=0; else PrSL=NormalizeDouble(Bid-SL*Point,Digits);
   if (TP==0) PrTP=0; else PrTP=NormalizeDouble(Bid+TP*Point,Digits);
   res=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,PrSL,PrTP,"",MAGICMA,0,Blue);
  } 
 }
 else
 {
  CountOrders=CloseOrders(OP_BUY);
  if (CountOrders==0 && EnableSELL)
  {
   if (SL==0) PrSL=0; else PrSL=NormalizeDouble(Ask+SL*Point,Digits);
   if (TP==0) PrTP=0; else PrTP=NormalizeDouble(Ask-TP*Point,Digits);
   res=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,PrSL,PrTP,"",MAGICMA,0,Blue);
  } 
 } 
}

int start()
  {
   if (LastTime!=Time[0])
   {
    LastTime=Time[0];
    bool BullFl=false;
    bool BearFl=false;
    
    double HighBorder=iCustom(NULL, 0, "Price_Extreme_Indicator", Multiplier, 0, 1);
    double LowBorder=iCustom(NULL, 0, "Price_Extreme_Indicator", Multiplier, 1, 1);
    if (Close[1]>HighBorder) if (!Reverse) BullFl=true; else BearFl=true;
    if (Close[1]<LowBorder) if (!Reverse) BearFl=true; else BullFl=true;

    if (BullFl) ChangeOrders(OP_BUY);
    if (BearFl) ChangeOrders(OP_SELL);
   } 

   return(0);
  }


