//+------------------------------------------------------------------+
//|                                                   Darvas_Box.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

double Up[], Dn[];
double State[];

int init()
{
 IndicatorShortName("Darvas Box");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,State);

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
 double box_top, box_bottom;
 double state;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   State[pos]=1.;
  }
  else
  {
   box_top=Up[pos+1];
   box_bottom=Dn[pos+1];
   state=State[pos+1];
   
   if (state==1.)
   {
    box_top=High[pos];
   }
   else
   {
    if (state==2.)
    {
     if (box_top<=High[pos])
     {
      box_top=High[pos];
     }
    }
    else
    {
     if (state==3.)
     {
      if (box_top>High[pos])
      {
       box_bottom=High[pos];
      }
      else
      {
       box_top=High[pos];
      }
     }
     else
     {
      if (state==4.)
      {
       if (box_top>High[pos])
       {
        if (box_bottom>=Low[pos])
        {
         box_bottom=Low[pos];
        }
       }
       else
       {
        box_top=High[pos];
       }
      }
      else
      {
       if (box_top>High[pos])
       {
        if (box_bottom>=Low[pos])
        {
         box_bottom=Low[pos];
        }
       }
       else
       {
        box_top=High[pos];
       }
       state=0.;
      }
     }
    }
   }
   state++;
   State[pos]=state;
   Up[pos]=box_top;
   Dn[pos]=box_bottom;
  }

  pos--;
 } 
 return(0);
}

