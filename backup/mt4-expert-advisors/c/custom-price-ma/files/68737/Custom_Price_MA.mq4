//+------------------------------------------------------------------+
//|                                              Custom_Price_MA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern double Coeff_Open=1;
extern double Coeff_High=0;
extern double Coeff_Low=0;
extern double Coeff_Close=0;
extern int Length=20;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double CP[], CP_MA[];
double Sum_Coeff;

int init()
{
 IndicatorShortName("Custom price moving average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CP_MA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,CP);
 Sum_Coeff=Coeff_Open+Coeff_High+Coeff_Low+Coeff_Close;
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=2) return(0);
 if (Sum_Coeff==0) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  CP[pos]=(Coeff_Open*Open[pos]+Coeff_High*High[pos]+Coeff_Low*Low[pos]+Coeff_Close*Close[pos])/Sum_Coeff;
  pos--;
 } 
 pos=limit;
 while(pos>=0)
 {
  CP_MA[pos]=iMAOnArray(CP, 0, Length, 0, Method, pos);
  pos--;
 }  
 return(0);
}

