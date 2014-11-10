<%@LANGUAGE="VBSCRIPT" CODEPAGE="936"%>
<!--#include file="./tenpay_config.asp"-->
<!--#include file="./classes/PayRequestHandler.asp"-->
<%
'---------------------------------------------------------
'΢��֧��������ǩ��֧������ʾ�����̻����մ��ĵ����п�������
'����˷������ݣ�App��ȡ�����ݺ��ֱ�ӵ���΢��֧��
'---------------------------------------------------------
'����������ʼ��
Dim order_price,product_name,out_trade_no
'��ȡ�ύ����Ʒ�۸���ԪΪ��λ
order_price		= trim(request("order_price"))
If order_price = "" Then order_price = "0.01"
'��ȡ�ύ����Ʒ����
product_name	= trim(request("product_name"))
If product_name = "" Then product_name = "������Ʒ����"
'��ȡ�ύ�Ķ�����
out_trade_no	= trim(request("order_no"))
If out_trade_no = "" Then out_trade_no = getStrNow & getStrRandNumber(9999,1000)
Dim total_fee
'��Ʒ�۸񣨰����˷ѣ����Է�Ϊ��λ
total_fee		= cint(100*order_price)

'=========================
'��ȡToken
'=========================
Dim payHandler, outParams
'�����������
Set outParams	= Server.CreateObject("Scripting.Dictionary")

Set payHandler	= new PayRequestHandler
'��ʼ��
payHandler.init APP_ID, APP_SECRET, PARTNER_KEY, APP_KEY

Dim Token
Token			= payHandler.GetToken()
If Token <> "" Then
	'=========================
	'����Ԥ֧����
	'=========================
	'����package��������
	Set packageParams = Server.CreateObject("Scripting.Dictionary")
	packageParams.Add	"bank_type",	"WX"	    		'֧������
	packageParams.Add	"body",			product_name	    '��Ʒ����
	packageParams.Add	"fee_type",		"1"					'���б���
	packageParams.Add	"input_charset","GBK"			    '�ַ���
	packageParams.Add	"notify_url",	NOTIFY_URL			'֪ͨ��ַ
	packageParams.Add	"out_trade_no",	out_trade_no		'�̻�������
	packageParams.Add	"partner",		PARTNER				'�����̻���
	packageParams.Add	"total_fee",	total_fee			'��Ʒ�ܽ��,�Է�Ϊ��λ
	packageParams.Add	"spbill_create_ip",	Request.ServerVariables("REMOTE_ADDR")	'֧������IP

	dim package, time_stamp, nonce_str, traceid, prepayId, sign
	'��ȡpackage��
	package		= payHandler.genPackage(packageParams)
	time_stamp	= DateDiff("s", "01/01/1970 00:00:00", Now())
	nonce_str	= ASP_MD5(Rnd())
	traceid		= "mytestid_001"
	
	'����֧������
	Set signParams = Server.CreateObject("Scripting.Dictionary")
	signParams.Add	"appid",		APP_ID
	signParams.Add	"appkey",		APP_KEY
	signParams.Add	"noncestr",		nonce_str
	signParams.Add	"package",		package
	signParams.Add	"timestamp",	time_stamp
	signParams.Add	"traceid",		traceid
	
	'����֧��ǩ��
	sign		= payHandler.createSHA1Sign(signParams)
	
	'���ӷǲ���ǩ���Ķ������
	signParams.Add	"sign_method",	"sha1"
	signParams.Add	"app_signature",sign
	
	'��ȡprepayId
	prepayId	= payHandler.sendPrepay(signParams)
	If prepayId <> "" Then
		Set prePayParams = Server.CreateObject("Scripting.Dictionary")
		'ǩ�������б�
		prePayParams.Add	"appid",		APP_ID
		prePayParams.Add	"appkey",		APP_KEY
		prePayParams.Add	"noncestr",		nonce_str
		prePayParams.Add	"package",		"Sign=WXPay"	'5.0.3���°�ֻ��֧�ָù̶�ֵ"Sign=" & package
		prePayParams.Add	"partnerid",	PARTNER
		prePayParams.Add	"prepayid",		prepayId
		prePayParams.Add	"timestamp",	time_stamp
		'����ǩ��
		sign	= payHandler.createSHA1Sign(prePayParams)
		'��������б�
		outParams.Add	"retcode",		0
		outParams.Add	"retmsg",		"OK"
		outParams.Add	"appid",		APP_ID
		outParams.Add	"partnerid",	PARTNER
		outParams.Add	"noncestr",		nonce_str
		outParams.Add	"package",		prePayParams.Item("package")
		outParams.Add	"prepayid",		prepayId
		outParams.Add	"timestamp",	time_stamp
		outParams.Add	"sign",			sign
	Else
		'�����ʺŶ��app���ԣ���Ҫ�ж�Token�Ƿ�ʧЧ���������»�ȡһ��
		If payHandler.getLasterrCode() = 40001 Then
			Token	= payHandler.getTokenReal()
		End If
		outParams.Add	"retcode",		-2
		outParams.Add	"retmsg",		"���󣺻�ȡprepayIdʧ��"
	End If
Else
	outParams.Add	"retcode",		-1
	outParams.Add	"retmsg",		"���󣺻�ȡ����Token"
End If
'=========================
'��������б�
'=========================
Response.clear
'Json ���
Response.ContentType="text/json"
set json = jsObject()
For Each k In outParams
	json(k) = outParams(k)
Next
Response.Write toJson(json)
'debug��Ϣ,ע��������������ַ�����ҪJsEncode
If DEBUG_ Then
	Response.Write chr(10) & "/*" & (payHandler.getDebugInfo()) & "*/"
End If
%>