<?php
/**
 * ������
 * ============================================================================
 * api˵����
 * init(),��ʼ��������Ĭ�ϸ�һЩ������ֵ����cmdno,date�ȡ�
 * getGateURL()/setGateURL(),��ȡ/������ڵ�ַ,����������ֵ
 * getKey()/setKey(),��ȡ/������Կ
 * getParameter()/setParameter(),��ȡ/���ò���ֵ
 * getAllParameters(),��ȡ���в���
 * getRequestURL(),��ȡ������������URL
 * getDebugInfo(),��ȡdebug��Ϣ
 * 
 * ============================================================================
 *
 */
class RequestHandler {
	
	/** Token��ȡ���ص�ַ*/
	var $tokenUrl;
	
	/**Ԥ֧������url��ַ */
	var $gateUrl;
	
	/** �̻����� */
	var $app_id, $partner_key, $app_secret, $app_key;

	/**  Token */
	var $Token;

	/** debug��Ϣ */
	var $debugInfo;

	function __construct(){
		$this->RequestHandler();
	}
	function RequestHandler(){
		$this->tokenUrl		= 'https://api.weixin.qq.com/cgi-bin/token';
		$this->gateUrl		= 'https://api.weixin.qq.com/pay/genprepay';
		$this->notifyUrl	= 'https://gw.tenpay.com/gateway/simpleverifynotifyid.xml';
	}
	/**
	*��ʼ��������
	*/
	function init($appid, $appsecret,$partnerkey, $appkey) {
		$this->debugInfo	= '';
		$this->Token		= '';
		$this->app_id		= $appid;
		$this->partner_key	= $partnerkey;
		$this->app_secret	= $appsecret;
		$this->app_key		= $appkey;
	}
	/**
	*��ȡdebug��Ϣ
	*/
	function getDebugInfo() {
		$res = $this->debugInfo;
		$this->debugInfo = '';
		return $res;
	}

	//
	function httpSend($url, $method, $data){
		$client = new TenpayHttpClient();
		$client->setReqContent($url);
		$client->setMethod($method);
		$client->setReqBody($data);
		$res =  '';
		if( $client->call()){
			$res =  $client->getResContent();
		}
		//����debug��Ϣ
		$this->_setDebugInfo('Req Url:' .$url);
		$this->_setDebugInfo('Req data:' .$data);
		$this->_setDebugInfo('Res Content:' .$res);

		return $res;
	}

	//��ȡTOKEN��һ������ȡ200��
	function GetToken(){
		$url= $this->tokenUrl . '?grant_type=client_credential&appid='.$this->app_id .'&secret='.$this->app_secret;
		$json=$this->httpSend($url,'GET','');
		if( $json != ""){
			$tk = json_decode($json);
			if( $tk->access_token != "" )
			{
				$this->Token =$tk->access_token;
			}else{
				$this->Token = '';
			}
		}
		//����debug��Ϣ
		$this->_setDebugInfo('tokenUrl:' .$url);
		$this->_setDebugInfo('tokenRes jsonContent:' .$json);
		return $this->Token;
	}

	/**
	*����packageǩ��
	*/
	function createMd5Sign($signParams) {
		$signPars = '';
		
		ksort($signParams);
		foreach($signParams as $k =>$v) {
			if($v != "" && 'sign' !=$k) {
				$signPars .= $k . '=' .$v.'&';
			}
		}
			$signPars .= 'key=' .$this->partner_key;
		
		$sign = strtoupper(md5($signPars));	
		//debug��Ϣ
		$this->_setDebugInfo('md5ǩ��:'.$signPars . ' => sign:' .$sign);

		return $sign;
		
	}	

	//��ȡ��������ǩ����
	function genPackage($packageParams){
		
		$sign = $this->createMd5Sign($packageParams);
		$reqPars = '';
		foreach ($packageParams as $k =>$v ){
			$reqPars.=$k . '='.URLencode($v) . '&';
		}
		$reqPars = $reqPars . 'sign=' .$sign;
		//debug��Ϣ
		$this->_setDebugInfo('gen package:' .$reqPars);

		return $reqPars;
	}
	
	//����ǩ��SHA1
	function createSHA1Sign($packageParams){
		$signPars = '';
		ksort($packageParams);
		foreach($packageParams as $k=> $v) {
			if($signPars == ''){
				$signPars =$signPars .$k. '=' .$v;
			}else{
				$signPars =$signPars. '&' .$k. '=' .$v;
			}
		}

		$sign = SHA1($signPars);
		
		//debug��Ϣ
		$this->_setDebugInfo('sha1:' .$signPars .'=>'. $sign);

		return $sign;		
	}
	
	//�ύԤ֧��
	function sendPrepay($packageParams){

		$prepayid=null;

		$reqPars= json_encode($packageParams);
		

		$url= $this->gateUrl .'?access_token='.$this->Token;

		$json=$this->httpSend($url,'POST',$reqPars);
		$tk= json_decode($json);
		//echo "aaaaaaaaaaaaaaaaaaa".$json."ccccccccccccccccccccc<br>";
		if ( $tk->errcode == 0){

			$prepayid= $tk->prepayid;
		}


		return $prepayid;
	}
	/**
	*����debug��Ϣ
	*/
	function _setDebugInfo($debugInfo) {
		$this->debugInfo = PHP_EOL.$this->debugInfo.$debugInfo.PHP_EOL;
	}
}
?>