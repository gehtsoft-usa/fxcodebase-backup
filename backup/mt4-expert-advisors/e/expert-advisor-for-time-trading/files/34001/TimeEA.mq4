//+------------------------------------------------------------------+
//|                                                       TimeEA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define MAGICMA  20043610

extern int OpenHour=1;
extern int OpenMin=0;
extern int CloseHour=6;
extern int CloseMin=0;
extern int Direction=0;
extern double Lots=0.1;
extern int Slippage=5;
extern int TP=0;
extern int SL=0;

int OpenTime, CloseTime;

int init()
  {
   OpenTime=OpenHour*60+OpenMin;
   CloseTime=CloseHour*60+CloseMin;
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
void CheckForOpen()
{
 double TP_Level, SL_Level;
 int res;
 if (CalculateCurrentOrders(Symbol())==0)
 {
  if (Direction==OP_BUY)
  {
   RefreshRates();
   if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Bid+TP*Point,Digits);
   if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Bid-SL*Point,Digits);
   res=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL_Level,TP_Level,"",MAGICMA,0,Blue);
   if (res==-1) Print("LastError = ",GetLastError());
  } 
  else
  {
   RefreshRates();
   if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Ask-TP*Point,Digits);
   if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Ask+SL*Point,Digits);
   res=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL_Level,TP_Level,"",MAGICMA,0,Blue);
   if (res==-1) Print("LastError = ",GetLastError());
  }
 }
 return;
}

void CheckForClose()
{
 bool res;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderType()==OP_BUY)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Bid,5);
   if (!res) Print("LastError = ",GetLastError());
  }
  if(OrderType()==OP_SELL)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Ask,5);
   if (!res) Print("LastError = ",GetLastError());
  }
 } 
 return;
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

int start()
  {
   datetime TC=TimeCurrent();
   int TimeNow=TimeHour(TC)*60+TimeMinute(TC);
   int Time0=TimeHour(Time[0])*60+TimeMinute(Time[0]);
   if (Time0<=OpenTime && TimeNow>=OpenTime) CheckForOpen();
   if (Time0<=CloseTime && TimeNow>=CloseTime) CheckForClose();
   return(0);
  }

