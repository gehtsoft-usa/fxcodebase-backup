// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68895

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0" 

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 clrRed
 
 
#property indicator_width1 1
 

#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

#property indicator_minimum -5 
#property indicator_maximum 5

 
 
extern int Length=20;
 
 
 
extern double OB_Level1     = 2;
extern double OB_Level2     = 2.5;
 
 extern double OS_Level1     = -2;
extern double OS_Level2     = -2.5;


extern string Custom_Indicator = "Z distance from VWAP";
 
double Oscillator[]; 
double PV_Data[];
double V_Data[];
double Data_Data[];
double mean[];
int init() {
 
 
   IndicatorBuffers(5);
	
   SetIndexBuffer(0,Oscillator); 
   SetIndexStyle(0, DRAW_LINE); 
   
   SetIndexBuffer(1,PV_Data); 
   SetIndexBuffer(2,V_Data); 
   SetIndexBuffer(3,Data_Data); 
   SetIndexBuffer(4,mean);
   
   
   SetLevelValue(1,OB_Level1);
   SetLevelValue(2,OS_Level1);
   SetLevelValue(3,OB_Level2);
   SetLevelValue(4,OS_Level2);
   
   
   return (0);
}

int deinit() {
   return (0);
}

int start() {
 
 
   if (Bars <= 10) return (0);
   double gi_116 = IndicatorCounted();
   if (gi_116 < 0) return (-1);
   if (gi_116 > 0) gi_116--;
 
   int pos;
   
   
   for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
    
    PV_Data[pos]=Volume[pos]*Close[pos]; 
	V_Data[pos]=Volume[pos]; 
	
	
	   
   }
   
   

	double sma;
	double Delta;
	
    for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
   
    sma= iMAOnArray(V_Data,0,Length,0,MODE_SMA,pos);
	
	
	
		if (sma!= 0)
		{
		mean[pos]= (iMAOnArray(PV_Data,0,Length,0,MODE_SMA,pos)*Length)/(sma*Length);
		}
	    else
		{
	    mean[pos]=0;
	    }
	 
	
	 Delta= Close[pos]-mean[pos];
	 
	 if (Delta!=0)
	 {
	 Data_Data[pos]=MathPow(  Delta,2 );
	 }
	 else
	 {
	 Data_Data[pos]=0;
	 }
	
	
	}
	
	double vwapsd;
 
	
	
	for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
	
	sma = iMAOnArray(Data_Data,0,Length,0,MODE_SMA,pos);
	    if (sma> 0)		
	    {
		vwapsd = MathSqrt(sma);
		
		
				 if (vwapsd!=0)
				{
				Oscillator[pos]=(Close[pos]-mean[pos])/vwapsd;
				}
				 else
				 {
				 Oscillator[pos]=0;
				 }
				
		}
		
		else
				 {
				 Oscillator[pos]=0;
				 }
				
	   
	}
	
	
   return (0);
}