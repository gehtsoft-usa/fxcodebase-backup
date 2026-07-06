//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  https://goo.gl/9Rj74e | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+



#property indicator_buffers 3
#property indicator_separate_window
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int   Period = 14;
extern int   Method = 0;
 

double Up[];
double Down[];
double Difference[];
 
double u[];
double d[];

int init(){
   
   IndicatorShortName("TIA_Oscillator");
   IndicatorBuffers(5);
   
 
   SetIndexBuffer(0,Up);
   SetIndexLabel(0,"Up");
   
   SetIndexBuffer(1,Down);
   SetIndexLabel(1,"Down");
   
   SetIndexBuffer(2,Difference);
   SetIndexLabel(2,"Difference");
      
   SetIndexBuffer(3,u);
   SetIndexBuffer(4,d); 
   
    if(! ( Method >= 0 &&  Method <= 3  )  ) 
   {
   Alert("Permitted  MA Method are between 0 and 3");

   return(-1);
   }
   
   
   SetLevelValue(0,0);
   SetLevelStyle(STYLE_SOLID,1);
   
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
      
   for(i=limit; i>=0; i--){
   
   
            u[i]=0;
			d[i]=0;
      
			if (Close[i]> Close[i+1])
			{
			u[i]=u[i+1]+1;
			d[i]=0;
			}
			
			if (Close[i]< Close[i+1])
			{
			d[i]=d[i+1]+1;
			u[i]=0;
			}
			
      
   }
   
   for(i=limit; i>=0; i--){
      
      Up[i]= iMAOnArray(u,0,Period,0,Method,i);
      Down[i]= iMAOnArray(d,0,Period,0,Method,i);
	  Difference[i] = Up[i]-Down[i] ;
   }
   
   
   
//----
   return(0);
}
  