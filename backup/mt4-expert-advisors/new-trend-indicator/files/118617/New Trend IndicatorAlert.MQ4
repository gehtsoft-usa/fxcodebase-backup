	// More information about this indicator can be found at:
	//http://fxcodebase.com/code/viewtopic.php?f=38&t=65918

	//+------------------------------------------------------------------+
	//|                               Copyright � 2018, Gehtsoft USA LLC | 
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

	#property copyright "Copyright � 2017, Gehtsoft USA LLC"
	#property link      "http://fxcodebase.com"
	#property version "1.0"

	#property indicator_separate_window
	#property indicator_buffers 3
	#property indicator_color1 Green
	#property indicator_color2 Red
	#property indicator_color3 Gray

	#property indicator_width1 5
	#property indicator_width2 5
	#property indicator_width3 5
	
	extern int ATR_Period=12; 
	extern int MVA_Period=14;

	extern bool     Sound_Alert              = true;
	extern bool     Email_Alert              = false;
	extern bool     Telegram_Alert           = false;
	extern string   Telegram_Key             = "";
	extern string   Comment2                 = "- You can get a telegram key by starting a dialog with @profit_robots_bot -";
	extern string   Comment3                 = "- Also, you need to install TelegramNotificationsLib.dll and allow use of dll in the indicator parameters window -";

	
	double UP[], DN[],NE[];
	
	

	int init()
	{
	IndicatorShortName("New Trend Indicator");
	IndicatorDigits(Digits);
	
	IndicatorBuffers(3);
		
	
	SetIndexStyle(0,DRAW_HISTOGRAM);
	SetIndexBuffer(0,UP);
	SetIndexStyle(1,DRAW_HISTOGRAM);
	SetIndexBuffer(1,DN);
	SetIndexStyle(2,DRAW_HISTOGRAM);
	SetIndexBuffer(2,NE);
	
	return(0);
	}

	int deinit()
	{

	return(0);
	}

	#import "TelegramNotificationsLib.dll"
	void AlertTelegram(string key, string text, string instrument, string timeframe);
	#import

	string GetTimeframe()
	{
		switch (_Period)
		{
			case PERIOD_M1: return "M1";
			case PERIOD_M5: return "M5";
			case PERIOD_D1: return "D1";
			case PERIOD_H1: return "H1";
			case PERIOD_H4: return "H4";
			case PERIOD_M15: return "M15";
			case PERIOD_M30: return "M30";
			case PERIOD_MN1: return "MN1";
			case PERIOD_W1: return "W1";
		}
		return "M1";
	}

	void SendNotifications(const int direction)
	{
		static datetime _lastDatetime;
		static int _lastDirection;
		datetime currentTime = iTime(NULL, NULL, 0);
		if (_lastDatetime == currentTime || _lastDirection == direction)
			return;

		_lastDirection = direction;
		_lastDatetime = currentTime;
		if (direction == 0)
			return;
			
		string tf = GetTimeframe();
		string alert_Subject;
		string alert_Body;
		switch (direction)
		{
			case 1:
				alert_Subject = "Up on " + _Symbol + "/" + tf;
				alert_Body = "Up on " + _Symbol + "/" + tf;
				break;
			case -1:
				alert_Subject = "Down on " + _Symbol + "/" + tf;
				alert_Body = "Down on " + _Symbol + "/" + tf;
				break;
		}
		
		if (Sound_Alert)
			Alert(alert_Body);
		if (Email_Alert)
			SendMail(alert_Subject, alert_Body);
		if (Telegram_Alert && Telegram_Key != "")
			AlertTelegram(Telegram_Key, alert_Body, _Symbol, tf);
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
		
		double MVA;
		double ATR;
		while (pos>=0)
		{
			MVA= iMA(NULL,0,MVA_Period ,0,MODE_SMA,PRICE_CLOSE,pos);
			ATR= iATR(NULL,0,ATR_Period,pos);
			
			NE[pos]=1.;

			if (Close[pos] >  MVA + ATR  )
			{
				if (pos == 0)
					SendNotifications(1);
				UP[pos]=1.;
				DN[pos]=0.;
				NE[pos]=0.;
			}
			
			if (Close[pos] <  MVA - ATR  ) 
			{
				if (pos == 0)
					SendNotifications(-1);
				DN[pos]=1.;
				UP[pos]=0.;
				NE[pos]=0.;
			}
			pos--;
		}
		return(0);
	}

