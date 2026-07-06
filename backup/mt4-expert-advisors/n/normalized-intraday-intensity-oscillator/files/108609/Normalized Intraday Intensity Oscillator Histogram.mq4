//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  https://goo.gl/9Rj74e | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_buffers 1
#property indicator_separate_window
#property indicator_levelcolor clrTomato
#property indicator_color1 Blue     

extern int    Period    = 10;


double Temp[];
double Normalized[];
double Raw[];
int init(){
   
   IndicatorShortName("Normalized Intraday Intensity Oscillator");
   IndicatorBuffers(3);
   
   SetIndexStyle(0,DRAW_HISTOGRAM); 
   SetIndexBuffer(0,Normalized);
   SetIndexLabel(0,"Normalized");
   
   SetIndexBuffer(1,Temp);
   SetIndexBuffer(2,Raw);
 

   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
      
   for (i=limit; i>=0; i--){
   
      if ((High[i]-Low[i])  != 0 )
	  {
      Temp[i]=(2*Close[i]-High[i]-Low[i])/(High[i]-Low[i])*Volume[i];
      }
	  else
	  {
	  Temp[i]=0;
	  }
	  
	  Raw[i]= Volume[i];
         
   }
    
      for (i=limit-Period; i>=0; i--){ 
      
            Normalized[i]= iMAOnArray(Temp,0,Period,0,0,i)/iMAOnArray(Raw,0,Period,0,0,i)*100;
      }
 
   
//----
   return(0);
}
