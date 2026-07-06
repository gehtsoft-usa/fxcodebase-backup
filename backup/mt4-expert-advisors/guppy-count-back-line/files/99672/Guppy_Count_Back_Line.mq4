//+------------------------------------------------------------------+
//|                                        Guppy_Count_Back_Line.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Navy
#property indicator_color3 Aqua
#property indicator_color4 Blue
#property indicator_color5 Red
#property indicator_color6 Green
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID

double Out1[], Out2[], Out3[], Out4[], Out5[], Out6[];
double V2[], V4[];

int init()
{
 IndicatorShortName("Guppy count back line");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Out1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Out2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Out3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,Out4);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,Out5);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,Out6);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,V2);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,V4);

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
 double V1, V3;
 pos=limit;
 while(pos>=0)
 {
  if (Low[pos+2]<Low[pos+1] && Low[pos+2]<Low[pos+3])
  {
   V1=1.;
  }
  else
  {
   V1=0.;
  }

  if (High[pos+2]>High[pos+1] && High[pos+1]>High[pos])
  {
   V2[pos+2]=1.;
  }
  else
  {
   V2[pos+2]=0.;
  }

  if (High[pos+2]>High[pos+1] && High[pos+2]>High[pos+3])
  {
   V3=1.;
  }
  else
  {
   V3=0.;
  }

  if (Low[pos+2]<Low[pos+1] && Low[pos+1]<Low[pos])
  {
   V4[pos+2]=1.;
  }
  else
  {
   V4[pos+2]=0.;
  }
  
  if (V1>0.5)
  {
   Out1[pos+2]=Low[pos+2];
  }
  else
  {
   Out1[pos+2]=Out1[pos+3];
  }
  
  if (V2[pos+4]>0.5 && V1>0.5)
  {
   Out2[pos+2]=High[pos+4];
  }
  else
  {
   Out2[pos+2]=Out2[pos+3];
  }
  
  if (V3>0.5)
  {
   Out3[pos+2]=High[pos+2];
  }
  else
  {
   Out3[pos+2]=Out3[pos+3];
  }
  
  if (V4[pos+4]>0.5 && V3>0.5)
  {
   Out4[pos+2]=Low[pos+4];
  }
  else
  {
   Out4[pos+2]=Out4[pos+3];
  }
  
  if (Out4[pos+2]<Out3[pos+2])
  {
   Out5[pos+2]=2.*Out4[pos+2]-Out3[pos+2];
  }
  else
  {
   Out5[pos+2]=EMPTY_VALUE;
  }
  
  if (Out2[pos+2]>Out1[pos+2])
  {
   Out6[pos+2]=2.*Out2[pos+2]-Out1[pos+2];
  }
  else
  {
   Out6[pos+2]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

