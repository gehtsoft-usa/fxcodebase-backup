
//+------------------------------------------------------------------+
//|                                   Extreme TMA line indicator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, Copyright © 2014, Gehtsoft USA LLC"
#property link      " http://fxcodebase.com"
 
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 DarkGray
#property indicator_color4 DarkGray
#property indicator_color5 DarkGray
 
//---- input parameters
extern int TMA_Period=56;
extern int ATR_Period=100;
extern double ATR_Mult=2;
extern double TrendThreshold=0.5;
extern bool Redraw = True;
 
//---- indicator buffers
double Up[];
double Down[];
double Neutral[];
double TMA[];

double Top[];
double Bottom[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
  IndicatorBuffers(6);
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Down);
   SetIndexBuffer(2,Neutral);
   SetIndexBuffer(3,Top);
   SetIndexBuffer(4,Bottom);
   
   SetIndexBuffer(5,TMA);
   
  
   
 
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE); 
    SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   
   SetIndexStyle(5,DRAW_NONE);
  
   IndicatorShortName("Extreame_TMA_Line");
 
 
//---- initialization done
   return(0);
  }
 
int start()
  {
   int    i,j,nLimit; 
//---- bars count that does not changed after last indicator launch.
   int    nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted
   if(nCountedBars<=ATR_Period*2)
      nLimit=Bars-(ATR_Period*2);
   else
      nLimit=Bars-nCountedBars-1;
//---- moving averages absolute difference

   double Sum, SumW;
   int ii;
   bool LastPeriod;
  double ATR, Slope;
  	
		
   for(i=nLimit; i>=0; i--)
     {
			    ii=TMA_Period;
				
				if  (i==0) 
				{
				 LastPeriod=True;
				} 
				else
				{
				 LastPeriod=False;
				} 
		
		
				while (ii>0) 
				{
					 if  (LastPeriod == False ) 
					 {
					 ii=0;
					 }
					else
					{
					 ii=ii-1; 
					}
					
				Sum=0;
                SumW=(TMA_Period+2)*(TMA_Period+1)/2;
				
				  for(j=0; j<=TMA_Period; j++)   
				   {
				   Sum=Sum+(TMA_Period-j+1)*Close[i+j];
						 if (Redraw== True) 
						 {
						   if  (i-j>0) // (j<=nLimiti && j>0)
						   {
						   Sum=Sum+(TMA_Period-j+1)*Close[i-j];
						   SumW=SumW+(TMA_Period-j+1);				 
						  }
						}
				
			    	}
	
         
				 if (SumW != 0)
				 {
				 TMA[i]=Sum/SumW;
				 }
			    // i=i+1;
	            
              } 
	         
    }		
    
    if(nCountedBars<=ATR_Period*2)
      nLimit=Bars-(ATR_Period*2);
   else
      nLimit=Bars-nCountedBars-1;	
	  
	  
	  
	double range;
	
	  for(i=nLimit; i>=0; i--)
     {
	 
	 	ATR = iATR(NULL,0,ATR_Period,i);
				Slope=(TMA[i]-TMA[i+1])/(0.1*ATR);
				if ( Slope>TrendThreshold)
				{
				 Up[i]=TMA[i];
				 Up[i+1]=TMA[i+1];
				 Down[i]= EMPTY_VALUE;
				 Neutral[i]= EMPTY_VALUE;
				}
				else if ( Slope<-TrendThreshold )
				{
				 Up[i]= EMPTY_VALUE;
				 Down[i]= TMA[i];
				 Down[i+1]= TMA[i+1];
				 Neutral[i]= EMPTY_VALUE;
				}
				
				else 
				{
				 Up[i]=EMPTY_VALUE;
				 Down[i]= EMPTY_VALUE;
				 Neutral[i]= TMA[i];
				 Neutral[i+1]= TMA[i+1];
				} 
	 
	   range=ATR*ATR_Mult;
		Top[i]=TMA[i]+range;
		Bottom[i]=TMA[i]-range;
	 }
	 
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

