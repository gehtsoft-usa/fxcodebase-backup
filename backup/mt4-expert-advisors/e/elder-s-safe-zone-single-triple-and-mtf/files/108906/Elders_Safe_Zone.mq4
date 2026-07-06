//+------------------------------------------------------------------+
//|                                             Elders_Safe_Zone.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  clrLime
#property indicator_width1  2

extern int    LookBack   = 10;
extern int    StopFactor = 3;
extern int    EMALength  = 13;

double ESZ[];
double EMA[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Elder's Safe Zone");
   
   IndicatorBuffers(2);
      
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ESZ);
   SetIndexLabel(0,"Elders Safe Zone");
   
   SetIndexBuffer(1,EMA);
   
   return(0);
   
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   for(i=limit; i>=0; i--){
      
      EMA[i] = iMA(NULL,0,EMALength,0,MODE_EMA,PRICE_CLOSE,i);
      
   }
   
   double PreSafeStop, Pen, Counter, SafeStop;
   
   for(i=limit; i>=0; i--){

      PreSafeStop = ESZ[i+1];
      Pen = 0;
      Counter = 0;
      
      if (EMA[i] > EMA[i+1]){
      
         for (j=0; j<LookBack; j++){
         
            if (Low[i+j] < Low[i+j+1]){
               
               Pen = Low[i+j+1] - Low[i+j] + Pen;
               Counter++;
               
            }
         
         }
         
         if (Counter > 0)
         
            SafeStop = Close[i] - (StopFactor*(Pen/Counter));
            
         else
         
            SafeStop = Close[i] - (StopFactor*Pen);
            
         if (SafeStop < PreSafeStop && EMA[i+1] > EMA[i+2])
         
            SafeStop = PreSafeStop;
         
      }
      else if (EMA[i] < EMA[i+1]){
      
         for (j=0; j<LookBack; j++){
         
            if (High[i+j] > High[i+j+1]){
               
               Pen = High[i+j] - High[i+j+1] + Pen;
               Counter++;
               
            }
         
         }
         
         if (Counter > 0)
         
            SafeStop = Close[i] + (StopFactor*(Pen/Counter));
            
         else
         
            SafeStop = Close[i] + (StopFactor*Pen);
            
         if (SafeStop > PreSafeStop && EMA[i+1] < EMA[i+2])
         
            SafeStop = PreSafeStop;
      
      }
      
      PreSafeStop=SafeStop;
      ESZ[i]=SafeStop;
      
   }
   
   return(0);
   
  }
  
