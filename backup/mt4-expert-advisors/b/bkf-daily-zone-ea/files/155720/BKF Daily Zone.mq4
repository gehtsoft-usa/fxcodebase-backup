// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74965

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property  indicator_chart_window

#property indicator_buffers 3
#property indicator_color1 Navy 
#property indicator_color2 White 
#property indicator_color3 DodgerBlue 


double HiPrice, LoPrice, Range;
datetime StartTime;

int init()
{
   return(0);
}

int deinit()
{
   ObjectDelete("LongFibo6");
   ObjectDelete("ShortFibo6");
   ObjectDelete("dailyFibo6");
   return(0);
}

//+------------------------------------------------------------------+
//| Draw Fibo
//+------------------------------------------------------------------+

int DrawFibo()
{
	if(ObjectFind("LongFibo6") == -1)
		ObjectCreate("LongFibo6",OBJ_FIBO,0,StartTime,HiPrice+Range,StartTime,HiPrice);
	else
	{
		ObjectSet("LongFibo6",OBJPROP_TIME2, StartTime);
		ObjectSet("LongFibo6",OBJPROP_TIME1, StartTime);
		ObjectSet("LongFibo6",OBJPROP_PRICE1,HiPrice+Range);
		ObjectSet("LongFibo6",OBJPROP_PRICE2,HiPrice);
	}
   ObjectSet("LongFibo6",OBJPROP_LEVELCOLOR,indicator_color1);
   ObjectSet("LongFibo6",OBJPROP_FIBOLEVELS,2);
   ObjectSet("LongFibo6",OBJPROP_FIRSTLEVEL+0,0.34);	ObjectSetFiboDescription("LongFibo6",0,"Daily Long Target 1 -  %$"); 
   ObjectSet("LongFibo6",OBJPROP_FIRSTLEVEL+1,0.55);	ObjectSetFiboDescription("LongFibo6",1,"Daily Long Target 2 -  %$"); 

   ObjectSet("LongFibo6",OBJPROP_RAY,true);
   ObjectSet("LongFibo6",OBJPROP_BACK,true);

	if(ObjectFind("ShortFibo6") == -1)
		ObjectCreate("ShortFibo6",OBJ_FIBO,0,StartTime,LoPrice-Range,StartTime,LoPrice);
	else
	{
		ObjectSet("ShortFibo6",OBJPROP_TIME2, StartTime);
		ObjectSet("ShortFibo6",OBJPROP_TIME1, StartTime);
		ObjectSet("ShortFibo6",OBJPROP_PRICE1,LoPrice-Range);
		ObjectSet("ShortFibo6",OBJPROP_PRICE2,LoPrice);
	}
   ObjectSet("ShortFibo6",OBJPROP_LEVELCOLOR,indicator_color3); 
   ObjectSet("ShortFibo6",OBJPROP_FIBOLEVELS,2);
   ObjectSet("ShortFibo6",OBJPROP_FIRSTLEVEL+0,0.34);	ObjectSetFiboDescription("ShortFibo6",0,"Daily Short Target 1 -  %$"); 
   ObjectSet("ShortFibo6",OBJPROP_FIRSTLEVEL+1,0.55);	ObjectSetFiboDescription("ShortFibo6",1,"Daily Short Target 2 -  %$"); 

   ObjectSet("ShortFibo6",OBJPROP_RAY,true);
   ObjectSet("ShortFibo6",OBJPROP_BACK,true);

		if(ObjectFind("dailyFibo6") == -1)
			ObjectCreate("dailyFibo6",OBJ_FIBO,0,StartTime,HiPrice,StartTime+PERIOD_D1*60,LoPrice);
		else
		{
			ObjectSet("dailyFibo6",OBJPROP_TIME2, StartTime);
			ObjectSet("dailyFibo6",OBJPROP_TIME1, StartTime+PERIOD_D1*60);
			ObjectSet("dailyFibo6",OBJPROP_PRICE1,HiPrice);
			ObjectSet("dailyFibo6",OBJPROP_PRICE2,LoPrice);
		}
   	ObjectSet("dailyFibo6",OBJPROP_LEVELCOLOR,indicator_color2); 
   	ObjectSet("dailyFibo6",OBJPROP_FIBOLEVELS,7);
   	ObjectSet("dailyFibo6",OBJPROP_FIRSTLEVEL+0,0.382);	ObjectSetFiboDescription("dailyFibo6",0,"daily Short -  %$"); 
   	ObjectSet("dailyFibo6",OBJPROP_FIRSTLEVEL+1,0.382);	ObjectSetFiboDescription("dailyFibo6",1,"daily Short -  %$"); 
   	ObjectSet("dailyFibo6",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("dailyFibo6",2,"daily Short -  %$"); 
   	ObjectSet("dailyFibo6",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("dailyFibo6",3,"daily Pivot -  %$"); 
   	ObjectSet("dailyFibo6",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("dailyFibo6",4,"daily Long -  %$"); 
   	ObjectSet("dailyFibo6",OBJPROP_FIRSTLEVEL+5,0.382);	ObjectSetFiboDescription("dailyFibo6",5,"daily Short -  %$"); 
   	ObjectSet("dailyFibo6",OBJPROP_FIRSTLEVEL+6,0.382);	ObjectSetFiboDescription("dailyFibo6",6,"daily Short -  %$"); 
   	ObjectSet("dailyFibo6",OBJPROP_RAY,true);
   	ObjectSet("dailyFibo6",OBJPROP_BACK,true);
   }

//+------------------------------------------------------------------+
//| Indicator start function
//+------------------------------------------------------------------+

int start()
{
	int shift	= iBarShift(NULL,PERIOD_D1,Time[0]) + 1;	// yesterday
	HiPrice		= iHigh(NULL,PERIOD_D1,shift);
	LoPrice		= iLow (NULL,PERIOD_D1,shift);
	StartTime	= iTime(NULL,PERIOD_D1,shift);

	if(TimeDayOfWeek(StartTime)==0/*Sunday*/)
	{//Add fridays high and low
		HiPrice = MathMax(HiPrice,iHigh(NULL,PERIOD_D1,shift+1));
		LoPrice = MathMin(LoPrice,iLow(NULL,PERIOD_D1,shift+1));
	}

	Range = HiPrice-LoPrice;

	DrawFibo();

	return(0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 