//+------------------------------------------------------------------+
//|                                                  LicenseCode.mq5 |
//|                            Copyright 2021, Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property version   "1.00"
#property indicator_chart_window

//--- includes
#include <DS\LicenseCode\LicenseCode.mqh>

//--- inputs
input string i_LicenseCode = "";    // LicenseCode

//--- global variables
CLicenseCode LicenseCode;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   LicenseCode.Init(i_LicenseCode, "w0ypiN0X@$DSscTEY9/f!KeDlDnwVcv$", "b3541c2fbbfa62952349ce1a9b1f53b1");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (! LicenseCode.CheckLicense())
   {
      Comment("ERROR: License code!");
      return rates_total;
   }
   
   Comment("Price: ", SymbolInfoDouble(Symbol(), SYMBOL_BID));
   
   return(rates_total);
}

//+------------------------------------------------------------------+
