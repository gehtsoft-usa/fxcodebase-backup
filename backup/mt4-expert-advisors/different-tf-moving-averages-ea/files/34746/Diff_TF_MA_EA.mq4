//+------------------------------------------------------------------+
//|                                                Diff_TF_MA_EA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define MAGICMA  203453610

extern int MA_Period=10;
extern int MA_Timeframe=240;
extern bool Reverse=false;
extern double Lots=0.1;
extern int Slippage=5;
extern int SL=0;
extern int TP=0;

datetime LastTime;
int MA_Period2;

int init()
  {
   LastTime=Time[0];
   MA_Period2=MA_Period*MA_Timeframe/Period();
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
int CalculateCurrentOrders(string symbol)
{
 int buys=0,sells=0;
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY)  buys++;
   if(OrderType()==OP_SELL) sells++;
  }
 }
 if(buys>0) return(buys);
 else       return(-sells);
}

void CloseOrders()
{
 bool res;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderType()==OP_BUY)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage);
   if (!res) Print("LastError = ",GetLastError());
  }
  if(OrderType()==OP_SELL)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage);
   if (!res) Print("LastError = ",GetLastError());
  }
 } 
 return;
}
  
void ChangeDir(int Dir)
{
 int res;
 double SL_Level, TP_Level;
 int CCO=CalculateCurrentOrders(Symbol());
 if (Dir==OP_BUY)
 {
  if (CCO<0) CloseOrders();
  if (CCO<=0)
  {
   if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Bid-SL*Point,Digits);
   if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Bid+TP*Point,Digits);
   res=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL_Level,TP_Level,"",MAGICMA,0,Blue);
   if (res==-1) Print("LastError = ",GetLastError());
  }
 }
 if (Dir==OP_SELL)
 {
  if (CCO>0) CloseOrders();
  if (CCO>=0)
  {
   if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Ask+SL*Point,Digits);
   if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Ask-TP*Point,Digits);
   res=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL_Level,TP_Level,"",MAGICMA,0,Blue);
   if (res==-1) Print("LastError = ",GetLastError());
  }
 }
 return;
}  

int start()
  {
   if (LastTime!=Time[0])
   {
    double MA_TF1=iMA(NULL, MA_Timeframe, MA_Period, 0, MODE_SMA, PRICE_CLOSE, 1);
    double MA_TF2=iMA(NULL, MA_Timeframe, MA_Period, 0, MODE_SMA, PRICE_CLOSE, 2);
    int bar1=iBarShift(NULL, 0, iTime(NULL, MA_Timeframe, 1), false);
    int bar2=iBarShift(NULL, 0, iTime(NULL, MA_Timeframe, 2), false);
    double MA1=iMA(NULL, 0, MA_Period2, 0, MODE_SMA, PRICE_CLOSE, bar1);
    double MA2=iMA(NULL, 0, MA_Period2, 0, MODE_SMA, PRICE_CLOSE, bar2);

    if (MA_TF2<MA2 && MA_TF1>MA1) if (!Reverse) ChangeDir(OP_BUY); else ChangeDir(OP_SELL);
    if (MA_TF2>MA2 && MA_TF1<MA1) if (!Reverse) ChangeDir(OP_SELL); else ChangeDir(OP_BUY);
    LastTime=Time[0];
   }
   return(0);
  }


