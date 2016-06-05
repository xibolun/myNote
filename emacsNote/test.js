import Ember from 'ember';
import uploadFn from 'idcos-enterprise-ui2/utils/file-uploader';
var set = Ember.set,
    setProperties = Ember.setProperties,
    copy = Ember.copy,
    inject = Ember.inject,
    get = Ember.get;
export default Ember.Controller.extend({
    //controller入参
    queryParams: ["id", "type"],
    //服务注入
    pkgSrv: inject.service('api/cm-soft-package/service'),
    operateDefSrv: inject.service('api/cm-soft-operate-definition/service'),
    //变量声明
    softId: '', //软件ID，用于新增的时候保存包信息
    packageId: '', //包ID
    fileInfo: null, //编辑文件时用于记录文件旧值
    editing: null,
    tempFileList: [], //用于存放用户上传多个文件
    autoScriptForm: {
        installScript: '',
        uninstallScript: ''
    }, //脚本form
    infoForm: {
        version: '',
        name: '',
        type: '',
        author: '',
        defaultOwner: '',
        description: '',
        softPackageOsIds: ''
    }, //包form
    dirForm: {
        dirName: ''
    }, //创建目录Form
    operateDefObj: {}, //此项为操作定义编辑操作时变量
    //清空内容
    resetController: function() {
        set(this, 'filetempPath', '');
        set(this, 'folderData', []);
        set(this, 'autoScriptForm', {});
        set(this, 'initForm', {});
        set(this, 'infoForm', {});
        set(this, 'packageId', '');
    },
    /*包名修改的时候进行监视版本号*/
    nameChanged: function() {
        var self = this,
            infoForm = this.get('infoForm'),
            packageId = this.get('packageId'),
            name = infoForm.name,
            pkgSrv = get(this, 'pkgSrv');
        if (!Ember.isBlank(name)) {
            pkgSrv.queryByName(name).then(function(data) {
                var packageBaseData = data.list,
                    newVersion = "1.0.0";
                if (packageBaseData.length > 0) {
                    var lastVersion = packageBaseData[0].version;
                    var versionSplit = lastVersion.split('.');
                    var versionNum = Number(versionSplit[2]) + 1; //新version号
                    if (Ember.isBlank(packageId)) {
                        newVersion = versionSplit[0] + "." + versionSplit[1] + "." + versionNum;
                    } else {
                        newVersion = packageBaseData.findBy("id", packageId).version;
                    }
                }
                set(self, 'infoForm.version', newVersion);
            });
        }
    }.observes('infoForm.name'),
    //插入..文件目录，并排序
    setFileName: function(paramPath, folderList) {
        var filetempPath = get(this, 'filetempPath');
        var parentFilePath = paramPath.substring(0, paramPath.lastIndexOf('/'));
        var fileObj = {
            fileName: '..',
            filePath: parentFilePath,
            directory: true
        };
        var newFolderList = this.sortFileList(folderList);
        if (paramPath !== filetempPath) {
            newFolderList.insertAt(0, fileObj); //将..放在第一个
        }
        return newFolderList;
    },
    /**
     * 根据文件临时目录与当前目录，确定所操作的文件绝对路径
     * @return {[type]} [description]
     */
    getFileAbsoutPath: function() {
        var filetempPath = get(this, 'filetempPath'),
            curFilePath = get(this, 'curFilePath');
        //拼接当前目录的绝对路径
        var fileAbsoutePath = "";
        if (curFilePath === "./") {
            fileAbsoutePath = filetempPath;
        } else {
            fileAbsoutePath = filetempPath + "/" + curFilePath.replace("./", "");
        }
        return fileAbsoutePath;
    },
    /**
     * 文件列表排序
     * 分别对文件夹和文件进行名称的排序
     * @param  {[type]} folderList [description]
     * @return {[type]}            [description]
     */
    sortFileList: function(folderList) {
        var dirList = folderList.filterBy("directory", true);
        var fileList = folderList.filterBy("directory", false);
        dirList.sortBy("fileName");
        fileList.sortBy("fileName");
        dirList.pushObjects(fileList);
        return dirList;
    },
    //编辑文件权限和名称的时候 重置操作
    reset: function() {
        set(this, 'fileInfo', null);
        set(this, 'editing', null);
    },

    /**
     * 根据调用方式id获取调用方式名称，并重新组装数据格式进行显示名称
     * @param  {[type]} operateDefData  [description]
     * @param  {[type]} callingModeData [description]
     * @return {[type]}                 [description]
     */
    getCallingModeNameById: function(operateDefData, callingModeData) {
        //将调用方式id转换成显示名称，用于前台展示
        if (!Ember.isBlank(operateDefData) && !Ember.isBlank(callingModeData)) {
            for (var i = operateDefData.length - 1; i >= 0; i--) {
                var callingModeId = operateDefData[i].callingModeId;
                var callingMode = callingModeData.findBy('id', callingModeId);
                set(operateDefData[i], 'callingModeName', callingMode.name);
            }
        }
        return operateDefData;
    },

    /**
     * 事件集合
     * @type {Object}
     */
    actions: {
        /**
         * 模态框控制显示
         * @return {[type]} [description]
         */
        toggleModal: function(showingParam) {
            this.toggleProperty(showingParam);
        },
        /**
         * 选择不同的标签，时显示不同的tab内容
         * @param  {[itemId]}
         */
        selectAction: function(itemId) {
            set(this, 'activeItem', itemId);
        },
        /**
         *  新增，更新包
         * 若type为add，则新增，提交ajax为softId与infoForm
         * 若type为edit，则修改，提交ajax为packageId与infoForm
         * @param  {[type]}
         * @return {[type]}
         */
        savePackageAction: function(infoForm) {
            var softId = get(this, 'softId'),
                pkgSrv = get(this, 'pkgSrv'),
                self = this,
                packageId = get(this, 'packageId');
            // //取出选中的radio的值，若选中则packageTypeData当中的checked值为true
            // infoForm.type = packageTypeData.findBy('checked', true).code;
            if (Ember.isBlank(packageId)) {
                if (Ember.isBlank(softId)) {
                    swal("软件id不能为空");
                    return;
                }
                pkgSrv.create(softId, infoForm).then(function(data) {
                    swal(data.message);
                    if (data.status === "success") {
                        // set(self, 'activeItem', itemId);
                        set(self, 'packageId', data.item);
                    }
                });
            } else {
                pkgSrv.update(packageId, infoForm).then(function(data) {
                    swal(data.message);
                    if (data.status === "success") {
                        // set(self, 'activeItem', itemId);
                        set(self, 'packageId', data.item);
                    }
                });
            }
        },
        /**
         * 保存文件信息，用于保存用户对于包文件的操作
         * @param  {[type]} itemId [description]
         * @return {[type]}        [description]
         */
        saveFolerAction: function() {
            var filetempPath = get(this, 'filetempPath'),
                pkgSrv = get(this, 'pkgSrv'),
                packageId = get(this, 'packageId'),
                self = this,
                autoScriptForm = {
                    postinstallContent: "",
                    postuninstallContent: "",
                    preinstallContent: "",
                    preuninstallContent: ""
                };
            pkgSrv.initShell(filetempPath, packageId).then(function(data) {
                swal(data.message);
                if (data.status === "success") {
                    // set(self, 'activeItem', itemId);
                    autoScriptForm.postinstallContent = data.item.postinstallContent;
                    autoScriptForm.postuninstallContent = data.item.postuninstallContent;
                    autoScriptForm.preinstallContent = data.item.preinstallContent;
                    autoScriptForm.preuninstallContent = data.item.preuninstallContent;
                    set(self, 'autoScriptForm', autoScriptForm);
                    set(self, 'filetempPath', data.item.packageFilePath);
                }
            });
        },

        /**
         * 保存脚本
         * 保存脚本成功之后
         * @param  {[type]}
         * @return {[type]}
         */
        saveAutoScriptAction: function(autoScriptForm) {
            var filetempPath = get(this, 'filetempPath'),
                packageId = get(this, 'packageId'),
                pkgSrv = get(this, 'pkgSrv'),
                self = this;
            if (Ember.isBlank(packageId)) {
                swal("packageId不能为空");
                return;
            }
            autoScriptForm.filePath = filetempPath; //将脚本文件写入虚拟目录当中
            pkgSrv.saveShell(autoScriptForm).then(function(data) {
                swal(data.message);
                if ("success" === data.status) {
                    // set(self, 'activeItem', itemId);
                    pkgSrv.saveInitData(filetempPath, packageId).then(function(data) {
                        set(self, 'initForm', {
                            "initData": data.item
                        });
                    });
                }
            });
        },
        /**
         * 修改发布接口，实现打包与发布一体操作，直接打包并上传至yum源当中
         * 发布tar包到远程仓库，修改包的状态
         * @param  {[type]}
         * @return {[type]}
         */
        releaseAction: function() {
            var packageFilePath = get(this, 'filetempPath'),
                pkgInfo = get(this, 'infoForm'),
                packageId = get(this, 'packageId'),
                pkgSrv = get(this, 'pkgSrv');
            var packageName = pkgInfo.name + "-" + pkgInfo.version;
            var postData = {
                "packageId": packageId,
                "packageFilePath": packageFilePath,
                "packagePath": packageName
            };
            pkgSrv.tarFile(postData).then(function(data) {
                if (data.status === 'success') {
                    pkgSrv.releaseFile(packageId).then(function(data) {
                        if (data.status === "success") {
                            swal("提交成功");
                        } else {
                            swal("提交失败");
                        }
                    });
                }
            });
        },
        /**
         *  根据文件目录查询目录下的所有文件
         * @param  {[fileInfo]}
         * @return {[type]}
         */
        queryFileListAction: function(fileInfo) {
            var filetempPath = get(this, 'filetempPath'),
                fileAbsoutePath = fileInfo.filePath,
                pkgSrv = get(this, 'pkgSrv'),
                self = this;
            var curFilePath = "./" + fileAbsoutePath.substring(filetempPath.length + 1, fileAbsoutePath.length);
            pkgSrv.queryFileList(fileAbsoutePath).then(function(data) {
                set(self, 'folderData', self.setFileName(fileAbsoutePath, data.list));
            });
            set(this, 'curFilePath', curFilePath);
        },
        /**
         *  本地上传，弹出模态框操作
         * @param  {[type]}
         * @return {[type]}
         */
        addNewFileAction: function() {
            //写入当前的文件路径
            var curFilePath = get(this, 'curFilePath');
            var fileForm = {
                curPath: curFilePath,
                permission: '644',
                isDelSrc: true
            };
            $('.file-uploader')[0].value = '';
            set(this, 'fileForm', fileForm);
            set(this, 'tempFileList', []);
            this.send('toggleModal', 'fileUploadShowing');
        },
        /**
         *  刷新文件列表
         * @param  {[type]}
         * @return {[type]}
         */
        refreshFileAction: function() {
            var self = this,
                pkgSrv = get(this, 'pkgSrv');
            //拼接当前目录的绝对路径
            var fileAbsoutePath = this.getFileAbsoutPath();
            //查询文件列表
            pkgSrv.queryFileList(fileAbsoutePath).then(function(data) {
                set(self, "folderData", self.setFileName(fileAbsoutePath, data.list));
            });
        },
        /**
         * 上传文件至临时路径
         * [upload description]
         * @param  {[type]} files [description]
         * @return {[type]}       [description]
         */
        upload: function(files) {
            var self = this;
            //可选参数说明：1、文件上传的后端保存地址  2、ajax交互的数据类型，可选参数有：html,json等
            uploadFn(files, '/cm/soft/package/importFile', 'json').then(function(response) {
                //后端输出的内容
                if (response.status = "success") {
                    set(self, 'tempFileList', response.item);
                }
            });
        },
        /**
         * 将导入的文件信息上传
         * 上传成功，刷新界面
         * @param  {[type]}
         * @return {[type]}
         */
        uploadFileAction: function() {
            var self = this,
                tempFileList = get(this, 'tempFileList'),
                pkgSrv = get(this, 'pkgSrv'),
                fileForm = get(this, 'fileForm'),
                tempFileListStr = "";
            if (tempFileList.length <= 0) {
                swal("上传文件内容不能为空");
                return;
            } else {
                //用逗号分隔文件名称
                tempFileListStr = tempFileList.join(",");
                //拼接当前目录的绝对路径
                var fileAbsoutePath = this.getFileAbsoutPath();
                var uploadParam = {
                    fileAbsoutePath: fileAbsoutePath,
                    permission: "" + fileForm.permission,
                    tempFileList: tempFileListStr,
                    isDelSrc: fileForm.isDelSrc
                };
                pkgSrv.uploadFile(uploadParam).then(function(data) {
                    swal(data.message);
                    if (data.status === "success") {
                        pkgSrv.queryFileList(fileAbsoutePath).then(function(data) {
                            set(self, 'folderData', self.setFileName(fileAbsoutePath, data.list));
                        });
                        self.send('toggleModal', 'fileUploadShowing');
                    }
                });
            }
        },
        /**
         *  删除文件操作
         * @param  {[fileInfo]} fileInfo
         * @return {[type]}
         */
        deleteFileAction: function(fileInfo) {
            var filetempPath = get(this, 'filetempPath'),
                name = fileInfo.fileName,
                pkgSrv = get(this, 'pkgSrv'),
                self = this;
            var filePath = filetempPath + "/" + name;
            //拼接当前目录的绝对路径
            var fileAbsoutePath = this.getFileAbsoutPath();
            swal({
                title: "是否删除文件?",
                type: "warning",
                showCancelButton: true,
                confirmButtonClass: "btn-danger",
                cancelButtonText: "取消",
                confirmButtonText: "删除",
                closeOnConfirm: false
            }, function(isConfirm) {
                if (isConfirm) {
                    pkgSrv.deleteFile(filePath).then(function(data) {
                        return data;
                    }).then(function(data) {
                        if ("success" === data.status) {
                            swal(data.message);
                            pkgSrv.queryFileList(fileAbsoutePath).then(function(data) {
                                set(self, 'folderData', self.setFileName(fileAbsoutePath, data.list));
                            });
                        }
                    });
                }
            });
        },
        /**
         * 显示创建目录模态框，并且将内容清空
         * @return {[type]} [description]
         */
        toggleDirShowing: function() {
            var dirForm = {
                dirName: ""
            };
            set(this, 'dirForm', dirForm);
            this.send('toggleModal', 'createDirShowing');
        },
        /**
         * 创建目录操作
         * @param  {[type]}
         * @return {[type]}
         */
        createDirAction: function() {
            var self = this,
                pkgSrv = get(this, 'pkgSrv'),
                dirForm = get(this, 'dirForm');
            var dirName = dirForm.dirName;
            if (Ember.isBlank(dirName)) {
                swal('请输入文件目录名');
                return;
            }
            //拼接当前目录的绝对路径
            var fileAbsoutePath = this.getFileAbsoutPath();
            //拼接创建目录的绝对路径
            var dirAbsoutPath = fileAbsoutePath + '/' + dirName;
            pkgSrv.createFile(dirAbsoutPath).then(function(data) {
                if ("success" === data.status) {
                    swal("创建成功");
                    pkgSrv.queryFileList(fileAbsoutePath).then(function(data) {
                        set(self, 'folderData', self.setFileName(fileAbsoutePath, data.list));
                    });
                } else {
                    swal(data.message);
                }
                self.send('toggleModal', 'createDirShowing');
            });
        },
        /**
         * 修改文件名称和文件权限操作
         * @param  {[type]} obj [description]
         * @return {[type]}     [description]
         */
        editFileAction: function(obj) {
            set(this, 'fileInfo', copy(obj));
            set(this, 'editing', obj);
        },
        /**
         * 保存修改文件名称和文件权限操作
         * @return {[type]} [description]
         */
        save: function() {
            var editingObj = get(this, 'editing'),
                pkgSrv = get(this, 'pkgSrv'),
                self = this;
            var filePath = editingObj.filePath;
            var name = editingObj.fileName;
            var permissionNumberFormat = parseInt(editingObj.permissionNumberFormat);
            if (Ember.isNone(permissionNumberFormat) || permissionNumberFormat > 777) {
                alert("输入正确的权限");
                return;
            }
            if (Ember.isNone(name)) {
                alert("文件名称不能为空");
                return;
            }
            var obj = {
                filePath: filePath,
                fileNewName: name,
                filePermission: permissionNumberFormat
            };
            pkgSrv.editFile(obj).then(function(data) {
                if ("success" === data.status) {
                    alert(data.message);
                    set(self, 'resMsg', 'success');
                }
            });
            this.reset();
        },
        /**
         * 取消修改文件名称和文件权限
         * @return {[type]} [description]
         */
        cancel: function() {
            setProperties(get(this, 'editing'), get(this, 'fileInfo'));
            this.reset();
        },

        /**
         * 新建操作定义
         */
        addOperateAction: function() {
            var operateDefForm = {
                name: '',
                userName: '',
                callingModeId: '',
                callingFile: '',
                callingParam: '',
                description: '',
                packageId: ''
            };
            set(this, 'operateDefForm', operateDefForm);
            this.send('toggleModal', 'operateDefShowing');
        },

        /**
         * 编辑操作定义
         * @param  {[type]} operateDefObj [description]
         * @return {[type]}            [description]
         */
        editOperateAction: function(operateDefObj) {
            set(this, 'operateDefObj', operateDefObj);
            set(this, 'operateDefForm', Ember.copy(operateDefObj));
            this.send('toggleModal', 'operateDefShowing');
        },

        /**
         * 删除操作定义
         * @param  {[type]} operateDefObj [description]
         * @return {[type]}            [description]
         */
        deleteOperateAction: function(operateDefObj) {
            var operateDefSrv = get(this, 'operateDefSrv'),
                operateDefId = operateDefObj.id,
                callingModeData = get(this, 'callingModeData'),
                self = this;

            if (Ember.isBlank(operateDefId)) {
                swal("操作定义数据id不能为空");
                return;
            }

            swal({
                title: "是否删除此项?",
                type: "warning",
                showCancelButton: true,
                confirmButtonClass: "btn-danger",
                cancelButtonText: "取消",
                confirmButtonText: "删除",
                closeOnConfirm: false
            }, function(isConfirm) {
                if (isConfirm) {
                    operateDefSrv.delete(operateDefId).then(function(data) {
                        swal(data.message);
                        if (data.status === "success") {
                            operateDefSrv.queryAll().then(function(res) {
                                var operateDefData = self.getCallingModeNameById(res.list, callingModeData);
                                set(self, 'operateDefData', operateDefData);
                            });
                        }
                    });
                }
            });
        },

        /**
         * 保存操作定义操作
         * @return {[type]} [description]
         */
        saveOperateAction: function() {
            var operateDefSrv = get(this, 'operateDefSrv'),
                operateDefForm = get(this, 'operateDefForm'),
                packageId = get(this, 'packageId'),
                callingModeData = get(this, 'callingModeData'),
                self = this,
                operateDefId = operateDefForm.id;

            if (Ember.isBlank(packageId)) {
                swal("包信息不能为空");
                return;
            }

            set(operateDefForm, 'packageId', packageId);

            if (Ember.isBlank(operateDefId)) {
                operateDefSrv.create(operateDefForm).then(function(data) {
                    swal(data.message);
                    if (data.status === "success") {
                        self.send('toggleModal', 'operateDefShowing');
                        operateDefSrv.queryAll().then(function(res) {
                            var operateDefData = self.getCallingModeNameById(res.list, callingModeData);
                            set(self, 'operateDefData', operateDefData);
                        });
                    }
                });
            } else {
                operateDefSrv.update(operateDefId, operateDefForm).then(function(data) {
                    swal(data.message);
                    if (data.status === "success") {
                        self.send('toggleModal', 'operateDefShowing');
                        operateDefSrv.queryAll().then(function(res) {
                            var operateDefData = self.getCallingModeNameById(res.list, callingModeData);
                            set(self, 'operateDefData', operateDefData);
                        });
                    }
                });
            }
        }
    }

});



