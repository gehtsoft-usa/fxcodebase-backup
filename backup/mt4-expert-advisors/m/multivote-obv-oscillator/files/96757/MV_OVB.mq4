//+------------------------------------------------------------------+
//|                                                       MV_OVB.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

double MV_OVB_Up[], MV_OVB_Dn[];

int init()
{
 IndicatorShortName("MultiVote OBV");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,MV_OVB_Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,MV_OVB_Dn);

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
 double HV, LV, CV, TV;
 double MV_OVB;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   MV_OVB_Up[pos]=0.;
   MV_OVB_Dn[pos]=0.;
  }
  else
  {
   if (High[pos]>High[pos+1])
   {
    HV=1.;
   }
   else
   {
    if (High[pos]<High[pos+1])
    {
     HV=-1.;
    }
   }

   if (Low[pos]>Low[pos+1])
   {
    LV=1.;
   }
   else
   {
    if (Low[pos]<Low[pos+1])
    {
     LV=-1.;
    }
   }

   if (Close[pos]>Close[pos+1])
   {
    CV=1.;
   }
   else
   {
    if (Close[pos]<Close[pos+1])
    {
     CV=-1.;
    }
   }
  
   TV=HV+LV+CV;
  
   MV_OVB=(MV_OVB_Up[pos+1]+MV_OVB_Dn[pos+1])+Volume[pos]*TV;
   if (MV_OVB>0.)
   {
    MV_OVB_Up[pos]=MV_OVB;
    MV_OVB_Dn[pos]=0.;
   }
   else
   {
    MV_OVB_Up[pos]=0.;
    MV_OVB_Dn[pos]=MV_OVB;
   }
  }

  pos--;
 } 
 return(0);
}

