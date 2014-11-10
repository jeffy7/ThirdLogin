<%
'==============
'参数配置页面
'==============
 DEBUG_			= false									'调试信息输出开关，注意：调试信息中带有密钥等信息,配置自己的商户信息后请关闭调试
 PARTNER		= "1900000109" 							'财付通商户号
 PARTNER_KEY	= "8934e7d15453e97507ef794cf7b0519d"	'财付通密钥
 APP_ID			= "wxd930ea5d5a258f4f"					'appid
 APP_SECRET		= "db426a9829e4b49a0dcac7b4162da6b6"	'appsecret
														'paysignkey 128位字符串(非appkey)
 APP_KEY		="L8LrMqqeGRxST5reouB0K66CaYAWpqhAVsq7ggKkxHCOastWksvuX1uvmvQclxaHoYd3ElNBrNO2DHnnzgfVG9Qs473M3DTOZug5er46FhuGofumV8H2FVR9qkjSlC5K"
 NOTIFY_URL		="http://localhost/appay/notify_url.asp"  '支付完成后的回调处理页面,*替换成notify_url.asp所在路径
%>