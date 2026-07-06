// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70456

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_width1 5
#property indicator_color2 Lime
#property indicator_width2 5
//---- indicator parameters
extern int ExtDepth=115;//105;//21;
extern int ExtDeviation=130;//120;//24;
extern int ExtBackstep=80;//70;//14;
//---- indicator buffers
double ZigZagUp[];
double ZigZagDown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
//---- drawing settings
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1, 234);
//---- indicator buffers mapping
   SetIndexBuffer(0,ZigZagUp);
   SetIndexBuffer(1,ZigZagDown);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);     
//---- indicator short name
   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ZigZagUp[shift+back];
               if((res!=0)&&(res>val)) { ZigZagUp[shift+back]=0.0; } 
              }
           }
        } 
      ZigZagUp[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ZigZagDown[shift+back];
               if((res!=0)&&(res<val)){ ZigZagDown[shift+back]=0.0; } 
              } 
           }
        }
      ZigZagDown[shift]=val;
     }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ZigZagUp[shift];
      curhigh=ZigZagDown[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh)
             {
              ZigZagDown[lasthighpos]=0;
             }
            else ZigZagDown[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow)
             {
              ZigZagUp[lastlowpos]=0;
            }
            else ZigZagUp[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
  
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ZigZagUp[shift]=0.0;
      else
        {
         res=ZigZagDown[shift];
         if(res!=0.0) ZigZagDown[shift]=res;
        }
     }
  }
  
  //end//