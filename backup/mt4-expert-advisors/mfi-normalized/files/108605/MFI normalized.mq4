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

extern int     MFI_Periods    = 10;
extern int     BB_Period    = 40;
extern int     BB_Deviation    = 2;

double MFI[];
double Normalized[];

int init(){
   
   IndicatorShortName("MFI normalized");
   IndicatorBuffers(2);
   
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexBuffer(0,Normalized);
   SetIndexLabel(0,"Normalized");
   
   SetIndexBuffer(1,MFI);
 
   
   SetLevelValue(1,1);
   SetLevelValue(2,0);

   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
      
   for (i=limit-MFI_Periods; i>=0; i--){
      MFI[i]=iMFI(NULL,0,MFI_Periods,i);
      
         
   }
    
      for (i=limit-MFI_Periods-BB_Period; i>=0; i--){ 
      
	  double TL = iBandsOnArray(MFI,0,BB_Period,BB_Deviation,0,1,i);
       double BL = iBandsOnArray(MFI,0,BB_Period,BB_Deviation,0,2,i); 
       Normalized[i] =(MFI[i] - BL) / (TL - BL);	   
   }
 
   
//----
   return(0);
}
