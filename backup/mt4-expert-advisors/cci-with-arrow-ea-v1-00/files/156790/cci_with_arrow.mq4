// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75232

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 3
#property  indicator_level1  100
#property  indicator_level2  -100
#property  indicator_level3  0
#property  indicator_level4  200
#property  indicator_level5  -200
#property  indicator_levelwidth  1
#property  indicator_levelcolor  Gold
#property  indicator_levelstyle  4


double uparrow[],downarrow[];
extern double barheight=300;
extern int BarCount=3000;
extern bool showheightline=false,showarrowline=false;
extern bool sound=false;
extern bool usechart=true;
extern int period=20;
extern int per=0;
datetime bartime;
extern int price_type=1;
extern string pair="EURUSD";
double cc[];
double lasthigh,high,highest,newhigh,lastlow,low,lowest,newlow;
color col=Lime;
double cci;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
if(usechart) {pair=Symbol();}
//---- indicators
//----
  for(int h=0;h<=Bars;h++)
      {
       
        ObjectDelete("UP"+h);
        ObjectDelete("SELL"+h);
      }
      string name="CCI with ARROW("+period+") on "+pair+per;
     if(per==5)col=Aqua;
    else if(per==15)col=Blue;
    else if(per==30)col=Coral;
    else if(per==60)col=Red;
     else col=Lime;
  IndicatorShortName(name); 
   SetIndexStyle(0,DRAW_LINE,0,2,col);
   SetIndexBuffer(0,cc);
   SetIndexStyle(1, DRAW_ARROW,EMPTY,2,Blue);
   SetIndexBuffer(1, uparrow);
   SetIndexArrow(1, 233);
   SetIndexStyle(2, DRAW_ARROW,EMPTY,2,Red);
   SetIndexBuffer(2, downarrow);
   SetIndexArrow(2, 234); 
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int h=0;h<=Bars;h++)
      {
        ObjectDelete("UP"+h);
        ObjectDelete("SELL"+h);
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
        
//   int Counted_bars=IndicatorCounted();
//  int newbars = Bars-Counted_bars-1;
  
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
if(counted_bars > 0)   counted_bars--;
int limit = Bars - counted_bars;
if(counted_bars==0) limit--;
  
  
//  if(IsConnected()) limit=BarCount;
  
        // get last high...........

 highest=0; lasthigh=0;high=0;newhigh=0;lowest=200; int chan=0;int chan2=0;int bar=Bars-1;
 bool arrow=false,arrow2=false;
 
   for(int y=limit;y>=0;y--)
    {
    
    datetime time=iTime(pair,Period(),y);
    int shift1=iBarShift(pair,per,time,true);
    cc[y] =iCCI(pair,per,period,price_type,shift1);
     
    cci=cc[y];//iCCI(pair,per,period,price_type,shift1);
    
   // get last high...........
   
       if(High[y]- Low[y]>=barheight*Point && showheightline)
          {  
               ObjectCreate("UP"+y,  OBJ_VLINE,0,0,0);   
               ObjectSet("UP"+y, OBJPROP_TIME1, Time[y]);   
               ObjectSet("UP"+y, OBJPROP_COLOR, Blue);   
               ObjectSet("UP"+y, OBJPROP_STYLE, 1);      
               ObjectSet("UP"+y, OBJPROP_WIDTH, 0);        
          }
             
   if(cci>=100)
       {
         chan=0;
         if(cci>=highest)
            {
               highest=cci;high=cci;
                  if(cci>=lasthigh)
                     {
                     
                         newhigh=cci; bar=y;
                     if (arrow)
                         continue;
                    else {
                           uparrow[bar]=newhigh;
                         
                           if(showarrowline)
                            {       
                              ObjectCreate("UP"+bar,OBJ_VLINE,0,0,0);
                              ObjectSet("UP"+bar, OBJPROP_TIME1, Time[bar]);  
                              ObjectSet("UP"+bar, OBJPROP_COLOR, Blue);
                              ObjectSet("UP"+bar, OBJPROP_STYLE, 2);
                              ObjectSet("UP"+bar, OBJPROP_WIDTH, 0);
                            }
                          if(sound&&bartime!=Time[bar])PlaySound( "alert2.wav");bartime=Time[bar];
                        }
                     }
                  else
                     { 
                        newhigh=0;continue;
                     }
            }
        else   continue;
      }
   else
      {
         if(chan==1) {}//continue;
       else 
          {
            lasthigh=high; highest=0;arrow=false;
             //  if(newhigh>0)
               //  uparrow[bar]=newhigh;
            chan=1;// continue;
          }
      }
  
  // get last new lows
    if(cci<=-100)
      {
         chan2=0;
         if(cci<=lowest)
            {
               lowest=cci;low=cci;
                  if(cci<=lastlow)
                     {
                        newlow=cci; bar=y;
                        if(arrow2)continue;
                   else   {
                           downarrow[bar]=newlow; 
                    if(showarrowline){       ObjectCreate("SELL"+bar,OBJ_VLINE,0,0,0);
                  ObjectSet("SELL"+bar, OBJPROP_TIME1, Time[bar]);  
                  ObjectSet("SELL"+bar, OBJPROP_COLOR, Red);
                  ObjectSet("SELL"+bar, OBJPROP_STYLE, 2);
                  ObjectSet("SELL"+bar, OBJPROP_WIDTH, 0);}
                 if(sound&&bartime!=Time[bar])PlaySound("alert2.wav");bartime=Time[bar];}
                     }
                  else
                     { 
                        newlow=0;continue;
                     }
            }
        else   continue;
      }
   else
      {
         if(chan2==1) continue;
       else 
          {
            lastlow=low; lowest=0;arrow2=false;
             //  if(newlow<0)
               //   downarrow[bar]=newlow;
            chan2=1; continue;
          }
      }
       
    }           


   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 