<%@ page language="java" contentType="text/html; charset=GBK"
	pageEncoding="GBK"%>
<%@ page import="com.wxap.util.TenpayUtil"%>
<%@ page import="com.wxap.util.MD5Util"%>
<%@ page import="com.wxap.RequestHandler"%>
<%@ page import="com.wxap.ResponseHandler"%>
<%@ page import="com.wxap.client.TenpayHttpClient"%>
<%@ include file="config.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
	//---------------------------------------------------------
	//微信支付通知（后台通知）示例，商户按照此文档进行开发即可
	//---------------------------------------------------------

	//创建支付应答对象

	ResponseHandler resHandler = new ResponseHandler(request, response);
	resHandler.setKey(partner_key);
	//创建请求对象
	RequestHandler queryReq = new RequestHandler(null, null);
	queryReq.init();
	if (resHandler.isTenpaySign() == true) {
		//商户订单号
		String out_trade_no = resHandler.getParameter("out_trade_no");
		//财付通订单号
		String transaction_id = resHandler
				.getParameter("transaction_id");
		//金额,以分为单位
		String total_fee = resHandler.getParameter("total_fee");
		//如果有使用折扣券，discount有值，total_fee+discount=原请求的total_fee
		String discount = resHandler.getParameter("discount");
		//支付结果
		String trade_state = resHandler.getParameter("trade_state");

		//判断签名及结果
		if ("0".equals(trade_state)) {
			//------------------------------
			//即时到账处理业务开始
			//------------------------------

			//处理数据库逻辑
			//注意交易单不要重复处理
			//注意判断返回金额

			//------------------------------
			//即时到账处理业务完毕
			//------------------------------

			System.out.println("即时到账支付成功");
			//给财付通系统发送成功信息，财付通系统收到此结果后不再进行后续通知
		} else {
			System.out.println("即时到账支付失败");
		}
		resHandler.sendToCFT("success");
	} else {
		System.out.println("通知签名验证失败");
		resHandler.sendToCFT("fail");
	}
%>

