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
	//΢��֧��֪ͨ����̨֪ͨ��ʾ�����̻����մ��ĵ����п�������
	//---------------------------------------------------------

	//����֧��Ӧ�����

	ResponseHandler resHandler = new ResponseHandler(request, response);
	resHandler.setKey(partner_key);
	//�����������
	RequestHandler queryReq = new RequestHandler(null, null);
	queryReq.init();
	if (resHandler.isTenpaySign() == true) {
		//�̻�������
		String out_trade_no = resHandler.getParameter("out_trade_no");
		//�Ƹ�ͨ������
		String transaction_id = resHandler
				.getParameter("transaction_id");
		//���,�Է�Ϊ��λ
		String total_fee = resHandler.getParameter("total_fee");
		//�����ʹ���ۿ�ȯ��discount��ֵ��total_fee+discount=ԭ�����total_fee
		String discount = resHandler.getParameter("discount");
		//֧�����
		String trade_state = resHandler.getParameter("trade_state");

		//�ж�ǩ�������
		if ("0".equals(trade_state)) {
			//------------------------------
			//��ʱ���˴���ҵ��ʼ
			//------------------------------

			//�������ݿ��߼�
			//ע�⽻�׵���Ҫ�ظ�����
			//ע���жϷ��ؽ��

			//------------------------------
			//��ʱ���˴���ҵ�����
			//------------------------------

			System.out.println("��ʱ����֧���ɹ�");
			//���Ƹ�ͨϵͳ���ͳɹ���Ϣ���Ƹ�ͨϵͳ�յ��˽�����ٽ��к���֪ͨ
		} else {
			System.out.println("��ʱ����֧��ʧ��");
		}
		resHandler.sendToCFT("success");
	} else {
		System.out.println("֪ͨǩ����֤ʧ��");
		resHandler.sendToCFT("fail");
	}
%>

