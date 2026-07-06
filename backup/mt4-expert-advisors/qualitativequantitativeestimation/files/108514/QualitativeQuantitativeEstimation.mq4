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

extern int   RSI_Period = 14;
extern int   RSI_Smoothing_Period = 5;
extern int   ATR_Period = 14;
extern double Fast_ATR_Multipliers = 2.618;
extern double Slow_ATR_Multipliers = 4.236;
 

double TR[];
double QQE[]; 
double TS1[]; 
double TS2[]; 
double RSI[];
double ATR[];
double DELTA[];
double WildersPeriod;
int init(){
   
   IndicatorShortName("QualitativeQuantitativeEstimation");
   IndicatorBuffers(7);
   
   WildersPeriod=RSI_Period * 2 - 1;
   
 
   SetIndexBuffer(0,QQE);
   SetIndexLabel(0,"QQE");
   
   SetIndexBuffer(1,TS1);
   SetIndexLabel(1,"TS1");
   
   SetIndexBuffer(2,TS2);
   SetIndexLabel(2,"TS2");
      
   SetIndexBuffer(3,TR);
   SetIndexBuffer(4,RSI);
   SetIndexBuffer(5,ATR);
   SetIndexBuffer(6,DELTA);
   
   SetLevelValue(1,50);
   SetLevelValue(2,30);
   SetLevelValue(3,70);
   SetLevelStyle(STYLE_SOLID,1);
   
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
      
   for(i=limit; i>=0; i--){
   
   
            RSI[i]= iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i);
			
      
   }
   
  
   for(i=limit; i>=0; i--){
   
           QQE[i]= iMAOnArray(RSI,0,RSI_Smoothing_Period,0,MODE_EMA,i);
		   
		   TR[i] = MathAbs(QQE[i] - QQE[i+1]);
      
   }
   
   
    for(i=limit; i>=0; i--){
   
   ATR[i]= iMAOnArray(TR,0,ATR_Period,0,MODE_EMA,i);
   
   
   }
   
    for(i=limit; i>=0; i--){
   DELTA[i]= iMAOnArray(ATR,0,WildersPeriod,0,MODE_EMA,i);
  }

   double Stop1=QQE[limit];
   double Stop2=QQE[limit];
   
    for(i=limit; i>=0; i--){
	
	
	

	
	      		                                      if( QQE[i] < TS1[i+1] )														
													  {	
														 Stop1=QQE[i] + DELTA[i]*Fast_ATR_Multipliers;
														 
															 if (Stop1 > TS1[i+1])  
															 {        
															 	   if ( QQE[i+1] <  TS1[i+1])
 																   {
															       Stop1 = TS1[i+1];
																   }
															     
															 }									
														}		
														
														else if  ( QQE[i] > TS1[i+1] )
														{
                                                         Stop1=QQE[i] - DELTA[i]*Fast_ATR_Multipliers;
														 
															 if (Stop1 < TS1[i+1] )
															 {       
															        if (QQE[i+1] >  TS1[i+1]) 
 																	{
															        Stop1 = TS1[i+1];
																    }
															       
															 }
															 
													    }	
														
														TS1[i]=Stop1;
														
	                                                    
	
	}
   
     for(i=limit; i>=0; i--){
   
   			                                            if (QQE[i] < TS2[i+1])														
														{		
																 Stop2=QQE[i] + DELTA[i]*Slow_ATR_Multipliers;
																 
																	 if (Stop2 > TS2[1+1])
																	{		 
																			 if (QQE[i+1] <  TS2[i+1] )
 																			 {
																			 Stop2 = TS2[i+1];
																			 }
																	 }									
															}			
															else if  (QQE[i] > TS2[i+1])																
															{	 
															       Stop2=QQE[i] - DELTA[i]*Slow_ATR_Multipliers;
																 
																	 if (Stop2 < TS2[i+1])
																	{		 
																			 if (QQE[i+1] >  TS2[i+1])
																			 {
																			 Stop2 = TS2[i+1];
																			 }
																	 }
																	 
															}		
																
																TS2[i]=Stop2;
   
   }
   
   
//----
   return(0);
}
  