//+------------------------------------------------------------------+
//|                                             Color Stochastic.mq4 |
//|                                                           mladen |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      ""

//mods  by BLUR71

#property indicator_separate_window
#property indicator_buffers   6
#property indicator_minimum   0
#property indicator_maximum 100
#property indicator_color1 DimGray
#property indicator_style1 STYLE_DOT
#property indicator_color2 Yellow //Neutral
#property indicator_color3 Lime //UPPER
#property indicator_color4 Red //LOWER
#property indicator_color5 Lime //UPTREND
#property indicator_color6 Red //DOWNTREND
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 4
#property indicator_width6 4
#define SignalName "StochasticSignal"
 


//---- input parameters
//
//    nice setings for trend = 35,10,1
//
//

extern string note1 = "Chart Time Frame",
              note2 = "0=current time frame",
              note3 = "1=M1, 5=M5, 15=M15, 30=M30",
              note4 = "60=H1, 240=H4, 1440=D1",
              note5 = "10080=W1, 43200=MN1";
extern int	timeFrame	= 0;		// {1=M1, 5=M5, 15=M15, ..., 1440=D1, 10080=W1, 43200=MN1}
extern string note6 = "Stochastic settings";
extern int       KPeriod       =   10,
                 DPeriod       =   3,
                 Slowing       =   3;
extern string note7 = "0=sma, 1=ema, 2=smma, 3=lwma";
extern int       MAMethod      =   3;
extern string note8 = "0=high/low, 1=close/close";
extern int       PriceField    =   1;
extern string note9 = "OverSold/OverBought Level";
extern int       overSold      =  80,
                 overBought    =  20;
extern string note11 = "Directional: true/false";
extern bool      Directional   = true,
                 showBars      = false,
                 showArrows    = false,
                 alertsOn      = true,
                 alertsMessage = true,
                 alertsSound   = true,
                 alertsEmail   = false;


//---- buffers
//
//
//
//
//

double   KFull[],
         DFull[],
         Upper[],
         Lower[],
         Uptrend[],
         Downtrend[];

//
//
//
//
//

int      TimeFrame;
datetime TimeArray[];
int      maxArrows;
int      SignalGap;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{

      SetIndexBuffer(0,DFull);
      SetIndexBuffer(1,KFull);
      SetIndexBuffer(2,Upper);
      SetIndexBuffer(3,Lower);
      SetIndexBuffer(4,Uptrend);
      SetIndexBuffer(5,Downtrend);
         
         //
         //
         //
         //
         //
         
      if (showBars)
         {      
            SetIndexStyle(0,DRAW_NONE);
            SetIndexStyle(1,DRAW_NONE);
            SetIndexStyle(2,DRAW_HISTOGRAM);
            SetIndexStyle(3,DRAW_HISTOGRAM);
            SetIndexStyle(4,DRAW_HISTOGRAM);
            SetIndexStyle(5,DRAW_HISTOGRAM);
            SetIndexLabel(0,NULL);
            SetIndexLabel(1,NULL);
            SetIndexLabel(2,"Stochastic");
            SetIndexLabel(3,"Stochastic");
            SetIndexLabel(4,"Stochastic");
            SetIndexLabel(5,"Stochastic");
         }                  
      else
         {
            SetIndexLabel(0,"Stochastic");
            SetIndexLabel(1,"Stochastic");
            SetIndexLabel(2,NULL);
            SetIndexLabel(3,NULL);
            SetIndexLabel(4,NULL);
            SetIndexLabel(5,NULL);
            SetIndexStyle(0,DRAW_LINE);
            SetIndexStyle(1,DRAW_LINE);
            SetIndexStyle(2,DRAW_LINE);
            SetIndexStyle(3,DRAW_LINE);
            SetIndexStyle(4,DRAW_NONE);
            SetIndexStyle(5,DRAW_NONE);
            DPeriod = MathMax(DPeriod,1);
            if (DPeriod==1) {
                  SetIndexStyle(0,DRAW_NONE);
                  SetIndexLabel(0,NULL);
               }
            else {
                  SetIndexStyle(0,DRAW_LINE); 
                  SetIndexLabel(0,"Signal");
               }               
         }
              
         //
         //
         //
         //
         //
         
   TimeFrame        =stringToTimeFrame(timeFrame);
   string shortName = "Stochastic ("+TimeFrameToString(TimeFrame)+","+KPeriod+","+DPeriod+","+Slowing+","+maDescription(MAMethod)+","+priceDescription(PriceField);
         if (overBought < overSold) overBought = overSold;
         if (overBought < 100)      shortName  = shortName+","+overBought;
         if (overSold   >   0)      shortName  = shortName+","+overSold;
   IndicatorShortName(shortName+")");
   return(0);
}

//
//
//
//
//

