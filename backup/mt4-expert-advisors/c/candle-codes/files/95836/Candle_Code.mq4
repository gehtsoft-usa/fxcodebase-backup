//+------------------------------------------------------------------+
//|                                                  Candle_Code.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray

extern double Body_Size_Weight=32;
extern double Upper_Shadow_Weight=16;
extern double Lower_Shadow_Weight=16;
extern double Gap_Weight=8;
extern double Body_Color_Weight=32;
extern bool Show_Data=false;
extern bool Show_Single_Smoothing=true;
extern bool Show_Double_Smoothing=true;
extern int MA1_Length=21;
extern int MA1_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA2_Length=3;
extern int MA2_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA

double Raw[], One[], Two[];
double RawBody[], RawUpper[], RawLower[], RawGap[];

int init()
{
 IndicatorShortName("Candle Codes");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,One);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Two);
 if (Show_Data)
 {
  SetIndexStyle(2,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
 } 
 SetIndexBuffer(2,Raw);

 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,RawBody);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,RawUpper);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,RawLower);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,RawGap);

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
  RawBody[pos]=MathAbs(Close[pos]-Open[pos]);
  RawUpper[pos]=High[pos]-MathMax(Close[pos], Open[pos]);
  RawLower[pos]=MathMin(Close[pos], Open[pos])-Low[pos];
  RawGap[pos]=Open[pos]-Close[pos+1];

  pos--;
 } 
 
 double AvgShadow, AvgBodySize, AvgGap;
 AvgShadow=(iMAOnArray(RawLower, 0, Bars-2, 0, MODE_SMA, 0)+iMAOnArray(RawUpper, 0, Bars-2, 0, MODE_SMA, 0))/2.;
 AvgBodySize=iMAOnArray(RawBody, 0, Bars-2, 0, MODE_SMA, 0);
 AvgGap=iMAOnArray(RawGap, 0, Bars-2, 0, MODE_SMA, 0);
 
 double BodySize, UpperShadow, LowerShadow, Gap, BodyColor;
 pos=Bars-2;
 while(pos>=0)
 {
  if (MathAbs(Close[pos]-Open[pos])>=AvgBodySize*2.)
  {
   BodySize=Body_Size_Weight;
  }
  else
  {
   BodySize=Body_Size_Weight*MathAbs(Close[pos]-Open[pos])/(2.*AvgBodySize);
  }
  
  if (High[pos]-MathMax(Close[pos], Open[pos])>=AvgShadow*2.)
  {
   UpperShadow=Upper_Shadow_Weight;
  }
  else
  {
   UpperShadow=Upper_Shadow_Weight*(High[pos]-MathMax(Close[pos], Open[pos]))/(2.*AvgShadow);
  }
  
  if (MathMin(Close[pos], Open[pos])-Low[pos]>=AvgShadow*2.)
  {
   LowerShadow=Lower_Shadow_Weight;
  }
  else
  {
   LowerShadow=Lower_Shadow_Weight*(MathMin(Close[pos], Open[pos])-Low[pos])/(2.*AvgShadow);
  }
  
  Gap=Gap_Weight*(Open[pos]-Close[pos+1])/AvgGap;
  
  if (Close[pos]>Open[pos])
  {
   BodyColor=Body_Color_Weight;
  }
  else
  {
   if (Close[pos]<Open[pos])
   {
    BodyColor=-1.*Body_Color_Weight;
   }
   else
   {
    BodyColor=0.;
   }
  }
  
  Raw[pos]=BodyColor+BodySize+UpperShadow+LowerShadow+Gap;

  pos--;
 }  
 
 pos=Bars-2;
 while(pos>=0)
 {
  One[pos]=iMAOnArray(Raw, 0, MA1_Length, 0, MA1_Method, pos);

  pos--;
 }
   
 pos=Bars-2;
 while(pos>=0)
 {
  Two[pos]=iMAOnArray(One, 0, MA2_Length, 0, MA2_Method, pos);

  pos--;
 }
   
 return(0);
}

