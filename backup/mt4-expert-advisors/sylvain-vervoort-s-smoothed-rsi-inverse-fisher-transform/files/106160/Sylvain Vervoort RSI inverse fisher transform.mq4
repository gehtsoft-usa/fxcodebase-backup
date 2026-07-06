//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window 
#property indicator_buffers 1
#property indicator_color1 Blue


 
extern int Average_Period=2;
extern int RSI_Period=4;
extern int MA_Period=4;

extern double OS=12;
extern double OB=88;
 
double LWMA1[];
double LWMA2[];
double LWMA3[];
double LWMA4[];
double LWMA5[];
double LWMA6[];
double LWMA7[];
double LWMA8[];
double LWMA9[];
double LWMA10[];
double RAW[];
double RSI[];
double MA1[];
double MA2[];

double OUT[];
 

int init()
  {
   IndicatorBuffers(15);
   IndicatorShortName("Sylvain Vervoort RSI inverse fisher transform");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,OUT);
   
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,LWMA1);
   
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,LWMA2);
   
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,LWMA3);
 
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,LWMA4);
  
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,LWMA5);
   
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,LWMA6);
   
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,LWMA7);
   
   SetIndexStyle(8,DRAW_NONE);
   SetIndexBuffer(8,LWMA8);
   
   SetIndexStyle(9,DRAW_NONE);
   SetIndexBuffer(9,LWMA9);
   
   SetIndexStyle(10,DRAW_NONE);
   SetIndexBuffer(10,LWMA10);
   
    SetIndexStyle(11,DRAW_NONE);
   SetIndexBuffer(11,RAW);
   
   SetIndexStyle(12,DRAW_NONE);
   SetIndexBuffer(12,RSI);
   
   SetIndexStyle(13,DRAW_NONE);
   SetIndexBuffer(13,MA1);
   
    SetIndexStyle(14,DRAW_NONE);
   SetIndexBuffer(14,MA2);
   
   SetLevelValue(1,OB);
   SetLevelValue(2,OS);
   SetLevelValue(3,0);
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
 {

 
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 { 
	 
        LWMA1[pos]= iMA(NULL,0,MA_Period,0,0,0,pos);

        LWMA2[pos]=  iMAOnArray(LWMA1,0,Average_Period,0,3,pos);

        LWMA3[pos]=  iMAOnArray(LWMA2,0,Average_Period,0,3,pos);

		LWMA4[pos]=  iMAOnArray(LWMA3,0,Average_Period,0,3,pos);
	
		LWMA5[pos]=  iMAOnArray(LWMA4,0,Average_Period,0,3,pos);

		LWMA6[pos]=  iMAOnArray(LWMA5,0,Average_Period,0,3,pos);

		LWMA7[pos]=  iMAOnArray(LWMA6,0,Average_Period,0,3,pos);

		LWMA8[pos]=  iMAOnArray(LWMA7,0,Average_Period,0,3,pos);

		LWMA9[pos]=  iMAOnArray(LWMA8,0,Average_Period,0,3,pos);

		LWMA10[pos]=  iMAOnArray(LWMA9,0,Average_Period,0,3,pos);
			  pos--;
 } 

  
  double Value=0; 
  pos=limit;
 while(pos>=0)
 { 
       Value=0;
       Value = Value + 5 * LWMA1[pos];
	   Value = Value + 4 * LWMA2[pos];
	   Value = Value + 3 * LWMA3[pos];
	   Value = Value + 2 * LWMA4[pos];
	   Value = Value + 1 * LWMA5[pos];
	   Value = Value + 1 * LWMA6[pos];
	   Value = Value + 1 * LWMA7[pos];
	   Value = Value + 1 * LWMA8[pos];
	   Value = Value + 1 * LWMA9[pos];
	   Value = Value + 1 * LWMA10[pos];
	   
	   RAW[pos]= Value/20;
        pos--;
 } 
 
 
  pos=limit;
 while(pos>=0)
 { 
 
 	   RSI [pos]= 0.1 * (iRSIOnArray(RAW,0,RSI_Period,pos)-50);
	   MA1[pos]= iMAOnArray(RSI,0,MA_Period,0,1,pos);
	   MA2[pos]= iMAOnArray(MA1,0,MA_Period,0,1,pos);
	   
	   double zl_ema = MA1[pos] + (MA1[pos] - MA2[pos]);
	   
       OUT[pos]= (( MathPow(2.71828183, 2 * zl_ema) - 1) / ( MathPow(2.71828183, 2 * zl_ema) + 1) + 1) * 50;
        pos--;
 } 
 
   
 return(0);
}

