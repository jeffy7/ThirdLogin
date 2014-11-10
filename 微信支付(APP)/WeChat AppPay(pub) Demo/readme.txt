微信APP支付（公众版）注意事项

获取access_token一天内有频次限制，
商户侧必须统一管理access_token，
每次获取的access_token有效期为2个小时，
不能每次获取prepayid都去请求一次，否则超过微信频次限制将无法下单。

demo中，server端的代码是，为了方便商户阅读，直接每次请求都获取了，商户实际开发应该将获取access_token独立处理，请注意此点！！！