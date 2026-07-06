//+------------------------------------------------------------------+
//|                                      Elders_Safe_Zone_Triple.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_color2  clrSkyBlue
#property indicator_width2  2
#property indicator_color3  clrRed
#property indicator_width3  2

extern string Comment1    = "-- Values for Safe Zone 1 --";
extern int    LookBack1   = 10;
extern int    StopFactor1 = 3;
extern int    EMALength1  = 13;
extern string Comment2    = "-- Values for Safe Zone 2 --";
extern int    LookBack2   = 20;
extern int    StopFactor2 = 6;
extern int    EMALength2  = 50;
extern string Comment3    = "-- Values for Safe Zone 3 --";
extern int    LookBack3   = 30;
extern int    StopFactor3 = 10;
extern int    EMALength3  = 100;


double ESZ1[];
double EMA1[];
double ESZ2[];
double EMA2[];
double ESZ3[];
double EMA3[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Elder's Safe Zone Triple");
   
   IndicatorBuffers(6);
      
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ESZ1);
   SetIndexLabel(0,"Elders Safe Zone 1");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ESZ2);
   SetIndexLabel(1,"Elders Safe Zone 2");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ESZ3);
   SetIndexLabel(2,"Elders Safe Zone 3");
   
   SetIndexBuffer(3,EMA1);
   SetIndexBuffer(4,EMA2);
   SetIndexBuffer(5,EMA3);
   
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
      
      EMA1[i] = iMA(NULL,0,EMALength1,0,MODE_EMA,PRICE_CLOSE,i);
      EMA2[i] = iMA(NULL,0,EMALength2,0,MODE_EMA,PRICE_CLOSE,i);
      EMA3[i] = iMA(NULL,0,EMALength3,0,MODE_EMA,PRICE_CLOSE,i);
      
   }
   
   double PreSafeStop, Pen, Counter, SafeStop;
   
   // Elder's Safe Zone 1
   for(i=limit; i>=0; i--){

      PreSafeStop = ESZ1[i+1];
      Pen = 0;
      Counter = 0;
      
      if (EMA1[i] > EMA1[i+1]){
      
         for (j=0; j<LookBack1; j++){
         
            if (Low[i+j] < Low[i+j+1]){
               
               Pen = Low[i+j+1] - Low[i+j] + Pen;
               Counter++;
               
            }
         
         }
         
         if (Counter > 0)
         
            SafeStop = Close[i] - (StopFactor1*(Pen/Counter));
            
         else
         
            SafeStop = Close[i] - (StopFactor1*Pen);
            
         if (SafeStop < PreSafeStop && EMA1[i+1] > EMA1[i+2])
         
            SafeStop = PreSafeStop;
         
      }
      else if (EMA1[i] < EMA1[i+1]){
      
         for (j=0; j<LookBack1; j++){
         
            if (High[i+j] > High[i+j+1]){
               
               Pen = High[i+j] - High[i+j+1] + Pen;
               Counter++;
               
            }
         
         }
         
         if (Counter > 0)
         
            SafeStop = Close[i] + (StopFactor1*(Pen/Counter));
            
         else
         
            SafeStop = Close[i] + (StopFactor1*Pen);
            
         if (SafeStop > PreSafeStop && EMA1[i+1] < EMA1[i+2])
         
            SafeStop = PreSafeStop;
      
      }
      
      PreSafeStop=SafeStop;
      ESZ1[i]=SafeStop;
      
   }
   
   // Elder's Safe Zone 2
   for(i=limit; i>=0; i--){

      PreSafeStop = ESZ2[i+1];
      Pen = 0;
      Counter = 0;
      
      if (EMA2[i] > EMA2[i+1]){
      
         for (j=0; j<LookBack2; j++){
         
            if (Low[i+j] < Low[i+j+1]){
               
               Pen = Low[i+j+1] - Low[i+j] + Pen;
               Counter++;
               
            }
         
         }
         
         if (Counter > 0)
         
            SafeStop = Close[i] - (StopFactor2*(Pen/Counter));
            
         else
         
            SafeStop = Close[i] - (StopFactor2*Pen);
            
         if (SafeStop < PreSafeStop && EMA2[i+1] > EMA2[i+2])
         
            SafeStop = PreSafeStop;
         
      }
      else if (EMA2[i] < EMA2[i+1]){
      
         for (j=0; j<LookBack2; j++){
         
            if (High[i+j] > High[i+j+1]){
               
               Pen = High[i+j] - High[i+j+1] + Pen;
               Counter++;
               
            }
         
         }
         
         if (Counter > 0)
         
            SafeStop = Close[i] + (StopFactor2*(Pen/Counter));
            
         else
         
            SafeStop = Close[i] + (StopFactor2*Pen);
            
         if (SafeStop > PreSafeStop && EMA2[i+1] < EMA2[i+2])
         
            SafeStop = PreSafeStop;
      
      }
      
      PreSafeStop=SafeStop;
      ESZ2[i]=SafeStop;
      
   }
   
   // Elder's Safe Zone 3
   for(i=limit; i>=0; i--){

      PreSafeStop = ESZ3[i+1];
      Pen = 0;
      Counter = 0;
      
      if (EMA3[i] > EMA3[i+1]){
      
         for (j=0; j<LookBack3; j++){
         
            if (Low[i+j] < Low[i+j+1]){
               
               Pen = Low[i+j+1] - Low[i+j] + Pen;
               Counter++;
               
            }
         
         }
         
         if (Counter > 0)
         
            SafeStop = Close[i] - (StopFactor3*(Pen/Counter));
            
         else
         
            SafeStop = Close[i] - (StopFactor3*Pen);
            
         if (SafeStop < PreSafeStop && EMA3[i+1] > EMA3[i+2])
         
            SafeStop = PreSafeStop;
         
      }
      else if (EMA3[i] < EMA3[i+1]){
      
         for (j=0; j<LookBack3; j++){
         
            if (High[i+j] > High[i+j+1]){
               
               Pen = High[i+j] - High[i+j+1] + Pen;
               Counter++;
               
            }
         
         }
         
         if (Counter > 0)
         
            SafeStop = Close[i] + (StopFactor3*(Pen/Counter));
            
         else
         
            SafeStop = Close[i] + (StopFactor3*Pen);
            
         if (SafeStop > PreSafeStop && EMA3[i+1] < EMA3[i+2])
         
            SafeStop = PreSafeStop;
      
      }
      
      PreSafeStop=SafeStop;
      ESZ3[i]=SafeStop;
      
   }
   
   return(0);
   
  }
  
