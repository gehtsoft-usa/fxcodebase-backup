//+------------------------------------------------------------------+
//|                                            Vortex_Difference.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Lime
#property indicator_color2 Green
#property indicator_color3 DarkOrange
#property indicator_color4 Red

extern int Length=14;

double H_UU[], H_UD[], H_DU[], H_DD[];
double iVIP[], iVIM[], _ATR[];

int init()
{
 IndicatorShortName("VORTEX Difference");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,H_UU);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,H_UD);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,H_DU);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,H_DD);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,iVIP);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,iVIM);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,_ATR);

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
  iVIP[pos]=MathAbs(High[pos]-Low[pos+1]);
  iVIM[pos]=MathAbs(Low[pos]-High[pos+1]);
  _ATR[pos]=iATR(NULL, 0, 1, pos);

  pos--;
 } 
 
 double svip, svim, satr;
 double VIP, VIM;
 pos=limit;
 while(pos>=0)
 {
  svip=iMAOnArray(iVIP, 0, Length, 0, MODE_SMA, pos);
  svim=iMAOnArray(iVIM, 0, Length, 0, MODE_SMA, pos);
  satr=iMAOnArray(_ATR, 0, Length, 0, MODE_SMA, pos);
  if (satr!=0.)
  {
   VIP=100.*svip/satr;
   VIM=100.*svim/satr;
   H_UU[pos]=VIP-VIM;
   if (H_UU[pos]>0.)
   {
    if (H_UU[pos]<H_UU[pos+1])
    {
     H_UD[pos]=H_UU[pos];
    }
   }
   else
   {
    if (H_UU[pos]>=H_UU[pos+1])
    {
     H_DU[pos]=H_UU[pos];
    }
    else
    {
     H_DD[pos]=H_UU[pos];
    }
   }
   
  }
  else
  {
   H_UU[pos]=EMPTY_VALUE;
   H_UD[pos]=EMPTY_VALUE;
   H_DU[pos]=EMPTY_VALUE;
   H_DD[pos]=EMPTY_VALUE;
  }

  pos--;
 }
   
 return(0);
}

