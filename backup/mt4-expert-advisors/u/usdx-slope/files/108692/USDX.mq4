//+------------------------------------------------------------------+
//|                                                      LWMA_MA.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 clrRed
#property indicator_width1 2

double USDX[];

int init(){
   
   IndicatorShortName("US Dollar Index");
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,USDX);
   SetIndexLabel(0,"USDX");
   
   return(0);
   
}

int start(){
   
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   
   double EU, UJ, GU, UC, US, UCH;
   
   for(int i=limit; i>=0; i--){
      
      EU  = MathPow(iClose("EURUSD",0,i),-0.576);
      UJ  = MathPow(iClose("USDJPY",0,i),0.136);
      GU  = MathPow(iClose("GBPUSD",0,i),-0.119);
      UC  = MathPow(iClose("USDCAD",0,i),0.091);
      US  = MathPow(iClose("USDSEK",0,i),0.042);
      UCH = MathPow(iClose("USDCHF",0,i),0.036);
      
      USDX[i]=50.14348112*EU*UJ*GU*UC*US*UCH;
   }
   return(0);

}