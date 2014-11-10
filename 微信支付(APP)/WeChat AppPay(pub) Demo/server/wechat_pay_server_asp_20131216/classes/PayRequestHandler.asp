<!--#include file="../util/md5.asp"-->
<!--#include file="../util/JSON_2.0.4.asp"-->
<!--#include file="../util/tenpay_util.asp"-->
<%
'
'微信支付服务器签名支付请求请求类
'============================================================================
'api说明：
'init(app_id, app_secret, partner_key, app_key);
'初始化函数，默认给一些参数赋值，如cmdno,date等。
'setKey(key_)'设置商户密钥
'getLasterrCode(),获取最后错误号
'GetToken();获取Token
'getTokenReal();Token过期后实时获取Token
'createMd5Sign(signParams);字典生成Md5签名
'genPackage(packageParams);获取package包
'createSHA1Sign(signParams);创建签名SHA1
'sendPrepay(packageParams);提交预支付
'getDebugInfo(),获取debug信息
'============================================================================
'
Class PayRequestHandler
	'Token获取网关地址
	Private tokenUrl
	'预支付网关url地址
	Private gateUrl
	'查询支付通知网关URL
	Private notifyUrl
	'商户参数
	Private appid, partnerkey, appsecret, appkey
	'Token
	Private Token
	'debug信息
	Private debugInfo
	'last error code 
	Private last_errcode
	'初始构造函数
	Private Sub class_initialize()
		last_errcode = 0
		tokenUrl	= "https://api.weixin.qq.com/cgi-bin/token"					'获取Token网关
		gateUrl		= "https://api.weixin.qq.com/pay/genprepay"					'提交预支付单网关
		notifyUrl	= "https://gw.tenpay.com/gateway/simpleverifynotifyid.xml"	'验证notify支付订单网关
	End Sub
	
	'初始化函数
	Public Function init(app_id, app_secret, partner_key, app_key)
		debugInfo	= ""
		last_errcode= 0
		appid		= app_id
		partnerkey	= partner_key
		appsecret	= app_secret
		appkey		= app_key
	End Function
	'设置商户密钥
	Public Function setKey(key_)
		partnerkey = key_
	End Function
	'获取最后错误号
	Public Function getLasterrCode()
		getLasterrCode = last_errcode
	End Function
	'获取TOKEN，一天最多获取200次，需要所有用户共享值
	Public Function GetToken()
		dim time,last_time
		'获取当前时间戳
		time		= DateDiff("s", "01/01/1970 08:00:00", Now())
		'从application中获取Token过期时间
		last_time	= Application("expires_in")
		If last_time <> "" And time < last_time then
			'在有效期内直接返回access_token
			Token	= Application("access_token")
			debugInfo	= debugInfo & "token from Application:" & Token & chr(10)
		Else
			'token 失效后重新获取
			Token	= getTokenReal()
			debugInfo	= debugInfo & "token real:" & Token & chr(10)
		End If
		GetToken	= Token
	End Function
	
	'实时获取token，并更新到application中
	Public Function getTokenReal()
		dim json,tk, url
		url			= tokenUrl & "?grant_type=client_credential&appid="& appid &"&secret="& appsecret
		'发送请求，返回json
		json		= httpSend(url, "GET", "")
		'设置debug信息
		debugInfo	= debugInfo & "tokenUrl:" & url & chr(10)
		debugInfo	= debugInfo & "jsonContent:" & json & chr(10)
		'Json转换成对象
		set tk = JStoObject(json)
		'以下是转换异常判断
		on error resume next
		Err.Number = 0
		'返回是否异常判断
		If isobject(tk) And tk.access_token <> "" And Err.Number = 0 Then
			Token = tk.access_token	'判断返回是否含有access_token
			Application.Lock
			'更新application值
			Application("access_token")	= Token
			Application("expires_in")	= DateDiff("s", "01/01/1970 08:00:00", Now()) + tk.expires_in
			Application.Unlock
			getTokenReal = Token
		Else
			last_errcode=Err.Number
			getTokenReal= ""
			Token		= ""
		End If
	End Function
	
	'创建package签名
	Private Function createMd5Sign(signParams)
		Dim keys,k,v,i,j,md5str,sign
		keys	= signParams.Keys()
		'按字母顺序排序
		for i=0 to UBound(keys)-1
			for j=i+1 to UBound(keys)
				if StrComp(keys(i), keys(j)) > 0 then 
					tmp=keys(i)
					keys(i)=keys(j)
					keys(j)=tmp
				end if
			next
		next
		'组合签名字符串
		For Each k in keys
			v = signParams(k)
			if v <> "" and k <> "sign" and k <> "key" then
				md5str	= md5str & k & "=" & v & "&"
			end if
		Next
		'添加key字段
		md5str			= md5str & "key=" & partnerkey
		sign			= UCase(ASP_MD5(md5str))
		createMd5Sign	= sign
		'设置debuginfo
		debugInfo		= debugInfo & "Md5str:" & md5str & " => md5 sign:" & sign & chr(10)
	End Function
	
	'获取package带参数的签名包
	Public Function genPackage(packageParams)
		Dim reqPars,k,sign
		'生成签名
		sign	= createMd5Sign(packageParams)
		'组合package包
		For Each k In packageParams
			reqPars = reqPars & k & "=" & URLencode(packageParams(k)) & "&"
		Next
		genPackage = reqPars & "sign=" & sign
	End Function
	
	'创建签名SHA1
	Public Function createSHA1Sign(signParams)
		dim signStr, sign, keys, i, j, tmp, k
		keys	= signParams.Keys()
		'按字母顺序排序
		for i=0 to UBound(keys)-1
			for j=i+1 to UBound(keys)
				if StrComp(keys(i), keys(j)) > 0 then 
					tmp=keys(i)
					keys(i)=keys(j)
					keys(j)=tmp
				end if
			next
		next
		'组合签名字符串
		For Each k In keys
			If signStr = "" Then
				signStr	= k & "=" & signParams(k)
			Else
				signStr = signStr & "&" & k & "=" & signParams(k)
			End If
		Next
		'生成签名
		sign = SHA1(signStr)
		'设置debuginfo
		debugInfo		= debugInfo & "SHA1:" & signStr & " => appsign:" & sign & chr(10)
		createSHA1Sign	= sign
	End Function
	
	'提交预支付
	Public Function sendPrepay(packageParams)
		Dim k
		Dim reqPars
		set json = jsObject()
		'将参数列表转存到json对象中
		For Each k In packageParams
			If k <> "appkey" Then'appkey不输出
				json(k) = packageParams(k)
			End If
		Next
		'集合转换成json
		reqPars		= toJson(json)
		'以下为异常处理
		on error resume next
		Err.Number = 0

		Dim json, tk, url
		'设置链接参数
		url				= gateUrl & "?access_token=" & Token
		'发送请求，发送Json格式数据，返回json数据
		json			= httpSend(url, "POST", reqPars)
		
		'返回json数据，转换成对象
		set tk			= JStoObject(json)
		'返回是否异常判断
		If isobject(tk) And tk.errcode = "0" And Err.Number = 0 Then
			sendPrepay	= tk.prepayid
		Else
			If tk.recode = "0" And Err.Number = 0 Then
				last_errcode = tk.errcode
			Else
				last_errcode= Err.Number
			End If
		End If
		
		'设置debug info
		debugInfo		= debugInfo & "url:" & url & chr(10)
		debugInfo		= debugInfo & "reqPars:" & reqPars & chr(10)
		debugInfo		= debugInfo & "json:" & json & chr(10)
	End Function

	'获取debug信息
	Public Function getDebugInfo()
		getDebugInfo	= debugInfo
		debugInfo		= ""
	End Function
End Class

%>