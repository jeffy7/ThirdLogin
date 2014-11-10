<?php

//---------------------------------------------------------
//��ʱ����֧����̨�ص�ʾ�����̻����մ��ĵ����п�������
//---------------------------------------------------------

require ("classes/ResponseHandler.class.php");
require ("classes/RequestHandler.class.php");
require ("classes/client/ClientResponseHandler.class.php");
require ("classes/client/TenpayHttpClient.class.php");
require ("./classes/function.php");
require_once ("./tenpay_config.php");

log_result("�����̨�ص�ҳ��");

/* ����֧��Ӧ����� */
$resHandler = new ResponseHandler();
$resHandler->setKey($key);

//��ʼ��ҳ���ύ�����Ĳ���
$resHandler->Init()��

	//�ж�ǩ��
	if($resHandler->isTenpaySign() == true) {
			//�̻����յ���̨֪ͨ�����֪ͨID��Ƹ�ͨ������֤ȷ�ϣ����ú�̨ϵͳ���ý���ģʽ	
			$notify_id = $resHandler->getParameter("notify_id");//֪ͨid
		
			//�̻����׵���
			$out_trade_no = $resHandler->getParameter("out_trade_no");
			
			
			//�Ƹ�ͨ������
			$transaction_id = $resHandler->getParameter("transaction_id");

			//��Ʒ���,�Է�Ϊ��λ
			$total_fee = $resHandler->getParameter("total_fee");

			//�����ʹ���ۿ�ȯ��discount��ֵ��total_fee+discount=ԭ�����total_fee
			$discount = $resHandler->getParameter("discount");

			//֧�����
			$trade_state = $resHandler->getParameter("trade_state");
			//�ɻ�ȡ��������������
			//bank_type			��������,Ĭ�ϣ�BL
			//fee_type			�ֽ�֧������,Ŀǰֻ֧�������,Ĭ��ֵ��1-�����
			//input_charset		�ַ�����,ȡֵ��GBK��UTF-8��Ĭ�ϣ�GBK��
			//partner			�̻���,�ɲƸ�ͨͳһ�����10λ������(120XXXXXXX)��
			//product_fee		��Ʒ���ã���λ�֡������ֵ�����뱣֤transport_fee + product_fee=total_fee
			//sign_type			ǩ�����ͣ�ȡֵ��MD5��RSA��Ĭ�ϣ�MD5
			//time_end			֧�����ʱ��
			//transport_fee		�������ã���λ�֣�Ĭ��0�������ֵ�����뱣֤transport_fee +  product_fee = total_fee

			//�ж�ǩ�������
			if ("0" = trade_state){
			//----------------------
			//��ʱ���ʴ���ҵ��ʼ
			//-----------------------
			//�������ݿ��߼�
			//ע�⽻�׵���Ҫ�ظ�����
			//ע���жϷ��ؽ��
			//-----------------------
			//��ʱ���ʴ���ҵ�����
			//-----------------------
			//���Ƹ�ͨϵͳ���ͳɹ���Ϣ�����Ƹ�ͨϵͳ�յ��˽�����ڽ��к���֪ͨ
			log_result("��̨֪ͨ�ɹ�");
		} else {
			log_result("��̨֪ͨʧ��");
		}
		//�ظ�����������ɹ�
			echo "Success";
} else {
	echo "<br/>" . "��֤ǩ��ʧ��" . "<br/>";
	echo $resHandler->getDebugInfo() . "<br>";
}
?>