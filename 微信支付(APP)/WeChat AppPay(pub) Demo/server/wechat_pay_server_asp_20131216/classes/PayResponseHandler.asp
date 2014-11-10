<!--#include file="./PayRequestHandler.asp"-->
<%
'
'微信支付服务器签名支付请求应答类
'============================================================================
'api说明：
'getKey()/setKey(),获取/设置密钥
'getParameter()/setParameter(),获取/设置参数值
'getAllParameters(),获取所有参数
'isTenpaySign(),是否财付通签名,true:是 false:否
'getDebugInfo(),获取debug信息
'============================================================================
'
Class PayResponseHandler

	'密钥
	Private key

	'应答的参数
	Private parameters

	'debug信息
	Private debugInfo

	'初始构造函数
	Private Sub class_initialize()
		key = ""
		Set parameters = Server.CreateObject("Scripting.Dictionary")	'设置集合
		debugInfo = ""
		parameters.RemoveAll
	End Sub
	'获取页面提交的get和post参数
	Public Function Init
		'获取传过来的参数
		Dim k, v
		'获取页面GET参数
		For Each k In Request.QueryString
			v = Request.QueryString(k)
			setParameter k,v
		Next
		'获取页面POST参数
		For Each k In Request.Form
			v = Request(k)
			setParameter k,v
		Next
	End Function
	'获取密钥
	Public Function getKey()
		getKey = key
	End Function
	
	'设置密钥
	Public Function setKey(key_)
		key = key_
	End Function
	
	'获取参数值
	Public Function getParameter(parameter)
		getParameter = parameters.Item(parameter)
	End Function
	
	'设置参数值
	Public Sub setParameter(parameter, parameterValue)
		If parameters.Exists(parameter) = True Then
			parameters.Remove(parameter)
		End If
		parameters.Add parameter, parameterValue	
	End Sub
	'清空参数值
	Public Sub clearParameter()
		parameters.RemoveAll
	End Sub
	
	'获取所有请求的参数,返回Scripting.Dictionary
	Public Function getAllParameters()
		getAllParameters = parameters
	End Function

	'是否财付通签名
	'true:是 false:否
	Public Function isTenpaySign()
		Dim keys,k,v
		keys	= parameters.Keys()
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
		md5str = ""
		'组合签名字符串
		For Each k in keys
			v = getParameter(k)
			if v <> "" and k <> "sign" and k <> "key" then
				md5str = md5str & k & "=" & v & "&"
			end if
		Next
		'最后添加Key字段
		md5str = md5str & "key=" & key
		Dim sign
		'生成签名转换成小写
		sign= LCase(ASP_MD5(md5str))
		
		Dim tenpaySign
		tenpaySign = LCase( getParameter("sign"))
		'debugInfo
		debugInfo = debugInfo & md5str & " => sign:" & sign & " tenpaySign:" & tenpaySign & chr(10)

		isTenpaySign = (sign = tenpaySign)
	End Function
	
	'获取debug信息
	Function getDebugInfo()
		getDebugInfo = debugInfo
	End Function
End Class
%>