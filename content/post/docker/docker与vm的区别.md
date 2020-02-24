### docker与vm的区别

### image原理

- UnionFS
- 加载原理
  - bootfs、rootfs

### dockerfile

- 关键字列表
- CMD与entrypoint的区别
  - docker run 的参数会将CMD进行覆盖，因为只有最后一个CMD生效
  - docker run的参数会追求参数至CMD的参数里面