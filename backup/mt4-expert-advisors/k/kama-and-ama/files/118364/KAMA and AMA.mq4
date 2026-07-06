// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65861


//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_buffers 2
#property indicator_chart_window
#property indicator_color1  clrLime
#property indicator_color2  clrRed

 

extern int Periods = 10; 

double KAMA[];
double AAA[];  
double ROC[];

int Pds;
double FastSC;
double SlowSC;
   

int init(){
   
   IndicatorShortName("KAMA_and_AMA");
   IndicatorBuffers(3);
   IndicatorDigits(Digits);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,KAMA);
   SetIndexLabel(0,"KAMA");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,AAA);
   SetIndexLabel(1,"AAA");
 
   SetIndexBuffer(2,ROC);
   
   
   Pds=Periods+1;
   FastSC=2.0/3;
   SlowSC=2.0/31;
    
   return(0);
}

int start()
  {
   
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   int i;
   
  
 
 
   for(i=limit; i>=0; i--){
 
     
     
       ROC[i]=MathAbs(Close[i]-(Close[i+1])) ;
  
	  
   }
  
   //Adaptive Moving Average
   int max;
   int min;
   double Mltp=0;
   double SSC;
   double Constant;
   double Direction;
   double Volatility;
   double ER;
   
   
 limit = Bars-counted_bars-1;
 
   for(i=limit; i>=0; i--){
 
 
   max=iHighest(NULL,0,MODE_HIGH,Pds,i);    
   min=iLowest(NULL,0,MODE_LOW,Pds,i);  
   
    if (High[max]==Low[min])
	{
     Mltp=0;
	}
	else
	{
	  Mltp=MathAbs((Close[i]-Low[min])-(High[max]-Close[i]))/(High[max]-Low[min]);	
	 
	}
	
	SSC=Mltp*(FastSC-SlowSC)+SlowSC;
	Constant= MathPow(SSC,2.0);      
	

	 
    if ( i> (limit-Pds))
	{
 
	AAA[i]=Close[i+1]+Constant*(Close[i]-Close[i+1]);
	}
	else
	{
	 
	AAA[i]=AAA[i+1]+Constant*(Close[i]-AAA[i+1]);
	}	
	 	 
   }
   
   
   
   //Kaufman Adaptive Moving Average
   
    limit = Bars-counted_bars-1;
 
   for(i=limit; i>=0; i--){
 
 
    Direction=MathAbs(Close[i]- Close[i+Periods]);
   
    Volatility=iMAOnArray(ROC,0,Periods,0,MODE_SMA,i)*Periods;
    if (Volatility != 0 )
	{
    ER=Direction/Volatility;
	}
    SSC=ER*(FastSC-SlowSC)+SlowSC;
    Constant= MathPow(SSC,2.0); 
	
	 if ( i> (limit-Pds))
	{
 
	KAMA[i]=Close[i+1]+Constant*(Close[i]-Close[i+1]);
	}
	else
	{
	 
	KAMA[i]=KAMA[i+1]+Constant*(Close[i]-KAMA[i+1]);
	}	
	 	 
   }
	
//----
   return(0);
}
