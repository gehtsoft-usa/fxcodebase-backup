//+------------------------------------------------------------------+
//|                                                          CMH.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Aqua
#property indicator_color2 Magenta

double CMH[], CMH_Dn[];
double hh[], ll[], lh[], hl[], swing[];

int init()
{
 IndicatorShortName("Clear Method Histogram");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,CMH);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,CMH_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,hh);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,ll);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,lh);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,hl);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,swing);

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
  if (pos==Bars-2)
  {
   swing[pos]=0.;
   hh[pos]=High[pos];
   lh[pos]=High[pos];
   hl[pos]=Low[pos];
   ll[pos]=Low[pos];
  }
  else
  {
   swing[pos]=swing[pos+1];
   hh[pos]=MathMax(High[pos], hh[pos+1]);
   lh[pos]=MathMin(High[pos], lh[pos+1]);
   hl[pos]=MathMax(Low[pos], hl[pos+1]);
   ll[pos]=MathMin(Low[pos], ll[pos+1]);
  }
  
  if (swing[pos]>0.)
  {
   if (High[pos]<hl[pos])
   {
    swing[pos]=-1.;
    ll[pos]=Low[pos];
    lh[pos]=High[pos];
   }
  }
  else
  {
   if (swing[pos]<0.)
   {
    if (Low[pos]>lh[pos])
    {
     swing[pos]=1.;
     hh[pos]=High[pos];
     hl[pos]=Low[pos];
    }
   }
   else
   {
    if (High[pos]<hl[pos])
    {
     swing[pos]=-1.;
     ll[pos]=Low[pos];
     lh[pos]=High[pos];
    }
    else
    {
     if (Low[pos]>hl[pos])
     {
      swing[pos]=1.;
      hh[pos]=High[pos];
      hl[pos]=Low[pos];
     }
    }
   }
  }
  
  if (swing[pos]>0.)
  {
   CMH[pos]=(High[pos]-hl[pos])/Point;
   CMH_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   if (swing[pos]<0.)
   {
    CMH[pos]=(lh[pos]-Low[pos])/Point;
    CMH_Dn[pos]=CMH[pos];
   }
  }

  pos--;
 } 
 return(0);
}

