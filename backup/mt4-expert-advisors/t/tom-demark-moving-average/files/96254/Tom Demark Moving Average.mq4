//+------------------------------------------------------------------+
//|                                    Tom Demark Moving Average.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrGreen
#property indicator_color2 clrRed

extern int TrendPeriod=12;
extern int  MovingAveragePeriod=5;

double UP[];
double DOWN[];
double Trend[];

int init()
{
 IndicatorShortName("Tom Demark Moving Average");
 IndicatorBuffers(3);
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,DOWN);
 
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Trend);

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
 int period;
 double Min, Max;
 period=limit;
 while(period>=0)
 {
  Max=Low[iHighest(NULL, 0, MODE_LOW, TrendPeriod, period+1)];
  Min=High[iLowest(NULL, 0, MODE_HIGH, TrendPeriod, period+1)];
 
  
    if  (Trend[period+1] == 1 || Trend[period+1] == -1) 
	{
	Trend[period]=0;
	}
	
	
	else if ( Trend[period+1] > 1) 
	{
	Trend[period]=Trend[period+1]-1;
	}
	
	else if ( Trend[period+1] < -1 )
	{
	Trend[period]=Trend[period+1]+1;
	}
	
	if (Low[period]>  Max)
	{
	Trend[period]= MovingAveragePeriod;
	}
	
	else if (High[period] < Min)
	{
	Trend[period]= -1*MovingAveragePeriod;
	}
	
	
	    if (Trend[period] == MovingAveragePeriod)
		{
        UP[period] = iMA(NULL,0,MovingAveragePeriod,0,MODE_SMA,PRICE_LOW,period);  
        DOWN[period] = EMPTY_VALUE;

        }		
		else if  (Trend[period] == -MovingAveragePeriod)
		{
		DOWN[period] = iMA(NULL,0,MovingAveragePeriod,0,MODE_SMA,PRICE_HIGH,period); 
        UP[period] = EMPTY_VALUE;		
		}
		else if (Trend[period]!=0 || Trend[period]!=EMPTY_VALUE )
		{
		UP[period]=UP[period+1];
		DOWN[period]=DOWN[period+1];
		}
		else
		{
		UP[period]=EMPTY_VALUE;
		DOWN[period]=EMPTY_VALUE;	
		}
	
  
  period--;
 } 
 return(0);
}


