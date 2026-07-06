//+------------------------------------------------------------------+
//|                                                          4MA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrChartreuse
#property indicator_color2 clrOliveDrab
#property indicator_color3 clrSlateBlue
#property indicator_color4 clrPaleVioletRed
#property indicator_color5 clrGreen
#property indicator_color6 clrRed

extern bool Show_Signals=true;
extern bool Test_AO=true;
extern int AO_Fast_Length=12;
extern int AO_Slow_Length=36;

extern bool Show_MA1=true;
extern int MA1_Length=12;
extern int MA1_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA1_Price=2;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted  

extern bool Show_MA2=true;
extern int MA2_Length=36;
extern int MA2_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA2_Price=3;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted  

extern bool Show_MA3=true;
extern int MA3_Length=36;
extern int MA3_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA3_Price=0;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted  

extern bool Show_MA4=true;
extern int MA4_Length=36;
extern int MA4_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA4_Price=2;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted  
extern int ArrowSize=3;                           

double MA1[], MA2[], MA3[], MA4[], Up[], Dn[];

int init()
{
 IndicatorShortName("Multiple Moving Average Cross");
 IndicatorDigits(Digits);
 if (Show_MA1)
 {
  SetIndexStyle(0,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
 } 
 SetIndexBuffer(0,MA1);
 if (Show_MA2)
 {
  SetIndexStyle(1,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(1,DRAW_NONE);
 } 
 SetIndexBuffer(1,MA2);
 if (Show_MA3)
 {
  SetIndexStyle(2,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
 } 
 SetIndexBuffer(2,MA3);
 if (Show_MA4)
 {
  SetIndexStyle(3,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(3,DRAW_NONE);
 } 
 SetIndexBuffer(3,MA4);
 SetIndexStyle(4,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(4,233);
 SetIndexBuffer(4,Up);
 SetIndexStyle(5,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(5,234);
 SetIndexBuffer(5,Dn);

 return(0);
}

int deinit()
{

 return(0);
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
  MA1[pos]=iMA(NULL, 0, MA1_Length, 0, MA1_Method, MA1_Price, pos);
  MA2[pos]=iMA(NULL, 0, MA2_Length, 0, MA2_Method, MA2_Price, pos);
  MA3[pos]=iMA(NULL, 0, MA3_Length, 0, MA3_Method, MA3_Price, pos);
  MA4[pos]=iMA(NULL, 0, MA4_Length, 0, MA4_Method, MA4_Price, pos);

  pos--;
 } 
 
 if (Show_Signals)
 {
  bool Up1, Dn1, Up2, Dn2, Up3, Dn3;
  pos=limit;
  while(pos>=0)
  {
//   Up1=false; Dn1=false;
//   Up2=false; Dn2=false;
//   Up3=false; Dn3=false;
   
   if (MA1[pos+1]<MA2[pos+1] && MA1[pos]>MA2[pos])
   {
    Up1=true;
    Dn1=false;
   }
   if (MA1[pos+1]<MA3[pos+1] && MA1[pos]>MA3[pos])
   {
    Up2=true;
    Dn2=false;
   }
   if (MA1[pos+1]<MA4[pos+1] && MA1[pos]>MA4[pos])
   {
    Up3=true;
    Dn3=false;
   }

   if (MA1[pos+1]>MA2[pos+1] && MA1[pos]<MA2[pos])
   {
    Dn1=true;
    Up1=false;
   }
   if (MA1[pos+1]>MA3[pos+1] && MA1[pos]<MA3[pos])
   {
    Dn2=true;
    Up2=false;
   }
   if (MA1[pos+1]>MA4[pos+1] && MA1[pos]<MA4[pos])
   {
    Dn3=true;
    Up3=false;
   }
   
   if (Test_AO)
   {
    double AO0, AO1;
    AO0=iMA(NULL, 0, AO_Fast_Length, 0, MODE_SMA, PRICE_MEDIAN, pos)-iMA(NULL, 0, AO_Slow_Length, 0, MODE_SMA, PRICE_MEDIAN, pos);
    AO1=iMA(NULL, 0, AO_Fast_Length, 0, MODE_SMA, PRICE_MEDIAN, pos+1)-iMA(NULL, 0, AO_Slow_Length, 0, MODE_SMA, PRICE_MEDIAN, pos+1);
    
    if (AO1<AO0 && Up1 && Up2)
    {
     Up[pos]=Low[pos];
     Up2=false;
    }
    if (AO1>AO0 && Dn3 && Dn2)
    {
     Dn[pos]=High[pos];
     Dn2=false;
    }
   }
   else
   {
    if (Up1 && Up2)
    {
     Up[pos]=Low[pos];
     Up2=false;
    }
    if (Dn3 && Dn2)
    {
     Dn[pos]=High[pos];
     Dn2=false;
    }
   }

   pos--;
  }
 } 
   
 return(0);
}

