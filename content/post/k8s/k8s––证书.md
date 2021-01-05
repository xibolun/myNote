---

date :  "2020-03-11T10:31:51+08:00" 
title : "k8s––证书修改" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
---

### 证书列表

校验一下证书过期属性即可得到以下的证书列表，可以看到默认是一年的有效期；

```shell
[root@ops-pre-4-175 pod]# kubeadm  alpha certs check-expiration
[check-expiration] Reading configuration from the cluster...
[check-expiration] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
W1209 10:32:32.802898   25396 defaults.go:186] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.233.0.10]; the provided value is: [169.254.25.10]

CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Dec 09, 2021 02:22 UTC   364d                                    no
apiserver                  Dec 09, 2021 02:22 UTC   364d            ca                      no
apiserver-kubelet-client   Dec 09, 2021 02:23 UTC   364d            ca                      no
controller-manager.conf    Dec 09, 2021 02:23 UTC   364d                                    no
front-proxy-client         Dec 09, 2021 02:23 UTC   364d            front-proxy-ca          no
scheduler.conf             Dec 09, 2021 02:23 UTC   364d                                    no

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Sep 14, 2030 08:42 UTC   9y              no
front-proxy-ca          Sep 14, 2030 08:42 UTC   9y              no
```

可以看到`CA`的有效期为10年，而`api、schedule`等相关认证的证书时间为1年，为什么是这样呢？

在生成`k8s config`的时候会创建证书和`key`

```go
// cmd/kubeadm/app/util/pkiutil/pki_helpers.go
// NewCertAndKey creates new certificate and key by passing the certificate authority certificate and key
func NewCertAndKey(caCert *x509.Certificate, caKey crypto.Signer, config *CertConfig) (*x509.Certificate, crypto.Signer, error) {
	key, err := NewPrivateKey(config.PublicKeyAlgorithm)
	if err != nil {
		return nil, nil, errors.Wrap(err, "unable to create private key")
	}

	cert, err := NewSignedCert(config, key, caCert, caKey)
	if err != nil {
		return nil, nil, errors.Wrap(err, "unable to sign certificate")
	}

	return cert, key, nil
}
```

```go
// cmd/kubeadm/app/util/pkiutil/pki_helpers.go
// NewSignedCert creates a signed certificate using the given CA certificate and key
func NewSignedCert(cfg *CertConfig, key crypto.Signer, caCert *x509.Certificate, caKey crypto.Signer) (*x509.Certificate, error) {
	serial, err := cryptorand.Int(cryptorand.Reader, new(big.Int).SetInt64(math.MaxInt64))
	if err != nil {
		return nil, err
	}
	if len(cfg.CommonName) == 0 {
		return nil, errors.New("must specify a CommonName")
	}
	if len(cfg.Usages) == 0 {
		return nil, errors.New("must specify at least one ExtKeyUsage")
	}

	RemoveDuplicateAltNames(&cfg.AltNames)

	certTmpl := x509.Certificate{
		Subject: pkix.Name{
			CommonName:   cfg.CommonName,
			Organization: cfg.Organization,
		},
		DNSNames:     cfg.AltNames.DNSNames,
		IPAddresses:  cfg.AltNames.IPs,
		SerialNumber: serial,
		NotBefore:    caCert.NotBefore,
    // 这里引用了一个常量，常量value为
    // 	CertificateValidity = time.Hour * 24 * 365
		NotAfter:     time.Now().Add(kubeadmconstants.CertificateValidity).UTC(),
		KeyUsage:     x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  cfg.Usages,
	}
	certDERBytes, err := x509.CreateCertificate(cryptorand.Reader, &certTmpl, caCert, key.Public(), caKey)
	if err != nil {
		return nil, err
	}
	return x509.ParseCertificate(certDERBytes)
}
```

CA的认证有效期

```go
// staging/src/k8s.io/client-go/util/cert/cert.go
// NewSelfSignedCACert creates a CA certificate
func NewSelfSignedCACert(cfg Config, key crypto.Signer) (*x509.Certificate, error) {
	now := time.Now()
	tmpl := x509.Certificate{
		SerialNumber: new(big.Int).SetInt64(0),
		Subject: pkix.Name{
			CommonName:   cfg.CommonName,
			Organization: cfg.Organization,
		},
		NotBefore:             now.UTC(),
    // 这里指定了10年，可以修改为100年
		NotAfter:              now.Add(duration365d * 10).UTC(),
		KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}

	certDERBytes, err := x509.CreateCertificate(cryptorand.Reader, &tmpl, &tmpl, key.Public(), key)
	if err != nil {
		return nil, err
	}
	return x509.ParseCertificate(certDERBytes)
}
```

### 如何续约

```shell
kubeadm alpha certs renew all
```

`renew all`即可重新生成自当前时间开始，一年的有效证书；但是有一具问题，需要重启`k8s master\node`；

自己做了一个测试，修改一个`k8s`集群的时间

```shell
date -s 12/09/2022
```

```shell
[root@ops-pre-4-175 pki]# kubectl get pods  -n idcos -o wide
Unable to connect to the server: x509: certificate has expired or is not yet valid
```

调用的时候已经出现了证书校验不通过的问题，续签一年，然后再执行命令的时候依旧会报上面的错误；只有重启才可以生效；若想使用长久的证书，并且不重启集群，可以通过修改源码实现；需要了解一下如何编译`k8s`；

#### 镜像编译

下载编译镜像

```shell
docker pull gcrcontainer/kube-cross:v1.13.6-1
```

> 若k8s的版本较高，注意镜像里面的go version需要高一些；

下载指定版本源码

```shell
curl -LO https://github.com/kubernetes/kubernetes/archive/v1.18.12.zip
```

使用镜像编译

```shell
docker run --rm -v <k8s源码路径>:/go/src/k8s.io/kubernetes -it gcrcontainer/kube-cross:v1.13.6-1 bash

cd /go/src/k8s.io/kubernetes

# 编译kubeadm, 这里主要编译kubeadm 即可
make all WHAT=cmd/kubeadm GOFLAGS=-v

# 编译kubelet
# make all WHAT=cmd/kubelet GOFLAGS=-v

# 编译kubectl
# make all WHAT=cmd/kubectl GOFLAGS=-v

# 退出容器
exit

#编译完产物在 _output/bin/kubeadm 目录下，
#其中bin是使用了软连接
#真实路径是_output/local/bin/linux/amd64/kubeadm
mv /usr/bin/kubeadm /usr/bin/kubeadm_backup
cp _output/local/bin/linux/amd64/kubeadm /usr/bin/kubeadm
#chmod +x /usr/bin/kubeadm

# 验证版本
kubeadm version
```
使用新版本的`kubeadm`进行续约

```
kubeadm alpha certs renew all
```

需要重新配置证书

```shell
[root@ops-pre-4-175 pki]# kubectl get pods  -n idcos -o wide
error: You must be logged in to the server (Unauthorized)

cp  /etc/kubernetes/admin.conf ~/.kube/config
```

