<!--#include file="./PayRequestHandler.asp"-->
<%
'
'΢��֧��������ǩ��֧������Ӧ����
'============================================================================
'api˵����
'getKey()/setKey(),��ȡ/������Կ
'getParameter()/setParameter(),��ȡ/���ò���ֵ
'getAllParameters(),��ȡ���в���
'isTenpaySign(),�Ƿ�Ƹ�ͨǩ��,true:�� false:��
'getDebugInfo(),��ȡdebug��Ϣ
'============================================================================
'
Class PayResponseHandler

	'��Կ
	Private key

	'Ӧ��Ĳ���
	Private parameters

	'debug��Ϣ
	Private debugInfo

	'��ʼ���캯��
	Private Sub class_initialize()
		key = ""
		Set parameters = Server.CreateObject("Scripting.Dictionary")	'���ü���
		debugInfo = ""
		parameters.RemoveAll
	End Sub
	'��ȡҳ���ύ��get��post����
	Public Function Init
		'��ȡ�������Ĳ���
		Dim k, v
		'��ȡҳ��GET����
		For Each k In Request.QueryString
			v = Request.QueryString(k)
			setParameter k,v
		Next
		'��ȡҳ��POST����
		For Each k In Request.Form
			v = Request(k)
			setParameter k,v
		Next
	End Function
	'��ȡ��Կ
	Public Function getKey()
		getKey = key
	End Function
	
	'������Կ
	Public Function setKey(key_)
		key = key_
	End Function
	
	'��ȡ����ֵ
	Public Function getParameter(parameter)
		getParameter = parameters.Item(parameter)
	End Function
	
	'���ò���ֵ
	Public Sub setParameter(parameter, parameterValue)
		If parameters.Exists(parameter) = True Then
			parameters.Remove(parameter)
		End If
		parameters.Add parameter, parameterValue	
	End Sub
	'��ղ���ֵ
	Public Sub clearParameter()
		parameters.RemoveAll
	End Sub
	
	'��ȡ��������Ĳ���,����Scripting.Dictionary
	Public Function getAllParameters()
		getAllParameters = parameters
	End Function

	'�Ƿ�Ƹ�ͨǩ��
	'true:�� false:��
	Public Function isTenpaySign()
		Dim keys,k,v
		keys	= parameters.Keys()
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
		md5str = ""
		'���ǩ���ַ���
		For Each k in keys
			v = getParameter(k)
			if v <> "" and k <> "sign" and k <> "key" then
				md5str = md5str & k & "=" & v & "&"
			end if
		Next
		'������Key�ֶ�
		md5str = md5str & "key=" & key
		Dim sign
		'����ǩ��ת����Сд
		sign= LCase(ASP_MD5(md5str))
		
		Dim tenpaySign
		tenpaySign = LCase( getParameter("sign"))
		'debugInfo
		debugInfo = debugInfo & md5str & " => sign:" & sign & " tenpaySign:" & tenpaySign & chr(10)

		isTenpaySign = (sign = tenpaySign)
	End Function
	
	'��ȡdebug��Ϣ
	Function getDebugInfo()
		getDebugInfo = debugInfo
	End Function
End Class
%>