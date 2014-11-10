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
	//'΢��֧��������ǩ��֧������ʾ�����̻����մ��ĵ����п�������
	//'����˷������ݣ�App��ȡ�����ݺ��ֱ�ӵ���΢��֧��
	//---------------------------------------------------------

	//---------------���ɶ����� ��ʼ------------------------
	//��ǰʱ�� yyyyMMddHHmmss
	String currTime = TenpayUtil.getCurrTime();
	//8λ����
	String strTime = currTime.substring(8, currTime.length());
	//��λ�����
	String strRandom = TenpayUtil.buildRandom(4) + "";
	//10λ���к�,�������е�����
	String strReq = strTime + strRandom;
	//�����ţ��˴���ʱ�����������ɣ��̻������Լ����������ֻҪ����ȫ��Ψһ����
	String out_trade_no = strReq;
	//---------------���ɶ����� ����------------------------

	//��ȡ�ύ����Ʒ�۸�
	String order_price = request.getParameter("order_price");
	//��ȡ�ύ����Ʒ����
	String product_name = request.getParameter("product_name");

	TreeMap<String, String> outParams = new TreeMap<String, String>();

	RequestHandler reqHandler = new RequestHandler(request, response);
	TenpayHttpClient httpClient = new TenpayHttpClient();
    //��ʼ�� 
	reqHandler.init();
	reqHandler.init(app_id, app_secret, app_key, partner, partner_key);

	//��ȡtokenֵ 
	String token = reqHandler.GetToken();
	if (!"".equals(token)) {
		//=========================
		//����Ԥ֧����
		//=========================
		//����package��������
		SortedMap<String, String> packageParams = new TreeMap<String, String>();
		packageParams.put("bank_type", "WX"); //��Ʒ����   
		packageParams.put("body", "������Ʒ����"); //��Ʒ����   
		packageParams.put("notify_url", notify_url); //���ղƸ�֪ͨͨ��URL  
		packageParams.put("partner", partner); //�̻���    
		packageParams.put("out_trade_no", "out_trade_no"); //�̼Ҷ�����  
		packageParams.put("total_fee", "1"); //��Ʒ���,�Է�Ϊ��λ  
		packageParams.put("spbill_create_ip", request.getRemoteAddr()); //�������ɵĻ���IP��ָ�û��������IP  
		packageParams.put("fee_type", "1"); //���֣�1�����   66
		packageParams.put("input_charset", "GBK"); //�ַ�����

		//��ȡpackage��
		String packageValue = reqHandler.genPackage(packageParams);

		String noncestr = Sha1Util.getNonceStr();
		String timestamp = Sha1Util.getTimeStamp();
		String traceid = "mytestid_001";

		//����֧������
		SortedMap<String, String> signParams = new TreeMap<String, String>();
		signParams.put("appid", app_id);
		signParams.put("appkey", app_key);
		signParams.put("noncestr", noncestr);
		signParams.put("package", packageValue);
		signParams.put("timestamp", timestamp);
		signParams.put("traceid", traceid);

		//����֧��ǩ����Ҫ����URLENCODER��ԭʼֵ����SHA1�㷨��
		String sign = Sha1Util.createSHA1Sign(signParams);
		//���ӷǲ���ǩ���Ķ������
		signParams.put("app_signature", sign);
		signParams.put("sign_method", "sha1");

		//��ȡprepayId
		String prepayid = reqHandler.sendPrepay(signParams);

		if (null != prepayid && !"".equals(prepayid)) {
			//ǩ�������б�
			SortedMap<String, String> prePayParams = new TreeMap<String, String>();
			prePayParams.put("appid", app_id);
			prePayParams.put("appkey", app_key);
			prePayParams.put("noncestr", noncestr);
			prePayParams.put("package", "Sign=WXPay");
			prePayParams.put("partnerid", partner);
			prePayParams.put("prepayid", prepayid);
			prePayParams.put("timestamp", timestamp);
			//����ǩ��
			sign = Sha1Util.createSHA1Sign(prePayParams);

			//�������
			outParams.put("retcode", "0");
			outParams.put("retmsg", "OK");
			outParams.put("appid", app_id);
			outParams.put("partnerid", partner);
			outParams.put("noncestr", noncestr);
			outParams.put("package", "Sign=WXPay");
			outParams.put("prepayid", prepayid);
			outParams.put("timestamp", timestamp);
			outParams.put("sign", sign);
			//�����ʺŶ��app���ԣ���Ҫ�ж�Token�Ƿ�ʧЧ���������»�ȡһ�� 
			if(reqHandler.getLasterrCode()=="40001"){
	         token = reqHandler.getTokenReal();
			}
		} else {
			outParams.put("retcode", "-2");
			outParams.put("retmsg", "���󣺻�ȡprepayIdʧ��");
		}
	} else {
		outParams.put("retcode", "-1");
		outParams.put("retmsg", "���󣺻�ȡ����Token");
	}
	response.resetBuffer();
	out.clear();
	response.setHeader("ContentType", "text/json");
	Gson gson = new Gson();
	out.println(gson.toJson(outParams));
	out.flush();
%>