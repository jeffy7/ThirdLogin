<?php
//header('Content-type: text/json');
//header('Content-type: text/html; charset=gb2312');
//---------------------------------------------------------
//΢��֧��������ǩ��֧������ʾ�����̻����մ��ĵ����п�������
//---------------------------------------------------------
require_once ("classes/RequestHandler.class.php");

require_once ("./tenpay_config.php");

require_once ("classes/ResponseHandler.class.php");

require ("./classes/client/TenpayHttpClient.class.php");

//��ȡ�ύ����Ʒ�۸�
$order_price=trim($_GET['order_price']);
if($order_price == ''){
	$order_price = '1';
}

//��ȡ�ύ����Ʒ����
$product_name=trim($_GET['product_name']);
if ($product_name == ''){
	$product_name = '������Ʒ����';
}

//��ȡ�ύ�Ķ�����
$out_trade_no=trim($_GET['order_no']);
if ($out_trade_no == ''){
	$out_trade_no = time();
}


$outparams =array();
//��Ʒ�۸񣨰����˷ѣ����Է�Ϊ��λ
$total_fee= $order_price*100;
//�������
$out_type	= strtoupper($_GET['out_type']);
$plat_from	= strtoupper($_GET['plat']);
//��ȡtokenֵ
$reqHandler = new RequestHandler();
$reqHandler->init($APP_ID, $APP_SECRET, $PARTNER_KEY, $APP_KEY);
$Token= $reqHandler->GetToken();
if ( $Token !='' ){
	//=========================
	//����Ԥ֧����
	//=========================
	//����packet֧������
	$packageParams =array();		
	
	$packageParams['bank_type']		= 'WX';	            //֧������
	$packageParams['body']			= $product_name;					//��Ʒ����
	$packageParams['fee_type']		= '1';				//���б���
	$packageParams['input_charset']	= 'GBK';		    //�ַ���
	$packageParams['notify_url']	= $notify_url;	    //֪ͨ��ַ
	$packageParams['out_trade_no']	= $out_trade_no;		        //�̻�������
	$packageParams['partner']		= $PARTNER;		        //�����̻���
	$packageParams['total_fee']		= $total_fee;			//��Ʒ�ܽ��,�Է�Ϊ��λ
	$packageParams['spbill_create_ip']= $_SERVER['REMOTE_ADDR'];  //֧������IP
	//��ȡpackage��
	$package= $reqHandler->genPackage($packageParams);
	$time_stamp = time();
	$nonce_str = md5(rand());
	//����֧������
	$signParams =array();
	$signParams['appid']	=$APP_ID;
	$signParams['appkey']	=$APP_KEY;
	$signParams['noncestr']	=$nonce_str;
	$signParams['package']	=$package;
	$signParams['timestamp']=$time_stamp;
	$signParams['traceid']	= 'mytraceid_001';
	//����֧��ǩ��
	$sign = $reqHandler->createSHA1Sign($signParams);
	//���ӷǲ���ǩ���Ķ������
	$signParams['sign_method']		='sha1';
	$signParams['app_signature']	=$sign;
	//�޳�appkey
	unset($signParams['appkey']); 
	//��ȡprepayid
	$prepayid=$reqHandler->sendPrepay($signParams);

	if ($prepayid != null) {
		$pack	= 'Sign=WXPay';
		//��������б�
		$prePayParams =array();
		$prePayParams['appid']		=$APP_ID;
		$prePayParams['appkey']		=$APP_KEY;
		$prePayParams['noncestr']	=$nonce_str;
		$prePayParams['package']	=$pack;
		$prePayParams['partnerid']	=$PARTNER;
		$prePayParams['prepayid']	=$prepayid;
		$prePayParams['timestamp']	=$time_stamp;
		//����ǩ��
		$sign=$reqHandler->createSHA1Sign($prePayParams);

		$outparams['retcode']=0;
		$outparams['retmsg']='ok';
		$outparams['appid']=$APP_ID;
		$outparams['noncestr']=$nonce_str;
		$outparams['package']=$pack;
		$outparams['prepayid']=$prepayid;
		$outparams['timestamp']=$time_stamp;
		$outparams['sign']=$sign;

	}else{
		$outparams['retcode']=-2;
		$outparams['retmsg']='���󣺻�ȡprepayIdʧ��';
	}
}else{
	$outparams['retcode']=-1;
	$outparams['retmsg']='���󣺻�ȡ����Token';
}


	/**
	=========================
	��������б�
	=========================
	*/
	//Json ���
	ob_clean();
	echo json_encode($outparams);
	//debug��Ϣ,ע��������������ַ�����ҪJsEncode
	if ($DEBUG_ ){
		echo PHP_EOL  .'/*' . ($reqHandler->getDebugInfo()) . '*/';
	}
?> 