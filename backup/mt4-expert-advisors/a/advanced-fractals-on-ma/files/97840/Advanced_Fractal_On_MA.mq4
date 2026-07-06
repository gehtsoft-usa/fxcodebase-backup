//+------------------------------------------------------------------+
//|                                       Advanced_Fractal_On_MA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Length=20;                      
extern int UP_Price=2;    // Applied price
                          // 0 - Close
                          // 1 - Open
                          // 2 - High
                          // 3 - Low
                          // 4 - Median
                          // 5 - Typical
                          // 6 - Weighted  
extern int DN_Price=3;    // Applied price
                          // 0 - Close
                          // 1 - Open
                          // 2 - High
                          // 3 - Low
                          // 4 - Median
                          // 5 - Typical
                          // 6 - Weighted  
extern int Frame=5; 
extern int ArrowSize=3;                         

double Up[], Dn[];
double Up_MA[], Dn_MA[];
int Shift;

int init()
{
 IndicatorShortName("Advanced fractal on MA");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,Up);
 SetIndexBuffer(1,Dn);   
 SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(0,234);
 SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(1,233);
 SetIndexEmptyValue(0,0.0);
 SetIndexEmptyValue(1,0.0);
 SetIndexLabel(0,"Fractal Up");
 SetIndexLabel(1,"Fractal Down");
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Up_MA);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Dn_MA);
 
 Shift=MathFloor((Frame-1)/2);

 return(0);
}

int deinit()
{

 return(0);
}

bool IsUpFr(int index)
{
 int i;
 bool Fr=true;
 for (i=1;i<=Shift;i++)
 {
  if (Up_MA[index]<=Up_MA[index+i] || Up_MA[index]<=Up_MA[index-i])
  {
   Fr=false;
  }
 }
 
 return (Fr);
}

bool IsDnFr(int index)
{
 int i;
 bool Fr=true;
 for (i=1;i<=Shift;i++)
 {
  if (Dn_MA[index]>=Dn_MA[index+i] || Dn_MA[index]>=Dn_MA[index-i])
  {
   Fr=false;
  }
 }
 
 return (Fr);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Up_MA[pos]=iMA(NULL, 0, Length, 0, Method, UP_Price, pos);
  Dn_MA[pos]=iMA(NULL, 0, Length, 0, Method, DN_Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (IsUpFr(pos+Shift))
  {
   Up[pos+Shift]=High[pos+Shift];
  }
  else
  {
   Up[pos+Shift]=0.;
  }

  if (IsDnFr(pos+Shift))
  {
   Dn[pos+Shift]=Low[pos+Shift];
  }
  else
  {
   Dn[pos+Shift]=0.;
  }

  pos--;
 }
   
 return(0);
}

