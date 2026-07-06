//+------------------------------------------------------------------+
//|                                                      CCI_Bar.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 clrLawnGreen
#property indicator_color2 clrLimeGreen
#property indicator_color3 clrOrangeRed
#property indicator_color4 clrMaroon
#property indicator_color5 clrDarkGray
#property indicator_color6 clrGray
#property indicator_color7 clrChocolate
#property indicator_color8 clrYellow

extern int CCI_Period=14;
 
extern int Price=5;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern double Overbought_Level=100;
extern double Oversold_Level=-100;

double UpOB[], DnOB[], UpOS[], DnOS[], UpOF[], DnOF[], UpUF[], DnUF[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UpOB);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DnOB);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,UpOS);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,DnOS);
 SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexBuffer(4,UpOF);
 SetIndexStyle(5,DRAW_HISTOGRAM);
 SetIndexBuffer(5,DnOF);
 SetIndexStyle(6,DRAW_HISTOGRAM);
 SetIndexBuffer(6,UpUF);
 SetIndexStyle(7,DRAW_HISTOGRAM);
 SetIndexBuffer(7,DnUF);
 
   if(! (Price >= 0 && Price <= 6  )  ) 
   {
   Alert("Permitted Price Modes are between 0 and 6");

   return(-1);
   }

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
 double Ind0;
 double Ind1;
 pos=limit;
 while(pos>=0)
 {
  Ind0=iCCI(NULL,0,CCI_Period,Price,pos);
  Ind1=iCCI(NULL,0,CCI_Period,Price,pos+1);
  
  UpOB[pos]=0.;
  DnOB[pos]=0.;
  UpOS[pos]=0.;
  DnOS[pos]=0.;
  UpOF[pos]=0.;
  DnOF[pos]=0.;
  UpUF[pos]=0.;
  DnUF[pos]=0.;
  
  if (Ind0>Overbought_Level)
  {
   if (Ind0>Ind1)
   {
    UpOB[pos]=1.;
   }
   else
   {
    DnOB[pos]=1.;
   }
  }
  else
  {
   if (Ind0<Oversold_Level)
   {
    if (Ind0>Ind1)
    {
     UpOS[pos]=1.;
    }
    else
    {
     DnOS[pos]=1.;
    }
   }
   else
   {
    if (Ind0>0)
    {
     if (Ind0>Ind1)
     {
      UpOF[pos]=1.;
     }
     else
     {
      DnOF[pos]=1.;
     }
    }
    else
    {
     if (Ind0>Ind1)
     {
      UpUF[pos]=1.;
     }
     else
     {
      DnUF[pos]=1.;
     }
    }
   }
  }

  pos--;
 } 
 return(0);
}
