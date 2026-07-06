//+------------------------------------------------------------------+
//|                                                        iMax3.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 clrPeru
#property indicator_color4 clrPlum
#property indicator_color5 Gray
#property indicator_color6 Blue

extern double Ph1stepHPmodes=0.;
extern bool hpMode=true;
extern bool hpxMode=true;
extern bool iMAXmode=true;

double hpx0[], hpx1[], hp0[], hp1[], iMAX0[], iMAX1[];
double Ph1step;

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 if (hpxMode)
 {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_NONE);
 } 
 SetIndexBuffer(0,hpx0);
 SetIndexBuffer(1,hpx1);
 if (hpMode)
 {
  SetIndexStyle(2,DRAW_LINE);
  SetIndexStyle(3,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(3,DRAW_NONE);
 } 
 SetIndexBuffer(2,hp0);
 SetIndexBuffer(3,hp1);
 if (iMAXmode)
 {
  SetIndexStyle(4,DRAW_LINE);
  SetIndexStyle(5,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(4,DRAW_NONE);
  SetIndexStyle(5,DRAW_NONE);
 } 
 SetIndexBuffer(4,iMAX0);
 SetIndexBuffer(5,iMAX1);
 
 Ph1step=Ph1stepHPmodes;
 if (Period()==1) Ph1step=0.0001;        // m1
 if (Period()==5) Ph1step=0.00015;       // m5
 if (Period()==15) Ph1step=0.0003;       // m15
 if (Period()==30) Ph1step=0.0005;       // m30
 if (Period()==60) Ph1step=0.00075;      // H1
 if (Period()==240) Ph1step=0.0015;      // H4
 if (Period()==1440) Ph1step=0.003;      // D1
 if (Period()==10080) Ph1step=0.005;     // W1
 if (Period()==43200) Ph1step=0.01;      // MN

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
  hpx1[pos]=0.13785*(High[pos]+Low[pos]-(High[pos+1]+Low[pos+1])/2.)+0.0007*(High[pos+1]+Low[pos+1]-(High[pos+2]+Low[pos+2])/2.)+0.13785*(High[pos+2]+Low[pos+2]-(High[pos+3]+Low[pos+3])/2.)+1.2103*hpx0[pos+1]-0.4867*hpx0[pos+2];
  
  if (Close[pos]>hpx1[pos])
  {
   hpx0[pos]=hpx1[pos]+Ph1step;
  }
  else
  {
   hpx0[pos]=hpx1[pos]-Ph1step;
  }
  
  iMAX0[pos]=0.13785*(High[pos]+Low[pos]-(High[pos+1]+Low[pos+1])/2.)+0.0007*(High[pos+1]+Low[pos+1]-(High[pos+2]+Low[pos+2])/2.)+0.13785*(High[pos+2]+Low[pos+2]-(High[pos+3]+Low[pos+3])/2.)+1.2103*iMAX0[pos+1]-0.4867*iMAX0[pos+2];
  
  hp1[pos]=iMAX0[pos];
  iMAX1[pos]=iMAX0[pos+1];
  
  if (Close[pos]>iMAX0[pos])
  {
   hp0[pos]=iMAX0[pos]+Ph1step;
  }
  else
  {
   hp0[pos]=iMAX0[pos]-Ph1step;
  }

  pos--;
 } 
 return(0);
}

