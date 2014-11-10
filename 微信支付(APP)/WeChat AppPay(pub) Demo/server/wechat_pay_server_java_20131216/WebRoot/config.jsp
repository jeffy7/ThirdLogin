<%@ page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<% 

//收款方

String spname = "微信支付接口测试";                                           

//商户号
String partner = "1900000109";

//密钥
String partner_key = "8934e7d15453e97507ef794cf7b0519d";

//appi
String app_id="wxd930ea5d5a258f4f";

String app_secret = "db426a9829e4b49a0dcac7b4162da6b6";

//appkey
String app_key="L8LrMqqeGRxST5reouB0K66CaYAWpqhAVsq7ggKkxHCOastWksvuX1uvmvQclxaHoYd3ElNBrNO2DHnnzgfVG9Qs473M3DTOZug5er46FhuGofumV8H2FVR9qkjSlC5K";

//支付完成后的回调处理页面
String notify_url ="http://localhost/tenpay/payNotifyUrl.jsp";
//调试模式
boolean DEBUG_ = true;
%>
