<%@ page language="java" contentType="text/html; charset=GBK"
	pageEncoding="GBK"%>
<%@ page import="com.wxap.util.TenpayUtil"%>
<%@ page import="com.wxap.util.MD5Util"%>
<%@ page import="com.wxap.RequestHandler"%>
<%@ page import="com.wxap.ResponseHandler"%>
<%@ page import="com.wxap.client.TenpayHttpClient"%>
<%@ page import="java.io.BufferedWriter"%>
<%@ page import="java.io.BufferedOutputStream"%>
<%@ page import="java.io.OutputStream"%>
<%@page import="com.wxap.util.Sha1Util"%>
<%@page import="java.util.SortedMap"%>
<%@page import="java.util.TreeMap"%>
<%@page import="com.google.gson.Gson"%>
<%@ include file="config.jsp"%>
<%
	//---------------------------------------------------------
	//'微信支付服务器签名支付请求示例，商户按照此文档进行开发即可
	//'服务端返回数据，App获取到数据后可直接调起微信支付
	//---------------------------------------------------------

	//---------------生成订单号 开始------------------------
	//当前时间 yyyyMMddHHmmss
	String currTime = TenpayUtil.getCurrTime();
	//8位日期
	String strTime = currTime.substring(8, currTime.length());
	//四位随机数
	String strRandom = TenpayUtil.buildRandom(4) + "";
	//10位序列号,可以自行调整。
	String strReq = strTime + strRandom;
	//订单号，此处用时间加随机数生成，商户根据自己情况调整，只要保持全局唯一就行
	String out_trade_no = strReq;
	//---------------生成订单号 结束------------------------

	//获取提交的商品价格
	String order_price = request.getParameter("order_price");
	//获取提交的商品名称
	String product_name = request.getParameter("product_name");

	TreeMap<String, String> outParams = new TreeMap<String, String>();

	RequestHandler reqHandler = new RequestHandler(request, response);
	TenpayHttpClient httpClient = new TenpayHttpClient();
    //初始化 
	reqHandler.init();
	reqHandler.init(app_id, app_secret, app_key, partner, partner_key);

	//获取token值 
	String token = reqHandler.GetToken();
	if (!"".equals(token)) {
		//=========================
		//生成预支付单
		//=========================
		//设置package订单参数
		SortedMap<String, String> packageParams = new TreeMap<String, String>();
		packageParams.put("bank_type", "WX"); //商品描述   
		packageParams.put("body", "测试商品名称"); //商品描述   
		packageParams.put("notify_url", notify_url); //接收财付通通知的URL  
		packageParams.put("partner", partner); //商户号    
		packageParams.put("out_trade_no", "out_trade_no"); //商家订单号  
		packageParams.put("total_fee", "1"); //商品金额,以分为单位  
		packageParams.put("spbill_create_ip", request.getRemoteAddr()); //订单生成的机器IP，指用户浏览器端IP  
		packageParams.put("fee_type", "1"); //币种，1人民币   66
		packageParams.put("input_charset", "GBK"); //字符编码

		//获取package包
		String packageValue = reqHandler.genPackage(packageParams);

		String noncestr = Sha1Util.getNonceStr();
		String timestamp = Sha1Util.getTimeStamp();
		String traceid = "mytestid_001";

		//设置支付参数
		SortedMap<String, String> signParams = new TreeMap<String, String>();
		signParams.put("appid", app_id);
		signParams.put("appkey", app_key);
		signParams.put("noncestr", noncestr);
		signParams.put("package", packageValue);
		signParams.put("timestamp", timestamp);
		signParams.put("traceid", traceid);

		//生成支付签名，要采用URLENCODER的原始值进行SHA1算法！
		String sign = Sha1Util.createSHA1Sign(signParams);
		//增加非参与签名的额外参数
		signParams.put("app_signature", sign);
		signParams.put("sign_method", "sha1");

		//获取prepayId
		String prepayid = reqHandler.sendPrepay(signParams);

		if (null != prepayid && !"".equals(prepayid)) {
			//签名参数列表
			SortedMap<String, String> prePayParams = new TreeMap<String, String>();
			prePayParams.put("appid", app_id);
			prePayParams.put("appkey", app_key);
			prePayParams.put("noncestr", noncestr);
			prePayParams.put("package", "Sign=WXPay");
			prePayParams.put("partnerid", partner);
			prePayParams.put("prepayid", prepayid);
			prePayParams.put("timestamp", timestamp);
			//生成签名
			sign = Sha1Util.createSHA1Sign(prePayParams);

			//输出参数
			outParams.put("retcode", "0");
			outParams.put("retmsg", "OK");
			outParams.put("appid", app_id);
			outParams.put("partnerid", partner);
			outParams.put("noncestr", noncestr);
			outParams.put("package", "Sign=WXPay");
			outParams.put("prepayid", prepayid);
			outParams.put("timestamp", timestamp);
			outParams.put("sign", sign);
			//测试帐号多个app测试，需要判断Token是否失效，否则重新获取一次 
			if(reqHandler.getLasterrCode()=="40001"){
	         token = reqHandler.getTokenReal();
			}
		} else {
			outParams.put("retcode", "-2");
			outParams.put("retmsg", "错误：获取prepayId失败");
		}
	} else {
		outParams.put("retcode", "-1");
		outParams.put("retmsg", "错误：获取不到Token");
	}
	response.resetBuffer();
	out.clear();
	response.setHeader("ContentType", "text/json");
	Gson gson = new Gson();
	out.println(gson.toJson(outParams));
	out.flush();
%>