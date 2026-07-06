//+------------------------------------------------------------------+
//|                                                  Read_Orders.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property show_inputs

#include <stdlib.mqh>

extern string FileName="orders";
extern bool CurrentSymbolOnly=false;
extern bool MarketOrdersOnly=false;
extern int Slippage=5;
extern bool WriteComments=true;

void OComment(string _Comment)
{
 if (WriteComments) Print(_Comment);
 return;
}

int OpenOrder(int _Line, string _Symbol, string _Operation, double _Price, double _Lots, double _SL, double _TP, int _Magic)
{
 int res;
 int err;
 double CurrPrice;
 if (CurrentSymbolOnly && Symbol()!=_Symbol) return (0);
 if (_Price==0)
 {
  if (_Operation=="B")
  {
   CurrPrice=MarketInfo(_Symbol, MODE_ASK);
   res=OrderSend(_Symbol, OP_BUY, _Lots, CurrPrice, Slippage, _SL, _TP, "", _Magic);
  }
  else
  {
   if (_Operation=="S")
   {
    CurrPrice=MarketInfo(_Symbol, MODE_BID);
    res=OrderSend(_Symbol, OP_SELL, _Lots, CurrPrice, Slippage, _SL, _TP, "", _Magic);
   }
  }
  if (res==-1)
  {
   err=GetLastError();
   OComment("Line "+_Line+": Error: "+ErrorDescription(err));
  }
  else
  {
   OComment("Line "+_Line+": Order was opened successfully.");
  }
 }
 else
 {
  if (!MarketOrdersOnly)
  {
   if (_Operation=="B")
   {
    CurrPrice=MarketInfo(_Symbol, MODE_ASK);
    if (_Price>CurrPrice)
    {
     res=OrderSend(_Symbol, OP_BUYSTOP, _Lots, _Price, Slippage, _SL, _TP, "", _Magic);
    }
    else
    {
     res=OrderSend(_Symbol, OP_BUYLIMIT, _Lots, _Price, Slippage, _SL, _TP, "", _Magic);
    }
   }
   else
   {
    if (_Operation=="S")
    {
     CurrPrice=MarketInfo(_Symbol, MODE_BID);
     if (_Price>CurrPrice)
     {
      res=OrderSend(_Symbol, OP_SELLLIMIT, _Lots, _Price, Slippage, _SL, _TP, "", _Magic);
     }
     else
     {
      res=OrderSend(_Symbol, OP_SELLSTOP, _Lots, _Price, Slippage, _SL, _TP, "", _Magic);
     }
    }
   } 
   if (res==-1)
   {
    err=GetLastError();
    OComment("Line "+_Line+": Error: "+ErrorDescription(err));
   }
   else
   {
    OComment("Line "+_Line+": Order was opened successfully.");
   } 
  }
 }
}

void ReadFile()
{
 int FF=FileOpen(FileName, FILE_CSV|FILE_READ,";");
 string Str;
 int Pos;
 string _Symbol, _Operation;
 double _Price, _Lots, _SL, _TP;
 int _Magic;
 int _Line=0;
 while (!(FileIsEnding(FF)))
 {
  Str=StringTrimLeft(StringTrimRight(FileReadString(FF)));
  if (Str=="") continue;
  if (StringFind(Str, "//")==0) continue;
  Pos=StringFind(Str, ",");
  if (Pos!=-1)
  {
   _Symbol=StringTrimLeft(StringTrimRight(StringSubstr(Str, 0, Pos)));
   Str=StringSubstr(Str, Pos+1);
   Pos=StringFind(Str, ",");
   if (Pos!=-1)
   {
    _Operation=StringTrimLeft(StringTrimRight(StringSubstr(Str, 0, Pos)));
    Str=StringSubstr(Str, Pos+1);
    Pos=StringFind(Str, ",");
    if (Pos!=-1)
    {
     _Price=StrToDouble(StringSubstr(Str, 0, Pos));
     Str=StringSubstr(Str, Pos+1);
     Pos=StringFind(Str, ",");
     if (Pos!=-1)
     {
      _Lots=StrToDouble(StringSubstr(Str, 0, Pos));
      Str=StringSubstr(Str, Pos+1);
      Pos=StringFind(Str, ",");
      if (Pos!=-1)
      {
       _SL=StrToDouble(StringSubstr(Str, 0, Pos));
       Str=StringSubstr(Str, Pos+1);
       Pos=StringFind(Str, ",");
       if (Pos!=-1)
       {
        _TP=StrToDouble(StringSubstr(Str, 0, Pos));
        _Magic=StrToInteger(StringSubstr(Str, Pos+1, StringLen(Str)-Pos-1));
        _Line++;
        Print(_Symbol, ", ", _Operation, ", ", _Price, ", ", _Lots, ", ", _SL, ", ", _TP, ", ", _Magic);
        OpenOrder(_Line, _Symbol, _Operation, _Price, _Lots, _SL, _TP, _Magic);
       }
      }
     }
    }
   }
  }
 }
 FileClose(FF);
}

int init()
  {
   return(0);
  }
int deinit()
  {
   return(0);
  }
int start()
  {
   ReadFile();
   return(0);
  }

