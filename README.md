# EYCompressImage
## 手动配置+1行代码，让图片体积缩小一半的强大插件！

###插件说明EXPLAIN
    1.本插件是基于http://tinypng.com 提供服务编写的压缩图片插件。需要先注册服务获取key并在创建对象时配置方可使用。
    2.目前用法相对不是特别方便，需要跟着一下步骤进行配置。
    3.目前为Demo版，有些功能可能还不太完善
    目前已有功能为  1.批量转换图片  2.记录压缩失败图片  3.图片预览。
    
###使用方式USAGE
    1.需要先到https://tinypng.com/developers 填写信息得到API key。
    如图：
    
    2.创建在沙盒目录Douments下创建images文件夹，并将要压缩的图片放进去(如果找不到沙盒也可以先安装，在压缩界面会有沙河路径按钮可以方便看到沙盒位置)。
    2.项目中引入EYCompressImage头文件，并定义一个该类属性或者实例变量。
    3.调用
    -(instancetype)initWithBaseViewController:(UIViewController *)viewController userName:(NSString *)userName password:(NSString *)password;
    方法，userName为申请时填写的，password为邮件返回的key。
    
    至此安装完毕。
    转换后的图片会放在沙盒Documents/target_images文件夹内。





###注意 ATTENTION
本插件基于tinypng服务开发，tinypng免费用户每月只可以进行500张图片转换。

###版权COPY RIGHTS
本插件由tinypng提供服务，由elvain_yang负责开发，作者保留解释权。


  

