<%@LANGUAGE="VBSCRIPT" CODEPAGE="936"%>
<!--#include file="./tenpay_config.asp"-->
<!--#include file="./classes/PayRequestHandler.asp"-->
<%
'---------------------------------------------------------
'微信支付服务器签名支付请求示例，商户按照此文档进行开发即可
'服务端返回数据，App获取到数据后可直接调起微信支付
'---------------------------------------------------------
'订单参数初始化
Dim order_price,product_name,out_trade_no
'获取提交的商品价格，以元为单位
order_price		= trim(request("order_price"))
If order_price = "" Then order_price = "0.01"
'获取提交的商品名称
product_name	= trim(request("product_name"))
If product_name = "" Then product_name = "测试商品名称"
'获取提交的订单号
out_trade_no	= trim(request("order_no"))
If out_trade_no = "" Then out_trade_no = getStrNow & getStrRandNumber(9999,1000)
Dim total_fee
'商品价格（包含运费），以分为单位
total_fee		= cint(100*order_price)

'=========================
'获取Token
'=========================
Dim payHandler, outParams
'输出参数集合
Set outParams	= Server.CreateObject("Scripting.Dictionary")

Set payHandler	= new PayRequestHandler
'初始化
payHandler.init APP_ID, APP_SECRET, PARTNER_KEY, APP_KEY

Dim Token
Token			= payHandler.GetToken()
If Token <> "" Then
	'=========================
	'生成预支付单
	'=========================
	'设置package订单参数
	Set packageParams = Server.CreateObject("Scripting.Dictionary")
	packageParams.Add	"bank_type",	"WX"	    		'支付类型
	packageParams.Add	"body",			product_name	    '商品描述
	packageParams.Add	"fee_type",		"1"					'银行币种
	packageParams.Add	"input_charset","GBK"			    '字符集
	packageParams.Add	"notify_url",	NOTIFY_URL			'通知地址
	packageParams.Add	"out_trade_no",	out_trade_no		'商户订单号
	packageParams.Add	"partner",		PARTNER				'设置商户号
	packageParams.Add	"total_fee",	total_fee			'商品总金额,以分为单位
	packageParams.Add	"spbill_create_ip",	Request.ServerVariables("REMOTE_ADDR")	'支付机器IP

	dim package, time_stamp, nonce_str, traceid, prepayId, sign
	'获取package包
	package		= payHandler.genPackage(packageParams)
	time_stamp	= DateDiff("s", "01/01/1970 00:00:00", Now())
	nonce_str	= ASP_MD5(Rnd())
	traceid		= "mytestid_001"
	
	'设置支付参数
	Set signParams = Server.CreateObject("Scripting.Dictionary")
	signParams.Add	"appid",		APP_ID
	signParams.Add	"appkey",		APP_KEY
	signParams.Add	"noncestr",		nonce_str
	signParams.Add	"package",		package
	signParams.Add	"timestamp",	time_stamp
	signParams.Add	"traceid",		traceid
	
	'生成支付签名
	sign		= payHandler.createSHA1Sign(signParams)
	
	'增加非参与签名的额外参数
	signParams.Add	"sign_method",	"sha1"
	signParams.Add	"app_signature",sign
	
	'获取prepayId
	prepayId	= payHandler.sendPrepay(signParams)
	If prepayId <> "" Then
		Set prePayParams = Server.CreateObject("Scripting.Dictionary")
		'签名参数列表
		prePayParams.Add	"appid",		APP_ID
		prePayParams.Add	"appkey",		APP_KEY
		prePayParams.Add	"noncestr",		nonce_str
		prePayParams.Add	"package",		"Sign=WXPay"	'5.0.3以下版只本支持该固定值"Sign=" & package
		prePayParams.Add	"partnerid",	PARTNER
		prePayParams.Add	"prepayid",		prepayId
		prePayParams.Add	"timestamp",	time_stamp
		'生成签名
		sign	= payHandler.createSHA1Sign(prePayParams)
		'输出参数列表
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
		'测试帐号多个app测试，需要判断Token是否失效，否则重新获取一次
		If payHandler.getLasterrCode() = 40001 Then
			Token	= payHandler.getTokenReal()
		End If
		outParams.Add	"retcode",		-2
		outParams.Add	"retmsg",		"错误：获取prepayId失败"
	End If
Else
	outParams.Add	"retcode",		-1
	outParams.Add	"retmsg",		"错误：获取不到Token"
End If
'=========================
'输出参数列表
'=========================
Response.clear
'Json 输出
Response.ContentType="text/json"
set json = jsObject()
For Each k In outParams
	json(k) = outParams(k)
Next
Response.Write toJson(json)
'debug信息,注意参数含有特殊字符，需要JsEncode
If DEBUG_ Then
	Response.Write chr(10) & "/*" & (payHandler.getDebugInfo()) & "*/"
End If
%>