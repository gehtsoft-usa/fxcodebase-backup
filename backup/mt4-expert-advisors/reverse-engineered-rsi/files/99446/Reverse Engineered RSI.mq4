
//+------------------------------------------------------------------+
//|                                      Reverse Engineered RSI.MQ4  |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|------------------------------------------------------------------|
//|                                     Paypal: http://goo.gl/cEP5h5 |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
					   

extern int Period=14;
extern double OB=70;
extern double CL=50;
extern double OS=30;  
					   
double ExpPeriod;
double K;
					   
double Top[];
double Bottom[];
double Central[];
double AUC[];
double ADC[];

int init()
{
 IndicatorShortName("Reverse Engineered RSI");
 IndicatorDigits(Digits);
 IndicatorBuffers(5);
 
  
 ExpPeriod = 2 * Period - 1;	
 K = 2 / (ExpPeriod + 1);
 
 
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bottom);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Central);
 
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,AUC);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,ADC);
 


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
 double x1, x2, x3;

 while(pos>=0)
 {
 
   
	if(iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) > iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1)) 
	{
		AUC[pos] = K * (iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) - iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1)) + (1 - K) * AUC[pos+1];
		ADC[pos] = (1 - K) * ADC[pos+1];	
	}	
	else 
	{
		AUC[pos] = (1 - K) * AUC[pos+1];
		ADC[pos] = K * (iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1) - iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)) + (1 - K) * ADC[pos+1];
	}	
		
	

  pos--;
 } 
  pos=limit;
  while(pos>=0)
 {
 x1 = (Period - 1) * (ADC[pos] * OB / (100 - OB) - AUC[pos]);
	
	if(x1 >= 0)   
	{
	Top[pos] = iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) + x1;
	}
	else
	{
	Top[pos] =  iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) + x1 * (100 - OB) / OB;
	}	
	 
	
	  x2 = (Period - 1) * (ADC[pos] * OS / (100 - OS) - AUC[pos]);
	
	if(x2 >= 0)
    {	
		Bottom[pos]  = iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) + x2;
	}
	else
	{
	Bottom[pos] =  iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) + x2 * (100 - OS) / OS;
	}

      x3 = (Period - 1) * (ADC[pos] * CL / (100 - CL) - AUC[pos]);
	
	if(x3 >= 0) 
	{
		Central[pos]  = iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) + x3;
	}
	else
	{
	Central[pos] =  iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) + x3 * (100 - CL) / CL;
	}		
	
   pos--;
 } 
   
 return(0);
}

