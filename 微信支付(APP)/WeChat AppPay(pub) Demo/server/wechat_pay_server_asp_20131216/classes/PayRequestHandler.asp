<!--#include file="../util/md5.asp"-->
<!--#include file="../util/JSON_2.0.4.asp"-->
<!--#include file="../util/tenpay_util.asp"-->
<%
'
'΢��֧��������ǩ��֧������������
'============================================================================
'api˵����
'init(app_id, app_secret, partner_key, app_key);
'��ʼ��������Ĭ�ϸ�һЩ������ֵ����cmdno,date�ȡ�
'setKey(key_)'�����̻���Կ
'getLasterrCode(),��ȡ�������
'GetToken();��ȡToken
'getTokenReal();Token���ں�ʵʱ��ȡToken
'createMd5Sign(signParams);�ֵ�����Md5ǩ��
'genPackage(packageParams);��ȡpackage��
'createSHA1Sign(signParams);����ǩ��SHA1
'sendPrepay(packageParams);�ύԤ֧��
'getDebugInfo(),��ȡdebug��Ϣ
'============================================================================
'
Class PayRequestHandler
	'Token��ȡ���ص�ַ
	Private tokenUrl
	'Ԥ֧������url��ַ
	Private gateUrl
	'��ѯ֧��֪ͨ����URL
	Private notifyUrl
	'�̻�����
	Private appid, partnerkey, appsecret, appkey
	'Token
	Private Token
	'debug��Ϣ
	Private debugInfo
	'last error code 
	Private last_errcode
	'��ʼ���캯��
	Private Sub class_initialize()
		last_errcode = 0
		tokenUrl	= "https://api.weixin.qq.com/cgi-bin/token"					'��ȡToken����
		gateUrl		= "https://api.weixin.qq.com/pay/genprepay"					'�ύԤ֧��������
		notifyUrl	= "https://gw.tenpay.com/gateway/simpleverifynotifyid.xml"	'��֤notify֧����������
	End Sub
	
	'��ʼ������
	Public Function init(app_id, app_secret, partner_key, app_key)
		debugInfo	= ""
		last_errcode= 0
		appid		= app_id
		partnerkey	= partner_key
		appsecret	= app_secret
		appkey		= app_key
	End Function
	'�����̻���Կ
	Public Function setKey(key_)
		partnerkey = key_
	End Function
	'��ȡ�������
	Public Function getLasterrCode()
		getLasterrCode = last_errcode
	End Function
	'��ȡTOKEN��һ������ȡ200�Σ���Ҫ�����û�����ֵ
	Public Function GetToken()
		dim time,last_time
		'��ȡ��ǰʱ���
		time		= DateDiff("s", "01/01/1970 08:00:00", Now())
		'��application�л�ȡToken����ʱ��
		last_time	= Application("expires_in")
		If last_time <> "" And time < last_time then
			'����Ч����ֱ�ӷ���access_token
			Token	= Application("access_token")
			debugInfo	= debugInfo & "token from Application:" & Token & chr(10)
		Else
			'token ʧЧ�����»�ȡ
			Token	= getTokenReal()
			debugInfo	= debugInfo & "token real:" & Token & chr(10)
		End If
		GetToken	= Token
	End Function
	
	'ʵʱ��ȡtoken�������µ�application��
	Public Function getTokenReal()
		dim json,tk, url
		url			= tokenUrl & "?grant_type=client_credential&appid="& appid &"&secret="& appsecret
		'�������󣬷���json
		json		= httpSend(url, "GET", "")
		'����debug��Ϣ
		debugInfo	= debugInfo & "tokenUrl:" & url & chr(10)
		debugInfo	= debugInfo & "jsonContent:" & json & chr(10)
		'Jsonת���ɶ���
		set tk = JStoObject(json)
		'������ת���쳣�ж�
		on error resume next
		Err.Number = 0
		'�����Ƿ��쳣�ж�
		If isobject(tk) And tk.access_token <> "" And Err.Number = 0 Then
			Token = tk.access_token	'�жϷ����Ƿ���access_token
			Application.Lock
			'����applicationֵ
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
	
	'����packageǩ��
	Private Function createMd5Sign(signParams)
		Dim keys,k,v,i,j,md5str,sign
		keys	= signParams.Keys()
		'����ĸ˳������
		for i=0 to UBound(keys)-1
			for j=i+1 to UBound(keys)
				if StrComp(keys(i), keys(j)) > 0 then 
					tmp=keys(i)
					keys(i)=keys(j)
					keys(j)=tmp
				end if
			next
		next
		'���ǩ���ַ���
		For Each k in keys
			v = signParams(k)
			if v <> "" and k <> "sign" and k <> "key" then
				md5str	= md5str & k & "=" & v & "&"
			end if
		Next
		'���key�ֶ�
		md5str			= md5str & "key=" & partnerkey
		sign			= UCase(ASP_MD5(md5str))
		createMd5Sign	= sign
		'����debuginfo
		debugInfo		= debugInfo & "Md5str:" & md5str & " => md5 sign:" & sign & chr(10)
	End Function
	
	'��ȡpackage��������ǩ����
	Public Function genPackage(packageParams)
		Dim reqPars,k,sign
		'����ǩ��
		sign	= createMd5Sign(packageParams)
		'���package��
		For Each k In packageParams
			reqPars = reqPars & k & "=" & URLencode(packageParams(k)) & "&"
		Next
		genPackage = reqPars & "sign=" & sign
	End Function
	
	'����ǩ��SHA1
	Public Function createSHA1Sign(signParams)
		dim signStr, sign, keys, i, j, tmp, k
		keys	= signParams.Keys()
		'����ĸ˳������
		for i=0 to UBound(keys)-1
			for j=i+1 to UBound(keys)
				if StrComp(keys(i), keys(j)) > 0 then 
					tmp=keys(i)
					keys(i)=keys(j)
					keys(j)=tmp
				end if
			next
		next
		'���ǩ���ַ���
		For Each k In keys
			If signStr = "" Then
				signStr	= k & "=" & signParams(k)
			Else
				signStr = signStr & "&" & k & "=" & signParams(k)
			End If
		Next
		'����ǩ��
		sign = SHA1(signStr)
		'����debuginfo
		debugInfo		= debugInfo & "SHA1:" & signStr & " => appsign:" & sign & chr(10)
		createSHA1Sign	= sign
	End Function
	
	'�ύԤ֧��
	Public Function sendPrepay(packageParams)
		Dim k
		Dim reqPars
		set json = jsObject()
		'�������б�ת�浽json������
		For Each k In packageParams
			If k <> "appkey" Then'appkey�����
				json(k) = packageParams(k)
			End If
		Next
		'����ת����json
		reqPars		= toJson(json)
		'����Ϊ�쳣����
		on error resume next
		Err.Number = 0

		Dim json, tk, url
		'�������Ӳ���
		url				= gateUrl & "?access_token=" & Token
		'�������󣬷���Json��ʽ���ݣ�����json����
		json			= httpSend(url, "POST", reqPars)
		
		'����json���ݣ�ת���ɶ���
		set tk			= JStoObject(json)
		'�����Ƿ��쳣�ж�
		If isobject(tk) And tk.errcode = "0" And Err.Number = 0 Then
			sendPrepay	= tk.prepayid
		Else
			If tk.recode = "0" And Err.Number = 0 Then
				last_errcode = tk.errcode
			Else
				last_errcode= Err.Number
			End If
		End If
		
		'����debug info
		debugInfo		= debugInfo & "url:" & url & chr(10)
		debugInfo		= debugInfo & "reqPars:" & reqPars & chr(10)
		debugInfo		= debugInfo & "json:" & json & chr(10)
	End Function

	'��ȡdebug��Ϣ
	Public Function getDebugInfo()
		getDebugInfo	= debugInfo
		debugInfo		= ""
	End Function
End Class

%>