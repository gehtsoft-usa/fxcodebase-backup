// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68478

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
#property indicator_buffers 2
#property indicator_color1 clrGreen 
#property indicator_color2 clrRed
 
 
#property indicator_width1 1
#property indicator_width2 1
 
extern int Fundamental=20; 
extern double Bandwidth=0.1;
 
 
double L1, G1, S1, L2, G2, S2, L3,G3, S3,TWOPI; 
double BP1[];
double BP2[];
double BP3[];
double Q1[];
double Q2[];
double Q3[];
 

extern string Custom_Indicator = "FOURIER SERIES ANALYSIS";
 
double Wave[];
double ROC[]; 

int init() {
 
 
   IndicatorBuffers(8);
	
   SetIndexBuffer(0, Wave); 
   SetIndexStyle(0, DRAW_LINE); 

   SetIndexBuffer(1, ROC); 
   SetIndexStyle(1, DRAW_LINE); 
 
   
   SetIndexBuffer(2, BP1);
   SetIndexBuffer(3, BP2);
   SetIndexBuffer(4, BP3);
   
   SetIndexBuffer(5, Q1);
   SetIndexBuffer(6, Q2);
   SetIndexBuffer(7, Q3);
   
   
   TWOPI = 2 * 3.1415926;  
 

	L1 = MathCos(TWOPI / Fundamental); 
	G1 = MathCos(Bandwidth*TWOPI / Fundamental); 
	S1 = 1 / G1 - MathSqrt(1 / (G1*G1) - 1); 
	L2 = MathCos(TWOPI / (Fundamental / 2));
	G2 = MathCos(Bandwidth*TWOPI / (Fundamental / 2));
	S2 = 1 / G2 - MathSqrt(1 / (G2*G2) - 1);
	L3 = MathCos(TWOPI / (Fundamental / 3)); 
	G3 = MathCos(Bandwidth*TWOPI / (Fundamental / 3));
	S3 = 1 / G3 - MathSqrt(1 / (G3*G3) - 1);
 
   
   
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
 
   int pos,count;
   double P1 = 0; 
   double P2 = 0; 
   double P3 = 0;
   
   for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
   
   
     //Fundamental Band-Pass
	BP1[pos] = 0.5*(1 - S1)*(Close[pos] - Close[pos+2]) + L1*(1 + S1)*BP1[pos+1] - S1*BP1[pos+2];
	//if period <= 3 then BP1[period] = 0; end
	//Fundamental Quadrature 
	Q1[pos] = (Fundamental / 6.28)*(BP1[pos] - BP1[pos+1]);
	//if period <= 4 then Q1[period] = 0; end

	
	
    //Second Harmonic Band-Pass
	BP2[pos] = 0.5*(1 - S2)*(Close[pos] - Close[pos+2]) + L2*(1 + S2)*BP2[pos+1] - S2*BP2[pos+2]; 
	//if period <= 3 then BP2[period] = 0; end
	
	//Second Harmonic Quadrature 
	Q2[pos] = (Fundamental / 6.28)*(BP2[pos] - BP2[pos+1]); 
	//if period <= 4 then Q2[period] = 0; end
	
    //Third Harmonic Band-Pass 
	BP3[pos] = 0.5*(1 - S3)*(Close[pos] - Close[pos+2]) + L3*(1 + S3)*BP3[pos+1] - S3*BP3[pos+2];
   // if period <= 3 then BP2[period] = 0; end

   //Third Harmonic Quadrature 
    Q3[pos] = (Fundamental / 6.28)*(BP3[pos] - BP3[pos+1]);
   //  if period <= 4 then Q3[period] = 0; end
  
  }
  
  
  
  
   for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
  
		P1 = 0; 
		P2 = 0; 
		P3 = 0;
	
		for (count = 0; count< Fundamental;count++ )
		{
		P1 = P1 + BP1[pos+count]*BP1[pos+count] + Q1[pos+count]*Q1[pos+count];  
		P2 = P2 + BP2[pos+count]*BP2[pos+count] + Q2[pos+count]*Q2[pos+count];
		P3 = P3 + BP3[pos+count]*BP3[pos+count] + Q3[pos+count]*Q3[pos+count];
		}

	
		//Add the three harmonics together using their relative amplitudes 
		if (P1 != 0)
		{
		Wave[pos] = BP1[pos] +  MathSqrt(P2 / P1)*BP2[pos] +  MathSqrt(P3 / P1)*BP3[pos];
		}
	 
 
 
 
    // Optional cyclic trading signal 
    //   Rate of change crosses zero at cyclic turning points 
     ROC[pos] = (Fundamental / 12.57)*(Wave[pos] - Wave[pos+2]);
				  
	
 
	
	   
   }
   return (0);
} 