int deinit()
{
   DeleteArrows();
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
   int    counted_bars=IndicatorCounted();
   int    limit;
   int    i,y;
   
   
   
   
   if(counted_bars<0) return(-1);
         limit=MathMax(Bars-counted_bars,TimeFrame/Period());
         ArrayCopySeries(TimeArray ,MODE_TIME ,NULL,TimeFrame);
            
      
   //
   //
   //
   //
   //
   
   for(i=0,y=0; i<limit; i++)
      {
         if(Time[i]<TimeArray[y]) y++;
            KFull[i] = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,MODE_MAIN,y);
            DFull[i] = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,MODE_SIGNAL,y);
      }
   for(i=limit,y=0; i>=0; i--)
      {
         if (showBars)
            {
               Upper[i]     = EMPTY_VALUE;
               Lower[i]     = EMPTY_VALUE;
               while(true)
                  {
                     if (KFull[i] > overBought) { Upper[i]     = 100; break;}
                     if (KFull[i] < overSold)   { Lower[i]     = 100; break;}
                     if (KFull[i] > KFull[i+1]) { Uptrend[i]   = 100; break;}
                     if (KFull[i] < KFull[i+1]) { Downtrend[i] = 100; break;}
                        Uptrend[i]   = Uptrend[i+1];
                        Downtrend[i] = Downtrend[i+1];
                     break;
                  }
            }
         else
            {
             if (Directional)
              {
               if (KFull[i] > KFull[i+1]) { Upper[i] = KFull[i]; Upper[i+1] = KFull[i+1]; }
               else                       { Upper[i] = EMPTY_VALUE;
                                            if (Upper[i+2] == EMPTY_VALUE)
                                                Upper[i+1]  = EMPTY_VALUE; }
               if (KFull[i] < KFull[i+1]) { Lower[i] = KFull[i]; Lower[i+1] = KFull[i+1]; }
               else                       { Lower[i] = EMPTY_VALUE;
                                            if (Lower[i+2] == EMPTY_VALUE)
                                                Lower[i+1]  = EMPTY_VALUE; }
              }                                 
              else
              {  
              
               if (KFull[i] > overBought) { Upper[i] = KFull[i]; Upper[i+1] = KFull[i+1]; }
               else                       { Upper[i] = EMPTY_VALUE;
                                            if (Upper[i+2] == EMPTY_VALUE)
                                                Upper[i+1]  = EMPTY_VALUE; }
               if (KFull[i] < overSold)   { Lower[i] = KFull[i]; Lower[i+1] = KFull[i+1]; }
               else                       { Lower[i] = EMPTY_VALUE;
                                            if (Lower[i+2] == EMPTY_VALUE)
                                                Lower[i+1]  = EMPTY_VALUE; }
              }                                  
            }                                                
      }                                             

   //
   //
   //
   //
   //

   DeleteArrows();
   if (showArrows)
      {
         SignalGap = MathCeil(iATR(NULL,0,50,0)/Point);
         for (i=0; i<WindowBarsPerChart() ;i++)
            {
               if (KFull[i]>overBought && KFull[i+1]<overBought) DrawArrow(i,"up");
               if (KFull[i]<overSold   && KFull[i+1]>overSold)   DrawArrow(i,"down");
            }
      }            
   if (alertsOn)
         {
            if (KFull[0]>overBought && KFull[1]<overBought) doAlert(" *Maxing Going Up*");
            if (KFull[0]<overBought && KFull[1]>overBought) doAlert(" *Reversing Down*");//added this line
            if (KFull[0]<overSold   && KFull[1]>overSold)   doAlert(" *Maxing Going Down*");//corrected this
            if (KFull[0]>overSold   && KFull[1]<overSold)   doAlert(" *Reversing Up*");//added this line
         }
   
   //
   //
   //
   //
   //
 
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void DrawArrow(int i,string type)
{
   maxArrows++;
      string name = StringConcatenate(SignalName,maxArrows);
         
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
      if (type=="up")
         {
            ObjectSet(name,OBJPROP_PRICE1,High[i]+(SignalGap*Point));
            ObjectSet(name,OBJPROP_ARROWCODE,242);
            ObjectSet(name,OBJPROP_COLOR,Red);
         }
      else
         {
            ObjectSet(name,OBJPROP_PRICE1,Low[i]-(SignalGap*Point));
            ObjectSet(name,OBJPROP_ARROWCODE,241);
            ObjectSet(name,OBJPROP_COLOR,LimeGreen);
         }
}
void DeleteArrows()
{
   while(maxArrows>0) { ObjectDelete(StringConcatenate(SignalName,maxArrows)); maxArrows--; }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];
      
          //
          //
          //
          //
          //
            
          message =  StringConcatenate(Symbol()," Color Stoch",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsSound)   PlaySound("alert2.wav");
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Stochastic crossing"),message);
      }        
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

string priceDescription(int mode)
{
   string answer;
   switch(mode)
   {
      case 0:  answer = "Low/High"    ; break; 
      case 1:  answer = "Close/Close" ; break;
      default: answer = "Invalid price field requested";
                                    Alert(answer);
   }
   return(answer);
}
string maDescription(int mode)
{
   string answer;
   switch(mode)
   {
      case MODE_SMA:  answer = "SMA"  ; break; 
      case MODE_EMA:  answer = "EMA"  ; break;
      case MODE_SMMA: answer = "SMMA" ; break;
      case MODE_LWMA: answer = "LWMA" ; break;
      default:        answer = "Invalid MA mode requested";
                                    Alert(answer);
   }
   return(answer);
}
int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringUpperCase(tfs);
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf<Period()) tf=Period();
  return(tf);
}
string TimeFrameToString(int tf)
{
   string tfs="Current time frame";
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN1";
   }
   return(tfs);
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;
   int      lenght = StringLen(str) - 1;
   int      tchar;
   
   while(lenght >= 0)
      {
         tchar = StringGetChar(s, lenght);
         
         //
         //
         //
         //
         //
         
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                  s = StringSetChar(s, lenght, tchar - 32);
          else 
              if(tchar > -33 && tchar < 0)
                  s = StringSetChar(s, lenght, tchar + 224);
         lenght--;
   }
   
   //
   //
   //
   //
   //
   
   return(s);
}