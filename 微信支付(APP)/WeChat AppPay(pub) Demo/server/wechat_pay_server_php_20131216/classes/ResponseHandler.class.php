<?php

//��ʱ����֧��Ӧ����
//============================================================================
//api˵����
//getKey()/setKey(),��ȡ/������Կ
//getParameter()/setParameter(),��ȡ/���ò���ֵ
//getAllParameters(),��ȡ���в���
//isTenpaySign(),�Ƿ�Ƹ�ͨǩ��,true:�� false:��
//getDebugInfo(),��ȡdebug��Ϣ
//============================================================================

class ResponseHandler
{
	//��Կ
	var $key;

	//Ӧ��Ĳ���
	var $parameters;

	//debug��Ϣ
	var $debugInfo;

	//��ʼ���캯��
	function __construct() {
		$this->RequestHandler();
	}
	function RequestHandler() {
		$this->gateUrl = "https://wpay.tenpay.com/wx_pub/v1.0/wx_app_api.cgi";
		$this->key = "";
		$this->parameters = array();
		$this->debugInfo = "";
		/* GET */
		foreach($_GET as $k => $v) {
			$this->setParameter($k, $v);
		}
		/* POST */
		foreach($_POST as $k => $v) {
			$this->setParameter($k, $v);
		}
	}
	
	//��ȡ��Կ
	function getKey() {
		return $this->key;
	}
	
	//������Կ
	function setKey($key) {
		$this->key = $key;
	}
	
	//��ȡ����ֵ
	function getParameter($parameter) {
		return $this->parameters[$parameter];
	}
	
	//���ò���ֵ
	function setParameter($parameter, $parameterValue) {
		$this->parameters[$parameter] = $parameterValue;
	}
	//��ղ���ֵ
	function clearParameter(){
		 return $parameters->RemoveAll;
	}
	//��ȡ��������Ĳ���,����Scripting.Dictionary
	function getAllParameters() {
		return $this->parameters;
	}


	/**
	*�Ƿ�Ƹ�ͨǩ��,������:����������a-z����,������ֵ�Ĳ������μ�ǩ����
	*true:��
	*false:��
	*/	
	function isTenpaySign() {
		$signPars = "";
		ksort($this->parameters);
		foreach($this->parameters as $k => $v) {
			if("sign" != $k && "" != $v) {
				$signPars .= $k . "=" . $v . "&";
			}
		}
		$signPars .= "key=" . $this->getKey();
		
		$sign = strtolower(md5($signPars));
		
		$tenpaySign = strtolower($this->getParameter("sign"));
				
		//debug��Ϣ
		$this->_setDebugInfo($signPars . " => sign:" . $sign .
				" tenpaySign:" . $this->getParameter("sign"));
		
		return $sign == $tenpaySign;
		
	}
	
	//��ȡdebug��Ϣ
	function getDebugInfo() {
		return $this->debugInfo;
	}

	function setDebugInfo($debug) {
		$this->debugInfo=$debug;
	}
}
?>