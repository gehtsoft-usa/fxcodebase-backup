//+------------------------------------------------------------------+
//|                                            ScreenShot_Orders.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern int ScreenShotWidth=1024;
extern int ScreenShotHeight=768;

double PrevOrderArray[][4], CurrOrderArray[][4];

string GetFileName()
{
 string T=TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS);
 T=StringSetChar(T,StringFind(T,":"),'.');
 T=StringSetChar(T,StringFind(T,":"),'.');
 string Str=Symbol()+"_"+T+".gif";
 return (Str);
}

int init()
  {
   GetOrderTable(PrevOrderArray);
   return(0);
  }
  
  
void GetOrderTable(double &OrderArray[][])
{
 ArrayResize(OrderArray,0);
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  int ArrSize=ArraySize(OrderArray)/4;
  ArrayResize(OrderArray,ArrSize+1);
  OrderArray[ArrSize][0]=OrderTicket();
  OrderArray[ArrSize][1]=OrderType();
  OrderArray[ArrSize][2]=OrderStopLoss();
  OrderArray[ArrSize][3]=OrderTakeProfit();
 }
 if (ArrSize>0) ArraySort(OrderArray);
 return; 
} 

bool CompareArrays(double Array1[][], double Array2[][])
{
 int Rows1=ArraySize(Array1)/4;
 int Rows2=ArraySize(Array2)/4;
 if (Rows1!=Rows2) return (false);
 for (int i=0;i<Rows1;i++)
 {
  if (Array1[i][0]!=Array2[i][0]) return (false);
  if (Array1[i][1]!=Array2[i][1]) return (false);
  if (Array1[i][2]!=Array2[i][2]) return (false);
  if (Array1[i][3]!=Array2[i][3]) return (false);
 }
 return (true);
}
  

int deinit()
  {

   return(0);
  }
  
int start()
  {
   string FileName;
   GetOrderTable(CurrOrderArray);
   if (!CompareArrays(PrevOrderArray,CurrOrderArray))
   {
    FileName=GetFileName();
    WindowScreenShot(FileName,ScreenShotWidth,ScreenShotHeight);
    GetOrderTable(PrevOrderArray);
   }
   return(0);
  }


