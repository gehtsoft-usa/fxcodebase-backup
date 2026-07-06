#property  indicator_separate_window
#property  indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
//---- indicator parameters
extern int RPeriod = 14;
extern int EPeriod=6;
extern int Mode=0;
extern bool UsePercent = false;
//---- indicator buffers
double RateOfChange[];
double MovingAverage[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings

  if(! (Mode >= 0 && Mode <= 3  )  ) 
   {
   Alert("Permitted MA_Modes are between 0 and 3");

   return(-1);
   }

  IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   
   SetIndexBuffer(0,RateOfChange);
   SetIndexBuffer(1,MovingAverage);
   SetIndexDrawBegin(0,RPeriod);
   SetIndexDrawBegin (1,EPeriod+RPeriod);
   IndicatorDigits(Digits + 1);
//---- indicator buffers mapping
 
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("ROC+MA(" + RPeriod + ")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   double ROC, CurrentClose, PrevClose;
   int counted_bars = IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars ;
//---- ROC calculation



int i;

   for( i =  limit; i>= 0; i--)
     {
       CurrentClose = iClose(NULL, 0, i);
       PrevClose = iClose(NULL, 0, i + RPeriod);
       ROC = CurrentClose - PrevClose;
       //----
       if(UsePercent)
         {
           if(PrevClose != 0)
               RateOfChange[i] = 100 * ROC / PrevClose;
               
         }
       else
           RateOfChange[i] = ROC;
           
     }   
	 
	
	
	for( i =  limit; i>= 0; i--)
     {
	 MovingAverage[i] = iMAOnArray (RateOfChange, 0,EPeriod,0,MODE_EMA,i);
	 }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+