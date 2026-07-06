//+------------------------------------------------------------------+
//|                                                    Super_SAR.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray

extern double Step=0.02;
extern double Max=0.2;
extern int Length=8;
extern double Multiplier=1.5;
extern bool Broader=false;
extern int DotSize=3;

double ArrowUp[], ArrowDn[], ArrowNe[];
double TrUP[], TrDN[];
double UP[], DN[], TR[];
int Flag;
bool SARFlag, STFlag;

int init()
{
 IndicatorShortName("Super SAR Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW, 0, DotSize);
 SetIndexBuffer(0,ArrowUp);
 SetIndexArrow(0,233);
 SetIndexStyle(1,DRAW_ARROW, 0, DotSize);
 SetIndexBuffer(1,ArrowDn);
 SetIndexArrow(1,234);
 SetIndexStyle(2,DRAW_ARROW, 0, DotSize);
 SetIndexBuffer(2,ArrowNe);
 SetIndexArrow(2,119);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,TrUP);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,TrDN);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,UP);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,DN);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,TR);

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
 double Median;
 double ATR;
 bool flag, flagh;
 pos=limit;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, Length, pos);
  Median=(High[pos]+Low[pos])/2.;
  
  UP[pos]=Median+ATR*Multiplier;
  DN[pos]=Median-ATR*Multiplier;
  
  if (Close[pos]>UP[pos+1])
  {
   TR[pos]=1.;
  }
  else
  {
   if (Close[pos]<DN[pos+1])
   {
    TR[pos]=-1.;
   }
   else
   {
    TR[pos]=TR[pos+1];
   }
  }
  
  if (TR[pos]<0. && TR[pos+1]>0.)
  {
   flag=true;
  }
  else
  {
   flag=false;
  }
  
  if (TR[pos]>0. && TR[pos+1]<0.)
  {
   flagh=true;
  }
  else
  {
   flagh=false;
  }
  
  if (TR[pos]>0. && DN[pos]<DN[pos+1])
  {
   DN[pos]=DN[pos+1];
  }
  
  if (TR[pos]<0. && UP[pos]>UP[pos+1])
  {
   UP[pos]=UP[pos+1];
  }
  
  if (flag)
  {
   UP[pos]=Median+ATR*Multiplier;
  }
  
  if (flagh)
  {
   DN[pos]=Median-ATR*Multiplier;
  }
  
  if (TR[pos]==1.)
  {
   TrUP[pos]=DN[pos];
   TrDN[pos]=0.;
  }
  else
  {
   TrDN[pos]=UP[pos];
   TrUP[pos]=0.;
  }

  pos--;
 } 
 
 double SAR0, SAR1;
 pos=limit;
 while(pos>=0)
 {
  SAR0=iSAR(NULL, 0, Step, Max, pos);
  SAR1=iSAR(NULL, 0, Step, Max, pos+1);
  
  if (Broader)
  {
   if (SAR0<Close[pos] && SAR1>Close[pos+1])
   {
    SARFlag=true;
   }
   else
   {
    if (SAR0>Close[pos] && SAR1<Close[pos+1])
    {
     SARFlag=false;
    }
   }
   
   if (TrUP[pos]>0.)
   {
    STFlag=true;
   }
   else
   {
    if (TrDN[pos]>0.)
    {
     STFlag=false;
    }
   }
   
   if (SARFlag && STFlag && Flag!=1)
   {
    ArrowUp[pos]=High[pos];
    Flag=1;
   }
   
   if (!SARFlag && !STFlag && Flag!=-1)
   {
    ArrowDn[pos]=Low[pos];
    Flag=-1;
   }
  }
  else
  {
   if (SAR0<Close[pos] && SAR1>Close[pos+1] && TrUP[pos]>0.)
   {
    ArrowUp[pos]=High[pos];
   }
   else
   {
    if (SAR0>Close[pos] && SAR1<Close[pos+1] && TrDN[pos]>0.)
    {
     ArrowDn[pos]=Low[pos];
    }
    else
    {
     if (SAR0<Close[pos] && SAR1>Close[pos+1])
     {
      ArrowNe[pos]=High[pos];
     }
     else
     {
      if (SAR0>Close[pos] && SAR1<Close[pos+1])
      {
       ArrowNe[pos]=Low[pos];
      }
     }
    }
   }
  }

  pos--;
 }
   
 return(0);
}

