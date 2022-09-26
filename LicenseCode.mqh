//+------------------------------------------------------------------+
//|                                                  LicenseCode.mqh |
//|                            Copyright 2021, Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property strict

//+------------------------------------------------------------------+
//| License Code                                                     |
//+------------------------------------------------------------------+
class CLicenseCode
{
   private:
      string         m_LicenseCode;
      string         m_Key;
      int            m_LicenseStatus;
      
      string         ArrayToHex(uchar &arr[]);
   
   public:
                     CLicenseCode(void);
                    ~CLicenseCode(void);
      
      void           Init(string licenseCode, string key);
      bool           CheckLicense();
      int            GetLicenseStatus() { return m_LicenseStatus; }
      string         GenerateLicenseCode(int accountLogin);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CLicenseCode::CLicenseCode(void): m_LicenseStatus(0)
{}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CLicenseCode::~CLicenseCode(void)
{}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
void CLicenseCode::Init(string licenseCode, string key)
{
   m_Key = key;
   m_LicenseCode = licenseCode;
   m_LicenseStatus = 0;
}

//+------------------------------------------------------------------+
//| Check License code                                               |
//+------------------------------------------------------------------+
bool CLicenseCode::CheckLicense()
{
   if (m_LicenseStatus == 1)
      return true;
   else if (m_LicenseStatus == -1)
      return false;
   
   if (m_LicenseCode == NULL)
   {
      m_LicenseStatus = -1;
      return false;
   }
   
   if (! TerminalInfoInteger(TERMINAL_CONNECTED))
      return false;
   
   int accountLogin = (int)AccountInfoInteger(ACCOUNT_LOGIN);
   if (accountLogin < 1)
      return false;
   
   if (StringCompare(GenerateLicenseCode(accountLogin), m_LicenseCode, true) != 0)
   {
      m_LicenseStatus = -1;
      return false;
   }
   
   m_LicenseStatus = 1;
   return true;
}

//+------------------------------------------------------------------+
//| Generate License code                                            |
//+------------------------------------------------------------------+
string CLicenseCode::GenerateLicenseCode(int accountLogin)
{
   if (accountLogin < 1)
      return "";
   
   uchar src[], dst[];
   const uchar key[] = {};
   string code = m_Key + string(accountLogin);
   
   StringToCharArray(code, src, 0, StringLen(code));
   
   if (CryptEncode(CRYPT_HASH_MD5, src, key, dst) <= 0)
      return "";
   
   return ArrayToHex(dst);
}

//+------------------------------------------------------------------+
//| ArrayToHex                                                       |
//+------------------------------------------------------------------+
string CLicenseCode::ArrayToHex(uchar &arr[])
{
   string res = "";
   int cnt = ArraySize(arr);
   
   for (int i=0; i<cnt; i++)
      res += StringFormat("%.2X", arr[i]);

   return res;
}

//+------------------------------------------------------------------+
